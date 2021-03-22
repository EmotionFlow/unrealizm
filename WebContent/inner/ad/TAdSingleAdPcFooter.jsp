<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="FooterAd">
	<%if(Util.isSmartPhone(request)) {%>
	<div class="SideBarMid">
		<!-- /4789880/poipiku/poipikumobile_300x250_footer_left -->
		<!-- /4789880/poipiku/poipikumobile_336x280_footer_R18 -->

		<div id='div-gpt-ad-1598037992742-0'>
			<script>
				googletag.cmd.push(function() { googletag.display('div-gpt-ad-1598037992742-0'); });
			</script>
		</div>
	</div>
	<%}else{%>
	<div class="PcSideBarAd">
		<!-- /4789880/poipiku/poipiku_300x250_footer_left -->
		<!-- /4789880/poipiku/poipiku_300x250_footer_left_R18 -->
		<div id='div-gpt-ad-1597964764341-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() { googletag.display('div-gpt-ad-1597964764341-0'); });
			</script>
		</div>
	</div>
	<div class="PcSideBarAd">
		<!-- /4789880/poipiku/poipiku_300x250_footer_center -->
		<!-- /4789880/poipiku/poipiku_300x250_footer_center_R18 -->
		<div id='div-gpt-ad-1597964832589-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() { googletag.display('div-gpt-ad-1597964832589-0'); });
			</script>
		</div>
	</div>
	<div class="PcSideBarAd">
		<!-- /4789880/poipiku/poipiku_300x250_footer_right -->
		<!-- /4789880/poipiku/poipiku_300x250_footer_right_r18 -->
		<div id='div-gpt-ad-1597964525272-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() { googletag.display('div-gpt-ad-1597964525272-0'); });
			</script>
		</div>
	</div>
	<%}%>
</div>
<%}%>