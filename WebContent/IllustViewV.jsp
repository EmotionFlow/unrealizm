<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

IllustViewPcC cResults = new IllustViewPcC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	if(cResults.m_nNewContentId==null || cResults.m_nNewContentId==cResults.m_nContentId) {
		response.sendRedirect("/NotFoundV.jsp");
	}else{
		response.sendRedirect(Common.GetPoipikuUrl(String.format("/IllustViewV.jsp?ID=%d&TD=%d", cResults.m_nUserId, cResults.m_nNewContentId)));
	}
	return;
}
if(Util.isBot(request)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

//R18によるアドの切り替え
switch(cResults.m_cContent.m_nPublishId) {
case Common.PUBLISH_ID_R18:
case Common.PUBLISH_ID_R18G:
	g_nSafeFilter = Common.AD_ID_R18;
	break;
default:
	g_nSafeFilter = Common.AD_ID_ALL;
	break;
}

String strTitle = "";
switch(cResults.m_cContent.m_nPublishId) {
case Common.PUBLISH_ID_PASS:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.Pass.Title");
	break;
case Common.PUBLISH_ID_LOGIN:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.Login");
	break;
case Common.PUBLISH_ID_FOLLOWER:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.Follower");
	break;
case Common.PUBLISH_ID_T_FOLLOWER:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.T_Follower");
	break;
case Common.PUBLISH_ID_T_FOLLOW:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.T_Follow");
	break;
case Common.PUBLISH_ID_T_EACH:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.T_Each");
	break;
case Common.PUBLISH_ID_T_LIST:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.T_List");
	break;
case Common.PUBLISH_ID_HIDDEN:
	strTitle = _TEX.T("UploadFilePc.Option.Publish.Hidden");
	break;
case Common.PUBLISH_ID_ALL:
case Common.PUBLISH_ID_R15:
case Common.PUBLISH_ID_R18:
case Common.PUBLISH_ID_R18G:
default:
	strTitle = cResults.m_cContent.m_cUser.m_strNickName;
	String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
	if(strs.length>0 && strs[0].length()>0) {
		strTitle = strs[0];
	}
	break;
}
strTitle = Common.SubStrNum(strTitle, 10);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/ad/TAdIllustViewPcHeader.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<title><%=strTitle%></title>

		<%@ include file="/inner/TDeleteContent.jsp"%>

		<script type="text/javascript">
			function UpdateFollow(nUserId, nFollowUserId) {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": nUserId, "IID": nFollowUserId },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow_'+nFollowUserId).addClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Following")%>");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow_'+nFollowUserId).removeClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Follow")%>");
						} else {
							DispMsg('フォローできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function UpdateBlock() {
				var bBlocked = $("#UserInfoCmdBlock").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bBlocked)?0:1 },
					"url": "/f/UpdateBlockF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdBlock').addClass('Selected');
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('.UserInfoCmdFollow').hide();
							location.reload(true);
						} else if(data.result==2) {
							$('.UserInfoCmdBlock').removeClass('Selected');
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
							$('.UserInfoCmdFollow').show();
							location.reload(true);
						} else {
							DispMsg('ブロックできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
			});
		</script>

		<link href="/js/slick/slick-theme.css" rel="stylesheet" type="text/css">
		<link href="/js/slick/slick.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="/js/slick/slick.min.js"></script>
		<script>
		$(function(){
			$('.EventItemList').slick({
				autoplay:true,
				autoplaySpeed:3000,
				dots:true,
				infinite: true,
				slidesToShow: 1,
				variableWidth: true,
				centerMode: true,
				centerPadding: '10px',
			});
		});
		</script>
		<style>
			.IllustItemList.Related {margin-bottom: 6px;}
			.IllustItemList.Related .SearchResultTitle {height: auto; margin: 10px 0 0 0; line-height: normal;}
			.IllustItemList.Related .SearchResultTitle .Keyword {display: block;}
			.IllustItemList.Related .SearchResultTitle .IllustItem {margin-bottom: 0;}
			.IllustItemList.Related .AutoLink {display: block; float: left; background-color: #fff; color: #5bd; font-size: 15px; line-height: 34px; padding: 0 18px; margin: 4px 2px 0 2px; border-radius: 6px;}
			.FooterAd {display: block; float: left; width: 100%; margin: 0 auto; box-sizing: border-box;}
			.FooterAd .SideBarMid {isplay: block; float: left; width: 100%; height: auto;}
					<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
			.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
			<%}%>
		</style>
	</head>

	<body>
		<%{%>
		<article class="Wrapper">
			<div class="UserInfo">
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"></a>
					<h2 class="UserInfoUserName"><a href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_SP)%></h3>
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
						<%if(cResults.m_bOwner) {%>
						&nbsp;
						<%} else if(cResults.m_bBlocking){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
						<%} else if(cResults.m_bBlocked){%>
						<%} else if(cResults.m_bFollow){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock " onclick="UpdateBlock()"></span>
						<%} else {%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" onclick="UpdateBlock()"></span>
						<%}%>
						<%if(!cResults.m_bOwner) {%>
						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>"></a>
						</span>
						<%}%>
					</span>
				</section>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
					</a>
				</section>
			</div>
		</article>
		<%}%>

		<article class="Wrapper ViewPc">
			<section id="IllustItemList" class="IllustItemList">
				<%=CCnv.Content2Html(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
			</section>

			<%@ include file="/inner/TAdEvent_top_rightV.jsp"%>
		</article>

		<article class="Wrapper GridList">
			<section id="IllustItemList" class="IllustItemList Related">
				<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0; float: none;">
					<div class="IllustItem ">
						<div class="IllustItemUser">
							<a class="IllustItemUserThumb" href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>" style="background-image: url('<%=Common.GetUrl(cResults.m_cContent.m_cUser.m_strFileName)%>_120.jpg')"></a>
							<h2 class="IllustItemUserName">
								<a href="/IllustListAppV.jsp?ID=<%=cResults.m_cUser.m_nUserId%>"><%=Util.toStringHtml(cResults.m_cContent.m_cUser.m_strNickName)%></a>
							</h2>
							<span id="UserInfoCmdFollow"
								class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> <%=(cResults.m_cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?" Selected":""%>"
								onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=(cResults.m_cContent.m_cUser.m_nFollowing==CUser.FOLLOW_FOLLOWING)?_TEX.T("IllustV.Following"):_TEX.T("IllustV.Follow")%></span>
						</div>
					</div>
				</header>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
				<%}%>
			</section>
		</article>

		<%if(!cResults.m_vRelatedContentList.isEmpty()) {%>
		<article class="Wrapper GridList">
			<section id="IllustItemList" class="IllustItemList Related">
				<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px; float: none;">
					<h2 class="Keyword">
						<%
							String keyword = RelatedContents.getTitleTag(cResults.m_cContent.m_nContentId);
						%>
						<a class="AutoLink" href="/SearchIllustByTagV.jsp?KWD=<%=URLEncoder.encode(keyword, "UTF-8")%>">#<%=keyword%></a>
					</h2>
				</header>
				<%for(int nCnt=0; nCnt<cResults.m_vRelatedContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vRelatedContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
				<%}%>
			</section>
		</article>
		<%}%>

		<aside class="Wrapper GridList">
			<%@ include file="/inner/ad/TAdSingleAdSpFooter.jsp"%>
		</aside>
	</body>
</html>