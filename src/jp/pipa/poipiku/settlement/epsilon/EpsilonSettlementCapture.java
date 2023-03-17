package jp.pipa.poipiku.settlement.epsilon;

import jp.pipa.poipiku.util.Log;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicHeader;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilderFactory;
import java.io.InputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

// EPSILON実売上API呼び出しクラス
public class EpsilonSettlementCapture extends  EpsilonSettlement{
//	private String captureUrl;
	// dev
//	private static final String DEV_CAPTURE_URL = "https://beta.epsilon.jp/cgi-bin/order/sales_payment.cgi";
	// production
//	private static final String PROD_CAPTURE_URL = "https://secure.epsilon.jp/cgi-bin/order/sales_payment.cgi";

	private SettlementCaptureSendInfo settlementCaptureSendInfo;
	public SettlementCaptureSendInfo getSettlementCaptureInfo() {
		return settlementCaptureSendInfo;
	}

	public void setSettlementCaptureSendInfo(SettlementCaptureSendInfo settlementCaptureSendInfo) {
		this.settlementCaptureSendInfo = settlementCaptureSendInfo;
	}

	private void initUrl() {
		if (connectTo == ConnectTo.Dev) {
			Log.d("開発用CGIへ接続");
			//captureUrl = DEV_CAPTURE_URL;
		} else {
			//captureUrl = PROD_CAPTURE_URL;
		}
	}

	public EpsilonSettlementCapture(int userId){
		super(userId);
		initUrl();
		this.setSettlementCaptureSendInfo(new SettlementCaptureSendInfo());
	}
	public EpsilonSettlementCapture(int userId, SettlementCaptureSendInfo settlementCaptureSendInfo){
		super(userId);
		initUrl();
		this.setSettlementCaptureSendInfo(settlementCaptureSendInfo);
	}

	// 決済情報送信処理
	public SettlementCaptureResultInfo execSettlement(){
		// 決済情報送信
		// 送信用の設定を作成
//		RequestConfig rc = RequestConfig.custom().setConnectTimeout(60000)
//				.setSocketTimeout(60000)
//				.setMaxRedirects(0)
//				.build();
		// Header定義
		List<Header> header = new ArrayList<>();
		header.add( new BasicHeader("Accept-Charset","UTF-8" ));
		header.add( new BasicHeader("User-Agent","EPSILON SAMPLE PROGRAM JAVA" ));

//		HttpClient client = HttpClientBuilder.create()
//				.setDefaultRequestConfig(rc)
//				.setDefaultHeaders(header)
//				.build();

		List<NameValuePair> param = this.makeSendParam();
		Log.d("key => value");
		for(NameValuePair p : param){
			Log.d(String.format("%s => %s", p.getName(), p.getValue()));
		}
		HttpPost post = new HttpPost();
		HttpResponse res = null;

		try {
			post.setEntity(new UrlEncodedFormEntity(param,"UTF-8"));
//			post.setURI(new URI(captureUrl));
//			res = client.execute(post);
		}catch(Exception e){
			e.printStackTrace();
			notifyErrorToSlack("EpsilonSettlementCancel:client.execute()で例外発生");
			return null;
		}
		SettlementCaptureResultInfo settleResultInfo = new SettlementCaptureResultInfo();
		if( res.getStatusLine().getStatusCode() == HttpStatus.SC_OK ){
			// BODYを取得してXMLパーサー呼び出し
			try{
				String xml = EntityUtils.toString(res.getEntity(), StandardCharsets.UTF_8);
				//x-sjis-cp932だとエンコーダの未対応でエラーとなる
				xml = xml.replace("x-sjis-cp932", "Shift_JIS");
				//System.out.println(xml);
				InputStream body = new java.io.ByteArrayInputStream(xml.getBytes());
				Document xmlDoc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(body);

				NodeList resultList = xmlDoc.getElementsByTagName("result");
				for( int i = 0; i < resultList.getLength(); i++) {
					Node node = resultList.item(i);
					NamedNodeMap namedNodeMap = node.getAttributes();
					for( int j =0; j < namedNodeMap.getLength(); j++ ){
						Node attr = namedNodeMap.item(j);
						switch (attr.getNodeName()) {
							case "result":
								settleResultInfo.setResult(attr.getNodeValue());
								break;
							case "err_code":
								settleResultInfo.setErrCode(attr.getNodeValue());
								break;
							case "err_detail":
								settleResultInfo.setErrDetail(new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
						}
					}
				}
			}catch(Exception e){
				Log.d("caught exception");
				for(NameValuePair p : param){
					Log.d(String.format("%s => %s", p.getName(), p.getValue()));
				}
				e.printStackTrace();
				notifyErrorToSlack("EpsilonSettlementCancel:resultInfo解析で例外発生");
				return null;
			}
		}else{
			Log.d("res.getStatusLine().getStatusCode() != 200 -> " + res.getStatusLine().getStatusCode());
			for(NameValuePair p : param){
				Log.d(String.format("%s => %s", p.getName(), p.getValue()));
			}
			notifyErrorToSlack("EpsilonSettlementCancel:サーバ側からエラー受信");
			return null;
		}
		return settleResultInfo;
	}

	// 決済情報送信処理
	public SettlementCaptureResultInfo execSettlement(SettlementCaptureSendInfo sendInfo){
		this.setSettlementCaptureSendInfo(sendInfo);
		return this.execSettlement();
	}

	public List<NameValuePair> makeSendParam() {
		SettlementCaptureSendInfo si = this.getSettlementCaptureInfo();
		List<NameValuePair> param = new ArrayList<>();
		param.add( new BasicNameValuePair("contract_code", CONTRACT_CODE ));
		param.add( new BasicNameValuePair("order_number", si.orderNumber));
		return param;
	}
}
