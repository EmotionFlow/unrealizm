package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import static jp.pipa.poipiku.util.ContentAccessVerificationUtil.*;

public final class ShowAppendFileC {
	public static final int OK = 0;
	public static final int ERR_NOT_FOUND = -1;
	public static final int ERR_PASS = -2;
	public static final int ERR_LOGIN = -3;
	public static final int ERR_FOLLOWER = -4;
	public static final int ERR_T_FOLLOWER = -5;
	public static final int ERR_T_FOLLOW = -6;
	public static final int ERR_T_EACH = -7;
	public static final int ERR_T_LIST = -8;
	public static final int ERR_T_NEED_RETWEET = -20;
	public static final int ERR_T_RATE_LIMIT_EXCEEDED = -429088;
	public static final int ERR_T_INVALID_OR_EXPIRED_TOKEN = -404089;
	public static final int ERR_T_TARGET_ACCOUNT_NOT_FOUND = -98;
	public static final int ERR_T_UNLINKED = -10;
	public static final int ERR_HIDDEN = -9;
	public static final int ERR_R18_PLUS = -11;
	public static final int ERR_UNKNOWN = -99;

	public int contentUserId = -1;
	public int contentId = -1;
	public String m_strPassword = "";
	public int m_nSpMode = 0;
	public int m_nTwFriendship = CTweet.FRIENDSHIP_UNDEF;
	public String m_strMyTwitterScreenName = "";

	public void getParam(HttpServletRequest request) {
		try {
			contentUserId = Util.toInt(request.getParameter("UID"));
			contentId = Util.toInt(request.getParameter("IID"));
			m_strPassword = request.getParameter("PAS");
			m_nSpMode = Util.toInt(request.getParameter("MD"));
			m_nTwFriendship = Util.toInt(request.getParameter("TWF"));
			request.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			contentId = -1;
		}
	}


	public CContent content = null;
	public String errorMessage = "";
	public boolean isRequestClient = false;
	public boolean isOwner = false;


	public int verify(CheckLogin checkLogin) {
		content = null;
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(
				     "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?"
		     )
		) {
			statement.setInt(1, contentUserId);
			statement.setInt(2, contentId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				content = new CContent(resultSet);
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}
		if(content == null) return ERR_NOT_FOUND;

		isRequestClient = verifyRequestClient(content, checkLogin);
		isOwner = content.m_nUserId == checkLogin.m_nUserId;

		if (!isRequestClient && content.passwordEnabled) {
			if (m_strPassword.isEmpty() || !verifyPassword(content, m_strPassword)) {
				return ERR_PASS;
			}
		}

		if (!isOwner && !isRequestClient) {
			if (content.m_nPublishId == Common.PUBLISH_ID_LOGIN && !verifyPoipassLogin(checkLogin)) return ERR_LOGIN;

			if (content.m_nSafeFilter == Common.SAFE_FILTER_R18_PLUS && !verifyR18Plus(checkLogin)) return ERR_R18_PLUS;
			if (content.m_nPublishId == Common.PUBLISH_ID_FOLLOWER && !verifyPoipassFollower(content, checkLogin)) return ERR_FOLLOWER;
			if (!content.nowAvailable()) return ERR_HIDDEN;
			if (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER
					|| content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE
					|| content.m_nPublishId==Common.PUBLISH_ID_T_EACH) {
				VerifyTwitterResult verifyTwitterResult = verifyTwitterFollowing(content, checkLogin, m_nTwFriendship);
				m_strMyTwitterScreenName = verifyTwitterResult.myTwitterScreenName;
				if (verifyTwitterResult.code < 0) return verifyTwitterResult.code;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_LIST) {
				VerifyTwitterResult verifyTwitterResult  = verifyTwitterOpenList(content, checkLogin);
				m_strMyTwitterScreenName = verifyTwitterResult.myTwitterScreenName;
				if (verifyTwitterResult.code < 0) return verifyTwitterResult.code;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_RT && !verifyTwitterRetweet(content, checkLogin)) return ERR_T_NEED_RETWEET;
		}

		int nRtn = 0;
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(
				     "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000"
		     )
		) {
			statement.setInt(1, contentId);
			ResultSet resultSet = statement.executeQuery();
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				content.m_vContentAppend.add(new CContentAppend(resultSet));
			}
			nRtn = content.m_vContentAppend.size();
		} catch (SQLException throwables) {
			throwables.printStackTrace();
			nRtn = ERR_UNKNOWN;
		}
		return nRtn;
	}


	public int getResults(CheckLogin checkLogin, ResourceBundleControl _TEX) {
		final int nRtn = verify(checkLogin);

		// set error message
		StringBuilder sb = new StringBuilder();
		switch(nRtn) {
			case ShowAppendFileC.ERR_PASS:
				sb.append(_TEX.T("ShowAppendFileC.ERR_PASS"));
				break;
			case ShowAppendFileC.ERR_LOGIN:
				sb.append(_TEX.T("ShowAppendFileC.ERR_LOGIN"));
				break;
			case ShowAppendFileC.ERR_T_UNLINKED:
				sb.append(_TEX.T("ShowAppendFileC.ERR_T_UNLINKED"));
				break;
			case ShowAppendFileC.ERR_FOLLOWER:
				if(checkLogin.m_bLogin) {
					sb.append(_TEX.T("ShowAppendFileC.ERR_FOLLOWER"));
				} else {
					sb.append(_TEX.T("ShowAppendFileC.SigninPlease"));
				}
				break;
			case ShowAppendFileC.ERR_T_FOLLOWER:
				if(checkLogin.m_bLogin) {
					sb.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOWER"));
				} else {
					sb.append(_TEX.T("ShowAppendFileC.SigninPlease"));
				}
				break;
			case ShowAppendFileC.ERR_T_FOLLOW:
				if(checkLogin.m_bLogin) {
					sb.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOW"));
				} else {
					sb.append(_TEX.T("ShowAppendFileC.SigninPlease"));
				}
				break;
			case ShowAppendFileC.ERR_T_EACH:
				if(checkLogin.m_bLogin) {
					sb.append(_TEX.T("ShowAppendFileC.ERR_T_EACH"));
				} else {
					sb.append(_TEX.T("ShowAppendFileC.SigninPlease"));
				}
				break;
			case ShowAppendFileC.ERR_T_LIST:
				if(checkLogin.m_bLogin) {
					sb.append(_TEX.T("ShowAppendFileC.ERR_T_LIST"));
				} else {
					sb.append(_TEX.T("ShowAppendFileC.SigninPlease"));
				}
				break;
			case ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED:
				sb.append(_TEX.T("ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED"));
				break;
			case ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN:
				sb.append(_TEX.T("ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN"));
				break;
			case ShowAppendFileC.ERR_T_TARGET_ACCOUNT_NOT_FOUND:
				sb.append(_TEX.T("ShowAppendFileC.ERR_T_TARGET_ACCOUNT_NOT_FOUND"));
				break;
			case ShowAppendFileC.ERR_T_NEED_RETWEET:
				sb.append("need retweet");
				break;
			case ShowAppendFileC.ERR_R18_PLUS:
				sb.append("""
					%s<br><br><a href="javascript:void(0)" onclick="DispR18PlusDlg()" style="text-decoration: underline;"><i class="fas fa-info-circle"></i> %s</a>
					""".formatted(_TEX.T("ShowAppendFileC.ERR_R18_PLUS"), _TEX.T("ShowAppendFileC.ERR_R18_PLUS.ShowDetail")));
				break;
			case ShowAppendFileC.ERR_NOT_FOUND:
			case ShowAppendFileC.ERR_HIDDEN :
			case ShowAppendFileC.ERR_UNKNOWN:
			default:
				sb.append(_TEX.T("ShowAppendFileC.ERR_UNKNOWN"));
		}

		switch(nRtn) {
			case ShowAppendFileC.ERR_T_FOLLOWER:
			case ShowAppendFileC.ERR_T_FOLLOW:
			case ShowAppendFileC.ERR_T_EACH:
			case ShowAppendFileC.ERR_T_LIST:
				sb.append(
						String.format(
								_TEX.T("ShowAppendFileC.ERR_T_LINKED_ACCOUNT"), m_strMyTwitterScreenName
						)
				);
				break;
			default:
				;
		}

		errorMessage = sb.toString();
		return nRtn;
	}
}
