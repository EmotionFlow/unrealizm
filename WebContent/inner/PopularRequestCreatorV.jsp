<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
	if (isApp && SP_REVIEW && !checkLogin.m_bLogin) {
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
		return;
	}
	if (isApp) {
		checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
	}

	boolean bSmartPhone = Util.isSmartPhone(request);

	PopularRequestCreatorC cResults = new PopularRequestCreatorC();
	cResults.getParam(request);
	cResults.SELECT_MAX_GALLERY = 45;
	boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%if(isApp){%>
	<%@ include file="/inner/THeaderCommon.jsp"%>
	<%}else{%>
	<%@ include file="/inner/THeaderCommonPc.jsp"%>
	<%}%>
	<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
	<%@ include file="/inner/TRequestIntroduction.jsp"%>
	<meta name="description" content="人気クリエイター"/>
	<title><%=_TEX.T("THeader.Title")%> - 人気クリエイター</title>
	<style>
				body {
						padding-top: 79px !important;
				}
	</style>
	<script type="text/javascript">
		$(function(){
			$('#MenuRequest').addClass('Selected');
			$('#MenuSearch').hide();
			$('#MenuMyRequests').show();
		});
	</script>
</head>

<body>
<%if(!isApp){%>
<%String searchType = "Contents";%>
<%@ include file="/inner/TMenuPc.jsp"%>
<%}%>
<%@ include file="/inner/TTabMenuRequestPotalPc.jsp"%>
<div class="HeaderPoiPassAd" style="width: 100%;padding-top: 10px">
	<a onclick="dispRequestIntroduction()" href="javascript:void(0);" style="display: flex; flex-flow: row; padding: 3px 0 ; justify-content: center;">
		<span style="font-weight: bold; font-size: 13px; line-height: 25px; text-decoration: underline;">
			<i class="fas fa-info-circle"></i><%=_TEX.T("Request.WhatIs")%>
		</span>
	</a>
</div>

<article class="Wrapper GridList">
	<section id="IllustThumbList" class="IllustThumbList">
		<%
			final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
			for (int nCnt = 0; nCnt < cResults.m_vContentList.size(); nCnt++) {
				CUser cUser = cResults.m_vContentList.get(nCnt);
				if (CheckLogin.isStaff(cUser.m_nUserId)){
					continue;
				}
		%>
			<%=CCnv.toHtmlUser(cUser, CCnv.MODE_SP, _TEX, nSpMode)%>
			<%if (!isApp && Util.isSmartPhone(request)) {%>
				<%if (nCnt == 14) {%>
				<%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp" %>
				<%}%>
				<%if (nCnt == 29) {%>
				<%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp" %>
				<%}%>
				<%} else {%>
				<%if (nCnt == 14) {%>
				<%@ include file="/inner/ad/TAdSearchUserPc728x90_mid_1.jsp" %>
				<%}%>
				<%if (nCnt == 29) {%>
				<%@ include file="/inner/ad/TAdSearchUserPc728x90_mid_2.jsp" %>
				<%}%>
			<%}%>
		<%}%>
		<%if(isApp){%>
		<%@ include file="/inner/TAd336x280_mid.jsp"%>
		<%}%>
	</section>

	<%if(!isApp){%>
	<nav class="PageBar">
		<%=CPageBar.CreatePageBarSp("/PopularRequestCreatorPcV.jsp", "&KWD=", cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
	</nav>
	<%}%>
</article>
<%if(!isApp){%>
<%@ include file="/inner/TFooterSingleAd.jsp"%>
<%}%>
</body>
</html>