<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin checkLogin = new CheckLogin(request, response);

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("NotFound.TitleBar")%></title>
	</head>

	<body>
		<article class="Wrapper">
			<div style="box-sizing: border-box; width: 100%; float: left; text-align: center; padding: 70px 10px;">
				<h1><%=_TEX.T("NotFound.TitleBar")%></h1>
				<%=_TEX.T("NotFound.Detail")%>
			</div>
		</article>
	</body>
</html>
