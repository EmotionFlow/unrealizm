<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
if(!Util.isSmartPhone(request)) {
	getServletContext().getRequestDispatcher("/IllustViewGridPcV.jsp").forward(request,response);
	return;
}

final String referer = Util.toString(request.getHeader("Referer"));
final boolean fromIllustList = referer.matches("^https://poipiku\\.com/[0-9]+/$");

IllustViewPcC cResults = new IllustViewPcC();
cResults.getParam(request);
cResults.selectMaxGallery = 0;
cResults.selectMaxRelatedGallery = 0;
cResults.selectMaxRecommendedGallery = 0;

final CheckLogin checkLogin = new CheckLogin(request, response);
if(!cResults.getResults(checkLogin)) {
	if (cResults.m_bBlocked || cResults.m_bBlocking) {
		response.sendRedirect(String.format("/%d/", cResults.ownerUserId));
	} else if (cResults.m_nNewContentId==null || cResults.m_nNewContentId==cResults.contentId) {
		response.sendRedirect("/NotFoundPcV.jsp");
	} else {
		response.sendRedirect(Common.GetPoipikuUrl(String.format("/%d/%d.html", cResults.ownerUserId, cResults.m_nNewContentId)));
	}
	return;
}

if(cResults.m_cContent.m_nPublishId!=Common.PUBLISH_ID_ALL && Util.isBot(request)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

// R18によるアドの切り替え
switch(cResults.m_cContent.m_nPublishId) {
case Common.PUBLISH_ID_R18:
case Common.PUBLISH_ID_R18G:
	g_nSafeFilter = Common.AD_ID_R18;
	break;
default:
	g_nSafeFilter = Common.AD_ID_ALL;
	break;
}

String strFileUrl = "";
boolean bHidden = false;	// テキスト用カバー画像表示フラグ
switch(cResults.m_cContent.m_nPublishId) {
	case Common.PUBLISH_ID_R15:
	case Common.PUBLISH_ID_R18:
	case Common.PUBLISH_ID_R18G:
	case Common.PUBLISH_ID_PASS:
	case Common.PUBLISH_ID_LOGIN:
	case Common.PUBLISH_ID_FOLLOWER:
	case Common.PUBLISH_ID_T_FOLLOWER:
	case Common.PUBLISH_ID_T_FOLLOWEE:
	case Common.PUBLISH_ID_T_EACH:
	case Common.PUBLISH_ID_T_LIST:
		if (cResults.m_cContent.publishAllNum == 0) {
			strFileUrl = Common.PUBLISH_ID_FILE[cResults.m_cContent.m_nPublishId];
			bHidden = true;
		} else {
			strFileUrl = cResults.m_cContent.m_strFileName + "_640.jpg";
			bHidden = false;
		}
		break;
	case Common.PUBLISH_ID_HIDDEN:
		strFileUrl="/img/poipiku_icon_512x512_2.png";
		break;
	case Common.PUBLISH_ID_ALL:
	default:
		if (cResults.m_cContent.m_strFileName.isEmpty()) {
			strFileUrl = "/img/poipiku_icon_512x512_2.png";
		} else {
			strFileUrl = cResults.m_cContent.m_strFileName + "_640.jpg";
		}
		break;
}

String strDesc = Util.deleteCrLf(cResults.m_cContent.title);
strDesc = (strDesc.isEmpty())?Util.deleteCrLf(cResults.m_cContent.m_strDescription):strDesc;
String strTitle = CTweet.generateState(cResults.m_cContent, _TEX) +  CTweet.generateFileNum(cResults.m_cContent, _TEX) + " " + Util.subStrNum(strDesc, 15) + " " + String.format(_TEX.T("Tweet.Title"), cResults.m_cContent.m_cUser.m_strNickName) + " | " + _TEX.T("THeader.Title");;
String strUrl = "https://poipiku.com/"+cResults.m_cContent.m_nUserId+"/"+cResults.m_cContent.m_nContentId+".html";
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
g_bShowAd = (cResults.m_cUser.m_nPassportId==Common.PASSPORT_OFF || cResults.m_cUser.m_nAdMode==CUser.AD_MODE_SHOW);
boolean bSmartPhone = Util.isSmartPhone(request);

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>
		<%@ include file="/inner/ad/TAdIllustViewPcHeader.jsp"%>
		<%@ include file="/inner/TCreditCard.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TSendEmojiReply.jsp"%>
		<%@ include file="/inner/TSendGift.jsp"%>

		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<%if(cResults.m_cContent.isTwitterCardThumbnail()){%>
		<meta name="twitter:card" content="summary_large_image" />
		<%}else{%>
		<meta name="twitter:card" content="summary" />
		<%}%>
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=CTweet.generateMetaTwitterTitle(cResults.m_cContent, _TEX)%>" />
		<meta name="twitter:description" content="<%=Util.toDescString(strDesc)%>" />
		<%if(cResults.m_cContent.isTwitterCardThumbnail()){%>
		<meta name="twitter:image" content="<%="https://img.poipiku.com" + strFileUrl%>" />
		<%}else{%>
		<meta name="twitter:image" content="https://img.poipiku.com/img/poipiku_icon_512x512_2.png" />
		<%}%>
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
				 <%if(cResults.m_cContent.isTwitterCardThumbnail()){%>
				 "image": "<%="https://img.poipiku.com" + strFileUrl%>"
				 <%}else{%>
				 "image": "https://poipiku.com/img/poipiku_icon_512x512_2.png"
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

			let lastContentId = <%=cResults.contentId%>;
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
					"url": "/<%=isApp?"api":"f"%>/GetContentsByUserF.jsp",
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
				<%if(!fromIllustList && cResults.contentId < cResults.latestContentId){%>
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
				<%if(!cResults.m_bOwner){%>
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				<%}%>
				$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');

				<%if(!bHidden && cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {%>
				const frame_height = $('#IllustItemText_'+ <%=cResults.m_cContent.m_nContentId%> ).height();
				const text_height = $('#IllustItemText_'+ <%=cResults.m_cContent.m_nContentId%> + ' .IllustItemThumbText').height();
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
			<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
			.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
			<%}%>
		</style>

		<%if(cResults.m_cUser.m_nPassportId>=Common.PASSPORT_ON && !cResults.m_cUser.m_strBgFileName.isEmpty()) {%>
		<style>
			body {
				background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strBgFileName)%>');
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
			<a href="/<%=cResults.ownerUserId%>/latest.html">
				<i class="fas fa-arrow-up"></i> <%=_TEX.T("IllustView.GoLatestBtn")%>
			</a>
		</div>
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<%{%>
		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<%@ include file="TUserInfo.jsp"%>
			</div>
		</article>
		<%}%>

		<article class="Wrapper ViewPc">
			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</span>
			<%}%>

			<section id="IllustItemList" class="IllustItemList">
				<%= CCnv.Content2Html(
						cResults.m_cContent, checkLogin.m_nUserId, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC,
						_TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW,
						cResults.m_bOwner ? CCnv.PageCategory.MY_ILLUST_LIST : CCnv.PageCategory.DEFAULT)%>
				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
				<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin-bottom: 17px;">
				<%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%>
				</span>
				<%}%>
				<hr class="IllustItemListSeparator">
			</section>

			<%//@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>

		</article>

		<%@ include file="/inner/TShowDetail.jsp"%>
		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
