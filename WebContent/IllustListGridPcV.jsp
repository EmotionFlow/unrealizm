<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

IllustListGridC cResults = new IllustListGridC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
String strUrl = "https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/";
String strTitle = _TEX.T("THeader.Title") + " - " + Common.ToStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName));
String strDesc = String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal);
String strFileUrl = cResults.m_cUser.m_strFileName;
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta name="twitter:description" content="<%=Util.toDescString(strDesc)%>" />
		<%if(!strFileUrl.isEmpty()) {%>
		<meta name="twitter:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>" />
		<%}%>
		<meta property="og:type" content="article" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<%if(!strFileUrl.isEmpty()) {%>
		<meta property="og:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>" />
		<%}%>
		<title><%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			<%if(cResults.m_bOwner) {%>
			$('#MenuMe').addClass('Selected');
			<%} else {%>
			$('#MenuSearch').addClass('Selected');
			<%}%>
			updateCategoryMenuPos(0);
		});

		$(function(){
			$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');
			<%if(!bSmartPhone) {%>
			$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Poipiku.Info.RegistNow")%>');
			<%}%>
			/*
			$(window).bind("scroll.slideHeader", function() {
				$('.UserInfo.Float').css('background-position-y', $(this).scrollTop()/5 + 'px');
			});
			*/
		});
		</script>

		<script>
		var g_nPage = 1;
		var g_strKeyword = '<%=cResults.m_strKeyword%>';
		var g_bAdding = false;
		function addContents() {
			if(g_bAdding) return;
			g_bAdding = true;
			var $objMessage = $("<div/>").addClass("Waiting");
			$("#IllustThumbList").append($objMessage);
			$.ajax({
				"type": "post",
				"data": {"ID": <%=cResults.m_nUserId%>, "KWD": g_strKeyword, "PG" : g_nPage, "MD" : <%=CCnv.MODE_PC%>},
				"url": "/f/IllustListGridF.jsp",
				"success": function(data) {
					if(data) {
						g_nPage++;
						$("#IllustThumbList").append(data);
						$(".Waiting").remove();
						if(vg)vg.vgrefresh();
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
			<%if(!cResults.m_bOwner) {%>
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
			<%}%>
			$(window).bind("scroll.addContents", function() {
				$(window).height();
				if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 600) {
					addContents();
				}
			});
		});
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		</style>


		<style>
			.IllustThumb .IllustInfo {bottom: 0; background: #fff;}
			.CategoryMenu {float: none;}
			#IllustThumbList {opacity: 0; float: none;}
			.IllustItem .IllustItemUser {display: none;}
		</style>
		<script type="text/javascript" src="/js/jquery.easing.1.3.js"></script>
		<script type="text/javascript" src="/js/jquery.vgrid.min.js"></script>
		<script>
		//setup
		$(function() {
			vg = $("#IllustThumbList").vgrid({
				easing: "easeOutQuint",
				useLoadImageEvent: true,
				useFontSizeListener: true,
				time: 1,
				delay: 1,
				wait: 1,
				fadeIn: {
					time: 1,
					delay: 1
				},
				onStart: function(){
					$("#message1")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				},
				onFinish: function(){
					$("#message2")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				}
			});
			//$(window).load(function(e){
				$("#IllustThumbList").css('opacity', 1);
				//vg.vgrefresh();
			//});
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper" style="width: 100%;">
			<div class="UserInfo Float">
				<div class="UserInfoBg"></div>
				<div class="UserInfoUser">
					<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
					<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
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
						<a class="BtnBase UserInfoCmdFollow" href="/MyEditSettingPcV.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyEditSetting.Title.Setting")%></a>
						<a class="BtnBase UserInfoCmdFollow" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
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
				</div>
				<span class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/<%=cResults.m_cUser.m_nUserId%>/">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
					</a>
					<%if(cResults.m_bOwner) {%>
					<a class="UserInfoStateItem" href="/FollowListPcV.jsp">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
					</a>
					<%}%>
				</span>
			</div>
		</article>

		<article class="Wrapper GridList">
			<%if(cResults.m_vCategoryList.size()>0) {%>
			<div id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(cResults.m_strKeyword.isEmpty()){%> Selected<%}%>" href="/<%=cResults.m_nUserId%>/"><%=_TEX.T("Category.All")%></a>
				<%for(CTag cTag : cResults.m_vCategoryList) {%>
				<a class="BtnBase CategoryBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strKeyword)){%> Selected<%}%>" href="/IllustListPcV.jsp?ID=<%=cResults.m_nUserId%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%}%>
			</div>
			<%}%>

			<div id="IllustThumbList" class="IllustThumbList">
				<%//if(!bSmartPhone) {%>
				<%//@ include file="/inner/TAdPc336x280_top_right.jsp"%>
				<%//}%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%//=CCnv.Thumb2Html(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_PC, _TEX)%>
					<%//if(nCnt==17) {%>
					<%//@ include file="/inner/TAdPc336x280_bottom_right.jsp"%>
					<%//}%>
				<%}%>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
		<%//@ include file="/inner/TFooter.jsp"%>
	</body>
</html>