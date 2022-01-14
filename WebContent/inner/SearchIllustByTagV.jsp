<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/SearchIllustByTagGridPcV.jsp").forward(request,response);
	return;
}

if (isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

SearchIllustByTagC results = new SearchIllustByTagC();
results.getParam(request);
results.selectMaxGallery = 10;
results.getResults(checkLogin);

final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

URLEncoder.encode(results.keyword, "UTF-8");
final String strTitle = String.format(_TEX.T("SearchIllustByTag.Title"), results.keyword) + " | " + _TEX.T("THeader.Title");
final String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), results.keyword, results.contentsNum);
final String strUrl = "https://poipiku.com/SearchIllustByTagPcV.jsp?GD="+results.genreId;

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>

		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<%if(!isApp){%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<%}%>

		<title><%=_TEX.T("THeader.Title")%> - <%=Util.toDescString(strTitle)%></title>

		<%if(!results.genre.genreImageBg.isEmpty()) {%>
		<style>
			.SearchGenreFrame {background-image:url('<%=Common.GetUrl(results.genre.genreImageBg)%>');}
		</style>
		<%}%>
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
					"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page, "KWD": "<%=results.keyword.replaceAll("\"","\\\"")%>"},
					"dataType": "json",
					"url": "/<%=isApp?"api":"f"%>/SearchIllustByTagF.jsp",
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
				initContents();
			});
			$(document).ready(function(){
				$('html,body').animate({ scrollTop: 0 }, 500);
			});

		</script>
		<%if (!isApp) {%>
		<style>body {padding-top: 79px !important;}</style>
		<%} else {%>
		<style>body {padding-top: 0 !important;}</style>
		<%}%>
	</head>

	<body>
		<%if (!isApp) {%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%} else {%>
		<%@ include file="/inner/TMenuApp.jsp"%>
		<%}%>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		<header class="SearchGenreFrame">
			<div class="SearchGenre">
				<div class="SearchEdit">
					<a class="SearchEditCmd PoiPassInline" href="/EditGenreInfoPcV.jsp?ID=<%=checkLogin.m_nUserId%>&GD=<%=results.genre.genreId%>"><i class="fas fa-pencil-alt"></i> <%=_TEX.T("SearchIllustByGenre.Edit")%></a>
				</div>
				<div class="SearchGenreMeta">
					<div class="SearchGenreTitle">
						<span class="GenreImage" style="background-image: url('<%=Common.GetUrl(results.genre.genreImage)%>');" ></span>
						<h2 class="GenreTitle">#<%=Util.toStringHtml(results.genre.genreName)%></h2>
					</div>
					<div class="SearchGenreDesc"><%=Util.toStringHtml(results.genre.genreDesc)%></div>
				</div>
				<div class="SearchGenreCmd">
					<%if(!checkLogin.m_bLogin) {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow" href="/"><i class="fas fa-tag"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
					<%} else if(!results.following) {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.Follow")%></a>
					<%} else {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(results.keyword)%>')"><i class="far fa-star"></i> <%=_TEX.T("IllustV.Tag.UnFollow")%></a>
					<%}%>
				</div>
			</div>
			<div class="SearchGenreDetail showmore"><%=Common.AutoLinkHtml(Util.toStringHtml(results.genre.genreDetail), CCnv.SP_MODE_WVIEW)%></div>
		</header>

		<article class="Wrapper ThumbList">
			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</span>
			<%}%>

			<section id="IllustItemList" class="IllustItemList">
				<% for (int cnt=0; cnt<results.contentList.size(); cnt++) { %>
				<%=CCnv.Content2Html(results.contentList.get(cnt), checkLogin.m_nUserId, bSmartPhone ? CCnv.MODE_SP : CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
				<% if ((cnt == 2 || cnt == 7) && bSmartPhone){ %>
				<%=Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter)%>
				<%}%>
				<%}%>
			</section>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
	<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>
