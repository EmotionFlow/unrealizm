<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/RandomPickupGridPcV.jsp").forward(request,response);
	return;
}

RandomPickupC results = new RandomPickupC();
results.getParam(request);
results.SELECT_MAX_GALLERY = 45;
boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("RandomPickup.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("drag dragstart",function(e){return false;});
			});
			$('#MenuNew').addClass('Selected');
			$('#MenuRandom').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 51px !important;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a class="TabMenuItem Selected" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper ThumbList" style="padding-top: 30px">

			<%if(false) {%>
<%--			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>--%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</span>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
					CContent cContent = results.contentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
<%--					<%if(nCnt==14 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>--%>
<%--					<%if(nCnt==29 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>--%>
				<%}%>
			</section>
		</article>

		<div style="display: block; text-align: center; margin: 15px 0; width: 100%; float: left;">
			<a class="BtnBase" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
		</div>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
