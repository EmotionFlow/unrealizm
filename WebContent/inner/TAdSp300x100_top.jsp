<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
<div class="PcSideBarAd">
	<!-- /4789880/poipiku/poipikumobile_300x100_top -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1625176558051-<%=nRand%>'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipikumobile_300x100_top', [[300, 50]], 'div-gpt-ad-1625176558051-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1625176558051-<%=nRand%>');
		});
		</script>
	</div>
</div>
<%}%>