<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF) {%>
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
	<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
	<%}%>
</div>
<%} else {%>
<div class="SideBarMid">
	<!-- /4789880/poipiku/poipiku_468x60_mid -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1593015647932-<%=nRand%>' style='width: 468px; height: 60px;'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipiku_468x60_mid', [468, 60], 'div-gpt-ad-1593015647932-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1593015647932-<%=nRand%>');
		});
		</script>
	</div>
</div>
<%}%>
<%}%>