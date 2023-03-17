<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (g_isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

SearchIllustByTagC results = new SearchIllustByTagC();
results.getParam(request);
results.selectMaxGallery = 10;
results.getResults(checkLogin, true);

final String tagName = (results.transTagName != null && !results.transTagName.isEmpty()) ? results.transTagName : results.keyword;
final String strTitle = String.format(_TEX.T("SearchIllustByTag.Title"), tagName);
final String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc.Short"), tagName);
final String strUrl = "https://unrealizm.com/SearchIllustByTagV.jsp?GD="+results.genreId;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />

		<title><%=_TEX.T("THeader.Title")%> - <%=Util.toDescString(strTitle)%></title>

		<%if(!results.genre.genreImageBg.isEmpty()) {%>
		<style>
			.SearchGenreFrame {background-image:url('<%=Common.GetUrl(results.genre.genreImageBg)%>');}
		</style>
		<%}%>
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
					"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page, "KWD": "<%=results.keyword.replaceAll("\"","\\\"")%>"},
					"dataType": "json",
					"url": "/f/SearchIllustByTagF.jsp",
				}).then((data) => {
					page++;
					if (data.end_id > 0) {
						lastContentId = data.end_id;
						const contents = document.getElementById('IllustItemList');
						$(contents).append(data.html);
						observer.observe(contents.lastElementChild);
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
				initContents();
			});
			$(document).ready(function(){
				$('html,body').animate({ scrollTop: 0 }, 500);
			});

		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<header class="SearchGenreFrame">
			<div class="SearchGenre">
				<div class="SearchGenreMeta">
					<div class="SearchGenreTitle">
						<div class="GenreName">
							<h2 class="GenreNameOrg">#<%=Util.toStringHtml(results.genre.genreName)%></h2>
						</div>
					</div>
					<div class="SearchGenreCmd">
						<%if(!checkLogin.m_bLogin) {%>
						<a class="CmdBtn BtnBase TitleCmdFollow" href="/"><i class="fas fa-tag"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
						<%} else if(!results.following) {%>
						<a class="CmdBtn BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
						<%} else {%>
						<a class="CmdBtn BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.UnFollow")%></a>
						<%}%>
					</div>
				</div>
			</div>
		</header>

		<article class="Wrapper">
			<section id="IllustItemList" class="IllustItemList2Column">
				<%for (CContent content: results.contentList) {%>
				<%=CCnv.Content2Html2Column(content, checkLogin, _TEX)%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>
