<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="SideBarMid">
	<!-- /4789880/poipiku/poipikumobile_300x100_top -->
	<div id='div-gpt-ad-1625176558051-0'>
		<script>
			googletag.cmd.push(function() { googletag.display('div-gpt-ad-1625176558051-0'); });
		</script>
	</div>
</div>
<%}%>