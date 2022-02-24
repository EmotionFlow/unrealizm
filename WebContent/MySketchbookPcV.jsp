<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
if (Util.isBot(request)) return;
boolean isApp = false;

CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/SearchIllustByKeywordGridPcV.jsp").forward(request,response);
	return;
}

MySketchbookC cResults = new MySketchbookC();
cResults.getParam(request);
cResults.selectMaxGallery = 45;
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
		<%if (isApp || Util.isSmartPhone(request)) {%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%} else {%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<%}%>
		<%@ include file="/inner/TRequestIntroduction.jsp"%>
		<meta name="description" content="マイスケブ"/>
		<title><%=_TEX.T("THeader.Title")%> - マイスケブ</title>
		<style>
			<%if(!isApp){%>
            body {padding-top: 79px !important;}
			<%}%>
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
	<%@ include file="/inner/TMenuPc.jsp"%>
	<%@ include file="/inner/TTabMenuRequestPotalPc.jsp"%>
	<%}%>

		<article class="Wrapper ThumbList">
			<div class="HeaderPoiPassAd" style="width: 100%;padding-top: 10px">
				<a onclick="dispRequestIntroduction()" href="javascript:void(0);" style="display: flex; flex-flow: row; padding: 3px 0 ; justify-content: center;">
				<span style="font-weight: bold; font-size: 13px; line-height: 25px; text-decoration: underline;">
					<i class="fas fa-info-circle"></i><%=_TEX.T("Request.WhatIs")%>
				</span>
				</a>
			</div>

			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
			<div style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</div>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%if(nCnt==14 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
					<%if(nCnt==29 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchIllustByKeywordPcV.jsp", "", cResults.m_nPage, cResults.m_nContentsNum, cResults.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
