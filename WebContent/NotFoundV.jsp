<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin checkLogin = new CheckLogin(request, response);

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("NotFound.TitleBar")%></title>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div style="box-sizing: border-box; width: 100%; float: left; text-align: center; padding: 70px 10px;">
				<h1><%=_TEX.T("NotFound.TitleBar")%></h1>
				<%=_TEX.T("NotFound.Detail")%>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
