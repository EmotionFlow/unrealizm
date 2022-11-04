<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

NewArrivalC cResults = new NewArrivalC();
cResults.getParam(request);
cResults.selectMaxGallery = 48;
boolean bRtn = cResults.getResults(checkLogin);

String description = _TEX.T("THeader.Title.Desc");
String categoryName = _TEX.T("Category.All");
String categoryInfo = "";
if(cResults.categoryId >= 0) {
	categoryName = _TEX.T(String.format("Category.C%d", cResults.categoryId));
	categoryInfo = _TEX.T(String.format("Category.C%d.Info", cResults.categoryId)).trim();
	if(!categoryInfo.isEmpty()) {
		description = categoryInfo;
	}
}
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(Util.deleteCrLf(description))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%>(<%=categoryName%>)</title>

		<script type="text/javascript">
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("drag dragstart",function(e){return false;});
			});
			$('#MenuNew').addClass('Selected');
			$('#MenuRecent').addClass('Selected');
			updateCategoryMenuPos(0);
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
				<li><a class="TabMenuItem Selected" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper GridList">
			<nav id="CategoryMenu" class="CategoryMenu" style="display: none;">
				<a class="BtnBase CategoryBtn <%if(cResults.categoryId<0){%> Selected<%}%>" href="/NewArrivalPcV.jsp"><%=_TEX.T("Category.All")%></a>
				<%for(int nCategoryId : Common.CATEGORY_ID) {%>
				<a class="BtnBase CategoryBtn CC<%=nCategoryId%> <%if(nCategoryId==cResults.categoryId){%> Selected<%}%>" href="/NewArrivalPcV.jsp?CD=<%=nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></a>
				<%}%>
			</nav>

			<%if(!categoryInfo.isEmpty() && cResults.page <=0) {%>
			<header class="CategoryInfo">
				<%=categoryInfo%>
			</header>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt = 0; nCnt<cResults.contentList.size(); nCnt++) {
					CContent cContent = cResults.contentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%if(nCnt==3){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
					<%if(nCnt==19){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
					<%if(nCnt==35){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/NewArrivalPcV.jsp", String.format("&CD=%d", cResults.categoryId), cResults.page, cResults.contentsNum, cResults.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>

	</body>
</html>
