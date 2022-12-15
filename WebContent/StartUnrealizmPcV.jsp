<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
boolean isApp = false;

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

NewArrivalC cResults = new NewArrivalC();
cResults.selectMaxGallery = 10;
cResults.getParam(request);
cResults.getResults(checkLogin);

String strTitle = _TEX.T("THeader.Title");
String strDesc =  _TEX.T("THeader.Title.Desc");
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%if(!isApp){%>
	<%@ include file="/inner/THeaderCommonNoGenieePc.jsp"%>
	<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
	<%}else{%>
	<%@ include file="/inner/THeaderCommon.jsp"%>
	<%}%>

	<%@ include file="/inner/TSendEmoji.jsp"%>
	<%@ include file="/inner/TReplyEmoji.jsp"%>
	<%@ include file="/inner/TRetweetContent.jsp"%>
	<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

	<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
	<meta name="twitter:site" content="@pipajp" />
	<meta property="og:url" content="<%=Common.URL_ROOT%>" />
	<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
	<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
	<link rel="canonical" href="<%=Common.URL_ROOT%>" />
	<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=Common.URL_ROOT%>" />
	<title><%=Util.toDescString(strTitle)%></title>

	<script src="/js/masonry.pkgd.min.js"></script>
	<script src="/js/imagesloaded.pkgd.min.js"></script>

	<script type="text/javascript">
		<%if(!isApp){%>
		$(function(){
			$('#MenuNew').addClass('Selected');
		});
		<%}%>

		let initDone = false;
		let lastContentId = <%=cResults.contentList.size()>0 ? cResults.contentList.get(cResults.contentList.size()-1).m_nContentId : -1%>;
		let page = 0;

		const loadingSpinner = {
			appendTo: "#IllustItemList",
			className: "loadingSpinner",
		}
		const observer = createIntersectionObserver(addContents);

		function addContents() {
			appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
			return $.ajax({
				"type": "post",
				"data": {
					"PG": page,
					"CD": -1,
					"MD": <%=CCnv.MODE_SP%>,
					"VD": <%=CCnv.VIEW_DETAIL%>,
					"SD": lastContentId,
				},
				"dataType": "json",
				"url": "/f/NewArrivalF.jsp",
			}).then((data) => {
				page++;
				if (data.end_id > 0) {
					lastContentId = data.end_id;
					const contents = document.getElementById('IllustItemList');
					$(contents).append(data.html);

					let $newElems  = $('.IllustItem[style*="opacity: 0"]');
					<%if (!Common.isDevEnv()){ %>
					$('#IllustItemList').imagesLoaded(function(){
					<%}%>
					$newElems.animate({ opacity: 1 });
					$('#IllustItemList').masonry('appended', $newElems, true);

					setTimeout(()=>{
						observer.observe(contents.lastElementChild);
					}, 1000);

					<%if (!Common.isDevEnv()){ %>
					});
					<%}%>
				}
				removeLoadingSpinners(loadingSpinner.className);
			}, (error) => {
				DispMsg('Connection error');
			});
		}

		$(function(){
			$('#HeaderSearchWrapper').on('submit', SearchByKeyword('Contents', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
			$('#HeaderSearchBtn').on('click', SearchByKeyword('Contents', <%=checkLogin.m_nUserId%>, <%=Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId]%>));
			$('body, .Wrapper').each(function(index, element){
				$(element).on("drag dragstart",function(e){return false;});
			});
		});
	</script>

	<style>
	<%if (!isApp) {%>
	body {padding-top: 51px !important;}
	<%if (!bSmartPhone){%>
	.Wrapper.ThumbList {padding-top: 10px; width: 1180px;}
	<%}%>
	<%} else {%>
	body {padding-top: 0 !important;}
	<%}%>
	</style>

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
				$('#IllustItemList').masonry({
					itemSelector: '.IllustItem',
					columnWidth: _columnWidth,
					isFitWidth: true,
					gutterWidth: 0,
				});

				setTimeout(()=>{
					const contents = document.getElementById('IllustItemList');
					observer.observe(contents.lastElementChild);
				}, 1000)

				<%if (!Common.isDevEnv()){ %>
			});
			<%}%>
		});
	</script>

</head>

<body>
<%if (!isApp) {%>
<%@ include file="/inner/TMenuPc.jsp"%>
<nav class="TabMenuWrapper">
</nav>
<%} else {%>
<%@ include file="/inner/TMenuApp.jsp"%>
<%}%>

<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

<header class="StartPageTitle">
	<h2><%=_TEX.T("THeader.Title")%> - <span style="font-size: 14px"><%=_TEX.T("Catchphrase")%></span> -</h2>
<%--<span style="font-size: 12px; color: #808080"><%=_TEX.T("Unrealizm.Info.Message.Short")%></span>--%>
</header>

<article class="Wrapper ThumbList">

	<section
			id="IllustItemList"
			class="IllustItemList2Column"
			style="position: relative; top: 15px;"
	>
		<% for (int cnt = 0; cnt<cResults.contentList.size(); cnt++) { %>
		<%=CCnv.Content2Html2Column(cResults.contentList.get(cnt), checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>

		<% if (false){ %>
<%--		<% if (checkLogin.m_nPassportId==Common.PASSPORT_OFF && (cnt == 3 || cnt == 9) && bSmartPhone){ %>--%>
		<div class="IllustItem" style="width: 360px; height: 250px; background: none; border: none;">
			<%=Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter)%>
		</div>
		<%}%>

		<%}%>
	</section>
</article>
<%@ include file="/inner/TShowDetail.jsp"%>
</body>
<%@include file="/inner/PolyfillIntersectionObserver.jsp"%>
</html>
