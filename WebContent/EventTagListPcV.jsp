<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

EventTagListC cResults = new EventTagListC();
cResults.getParam(request);
cResults.SELECT_MAX_SAMPLE_GALLERY = 0;
cResults.SELECT_SAMPLE_GALLERY = 0;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EventTagList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
			$('#MenuHotTag').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 83px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0;}
			.CategoryTitle {display: block; float: left; width: 100%; padding: 0; margin: 0;}
			.CategoryTitle .CategoryKeyword {font-size: 18px; padding: 10px 5px 0px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryListItem .CategoryMore {display: block; float: left; width: 100%; text-align: right; font-size: 13px; font-weight: normal; color: #5bd; padding: 0 7px; box-sizing: border-box;}

			<%if(Util.isSmartPhone(request)) {%>
			.IllustThumb .Category {top: 3px; left: 3px;font-size: 10px; min-width: 50px; height: 18px; line-height: 18px; max-width: 80px; padding: 0 3px;}
			.IllustThumb {margin: 2px !important; width: 86px; height: 86px;}
			.IllustThumbList {padding: 0;}
			.IllustThumb .IllustThumbImg {width: 84px; height: 84px;}
			<%} else {%>
			.IllustThumb .Category {font-size: 11px; min-width: 50px; height: 20px; line-height: 20px; padding: 0 5px;}
			.IllustThumb {margin: 2px !important; width: 118px; height: 118px;}
			.IllustThumbList {padding: 0 7px;}
			.IllustThumb .IllustThumbImg {width: 116px; height: 116px;}
			.IllustThumb .IllustInfo {padding: 3px 3px 0px 3px;}
			.IllustThumb .IllustInfo .IllustInfoDesc {font-size: 10px; height: 20px; line-height: 20px;}
			<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
				<li><a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem Selected" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper ItemList">
			<nav id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="BtnBase CategoryBtn Selected" href="/EventTagListPcV.jsp"><%=_TEX.T("EventTagList.Title")%></a>
			</nav>
			<div style="font-size: 11px; padding: 20px 0 0 0 ;">
				<span style="color: red;">new!</span>
				(βテスト中)
				タグに「企画」という文字を入れるとこの一覧に表示させることができます。企画に活用してください！
			</div>
			<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
				CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
			<section id="IllustThumbList" class="IllustThumbList" style="">
				<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
			</section>
				<%if((nCnt+1)%15==0) {%>
				<%@ include file="/inner/TAdMidWide.jsp"%>
				<%}%>
			<%}%>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>