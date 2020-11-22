<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = UserAuthUtil.activateEmail(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("ActivateEmailV.Title")%></title>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<article class="Wrapper">
			<div class="SettingList" style="margin-top: 50px;">
				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("ActivateEmailV.Title")%></div>
					<div class="SettingBody">
						<% if(nRtn>0){ %>
						<p><%=_TEX.T("ActivateEmailV.Message.Ok")%></p>
						<% } else { %>
						<p><%=_TEX.T("ActivateEmailV.Message.Ng")%></p>
						<% } %>
					</div>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
