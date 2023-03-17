<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(!g_isApp){%>

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
					<img  class="HeaderImg" src="//img.unrealizm.com/img/logo_tr_48.png" alt="<%=_TEX.T("THeader.Title")%>" />
				</a>
			</h1>
			<%if(!checkLogin.m_bLogin) {%>
			<form method="post" name="login_from_twitter_tmenupc_00" action="/LoginFormTwitter.jsp">
				<input id="login_from_twitter_tmenupc_callback_00" type="hidden" name="CBPATH" value=""/>
				<script>{
					let s = document.URL.split("/");
					for(let i=0; i<3; i++){s.shift();}
					$('#login_from_twitter_tmenupc_callback_00').val("/" + s.join("/"));
				}</script>
				<div class="CreateAccountButtons">
					<i class="fas fa-sign-in-alt"></i>
					<a class="BtnBase LoginButton" href="javascript:login_from_twitter_tmenupc_00.submit()">
						<span class="typcn typcn-social-twitter"></span>
					</a>
					or
					<a class="BtnBase LoginButton" href="/LoginFormEmailV.jsp">
						<span class="typcn typcn-mail"></span>
					</a>
				</div>
			</form>
			<a id="MenuSearch" class="HeaderTitleSearch material-symbols-sharp" style="right: 38px;" href="javascript:void(0);" onclick="showSearch()">search</a>
			<div class="HeaderSelectLang" onclick="showSelectLangDlg(false);">
				<i class="fas fa-globe" style="font-size: 19px; padding: 5px;"></i>
			</div>
			<%} else {%>
			<div style="display: flex; margin-right: 8px">
				<a id="MenuSearch" class="HeaderTitleSearch material-symbols-sharp" href="javascript:void(0);" onclick="showSearch()">search</a>
				<a id="HeaderMenuUpload" style="display: none;margin-right: 7px" href="/UploadFilePcV2.jsp?ID=<%=checkLogin.m_nUserId%>">
					<span class="MenuUploadIcon material-symbols-sharp">file_upload</span>
					<span class="MenuUploadName"><%=_TEX.T("THeader.Menu.Upload")%></span>
				</a>
				<a id="MenuSettings" style="display: none;" href="<%="/MyEditSettingPcV.jsp?ID="+checkLogin.m_nUserId%>" >
					<span class="MenuSettingsIcon material-symbols-sharp">settings</span>
					<span class="MenuSettingsName"><%=_TEX.T("MyEditSetting.Title.Setting")%></span>
				</a>
			</div>
			<%}%>
		</div>
		<%
		String searchType = "Contents";
		final String requestPath = request.getRequestURL().toString();
		if (requestPath.contains("/SearchUserByKeyword")) {
			searchType = "Users";
		} else if (requestPath.contains("/SearchTagByKeyword")) {
			searchType = "Tags";
		}
		final int cacheMin = Common.SEARCH_LOG_CACHE_MINUTES;
		final int suggestMax = Common.SEARCH_LOG_SUGGEST_MAX[checkLogin.m_nPassportId];
		final boolean passportOn = checkLogin.m_nPassportId == Common.PASSPORT_ON;
		%>
		<div id="OverlaySearchWrapper" class="SearchWrapper overlay">
			<form id="HeaderSearchWrapper" class="HeaderSearchWrapper" method="get">
				<div id="OverlaySearchCloseBtn" class="OverlaySearchCloseBtn" onclick="$('#HeaderTitleWrapper').show();$('#OverlaySearchWrapper').hide();">
					<i class="fas fa-arrow-left"></i>
				</div>
				<div class="HeaderSearch">
					<div class="HeaderSearchInputWrapper">
						<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text" maxlength="20"
								placeholder="<%=_TEX.T("THeader.Search.PlaceHolder")%>" value="<%=Util.toStringHtml(g_strSearchWord)%>"
								autocomplete="off" enterkeyhint="search" oninput="onSearchInput()"/>
						<div id="HeaderSearchClear" class="HeaderSearchClear">
							<i class="fas fa-times-circle" onclick="clearHeaderSearchInput()"></i>
						</div>
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

				<%if(checkLogin.m_bLogin){%>
				showSearchHistory('<%=searchType%>', '<%=_TEX.T("SearchLog.NotFound")%>', <%=cacheMin%>, <%=checkLogin.m_nUserId%>, <%=suggestMax%>, <%=passportOn%>);
				<%}else{%>
				showSearchHistory(null, '<%=_TEX.T("SearchLog.NoLogin")%>', <%=cacheMin%>);
				<%}%>
			}

			<%if(checkLogin.m_bLogin) {%>
			$(document).on('click', '.RecentSearchKW', ev => {
				$('#HeaderTitleWrapper').show();
				$('#OverlaySearchWrapper').hide();
				$('ul#RecentSearchList').empty();
				SearchByKeyword('<%=searchType%>', <%=checkLogin.m_nUserId%>, <%=suggestMax%>, $(ev.currentTarget).text())();
			});
			$(document).on('click', '.RecentSearchDelBtn', ev => {
				<%if(checkLogin.m_bLogin && checkLogin.m_nPassportId == Common.PASSPORT_OFF){%>
					DispMsg("<%=_TEX.T("SearchLog.Delete.IntroPoipass")%>", 1500);
				<%}else{%>
					deleteSearchHistory('<%=searchType%>', $(ev.target).closest('.RecentSearchRow').find('.RecentSearchKW').text())
					.then(() => {
						showSearchHistory('<%=searchType%>', '<%=_TEX.T("SearchLog.NotFound")%>', <%=cacheMin%>, <%=checkLogin.m_nUserId%>, <%=suggestMax%>, <%=passportOn%>);
					});
				<%}%>
			});
			<%}%>
		</script>
	</div>
</header>


<script>
	function onSearchInput() {
		const inputStr = $('#HeaderSearchBox').val().trim();
		if (!inputStr) {
			$('#HeaderSearchBox').val('');
			toggleClearSearchBtn();
			return false;
		}
		toggleClearSearchBtn();
		<%if(checkLogin.m_bLogin){%>
		const prevTimeout = getLocalStrage('search-suggestion-timeout');
		if (prevTimeout) clearTimeout(prevTimeout);
		setLocalStrage('search-suggestion-timeout', setTimeout(() => {
			if (inputStr && !/^(\d|\w|[\u3040-\u30FFＡ-Ｚａ-ｚ０-９])$/.test(inputStr)) {
				showSearchSuggestion('<%=searchType%>', inputStr);
			} else {
				showSearch();
			}
		}, 800));
		<%}%>
	}
	localStorage.removeItem('search-suggestion-timeout');
	$('#HeaderSearchWrapper').on('submit', SearchByKeyword('<%=searchType%>', <%=checkLogin.m_nUserId%>, <%=suggestMax%>));
	$('#HeaderSearchBtn').on('click', SearchByKeyword('<%=searchType%>', <%=checkLogin.m_nUserId%>, <%=suggestMax%>));
	toggleClearSearchBtn();
</script>

<div class="FooterMenuWrapper">
	<nav class="FooterMenu">
		<a id="MenuHome" class="FooterMenuItem" href="/MyHomePcV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon material-symbols-sharp">home</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Home")%></span>
		</a>
		<a id="MenuNew" class="FooterMenuItem" href="/NewArrivalV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon material-symbols-sharp">schedule</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Search")%></span>
		</a>
		<a id="MenuUpload" class="FooterMenuItem" href="/UploadFilePcV2.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon material-symbols-sharp">file_upload</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Upload")%></span>
		</a>
		<a id="MenuAct" class="FooterMenuItem" href="/ActivityListPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon material-symbols-sharp">mode_comment</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
			<div id="InfoNumAct" class="InfoNum">0</div>
		</a>
		<a id="MenuMe" class="FooterMenuItem" href="/MyIllustListV.jsp?ID=<%=checkLogin.m_nUserId%>">
			<span class="FooterMenuItemIcon material-symbols-sharp">account_circle</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
		</a>
	</nav>
</div>
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
<%}%>

<%}	//if(!g_isApp)%>
