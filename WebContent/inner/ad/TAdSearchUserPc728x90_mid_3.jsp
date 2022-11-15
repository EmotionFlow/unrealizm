<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="SideBarMid Wide">
	<!-- /4789880/poipiku/poipiku_728x90_mid -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1593016129927-<%=nRand%>' style='width: 728px; height: 90px;'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipiku_728x90_mid_3', [728, 90], 'div-gpt-ad-1593016129927-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1593016129927-<%=nRand%>');
		});
		</script>
	</div>
</div>
<%}%>