package jp.pipa.poipiku.util;

import java.awt.image.BufferedImage;
import java.io.File;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.sql.DataSource;

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

public class CTweet {
	public boolean m_bIsTweetEnable = false;
	public String m_strUserAccessToken = "";
	public String m_strSecretToken = "";
	public int m_nUserId = -1;
	public long m_lnTwitterUserId = -1;
	public ResponseList<UserList> m_listOpenList = null;
	public static final int MAX_LENGTH = 140;
	public static final String ELLIPSE = "...";
	public static final int FRIENDSHIP_UNDEF = -1;		// 未定義
	public static final int FRIENDSHIP_NONE = 0;		// 無関係
	public static final int FRIENDSHIP_FOLLOWEE = 1;		// フォローしている
	public static final int FRIENDSHIP_FOLLOWER = 2;	// フォローされている
	public static final int FRIENDSHIP_EACH = 3;		// 相互フォロー

	public static final int OK = 1;
	public static final int ERR_NOT_FOUND = -404000;
	public static final int ERR_RATE_LIMIT_EXCEEDED = -429088;
	public static final int ERR_INVALID_OR_EXPIRED_TOKEN = -404089;
	public static final int ERR_USER_IS_OVER_DAILY_STATUS_UPDATE_LIMIT = -403185;
	public static final int ERR_TWEET_DISABLE = -999998;
	public static final int ERR_OTHER = -999999;
	public Status m_statusLastTweet = null;

	private void LoggingTwitterException(TwitterException te){
		String strCallFrom = "";
		StackTraceElement[] steArray = Thread.currentThread().getStackTrace();
		if (steArray.length <= 3) {
			strCallFrom =  "???";
		} else {
			StackTraceElement ste = steArray[2];
			strCallFrom = ste.getMethodName();
		}
		Log.d(String.format("TwitterException, %s, %d, %s, %d, %s", strCallFrom, te.getStatusCode() , m_strUserAccessToken, te.getErrorCode(), te.getMessage()));
	}

	private static int GetErrorCode(TwitterException te){
		int nErrCode = ERR_OTHER;
		int nTwErrCode = te.getErrorCode();
		if(nTwErrCode==89){
			nErrCode = ERR_INVALID_OR_EXPIRED_TOKEN;
		} else if(nTwErrCode==88) {
			nErrCode = ERR_RATE_LIMIT_EXCEEDED;
		} else if(nTwErrCode==185) {
			nErrCode = ERR_USER_IS_OVER_DAILY_STATUS_UPDATE_LIMIT;
		} else if(te.getStatusCode()==404){
			nErrCode = ERR_NOT_FOUND;
		}
		return nErrCode;
	}

	public boolean GetResults(int nUserId) {
		boolean bResult = true;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		m_nUserId = nUserId;
		String strUserId = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			strSql = "SELECT * FROM tbloauth WHERE flduserid=? AND fldproviderid=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			if(cResSet.next()){
				// Token格納
				m_strUserAccessToken = cResSet.getString("fldaccesstoken");
				m_strSecretToken = cResSet.getString("fldsecrettoken");
				strUserId = cResSet.getString("twitter_user_id");
				m_bIsTweetEnable = true;
			} else {
				m_bIsTweetEnable = false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		} finally {
			try {if(cResSet!=null)cResSet.close();}catch(Exception e){}
			try {if(cState!=null)cState.close();}catch(Exception e){}
			try {if(cConn!=null)cConn.close();}catch(Exception e){}
		}
		try {
			if(!strSql.isEmpty()) {
				m_lnTwitterUserId = Util.toLong(strUserId);
			}
		} catch (Exception e) {}
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
			LoggingTwitterException(te);
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
			LoggingTwitterException(te);
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
			LoggingTwitterException(te);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int Tweet(String strTweet, ArrayList<String> vFileList) {
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
			for(int index = 0; index<vFileList.size(); index++) {
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
				ImageUtil.deleteFile(strDstFileName);
			}

			StatusUpdate update = new StatusUpdate(strTweet);
			update.setMediaIds(vMediaList);
			m_statusLastTweet = twitter.updateStatus(update);
		} catch (TwitterException te) {
			te.printStackTrace();
			LoggingTwitterException(te);
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
			LoggingTwitterException(te);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	public int LookupFriendship(int nTargetUserId){
		int nResult = FRIENDSHIP_UNDEF;
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT twitter_user_id FROM tbloauth WHERE flduserid=? AND fldproviderid=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nTargetUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cResSet = cState.executeQuery();
			Long lnTargetUserId = -1L;
			if(cResSet.next()){
				lnTargetUserId = Long.parseLong(cResSet.getString("twitter_user_id"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if(lnTargetUserId==-1L) return ERR_OTHER;

			// DBに5分以内のフォローがあるか
			boolean bFollowing = checkDBFollowInfo(m_nUserId, nTargetUserId);
			// DBに5分以内の被フォローがあるか
			boolean bFollower = checkDBFollowInfo(nTargetUserId, m_nUserId);

			// 判定
			if(bFollowing && bFollower) return FRIENDSHIP_EACH;
			if(bFollowing) return FRIENDSHIP_FOLLOWEE;
			if(bFollower) return FRIENDSHIP_FOLLOWER;

			// 5分以内の情報DB内に無いだけの可能性があるのでDBをTwitterAPIを使って更新
			updateDBFollowInfoFromTwitter(m_nUserId);
			updateDBFollowInfoFromTwitter(nTargetUserId);

			// もう一度チェック
			// DBに5分以内のフォローがあるか
			bFollowing = checkDBFollowInfo(m_nUserId, nTargetUserId);
			// DBに5分以内の被フォローがあるか
			bFollower = checkDBFollowInfo(nTargetUserId, m_nUserId);

			// 判定
			if(bFollowing && bFollower) return FRIENDSHIP_EACH;
			if(bFollowing) return FRIENDSHIP_FOLLOWEE;
			if(bFollower) return FRIENDSHIP_FOLLOWER;

			// DBには最大30000フォローワーまでしか取得していないので、念の為ID間のFriend関係を確認
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			ResponseList<Friendship> lookupResults = twitter.lookupFriendships(lnTargetUserId);
			if(lookupResults.size() > 0){
				Friendship f = lookupResults.get(0);
				if(f.isFollowing() && f.isFollowedBy()){
					nResult = FRIENDSHIP_EACH;
				} else if(f.isFollowing() && !f.isFollowedBy()){
					nResult = FRIENDSHIP_FOLLOWEE;
				} else if(!f.isFollowing() && f.isFollowedBy()){
					nResult = FRIENDSHIP_FOLLOWER;
				} else {
					nResult = FRIENDSHIP_NONE;
				}
			}
		} catch (TwitterException te) {
			LoggingTwitterException(te);
			nResult = GetErrorCode(te);
		} catch (Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		} finally {
			try {if(cResSet!=null)cResSet.close();}catch(Exception e){}
			try {if(cState!=null)cState.close();}catch(Exception e){}
			try {if(cConn!=null)cConn.close();}catch(Exception e){}
		}
		return nResult;
	}

	// twitter_followsに5分以内のフォローがあるか
	private boolean checkDBFollowInfo(int userId, int targetUserId) {
		boolean bFollow = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "select * FROM twitter_follows WHERE user_id=? AND follow_user_id=? AND last_update_date<CURRENT_TIMESTAMP-interval'5 minutes'";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, targetUserId);
			cState.setInt(2, userId);
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
		// userIdがフォローしているIDをTwitterから取得
		ArrayList<Long> id_list = new ArrayList<>(); // エラーが起きてもそれまで取れたものがあれば続行
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
				IDs ids = twitter.getFollowersIDs(cursor);
				for (long id : ids.getIDs()) {
					id_list.add(id);
				}
				cursor = ids.getNextCursor();
			} while(cursor>=0 && cursor<30000);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if(id_list.isEmpty()) return;

		// 取れたものを追加
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			// 古いものを削除
			strSql = "DELETE FROM twitter_follows WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, userId);
			cState.executeUpdate();
			cState.close();cState=null;
			// 新しく追加
			strSql = "INSERT INTO twitter_follows(user_id, twitter_user_id, twitter_follows_user_id) VALUES (?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			for(long id: id_list) {
				cState.setInt(1, userId);
				cState.setLong(2, m_lnTwitterUserId);
				cState.setLong(3, id);
				cState.executeUpdate();
				cState.close();cState=null;
			}
			// ポイピク上のuser_id紐付け
			strSql = "UPDATE twitter_follows SET follow_user_id=fldUserId FROM tbloauth "
					+ "WHERE twitter_follows.twitter_user_id=cast(tbloauth.twitter_user_id as bigint) AND user_id=?";
			cState.setInt(1, userId);
			cState.executeUpdate();
			cState.close();cState=null;
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {if(cResSet!=null)cResSet.close();}catch(Exception e){}
			try {if(cState!=null)cState.close();}catch(Exception e){}
			try {if(cConn!=null)cConn.close();}catch(Exception e){}
		}
	}

	public int LookupListMember(CContent cContent){
		if (!m_bIsTweetEnable) return ERR_TWEET_DISABLE;
		if (cContent.m_strListId.isEmpty()) return ERR_OTHER;

		int nResult;
		try{
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			/*User u = */twitter.showUserListMembership(Long.parseLong(cContent.m_strListId), m_lnTwitterUserId);
			nResult = 1;
		}catch(TwitterException te){
			LoggingTwitterException(te);
			nResult = GetErrorCode(te);
		}catch(Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
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
			LoggingTwitterException(te);
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


	static public String generateState(CContent cContent, ResourceBundleControl _TEX) {
		String strState = "["+_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))+"] ";
		switch(cContent.m_nPublishId) {
		case Common.PUBLISH_ID_PASS:
			strState += _TEX.T("UploadFilePc.Option.Publish.Pass.Title");
			break;
		case Common.PUBLISH_ID_LOGIN:
			strState += _TEX.T("UploadFilePc.Option.Publish.Login");
			break;
		case Common.PUBLISH_ID_FOLLOWER:
			strState += _TEX.T("UploadFilePc.Option.Publish.Follower");
			break;
		case Common.PUBLISH_ID_T_FOLLOWER:
			strState += _TEX.T("UploadFilePc.Option.Publish.T_Follower");
			break;
		case Common.PUBLISH_ID_T_FOLLOWEE:
			strState += _TEX.T("UploadFilePc.Option.Publish.T_Followee");
			break;
		case Common.PUBLISH_ID_T_EACH:
			strState += _TEX.T("UploadFilePc.Option.Publish.T_Each");
			break;
		case Common.PUBLISH_ID_T_LIST:
			strState += _TEX.T("UploadFilePc.Option.Publish.T_List");
			break;
		case Common.PUBLISH_ID_HIDDEN:
			strState += _TEX.T("UploadFilePc.Option.Publish.Hidden");
			break;
		case Common.PUBLISH_ID_ALL:
		case Common.PUBLISH_ID_R15:
		case Common.PUBLISH_ID_R18:
		case Common.PUBLISH_ID_R18G:
		default:
			break;
		}
		return strState;
	}

	static public String generateFileNum(CContent cContent, ResourceBundleControl _TEX) {
		String strFileNum = "";
		if(cContent.m_nEditorId==Common.EDITOR_TEXT ) {
			strFileNum = "(" + String.format(_TEX.T("Common.Unit.Text"), cContent.m_strTextBody.length()) + ")";
		} else {
			strFileNum = "(" + String.format(_TEX.T("UploadFileTweet.FileNum"), cContent.m_nFileNum) + ")";
		}
		return strFileNum;
	}

	static public String generateMetaTwitterTitle(CContent cContent, ResourceBundleControl _TEX) {
		return generateState(cContent, _TEX) +  generateFileNum(cContent, _TEX) + " - " + String.format(_TEX.T("Tweet.Title"), cContent.m_cUser.m_strNickName);
	}

	static public String generateMetaTwitterDesc(CContent cContent, ResourceBundleControl _TEX) {
		return "";
	}

	static public String generateWithTweetMsg(CContent cContent, ResourceBundleControl _TEX) {
		String strFooter = String.format("\nhttps://poipiku.com/%d/%d.html",
				cContent.m_nUserId,
				cContent.m_nContentId);

		int nMessageLength = CTweet.MAX_LENGTH - strFooter.length();
		String strDesc = cContent.m_strDescription;
		if (nMessageLength < strDesc.length()) {
			strDesc = strDesc.substring(0, nMessageLength-CTweet.ELLIPSE.length()) + CTweet.ELLIPSE;
		}

		return strDesc + strFooter;
	}

	static public String generateAfterTweerMsg(CContent cContent, ResourceBundleControl _TEX) {
		String strTwitterUrl="";
		try {
			String strUrl = String.format("https://poipiku.com/%d/%d.html",
					cContent.m_nUserId,
					cContent.m_nContentId);

			String strFooter = "\n" + strUrl;

			int nMessageLength = CTweet.MAX_LENGTH - strFooter.length();

			String strDesc = cContent.m_strDescription;
			if (nMessageLength < strDesc.length()) {
				strDesc = strDesc.substring(0, nMessageLength-CTweet.ELLIPSE.length()) + CTweet.ELLIPSE;
			}

			strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
					URLEncoder.encode(strDesc, "UTF-8"),
					URLEncoder.encode(strUrl, "UTF-8"));
		} catch (Exception e) {
			;
		}
		return strTwitterUrl;
	}
}
