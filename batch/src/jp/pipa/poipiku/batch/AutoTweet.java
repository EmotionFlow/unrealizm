package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.ImageMagickUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class AutoTweet extends Batch {
	static final boolean _DEBUG = false;
	static final String SRC_IMG_PATH = "/var/www/html/ai_poipiku";	// 最後の/はDBに入っている

	static final int TWITTER_PROVIDER_ID = 1;

	public static void main(String[] args) {
		class CTweetUser {
			public int m_nUserId=0;
			public String m_strAccessToken="";
			public String m_strSecretToken="";
			public ArrayList<String> m_vFileName = new ArrayList<>();
			public String m_strAutoTweetDesc="";
			public String m_strTweetId = "";
			public int m_nAutoTweetThumNum = 9;
		}

		ArrayList<CTweetUser> m_vTweetUser = new ArrayList<>();

		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			// CONNECT DB
			cConn = dataSource.getConnection();
			// SELECT TWITTER TOKEN & OLD TWEET_ID
			if(_DEBUG) {
				strSql = "SELECT * FROM tbloauth WHERE flduserid=5510705 AND fldproviderid=?";	// for test
			} else {
				strSql = "SELECT tbloauth.* FROM tbloauth" +
						" INNER JOIN users_0000 ON users_0000.user_id=tbloauth.flduserid" +
						" WHERE users_0000.passport_id>0" +
						" AND del_flg=false" +
						" AND auto_tweet_time=date_part('hour', current_timestamp)" +
						" AND auto_tweet_weekday IN(-1, date_part('dow', current_timestamp))" +
						" AND auto_tweet_time>=0 AND fldproviderid=?";
			}
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			while(cResSet.next()) {
				CTweetUser cTweetUser = new CTweetUser();
				cTweetUser.m_nUserId = cResSet.getInt("flduserid");
				cTweetUser.m_strAccessToken = Util.toString(cResSet.getString("fldaccesstoken"));
				cTweetUser.m_strSecretToken = Util.toString(cResSet.getString("fldsecrettoken"));
				cTweetUser.m_strAutoTweetDesc = Util.toString(cResSet.getString("auto_tweet_desc"));
				cTweetUser.m_strTweetId = Util.toString(cResSet.getString("tweet_id"));
				cTweetUser.m_nAutoTweetThumNum = cResSet.getInt("auto_tweet_thumb_num");
				m_vTweetUser.add(cTweetUser);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// SELECT THUMBNAIL FILE NAME
			strSql = "SELECT * FROM contents_0000 WHERE publish_id=0 AND open_id<>2 AND user_id=? AND file_name NOT ILIKE '%.gif' AND file_name <> '' ORDER BY content_id DESC LIMIT 9";
			cState = cConn.prepareStatement(strSql);
			for(CTweetUser cTweetUser : m_vTweetUser) {
				Log.d("cTweetUser.m_nUserId:"+cTweetUser.m_nUserId);
				Log.d("m_nAutoTweetThumNum:"+cTweetUser.m_nAutoTweetThumNum);
				if(cTweetUser.m_nAutoTweetThumNum<1) continue;
				cState.setInt(1, cTweetUser.m_nUserId);
				cResSet = cState.executeQuery();
				while(cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					String strFileUrl = cContent.getThumbnailFilePath();
					if(!strFileUrl.isEmpty()) {
						if(_DEBUG) Log.d("m_nPublishId:"+cContent.m_nPublishId, "m strFileName:"+strFileUrl);
						cTweetUser.m_vFileName.add(SRC_IMG_PATH + strFileUrl);
					}
				}
				cResSet.close();cResSet=null;
			}
			cState.close();cState=null;

			// TWEET
			CTweet tweet = new CTweet();
			tweet.m_bIsTweetEnable = true;

			for(CTweetUser cTweetUser : m_vTweetUser) {
				Log.d("Tweet - UserId:"+cTweetUser.m_nUserId);

				tweet.m_strUserAccessToken = cTweetUser.m_strAccessToken;
				tweet.m_strSecretToken = cTweetUser.m_strSecretToken;

				final String profPath = Common.makeUserProfDir(cTweetUser.m_nUserId);
				if (profPath == null) continue;

				String strDestFileName = profPath + "/auto_tweet.png";
				if(_DEBUG) Log.d("strDestFileName:"+strDestFileName);
				Util.deleteFile(strDestFileName);

				// CREATE IMAGE
				String strTweetId = "";
				if(!cTweetUser.m_vFileName.isEmpty()) {
					int exitCode = ImageMagickUtil.createMontage(cTweetUser.m_vFileName, strDestFileName);
					if (exitCode<0) {
						Log.d("ImageMagickUtil.createMontage return < 0", exitCode);
					}
				} else {
					Log.d("cTweetUser.m_vFileName.isEmpty");
					continue;
				}

				if(!_DEBUG) {
					try {
						File oDelFile = new File(strDestFileName);
						int nTweetResult = CTweet.ERR_OTHER;
						if(oDelFile.exists()) {
							nTweetResult = tweet.Tweet(cTweetUser.m_strAutoTweetDesc, strDestFileName);
						} else {
							nTweetResult = tweet.Tweet(cTweetUser.m_strAutoTweetDesc);
						}
						if(nTweetResult==CTweet.OK) {
							Log.d("tweet succeed.");
							int nDeleteTweet = CTweet.ERR_OTHER;
							strTweetId = Long.toString(tweet.getLastTweetId());

							if(!cTweetUser.m_strTweetId.isEmpty()) {
								nDeleteTweet = tweet.Delete(cTweetUser.m_strTweetId);
								if (nDeleteTweet == CTweet.OK) {
									Log.d("old tweet deleted.");
								} else {
									Log.d("delete error.");
								}
							}
						}else{
							Log.d("tweet error.");
							strTweetId = null;
						}
					} catch (Exception e) {
						e.printStackTrace();
						continue;
					}

					try {
						if(!strTweetId.isEmpty()) {
							strSql = "UPDATE tbloauth SET flddefaultenable=true, last_tweet_date=CURRENT_TIMESTAMP, tweet_id=? WHERE flduserid=? AND del_flg=false";
							cState = cConn.prepareStatement(strSql);
							cState.setString(1, strTweetId);
							cState.setInt(2, cTweetUser.m_nUserId);
						} else {
							strSql = "UPDATE tbloauth SET flddefaultenable=false WHERE flduserid=? AND del_flg=false";
							cState = cConn.prepareStatement(strSql);
							cState.setInt(1, cTweetUser.m_nUserId);
						}
						cState.executeUpdate();
						cState.close();cState=null;
					} catch (Exception e) {
						//e.printStackTrace();
						continue;
					}
				}
			}
		} catch (Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try {if(cResSet!=null)cResSet.close();cResSet=null;}catch(Exception e){}
			try {if(cState!=null)cState.close();cState=null;}catch(Exception e){}
			try {if(cConn!=null)cConn.close();cConn=null;}catch(Exception e){}
		}
		System.out.println("AutoTweet finished.");
	}
}
