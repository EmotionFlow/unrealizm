<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF || g_bShowAd) {%>
<div class="SideBarMid Wide">
<%if(Util.isSmartPhone(request)) {%>
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
<%} else {%>
	<!-- /4789880/poipiku/poipiku_728x90_mid -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1593016129927-<%=nRand%>' style='width: 728px; height: 90px;'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipiku_728x90_mid', [728, 90], 'div-gpt-ad-1593016129927-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1593016129927-<%=nRand%>');
		});
		</script>
	</div>
<%}%>
</div>
<%}%>