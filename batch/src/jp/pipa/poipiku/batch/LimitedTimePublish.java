package jp.pipa.poipiku.batch;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;

import jp.pipa.poipiku.controller.UpdateC;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.util.CTweet;

public class LimitedTimePublish extends Batch {

	private static Logger logger = LogManager.getLogger(LimitedTimePublish.class);
	static final boolean _DEBUG = false;
	static final String DB_NAME			= (_DEBUG)?"jdbc:postgresql://localhost:58321/poipiku":"jdbc:postgresql://localhost:5432/poipiku";
	static final String DB_PORT   		= "5432";
	static final String DB_USER      	= "postgres";
	static final String DB_PASSWORD  	= (_DEBUG)?"knniwis4it":"dbpass";
	ResourceBundleControl _TEX = null;
	static final String SRC_IMG_PATH = "/var/www/html/poipiku";	// 最後の/はDBに入っている


	private static Integer updateContentId(int nOldContentId){
		Connection  cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		Integer nNewContentId=null;
		try{
			cConn = dataSource.getConnection();

			strSql = "INSERT INTO content_id_histories VALUES(?, nextval('contents_0000_content_id_seq'::regclass)) RETURNING new_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nOldContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nNewContentId = cResSet.getInt("new_id");
			} else {
				throw new Exception("new content id is null.");
			}
		}catch(Exception e){
			e.printStackTrace();
		}finally{
			try{cResSet.close();cResSet=null;}catch(SQLException se){};
			try{cState.close();cState=null;}catch(SQLException se){};
		}

		if(nNewContentId!=null){
			boolean bUpdateResult;
			try {
				bUpdateResult = UpdateC.doUpdateContentIdTransaction(cConn, nOldContentId, nNewContentId);
			} catch (SQLException e) {
				e.printStackTrace();
				bUpdateResult = false;
			} finally {
				try{cConn.close();cConn=null;}catch(SQLException se){};
			}

			if(!bUpdateResult){
				try{
					cConn = dataSource.getConnection();
					nNewContentId=null;
					strSql = "DELETE FROM content_id_histories WHERE old_id=?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, nOldContentId);
					cState.executeUpdate();
				}catch(Exception e){
					e.printStackTrace();
				}finally{
					try{cState.close();cState=null;}catch(SQLException se){};
				}
			}
		}
		return nNewContentId;
	}


	public static void main(String args[]) {
		ResourceBundleControl _TEX = new ResourceBundleControl();

		//Logger.getLogger(PushNotification.class).setLevel(Level.OFF);
		System.setProperty("log4j.rootLogger","INFO");
		//System.setProperty("org.apache.log4j.Level","OFF");
		System.setProperty("org.slf4j.simpleLogger.defaultLogLevel","OFF");

		BasicConfigurator.configure();
		logger.setLevel(Level.INFO);

		logger.info("start");
		LocalDateTime dtStart = LocalDateTime.now();

		Connection  cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		ArrayList<Integer> lOldContentId = new ArrayList<Integer>();
		ArrayList<Integer> lNewContentId = new ArrayList<Integer>();
		HashMap<Integer, LimitedTimePublishLog> lLogsByOldId = new HashMap<Integer, LimitedTimePublishLog>();
		HashMap<Integer, LimitedTimePublishLog> lLogsByNewId = new HashMap<Integer, LimitedTimePublishLog>();

		try {
			// CONNECT DB
			Class.forName("org.postgresql.Driver");
			cConn = DriverManager.getConnection(DB_NAME, DB_USER, DB_PASSWORD);

			// 公開状態に変更すべきコンテンツを抽出
			strSql = "SELECT content_id FROM contents_0000 WHERE limited_time_publish=true AND open_id=2 AND upload_date <= CURRENT_TIMESTAMP AND end_date >= CURRENT_TIMESTAMP";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();

			while(cResSet.next()) {
				int cid = cResSet.getInt("content_id");
				LimitedTimePublishLog log = new LimitedTimePublishLog();
				log.m_datetime = dtStart;
				log.m_nOldContentId = cid;
				lLogsByOldId.put(cid, log);
				lOldContentId.add(cid);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			for(int oldId : lOldContentId){
				Integer newId = updateContentId(oldId);
				lNewContentId.add(newId);

				LimitedTimePublishLog l = lLogsByOldId.get(oldId);
				l.m_nNewContentId = newId;
				lLogsByNewId.put(newId, l);
			}

			StringBuilder sb = new StringBuilder();
			String strPrefix = "";
			for(Integer newId : lNewContentId){
				sb.append(strPrefix);
				strPrefix = ",";
				sb.append(newId.toString());
			}

			// 公開状態にUPDATE. 新着よけboolean(false, true)をopen_idのinteger(0, 1)にキャストしている
			if(sb.length()>0){
				String strPublishContentIds = new String(sb);
				strSql = "UPDATE contents_0000 SET open_id=not_recently::int WHERE content_id IN (" + strPublishContentIds + ")";
				cState = cConn.prepareStatement(strSql);
				cState.executeUpdate();
				cState.close();cState=null;

				// ログ格納のため,udpateの結果をselect
				strSql = "SELECT content_id, user_id, open_id FROM contents_0000 WHERE content_id IN (" + strPublishContentIds + ")";
				cState = cConn.prepareStatement(strSql);
				cResSet = cState.executeQuery();
				while(cResSet.next()) {
					LimitedTimePublishLog l = lLogsByNewId.get(cResSet.getInt("content_id"));
					l.m_nUserId = cResSet.getInt("user_id");
					l.m_nOpenId = cResSet.getInt("open_id");
				}

				// 期間限定公開しましたTweet
				sb.setLength(0);
				sb.append("SELECT u.nickname, a.fldaccesstoken, a.fldsecrettoken, c.*")
						.append(" FROM (tbloauth a JOIN contents_0000 c ON c.user_id=a.flduserid) JOIN users_0000 u ON c.user_id=u.user_id")
						.append(" WHERE c.content_id IN(").append(strPublishContentIds).append(")")
						.append(" AND c.tweet_when_published <> 0 AND a.fldproviderid=1 AND a.fldaccesstoken IS NOT NULL AND a.fldsecrettoken IS NOT NULL AND a.del_flg=false");
				strSql = new String(sb);
				cState = cConn.prepareStatement(strSql);
				cResSet = cState.executeQuery();

				CTweet cTweet = new CTweet();
				cTweet.m_bIsTweetEnable = true;
				String strTwMsg;
				ArrayList<String> vFileList = new ArrayList<String>();

				while(cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					cContent.m_cUser.m_nUserId = cResSet.getInt("user_id");
					cContent.m_cUser.m_strNickName = cResSet.getString("nickname");
					String strFileName = cContent.m_strFileName;
					if(!strFileName.isEmpty()) {
						switch(cContent.m_nPublishId) {
							case Common.PUBLISH_ID_R15:
							case Common.PUBLISH_ID_R18:
							case Common.PUBLISH_ID_R18G:
							case Common.PUBLISH_ID_PASS:
							case Common.PUBLISH_ID_LOGIN:
							case Common.PUBLISH_ID_FOLLOWER:
							case Common.PUBLISH_ID_T_FOLLOWER:
							case Common.PUBLISH_ID_T_FOLLOWEE:
							case Common.PUBLISH_ID_T_EACH:
							case Common.PUBLISH_ID_T_LIST:
								strFileName = Common.PUBLISH_ID_FILE[cContent.m_nPublishId];
								break;
							case Common.PUBLISH_ID_ALL:
							case Common.PUBLISH_ID_HIDDEN:
							default:
								strFileName = cContent.m_strFileName;
								break;
						}

						if(!strFileName.isEmpty()) {
							strFileName = String.format("%s%s_360.jpg", SRC_IMG_PATH, strFileName);
							vFileList.add(strFileName);
						}
					}

					cTweet.m_strUserAccessToken = cResSet.getString("fldaccesstoken");
					cTweet.m_strSecretToken = cResSet.getString("fldsecrettoken");
					strTwMsg = CTweet.generateWithTweetMsg(cContent, _TEX);

					LocalDateTime ldt = cContent.m_timeEndDate.toLocalDateTime();
					ZonedDateTime zdtSystemDefault = ldt.atZone(ZoneId.systemDefault());
					ZonedDateTime zdtTokyo = zdtSystemDefault.withZoneSameInstant(ZoneId.of("Asia/Tokyo"));

					String strEndDate = zdtTokyo.format(DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm"));

					strTwMsg += " " + String.format(_TEX.T("Tweet.Message.LimitedTime"), strEndDate);

					// ツイート
					int nTweetResult = CTweet.ERR_OTHER;
					if(cContent.m_nTweetWhenPublished==1 || vFileList.size()<=0) {	// text only
						nTweetResult = cTweet.Tweet(strTwMsg);
					} else { // with image
						nTweetResult = cTweet.Tweet(strTwMsg, vFileList);
					}
					LimitedTimePublishLog l = lLogsByNewId.get(cContent.m_nContentId);
					l.m_nTweetResult = nTweetResult;
					if(nTweetResult == CTweet.OK){
						String strTweetId = Long.toString(cTweet.m_statusLastTweet.getId());
						PreparedStatement cStateUpdateTwId = cConn.prepareStatement("UPDATE contents_0000 SET tweet_id=? WHERE content_id=? ");
						cStateUpdateTwId.setString(1, strTweetId);
						cStateUpdateTwId.setInt(2, cContent.m_nContentId);
						cStateUpdateTwId.executeUpdate();
					}
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// 非公開にすべきコンテンツを更新
			strSql = "SELECT * FROM contents_0000 WHERE limited_time_publish=true AND (open_id=0 OR open_id=1) AND (upload_date > CURRENT_TIMESTAMP OR end_date < CURRENT_TIMESTAMP)";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();
			ArrayList<CContent> unpublishContents = new ArrayList<>();
			while(cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				unpublishContents.add(cContent);
				LimitedTimePublishLog l = new LimitedTimePublishLog();
				l.m_datetime = dtStart;
				l.m_nOldContentId = cContent.m_nContentId;
				l.m_nNewContentId = cContent.m_nContentId;
				l.m_nUserId = cContent.m_nUserId;
				l.m_nOpenId = 2;
				lLogsByOldId.put(cContent.m_nContentId, l);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if(unpublishContents.size()>0){
				strSql = "UPDATE contents_0000 SET open_id=2 WHERE content_id IN (" +
						unpublishContents.stream()
								.map( e -> Integer.valueOf(e.m_nContentId).toString())
								.collect(Collectors.joining(",")) +
						" )";
				cState = cConn.prepareStatement(strSql);
				cState.executeUpdate();
				cState.close();cState=null;
			}

			CTweet tweet = new CTweet();
			for (CContent content : unpublishContents) {
				if (!content.m_strTweetId.isEmpty()) {
					tweet.GetResults(content.m_nUserId);
					if (tweet.m_bIsTweetEnable) {
						tweet.Delete(content.m_strTweetId);
					}
				}
			}

			for(Integer key : lLogsByOldId.keySet()){
				LimitedTimePublishLog l = lLogsByOldId.get(key);
				logger.info(l.toString());
			}

		} catch (Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try {if(cResSet!=null)cResSet.close();cResSet=null;}catch(Exception e){}
			try {if(cState!=null)cState.close();cState=null;}catch(Exception e){}
			try {if(cConn!=null)cConn.close();cConn=null;}catch(Exception e){}
		}
		logger.info("end");
	}
}
