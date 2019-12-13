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
	public static final int ERR_RATE_LIMIT_EXCEEDED = -10088;
	public static final int ERR_TWEET_DISABLE = -10000;
	public static final int ERR_OTHER = -99999;

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

	public boolean GetMyOpenLists() {
		if (!m_bIsTweetEnable) return false;
		boolean bResult = true;
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
			for(UserList l : m_listOpenList){
				Log.d(String.format("%s, %d, %b", l.getName(), l.getId(), l.isPublic()));
			}
			m_listOpenList.removeIf(a -> !a.isPublic());
			for(UserList l : m_listOpenList){
				Log.d(String.format("%s, %d, %b", l.getName(), l.getId(), l.isPublic()));
			}
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		}
		return bResult;
	}

	public boolean Tweet(String strTweet) {
		if (!m_bIsTweetEnable) return false;
		boolean bResult = true;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			Status status = twitter.updateStatus(strTweet);
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		}
		return bResult;
	}

	public boolean Tweet(String strTweet, String strFileName) {
		if (!m_bIsTweetEnable) return false;

		boolean bResult = true;
		try {
			ConfigurationBuilder cb = new ConfigurationBuilder();
			cb.setDebugEnabled(true)
				.setOAuthConsumerKey(Common.TWITTER_CONSUMER_KEY)
				.setOAuthConsumerSecret(Common.TWITTER_CONSUMER_SECRET)
				.setOAuthAccessToken(m_strUserAccessToken)
				.setOAuthAccessTokenSecret(m_strSecretToken);
			TwitterFactory tf = new TwitterFactory(cb.build());
			Twitter twitter = tf.getInstance();
			Status status = twitter.updateStatus(new StatusUpdate(strTweet).media(new File(strFileName)));
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		}
		return bResult;
	}

	public boolean Tweet(String strTweet, ArrayList<String> vFileList) {
		if(!m_bIsTweetEnable) return false;
		if(vFileList.size()<=0) return false;

		boolean bResult = true;
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
			Status status = twitter.updateStatus(update);
		} catch (Exception e) {
			e.printStackTrace();
			bResult = false;
		}
		return bResult;
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
			System.out.println(String.format("ua: %s, st: %s", m_strUserAccessToken, m_strSecretToken));
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
			if(te.getErrorCode() == 88){
				nResult = ERR_RATE_LIMIT_EXCEEDED;
			} else {
				te.printStackTrace();
				nResult = ERR_OTHER;
			}
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
            User u = twitter.showUserListMembership(Long.parseLong(cContent.m_strListId), m_lnTwitterUserId);
			System.out.println(String.format("%s", u.getId()));
			nResult = 1;
        }catch(TwitterException te){
            if(te.getStatusCode()==404){
                nResult = 0; // リストが消されちゃった場合もここにくる。
			} else if(te.getErrorCode() == 88){
				nResult = ERR_RATE_LIMIT_EXCEEDED;
			} else {
				te.printStackTrace();
				nResult = ERR_OTHER;
			}
		}catch(Exception e) {
			e.printStackTrace();
			nResult = ERR_OTHER;
		}
		return nResult;
	}

	static public String generateIllustMsgFull(CContent cContent, ResourceBundleControl _TEX) {
		String strNickName = "";
		if(!cContent.m_cUser.m_strNickName.isEmpty()) {
			strNickName = String.format(_TEX.T("Tweet.Title"), cContent.m_cUser.m_strNickName);
		}
		String strFooter = String.format("%s\nhttps://poipiku.com/%d/%d.html",
				strNickName,
				cContent.m_nUserId,
				cContent.m_nContentId);
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
					URLEncoder.encode("https://poipiku.com/"+cContent.m_nUserId+"/"+cContent.m_nContentId+".html", "UTF-8"));
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
		String strFooter = String.format("%s\nhttps://poipiku.com/%d/%d.html",
				strNickName,
				cContent.m_nUserId,
				cContent.m_nContentId);
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
