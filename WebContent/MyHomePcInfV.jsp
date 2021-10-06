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

cResults.m_bNoContents = true;
cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
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
			let lastContentId = -1;
			let page = 0;

			const loadingSpinner = {
				appendTo: "#IllustItemList",
				className: "loadingSpinner",
			}
			const htmlCache = new CacheApiHtmlCache(CURRENT_CACHES_INFO.MyHomeContents, <%=checkLogin.m_nUserId%>);
			const observer = createIntersectionObserver(addContents);

			function addContents(){
				appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
				return $.ajax({
					"type": "post",
					"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page},
					"dataType": "json",
					"url": "/f/MyHomeF.jsp",
				}).then((data) => {
					page++;
					htmlCache.header.page = page;
					if (data.end_id > 0) {
						lastContentId = data.end_id;
						htmlCache.header.lastContentId = lastContentId;
						const contents = document.getElementById('IllustItemList');
						$(contents).append(data.html);
						//gtag('config', 'UA-125150180-1', {'page_location': location.pathname + '/' + g_nEndId + '.html'});
						observer.observe(contents.lastElementChild);
					}
					removeLoadingSpinners(loadingSpinner.className);
				}, (error) => {
					DispMsg('Connection error');
				});
			}

			function restoreContents(txt){
				if (Date.now() - htmlCache.header.updatedAt > htmlCache.maxAge) {
					htmlCache.delete(null);
					addContents().then(()=>{$(".ThumbListHeader").show();});
				} else {
					appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
					const contents = document.getElementById('IllustItemList');
					$(contents).empty().html(txt);
					removeLoadingSpinners(loadingSpinner.className);
					$(window).scrollTop(htmlCache.header.scrollTop);
					lastContentId = htmlCache.header.lastContentId;
					page = htmlCache.header.page;
					observer.observe(contents.lastElementChild);
					htmlCache.delete(null);
					$(".ThumbListHeader").show();
				}
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){if(!$(e.target).is(".MyUrl")){return false;}}
				)});

				htmlCache.addClickEventListener(
					'#HeaderSearchBtn, .SystemInfo a, .slick-list a, ' +
					'#TabMenuMyHomeTag, #TabMenuMyBookmark, ' +
					'a.IllustItemThumb, .IllustItemDesc a, .IllustItemCategory a, .IllustItemUser a, .IllustItemCommandEdit, .IllustItemTag a, ' +
					'#MenuNew, #MenuRequest, #MenuAct, #MenuMe',
					'#IllustItemList'
				);

				htmlCache.pull(restoreContents, initContents);

				if ((Math.random() * 50) | 0 === 0){
					deleteOldVersionCache();
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
				<li><a id="TabMenuMyHome" class="TabMenuItem Selected" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a id="TabMenuMyHomeTag" class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a id="TabMenuMyBookmark" class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>

		<div class="ThumbListHeader" style="display: none">
		<%if(cResults.m_cSystemInfo!=null) {%>
		<div class="SystemInfo" id="SystemInfo_<%=cResults.m_cSystemInfo.m_nContentId%>">
			<a class="SystemInfoTitle" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><i class="fas fa-bullhorn"></i></a>
			<a class="SystemInfoDate" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><%=(new SimpleDateFormat("yyyy MM/dd")).format(cResults.m_cSystemInfo.m_timeUploadDate)%></a>
			<a class="SystemInfoDesc" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><%=Util.toStringHtml(cResults.m_cSystemInfo.m_strDescription)%></a>
			<a class="SystemInfoClose" href="javascript:void(0)" onclick="$('#SystemInfo_<%=cResults.m_cSystemInfo.m_nContentId%>').hide();setCookie('<%=Common.POIPIKU_INFO%>', '<%=cResults.m_cSystemInfo.m_nContentId%>')"><i class="fas fa-times"></i></a>
		</div>
		<%}%>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		</div>

		<article class="Wrapper ThumbList">
			<div class="ThumbListHeader" style="display: none">
			<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
			</div>

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
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>