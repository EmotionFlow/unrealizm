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

StringBuilder strHtml = new StringBuilder();
ShowAppendFileC cResults = new ShowAppendFileC();
cResults.getParam(request);
int nRtn = cResults.getResults(checkLogin, _TEX);

if (nRtn < ShowAppendFileC.OK) {
	strHtml.append(cResults.errorMessage);
} else {
	cResults.content.setThumb(); // isHideThumbImgをセットするために必要

	final String illustDetailUrl = (cResults.m_nSpMode==CCnv.SP_MODE_APP)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";
	if (!cResults.isRequestClient && cResults.content.m_nOpenId==Common.OPEN_ID_HIDDEN
			|| !cResults.content.isHideThumbImg
			|| cResults.content.publishAllNum == 1) {
		if (cResults.content.m_nEditorId==Common.EDITOR_TEXT) {
			nRtn=1;
		}
	} else {
		if(cResults.content.m_nEditorId==Common.EDITOR_TEXT) {
			// 2枚目の場所に本文を表示する
			nRtn=2;
			strHtml.append(String.format("<a class=\"IllustItemText\" %s href=\"%s?ID=%d&TD=%d\">",
					cResults.content.novelDirection==1 ? "" : "style=\"max-height:470px; overflow: scroll;\"",
					illustDetailUrl, cResults.content.m_nUserId, cResults.content.m_nContentId));
			strHtml.append(String.format("<span class=\"IllustItemThumbText %s\">%s</span>",
					cResults.content.novelDirection==1 ? "Vertical" : "",
					Util.replaceForGenEiFont(cResults.content.novelHtml)));
			strHtml.append("</a>");
		} else {
			// 2枚目の場所に1枚目を表示する
			nRtn++;
			cResults.content.setOrgImgThumb();
			CCnv.appendIllustItemThumb3(strHtml, cResults.content, CCnv.VIEW_DETAIL, null);
		}
	}

	// 以降の画像を表示
	for(CContentAppend contentAppend : cResults.content.m_vContentAppend) {
		CCnv.appendIllustItemThumb2(strHtml, cResults.content, contentAppend, CCnv.VIEW_DETAIL, null);
	}
}
%>{"result_num":<%=nRtn%>,"html":"<%=CEnc.E(strHtml.toString())%>","tw_friendship":"<%=cResults.m_nTwFriendship%>"}