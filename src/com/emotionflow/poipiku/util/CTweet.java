package com.emotionflow.poipiku.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import com.emotionflow.poipiku.Common;

import oauth.signpost.OAuthConsumer;
import oauth.signpost.basic.DefaultOAuthConsumer;

public class CTweet {
	public boolean m_bIsTweetEnable = false;
	public String m_strUserAccessToken = "";
	public String m_strSecretToken = "";
	public static final int MAX_LENGTH = 140;
	public static final String ELLIPSE = "...";

	public boolean GetResults(int nUserId) {
		boolean bResult = true;
		DataSource dsPostgres = null;
		Connection cConn = null;
		Statement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			cState = cConn.createStatement();

			// useridからTweet可否とTokenを検索
			strSql = String.format(
					"SELECT fldaccesstoken, fldsecrettoken FROM tbloauth WHERE flduserid=%d AND fldproviderid=%d;",
					nUserId,
					Common.TWITTER_PROVIDER_ID
					);
			cResSet = cState.executeQuery(strSql);
			if(cResSet.next()){
				// Token格納
				m_strUserAccessToken = cResSet.getString(1);
				m_strSecretToken = cResSet.getString(2);
				m_bIsTweetEnable = true;
			} else {
				m_bIsTweetEnable = false;
			}
			cResSet.close();
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		} finally {
			try {if (cResSet != null) cResSet.close();} catch (Exception e) {}
			try {if (cState != null) cState.close();} catch (Exception e) {}
			try {if (cConn != null) cConn.close();} catch (Exception e) {}
		}
		//System.out.println(strResult);
		return bResult;
	}

	public boolean Tweet(String strTweet) {
		if (!m_bIsTweetEnable) {
			return false;
		}

		boolean bResult = true;
		try {
			// これはユーザによらない
			OAuthConsumer cConsumer = new DefaultOAuthConsumer(
					Common.TWITTER_CONSUMER_KEY, Common.TWITTER_CONSUMER_SECRET);

			// これはユーザごとに異なる
			cConsumer.setTokenWithSecret(
					m_strUserAccessToken,
					m_strSecretToken);

			//つぶやく内容
			StringBuilder message = new StringBuilder(strTweet);

			//返信の場合は先頭に"@宛先 "を付けることが必須
			//message.insert(0, "@yabuki ");
			//重複回避のために現在時刻を入れる（オプショナル）
			//message.append(" at ").append(new Date());

			//送信データ（「status=つぶやき&...」という形式にする）
			StringBuilder body = new StringBuilder("status=");

			body.append(URLEncoder.encode(message.toString(), "UTF-8")
					.replace("+", "%20"));

			//返信の場合は返信先のTweet IDを指定する（オプショナル）
			//body.append("&in_reply_to_status_id=").append("27905604456");

			// HTTPリクエストを作って署名する
			URL url = new URL(
					"https://api.twitter.com/1.1/statuses/update.json?" + body);
			HttpURLConnection connection = (HttpURLConnection) url
					.openConnection();
			connection.setRequestMethod("POST");
			cConsumer.sign(connection);

			// レスポンスコード
			//System.out.printf("%s %s\n", connection.getResponseCode(), connection.getResponseMessage());

			// 成功ならレスポンスボディをそのまま表示する
			if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
				/*
				BufferedReader br = new BufferedReader(
						new InputStreamReader(connection.getInputStream(),
								"UTF-8"));
				String line = null;
				while ((line = br.readLine()) != null) {
					System.out.println(line);
				}
				br.close();
				*/
			}
			// 失敗ならエラーメッセージだけを表示する
			else {
				/*
				InputSource is = new InputSource(
						connection.getErrorStream());
				XPath xpath = XPathFactory.newInstance().newXPath();
				Node error = (Node) xpath.evaluate("//error", is,
						XPathConstants.NODE);
				System.out.println(error.getTextContent());
				*/
				bResult = false;
			}
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		}

		return bResult;
	}


	public boolean Tweet(String strTweet, String strFileName) {
		if (!m_bIsTweetEnable) {
			return false;
		}

		boolean bResult = true;
		try {
			String boundary = "galleriapostboundary";

			File file = new File(strFileName);
			int contentLength = instrumentContentLength(boundary, strTweet, file);

			OAuthConsumer cConsumer = new DefaultOAuthConsumer(Common.TWITTER_CONSUMER_KEY, Common.TWITTER_CONSUMER_SECRET);
			cConsumer.setTokenWithSecret(m_strUserAccessToken, m_strSecretToken);

			URL url = new URL("https://api.twitter.com/1.1/statuses/update_with_media.json?");
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setFixedLengthStreamingMode(contentLength);
			conn.setRequestMethod("POST");
			conn.setDoOutput(true);
			cConsumer.sign(conn);
			conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

			String charset = "UTF-8";
			OutputStream out = conn.getOutputStream();

			// テキストフィールド送信
			out.write( ("--" + boundary + "\r\n").getBytes(charset));
			out.write( ("Content-Disposition: form-data; name=\"status\"\r\n").getBytes(charset));
			out.write( ("Content-Type: text/plain; charset=UTF-8\r\n\r\n").getBytes(charset));
			out.write( (strTweet).getBytes(charset));
			out.write( ("\r\n").getBytes(charset));

			// ファイルフィールド送信
			out.write( ("--" + boundary + "\r\n").getBytes(charset));
			out.write( ("Content-Disposition: form-data; name=\"media[]\"; filename=\"").getBytes(charset));
			out.write( (file.getName()).getBytes(charset));
			out.write( ("\"\r\n").getBytes(charset));
			out.write( ("Content-Type: application/octet-stream\r\n\r\n").getBytes(charset));
			InputStream in = new FileInputStream(file);
			byte[] bytes = new byte[1024];
			while (true) {
			int ret = in.read(bytes);
			if (ret <= 0) break;
				out.write(bytes, 0, ret);
				out.flush();
			}
			out.write(  ("\r\n").getBytes(charset));
			in.close();
			out.write(  ("--" + boundary + "--").getBytes(charset));
			out.flush();
			out.close();

			// 成功ならレスポンスボディをそのまま表示する
			if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
				/*
				BufferedReader br = new BufferedReader(
						new InputStreamReader(conn.getInputStream(),
								"UTF-8"));
				String line = null;
				while ((line = br.readLine()) != null) {
					System.out.println(line);
				}
				br.close();
				*/
			}
			// 失敗ならエラーメッセージだけを表示する
			else {
				//InputSource is = new InputSource(conn.getErrorStream());
				//XPath xpath = XPathFactory.newInstance().newXPath();
				//Node error = (Node) xpath.evaluate("//error", is, XPathConstants.NODE);
				//System.out.println(error.getTextContent());
				bResult = false;
			}
			conn.disconnect();
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		}

		return bResult;
	}

	private int instrumentContentLength(String boundary, String status, File file) {
		int size = 0;
		String charset = "UTF-8";

		try {
			// テキストフィールドサイズ計測
			size += ("--" + boundary + "\r\n").getBytes(charset).length;
			size += ("Content-Disposition: form-data; name=\"status\"\r\n").getBytes(charset).length;
			size += ("Content-Type: text/plain; charset=UTF-8\r\n\r\n").getBytes(charset).length;
			size += (status).getBytes(charset).length;
			size += ("\r\n").getBytes(charset).length;

			// ファイルフィールドサイズ計測
			size += ("--" + boundary + "\r\n").getBytes(charset).length;
			size += ("Content-Disposition: form-data; name=\"media[]\"; filename=\"").getBytes(charset).length;
			size += (file.getName()).getBytes(charset).length;
			size += ("\"\r\n").getBytes(charset).length;
			size += ("Content-Type: application/octet-stream\r\n\r\n").getBytes(charset).length;
			InputStream in = new FileInputStream(file);
			byte[] bytes = new byte[1024];
			while (true) {
				int ret = in.read(bytes);
				if (ret <= 0) {
					break;
				}
				size += ret;
			}
			size += ("\r\n").getBytes(charset).length;
			in.close();
			size += ("--" + boundary + "--").getBytes(charset).length;
		} catch (Exception e) {
			// TODO 自動生成された catch ブロック
			e.printStackTrace();
		}
		return size;
	}
}
