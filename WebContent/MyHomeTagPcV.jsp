<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/MyHomeTagGridPcV.jsp").forward(request,response);
	return;
}

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

MyHomeTagPcC cResults = new MyHomeTagPcC();
cResults.getParam(request);
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
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<script>
			let lastContentId = -1;
			let page = 0;

			const loadingSpinner = {
				appendTo: "#IllustItemList",
				className: "loadingSpinner",
			}
			const htmlCache = new CacheApiHtmlCache(CURRENT_CACHES_INFO.MyHomeTagContents, <%=checkLogin.m_nUserId%>);
			const observer = createIntersectionObserver(addContents);

			function addContents(){
				appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
				return $.ajax({
					"type": "post",
					"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page},
					"dataType": "json",
					"url": "/f/MyHomeTagF.jsp",
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

			function initContents(){
				$(window).scrollTop(0);
				$(".ThumbListHeader").show();
				addContents();
			}

			function restoreContents(txt){
				if (Date.now() - htmlCache.header.updatedAt > htmlCache.maxAge) {
					htmlCache.delete(null);
					addContents().then(()=>{$(".ThumbListHeader").show();})
				} else {
					appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
					const contents = document.getElementById('IllustItemList');
					$(contents).empty().html(txt);
					removeLoadingSpinners(loadingSpinner.className);
					$(".ThumbListHeader").show();
					$(window).scrollTop(htmlCache.header.scrollTop);
					lastContentId = htmlCache.header.lastContentId;
					page = htmlCache.header.page;
					observer.observe(contents.lastElementChild);
					htmlCache.delete(null);
				}
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){if(!$(e.target).is(".MyUrl")){return false;}}
					)});

				htmlCache.addClickEventListener(
					'#HeaderSearchBtn, .SystemInfo a, .slick-list a, ' +
					'#TabMenuMyHome, #TabMenuMyBookmark, ' +
					'a.IllustItemThumb, .IllustItemDesc a, .IllustItemCategory a, .IllustItemUser a, .IllustItemCommandEdit, .IllustItemTag a, ' +
					'#MenuHome, #MenuNew, #MenuRequest, #MenuAct, #MenuMe',
					'#IllustItemList'
				);

				htmlCache.pull(restoreContents, initContents);
			});
		</script>

		<style>
			body {padding-top: 79px !important;}
			<%if(!Util.isSmartPhone(request)) {%>
			.Wrapper.ViewPc {flex-flow: row-reverse wrap;}
			.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 113px;}
			.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
			<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a id="TabMenuMyHome" class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a></li>
				<li><a id="TabMenuMyHomeTag" class="TabMenuItem Selected" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a></li>
				<li><a id="TabMenuMyBookmark" class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a></li>
			</ul>
		</nav>

		<div class="ThumbListHeader" style="display: none">
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		</div>

		<article class="Wrapper ViewPc">
			<div class="ThumbListHeader" style="display: none">
			<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
			</div>

			<div style="width: 100%; box-sizing: border-box; padding: 10px 15px 0 15px; font-size: 16px; text-align: right;">
				<a href="/MyHomeTagSettingPcV.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyHomeTagSetting.Title")%></a>
			</div>

			<section id="IllustItemList" class="IllustItemList">
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div style="margin-top:30px; text-align: center;">
					<h3><%=_TEX.T("FollowingTag.Info01")%></h3>
					<div style="text-decoration: underline; margin-top: 15px;">
						<a class="FooterLink" href="https://poipiku.com/SearchTagByKeywordPcV.jsp"><%=_TEX.T("FollowingTag.Link01")%></a>
					</div>
					<div style="text-decoration: underline; margin-top: 15px;">
						<a class="FooterLink" href="https://poipiku.com/PopularTagListPcV.jsp"><%=_TEX.T("FollowingTag.Link02")%></a>
					</div>
				</div>
				<%}%>

				<%if(cResults.m_nContentsNumTotal<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 150px 10px 50px 10px; text-align: center; box-sizing: border-box;">
					<%=_TEX.T("MyHomeTag.FirstMsg")%>
				</div>
				<%}%>
			</section>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>