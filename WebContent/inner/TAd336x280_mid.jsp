<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
<%if(Util.isSmartPhone(request)) {%>
<div class="SideBarMid">
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<!-- /4789880/poipiku/poipikumobile_336x280_mid -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1592939682472-<%=nRand%>'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipikumobile_336x280_mid', [[336, 280], [300, 250]], 'div-gpt-ad-1592939682472-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1592939682472-<%=nRand%>');
		});
		</script>
	</div>
	<%}else{%>
	<!-- /4789880/poipiku/poipikumobile_336x280_mid_R18 -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1594920446129-<%=nRand%>'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipikumobile_336x280_mid_R18', [[300, 250], [336, 280]], 'div-gpt-ad-1594920446129-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1594920446129-<%=nRand%>');
		});
		</script>
	</div>
	<%}%>
</div>
<%} else {%>
<div class="PcSideBarAd">
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<!-- /4789880/poipiku/poipiku_336x280_mid -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1592940074228-<%=nRand%>'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid', [[336, 280], [300, 250]], 'div-gpt-ad-1592940074228-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1592940074228-<%=nRand%>');
		});
		</script>
	</div>
	<%}else{%>
	<!-- /4789880/poipiku/poipiku_336x280_mid_r18 -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1594920278323-<%=nRand%>'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_r18', [[336, 280], [300, 250]], 'div-gpt-ad-1594920278323-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1594920278323-<%=nRand%>');
		});
		</script>
	</div>
	<%}%>
</div>
<%}%>
<%}%>