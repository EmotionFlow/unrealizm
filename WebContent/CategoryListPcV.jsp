<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

CategoryListC cResults = new CategoryListC();
cResults.getParam(request);
cResults.SELECT_SAMPLE_GALLERY = (Util.isSmartPhone(request))?4:8;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("CategoryList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuSearch').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 83px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 20px 0; border-top: solid 1px #fff; border-bottom: solid 1px #eee; }
			.CategoryTitle {display: block; float: left; width: 100%;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 10px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}

			<%if(Util.isSmartPhone(request)) {%>
			.IllustThumb .Category {top: 3px; left: 3px;font-size: 10px; min-width: 50px; height: 18px; line-height: 18px; max-width: 80px; padding: 0 3px;}
			.IllustThumb {margin: 2px !important; width: 86px; height: 130px;}
			.IllustThumbList {padding: 0;}
			.IllustThumb .IllustThumbImg {width: 86px; height: 86px;}
			<%} else {%>
			.IllustThumb .Category {font-size: 11px; min-width: 50px; height: 20px; line-height: 20px; padding: 0 5px;}
			.IllustThumb {margin: 2px !important; width: 118px; height: 164px;}
			.IllustThumbList {padding: 0 7px;}
			.IllustThumb .IllustThumbImg {width: 118px; height: 118px;}
			.IllustThumb .IllustInfo {padding: 3px 3px 0px 3px;}
			.IllustThumb .IllustInfo .IllustInfoDesc {font-size: 10px; height: 20px; line-height: 20px;}
			<%}%>
		</style>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem Selected" href="/CategoryListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Category")%></a>
				<a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>


		<div class="Wrapper ThumbList">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeList.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeList.get(nCnt);
				int nCategoryId = cResults.m_vContentList.get(nCnt);
			%>
			<a class="CategoryListItem" href="/SearchIllustByCategoryPcV.jsp?CD=<%=nCategoryId%>">
				<span class="CategoryTitle">
					<span class="Category2 C<%=nCategoryId%>">
						<%=_TEX.T(String.format("Category.C%d", nCategoryId))%>
						<span class="More"><%=_TEX.T("TopV.ContentsTitle.More")%></span>
					</span>
				</span>
				<span class="IllustThumbList">
					<%for(CContent cContent : m_vContentList) {%>
					<span class="IllustThumb">
						<%
						String strSrc;
						if(cContent.m_nSafeFilter<2) {
							strSrc = Common.GetUrl(cContent.m_strFileName);
						} else if(cContent.m_nSafeFilter<4) {
							strSrc = "/img/warning.png";
						} else {
							strSrc = "/img/R18.png";
						}
						%>
						<img class="IllustThumbImg" src="<%=strSrc%>_360.jpg">
						<span class="IllustInfo">
							<span class="Category C<%=cContent.m_nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))%></span>
							<span class="IllustInfoDesc"><%=Common.ToStringHtml(cContent.m_strDescription)%></span>
						</span>
					</span>
					<%}%>
				</span>
			</a>
			<%if((nCnt+1)%5==0) {%>
			<%@ include file="/inner/TAdMidWide.jspf"%>
			<%}%>
			<%}%>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>