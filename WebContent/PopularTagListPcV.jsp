<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

PopularTagListC cResults = new PopularTagListC();
cResults.getParam(request);
cResults.SELECT_MAX_SAMPLE_GALLERY = 15;
cResults.SELECT_SAMPLE_GALLERY = (Util.isSmartPhone(request))?4:8;
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularTagList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});

		$(function() {
			var loadCount = 0, //loading状況の初期化
				imgLength = $("img").size(); //読み込む画像の数を取得
			$("img").each(function() {
				var src = $(this).attr("src");
				$("<img>")
					.attr("src", src)
					.load(function() {
						loadCount++; //画像が読み込まれたら、loading状況を更新
					});
			});

			var timer = setInterval(function() { //一定間隔でloading状況をローディングバーに反映
				$(".loadingBar").css({
					"width": (loadCount / imgLength) * 100 + "%" //読み込まれた画像の数を画像全体で割り、%としてローディングバーのwidthに設定
				});
				if((loadCount / imgLength) * 100 == 100){ //100%読み込まれたらローディングバーを隠す
					clearInterval(timer);
					$(".loadingBar").delay(200).animate({
						"opacity": 0
					}, 200);
				}
			}, 5);
		});		</script>
		<style>
			body {padding-top: 83px !important;}
			.CategoryListItem {display: block; float: left; width: 100%; padding: 0 0 20px 0; border-top: solid 1px #fff; border-bottom: solid 1px #eee; }
			.CategoryTitle {display: block; float: left; width: 100%;}
			.CategoryTitle .Category2 {font-size: 18px; padding: 10px 5px 5px 5px; display: block; font-weight: bold; color: #5bd;}
			.CategoryTitle .Category2 .More {display: block; float: right; font-size: 13px; font-weight: normal; color: #5bd;}

			<%if(Util.isSmartPhone(request)) {%>
			.IllustThumb .Category {top: 3px; left: 3px;font-size: 10px; min-width: 50px; height: 18px; line-height: 18px; max-width: 80px; padding: 0 3px;}
			.IllustThumb {margin: 2px !important; width: 86px; height: 86px;}
			.IllustThumbList {padding: 0;}
			<%} else {%>
			.IllustThumb .Category {font-size: 11px; min-width: 50px; height: 22px; line-height: 22px; max-width: 108px;}
			.IllustThumb {margin: 2px !important; width: 118px; height: 118px;}
			.IllustThumbList {padding: 0 7px;}
			<%}%>
		</style>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
				<a class="TabMenuItem" href="/CategoryListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Category")%></a>
				<a class="TabMenuItem Selected" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

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
			<%if((nCnt+1)%5==0) {%>
			<%@ include file="/inner/TAdMidWide.jspf"%>
			<%}%>
			<%}%>
		</div>

		<div class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList" style="padding: 0;">
				<%for(int nCnt=cResults.SELECT_MAX_SAMPLE_GALLERY; nCnt<cResults.m_vContentListWeekly.size(); nCnt++) {
					CTag cTag = cResults.m_vContentListWeekly.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMidWide.jspf"%>
					<%}%>
				<%}%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>