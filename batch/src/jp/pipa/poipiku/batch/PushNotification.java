package jp.pipa.poipiku.batch;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

import org.json.JSONObject;

import com.eatthepath.pushy.apns.ApnsClient;
import com.eatthepath.pushy.apns.ApnsClientBuilder;
import com.eatthepath.pushy.apns.PushNotificationResponse;
import com.eatthepath.pushy.apns.auth.ApnsSigningKey;
import com.eatthepath.pushy.apns.util.ApnsPayloadBuilder;
import com.eatthepath.pushy.apns.util.SimpleApnsPayloadBuilder;
import com.eatthepath.pushy.apns.util.SimpleApnsPushNotification;
import com.eatthepath.pushy.apns.util.TokenUtil;
import com.eatthepath.pushy.apns.util.concurrent.PushNotificationFuture;

import jp.pipa.poipiku.util.CEnc;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class PushNotification extends Batch{
	static final boolean _DEBUG = false;
	static final String SERVER_KEY		= "AAAAvJqJMJQ:APA91bGvkdXW4FX33NZJirqQ4wf_tCnZtQ5bAEE-yD75233I09rDrlpUa3SmDxsklB6_bKqGImnAqlut9E1IbWeDRclK1wJefT4YPzfjQjSCbUr0mpDv3ts3JWQ2pQjqwTeeEnq8uKzx";
	static final String URL_GOOGLE_FCM	= "https://fcm.googleapis.com/fcm/send";

	public static void main(String args[]) {
		//Logger.getLogger(PushNotification.class).setLevel(Level.OFF);
		System.setProperty("log4j.rootLogger","OFF");
		//System.setProperty("org.apache.log4j.Level","OFF");
		System.setProperty("org.slf4j.simpleLogger.defaultLogLevel","OFF");

		ArrayList<CNotification> listNotifications = new ArrayList<CNotification>();
		Connection  cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {

			// UUID
			final String AGENT_UUID = UUID.randomUUID().toString();
			Log.d(AGENT_UUID);

			// CONNECT DB
			cConn = dataSource.getConnection();

			// 10分以上処理が行われていないものをリセット
			strSql = (_DEBUG)?
					"UPDATE notification_buffers_0000 SET agent_uuid=NULL WHERE agent_uuid IS NOT NULL":
					"UPDATE notification_buffers_0000 SET agent_uuid=NULL WHERE agent_uuid IS NOT NULL AND regist_date<current_timestamp - interval'10 minutes'";
			cState = cConn.prepareStatement(strSql);
			cState.executeUpdate();
			cState.close();cState=null;

			// 100件予約
			strSql = "UPDATE notification_buffers_0000 SET agent_uuid=? WHERE notification_id IN (SELECT notification_id FROM notification_buffers_0000 WHERE agent_uuid IS NULL LIMIT 100)";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, AGENT_UUID);
			cState.executeUpdate();
			cState.close();cState=null;

			// 予約したデータを取得
			strSql = "SELECT * FROM notification_buffers_0000 WHERE agent_uuid=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, AGENT_UUID);
			cResSet = cState.executeQuery();
			while(cResSet.next()) {
				CNotification cNotification = new CNotification();
				cNotification.notification_id = cResSet.getLong("notification_id");
				cNotification.notification_token = Util.toString(cResSet.getString("notification_token"));
				cNotification.badge_num = cResSet.getInt("badge_num");
				cNotification.title = Util.toString(cResSet.getString("title"));
				cNotification.sub_title = Util.toString(cResSet.getString("sub_title"));
				cNotification.body = Util.toString(cResSet.getString("body"));
				cNotification.token_type = cResSet.getInt("token_type");
				listNotifications.add(cNotification);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// 通知送信
			strSql = "DELETE FROM notification_buffers_0000 WHERE notification_id=?";
			cState = cConn.prepareStatement(strSql);
			for(CNotification cNotification : listNotifications) {
				Notification notification = new Notification(cNotification.notification_token);
				switch (cNotification.token_type) {
					case CNotification.NOTIFICATION_TOKEN_TYPE_IOS -> {
						Log.d("iOS", cNotification.notification_token, "" + cNotification.token_type, "" + cNotification.badge_num, cNotification.title, cNotification.sub_title, cNotification.body);
						notification.sendNotificationIos(cNotification.badge_num, cNotification.title, cNotification.sub_title, cNotification.body);
					}
					case CNotification.NOTIFICATION_TOKEN_TYPE_ANDROID -> {
						Log.d("Android", cNotification.notification_token, "" + cNotification.token_type, "" + cNotification.badge_num, cNotification.title, cNotification.sub_title, cNotification.body);
						notification.sendNotificationAndroid(cNotification.badge_num, cNotification.title, cNotification.sub_title, cNotification.body);
					}
				}
				cNotification.result = notification.getResult();
				cState.setLong(1, cNotification.notification_id);
				cState.executeUpdate();
			}
			cState.close();cState=null;

			// 送信に失敗したTokenを削除
			strSql = "DELETE FROM notification_tokens_0000 WHERE notification_token=? AND token_type=?";
			cState = cConn.prepareStatement(strSql);
			for(CNotification cNotification : listNotifications) {
				if(cNotification.result) continue;
				cState.setString(1, cNotification.notification_token);
				cState.setInt(2, cNotification.token_type);
				cState.executeUpdate();
				Log.d("Delete token", cNotification.notification_token);
			}
			cState.close();cState=null;
		} catch (Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try {if(cResSet!=null)cResSet.close();cResSet=null;}catch(Exception e){}
			try {if(cState!=null)cState.close();cState=null;}catch(Exception e){}
			try {if(cConn!=null)cConn.close();cConn=null;}catch(Exception e){}
		}
	}

	static class Notification {
		static final String PUSH_HOST = (_DEBUG)?ApnsClientBuilder.DEVELOPMENT_APNS_HOST:ApnsClientBuilder.PRODUCTION_APNS_HOST;
		static final String KEY_FILE = (_DEBUG)?"/Users/kawai/git/poipiku_script/lib/AuthKey_LX9QA98LL7.p8":"/root/poipiku_script/lib/AuthKey_LX9QA98LL7.p8";
		static final String TEAM_ID = "EGZY7K38QW";
		static final String KEY_ID = "LX9QA98LL7";
		static final String APP_ID = "jp.pipa.poipiku";

		String tokenString = "";
		boolean isSuccess = false;

		public Notification(String strToken) {
			setToken(strToken);
		}

		void setToken(String strToken) {
			tokenString = strToken;
		}

		boolean getResult() {
			return isSuccess;
		}

		boolean sendNotificationIos(int nBadgeNum, String strTitle, String strSubTitle, String strBody) {
			if(tokenString.isEmpty()) return false;
			ApnsClient apnsClient = null;
			try {
				// 通知クライアントを作成
				apnsClient = new ApnsClientBuilder()
						.setApnsServer(PUSH_HOST)
						.setConnectionTimeout(Duration.ofSeconds(10))
						.setSigningKey(
								ApnsSigningKey.loadFromPkcs8File(
										new File(KEY_FILE),
										TEAM_ID,
										KEY_ID))
						.build();

				final SimpleApnsPushNotification pushNotification;
				final ApnsPayloadBuilder payloadBuilder = new SimpleApnsPayloadBuilder();
				payloadBuilder.setBadgeNumber(nBadgeNum);
				payloadBuilder.setAlertTitle(strTitle);
				payloadBuilder.setAlertSubtitle(strSubTitle);
				payloadBuilder.setAlertBody(strBody);

				final String token = TokenUtil.sanitizeTokenString(tokenString);
				pushNotification = new SimpleApnsPushNotification(token, APP_ID, payloadBuilder.build());

				final PushNotificationFuture<SimpleApnsPushNotification, PushNotificationResponse<SimpleApnsPushNotification>> sendNotificationFuture = apnsClient.sendNotification(pushNotification);
				final PushNotificationResponse<SimpleApnsPushNotification> pushNotificationResponse = sendNotificationFuture.get();

				if (pushNotificationResponse.isAccepted()) {
					isSuccess = true;
					//System.out.println("Push notification accepted by APNs gateway.");
				} else {
					System.out.println("Notification rejected by the APNs gateway: " + pushNotificationResponse.getRejectionReason());
					isSuccess = false;
					pushNotificationResponse.getTokenInvalidationTimestamp().ifPresent(timestamp -> {
						System.out.println("\t…invalid " + timestamp);
					});
					return false;
				}

				sendNotificationFuture.whenComplete((response, cause) -> {
					if (response != null) {
						// Handle the push notification response as before from here.
					} else {
						// Something went wrong when trying to send the notification to the
						// APNs server. Note that this is distinct from a rejection from
						// the server, and indicates that something went wrong when actually
						// sending the notification or waiting for a reply.
						cause.printStackTrace();
					}
				});

			} catch (Exception e) {
				e.printStackTrace();
				isSuccess = false;
			} finally {
				if (apnsClient != null) {
					final CompletableFuture<Void> closeFuture = apnsClient.close();
					closeFuture.whenComplete((response, cause) -> {
						cause.printStackTrace();
					});
				}
			}
			return isSuccess;
		}


		boolean sendNotificationAndroid(int nBadgeNum, String strTitle, String strSubTitle, String strBody) {
			if(tokenString.isEmpty()) return false;

			OutputStream os = null;
			InputStream inputStream = null;

			try {
				HttpURLConnection httpcon = (HttpURLConnection) ((new URL(URL_GOOGLE_FCM).openConnection()));
				httpcon.setReadTimeout(10000);
				httpcon.setConnectTimeout(10000);
				httpcon.setDoOutput(true);
				httpcon.setRequestProperty("Content-Type", "application/json");
				httpcon.setRequestProperty("Authorization", "key="+SERVER_KEY);
				httpcon.setRequestMethod("POST");
				httpcon.connect();

				StringBuilder json = new StringBuilder();
				json.append("{");
				json.append(String.format("\"to\":\"%s\",", tokenString));
				/*
				 * 自動通知(offにしたいので送らない)
				json.append(String.format("\"notification\":{\"title\":\"%s\", \"body\":\"%s\"},",
						CEnc.E(strTitle),
						CEnc.E(strBody)));
				*/
				json.append(String.format("\"data\":{\"badge_num\":%d, \"title\":\"%s\", \"sub_title\":\"%s\", \"body\":\"%s\"},",
						nBadgeNum,
						CEnc.E(strTitle),
						CEnc.E(strSubTitle),
						CEnc.E(strBody)));
				json.append("\"priority\":10");
				json.append("}");

				byte[] outputBytes = json.toString().getBytes(StandardCharsets.UTF_8);
				os = httpcon.getOutputStream();
				os.write(outputBytes);
				os.close();
				os = null;

				// 送信確認(必須ではない)
				InputStream input = httpcon.getInputStream();
				BufferedReader reader = new BufferedReader(new InputStreamReader(input));
				StringBuilder result = new StringBuilder();
				for (String line; (line = reader.readLine()) != null;) {
					result.append(line);
				}
				System.out.println("Android return : "+result);
				JSONObject jsonRoot = new JSONObject(result.toString().trim());
				int nSuccessNum = 0;
				Iterator<String> keys = jsonRoot.keys();
				while(keys.hasNext()) {
					String key = keys.next();
					//System.out.println("key: " + key);
					if(key.equals("success")) {
						nSuccessNum = jsonRoot.getInt("success");
						//System.out.println("nSuccessNum: " + nSuccessNum);
						break;
					}
				}
				if(nSuccessNum>0) {
					// 成功
					// {"multicast_id":5427354999662616495,"success":1,"failure":0,"canonical_ids":0,"results":[{"message_id":"0:1544038572329179%f198a5d1f9fd7ecd"}]}
					isSuccess = true;
				} else {
					// 失敗
					// {"multicast_id":7566872899851760487,"success":0,"failure":1,"canonical_ids":0,"results":[{"error":"InvalidRegistration"}]}
					System.out.println("Notification rejected by the FCM gateway: " + result);
					isSuccess = false;
					return false;
				}
				input.close();
				input = null;
			} catch (Exception e) {
				e.printStackTrace();
				isSuccess = false;
			} finally {
				if(os != null){try{os.close();}catch(IOException ignore){}}
				if(inputStream != null){try{inputStream.close();}catch(IOException ignore){}}
			}

			return isSuccess;
		}
	}

	static class CNotification {
		public static final int NOTIFICATION_TOKEN_TYPE_IOS = 1;
		public static final int NOTIFICATION_TOKEN_TYPE_ANDROID = 2;

		long notification_id = 0;
		String notification_token = "";
		int badge_num = 0;
		String title = "";
		String sub_title = "";
		String body = "";
		int token_type = -1;
		boolean result = false;
	}
}
