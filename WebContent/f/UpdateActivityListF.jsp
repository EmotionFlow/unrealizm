<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
	UpdateActivityListC results = new UpdateActivityListC();
	results.getParam(request);
	boolean rtn = results.getResults(checkLogin);

	String toUrl = "";
	if (rtn) {
		if (results.infoType == InfoList.InfoType.Emoji.getCode()
		 || results.infoType == InfoList.InfoType.EmojiReply.getCode()
		) {
			toUrl = String.format("/%d/%d.html", results.contentUserId, results.contentId);
		} else if (results.infoType == InfoList.InfoType.Request.getCode()) {
			toUrl = String.format("/MyRequestListPcV.jsp?MENUID=%s&ST=%d", results.requestListMenuId, results.requestListSt);
		} else if (results.infoType == InfoList.InfoType.Gift.getCode()) {
			toUrl = "";
		} else if (results.infoType == InfoList.InfoType.RequestStarted.getCode()) {
			// requestIdにクリエイターのuserIdを格納している
			toUrl = "/RequestNewPcV.jsp?ID=" + results.requestId;
		} else if (results.infoType == InfoList.InfoType.WaveEmoji.getCode()
				|| results.infoType == InfoList.InfoType.WaveEmojiMessage.getCode()
				|| results.infoType == InfoList.InfoType.WaveEmojiMessageReply.getCode()
		) {
			toUrl = String.format("MyIllustListPcV.jsp?ID=%d", checkLogin.m_nUserId);
		}
	}
%>
{"result": <%=rtn ? Common.API_OK : Common.API_NG%>, "to_url": "<%=toUrl%>", "error_code": <%=results.errorKind.getCode()%>}
