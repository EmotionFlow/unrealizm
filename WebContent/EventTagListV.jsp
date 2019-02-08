<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(SP_REVIEW && !cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}

EventTagListC cResults = new EventTagListC();
cResults.getParam(request);
cResults.SELECT_MAX_SAMPLE_GALLERY = 0;
cResults.SELECT_SAMPLE_GALLERY = 0;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>Event tag</title>
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
			<div style="font-size: 11px; padding: 20px 0 0 0 ;">
				<span style="color: red;">new!</span>
				(βテスト中)
				タグに「企画」という文字を入れるとこの一覧に表示させることができます。企画に活用してください！
			</div>
			<section id="IllustThumbList" class="IllustThumbList">
			<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
				CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
				<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX)%>
				<%if((nCnt+1)%15==0) {%>
				<%@ include file="/inner/TAdMidWide.jsp"%>
				<%}%>
			<%}%>
			</section>
		</article>
	</body>
</html>