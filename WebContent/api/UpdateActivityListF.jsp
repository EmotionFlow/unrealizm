<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
	UpdateActivityListC cResults = new UpdateActivityListC();
	cResults.getParam(request);
	boolean rtn = cResults.getResults(checkLogin);

	String toUrl = "";
	if (rtn) {
		if (cResults.infoType == InfoList.InfoType.Emoji.getCode()
		 || cResults.infoType == InfoList.InfoType.EmojiReply.getCode()
		) {
			toUrl = String.format("/IllustViewAppV.jsp?ID=%d&TD=%d", cResults.contentUserId, cResults.contentId);
		} else if (cResults.infoType == InfoList.InfoType.Request.getCode()) {
			toUrl = String.format("/MyRequestListAppV.jsp?MENUID=%s&ST=%d", cResults.requestListMenuId, cResults.requestListSt);
		} else if (cResults.infoType == InfoList.InfoType.Gift.getCode()) {
			toUrl = "";
		} else if (cResults.infoType == InfoList.InfoType.RequestStarted.getCode()) {
			// requestIdにクリエイターのuserIdを格納している
			toUrl = "/RequestNewAppV.jsp?ID=" + cResults.requestId;
		} else if (cResults.infoType == InfoList.InfoType.WaveEmoji.getCode()
				|| cResults.infoType == InfoList.InfoType.WaveEmojiMessage.getCode()
				|| cResults.infoType == InfoList.InfoType.WaveEmojiMessageReply.getCode()
		) {
			toUrl = String.format("MyIllustListAppV.jsp?ID=%d", checkLogin.m_nUserId);
		}
	}
%>
{"result": <%=rtn ? Common.API_OK : Common.API_NG%>, "to_url": "<%=toUrl%>", "error_code": <%=cResults.errorKind.getCode()%>}
