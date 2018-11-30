<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(SP_REVIEW && !cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.SELECT_SAMPLE_GALLERY = 4;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>HOT tag</title>
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


			<div class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
					ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
					String strKeyWord = cResults.m_vContentListWeekly.get(nCnt).m_strTagTxt;%>
				<a class="CategoryListItem" href="/SearchIllustByTagV.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
					<span class="CategoryTitle">
						<span class="Category2">
							<i class="fas fa-hashtag"></i> <%=strKeyWord%>
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
				<%//if((nCnt+1)%10==0) {%>
				<%//@ include file="/inner/TAdMidWide.jspf"%>
				<%//}%>
				<%}%>
			</div>

			<div id="IllustThumbList" class="IllustItemList">
				<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
					CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX)%>
					<%if((nCnt+1)%15==0) {%>
					<%@ include file="/inner/TAdMidWide.jspf"%>
					<%}%>
				<%}%>
			</div>

		</div>
	</body>
</html>