<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(SP_REVIEW && !checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartPoipikuV.jsp").forward(request,response);
	}
	return;
}

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 50;
cResults.SELECT_MAX_SAMPLE_GALLERY = 50;
cResults.SELECT_SAMPLE_GALLERY = 3;
boolean bRtn = cResults.getResults(checkLogin);

int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>HOT tag</title>
		<style>
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0;}
			.CategoryListItem .CategoryMore {display: block; float: left; width: 100%; text-align: right; font-size: 13px; font-weight: normal; padding: 0 7px; box-sizing: border-box;}
			.SearchResultTitle {margin: 10px 0 0 0;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

		<article class="Wrapper">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
				String strKeyWord = cResults.m_vContentListWeekly.get(nCnt).m_strTagTxt;%>
			<section class="CategoryListItem">
				<header class="SearchResultTitle">
					<a class="Keyword" href="/SearchIllustByTag<%=isApp?"App":""%>V.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
						#<%=strKeyWord%>
					</a>
				</header>
				<div class="IllustThumbList">
					<%for(CContent cContent : m_vContentList) {%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX)%>
					<%}%>
				</div>
				<a class="CategoryMore" href="/SearchIllustByTag<%=isApp?"App":""%>V.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
					<%=_TEX.T("TopV.ContentsTitle.More")%>&nbsp;<i class="fas fa-angle-right"></i>
				</a>
			</section>
			<%if((nCnt+1)%10==0) {%>
			<%@ include file="/inner/TAd728x90_mid.jsp"%>
			<%}%>
			<%}%>
		</article>

		<%if(cResults.SELECT_MAX_SAMPLE_GALLERY-cResults.SELECT_MAX_GALLERY>0) {%>
		<article class="Wrapper ItemList">
			<section id="IllustThumbList" class="IllustItemList">
			<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
				CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
				<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX, nSpMode)%>
				<%if((nCnt+1)%15==0) {%>
				<%@ include file="/inner/TAd728x90_mid.jsp"%>
				<%}%>
			<%}%>
			</section>
		</article>
		<%}%>

	</body>
</html>