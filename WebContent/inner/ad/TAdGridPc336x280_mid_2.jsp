<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%if(false) {%>
<%--<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>--%>
<div class="PcSideBarAd">
	<a class="PassAd" href="/MyEditSettingPcV.jsp?MENUID=POIPASS"><%=_TEX.T("Common.Ad.Hide")%> &nbsp; <i class="fas fa-times"></i></a>

	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
	<!-- /4789880/poipiku/poipiku_336x280_mid -->
	<%int nRand = (int)(Math.random()*10000);%>
	<div id='div-gpt-ad-1592940074228-<%=nRand%>'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_2', [[336, 280], [300, 250]], 'div-gpt-ad-1592940074228-<%=nRand%>').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1592940074228-<%=nRand%>');
		});
		</script>
	</div>
	<%} else {	// R18%>
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