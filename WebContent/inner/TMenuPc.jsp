<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="Header">
	<div id="HeaderSlider"></div>
	<div class="HeaderWrapper">
		<div id="HeaderTitleWrapper" class="HeaderTitleWrapper">
			<h1 class="HeaderTitle">
				<a id="HeaderLink" class="HeaderLink" href="/">
					<img  class="HeaderImg" src="/img/pc_top_title.jpg" alt="<%=_TEX.T("THeader.Title")%>" />
				</a>
			</h1>
			<%if(Util.isSmartPhone(request) && !cCheckLogin.m_bLogin) {%>
				<form method="post" name="login_from_twitter_tmenupc_00" action="/LoginFormTwitterPc.jsp">
					<input id="login_from_twitter_tmenupc_callback_00" type="hidden" name="CBPATH" value=""/>
					<script>{
						let s = document.URL.split("/");
						for(let i=0; i<3; i++){s.shift();}
						$('#login_from_twitter_tmenupc_callback_00').val("/" + s.join("/"));
					}</script>
					<a class="BtnBase Rev HeaderLoginBtn" href="javascript:login_from_twitter_tmenupc_00.submit()">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login.Short")%>
					</a>
				</form>
			<%}else{%>
			<a class="HeaderTitleSearch fas fa-search" href="javascript:void(0);" onclick="$('#HeaderTitleWrapper').hide();$('#HeaderSearchWrapper').show();"></a>
			<%}%>
		</div>
		<%if(!Util.isSmartPhone(request)) {%>
		<nav class="GlobalLinkWrapper">
			<ul class="GlobalLink">
				<li><a id="MenuHotIllust" class="LinkItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a></li>
				<li><a id="MenuHotTag" class="LinkItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a></li>
				<li><a id="MenuRandom" class="LinkItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
				<li><a id="MenuRecent" class="LinkItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
			</ul>
		</nav>
		<%}%>
		<form id="HeaderSearchWrapper" class="HeaderSearchWrapper" method="get">
			<div class="HeaderSearch">
				<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text" placeholder="<%=_TEX.T("THeader.Search.PlaceHolder")%>" value="<%=Common.ToStringHtml(g_strSearchWord)%>" />
				<div id="HeaderSearchBtn" class="HeaderSearchBtn">
					<i class="fas fa-search"></i>
				</div>
			</div>
		</form>

		<script>
			$('#HeaderSearchWrapper').attr("action","/SearchIllustByKeywordPcV.jsp");
			$('#HeaderSearchBtn').on('click', SearchIllustByKeyword);
		</script>

		<%if(!Util.isSmartPhone(request)) {%>
		<nav class="FooterMenu">
			<%if(!cCheckLogin.m_bLogin) {%>
			<form method="post" name="login_from_twitter_tmenupc_01" action="/LoginFormTwitterPc.jsp">
				<input id="login_from_twitter_tmenupc_callback_01" type="hidden" name="CBPATH" value=""/>
				<script>{
					let s = document.URL.split("/");
					for(let i=0; i<3; i++){s.shift();}
					$('#login_from_twitter_tmenupc_callback_01').val("/" + s.join("/"));
				}</script>
				<a class="BtnBase Rev HeaderLoginBtnPc" href="javascript:login_from_twitter_tmenupc_01.submit()">
					<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login.Short")%>
				</a>
			</form>
			<%} else {%>
			<!--
			<a id="MenuSearch" class="FooterMenuItem" href="/NewArrivalPcV.jsp">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Search")%></span>
			</a>
			<span class="MenuSep"></span>
			-->
			<a id="MenuHome" class="FooterMenuItem" href="/MyHomePcV.jsp">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Home")%></span>
			</a>
			<a id="MenuUpload" class="FooterMenuItem" href="/UploadFilePcV.jsp">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Upload")%></span>
			</a>
			<a id="MenuAct" class="FooterMenuItem" href="/ActivityListPcV.jsp">
				<span class="FooterMenuItemIcon">
					<div id="InfoNumAct" class="InfoNum">0</div>
				</span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
			</a>
			<a id="MenuMe" class="FooterMenuItem" href="<%=(cCheckLogin.m_bLogin) ? "/MyIllustListV.jsp?ID="+cCheckLogin.m_nUserId : "/" %>">
				<span class="FooterMenuItemIcon"></span>
				<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
			</a>
			<%}%>
		</nav>
		<%}%>
	</div>
</header>

<%if(Util.isSmartPhone(request) && cCheckLogin.m_bLogin) {%>
<div class="FooterMenuWrapper">
	<nav class="FooterMenu">
		<a id="MenuMe" class="FooterMenuItem" href="<%=(cCheckLogin.m_bLogin) ? "/MyIllustListV.jsp?ID="+cCheckLogin.m_nUserId : "/" %>">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
		</a>
		<a id="MenuHome" class="FooterMenuItem" href="/MyHomePcV.jsp">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Home")%></span>
		</a>
		<!--
		<a id="MenuSearch" class="FooterMenuItem" href="/NewArrivalPcV.jsp">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Search")%></span>
		</a>
		-->
		<a id="MenuUpload" class="FooterMenuItem" href="/UploadFilePcV.jsp">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Upload")%></span>
		</a>
		<a id="MenuAct" class="FooterMenuItem" href="/ActivityListPcV.jsp">
			<span class="FooterMenuItemIcon">
				<div id="InfoNumAct" class="InfoNum">0</div>
			</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
		</a>
	</nav>
</div>
<%}%>
<%if(cCheckLogin.m_bLogin) {%>
<script>
	function UpdateNotify() {
		$.getJSON("/f/CheckNotifyF.jsp", {}, function(data){
			var ntfy_num = Math.min(data.check_comment + data.check_follow + data.check_heart, 99);
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
		g_timerUpdateNotify = setInterval(UpdateNotify, 1000*60);
	});
</script>
<%}%>

<%if(!cCheckLogin.m_bLogin) {%>
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
	<!--
	<div class="LinkApp">
		<a href="https://itunes.apple.com/jp/app/%E3%83%9D%E3%82%A4%E3%83%94%E3%82%AF/id1436433822?mt=8" target="_blank" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg) no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; "></a>
		<a href="https://play.google.com/store/apps/details?id=jp.pipa.poipiku" target="_blank" style="display:inline-block;overflow:hidden; background:url('https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png') no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; background-size: 158px;"></a>
	</div>
	-->
</div>
<%}%>
