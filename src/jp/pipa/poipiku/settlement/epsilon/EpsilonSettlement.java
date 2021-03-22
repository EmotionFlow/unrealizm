package jp.pipa.poipiku.settlement.epsilon;

import java.io.InputStream;
import java.net.URI;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilderFactory;

import jp.pipa.poipiku.Common;
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

// EPSILON決済API呼び出しクラス
public class EpsilonSettlement {
	private static final String CONTRACT_CODE = "68968190";

	private String TOKEN_SETTLEMENT_URL;
	private String LINK_SETTLEMENT_URL;
	// dev
	private static final String DEV_TOKEN_SETTLEMENT_URL = "https://beta.epsilon.jp/cgi-bin/order/direct_card_payment.cgi";
	private static final String DEV_LINK_SETTLEMENT_URL = "https://beta.epsilon.jp/cgi-bin/order/receive_order3.cgi";
	// production
	private static final String PROD_TOKEN_SETTLEMENT_URL = "https://secure.epsilon.jp/cgi-bin/order/direct_card_payment.cgi";
	private static final String PROD_LINK_SETTLEMENT_URL = "https://secure.epsilon.jp/cgi-bin/order/receive_order3.cgi";

	private SettlementSendInfo settlementSendInfo;
	public SettlementSendInfo getSettlementSendInfo() {
		return settlementSendInfo;
	}

	public void setSettlementSendInfo(SettlementSendInfo settlementSendInfo) {
		this.settlementSendInfo = settlementSendInfo;
	}

	private void initUrl() {
		if (Common.isDevEnv()) {
			Log.d("開発用CGIへ接続");
			TOKEN_SETTLEMENT_URL = DEV_TOKEN_SETTLEMENT_URL;
			LINK_SETTLEMENT_URL = DEV_LINK_SETTLEMENT_URL;
		} else {
			TOKEN_SETTLEMENT_URL = PROD_TOKEN_SETTLEMENT_URL;
			LINK_SETTLEMENT_URL = PROD_LINK_SETTLEMENT_URL;
		}
	}

	public EpsilonSettlement(){
		initUrl();
		this.setSettlementSendInfo(new SettlementSendInfo());
	}
	public EpsilonSettlement( SettlementSendInfo settlementSendInfo){
		initUrl();
		this.setSettlementSendInfo(settlementSendInfo);
	}

	// 決済情報送信処理
	public SettlementResultInfo execSettlement(){
		// 決済情報送信
		// 送信用の設定を作成
		RequestConfig rc = RequestConfig.custom().setConnectTimeout(60000)
				.setSocketTimeout(60000)
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
			String url ="";
			switch (settlementSendInfo.processCode) {
				case 1: case 2: // 初回/登録済み課金
					url = TOKEN_SETTLEMENT_URL;
					break;
				case 7: case 9: // ユーザ退会又は退会取消
					url = LINK_SETTLEMENT_URL;
					break;
			}
			post.setURI(new URI(url));
			res = client.execute(post);
		}catch(Exception e){
			e.printStackTrace();
			return null;
		}
		SettlementResultInfo settleResultInfo = new SettlementResultInfo();
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
								settleResultInfo.setResult(attr.getNodeValue());
								break;
							case "err_code":
								settleResultInfo.setErrCode(attr.getNodeValue());
								break;
							case "err_detail":
								settleResultInfo.setErrDetail(new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "memo1":
								settleResultInfo.setMemo1( new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "memo2":
								settleResultInfo.setMemo2( new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "redirect":
								settleResultInfo.setRedirect(new String(URLDecoder.decode(attr.getNodeValue(),"UTF-8").getBytes("UTF-8"),"UTF-8" ));
								break;
							case "trans_code":
								settleResultInfo.setTransCode(attr.getNodeValue());
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
				return null;
			}
		}else{
			Log.d("res.getStatusLine().getStatusCode() != 200 -> " + res.getStatusLine().getStatusCode());
			for(NameValuePair p : param){
				Log.d(String.format("%s => %s", p.getName(), p.getValue()));
			}
			return null;
		}
		return settleResultInfo;
	}

	// 決済情報送信処理
	public SettlementResultInfo execSettlement(SettlementSendInfo settlementSendInfo){
		this.setSettlementSendInfo(settlementSendInfo);
		return this.execSettlement();
	}

	public List<NameValuePair> makeSendParam() {
		SettlementSendInfo si = this.getSettlementSendInfo();
		List<NameValuePair> param = new ArrayList<>();
		switch (si.processCode){
			case 1: case 2: // 初回/登録済み課金
				param.add( new BasicNameValuePair("version", si.version.toString()));
				param.add( new BasicNameValuePair("contract_code", CONTRACT_CODE ));
				param.add( new BasicNameValuePair("user_id", si.userId));
				param.add( new BasicNameValuePair("user_name", si.userName));
				param.add( new BasicNameValuePair("user_mail_add", si.userMailAdd));
				param.add( new BasicNameValuePair("item_code", si.itemCode));
				param.add( new BasicNameValuePair("item_name", si.itemName));
				param.add( new BasicNameValuePair("order_number", si.orderNumber));
				param.add( new BasicNameValuePair("st_code",  si.stCode));
				param.add( new BasicNameValuePair("card_st_code",  si.cardStCode));
				param.add( new BasicNameValuePair("mission_code",si.missionCode.toString()));
				param.add( new BasicNameValuePair("item_price", si.itemPrice.toString()));
				param.add( new BasicNameValuePair("process_code", si.processCode.toString()));
				param.add( new BasicNameValuePair("memo1", si.memo1));
				param.add( new BasicNameValuePair("memo2", si.memo2));
				param.add( new BasicNameValuePair("xml", si.xml.toString()));
				param.add( new BasicNameValuePair("character_code", si.characterCode));
				param.add( new BasicNameValuePair("user_agent", si.userAgent));

				if(si.securityCheck!=null){
					param.add( new BasicNameValuePair("security_check", si.securityCheck.toString()));
				}
				if(!si.token.isEmpty()){
					param.add( new BasicNameValuePair("token", si.token));
				}

				/*
				// コンビニ指定があるときのみ指定する
				if( si.getConveniCode() != 0) {
					param.add( new BasicNameValuePair("conveni_code", si.getConveniCode().toString()));
					param.add( new BasicNameValuePair("user_tel", si.getUserTel()));
					param.add( new BasicNameValuePair("user_name_kana", si.getUserNameKana()));
				}else if ( si.getConsigneePostal() != null && !si.getConsigneePostal().isEmpty() ){
					// 後払い用パラメータの先頭項目に値が有る場合は後払い用パラメータも設定
					param.add( new BasicNameValuePair("delivery_code",si.getDeliveryCode()));
					param.add( new BasicNameValuePair("consignee_postal",si.getConsigneePostal()));
					param.add( new BasicNameValuePair("consignee_name",si.getConsigneeName()));
					param.add( new BasicNameValuePair("consignee_address",si.getConsigneeAddress()));
					param.add( new BasicNameValuePair("consignee_tel",si.getConsigneeTel()));
					param.add( new BasicNameValuePair("orderer_postal",si.getOrdererPostal()));
					param.add( new BasicNameValuePair("orderer_name",si.getOrdererName()));
					param.add( new BasicNameValuePair("orderer_address",si.getOrdererAddress()));
					param.add( new BasicNameValuePair("orderer_tel",si.getOrdererTel()));
				}
				 */
				break;
			case 3: case 4: // ユーザ登録のみ、又は登録変更
				/*
				param.add( new BasicNameValuePair("version", si.getVersion().toString()));
				param.add( new BasicNameValuePair("contract_code", CONTRACT_CODE ));
				param.add( new BasicNameValuePair("user_id", si.getUserId()));
				param.add( new BasicNameValuePair("user_name", si.getUserName()));
				param.add( new BasicNameValuePair("user_mail_add", si.getUserMailAdd()));
				// ここでは設定からカード変更有無を読み取る
				param.add( new BasicNameValuePair("st_code",  getConfig().getSt_code()));
				param.add( new BasicNameValuePair("process_code", si.getProcessCode().toString()));
				param.add( new BasicNameValuePair("memo1", si.getMemo1()));
				param.add( new BasicNameValuePair("memo2", si.getMemo2()));
				param.add( new BasicNameValuePair("xml", si.getXml().toString()));
				 */
				break;
			case 7: case 9: // ユーザ退会又は退会取消
				Log.d("ユーザ退会又は退会取消");
				param.add( new BasicNameValuePair("version", si.version.toString()));
				param.add( new BasicNameValuePair("contract_code", CONTRACT_CODE ));
				param.add( new BasicNameValuePair("user_id", si.userId));
				param.add( new BasicNameValuePair("process_code", si.processCode.toString()));
				param.add( new BasicNameValuePair("memo1", si.memo1));
				param.add( new BasicNameValuePair("memo2", si.memo2));
				param.add( new BasicNameValuePair("xml", si.xml.toString()));
				break;
		}
		return param;
	}
}
