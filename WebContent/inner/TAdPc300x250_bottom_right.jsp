<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF) {%>
<div class="PcSideBarAd">
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<!-- /4789880/poipiku/poipiku_300x250_right_bottom -->
	<div id='div-gpt-ad-1592859971182-0' style='width: 300px; height: 250px;'>
		<script>
			googletag.cmd.push(function() {
				googletag.defineSlot('/4789880/poipiku/poipiku_300x250_right_bottom', [300, 250], 'div-gpt-ad-1592859971182-0').addService(googletag.pubads());
				googletag.enableServices();
				googletag.display('div-gpt-ad-1592859971182-0');
			});
		</script>
	</div>
	<%}else{%>
	<!-- /4789880/poipiku/poipiku_300x250_right_botto_r18 -->
	<div id='div-gpt-ad-1594921274456-0' style='width: 300px; height: 250px;'>
		<script>
		googletag.cmd.push(function() {
			googletag.defineSlot('/4789880/poipiku/poipiku_300x250_right_botto_r18', [300, 250], 'div-gpt-ad-1594921274456-0').addService(googletag.pubads());
			googletag.enableServices();
			googletag.display('div-gpt-ad-1594921274456-0');
		});
		</script>
	</div>
	<%}%>
</div>
<%}%>