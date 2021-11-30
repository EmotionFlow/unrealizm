<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/IllustViewGridPcV.jsp").forward(request,response);
	return;
}

IllustViewPcC cResults = new IllustViewPcC();
cResults.SELECT_MAX_GALLERY = 6;
cResults.getParam(request);

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
			});

			let lastContentId = <%=cResults.contentId%>;
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
				<%if(cResults.contentId < cResults.latestContentId){%>
				setTimeout(()=>{
					const $IllustViewGoLatestBtn = $("#IllustViewGoLatestBtn");
					$IllustViewGoLatestBtn.show();
					$IllustViewGoLatestBtn.animate({top: "+=57px"}, 1000);
				}, 9000);
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

		<style>
			#IllustViewGoLatestBtn {
                width: 240px;
                height: 22px;
                display: block;
                position: fixed;
                top: 0;
                left: calc(50% - 240px/2);
                background: rgba(52,152,218,0.9);
                padding: 4px;
                text-align: center;
                border: solid 1px #fff;
                border-radius: 20px;
				z-index: 100;
			}
		</style>
		<div id="IllustViewGoLatestBtn" style="display: none;">
			<a href="/<%=cResults.ownerUserId%>/latest.html">
				<i class="fas fa-arrow-up"></i> <%=_TEX.T("IllustView.GoLatestBtn")%>
			</a>
		</div>
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<%{%>
		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<%@ include file="IllustBrowserVGiftButton.jsp"%>
				<%@ include file="IllustVBlockButton.jsp"%>
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<%}%>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
								URLEncoder.encode(String.format("%s%s %s #%s",
										cResults.m_cUser.m_strNickName,
										_TEX.T("Twitter.UserAddition"),
										String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nContentsNumTotal),
										_TEX.T("Common.Title")), "UTF-8"),
								URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"));
						%>

						<%@ include file="TFollowButton.jsp"%>
						<%@ include file="IllustBrowserVRequestButton.jsp"%>

						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
						</span>
					</span>
				</section>
				<section class="UserInfoState">
					<%@include file="IllustBrowserVUserInfoState.jsp"%>
				</section>
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
				<%= CCnv.Content2Html(cResults.m_cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL)%>
				<style>
				hr.style14 {
                    border: 0;
                    height: 2px;
                    background-image: -webkit-linear-gradient(left, #3498da, #ecf5fb, #3498da);                    background-image: -moz-linear-gradient(left, #f0f0f0, #8c8b8b, #f0f0f0);
                    background-image: -ms-linear-gradient(left, #3498da, #ecf5fb, #3498da);
                    background-image: -o-linear-gradient(left, #3498da, #ecf5fb, #3498da);
                }
				</style>
				<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
				<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin-bottom: 17px;">
				<%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%>
				</span>
				<%}%>
				<hr class="style14">
			</section>

			<%//@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>

			<section id="IllustItemListRelatedUser" class="IllustItemList Related User">
				<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0; float: none;">
					<div class="IllustItem" style="background: rgba(255,255,255,0.90); margin: 0; width: 100%; border: none; border-radius: 0; min-height: auto;">
						<div class="IllustItemUser" style="padding: 6px 8px 6px 8px;">
							<a class="IllustItemUserThumb" href="/<%=cResults.m_cUser.m_nUserId%>/" style="background-image: url('<%=Common.GetUrl(cResults.m_cContent.m_cUser.m_strFileName)%>_120.jpg')"></a>
							<h2 class="IllustItemUserName">
								<a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=Util.toStringHtml(cResults.m_cContent.m_cUser.m_strNickName)%></a>
							</h2>
							<%@ include file="TFollowButton.jsp"%>
						</div>
					</div>
				</header>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
				<%}%>
			</section>
		</article>

		<%if(!cResults.m_vRelatedContentList.isEmpty()) {%>
		<%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%>
		<h2 class="IllustItemListRelatedTitle"><%=_TEX.T("IllustV.Related")%></h2>
		<article class="Wrapper GridList">
			<section class="IllustItemList Related Tag">
				<%for(CContent cContent: cResults.m_vRelatedContentList) {%>
				<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
				<%}%>
			</section>
		</article>
		<%}%>

		<%if (cResults.m_vRecommendedList.size() > 0) {%>
		<h2 class="IllustItemListRelatedTitle"><%=_TEX.T("IllustV.Recommended")%></h2>
		<article class="Wrapper GridList">
			<section class="IllustItemList Related Tag">
				<%for(CContent cContent: cResults.m_vRecommendedList) {%>
				<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
				<%}%>
			</section>
		</article>
		<%}%>

		<%@ include file="/inner/TShowDetail.jsp"%>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
