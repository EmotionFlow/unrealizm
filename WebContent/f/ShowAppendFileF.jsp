<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	static int appendIllustItem(StringBuilder sb, String detailVUrl, CContent content, int nRtn) {
		if(content.m_nEditorId==Common.EDITOR_TEXT) {
			// 2枚目の場所に本文を表示する
			nRtn=2;
			sb.append(String.format("<a class=\"IllustItemText\" %s href=\"%s?ID=%d&TD=%d\">",
					content.novelDirection==1 ? "" : "style=\"max-height:470px; overflow: scroll;\"",
					detailVUrl, content.m_nUserId, content.m_nContentId));
			sb.append(String.format("<span class=\"IllustItemThumbText %s\">%s</span>",
					content.novelDirection==1 ? "Vertical" : "",
					Util.replaceForGenEiFont(content.novelHtml)));
			sb.append("</a>");
		} else {
			// 2枚目の場所に1枚目を表示する
			nRtn++;
			content.setOrgImgThumb();
			CCnv.appendIllustItemThumb2(sb, content, null, CCnv.VIEW_DETAIL, null);
		}
		return nRtn;
	}
%>
<%
if (Util.isBot(request)) return;

final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("unrealizm.com")) {
	Log.d("ShowIllustDetailFへの不正アクセス(referer不一致):" + referer);
	return;
}

CheckLogin checkLogin = new CheckLogin(request, response);

StringBuilder strHtml = new StringBuilder();
ShowAppendFileC results = new ShowAppendFileC();
results.getParam(request);
int nRtn = results.getResults(checkLogin, _TEX);

if (nRtn < ShowAppendFileC.OK) {
	strHtml.append(results.errorMessage);
} else {
	results.content.setThumb(); // isHideThumbImgをセットするために必要

	final String illustDetailUrl = (results.m_nSpMode==CCnv.SP_MODE_APP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";
	if (!results.isRequestClient && results.content.m_nOpenId==Common.OPEN_ID_HIDDEN
			|| !results.content.isHideThumbImg
			|| results.content.publishAllNum == 1) {

		if (results.isOwner
				&& results.content.m_nOpenId==Common.OPEN_ID_HIDDEN
				&& (results.content.m_nPublishId != Common.PUBLISH_ID_ALL
					||  results.content.m_nSafeFilter != Common.SAFE_FILTER_ALL
					||  results.content.isPasswordEnabled())
		) {
			nRtn = appendIllustItem(strHtml, illustDetailUrl, results.content, nRtn);
		}

		if (results.content.m_nEditorId==Common.EDITOR_TEXT) {
			nRtn=1;
		}
	} else {
		nRtn = appendIllustItem(strHtml, illustDetailUrl, results.content, nRtn);
	}

	// 以降の画像を表示
	for(CContentAppend contentAppend : results.content.m_vContentAppend) {
		CCnv.appendIllustItemThumb2(strHtml, results.content, contentAppend, CCnv.VIEW_DETAIL, null);
	}
}
%>{"result_num":<%=nRtn%>,"html":"<%=CEnc.E(strHtml.toString())%>","tw_friendship":"<%=results.m_nTwFriendship%>"}