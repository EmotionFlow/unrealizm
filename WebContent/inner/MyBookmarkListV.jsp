<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone;
if (isApp) {
	bSmartPhone = true;
} else {
	bSmartPhone = Util.isSmartPhone(request);
}

if(!checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartUnrealizmAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	}
	return;
}

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/MyBookmarkListGridPcV.jsp").forward(request,response);
	return;
}

MyBookmarkC myBookmarkC = new MyBookmarkC();
myBookmarkC.getParam(request);
myBookmarkC.noContents = true;
if (isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
myBookmarkC.getResults(checkLogin, false);

MyBookmarkC results = new MyBookmarkC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(isApp){%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%} else {%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyBookmarkList.Title")%></title>

		<%if(!isApp){%>
		<script type="text/javascript">
			$(function(){
				$('#MenuHome').addClass('Selected');
			});
		</script>
		<%}%>

		<script type="text/javascript">
			let lastBookmarkId = 0;
			let page = 0;

			const loadingSpinner = {
				appendTo: "#IllustThumbList",
				className: "loadingSpinner",
			}
			const htmlCache = new CacheApiHtmlCache(CURRENT_CACHES_INFO.MyBookmarkListContents, <%=checkLogin.m_nUserId%>);
			const observer = createIntersectionObserver(addContents);

			function addContents(){
				appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
				return $.ajax({
					"type": "post",
					"data": {"SD": lastBookmarkId, "PG": page},
					"dataType": "json",
					"url": "/f/MyBookmarkList<%=isApp ? "App" : ""%>F.jsp",
				}).then((data) => {
					page++;
					htmlCache.header.page = page;
					if (data.end_id > 0) {
						lastBookmarkId = data.end_id;
						htmlCache.header.lastContentId = lastBookmarkId;
						const contents = document.getElementById('IllustThumbList');
						$(contents).append(data.html);
						//gtag('config', 'UA-125150180-1', {'page_location': location.pathname + '/' + g_nEndId + '.html'});
						observer.observe(contents.lastElementChild);
					}
					removeLoadingSpinners(loadingSpinner.className);
				}, (error) => {
					DispMsg('Connection error');
				});
			}

			function initContents(){
				$(window).scrollTop(0);
				$(".ThumbListHeader").show();
				addContents().then(()=>{
					$("#Footer").show();
				});
			}

			<%if(!isApp){%>
			function restoreContents(txt){
				if (Date.now() - htmlCache.header.updatedAt > htmlCache.maxAge) {
					htmlCache.delete(null);
					initContents();
				} else {
					appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
					const contents = document.getElementById('IllustThumbList');
					$(contents).empty().html(txt);
					removeLoadingSpinners(loadingSpinner.className);
					$(".ThumbListHeader").show();
					$("#Footer").show();
					$(window).scrollTop(htmlCache.header.scrollTop);
					lastBookmarkId = htmlCache.header.lastContentId;
					page = htmlCache.header.page;
					observer.observe(contents.lastElementChild);
					htmlCache.delete(null);
				}
			}
			<%}%>

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("drag dragstart",function(e){if(!$(e.target).is(".MyUrl")){return false;}}
					)});

				<%if(!isApp){%>
				htmlCache.addClickEventListener(
					'#HeaderSearchBtn, .SystemInfo a, .slick-list a, ' +
					'#TabMenuMyHome, #TabMenuMyHomeTag, ' +
					'.IllustThumb a, ' +
					'#MenuHome, #MenuNew, #MenuRequest, #MenuAct, #MenuMe',
					'#IllustThumbList'
				);
				htmlCache.pull(restoreContents, initContents);
				<%} else {%>
				initContents();
				<%}%>
			});
		</script>
		<%if(!isApp){%>
		<style>
						body {padding-top: 51px !important;}
		</style>
		<%}%>
	</head>

	<body>
		<%if(!isApp){%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a id="TabMenuMyHome" class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a id="TabMenuMyHomeTag" class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a id="TabMenuMyBookmark" class="TabMenuItem Selected" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>
		<%}%>

		<%if(isApp){%>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>
		<%}else{%>
		<div class="ThumbListHeader" style="display: none">
			<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		</div>
		<%}%>

		<article class="Wrapper ThumbList" style="padding-top: 44px">
			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/TAdSp300x100_top.jsp"%>
			</span>
			<%}%>

			<%if(myBookmarkC.contentsNum <=0) {%>
			<div style="padding: 10px; box-sizing: border-box; text-align: center;">
				<%=_TEX.T("MyBookmarkList.LetsMessage")%>
			</div>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList" style="padding-bottom: 5px;">
			</section>
		</article>
		<%if(!isApp){%>
		<div id="Footer" style="display: none">
			<%@ include file="/inner/TFooterBase.jsp"%>
		</div>
		<%}%>
	</body>
</html>