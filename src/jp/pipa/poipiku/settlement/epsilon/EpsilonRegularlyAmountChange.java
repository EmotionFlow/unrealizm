package jp.pipa.poipiku.settlement.epsilon;

import java.io.InputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilderFactory;

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

// EPSILON定期課金 金額変更API呼び出しクラス
public final class EpsilonRegularlyAmountChange extends EpsilonSettlement{
//	private String amountChangeUrl;

	// dev
//	private static final String DEV_AMOUNT_CHANGE_URL = "https://beta.epsilon.jp/cgi-bin/order/regularly_amount_change.cgi";

	// production
//	private static final String PROD_AMOUNT_CHANGE_URL = "https://secure.epsilon.jp/cgi-bin/order/regularly_amount_change.cgi";

	private RegularlyAmountChangeSendInfo sendInfo;
	public RegularlyAmountChangeSendInfo getSendInfo() {
		return sendInfo;
	}

	public void setSendInfo(RegularlyAmountChangeSendInfo sendInfo) {
		this.sendInfo = sendInfo;
	}

	private void initUrl() {
		if (connectTo == ConnectTo.Dev) {
			Log.d("開発用CGIへ接続");
//			amountChangeUrl = DEV_AMOUNT_CHANGE_URL;
		} else {
//			amountChangeUrl = PROD_AMOUNT_CHANGE_URL;
		}
	}

	public EpsilonRegularlyAmountChange(int userId){
		super(userId);
		initUrl();
		this.setSendInfo(new RegularlyAmountChangeSendInfo());
	}
	public EpsilonRegularlyAmountChange(int userId, RegularlyAmountChangeSendInfo _sendInfo){
		super(userId);
		initUrl();
		this.setSendInfo(_sendInfo);
	}

	// 決済情報送信処理
	public RegularlyAmountChangeResultInfo execSettlement(){
		// 決済情報送信
		// 送信用の設定を作成
//		RequestConfig rc = RequestConfig.custom().setConnectTimeout(60000)
//				.setSocketTimeout(60000)
//				.setMaxRedirects(0)
//				.build();
		// Header定義
		List<Header> header = new ArrayList<>();
		header.add( new BasicHeader("Accept-Charset","UTF-8" ))	;
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
//			post.setURI(new URI(amountChangeUrl));
//			res = client.execute(post);
		}catch(Exception e){
			e.printStackTrace();
			notifyErrorToSlack("EpsilonRegularlyAmountChange:client.execute()例外発生");
			return null;
		}

		RegularlyAmountChangeResultInfo resultInfo = new RegularlyAmountChangeResultInfo();
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
								resultInfo.setResult(attr.getNodeValue());
								break;
							case "err_code":
								resultInfo.setErrCode(attr.getNodeValue());
								break;
							case "err_detail":
								resultInfo.setErrDetail(new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "user_id":
								resultInfo.setUserId( new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "item_code":
								resultInfo.setItemCode( new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "item_price":
								resultInfo.setItemPrice(new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "mission_code":
								resultInfo.setMissionCode(attr.getNodeValue());
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
				notifyErrorToSlack("EpsilonRegularlyAmountChange:resultInfo解析で例外発生");
				return null;
			}
		}else{
			Log.d("res.getStatusLine().getStatusCode() != 200 -> " + res.getStatusLine().getStatusCode());
			for(NameValuePair p : param){
				Log.d(String.format("%s => %s", p.getName(), p.getValue()));
			}
			notifyErrorToSlack("EpsilonRegularlyAmountChange:サーバ側からエラー受信");
			return null;
		}
		return resultInfo;
	}

	// 金額変更情報送信処理
	public RegularlyAmountChangeResultInfo execAmountChange(RegularlyAmountChangeSendInfo _sendInfo){
		this.setSendInfo(_sendInfo);
		return this.execSettlement();
	}

	public List<NameValuePair> makeSendParam() {
		RegularlyAmountChangeSendInfo si = this.getSendInfo();
		List<NameValuePair> param = new ArrayList<>();
		param.add( new BasicNameValuePair("contract_code", CONTRACT_CODE ));
		param.add( new BasicNameValuePair("user_id", si.userId));
		param.add( new BasicNameValuePair("item_code", si.itemCode));
		param.add( new BasicNameValuePair("item_price", si.itemPrice.toString()));
		return param;
	}
}
