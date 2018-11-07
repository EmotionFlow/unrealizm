<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

CategoryListC cResults = new CategoryListC();
cResults.getParam(request);
cResults.SELECT_SAMPLE_GALLERY = (Util.isSmartPhone(request))?3:5;
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
			$('#MenuHome').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 83px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 40px 0; border-top: solid 1px #fff; border-bottom: solid 1px #eee; }
			.CategoryTitle {display: block; float: left; width: 100%;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 15px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}
		</style>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem Selected" href="/CategoryListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Category")%></a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper ThumbList">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeList.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeList.get(nCnt);%>
			<a class="CategoryListItem" href="/SearchIllustByCategoryPcV.jsp?CD=<%=Common.CATEGORY_ID[nCnt]%>">
				<span class="CategoryTitle">
					<span class="Category2 C<%=Common.CATEGORY_ID[nCnt]%>">
						<%=_TEX.T(String.format("Category.C%d", Common.CATEGORY_ID[nCnt]))%>
						<span class="More"><%=_TEX.T("TopV.ContentsTitle.More")%></span>
					</span>
				</span>
				<span class="IllustThumbList">
					<%for(CContent cContent : m_vContentList) {%>
					<span class="IllustThumb">
						<span class="Category C<%=cContent.m_nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))%></span>
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
					</span>
					<%}%>
				</span>
			</a>
			<%//if((nCnt+1)%15==0) {%>
			<%//@ include file="/inner/TAdMidWide.jspf"%>
			<%//}%>
			<%}%>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>