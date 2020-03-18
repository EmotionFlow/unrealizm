<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(SP_REVIEW && !cCheckLogin.m_bLogin) {
	response.sendRedirect("https://poipiku.com/StartPoipikuV.jsp");
	return;
}

CategoryListC cResults = new CategoryListC();
cResults.getParam(request);
cResults.SELECT_SAMPLE_GALLERY = 4;
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>process</title>
		<style>
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 20px 0;}
			.CategoryTitle {display: block; float: left; width: 100%; padding: 0; margin: 0;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 10px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}

			.IllustThumb .Category {top: 3px; left: 3px;font-size: 10px; min-width: 50px; height: 18px; line-height: 18px; max-width: 80px; padding: 0 3px;}
			.IllustThumb {margin: 2px !important; width: 86px; height: 86px;}
			.IllustThumbList {padding: 0;}
			.IllustThumb .IllustThumbImg {width: 84px; height: 84px;}
		</style>
	</head>

	<body>
		<article class="Wrapper">
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeList.size(); nCnt++) {
					ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeList.get(nCnt);
					int nCategoryId = cResults.m_vContentList.get(nCnt);
				%>
				<section class="CategoryListItem">
					<h2 class="CategoryTitle">
						<a class="Category2 C<%=nCategoryId%>" href="/NewArrivalV.jsp?CD=<%=nCategoryId%>">
							<span class="Keyword"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></span>
							<span class="More"><%=_TEX.T("TopV.ContentsTitle.More")%></span>
						</a>
					</h2>
					<div class="IllustThumbList">
						<%for(CContent cContent : m_vContentList) {%>
						<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX)%>
						<%}%>
					</div>
				</section>
				<%}%>
			</div>
		</article>
	</body>
</html>