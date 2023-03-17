<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (g_isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

NewArrivalC results = new NewArrivalC();
results.selectMaxGallery = 10;
results.getParam(request);
results.getResults(checkLogin);

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
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>
		<meta name="description" content="<%=Util.toStringHtml(Util.deleteCrLf(description))%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="https://unrealizm.com/NewArrivalV.jsp" />
		<meta property="og:title" content="<%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%>" />
		<meta property="og:description" content="<%=Util.toDescString(description)%>" />

		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("NewArrivalPc.Title")%>(<%=categoryName%>)</title>

		<script src="/js/imagesloaded.pkgd.min.js"></script>

		<script type="text/javascript">
		<%if(!g_isApp){%>
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
				"url": "/f/NewArrivalF.jsp",
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

		<script>
			var _columnWidth = 180;

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
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<nav id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(results.categoryId<0){%> Selected<%}%>" href="/NewArrivalV.jsp"><%=_TEX.T("Category.All")%></a>
				<%for(int nCategoryId : Common.CATEGORY_ID) {%>
				<a class="BtnBase CategoryBtn CC<%=nCategoryId%> <%if(nCategoryId==results.categoryId){%> Selected<%}%>" href="/NewArrivalV.jsp?CD=<%=nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></a>
				<%}%>
			</nav>

			<%if(!categoryInfo.isEmpty() && results.page <=0) {%>
			<header class="CategoryInfo">
				<%=categoryInfo%>
			</header>
			<%}%>

			<section id="IllustItemList" class="IllustItemList2Column">
			<% for (CContent content: results.contentList) { %>
				<%=CCnv.Content2Html2Column(content, checkLogin, _TEX)%>
			<%}%>
			</section>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>
