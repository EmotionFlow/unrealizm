<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
if (isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

NewArrivalC results = new NewArrivalC();
results.selectMaxGallery = 10;
results.getParam(request);
results.getResults(checkLogin);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

final String description = "";
final String categoryName = "";
final String categoryInfo = "";
//if(results.categoryId >= 0) {
//	categoryName = _TEX.T(String.format("Category.C%d", results.categoryId));
//	categoryInfo = _TEX.T(String.format("Category.C%d.Info", results.categoryId)).trim();
//	if(!categoryInfo.isEmpty()) {
//		description = categoryInfo;
//	} else {
//		description = _TEX.T("THeader.Title.Desc");
//	}
//} else {
//	categoryName = _TEX.T("Category.All");
//	categoryInfo = "";
//	description = _TEX.T("THeader.Title.Desc");
//}

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoGenieePc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommonNoGenieePc.jsp"%>
		<%}%>

		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(Util.deleteCrLf(description))%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="https://unrealizm.com/NewArrivalPcV.jsp" />
		<meta property="og:title" content="<%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%>" />
		<meta property="og:description" content="<%=Util.toDescString(description)%>" />

		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%>(<%=categoryName%>)</title>

		<script src="/js/imagesloaded.pkgd.min.js"></script>

		<script type="text/javascript">
		<%if(!isApp){%>
		$(function(){
			$('#MenuNew').addClass('Selected');
			$('#MenuRecent').addClass('Selected');
		});
		<%}%>

		let lastContentId = <%=results.contentList.size()>0 ? results.contentList.get(results.contentList.size()-1).m_nContentId : -1%>;
		let page = 0;

		const loadingSpinner = {
			appendTo: "#IllustItemList",
			className: "loadingSpinner",
		}
		const observer = createIntersectionObserver(addContents);

		function addContents(){
			appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
			return $.ajax({
				"type": "post",
				"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page, "CD": <%=results.categoryId%>},
				"dataType": "json",
				"url": "/<%=isApp?"api":"f"%>/NewArrivalF.jsp",
			}).then((data) => {
				page++;
				if (data.end_id > 0) {
					lastContentId = data.end_id;
					const contents = document.getElementById('IllustItemList');
					$(contents).append(data.html);
					observer.observe(contents.lastElementChild);
					let $newElems  = $('.IllustItem[style*="opacity: 0"]');
					<%if (!Common.isDevEnv()){ %>
					$('#IllustItemList').imagesLoaded(function(){
						<%}%>
						$newElems.animate({ opacity: 1 });
//						$('#IllustItemList').masonry('appended', $newElems, true);
						<%if (!Common.isDevEnv()){ %>
					});
					<%}%>
				}
				removeLoadingSpinners(loadingSpinner.className);
			}, (error) => {
				DispMsg('Connection error');
			});
		}

		function initContents(){
			const contents = document.getElementById('IllustItemList');
			observer.observe(contents.lastElementChild);
		}

		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("drag dragstart",function(e){return false;});
			});
			updateCategoryMenuPos(0);
			initContents();
		});
		$(document).ready(function(){
			$('html,body').animate({ scrollTop: 0 }, 500);
		});

		</script>
		<%if (!isApp) {%>
		<style>body {padding-top: 51px !important;}</style>
		<%} else {%>
		<style>body {padding-top: 0 !important;}</style>
		<%}%>

		<script>
			var _columnWidth = 180;
			<%if (!isApp && !bSmartPhone) {%>
			_columnWidth = 236;
			<%}%>

			$(function () {
				<%if (!Common.isDevEnv()){ %>
				$('#IllustItemList').imagesLoaded(function(){
					<%}%>
					let $newElems = $('.IllustItem, .loadingSpinner');
					$newElems.animate({ opacity: 1 });
//					$('#IllustItemList').masonry({
//						itemSelector: '.IllustItem',
//						columnWidth: _columnWidth,
//						isFitWidth: true,
//						gutterWidth: 0,
//					});
					<%if (!Common.isDevEnv()){ %>
				});
				<%}%>
			});
		</script>
	</head>

	<body>
		<%if (!isApp) {%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%} else {%>
		<%@ include file="/inner/TMenuApp.jsp"%>
		<%}%>

		<article class="Wrapper ThumbList">
			<nav id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(results.categoryId<0){%> Selected<%}%>" href="/NewArrival<%=isApp?"App":"Pc"%>V.jsp"><%=_TEX.T("Category.All")%></a>
				<%for(int nCategoryId : Common.CATEGORY_ID) {%>
				<a class="BtnBase CategoryBtn CC<%=nCategoryId%> <%if(nCategoryId==results.categoryId){%> Selected<%}%>" href="/NewArrival<%=isApp?"App":"Pc"%>V.jsp?CD=<%=nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></a>
				<%}%>
			</nav>

			<%if(!categoryInfo.isEmpty() && results.page <=0) {%>
			<header class="CategoryInfo">
				<%=categoryInfo%>
			</header>
			<%}%>

			<section id="IllustItemList" class="IllustItemList2Column">
			<% for (int cnt=0; cnt<results.contentList.size(); cnt++) { %>
				<%=CCnv.Content2Html2Column(results.contentList.get(cnt), checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
			<%}%>
			</section>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>
