<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(SP_REVIEW && !cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}

CategoryListC cResults = new CategoryListC();
cResults.getParam(request);
cResults.SELECT_SAMPLE_GALLERY = 3;
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>process</title>
		<style>
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 40px 0; border-top: solid 1px #fff; border-bottom: solid 1px #eee; }
			.CategoryTitle {display: block; float: left; width: 100%;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 10px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}
		</style>
	</head>

	<body>
		<div class="Wrapper">

			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeList.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeList.get(nCnt);%>
				<a class="CategoryListItem" href="/SearchIllustByCategoryV.jsp?CD=<%=Common.CATEGORY_ID[nCnt]%>">
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
				<%}%>
			</div>

		</div>
	</body>
</html>