<%@page import="jp.pipa.poipiku.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%if(!checkLogin.m_bLogin){%>
<script>
function dispTwLoginUnsuccessfulInfo(callbackPath){
	Swal.fire({
		html: '<h2><%=_TEX.T("TMenu.TwLoginUnsuccessfulInfo.Title")%></h2>' +
			'<div style="text-align: left; font-size: 13px"><p><%=_TEX.T("TMenu.TwLoginUnsuccessfulInfo.Info01")%><p>' +
			'<p style="text-align: left; font-size: 13px"><%=_TEX.T("TMenu.TwLoginUnsuccessfulInfo.Info02")%><p></div>',
		showCancelButton: false,
		showCloseButton: true,
		confirmButtonText: '<i class="typcn typcn-social-twitter"></i> <%=_TEX.T("TMenu.TwLoginUnsuccessfulInfo.Button")%>',
	}).then((result) => {
		if (result.value) {
			location.href = "/LoginFormTwitter.jsp?AUTH=authorize&CBPATH=" + callbackPath;
		}
	});
}
</script>
<%}%>

<header class="Header">
	<div id="HeaderSlider"></div>
	<div class="HeaderWrapper">
		<div id="HeaderTitleWrapper" class="HeaderTitleWrapper">
			<h1 class="HeaderTitle">
				<a id="HeaderLink" class="HeaderLink" href="/">
					<img  class="HeaderImg" src="//img.poipiku.com/img/pc_top_title-03.png" alt="<%=_TEX.T("THeader.Title")%>" />
				</a>
			</h1>
			<%if(Util.isSmartPhone(request)) {
				if(!checkLogin.m_bLogin) {%>
				<form method="post" name="login_from_twitter_tmenupc_00" action="/LoginFormTwitter.jsp">
					<input id="login_from_twitter_tmenupc_callback_00" type="hidden" name="CBPATH" value=""/>
					<script>{
						let s = document.URL.split("/");
						for(let i=0; i<3; i++){s.shift();}
						$('#login_from_twitter_tmenupc_callback_00').val("/" + s.join("/"));
					}</script>
					<a class="BtnBase Rev HeaderLoginBtn LoginButton" style="right: 126px; width: 96px;" href="javascript:login_from_twitter_tmenupc_00.submit()">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login.Short")%>
					</a>
				</form>
				<div class="TwLoginUnsuccessfulIcon" onclick="dispTwLoginUnsuccessfulInfo($('#login_from_twitter_tmenupc_callback_00').val())">
					<i class="fas fa-info-circle" style="font-size: 19px; padding: 5px;"></i>
				</div>
				<div class="HeaderSelectLang" onclick="showSelectLangDlg(false);">
					<i class="fas fa-globe" style="font-size: 19px; padding: 5px;"></i>
				</div>
			<%} else {%>
				<a id="MenuSearch" class="HeaderTitleSearch fas fa-search" href="javascript:void(0);" onclick="showSearch()"></a>
				<a id="MenuMyRequests" style="display: none; <%=Util.isSmartPhone(request)?"position: absolute;":""%>" href="/MyRequestListPcV.jsp?MENUID=MENUROOT">
					<span class="MenuMyRequestsIcon"></span>
					<span class="MenuMyRequestsName"><%=_TEX.T("Request.MyRequests")%></span>
				</a>
				<a id="MenuSwitchUser" style="display: none; <%=Util.isSmartPhone(request)?"position: absolute;":""%>" href="javascript: void(0);" onclick="toggleSwitchUserList();">
					<span class="MenuSwitchUserIcon"></span>
					<span class="MenuSwitchUserName"><%=_TEX.T("SwitchAccount")%></span>
				</a>
				<a id="MenuUpload" style="display: none; <%=Util.isSmartPhone(request)?"position: absolute;":""%>" href="/UploadFilePcV.jsp?ID=<%=checkLogin.m_nUserId%>">
					<span class="MenuUploadIcon"></span>
					<span class="MenuUploadName"><%=_TEX.T("THeader.Menu.Upload")%></span>
				</a>
				<a id="MenuSettings" style="display: none; <%=Util.isSmartPhone(request)?"position: absolute;":""%>" href="<%="/MyEditSettingPcV.jsp?ID="+checkLogin.m_nUserId%>" >
					<span class="MenuSettingsIcon"></span>
					<span class="MenuSettingsName"><%=_TEX.T("MyEditSetting.Title.Setting")%></span>
				</a>
				<%}%>
			<%}%>
		</div>
		<%if(!Util.isSmartPhone(request)) {%>
		<nav class="FooterMenu">
			<a id="MenuHome" class="FooterMenuItem" href="/MyHomePcV.jsp?ID=<%=checkLogin.m_nUserId%>">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Home")%></span>
			</a>
			<a id="MenuNew" class="FooterMenuItem" href="/NewArrivalPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Search")%></span>
			</a>
			<a id="MenuAct" style="<%=Util.isSmartPhone(request)?"":"margin-right: 18px;"%>" class="FooterMenuItem" href="/ActivityListPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
				<span class="FooterMenuItemIcon">
					<div id="InfoNumAct" class="InfoNum">0</div>
				</span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
			</a>
			<a id="MenuMe" style="<%=Util.isSmartPhone(request)?"":"margin-right: 20px;"%>" class="FooterMenuItem" href="/MyIllustListPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
			</a>
			<a id="MenuRequest" class="FooterMenuItem" href="/MySketchbookPcV.jsp">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Request")%></span>
			</a>
			<a id="MenuMyRequests" class="FooterMenuItem" href="/MyRequestListPcV.jsp?MENUID=MENUROOT">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("Request.MyRequests")%></span>
			</a>
		</nav>
		<nav class="FooterMenu" style="float: right;">
			<%if(!checkLogin.m_bLogin) {%>
			<form method="post" name="login_from_twitter_tmenupc_01" action="/LoginFormTwitter.jsp">
				<input id="login_from_twitter_tmenupc_callback_01" type="hidden" name="CBPATH" value=""/>
				<script>{
					let s = document.URL.split("/");
					for(let i=0; i<3; i++){s.shift();}
					$('#login_from_twitter_tmenupc_callback_01').val("/" + s.join("/"));
				}</script>
				<a class="BtnBase Rev HeaderLoginBtnPc LoginButton" href="javascript:login_from_twitter_tmenupc_01.submit()">
					<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login.Short")%>
				</a>
			</form>
			<div class="TwLoginUnsuccessfulIcon" onclick="dispTwLoginUnsuccessfulInfo($('#login_from_twitter_tmenupc_callback_01').val())">
				<i class="fas fa-info-circle" style="padding: 2px"></i>
			</div>

			<%} else {%>
			<a id="MenuSwitchUser" class="FooterMenuItem" style="display: none;" href="javascript: void(0);" onclick="toggleSwitchUserList();">
				<span class="FooterMenuItemIcon MenuSwitchUserIcon" style="width: 27px;height: 27px;"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("SwitchAccount")%></span>
			</a>
			<a id="MenuUpload" class="FooterMenuItem" href="/UploadFilePcV.jsp?ID=<%=checkLogin.m_nUserId%>">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Upload")%></span>
			</a>
			<a id="MenuSettings" class="FooterMenuItem" href="<%=(checkLogin.m_bLogin) ? "/MyEditSettingPcV.jsp?ID="+checkLogin.m_nUserId : "/" %>">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("MyEditSetting.Title.Setting")%></span>
			</a>
			<%}%>
			<form id="HeaderSearchWrapper" class="HeaderSearchWrapper" method="get" style="float: right;">
				<div class="HeaderSearch">
					<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text"
						   placeholder="<%=_TEX.T("THeader.Search.PlaceHolder")%>" value="<%=Util.toStringHtml(g_strSearchWord)%>" autocomplete="off"
					/>
					<div id="HeaderSearchBtn" class="HeaderSearchBtn"
						 <%if(!checkLogin.m_bLogin){%> onclick="DispMsg('<%=_TEX.T("Common.NeedLogin")%>')"<%}%>
					>
						<i class="fas fa-search"></i>
					</div>
				</div>
			</form>
		</nav>
		<%}%>
		<%
			String searchType = "Contents";
			String requestPath = request.getRequestURL().toString();
			String searchFunction = "SearchIllustByKeyword";
			if (Pattern.compile("/SearchUserByKeyword.*\\.jsp").matcher(requestPath).find()) {
				searchType = "Users";
				searchFunction = "SearchUserByKeyword";
			} else if (Pattern.compile("/SearchTagByKeyword.*\\.jsp").matcher(requestPath).find()) {
				searchType = "Tags";
				searchFunction = "SearchTagByKeyword";
			}
		%>
		<%if(Util.isSmartPhone(request)) {%>
			<div id="OverlaySearchWrapper" class="SearchWrapper overlay">
				<form id="HeaderSearchWrapper" class="HeaderSearchWrapper" method="get">
					<div id="OverlaySearchCloseBtn" class="OverlaySearchCloseBtn" onclick="$('#HeaderTitleWrapper').show();$('#OverlaySearchWrapper').hide();">
						<i class="fas fa-arrow-left"></i>
					</div>
					<div class="HeaderSearch">
						<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text" placeholder="<%=_TEX.T("THeader.Search.PlaceHolder")%>" value="<%=Util.toStringHtml(g_strSearchWord)%>" autocomplete="off"/>
						<div id="HeaderSearchBtn" class="HeaderSearchBtn">
							<i class="fas fa-search"></i>
						</div>
					</div>
				</form>
				<div class="RecentSearchHeader"><%=_TEX.T("SearchLog.Header")%></div>
				<ul id="RecentSearchList" class="RecentSearchList" ontouchstart></ul>
			</div>
			<script>
				function showSearch() {
					$('#HeaderTitleWrapper').hide();
					$('#OverlaySearchWrapper').show();
					$('#HeaderSearchBox').focus();
					showSearchHistory('<%=searchType == null ? "Contents" : searchType%>', '<%=_TEX.T("SearchLog.NotFound")%>');
				}
				$(document).on('click', '.RecentSearchItem', ev => {
					$('#HeaderTitleWrapper').show();
					$('#OverlaySearchWrapper').hide();
					$('ul#RecentSearchList').empty();
					<%=searchFunction%>($(ev.currentTarget).find('.RecentSearchKW').text());
				});
			</script>
		<%} else {%>
			<div id="PulldownSearchWrapper" class="SearchWrapper pulldown">
				<div class="RecentSearchHeader"><%=_TEX.T("SearchLog.Header")%></div>
				<ul id="RecentSearchList" class="RecentSearchList"></ul>
			</div>
			<script>
				function showSearch() {
					$('#PulldownSearchWrapper').slideDown();
					showSearchHistory('<%=searchType == null ? "Contents" : searchType%>', '<%=_TEX.T("SearchLog.NotFound")%>');
				}
				$('#HeaderSearchBox').on('focus', showSearch);
				$(document).on('click', '.RecentSearchItem', ev => {
					$('#PulldownSearchWrapper').hide();
					$('ul#RecentSearchList').empty();
					<%=searchFunction%>($(ev.currentTarget).find('.RecentSearchKW').text());
				});
				$(document).on('click touchend', function(ev) {
					if (!$(ev.target).closest('#PulldownSearchWrapper, .HeaderSearch').length) $('#PulldownSearchWrapper').hide();
				});
			</script>
		<%}%>
	</div>
</header>


<script>
	<%if(checkLogin.m_bLogin){%>
	$('#HeaderSearchWrapper').attr("action","/SearchIllustByKeywordPcV.jsp");
	$('#HeaderSearchBtn').on('click', SearchIllustByKeyword);
	<%}%>
</script>

<%if(Util.isSmartPhone(request)) {%>
<div class="FooterMenuWrapper">
	<nav class="FooterMenu">
		<a id="MenuHome" class="FooterMenuItem" href="/MyHomePcV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Home")%></span>
		</a>
		<a id="MenuNew" class="FooterMenuItem" href="/NewArrivalPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Search")%></span>
		</a>
		<a id="MenuRequest" class="FooterMenuItem" href="/MySketchbookPcV.jsp">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Request")%></span>
		</a>
		<a id="MenuAct" class="FooterMenuItem" href="/ActivityListPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon">
				<div id="InfoNumAct" class="InfoNum">0</div>
			</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
		</a>
		<a id="MenuMe" class="FooterMenuItem" href="/MyIllustListPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
		</a>
	</nav>
</div>
<%}%>
<%if(checkLogin.m_bLogin) {%>
<script>
	function UpdateNotify() {
		$.getJSON("/f/CheckNotifyF.jsp", {}, (data) => {
			const notifyNum = Math.min(
				data.check_comment +
				data.check_comment_reply +
				data.check_follow +
				data.check_heart +
				data.check_request +
				data.check_gift +
				data.check_wave_emoji +
				data.check_wave_emoji_message +
				data.check_wave_emoji_message_reply,
				99);
			<%//var strNotifyNum = (ntfy_num>99)?"9+":""+ntfy_num;%>
			$('#InfoNumAct').html(notifyNum);
			if(notifyNum>0) {
				$('#InfoNumAct').show();
			} else {
				$('#InfoNumAct').hide();
			}
		});
	}
	var g_timerUpdateNotify = null;
	$(function(){
		UpdateNotify();
		g_timerUpdateNotify = setInterval(UpdateNotify, 1000*60*5);
	});
</script>
<%}%>

<%if(!checkLogin.m_bLogin) {%>
<script>
	$(function () {
		var bLoginButtonClicked = false;
		$(".LoginButton").click(function () {
			if(bLoginButtonClicked){
				$(this).attr("href", "javascript:void(0);");
			}else{
				bLoginButtonClicked=true;
			}
		})
	})
</script>
<%if(false){%>
<div id="AnalogicoInfo" class="AnalogicoInfo Float">
	<h2 class="AnalogicoInfoTitle">
		<%=_TEX.T("THeader.Title")%>
	</h2>
	<h2 class="AnalogicoInfoSubTitle">
		<%=_TEX.T("THeader.Title.Desc")%>
	</h2>
	<a class="AnalogicoMoreInfo" href="/">
		<%=_TEX.T("Poipiku.Info.MoreInfo")%>
	</a>
	<div class="LinkApp" style="display: none;">
		<a href="https://itunes.apple.com/jp/app/%E3%83%9D%E3%82%A4%E3%83%94%E3%82%AF/id1436433822?mt=8" target="_blank" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg) no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; "></a>
		<a href="https://play.google.com/store/apps/details?id=jp.pipa.poipiku" target="_blank" style="display:inline-block;overflow:hidden; background:url('https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png') no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; background-size: 158px;"></a>
	</div>
</div>
<%}%>
<%} // if(!checkLogin.m_bLogin)%>
