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
import java.util.List;
import java.util.Random;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.*;
import twitter4j.Friendship;
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
	public long m_lnTwitterUserId = -1;
	public ResponseList<UserList> m_listOpenList = null;
	public static final int MAX_LENGTH = 140;
	public static final String ELLIPSE = "...";
	public static final int FRIENDSHIP_UNDEF = -1;		// 未定義
	public static final int FRIENDSHIP_NONE = 0;		// 無関係
	public static final int FRIENDSHIP_FRIEND = 1;		// フォローしている
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
			if(cResSet.next()){
				ConfigurationBuilder cb = new ConfigurationBuilder();
				cb.setDebugEnabled(true)
					.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
					.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
					.setOAuthAccessToken(m_strUserAccessToken)
					.setOAuthAccessTokenSecret(m_strSecretToken);
				TwitterFactory tf = new TwitterFactory(cb.build());
				Twitter twitter = tf.getInstance();

				// 関係をlookup
				long tgtIds[] = {Long.parseLong(cResSet.getString("twitter_user_id"))};
				ResponseList<Friendship> lookupResults = twitter.lookupFriendships(tgtIds);
				if(lookupResults.size() > 0){
					Friendship f = lookupResults.get(0);
					if(f.isFollowing() && f.isFollowedBy()){
						nResult = FRIENDSHIP_EACH;
					} else if(f.isFollowing() && !f.isFollowedBy()){
						nResult = FRIENDSHIP_FRIEND;
					} else if(!f.isFollowing() && f.isFollowedBy()){
						nResult = FRIENDSHIP_FOLLOWER;
					} else {
						nResult = FRIENDSHIP_NONE;
					}
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
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

	static private int getRnd(){
		Random rnd = new Random();
		return rnd.nextInt(1000) + 10000;
	}

	static public String generateIllustMsgFull(CContent cContent, ResourceBundleControl _TEX) {
		String strNickName = "";
		if(!cContent.m_cUser.m_strNickName.isEmpty()) {
			strNickName = String.format(_TEX.T("Tweet.Title"), cContent.m_cUser.m_strNickName);
		}

		String strFooter = String.format("%s\nhttps://poipiku.com/%d/%d.html?%d",
				strNickName,
				cContent.m_nUserId,
				cContent.m_nContentId,
				getRnd());
		return generateIllustMsg(cContent, _TEX) + strFooter;
	}

	static public String generateIllustMsgUrl(CContent cContent, ResourceBundleControl _TEX) {
		String strTwitterUrl="";
		try {
			String strNickName = "";
			if(!cContent.m_cUser.m_strNickName.isEmpty()) {
				strNickName = String.format(_TEX.T("Tweet.Title"), cContent.m_cUser.m_strNickName);
			}
			strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
					URLEncoder.encode(generateIllustMsg(cContent, _TEX)+strNickName+"\n", "UTF-8"),
					URLEncoder.encode("https://poipiku.com/"+cContent.m_nUserId+"/"+cContent.m_nContentId+".html?"+getRnd(), "UTF-8"));
		} catch (Exception e) {
			;
		}
		return strTwitterUrl;
	}

	static public String generateIllustMsg(CContent cContent, ResourceBundleControl _TEX) {
		return String.format("[%s] ", _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))) + generateIllustMsgBase(cContent, _TEX);
	}

	static public String generateIllustMsgBase(CContent cContent, ResourceBundleControl _TEX) {
		String strHeader = String.format("[%s] ", _TEX.T(String.format("Category.C%d", cContent.m_nCategoryId)));
		String strNickName = "";
		if(!cContent.m_cUser.m_strNickName.isEmpty()) {
			strNickName = String.format(_TEX.T("Tweet.Title"), cContent.m_cUser.m_strNickName);
		}
		String strFooter = String.format("%s\nhttps://poipiku.com/%d/%d.html?%d",
				strNickName,
				cContent.m_nUserId,
				cContent.m_nContentId,
				getRnd());
		List<String> arrAppendex = new ArrayList<String>();
		if(cContent.m_nFileWidth>0 && cContent.m_nFileHeight>0) {
			//arrAppendex.add(String.format(_TEX.T("UploadFileTweet.OriginalSize"), cContent.m_nFileWidth, cContent.m_nFileHeight));
		}
		if(cContent.m_nFileNum>1) {
			arrAppendex.add(String.format(_TEX.T("UploadFileTweet.FileNum"), cContent.m_nFileNum));
		}
		String strAppendex = "";
		if(arrAppendex.size()>0) {
			strAppendex = "(" + String.join(" ", arrAppendex) + ")";
		}
		int nMessageLength = CTweet.MAX_LENGTH - strHeader.length() - strAppendex.length() - strFooter.length();
		StringBuffer bufMsg = new StringBuffer();
		if (nMessageLength < cContent.m_strDescription.length()) {
			bufMsg.append(cContent.m_strDescription.substring(0, nMessageLength-CTweet.ELLIPSE.length()));
			bufMsg.append(CTweet.ELLIPSE);
		} else {
			bufMsg.append(cContent.m_strDescription);
		}
		bufMsg.append(strAppendex);
		return bufMsg.toString();
	}
}
