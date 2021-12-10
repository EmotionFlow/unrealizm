<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

MyHomeTagSettingC cResults = new MyHomeTagSettingC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyHomeTagSetting.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<style>
			body {padding-top: 79px !important;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem Selected" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div style="margin-top:15px; text-align: center;">
					<h3><%=_TEX.T("FollowingTag.Info02")%></h3>
					<div style="text-decoration: underline; margin-top: 15px;">
						<a class="FooterLink" href="https://poipiku.com/SearchTagByKeywordPcV.jsp"><%=_TEX.T("FollowingTag.Link01")%></a>
					</div>
					<div style="text-decoration: underline; margin-top: 15px;">
						<a class="FooterLink" href="https://poipiku.com/PopularTagListPcV.jsp"><%=_TEX.T("FollowingTag.Link02")%></a>
					</div>
				</div>
				<%}%>

				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CTag cTag = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAd728x90_mid.jsp"%>
					<%}%>
				<%}%>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>