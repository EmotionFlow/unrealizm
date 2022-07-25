<%@page language="java" contentType="text/html; charset=UTF-8"%>
<%@include file="/inner/Common.jsp"%>

<%
request.setCharacterEncoding("UTF-8");
CheckLogin checkLogin = new CheckLogin(request, response);

//login check
if(!checkLogin.m_bLogin || checkLogin.m_nUserId < 1){
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

RegistTwitterTokenC c = new RegistTwitterTokenC();
c.getResult(checkLogin, request, session, _TEX);

String strNextContextPath = "";
if(c.result==RegistTwitterTokenC.Result.OK){
	strNextContextPath = "/MyEditSettingPcV.jsp?MENUID=TWITTER";
}else if(c.result==RegistTwitterTokenC.Result.LINKED_OTHER_POIPIKU_ID){
	strNextContextPath = "/MyEditSettingPcV.jsp?MENUID=TWITTER&ERR=TW_LINKED";
}else{
	strNextContextPath = "/MyEditSettingPcV.jsp?MENUID=TWITTER&ERR=OTHER";
}

response.sendRedirect(Common.GetPoipikuUrl(strNextContextPath));

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
		<meta http-equiv="refresh" content="3;URL=<%=strNextContextPath%>" />
		<style>
		.AnalogicoInfo {display: none;}
		</style>
	</head>

	<body>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper" style="text-align: center; margin: 150px auto;">
			<p><%=_TEX.T("EditSettingV.Twitter")%></p>
			<a href="<%=strNextContextPath%>">
			<%if(c.result==RegistTwitterTokenC.Result.OK) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
