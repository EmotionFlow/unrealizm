<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(SP_REVIEW && !cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
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
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>process</title>
		<style>
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 20px 0; border-top: solid 1px #fafaff; border-bottom: solid 1px #eee; }
			.CategoryTitle {display: block; float: left; width: 100%;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 10px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}

			.IllustThumb .Category {top: 3px; left: 3px;font-size: 10px; min-width: 50px; height: 18px; line-height: 18px; max-width: 80px; padding: 0 3px;}
			.IllustThumb {margin: 2px !important; width: 86px; height: 130px;}
			.IllustThumbList {padding: 0;}
			.IllustThumb .IllustThumbImg {width: 86px; height: 86px;}
		</style>
	</head>

	<body>
		<div class="Wrapper">


			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeList.size(); nCnt++) {
					ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeList.get(nCnt);
					int nCategoryId = cResults.m_vContentList.get(nCnt);
				%>
				<a class="CategoryListItem" href="/NewArrivalV.jsp?CD=<%=nCategoryId%>">
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
				<%}%>
			</div>

		</div>
	</body>
</html>