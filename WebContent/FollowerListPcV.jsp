<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

FollowerListC cResults = new FollowerListC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("IllustListV.Follower")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper ViewPc">
			<div id="IllustThumbList" class="IllustItemList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CUser cUser = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtml(cUser, CCnv.MODE_PC, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMidWide.jspf"%>
					<%}%>
				<%}%>
			</div>

			<%if(!bSmartPhone) {%>
			<div class="PcSideBar" style="margin-top: 30px;">
				<div class="FixFrame">
					<div class="PcSideBarItem">
						<%@ include file="/inner/TAdPc300x250_top_right.jspf"%>
					</div>

					<div class="PcSideBarItem">
						<%@ include file="/inner/TAdPc300x250_bottom_right.jspf"%>
					</div>
				</div>
			</div>
			<%}%>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/FollowerListPcV.jsp", "", cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>