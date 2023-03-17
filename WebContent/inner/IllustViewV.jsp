<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
final String referer = Util.toString(request.getHeader("Referer"));
final boolean fromIllustList = referer.matches("^https://poipiku\\.com/[0-9]+/$");

IllustViewPcC results = new IllustViewPcC();
results.getParam(request);
results.selectMaxGallery = 0;
results.selectMaxRelatedGallery = 0;
results.selectMaxRecommendedGallery = 0;

final CheckLogin checkLogin = new CheckLogin(request, response);
if(!results.getResults(checkLogin)) {
	if (results.m_bBlocked || results.m_bBlocking) {
		response.sendRedirect(String.format("/%d/", results.ownerUserId));
	} else if (results.m_nNewContentId==null || results.m_nNewContentId==results.contentId) {
		response.sendRedirect("/NotFoundV.jsp");
	} else {
		response.sendRedirect(Common.GetUnrealizmUrl(String.format("/%d/%d.html", results.ownerUserId, results.m_nNewContentId)));
	}
	return;
}

if(results.content.m_nPublishId!=Common.PUBLISH_ID_ALL && Util.isBot(request)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

// R18によるアドの切り替え
g_nSafeFilter = results.content.getAdSwitchId();

results.content.setThumb();
final String strFileUrl = results.content.thumbImgUrl;
final boolean bHidden = results.content.isHideThumbImg;	// テキスト用カバー画像表示フラグ

String strDesc = Util.deleteCrLf(results.content.title);
strDesc = (strDesc.isEmpty())?Util.deleteCrLf(results.content.m_strDescription):strDesc;

final String strTitle = CTweet.generateState(results.content, _TEX)
		+ CTweet.generateFileNum(results.content, _TEX)
		+ " " + Util.subStrNum(strDesc, 15)
		+ " " + results.content.m_strTagList
		+ " " + String.format(_TEX.T("Tweet.Title"), results.content.m_cUser.m_strNickName) + " | " + _TEX.T("THeader.Title");

String strUrl = "https://unrealizm.com/"+results.content.m_nUserId+"/"+results.content.m_nContentId+".html";
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
g_bShowAd = (results.m_cUser.m_nPassportId==Common.PASSPORT_OFF || results.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);

if (results.m_bRequestClient) {
	results.content.setRequestImgThumb();
}

//ツイッターカード用:作者の言語でツイッターカードを作るためのResourceBundleControl
ResourceBundleControl _TEX_TWEET = new ResourceBundleControl(SupportedLocales.findLocale(CacheUsers0000.getInstance().getUser(results.content.m_nUserId).langId));

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TCreditCard.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<%@ include file="/inner/TSendGift.jsp"%>

		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<%if(results.content.isTwitterCardThumbnail()){%>
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:image" content="<%="https://img.unrealizm.com" + strFileUrl%>" />
		<%}else{%>
		<meta name="twitter:card" content="summary" />
		<meta name="twitter:image" content="https://img.unrealizm.com/img/icon-512x512.png" />
		<%}%>
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=CTweet.generateMetaTwitterTitle(results.content, _TEX_TWEET)%>" />
		<meta name="twitter:description" content="<%=CTweet.generateMetaTwitterDesc(results.content, _TEX_TWEET)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<title><%=Util.toDescString(strTitle)%></title>
		<script type="application/ld+json">
		{
			"@context":"http://schema.org",
			"@type":"ItemList",
			"itemListElement":[
				{"@type":"ListItem", "position":1, "url":"<%=strUrl%>",
				"name": "<%=Util.toDescString(strTitle)%>",
				<%if(results.content.isTwitterCardThumbnail()){%>
				"image": "<%="https://img.unrealizm.com" + strFileUrl%>"
				<%}else{%>
				"image": "https://unrealizm.com/img/icon-512x512.png"
				<%}%>
				}
			]
		}
		</script>

		<script type="text/javascript">
			$(function(){
				$('#MenuNew').addClass('Selected');
				$(document).on('click', '.PrivateIcon', (ev) => {
					DispMsg("<%=_TEX.T("IllustView.IconMsg.Private")%>");
				});
				$(document).on('click', '.OutOfPeriodIcon', (ev) => {
					DispMsg("<%=_TEX.T("IllustView.IconMsg.OutOfPeriod")%>");
				});
			});

			let lastContentId = <%=results.contentId%>;
			let page = 0;

			const loadingSpinner = {
				appendTo: "#IllustItemList",
				className: "loadingSpinner",
			}
			const observer = createIntersectionObserver(addContents, {threshold: 0.5});

			function addContents(){
				appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
				return $.ajax({
					"type": "post",
					"data": {"SD": lastContentId, "MD": <%=CCnv.MODE_SP%>, "VD": <%=CCnv.VIEW_DETAIL%>, "PG": page},
					"dataType": "json",
					"url": "/<%=g_isApp?"api":"f"%>/GetContentsByUserF.jsp",
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
				<%if(!Util.isBot(request)){%>
				const contents = document.getElementById('IllustItemList');
				setTimeout(()=>{observer.observe(contents.lastElementChild);}, 1000);
				<%}%>
			}

			$(function(){
				initContents();
				<%if(!fromIllustList && results.contentId < results.latestContentId){%>
				const moveDist = 55;
				const $IllustViewGoLatestBtn = $("#IllustViewGoLatestBtn");
				setTimeout(()=>{
					$IllustViewGoLatestBtn.show();
					$IllustViewGoLatestBtn.animate({top: "+=" + moveDist + "px"}, 1000);
				}, 15000);
				setTimeout(()=>{
					$IllustViewGoLatestBtn.animate({top: "-=" + moveDist + "px"}, 500, 'linear', ()=>{
						$IllustViewGoLatestBtn.hide();
					});
				}, 20000);
				<%}%>
			});
			$(document).ready(function(){
				$('html,body').animate({ scrollTop: 0 }, 500);
			});
		</script>

		<%@ include file="/inner/TDeleteContent.jsp"%>
		<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>
		<script type="text/javascript">
			$(function(){
				<%if(!results.m_bOwner){%>
				$('body, .Wrapper').each(function(index, element){
					$(element).on("drag dragstart",function(e){return false;});
				});
				<%}%>
				$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(results.m_cUser.m_strNickName), results.m_nContentsNumTotal)%>');

				<%if(!bHidden && results.content.m_nEditorId==Common.EDITOR_TEXT) {%>
				const frame_height = $('#IllustItemText_'+ <%=results.content.m_nContentId%> ).height();
				const text_height = $('#IllustItemText_'+ <%=results.content.m_nContentId%> + ' .IllustItemThumbText').height();
				if(frame_height>=text_height) {
					$('.IllustItemExpandBtn').hide();
				}
				<%}%>
			});
		</script>

		<style>
			.IllustItemList.Related {margin-bottom: 6px;}
			.IllustItemList.Related .SearchResultTitle {height: auto; margin: 10px 0 0 0;}
			.IllustItemList.Related .SearchResultTitle .IllustItem {margin-bottom: 0;}
			.IllustItem .IllustItemUser {display: none;}
			<%if(!results.m_cUser.m_strHeaderFileName.isEmpty()){%>
			.UserInfo {background-image: url('<%=Common.GetUrl(results.m_cUser.m_strHeaderFileName)%>');}
			<%}%>
		</style>

		<%if(results.m_cUser.m_nPassportId>=Common.PASSPORT_ON && !results.m_cUser.m_strBgFileName.isEmpty()) {%>
		<style>
			body {
				background-image: url('<%=Common.GetUrl(results.m_cUser.m_strBgFileName)%>');
				background-repeat: repeat;
				background-position: 50% top;
				background-attachment: fixed;
			}
		</style>
		<%}%>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<div id="IllustViewGoLatestBtn" style="display: none;">
			<a href="/<%=results.ownerUserId%>/latest.html">
				<i class="fas fa-arrow-up"></i> <%=_TEX.T("IllustView.GoLatestBtn")%>
			</a>
		</div>

		<%{%>
		<article class="Wrapper" style="width: 100%;">
			<%@ include file="TUserInfo.jsp"%>
		</article>
		<%}%>

		<article class="Wrapper ViewPc">
			<section id="IllustItemList" class="IllustItemList">
				<%= CCnv.Content2Html(
						results.content, checkLogin, CCnv.MODE_SP,
						_TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW,
						results.m_bOwner ? CCnv.PageCategory.MY_ILLUST_LIST : CCnv.PageCategory.DEFAULT)%>
			</section>

			<%//@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>

		</article>

		<%@ include file="/inner/TFooter.jsp"%>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
</html>
