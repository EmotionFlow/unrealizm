<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request,response);
	return;
}

MyBookmarkC myBookmarkC = new MyBookmarkC();
myBookmarkC.getParam(request);
myBookmarkC.noContents = true;
if (g_isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
myBookmarkC.getResults(checkLogin, false);

MyBookmarkC results = new MyBookmarkC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>

		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyBookmarkList.Title")%></title>

		<%if(!g_isApp){%>
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
					"url": "/f/MyBookmarkList<%=g_isApp ? "App" : ""%>F.jsp",
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

			<%if(!g_isApp){%>
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

				<%if(!g_isApp){%>
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
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%if(!g_isApp){%>
		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a id="TabMenuMyHome" class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a id="TabMenuMyHomeTag" class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a id="TabMenuMyBookmark" class="TabMenuItem Selected" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>
		<%}%>

		<article class="Wrapper" style="padding-top: 28px">
			<%if(myBookmarkC.contentsNum <=0) {%>
			<div style="padding: 10px; box-sizing: border-box; text-align: center;">
				<%=_TEX.T("MyBookmarkList.LetsMessage")%>
			</div>
			<%}%>

			<section id="IllustThumbList" class="IllustItemList2Column" style="padding-bottom: 5px;">
			</section>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
