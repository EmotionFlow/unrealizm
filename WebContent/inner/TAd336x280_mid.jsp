<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%int nRand = (int)(Math.random()*10000);%>
<%if(Util.isSmartPhone(request)) {%>
<div class="SideBarMid">
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<!-- /4789880/poipiku/poipikumobile_336x280_mid -->
	<div id='div-gpt-ad-1592939682472-<%=nRand%>'>
		<script>
		googletag.cmd.push(function() {
			googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipikumobile_336x280_mid', [[336, 280], [300, 250]], 'div-gpt-ad-1592939682472-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1592939682472-<%=nRand%>');
		});
		</script>
	</div>
	<%}else{%>
	<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
	<%}%>
</div>
<%} else {%>
<div class="PcSideBarAd">
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<!-- /4789880/poipiku/poipiku_336x280_mid -->
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
	<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
	<%}%>
</div>
<%}%>
