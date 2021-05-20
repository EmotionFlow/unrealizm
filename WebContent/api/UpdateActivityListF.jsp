<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
	UpdateActivityListC cResults = new UpdateActivityListC();
	cResults.getParam(request);
	boolean rtn = cResults.getResults(checkLogin);

	String toUrl = "";
	if (rtn) {
		if (cResults.infoType == Common.NOTIFICATION_TYPE_REACTION) {
			toUrl = String.format("/IllustViewAppV.jsp?ID=%d&TD=%d", cResults.userId, cResults.contentId);
		} else if (cResults.infoType == Common.NOTIFICATION_TYPE_REQUEST) {
			toUrl = String.format("/MyRequestListAppV.jsp?MENUID=%s&ST=%d", cResults.requestListMenuId, cResults.requestListSt);
		} else if (cResults.infoType == Common.NOTIFICATION_TYPE_GIFT) {
			toUrl = "";
		}
	}
%>
{"result": <%=rtn ? Common.API_OK : Common.API_NG%>, "to_url": "<%=toUrl%>", "error_code": <%=cResults.errorKind.getCode()%>}
