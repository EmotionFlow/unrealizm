<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

NewArrivalRequestC cResults = new NewArrivalRequestC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 45;
boolean bRtn = cResults.getResults(checkLogin);

String description = _TEX.T("THeader.Title.Desc");
String categoryName = _TEX.T("Category.All");
String categoryInfo = "";
if(cResults.m_nCategoryId >= 0) {
	categoryName = _TEX.T(String.format("Category.C%d", cResults.m_nCategoryId));
	categoryInfo = _TEX.T(String.format("Category.C%d.Info", cResults.m_nCategoryId)).trim();
	if(!categoryInfo.isEmpty()) {
		description = categoryInfo;
	}
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<%@ include file="/inner/TRequestIntroduction.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(Util.deleteCrLf(description))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%>(<%=categoryName%>)</title>

		<script type="text/javascript">
		$(function(){
			//$('#MenuNew').addClass('Selected');
			//$('#MenuRecent').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 79px !important;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%@ include file="/inner/TTabMenuRequestPotalPc.jsp"%>
		<div class="HeaderPoiPassAd" style="width: 100%;padding-top: 10px">
			<a onclick="dispRequestIntroduction()" href="javascript:void(0);" style="display: flex; flex-flow: row; padding: 3px 0 ; justify-content: center;">
				<span style="font-weight: bold; font-size: 13px; line-height: 25px; text-decoration: underline;">
					<i class="fas fa-info-circle"></i>リクエストとは？
				</span>
			</a>
		</div>

		<article class="Wrapper ThumbList">
			<%if(!categoryInfo.isEmpty() && cResults.m_nPage<=0) {%>
			<header class="CategoryInfo">
				<%=categoryInfo%>
			</header>
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
				<%=CPageBar.CreatePageBarSp("/NewArrivalRequestPcV.jsp", String.format("&CD=%d", cResults.m_nCategoryId), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
