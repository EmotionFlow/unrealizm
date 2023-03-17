package jp.pipa.poipiku.util;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import java.util.stream.Collectors;

import jp.pipa.poipiku.*;
import twitter4j.Friendship;
import twitter4j.IDs;
import twitter4j.ResponseList;
import twitter4j.Status;
import twitter4j.User;
import twitter4j.StatusUpdate;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.UploadedMedia;
import twitter4j.UserList;
import twitter4j.conf.ConfigurationBuilder;

public final class CTweet {
	public boolean m_bIsTweetEnable = false;
	public String m_strUserAccessToken = "";
	public String m_strSecretToken = "";
	public String m_strScreenName = "";
	public int m_nUserId = -1;
	public long m_lnTwitterUserId = -1;
	public ResponseList<UserList> m_listOpenList = null;
	public static final int MAX_LENGTH = 130;
	public static final String ELLIPSE = "...";

	public static final int FRIENDSHIP_UNDEF = -1;		// 未定義
	public static final int FRIENDSHIP_NONE = 0;		// 無関係
	public static final int FRIENDSHIP_FOLLOWEE = 1;	// フォローしている
	public static final int FRIENDSHIP_FOLLOWER = 2;	// フォローされている
	public static final int FRIENDSHIP_EACH = 3;		// 相互フォロー

	public static final int RETWEET_ALREADY = 4;		// すでにRT済み
	public static final int RETWEET_DONE    = 5;		// RTした

	public static final int OK = 1;
	public static final int ERR_NOT_FOUND = -404000;
	public static final int ERR_RATE_LIMIT_EXCEEDED = -429088;
	public static final int ERR_INVALID_OR_EXPIRED_TOKEN = -404089;
	public static final int ERR_USER_IS_OVER_DAILY_STATUS_UPDATE_LIMIT = -403185;
	public static final int ERR_TARGET_TW_ACCOUNT_NOT_FOUND = -999997;
	public static final int ERR_TWEET_DISABLE = -999998;
	public static final int ERR_OTHER = -999999;
	public Status m_statusLastTweet = null;

	public static final long GET_FRIEND_MAX = 30000L;
	private int m_nLastTargetUserId = -1;
	private long m_lnLastTwitterTargetUserId = -1;


	private Twitter createTwitter4jInstance(){
		ConfigurationBuilder cb = new ConfigurationBuilder();
		cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
		TwitterFactory tf = new TwitterFactory(cb.build());
		return tf.getInstance();
	}


	private void LoggingTwitterException(TwitterException te, long targetTwitterUserId, long listId){
		String strCallFrom = "";
		StackTraceElement[] steArray = Thread.currentThread().getStackTrace();
		if (steArray.length <= 3) {
			strCallFrom =  "???";
		} else {
			StackTraceElement ste = steArray[2];
			strCallFrom = ste.getMethodName();
		}
		//Log.d(String.format("TwitterException, %s, %d, %s, %d, %s", strCallFrom, te.getStatusCode() , m_strUserAccessToken, te.getErrorCode(), te.getMessage()));
		TwitterApiErrorLog log = new TwitterApiErrorLog();
		log.userId = m_nUserId;
		log.twitterUserid = m_lnTwitterUserId;
		log.targetTwitterUserid = targetTwitterUserId;
		log.listId = listId;
		log.callMethod = strCallFrom;
		log.statusCode = te.getStatusCode();
		log.accessToken = m_strUserAccessToken;
		log.errorCode = te.getErrorCode();
		log.errorMessage = te.getErrorMessage();
		log.insert();
	}

	private static int GetErrorCode(TwitterException te){
		return GetErrorCode(te.getErrorCode(), te.getStatusCode());
	}

	private static int GetErrorCode(int twitterErrorCode, int statusCode) {
//		Log.d(String.format("err: %d, st:%d", twitterErrorCode, statusCode));
		int nErrCode = ERR_OTHER;
		if(twitterErrorCode==89){
			nErrCode = ERR_INVALID_OR_EXPIRED_TOKEN;
		} else if(twitterErrorCode==88) {
			nErrCode = ERR_RATE_LIMIT_EXCEEDED;
		} else if(twitterErrorCode==185) {
			nErrCode = ERR_USER_IS_OVER_DAILY_STATUS_UPDATE_LIMIT;
		} else if(statusCode==404) {
			nErrCode = ERR_NOT_FOUND;
		}
//		Log.d("nErrCode: " + nErrCode);
		return nErrCode;
	}


	public boolean GetResults(int nUserId) {
		if (nUserId<=0) {
			m_bIsTweetEnable = false;
			return false;
		}
		boolean bResult = true;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();
			strSql = "SELECT fldaccesstoken,fldsecrettoken,twitter_user_id,twitter_screen_name FROM tbloauth WHERE flduserid=? AND fldproviderid=? AND del_flg=false";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			if(cResSet.next()){
				// Token格納
				m_strUserAccessToken = cResSet.getString("fldaccesstoken");
				m_strSecretToken = cResSet.getString("fldsecrettoken");
				m_nUserId = nUserId;
				m_lnTwitterUserId = Util.toLong(cResSet.getString("twitter_user_id"));
				m_strScreenName = cResSet.getString("twitter_screen_name");
				m_bIsTweetEnable = true;
			} else {
				m_bIsTweetEnable = false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
			m_bIsTweetEnable = false;
		} finally {
			try {if(cResSet!=null)cResSet.close();}catch(Exception e){}
			try {if(cState!=null)cState.close();}catch(Exception e){}
			try {if(cConn!=null)cConn.close();}catch(Exception e){}
		}
		return bResult;
	}

	public int GetMyOpenLists() {
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		int nResult = OK;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			m_listOpenList = twitter.getUserLists(m_lnTwitterUserId, true);
			m_listOpenList.removeIf(a -> !a.isPublic());
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te, -1, -1);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int Tweet(String strTweet) {
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		int nResult = OK;
		m_statusLastTweet = null;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			m_statusLastTweet = twitter.updateStatus(strTweet);
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te, -1, -1);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int Tweet(String strTweet, String strFileName) {
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		int nResult = OK;
		m_statusLastTweet = null;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			m_statusLastTweet = twitter.updateStatus(new StatusUpdate(strTweet).media(new File(strFileName)));
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te, -1, -1);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int Tweet(String strTweet, ArrayList<String> vFileList, boolean isDebug) {
		int FRAME_PADDING = 3;
		int FRAME_SIZE_BASE = 800;

		if(!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		if(vFileList.size()<=0) return ERR_OTHER;
		int nResult = OK;
		m_statusLastTweet = null;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();

			// 貼り付け先フレームの作成
			int numX = (int)Math.ceil(Math.sqrt(vFileList.size()));
			int numY = (int)Math.ceil((double)vFileList.size()/(double)numX);
			int thumn_size = FRAME_SIZE_BASE / numX;
			int FRAME_SIZE_X = thumn_size*numX+FRAME_PADDING*(numX+1);
			int FRAME_SIZE_Y = thumn_size*numY+FRAME_PADDING*(numY+1);
			BufferedImage frame = new BufferedImage(FRAME_SIZE_X, FRAME_SIZE_Y, BufferedImage.TYPE_INT_RGB);
			Graphics2D g = frame.createGraphics();
			g.setColor(Color.white);
			g.fillRect(0, 0, FRAME_SIZE_X, FRAME_SIZE_Y);

			String profPathStr = Common.makeUserProfDir(m_nUserId);
			Path profPath;
			if (profPathStr != null) {
				profPath = Paths.get(profPathStr);
			} else {
				Log.d("prof path の生成に失敗した");
				return -99;
			}

			// 1枚ずつ貼り付け
			int fileIdx = 0;
			for (int y=0; y<numY; y++) {
				for (int x=0; x<numX; x++) {
					Log.d("Tweet image:" + (fileIdx + 1) + "/" + vFileList.size());
					if(fileIdx >= vFileList.size()) break;
					String strSrcFileName = vFileList.get(fileIdx);
					Path srcPath = Paths.get(strSrcFileName);
					String strDstFileName = profPath.resolve(srcPath.getFileName()) + "_twitter_thumb.png";
					ImageUtil.createThumbNormalize(strSrcFileName, strDstFileName, thumn_size, false);
					BufferedImage image = ImageUtil.read(strDstFileName);
					g.drawImage(image, (x+1)*FRAME_PADDING+x*thumn_size, (y+1)*FRAME_PADDING+y*thumn_size, thumn_size, thumn_size, Color.white, null);
					Util.deleteFile(strDstFileName);
					fileIdx++;
				}
			}

			// 集約画像を保存
			Path firstPath = Paths.get(vFileList.get(0));
			String strDstFileName = profPath.resolve(firstPath.getFileName()) + "_twitter.png";
			ImageUtil.savePng(frame, strDstFileName);
			g.dispose();

			Log.d("集約画像 " + strDstFileName);

			// Twitterに投稿
			if (!isDebug) {
				UploadedMedia media = twitter.uploadMedia(new File(strDstFileName));
				long[] vMediaList = new long[1];
				vMediaList[0] = media.getMediaId();
				StatusUpdate update = new StatusUpdate(strTweet);
				update.setMediaIds(vMediaList);
				m_statusLastTweet = twitter.updateStatus(update);
				Util.deleteFile(strDstFileName);
			}
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te, -1, -1);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int Tweet_org(String strTweet, ArrayList<String> vFileList) {
		if(!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		if(vFileList.size()<=0) return ERR_OTHER;
		int nResult = OK;
		m_statusLastTweet = null;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();

			long[] vMediaList = new long[vFileList.size()];
			for(int index = 0; index<vFileList.size() && index<4; index++) {
				String strSrcFileName = vFileList.get(index);
				String strDstFileName = strSrcFileName+"_twitter.jpg";
				BufferedImage cImage = ImageUtil.read(strSrcFileName);
				int nWidth = cImage.getWidth();
				int nHeight = cImage.getHeight();
				if(nWidth<=2048 && nHeight<=2048) {
					Path pathSrc = Paths.get(strSrcFileName);
					Path pathDst = Paths.get(strDstFileName);
					try {
						Files.copy(pathSrc, pathDst);
					} catch (Exception e) {
						;
					}
				} else if(nWidth<nHeight) {
					ImageUtil.createThumb(strSrcFileName, strDstFileName, 0, 2048, true);
				} else {
					ImageUtil.createThumb(strSrcFileName, strDstFileName, 2048, 0, true);
				}
				UploadedMedia media = twitter.uploadMedia(new File(strDstFileName));
				vMediaList[index] = media.getMediaId();
				Util.deleteFile(strDstFileName);
			}

			StatusUpdate update = new StatusUpdate(strTweet);
			update.setMediaIds(vMediaList);
			m_statusLastTweet = twitter.updateStatus(update);
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te, -1, -1);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int Delete(String strTweetId){
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		int nResult = OK;
		m_statusLastTweet = null;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			m_statusLastTweet = twitter.destroyStatus(Long.parseLong(strTweetId));
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te, -1, -1);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int ReTweet(int contentId, long tweetId){
		if (!m_bIsTweetEnable || contentId<=0 || tweetId<=0 || m_nUserId<=0) {
			Log.d(String.format("ReTweetError: %b, %d, %d, %d",m_bIsTweetEnable, contentId, tweetId, m_nUserId));
			return ERR_TWEET_DISABLE;
		}
		if (TwitterRetweet.find(m_nUserId, contentId)) return RETWEET_ALREADY;

		int result;
		try{
			int loops = 0;
			long cursor = -1;
			Twitter twitter = createTwitter4jInstance();
			IDs ids;
			boolean isFound = false;
			while (loops++ < 20) {
				ids = twitter.getRetweeterIds(tweetId, cursor);
				long[] idAry = ids.getIDs();

//				Long[] idLst = Arrays.stream(idAry).boxed().toArray(Long[]::new);
//				Log.d(Arrays.stream(idLst).map(Object::toString).collect(Collectors.joining(",")));

				for (long id: idAry){
					if (id == m_lnTwitterUserId) {
						isFound = true;
						break;
					}
				}
				if (!ids.hasNext()) {
					break;
				} else {
					cursor = ids.getNextCursor();
				}
			}

			if (isFound) {
				TwitterRetweet.insert(m_nUserId, m_lnTwitterUserId, contentId);
				return RETWEET_ALREADY;
			} else {
				boolean alreadyRetweeted = false;
				try {
					twitter.retweetStatus(tweetId);
				} catch (TwitterException retwtex) {
					if (retwtex.getErrorCode() == 327) {
						alreadyRetweeted = true;
					} else {
						throw retwtex;
					}
				}
				TwitterRetweet.insert(m_nUserId, m_lnTwitterUserId, contentId);
				return alreadyRetweeted ? RETWEET_ALREADY : RETWEET_DONE;
			}
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te, -1, -1);
			result = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			result = ERR_OTHER;
		}
		return result;
	}

	public int LookupFriendship(int nTargetUserId, int publishId){
		int nResult = FRIENDSHIP_UNDEF;
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;

		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();
			// ターゲットユーザのTwitterID取得
			strSql = "SELECT twitter_user_id FROM tbloauth WHERE flduserid=? AND fldproviderid=? AND del_flg=false ORDER BY id DESC";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nTargetUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			if(cResSet.next()){
				m_nLastTargetUserId = nTargetUserId;
				m_lnLastTwitterTargetUserId = Long.parseLong(cResSet.getString("twitter_user_id"));
			} else {
				return ERR_TARGET_TW_ACCOUNT_NOT_FOUND;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			cConn.close();cConn=null;
			if(m_lnLastTwitterTargetUserId==-1L){
				return ERR_OTHER;
			}

			// DBに15分以内のフォローがあるか
			boolean bFollowing = checkDBFriendInfo(m_nUserId, nTargetUserId);
			// DBに15分以内の被フォローがあるか
			boolean bFollower = checkDBFriendInfo(nTargetUserId, m_nUserId);

			// DBキャッシュによる判定
			if(publishId == Common.PUBLISH_ID_T_EACH && bFollowing && bFollower) {return FRIENDSHIP_EACH;};
			if(publishId == Common.PUBLISH_ID_T_FOLLOWER && bFollowing) {return FRIENDSHIP_FOLLOWEE;};
			if(publishId == Common.PUBLISH_ID_T_FOLLOWEE && bFollower) {return FRIENDSHIP_FOLLOWER;};

			// 60秒以内のAPIエラーを取得、新しい順。
			List<TwitterApiErrorLog> errorLogs = TwitterApiErrorLog.selectLookupFriendshipErrors(m_nUserId, 60);
			if (errorLogs.size() > 0) {
				return GetErrorCode(errorLogs.get(0).errorCode, errorLogs.get(0).statusCode);
			}

			// DBに無い場合、ID間のFriend関係を確認
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			ResponseList<Friendship> lookupResults = twitter.lookupFriendships(m_lnLastTwitterTargetUserId);
			if(lookupResults.size() > 0){
				cConn = DatabaseUtil.dataSource.getConnection();
				//strSql = "INSERT INTO twitter_friends(user_id, twitter_user_id, twitter_follow_user_id) VALUES (?, ?, ?, ?) ON CONFLICT DO NOTHING;";
				strSql = "INSERT INTO twitter_friends(user_id, twitter_user_id, follow_user_id, twitter_follow_user_id) "
						+ "VALUES (?, ?, ?, ?) "
						+ "ON CONFLICT (user_id, twitter_follow_user_id) "
						+ "DO UPDATE SET last_update_date=CURRENT_TIMESTAMP; ";
				cState = cConn.prepareStatement(strSql);
				Friendship f = lookupResults.get(0);
				if(f.isFollowing() && f.isFollowedBy()){
					nResult = FRIENDSHIP_EACH;
					cState.setInt(1, m_nUserId);
					cState.setLong(2, m_lnTwitterUserId);
					cState.setLong(3, nTargetUserId);
					cState.setLong(4, m_lnLastTwitterTargetUserId);
					cState.executeUpdate();
					cState.setLong(1, nTargetUserId);
					cState.setLong(2, m_lnLastTwitterTargetUserId);
					cState.setInt(3, m_nUserId);
					cState.setLong(4, m_lnTwitterUserId);
					cState.executeUpdate();
				} else if(f.isFollowing() && !f.isFollowedBy()){
					nResult = FRIENDSHIP_FOLLOWEE;
					cState.setInt(1, m_nUserId);
					cState.setLong(2, m_lnTwitterUserId);
					cState.setLong(3, nTargetUserId);
					cState.setLong(4, m_lnLastTwitterTargetUserId);
					cState.executeUpdate();
				} else if(!f.isFollowing() && f.isFollowedBy()){
					nResult = FRIENDSHIP_FOLLOWER;
					cState.setLong(1, nTargetUserId);
					cState.setLong(2, m_lnLastTwitterTargetUserId);
					cState.setInt(3, m_nUserId);
					cState.setLong(4, m_lnTwitterUserId);
					cState.executeUpdate();
				} else {
					nResult = FRIENDSHIP_NONE;
				}
				cState.close();cState=null;
				cConn.close();cConn=null;
			}
		} catch (TwitterException te) {
			LoggingTwitterException(te, m_lnLastTwitterTargetUserId, -1);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			nResult = ERR_OTHER;
		} finally {
			try {if(cResSet!=null)cResSet.close();}catch(Exception e){}
			try {if(cState!=null)cState.close();}catch(Exception e){}
			try {if(cConn!=null)cConn.close();}catch(Exception e){}
		}
		return nResult;
	}

	// twitter_friendsに15分以内のフォローがあるか
	private boolean checkDBFriendInfo(int userId, int targetUserId) {
		boolean bFollow = false;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			//strSql = "SELECT * FROM twitter_friends WHERE user_id=? AND follow_user_id=? AND last_update_date<CURRENT_TIMESTAMP-interval'15 minutes' LIMIT 1";
			strSql = "SELECT user_id FROM twitter_friends WHERE user_id=? AND follow_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, userId);
			cState.setInt(2, targetUserId);
			cResSet = cState.executeQuery();
			bFollow = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {if(cResSet!=null)cResSet.close();}catch(Exception e){}
			try {if(cState!=null)cState.close();}catch(Exception e){}
			try {if(cConn!=null)cConn.close();}catch(Exception e){}
		}
		return bFollow;
	}

	public void updateDBFollowInfoFromTwitter(int userId) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		// twitter_user_id取得
		long twitterUserId = -1;
		if(userId==m_nUserId) {
			twitterUserId=m_lnTwitterUserId;
		} else if(userId==m_nLastTargetUserId) {
			twitterUserId=m_lnLastTwitterTargetUserId;
		} else {
			try {
				connection = DatabaseUtil.dataSource.getConnection();
				sql = "SELECT twitter_user_id FROM tbloauth WHERE flduserid=? AND fldproviderid=? AND del_flg=false";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, userId);
				statement.setInt(2, Common.TWITTER_PROVIDER_ID);
				resultSet = statement.executeQuery();
				if(resultSet.next()){
					twitterUserId = Long.parseLong(resultSet.getString("twitter_user_id"));
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				try {if(resultSet!=null)resultSet.close();}catch(Exception e){}
				try {if(statement!=null)statement.close();}catch(Exception e){}
				try {if(connection!=null)connection.close();}catch(Exception e){}
			}
		}
		if(twitterUserId==-1) return;

		// userIdがフォローしているIDをTwitterから取得
		ArrayList<Long> followIdList = new ArrayList<>(); // エラーが起きてもそれまで取れたものがあれば続行
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			long cursor = -1;
			do {
				IDs ids = twitter.getFriendsIDs(twitterUserId, cursor);
				for (long id : ids.getIDs()) {
					followIdList.add(id);
				}
				cursor = ids.getNextCursor();
			} while(cursor>=0 && cursor<GET_FRIEND_MAX);
		} catch (Exception e) {
			Log.d("getFriendsIDs Limit error : " + twitterUserId + "," + followIdList.size());
			//e.printStackTrace();
		}
		if(followIdList.isEmpty()) return;

		// 取れたものを追加
		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// 古いものを削除
			sql = "DELETE FROM twitter_friends WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setLong(1, userId);
			statement.executeUpdate();
			statement.close();statement=null;

			// 新しく追加
			sql = "INSERT INTO twitter_friends(user_id, twitter_user_id, twitter_follow_user_id) " +
					" VALUES ";
			final String prefix = String.format("(%d,%d,", userId, m_lnTwitterUserId);
			final String suffix = ")";
			sql += followIdList.stream()
					.map(e -> prefix + e + suffix)
					.collect(Collectors.joining(","));
			statement = connection.prepareStatement(sql);
			statement.executeUpdate();
			statement.close();statement=null;


			// Unrealizm上のuser_id紐付け
			sql = "WITH a AS (" +
					"    SELECT twitter_follow_user_id" +
					"    FROM twitter_friends" +
					"    WHERE user_id = ?" +
					" )" +
					" SELECT DISTINCT flduserid, CAST(twitter_user_id AS bigint)" +
					" FROM tbloauth" +
					" WHERE twitter_user_id IN (SELECT CAST(twitter_follow_user_id AS varchar) FROM a)" +
					"   AND del_flg = FALSE";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();

			Map<Integer, Long> map = new HashMap<>();
			while (resultSet.next()) {
				map.put(resultSet.getInt(1), resultSet.getLong(2));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if (map.size()>0) {
				sql = "UPDATE twitter_friends SET follow_user_id=? WHERE user_id=? AND twitter_follow_user_id=?";
				statement = connection.prepareStatement(sql);
				for (Map.Entry<Integer, Long> entry: map.entrySet()) {
					statement.setInt(1, entry.getKey());
					statement.setInt(2, userId);
					statement.setLong(3, entry.getValue());
					statement.executeUpdate();
				}
				statement.close();statement=null;
			}

			// 既存レコードに自分のTwitterIDがあったらUPDATE
			sql = "UPDATE twitter_friends" +
					" SET follow_user_id = ?" +
					" WHERE twitter_follow_user_id = (" +
					"    SELECT CAST(tbloauth.twitter_user_id AS bigint)" +
					"    FROM tbloauth" +
					"    WHERE flduserid = ?" +
					"      AND del_flg = FALSE" +
					"    ORDER BY id DESC" +
					"    LIMIT 1" +
					")";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, userId);
			statement.executeUpdate();
			statement.close();statement=null;

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {if(resultSet!=null)resultSet.close();}catch(Exception e){}
			try {if(statement!=null)statement.close();}catch(Exception e){}
			try {if(connection!=null)connection.close();}catch(Exception e){}
		}
	}

	public int LookupListMember(CContent content){
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		if (content.m_strListId.isEmpty()) {
			Log.d("content.m_strListId.isEmpty()");
			return ERR_OTHER;
		}

		List<TwitterApiErrorLog> errorLogs = TwitterApiErrorLog.selectListErrors(m_nUserId, Long.parseLong(content.m_strListId), 60);
		if (errorLogs.size() > 0) {
			TwitterApiErrorLog log = errorLogs.get(0);
			return GetErrorCode(log.errorCode, log.statusCode);
		}

		int nResult = ERR_OTHER;

		boolean bFind = false;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		long lnListId = -1;
		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			// DBのリストキャッシュを確認
			//strSql = "SELECT * FROM twitter_lists WHERE list_id=? AND user_id=? AND last_update_date<CURRENT_TIMESTAMP-interval'15 minutes' LIMIT 1";
			strSql = "SELECT user_id FROM twitter_lists WHERE list_id=? AND user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setLong(1, Long.parseLong(content.m_strListId));
			cState.setInt(2, m_nUserId);
			cResSet = cState.executeQuery();
			bFind = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			cConn.close();cConn=null;
			if(bFind){
				return OK;
			}

			lnListId = Long.parseLong(content.m_strListId);
			// DBに存在しなければTwitterに問い合わせ
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			/*User u = */twitter.showUserListMembership(lnListId, m_lnTwitterUserId);
			nResult = OK;

			// キャッシュへ登録
			cConn = DatabaseUtil.dataSource.getConnection();
			strSql = "INSERT INTO twitter_lists(list_id, twitter_user_id, user_id) "
					+ "VALUES (?, ?, ?) ON CONFLICT (list_id, user_id) DO UPDATE SET last_update_date=CURRENT_TIMESTAMP;";
			cState = cConn.prepareStatement(strSql);
			cState.setLong(1, lnListId);
			cState.setLong(2, m_lnTwitterUserId);
			cState.setInt(3, m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			cConn.close();cConn=null;
		}catch(TwitterException te){
			LoggingTwitterException(te, -1, lnListId);
			nResult = GetErrorCode(te);
		}catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			nResult = ERR_OTHER;
		} finally {
			try {if(cResSet!=null)cResSet.close();}catch(Exception e){}
			try {if(cState!=null)cState.close();}catch(Exception e){}
			try {if(cConn!=null)cConn.close();}catch(Exception e){}
		}
		return nResult;
	}

	public String GetEmailAddress(){
		if (!m_bIsTweetEnable) return null;
		User u = null;
		try{
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
					.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
					.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
					.setOAuthAccessToken(m_strUserAccessToken)
					.setOAuthAccessTokenSecret(m_strSecretToken)
					.setIncludeEmailEnabled(true);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			u = twitter.verifyCredentials();
		}catch(TwitterException te){
			LoggingTwitterException(te, -1, -1);
			return null;
		}catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		return u.getEmail();
	}

	public long getLastTweetId() {
		if(m_statusLastTweet==null) return -1;
		return m_statusLastTweet.getId();
	}


	static public String generateState(CContent content, ResourceBundleControl _TEX) {
		String strState;
		if (content.m_nCategoryId == 10 || content.m_nCategoryId == 11) {
			String s = _TEX.T(String.format("Category.C%d", content.m_nCategoryId));
			strState = s.substring(s.indexOf("</i>") + 4);
		} else {
			strState = "["+_TEX.T(String.format("Category.C%d", content.m_nCategoryId))+"] ";
		}

		String optionLabel = "";

		switch(content.m_nPublishId) {
		case Common.PUBLISH_ID_LOGIN:
			optionLabel += _TEX.T("UploadFilePc.Option.Publish.Login");
			break;
		case Common.PUBLISH_ID_FOLLOWER:
			optionLabel += _TEX.T("UploadFilePc.Option.Publish.Follower");
			break;
		case Common.PUBLISH_ID_T_FOLLOWER:
			optionLabel += _TEX.T("UploadFilePc.Option.Publish.T_Follower");
			break;
		case Common.PUBLISH_ID_T_FOLLOWEE:
			optionLabel += _TEX.T("UploadFilePc.Option.Publish.T_Followee");
			break;
		case Common.PUBLISH_ID_T_EACH:
			optionLabel += _TEX.T("UploadFilePc.Option.Publish.T_Each");
			break;
		case Common.PUBLISH_ID_T_LIST:
			optionLabel += _TEX.T("UploadFilePc.Option.Publish.T_List");
			break;
		case Common.PUBLISH_ID_T_RT:
			optionLabel += _TEX.T("UploadFilePc.Option.Publish.T_RT");
			break;
		case Common.PUBLISH_ID_ALL:
		default:
		}

		if (optionLabel.isEmpty()) {
			switch (content.m_nSafeFilter){
				case Common.SAFE_FILTER_R15:
					optionLabel = _TEX.T("UploadFilePc.Option.Publish.R15");
					break;
				case Common.SAFE_FILTER_R18:
				case Common.SAFE_FILTER_R18G:
				case Common.SAFE_FILTER_R18_PLUS:
					optionLabel = _TEX.T("UploadFilePc.Option.Publish.R18");
					break;
				default:
					optionLabel = content.passwordEnabled ? _TEX.T("UploadFilePc.Option.Publish.Pass.Title") : "";
			}
		}
		return strState + optionLabel;
	}

	static public String generateFileNum(CContent content, ResourceBundleControl _TEX) {
		String strFileNum = "";
		if(content.m_nEditorId==Common.EDITOR_TEXT ) {
			strFileNum = String.format("(%d"+_TEX.T("Common.Unit.Text")+")", content.m_strTextBody.length());
		} else {
			strFileNum = String.format("("+_TEX.T("UploadFileTweet.FileNum")+")", content.m_nFileNum);
		}
		return strFileNum;
	}

	static public String generateMetaTwitterTitle(CContent content, ResourceBundleControl _TEX) {
		return generateState(content, _TEX) +
				generateFileNum(content, _TEX) +
				String.format(_TEX.T("Tweet.Title"), content.m_cUser.m_strNickName);
	}

	static public String generateMetaTwitterDesc(CContent content, ResourceBundleControl _TEX) {
		return "";
	}

	static public String generateWithTweetMsg(CContent content, ResourceBundleControl _TEX) {
		String strFooter = String.format(" %s\nhttps://unrealizm.com/%d/%d.html",
				Common.CATEGORY_TW_HASHTAG[content.m_nCategoryId],
				content.m_nUserId,
				content.m_nContentId);

		int nMessageLength = CTweet.MAX_LENGTH - strFooter.length();
		String strDesc = content.m_strDescription;
		if (nMessageLength < strDesc.length()) {
			strDesc = strDesc.substring(0, nMessageLength-CTweet.ELLIPSE.length()) + CTweet.ELLIPSE;
		}

		return strDesc + strFooter;
	}

	static public String generateAfterTweetMsg(CContent content, ResourceBundleControl _TEX) {
		String strTwitterUrl="";
		try {
			final String strUrl = String.format(" %s %s\nhttps://unrealizm.com/%d/%d.html",
					Common.CATEGORY_TW_HASHTAG[content.m_nCategoryId],
					"#" + _TEX.T("Common.HashTag"),
					content.m_nUserId,
					content.m_nContentId);

			final String strFooter = "\n" + strUrl;

			int nMessageLength = CTweet.MAX_LENGTH - strFooter.length();

			String strDesc = content.m_strDescription;
			if (nMessageLength < strDesc.length()) {
				strDesc = strDesc.substring(0, nMessageLength-CTweet.ELLIPSE.length()) + CTweet.ELLIPSE;
			}

			strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
					URLEncoder.encode(strDesc, "UTF-8"),
					URLEncoder.encode(strUrl, "UTF-8"));
		} catch (Exception ignored) {
			;
		}
		return strTwitterUrl;
	}

	static public void updateTwitterCash(int userId) {
		Connection connection = null;
		PreparedStatement cState = null;
		String strSql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();

			strSql = "DELETE FROM twitter_friends WHERE user_id=?";
			cState = connection.prepareStatement(strSql);
			cState.setInt(1, userId);
			cState.executeUpdate();
			cState.close();cState=null;

			strSql = "DELETE FROM twitter_lists WHERE user_id=?";
			cState = connection.prepareStatement(strSql);
			cState.setInt(1, userId);
			cState.executeUpdate();
			cState.close();cState=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
			try{if(connection != null) connection.close();connection=null;} catch(Exception e) {;}
		}
	}

	public Date getCreatedAt() {
		if (!m_bIsTweetEnable) return null;
		User u = null;
		try{
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(false)
					.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
					.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
					.setOAuthAccessToken(m_strUserAccessToken)
					.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			u = twitter.showUser(m_lnTwitterUserId);
		}catch(TwitterException te){
			LoggingTwitterException(te, -1, -1);
			return null;
		}catch(Exception e) {
			e.printStackTrace();
			return null;
		}
		return u.getCreatedAt();
	}
}
