<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@page import="jp.pipa.poipiku.util.CTweet"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
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
	case ShowAppendFileC.ERR_FOLLOWER:
		strHtml.append((checkLogin.m_bLogin)?_TEX.T("ShowAppendFileC.ERR_FOLLOWER"):_TEX.T("ShowAppendFileC.ERR_FOLLOWER.NeedLogin"));
		break;
	case ShowAppendFileC.ERR_T_FOLLOWER:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOWER"));
		break;
	case ShowAppendFileC.ERR_T_FOLLOW:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_FOLLOW"));
		break;
	case ShowAppendFileC.ERR_T_EACH:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_EACH"));
		break;
	case ShowAppendFileC.ERR_T_LIST:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_LIST"));
		break;
	case ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_RATE_LIMIT_EXCEEDED"));
		break;
	case ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_T_INVALID_OR_EXPIRED_TOKEN"));
		break;
	case ShowAppendFileC.ERR_NOT_FOUND:
	case ShowAppendFileC.ERR_HIDDEN :
	case ShowAppendFileC.ERR_UNKNOWN:
	default:
		strHtml.append(_TEX.T("ShowAppendFileC.ERR_UNKNOWN"));
		break;
	}
} else {
	String ILLUST_DETAIL = (cResults.m_nMode==CCnv.MODE_SP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";
	switch(cResults.m_cContent.m_nPublishId) {
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
		if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {
	// 2枚目の場所に本文を表示する
	nRtn=2;
	strHtml.append(String.format("<a class=\"IllustItemText\" style=\"max-height:none;\" href=\"%s?ID=%d&TD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId));
	strHtml.append(String.format("<span class=\"IllustItemThumbText\">%s</span>", Util.toStringHtml(cResults.m_cContent.m_strTextBody)));
	strHtml.append("</a>");
		} else {
	// 2枚目の場所に1枚目を表示する
	nRtn++;
	strHtml.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId));
	strHtml.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cResults.m_cContent.m_strFileName)));
	strHtml.append("</a>");
		}
		break;
	case Common.PUBLISH_ID_ALL:
	case Common.PUBLISH_ID_HIDDEN:
	default:
		if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {nRtn=1;}
		break;
	}
	// 以降の画像・文章を表示
	for(CContentAppend cContentAppend : cResults.m_cContent.m_vContentAppend) {
		if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {
	// 2枚目の場所に本文に表示する
	strHtml.append(String.format("<a class=\"IllustItemText\" style=\"max-height:none;\" href=\"%s?ID=%d&TD=%d&AD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId, cContentAppend.m_nAppendId));
	strHtml.append(String.format("<span class=\"IllustItemThumbText\">%s</span>", Util.toStringHtml(cResults.m_cContent.m_strTextBody)));
	strHtml.append("</a>");
		} else {
	strHtml.append(String.format("<a class=\"IllustItemThumb\" href=\"%s?ID=%d&TD=%d&AD=%d\">", ILLUST_DETAIL, cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId, cContentAppend.m_nAppendId));
	strHtml.append(String.format("<img class=\"IllustItemThumbImg\" src=\"%s_640.jpg\" />", Common.GetUrl(cContentAppend.m_strFileName)));
	strHtml.append("</a>");
		}
	}
}
%>{
"result_num" : <%=nRtn%>,
"html" : "<%=CEnc.E(strHtml.toString())%>",
"tw_friendship" : "<%=cResults.m_nTwFriendship%>"
}