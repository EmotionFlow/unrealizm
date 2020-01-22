<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

IllustViewC cResults = new IllustViewC();
cResults.getParam(request);
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
if(cResults.m_cContent.m_nPublishId!=Common.PUBLISH_ID_ALL && Util.isBot(request.getHeader("user-agent"))) {
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
switch(cResults.m_cContent.m_nPublishId) {
case Common.PUBLISH_ID_R15:
case Common.PUBLISH_ID_R18:
case Common.PUBLISH_ID_R18G:
case Common.PUBLISH_ID_PASS:
case Common.PUBLISH_ID_LOGIN:
case Common.PUBLISH_ID_FOLLOWER:
case Common.PUBLISH_ID_T_FOLLOWER:
case Common.PUBLISH_ID_T_FOLLOW:
case Common.PUBLISH_ID_T_EACH:
case Common.PUBLISH_ID_T_LIST:
	strFileUrl = Common.PUBLISH_ID_FILE[cResults.m_cContent.m_nPublishId];
	break;
case Common.PUBLISH_ID_ALL:
case Common.PUBLISH_ID_HIDDEN:
default:
	strFileUrl = cResults.m_cContent.m_strFileName;
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
	strTitle = "["+_TEX.T(String.format("Category.C%d", cResults.m_cContent.m_nCategoryId))+"] ";
	String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
	if(strs.length>0 && strs[0].length()>0) {
		strTitle += strs[0];
	} else {
		strTitle += cResults.m_cContent.m_cUser.m_strNickName;
	}
	break;
}
strTitle = Util.subStrNum(strTitle, 25) + " | " + _TEX.T("THeader.Title");
String strDesc = CTweet.generateIllustMsgBase(cResults.m_cContent, _TEX);
strDesc = Util.deleteCrLf(strDesc) + String.format(_TEX.T("Tweet.Title"), cResults.m_cContent.m_cUser.m_strNickName);
String strUrl = "https://poipiku.com/"+cResults.m_cContent.m_nUserId+"/"+cResults.m_cContent.m_nContentId+".html";
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta name="twitter:description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>_640.jpg" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<title><%=Util.toDescString(strTitle)%></title>
		<script type="application/ld+json">
		{
			"@context":"http://schema.org",
			"@type":"ItemList",
			"itemListElement":[
				{"@type":"ListItem", "position":1, "url":"<%=strUrl%>", "name": "<%=Util.toDescString(strTitle)%>", "image": "<%=Common.GetPoipikuUrl(strFileUrl)%>_640.jpg"}
			]
		}
		</script>

		<script type="text/javascript">
			$(function(){
				$('#MenuSearch').addClass('Selected');
			});
		</script>

		<script type="text/javascript">
			var g_nPage = 0;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustItemList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {
						"ID" : <%=cResults.m_cContent.m_nUserId%>,
						"TD" : <%=cResults.m_cContent.m_nContentId%>,
						"PG" : g_nPage,
						"MD" : <%=CCnv.MODE_PC%>,
						"ADF" : <%=cResults.m_cContent.m_nSafeFilter%>},
					"url": "/f/IllustViewF.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$("#IllustItemList").append(data);
							$(".Waiting").remove();
							g_bAdding = false;
							if(g_nPage>0) {
								console.log(location.pathname+'/'+g_nPage+'.html');
								gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
							}
						} else {
							$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

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

			function DeleteContent(nUserId, nContentId) {
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				DeleteContentBase(nUserId, nContentId);
				return false;
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
				<%if(!cResults.m_bOwner){%>
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				<%}%>
				addContents();
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
				$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');
				<%if(!Util.isSmartPhone(request)) {%>
				$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Poipiku.Info.RegistNow")%>');
				<%}%>
				/*
				$(window).bind("scroll.slideHeader", function() {
					$('.UserInfo.Float').css('background-position-y', $(this).scrollTop()/5 + 'px');
				});
				*/
			});
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>

		<%if(!Util.isSmartPhone(request)) {%>
		.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 81px;}
		.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
		.IllustItem.Password .IllustItemThumb {min-height: 240px;}
		<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%{%>
		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<section class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
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
						<%if(!cCheckLogin.m_bLogin) {%>
						<a id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
						<a id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" href="/"></a>
						<%} else if(cResults.m_bOwner) {%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>"><%=_TEX.T("IllustV.Following")%></span>
						<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" ></span>
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
						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
						</span>
					</span>
				</section>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/<%=cResults.m_cUser.m_nUserId%>/">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
					</a>
				</section>
			</div>
		</article>
		<%}%>

		<article class="Wrapper ViewPc">
			<section id="IllustItemList" class="IllustItemList">
				<%=CCnv.Content2Html(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL)%>
			</section>


			<%if(!bSmartPhone) {%>
			<aside class="PcSideBar" style="margin-top: 30px;">
				<div class="FixFrame">

					<div class="PcSideBarItem">
						<%@ include file="/inner/TAdPc300x250_top_right.jsp"%>
					</div>

					<div class="PcSideBarItem">
						<div class="UserInfo" style="border: none;">
							<div class="UserInfoBgImg"></div>
							<div class="UserInfoBg"></div>
							<div class="UserInfoUser">
								<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
								<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
								<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
								<span class="UserInfoCmd">
									<%if(!cCheckLogin.m_bLogin) {%>
									<a id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
									<%} else if(cResults.m_bOwner) {%>
									<%} else if(cResults.m_bBlocking){%>
									<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
									<%} else if(cResults.m_bBlocked){%>
									<%} else if(cResults.m_bFollow){%>
									<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
									<%} else {%>
									<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
									<%}%>
								</span>
							</div>
						</div>
					</div>
				</div>
			</aside>
			<%}%>
		</article>

		<%if(bSmartPhone) {%>
		<aside class="UserInfo">
			<div class="UserInfoBgImg"></div>
			<div class="UserInfoBg"></div>
			<section class="UserInfoUser">
				<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
				<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
				<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
				<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
				<%}%>
				<span class="UserInfoCmd">
					<%
					String strTwitterUrl=String.format("https://twitter.com/share?url=%s&text=%s&hashtags=%s",
							URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"),
							URLEncoder.encode(String.format("%s%s", cResults.m_cUser.m_strNickName, _TEX.T("Twitter.UserAddition")), "UTF-8"),
							URLEncoder.encode(_TEX.T("Common.Title"), "UTF-8"));
					%>
					<%if(!cCheckLogin.m_bLogin) {%>
					<a id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
					<a id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" href="/"></a>
					<%} else if(cResults.m_bOwner) {%>
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
						<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
					</span>
					<%}%>
				</span>
			</section>
		</aside>
		<%}%>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>