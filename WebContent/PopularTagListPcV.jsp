<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.SELECT_MAX_SAMPLE_GALLERY = 15;
cResults.SELECT_SAMPLE_GALLERY = (Util.isSmartPhone(request))?4:8;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularTagList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
			$('#MenuHotTag').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 83px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 20px 0;}
			.CategoryTitle {display: block; float: left; width: 100%;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 10px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}

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
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem Selected" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="Wrapper ThumbList">
			<%for(int nCnt=0; nCnt<cResults.m_vContentSamplpeListWeekly.size(); nCnt++) {
				ArrayList<CContent> m_vContentList = cResults.m_vContentSamplpeListWeekly.get(nCnt);
				String strKeyWord = cResults.m_vContentListWeekly.get(nCnt).m_strTagTxt;%>
			<a class="CategoryListItem" href="/SearchIllustByTagPcV.jsp?KWD=<%=URLEncoder.encode(strKeyWord, "UTF-8")%>">
				<span class="CategoryTitle">
					<span class="Category2">
						<i class="fas fa-hashtag"></i> <%=strKeyWord%>
						<span class="More"><%=_TEX.T("TopV.ContentsTitle.More")%></span>
					</span>
				</span>
				<span class="IllustThumbList">
					<%for(CContent cContent : m_vContentList) {%>
					<span class="IllustThumb">
						<%
						String strSrc;
						if(cContent.m_nSafeFilter<2) {
							strSrc = cContent.m_strFileName;
						} else if(cContent.m_nSafeFilter<4) {
							strSrc = "/img/warning.png";
						} else {
							strSrc = "/img/R-18.png";
						}
						%>
						<span class="IllustThumbImg" style="background-image:url('<%=Common.GetUrl(strSrc)%>_360.jpg')"></span>
						<span class="IllustInfo">
							<span class="Category C<%=cContent.m_nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))%></span>
							<span class="IllustInfoDesc"><%=Common.ToStringHtml(cContent.m_strDescription)%></span>
						</span>
					</span>
					<%}%>
				</span>
			</a>
			<%if((nCnt+1)%10==0) {%>
			<%@ include file="/inner/TAdMidWide.jsp"%>
			<%}%>
			<%}%>
		</div>

		<div class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList" style="padding: 0;">
				<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
					CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
					<%if((nCnt+1)%15==0) {%>
					<%@ include file="/inner/TAdMidWide.jsp"%>
					<%}%>
				<%}%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>