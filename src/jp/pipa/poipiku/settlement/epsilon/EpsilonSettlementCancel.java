package jp.pipa.poipiku.settlement.epsilon;

import jp.pipa.poipiku.util.Log;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicHeader;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilderFactory;
import java.io.InputStream;
import java.net.URI;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;

// EPSILON定期課金解除API呼び出しクラス
public class EpsilonSettlementCancel {
	private static final String CONTRACT_CODE = "68968190";

	// TODO 本番適用時に入れ替え
	// dev
	private static final String CANCEL_URL = "https://beta.epsilon.jp/cgi-bin/order/regularly_cancel.cgi";

	// production
//	private static final String CANCEL_URL = "https://secure.epsilon.jp/cgi-bin/order/regularly_cancel.cgi";

	public SettlementCancelSendInfo sendInfo;

	public EpsilonSettlementCancel(){
		sendInfo = new SettlementCancelSendInfo();
	}
	public EpsilonSettlementCancel(SettlementCancelSendInfo _sendInfo){
		sendInfo = _sendInfo;
	}

	// 決済情報送信処理
	public SettlementCancelResultInfo execCancel(){
		// 決済情報送信
		// 送信用の設定を作成
		RequestConfig rc = RequestConfig.custom().setConnectTimeout(2000)
				.setSocketTimeout(2000)
				.setMaxRedirects(0)
				.build();
		// Header定義
		List<Header> header = new ArrayList<Header>();
		header.add( new BasicHeader("Accept-Charset","UTF-8" ))	;
		header.add( new BasicHeader("User-Agent","EPSILON SAMPLE PROGRAM JAVA" ));

		HttpClient client = HttpClientBuilder.create()
				.setDefaultRequestConfig(rc)
				.setDefaultHeaders(header)
				.build();

		List<NameValuePair> param = this.makeSendParam();
		Log.d("key => value");
		for(NameValuePair p : param){
			Log.d(String.format("%s => %s", p.getName(), p.getValue()));
		}
		HttpPost post = new HttpPost();
		HttpResponse res = null;

		try {
			post.setEntity(new UrlEncodedFormEntity(param,"UTF-8"));
			post.setURI(new URI(CANCEL_URL));
			res = client.execute(post);
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}
		SettlementCancelResultInfo resultInfo = new SettlementCancelResultInfo();
		if( res.getStatusLine().getStatusCode() == HttpStatus.SC_OK ){
			// BODYを取得してXMLパーサー呼び出し
			try{
				String xml = EntityUtils.toString(res.getEntity(), java.nio.charset.Charset.forName("UTF-8"));
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
								resultInfo.result = attr.getNodeValue();
								break;
							case "err_code":
								resultInfo.errCode = attr.getNodeValue();
								break;
							case "err_detail":
								resultInfo.errDetail = new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" );
								break;
							case "user_id":
								resultInfo.userId = new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" );
								break;
							case "item_code":
								resultInfo.itemCode = new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" );
								break;
							case "item_price":
								resultInfo.itemPrice = attr.getNodeValue();
								break;
							case "mission_code":
								resultInfo.missionCode = new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" );
								break;
						}
					}
				}
				Log.d(resultInfo.toString());
			}catch(Exception e){
				Log.d("caught exception");
				for(NameValuePair p : param){
					Log.d(String.format("%s => %s", p.getName(), p.getValue()));
				}
				e.printStackTrace();
				return null;
			}
		}else{
			Log.d("res.getStatusLine().getStatusCode() != 200 -> " + res.getStatusLine().getStatusCode());
			for(NameValuePair p : param){
				Log.d(String.format("%s => %s", p.getName(), p.getValue()));
			}
			return null;
		}
		return resultInfo;
	}


	public List<NameValuePair> makeSendParam() {
		List<NameValuePair> param = new ArrayList<NameValuePair>();
		param.add( new BasicNameValuePair("contract_code", CONTRACT_CODE ));
		param.add( new BasicNameValuePair("user_id", sendInfo.userId));
		param.add( new BasicNameValuePair("item_code", sendInfo.itemCode));
		return param;
	}
}
