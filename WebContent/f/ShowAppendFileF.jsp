<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
if (Util.isBot(request)) return;

final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("poipiku.com")) {
	Log.d("ShowIllustDetailFへの不正アクセス(referer不一致):" + referer);
	return;
}

CheckLogin checkLogin = new CheckLogin(request, response);
int nRtn = 0;
StringBuilder strHtml = new StringBuilder();
ShowAppendFileC cResults = new ShowAppendFileC();
cResults.getParam(request);
nRtn = cResults.getResults(checkLogin);

if(nRtn<ShowAppendFileC.OK) {
	switch(nRtn) {
	case ShowAppendFileC.ERR_PASS:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_PASS"));
		break;
	case ShowAppendFileC.ERR_LOGIN:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_LOGIN"));
		break;
	case ShowAppendFileC.ERR_T_UNLINKED:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_UNLINKED"));
		break;
	case ShowAppendFileC.ERR_FOLLOWER:
		if(checkLogin.m_bLogin) {
			strHtml.append(_TEX.T("ShowAppendFileC.ERR_FOLLOWER"));
		} else {
			strHtml.append(_TEX.T("ShowAppendFileC.SigninPlease"));
		}
		break;
	case ShowAppendFileC.ERR_T_FOLLOWER:
		if(checkLogin.m_bLogin) {
			strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOWER"));
		} else {
			strHtml.append(_TEX.T("ShowAppendFileC.SigninPlease"));
		}
		break;
	case ShowAppendFileC.ERR_T_FOLLOW:
		if(checkLogin.m_bLogin) {
			strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOW"));
		} else {
			strHtml.append(_TEX.T("ShowAppendFileC.SigninPlease"));
		}
		break;
	case ShowAppendFileC.ERR_T_EACH:
		if(checkLogin.m_bLogin) {
			strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_EACH"));
		} else {
			strHtml.append(_TEX.T("ShowAppendFileC.SigninPlease"));
		}
		break;
	case ShowAppendFileC.ERR_T_LIST:
		if(checkLogin.m_bLogin) {
			strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_LIST"));
		} else {
			strHtml.append(_TEX.T("ShowAppendFileC.SigninPlease"));
		}
		break;
	case ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED"));
		break;
	case ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN"));
		break;
	case ShowAppendFileC.ERR_T_TARGET_ACCOUNT_NOT_FOUND:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_TARGET_ACCOUNT_NOT_FOUND"));
		break;
	case ShowAppendFileC.ERR_T_NEED_RETWEET:
		strHtml.append("need retweet");
		break;
	case ShowAppendFileC.ERR_NOT_FOUND:
	case ShowAppendFileC.ERR_HIDDEN :
	case ShowAppendFileC.ERR_UNKNOWN:
	default:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_UNKNOWN"));
		;
	}

	switch(nRtn) {
		case ShowAppendFileC.ERR_T_FOLLOWER:
		case ShowAppendFileC.ERR_T_FOLLOW:
		case ShowAppendFileC.ERR_T_EACH:
		case ShowAppendFileC.ERR_T_LIST:
			strHtml.append(
					String.format(
							_TEX.T("ShowAppendFileC.ERR_T_LINKED_ACCOUNT"), cResults.m_strMyTwitterScreenName
					)
			);
			break;
		default:
			;
	}

} else {
	final String illustDetailUrl = (cResults.m_nSpMode==CCnv.SP_MODE_APP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";
	final int publishId = cResults.m_cContent.m_nPublishId;
	if (cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT && (cResults.m_cContent.m_nOpenId==Common.OPEN_ID_HIDDEN || !cResults.m_cContent.isHideThumbImg || cResults.m_cContent.publishAllNum == 1)) {
		nRtn=1;
	} else {
		if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {
			// 2枚目の場所に本文を表示する
			nRtn=2;
			strHtml.append(String.format("<a class=\"IllustItemText\" %s href=\"%s?ID=%d&TD=%d\">",
					cResults.m_cContent.novelDirection==1 ? "" : "style=\"max-height:470px; overflow: scroll;\"",
					illustDetailUrl, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId));
			strHtml.append(String.format("<span class=\"IllustItemThumbText %s\">%s</span>",
					cResults.m_cContent.novelDirection==1 ? "Vertical" : "",
					Util.replaceForGenEiFont(cResults.m_cContent.novelHtml)));
			strHtml.append("</a>");
		} else {
			// 2枚目の場所に1枚目を表示する
			nRtn++;
			CCnv.appendIllustItemThumb(strHtml, cResults.m_cContent, CCnv.VIEW_DETAIL, null, Common.GetUrl(cResults.m_cContent.m_strFileName));
		}
	}

	// 以降の画像を表示
	for(CContentAppend contentAppend : cResults.m_cContent.m_vContentAppend) {
		CCnv.appendIllustItemThumb(strHtml, cResults.m_cContent, contentAppend, CCnv.VIEW_DETAIL, null, Common.GetUrl(contentAppend.m_strFileName));
	}
}
%>{"result_num":<%=nRtn%>,"html":"<%=CEnc.E(strHtml.toString())%>","tw_friendship":"<%=cResults.m_nTwFriendship%>"}