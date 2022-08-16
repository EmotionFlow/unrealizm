package jp.pipa.poipiku.batch;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;

import jp.pipa.poipiku.controller.upcontents.v1.UpdateC;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.util.CTweet;

public class LimitedTimePublish extends Batch {
	static final boolean _DEBUG = false;
	static final String SRC_IMG_PATH = "/var/www/html/poipiku";	// 最後の/はDBに入っている

	private static Integer updateContentId(int nOldContentId) {
		String strSql = "";

		Integer nNewContentId = null;
		strSql = "INSERT INTO content_id_histories VALUES(?, NEXTVAL('contents_0000_content_id_seq'::regclass)) RETURNING new_id";
		try (Connection connection = dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, nOldContentId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				nNewContentId = resultSet.getInt("new_id");
			} else {
				throw new Exception("new content id is null.");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (nNewContentId != null) {
			boolean bUpdateResult;
			try (Connection connection = dataSource.getConnection()) {
				bUpdateResult = UpdateC.doUpdateContentIdTransaction(connection, nOldContentId, nNewContentId);
			} catch (SQLException e) {
				e.printStackTrace();
				bUpdateResult = false;
			}

			if (!bUpdateResult) {
				strSql = "DELETE FROM content_id_histories WHERE old_id=?";
				try (Connection connection = dataSource.getConnection();
				     PreparedStatement statement = connection.prepareStatement(strSql)) {

					statement.setInt(1, nOldContentId);
					statement.executeUpdate();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		return nNewContentId;
	}


	public static void main(String[] args) {
		ResourceBundleControl _TEX = new ResourceBundleControl();

		Log.d("start");
		LocalDateTime dtStart = LocalDateTime.now();

		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		ArrayList<Integer> lOldContentId = new ArrayList<>();
		ArrayList<Integer> lNewContentId = new ArrayList<>();
		HashMap<Integer, LimitedTimePublishLog> lLogsByOldId = new HashMap<>();
		HashMap<Integer, LimitedTimePublishLog> lLogsByNewId = new HashMap<>();

		try {
			// CONNECT DB
			cConn = dataSource.getConnection();

			// 公開状態に変更すべきコンテンツを抽出
			strSql = "SELECT content_id FROM contents_0000 WHERE limited_time_publish=TRUE AND open_id=2 AND upload_date <= CURRENT_TIMESTAMP AND end_date >= CURRENT_TIMESTAMP";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();

			while (cResSet.next()) {
				int cid = cResSet.getInt("content_id");
				LimitedTimePublishLog log = new LimitedTimePublishLog();
				log.m_datetime = dtStart;
				log.m_nOldContentId = cid;
				lLogsByOldId.put(cid, log);
				lOldContentId.add(cid);
			}
			cResSet.close();
			cResSet = null;
			cState.close();
			cState = null;

			for (int oldId : lOldContentId) {
				Integer newId = updateContentId(oldId);
				lNewContentId.add(newId);

				LimitedTimePublishLog l = lLogsByOldId.get(oldId);
				l.m_nNewContentId = newId;
				lLogsByNewId.put(newId, l);
			}

			StringBuilder sb = new StringBuilder();
			String strPrefix = "";
			for (Integer newId : lNewContentId) {
				sb.append(strPrefix);
				strPrefix = ",";
				sb.append(newId.toString());
			}

			// 公開状態にUPDATE. 新着よけboolean(false, true)をopen_idのinteger(0, 1)にキャストしている
			if (sb.length() > 0) {
				String strPublishContentIds = new String(sb);
				strSql = "UPDATE contents_0000 SET open_id=not_recently::int WHERE content_id IN (" + strPublishContentIds + ")";
				cState = cConn.prepareStatement(strSql);
				cState.executeUpdate();
				cState.close();
				cState = null;

				// ログ格納のため,udpateの結果をselect
				strSql = "SELECT content_id, user_id, open_id FROM contents_0000 WHERE content_id IN (" + strPublishContentIds + ")";
				cState = cConn.prepareStatement(strSql);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					LimitedTimePublishLog l = lLogsByNewId.get(cResSet.getInt("content_id"));
					l.m_nUserId = cResSet.getInt("user_id");
					l.m_nOpenId = cResSet.getInt("open_id");
				}

				// 期間限定公開しましたTweet
				sb.setLength(0);
				sb.append(
                """
				SELECT u.nickname, a.fldaccesstoken, a.fldsecrettoken, c.*
				FROM (tbloauth a JOIN contents_0000 c ON c.user_id=a.flduserid) JOIN users_0000 u ON c.user_id=u.user_id
				WHERE c.content_id IN(%s)
				AND mod(c.tweet_when_published, 2)=1 AND a.fldproviderid=1 AND a.fldaccesstoken IS NOT NULL AND a.fldsecrettoken IS NOT NULL AND a.del_flg=false
				""".formatted(strPublishContentIds));
				strSql = new String(sb);
				cState = cConn.prepareStatement(strSql);
				cResSet = cState.executeQuery();

				CTweet cTweet = new CTweet();
				cTweet.m_bIsTweetEnable = true;
				String strTwMsg;

				while (cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					cContent.m_cUser.m_nUserId = cResSet.getInt("user_id");
					cContent.m_cUser.m_strNickName = cResSet.getString("nickname");
					ArrayList<String> vFileList = new ArrayList<>();
					String strFileName = cContent.m_strFileName;
					if (!strFileName.isEmpty()) {
						strFileName = cContent.getThumbnailFilePath();
						if (!strFileName.isEmpty()) {
							vFileList.add(SRC_IMG_PATH + strFileName);
						}
					}
					if (!cContent.isHideThumbImg) {
						final String selectAppendFilesSql = "SELECT file_name FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id DESC LIMIT 3";
						try (Connection connection = DatabaseUtil.dataSource.getConnection();
						     PreparedStatement statement = connection.prepareStatement(selectAppendFilesSql)
						) {
							statement.setInt(1, cContent.m_nContentId);
							ResultSet resultSet = statement.executeQuery();
							while (resultSet.next()) {
								vFileList.add(SRC_IMG_PATH + resultSet.getString(1));
							}
						}
					}

					cTweet.m_nUserId = cResSet.getInt("user_id");
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
					if (cContent.m_nTweetWhenPublished == 1 || vFileList.isEmpty()) {    // text only
						if (!_DEBUG) {
							nTweetResult = cTweet.Tweet(strTwMsg);
						}
					} else { // with image
						nTweetResult = cTweet.Tweet(strTwMsg, vFileList, _DEBUG);
					}
					LimitedTimePublishLog l = lLogsByNewId.get(cContent.m_nContentId);
					l.m_nTweetResult = nTweetResult;
					if (nTweetResult == CTweet.OK) {
						String strTweetId = Long.toString(cTweet.m_statusLastTweet.getId());
						PreparedStatement cStateUpdateTwId = cConn.prepareStatement("UPDATE contents_0000 SET tweet_id=? WHERE content_id=? ");
						cStateUpdateTwId.setString(1, strTweetId);
						cStateUpdateTwId.setInt(2, cContent.m_nContentId);
						cStateUpdateTwId.executeUpdate();
					}
				}
				cResSet.close();
				cResSet = null;
				cState.close();
				cState = null;
			}

			// 非公開にすべきコンテンツを更新
			strSql = "SELECT * FROM contents_0000 WHERE limited_time_publish=TRUE AND (open_id=0 OR open_id=1) AND (upload_date > CURRENT_TIMESTAMP OR end_date < CURRENT_TIMESTAMP)";
			cState = cConn.prepareStatement(strSql);
			cResSet = cState.executeQuery();
			ArrayList<CContent> unpublishContents = new ArrayList<>();
			while (cResSet.next()) {
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
			cResSet.close();
			cResSet = null;
			cState.close();
			cState = null;

			if (unpublishContents.size() > 0) {
				strSql = "UPDATE contents_0000 SET open_id=2 WHERE content_id IN (" +
						unpublishContents.stream()
								.map(e -> Integer.valueOf(e.m_nContentId).toString())
								.collect(Collectors.joining(",")) +
						" )";
				cState = cConn.prepareStatement(strSql);
				cState.executeUpdate();
				cState.close();
				cState = null;
			}

			if (!_DEBUG) {
				CTweet tweet = new CTweet();
				for (CContent content : unpublishContents) {
					if (!content.m_strTweetId.isEmpty()) {
						tweet.GetResults(content.m_nUserId);
						if (tweet.m_bIsTweetEnable) {
							tweet.Delete(content.m_strTweetId);
						}
					}
				}
			}

			for (Integer key : lLogsByOldId.keySet()) {
				LimitedTimePublishLog l = lLogsByOldId.get(key);
				Log.d(l.toString());
			}

		} catch (Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try {
				if (cResSet != null) cResSet.close();
				cResSet = null;
			} catch (Exception e) {
			}
			try {
				if (cState != null) cState.close();
				cState = null;
			} catch (Exception e) {
			}
			try {
				if (cConn != null) cConn.close();
				cConn = null;
			} catch (Exception e) {
			}
		}
		Log.d("end");
	}
}
