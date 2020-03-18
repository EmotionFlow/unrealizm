<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(SP_REVIEW && !cCheckLogin.m_bLogin) {
	if(isApp){
		response.sendRedirect("https://poipiku.com/StartPoipikuAppV.jsp");
	} else {
		response.sendRedirect("https://poipiku.com/StartPoipikuV.jsp");
	}
	return;
}

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.SELECT_SAMPLE_GALLERY = 4;
boolean bRtn = cResults.getResults(cCheckLogin);

int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>HOT tag</title>
		<style>
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0;}
			.CategoryTitle {display: block; float: left; width: 100%; padding: 0; margin: 0;}
			.CategoryTitle .CategoryKeyword {font-size: 18px; padding: 10px 5px 0px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryListItem .CategoryMore {display: block; float: left; width: 100%; text-align: right; font-size: 13px; font-weight: normal; color: #5bd; padding: 0 7px; box-sizing: border-box;}

			.IllustThumb .Category {top: 3px; left: 3px;font-size: 10px; min-width: 50px; height: 18px; line-height: 18px; max-width: 80px; padding: 0 3px;}
			.IllustThumb {margin: 2px !important; width: 86px; height: 86px;}
			.IllustThumbList {padding: 0;}
			.IllustThumb .IllustThumbImg {width: 84px; height: 84px;}
		</style>
	</head>

	<body>
		<article class="Wrapper">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
				String strKeyWord = cResults.m_vContentListWeekly.get(nCnt).m_strTagTxt;%>
			<section class="CategoryListItem">
				<h2 class="CategoryTitle">
					<a class="CategoryKeyword" href="/SearchIllustByTag<%=isApp?"App":""%>V.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
						#<%=strKeyWord%>
					</a>
				</h2>
				<div class="IllustThumbList">
					<%for(CContent cContent : m_vContentList) {%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, nSpMode)%>
					<%}%>
				</div>
				<a class="CategoryMore" href="/SearchIllustByTag<%=isApp?"App":""%>V.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
					<%=_TEX.T("TopV.ContentsTitle.More")%>&nbsp;<i class="fas fa-angle-right"></i>
				</a>
			</section>
			<%//if((nCnt+1)%10==0) {%>
			<%//@ include file="/inner/TAdMidWide.jsp"%>
			<%//}%>
			<%}%>
		</article>

		<article class="Wrapper">
			<section id="IllustThumbList" class="IllustItemList">
			<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
				CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
				<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX, nSpMode)%>
				<%if((nCnt+1)%15==0) {%>
				<%@ include file="/inner/TAdMidWide.jsp"%>
				<%}%>
			<%}%>
			</section>
		</article>
	</body>
</html>