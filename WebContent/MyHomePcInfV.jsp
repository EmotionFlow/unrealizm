<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/MyHomeGridPcV.jsp").forward(request,response);
	return;
}

MyHomePcC cResults = new MyHomePcC();
cResults.getParam(request);

if(!checkLogin.m_bLogin) {
	if(cResults.n_nUserId>0) {
		response.sendRedirect("/"+cResults.n_nUserId+"/");
	} else {
		getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	}
	return;
}

cResults.getResults(checkLogin);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%//@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<title><%=_TEX.T("MyHomePc.Title")%> | <%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<%@ include file="/inner/TDeleteContent.jsp"%>
		<%@ include file="/inner/TDispRequestTextDlg.jsp"%>

		<script>
			const CURRENT_CACHE = CURRENT_CACHES.MyHomeContents;
			let lastContentId = -1;
			let page = 0;
			self.addEventListener('activate', function(event) {
				let expectedCacheNamesSet = new Set(Object.values(CURRENT_CACHES).map(e => e.name));
				event.waitUntil(
					caches.keys().then(function(cacheNames) {
						return Promise.all(
							cacheNames.map(function(cacheName) {
								if (!expectedCacheNamesSet.has(cacheName)) {
									console.log('Deleting out of date cache:', cacheName);
									return caches.delete(cacheName);
								}
							})
						);
					})
				);
			});

			const observer = new IntersectionObserver(entries => {
				entries.forEach(entry => {
					if (!entry.isIntersecting) return;
					observer.unobserve(entry.target);
					addContents();
				});
			});

			function addContents(){
				$("#IllustItemList").append(getLoadingSpinnerHtml());
				$.ajax({
					"type": "post",
					"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page + 1},
					"dataType": "json",
					"url": "/f/MyHomeF.jsp",
				}).then((data) => {
					page++;
					$(".loadingSpinner").remove();
					if (data.end_id > 0) {
						lastContentId = data.end_id;
						console.log("lastContentId:" + lastContentId);
						const contents = document.getElementById('IllustItemList');
						$(contents).append(data.html);
						//gtag('config', 'UA-125150180-1', {'page_location': location.pathname + '/' + g_nEndId + '.html'});
						observer.observe(contents.lastElementChild);
					}
				}, (error) => {
					DispMsg('Connection error');
				});
			}

			function restoreContents(txt, scrollTo, _lastContentId, _page, _updatedAt){
				if (Date.now() - _updatedAt > CURRENT_CACHE.maxAge) {
					console.log("cache was expired");
					addContents();
				} else {
					const contents = document.getElementById('IllustItemList');
					$(contents).html(txt);
					$(window).scrollTop(scrollTo);
					if (_lastContentId) lastContentId = _lastContentId;
					if (_page) page = _page;
					observer.observe(contents.lastElementChild);
				}
			}

			function _putCache(event) {
				event.waitUntil(
					putHtmlCache(CURRENT_CACHE.name, CURRENT_CACHE.request, $("#IllustItemList").html(), lastContentId, page)
				)
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){if(!$(e.target).is(".MyUrl")){return false;}}
				)});

				$(document).on('click',
					'.TabMenu a, .SystemInfo a, .slick-list a, .IllustItemCategory a, .IllustItemUser a, .IllustItemCommandEdit, .FooterMenu a',
					_putCache);

				const referrer = document.referrer;
				if (referrer.indexOf('https://poipiku.com/MyHomePcV.jsp') === 0  || referrer.indexOf('https://poipiku.com/MyHomePcInfV.jsp') === 0) {
					deleteCache(CURRENT_CACHE.name, CURRENT_CACHE.request, addContents);
				} else {
					pullHtmlCache(CURRENT_CACHE.name, CURRENT_CACHE.request, restoreContents, addContents);
				}
			});

			<%if(!checkLogin.m_bEmailValid && System.currentTimeMillis() % 100 == 0){%>
			Swal.fire({
				html:
					'<style>' +
					' .RequestEmailMsg {text-align: left; font-size: 19px;}' +
					' .RequestEmailSubmit {margin: 30px auto; padding: 10px 30px; -webkit-tap-highlight-color: rgba(255, 255, 255, 0) !important; -webkit-focus-ring-color: rgba(255, 255, 255, 0) !important; outline: none !important;}' +
					' .RequestEmailLater {width: 100%; text-align: left; font-size: 14px; font-weight: 500; margin: 10px 0 5px 0; padding: 0; font-weight: 400; color: #aaaaaa; background: none; border: none;}' +
					' .swal2-popup .swal2-actions {margin: 0;}' +
					'</style>' +
					'<div class="RequestEmailMsg">' + "<%=_TEX.T("RequestEmail.Msg")%>" + '</div>' +
					'<div><a class="BtnBase ResBtnSetItem Selected RequestEmailSubmit" href="/MyEditSettingPcV.jsp?MENUID=MAIL">' +
					'✉️ <%=_TEX.T("RequestEmail.GoSettingPage")%>' +
					'</a></div>',
				focusConfirm: false,
				showConfirmButton: false,
				showCancelButton: true,
				cancelButtonText: "<%=_TEX.T("RequestEmail.Later")%>",
				buttonsStyling: false,
				cancelButtonClass: "RequestEmailLater",
			})
			<%}%>
		</script>

		<style>
			body {padding-top: 79px !important;}
			.PoipikuDesc.Event {margin: 10px 0;}
			.RequestEmail {display: block; float: left; width: 100%; margin: 1px 0 0 0; text-decoration: underline; background: #f4f9fb; text-align: center;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>

		<%if(cResults.m_cSystemInfo!=null) {%>
		<div class="SystemInfo" id="SystemInfo_<%=cResults.m_cSystemInfo.m_nContentId%>">
			<a class="SystemInfoTitle" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><i class="fas fa-bullhorn"></i></a>
			<a class="SystemInfoDate" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><%=(new SimpleDateFormat("yyyy MM/dd")).format(cResults.m_cSystemInfo.m_timeUploadDate)%></a>
			<a class="SystemInfoDesc" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><%=Util.toStringHtml(cResults.m_cSystemInfo.m_strDescription)%></a>
			<a class="SystemInfoClose" href="javascript:void(0)" onclick="$('#SystemInfo_<%=cResults.m_cSystemInfo.m_nContentId%>').hide();setCookie('<%=Common.POIPIKU_INFO%>', '<%=cResults.m_cSystemInfo.m_nContentId%>')"><i class="fas fa-times"></i></a>
		</div>
		<%}%>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper ThumbList">
			<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>

			<section id="IllustItemList" class="IllustItemList">
				<%if(!(cResults.followUserNum > 1 || cResults.m_nContentsNumTotal > 1)) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 20px 10px 20px 10px; text-align: center; box-sizing: border-box;">
					<%=_TEX.T("MyHome.FirstMsg")%>
					<br />
					<a class="BtnBase" href="/how_to/TopPcV.jsp"><%=_TEX.T("HowTo.Title")%></a>
				</div>
				<%}%>
			</section>
		</article>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
	<script>
		if (!('IntersectionObserver' in window)){
			document.body.classList.add('polyfill');
			console.log("use in polyfill");
		}
	</script>
	<script src="/js/polyfill/intersectionobserver.js"></script>
</html>