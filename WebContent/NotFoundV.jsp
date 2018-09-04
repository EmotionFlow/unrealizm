<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title><%=_TEX.T("NotFound.TitleBar")%></title>
	</head>

	<body>
		<div class="Wrapper">
			<%@ include file="/inner/TAdTop.jspf"%>

			<div style="box-sizing: border-box; width: 100%; float: left; text-align: center; padding: 70px 10px;">
				<h1><%=_TEX.T("NotFound.TitleBar")%></h1>
				<%=_TEX.T("NotFound.Detail")%>
			</div>

			<%@ include file="/inner/TAdBottom.jspf"%>
		</div>
	</body>
</html>
