<%@page import="jp.pipa.poipiku.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="Header">
	<div id="HeaderSlider"></div>
	<div class="HeaderWrapper">
		<div id="HeaderTitleWrapper" class="HeaderTitleWrapper">
			<h1 class="HeaderTitle">
				<a id="HeaderLink" class="HeaderLink" href="/">
					<img  class="HeaderImg" src="//img-cdn.poipiku.com/img/pc_top_title-03.png" alt="<%=_TEX.T("THeader.Title")%>" />
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
					<a class="BtnBase Rev HeaderLoginBtn LoginButton" href="javascript:login_from_twitter_tmenupc_00.submit()">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login.Short")%>
					</a>
				</form>
				<%} else {%>
				<a id="MenuSearch" class="HeaderTitleSearch fas fa-search" href="javascript:void(0);" onclick="$('#HeaderTitleWrapper').hide();$('#HeaderSearchWrapper').show();"></a>
				<a id="MenuMyRequests" style="display: none; <%=Util.isSmartPhone(request)?"position: absolute;":""%>" href="/MyRequestListPcV.jsp?MENUID=MENUROOT">
					<span class="MenuMyRequestsIcon"></span>
					<span class="MenuMyRequestsName"><%=_TEX.T("Request.MyRequests")%></span>
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
			<a id="MenuRequest" class="FooterMenuItem" href="/NewArrivalRequestCreatorPcV.jsp">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Request")%></span>
			</a>
			<a id="MenuAct" style="<%=Util.isSmartPhone(request)?"":"margin-right: 25px;"%>" class="FooterMenuItem" href="/ActivityListPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
				<span class="FooterMenuItemIcon">
					<div id="InfoNumAct" class="InfoNum">0</div>
				</span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
			</a>
			<a id="MenuMe" class="FooterMenuItem" href="/MyIllustListPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
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
			<%} else {%>
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
					<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text" placeholder="<%=_TEX.T("THeader.Search.PlaceHolder")%>" value="<%=Util.toStringHtml(g_strSearchWord)%>" />
					<div id="HeaderSearchBtn" class="HeaderSearchBtn">
						<i class="fas fa-search"></i>
					</div>
				</div>
			</form>
		</nav>
		<%} else {%>
		<form id="HeaderSearchWrapper" class="HeaderSearchWrapper" method="get" style="float: right;">
			<div class="HeaderSearch">
				<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text" placeholder="<%=_TEX.T("THeader.Search.PlaceHolder")%>" value="<%=Util.toStringHtml(g_strSearchWord)%>" />
				<div id="HeaderSearchBtn" class="HeaderSearchBtn">
					<i class="fas fa-search"></i>
				</div>
			</div>
		</form>
		<%}%>

		<script>
			$('#HeaderSearchWrapper').attr("action","/SearchIllustByKeywordPcV.jsp");
			$('#HeaderSearchBtn').on('click', SearchIllustByKeyword);
		</script>

	</div>
</header>

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
		<a id="MenuRequest" class="FooterMenuItem" href="/NewArrivalRequestCreatorPcV.jsp">
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
		$.getJSON("/f/CheckNotifyF.jsp", {}, function(data){
			const ntfy_num = Math.min(data.check_comment + data.check_follow + data.check_heart + data.check_request + data.check_gift, 99);
			//var strNotifyNum = (ntfy_num>99)?"9+":""+ntfy_num;
			$('#InfoNumAct').html(ntfy_num);
			if(ntfy_num>0) {
				$('#InfoNumAct').show();
			} else {
				$('#InfoNumAct').hide();
			}
		});
	}
	var g_timerUpdateNotify = null;
	$(function(){
		UpdateNotify();
		g_timerUpdateNotify = setInterval(UpdateNotify, 1000*60*2);
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
