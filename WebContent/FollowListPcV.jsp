<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

FollowListC cResults = new FollowListC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("IllustListV.Follow")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
		});
		</script>
		<style>
		<%if(bSmartPhone){%>
		.Wrapper.ItemList .IllustItemList {margin-top: 6px;}
		<%} else {%>
		.Wrapper.ItemList .IllustItemList {margin-top: 16px;}
		<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper GridList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CUser cUser = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtmlUser(cUser, CCnv.MODE_PC, _TEX)%>
					<%if(bSmartPhone && (nCnt+1)%18==0) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</div>

			<%if(!bSmartPhone) {%>
			<div class="PcSideBar" style="margin-top: 16px;">
				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
				<div class="PcSideBarItem">
					<%@ include file="/inner/ad/TAdHomePc300x250_top_right.jsp"%>
				</div>
				<%}%>

				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
				<div class="FixFrame">
					<div class="PcSideBarItem">
						<%@ include file="/inner/ad/TAdHomePc300x600_bottom_right.jsp"%>
					</div>
				</div>
				<%}%>
			</div>
			<%}%>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/FollowListPcV.jsp", String.format("&MD=%d", cResults.m_nMode), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>