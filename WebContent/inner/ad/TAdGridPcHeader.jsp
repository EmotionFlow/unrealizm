<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
 <%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF || g_bShowAd) {%>
<script>
	googletag.cmd.push(function() {
<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_top_right', [[300, 250], [336, 280]], 'div-gpt-ad-1597961111008-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid', [[300, 250], [336, 280]], 'div-gpt-ad-1597961677347-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_2', [[300, 250], [336, 280]], 'div-gpt-ad-1597961771258-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_3', [[300, 250], [336, 280]], 'div-gpt-ad-1597961864627-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_left', [300, 250], 'div-gpt-ad-1597964764341-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_center', [300, 250], 'div-gpt-ad-1597964832589-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_right', [300, 250], 'div-gpt-ad-1597964525272-0').addService(googletag.pubads());
<%}else{%>
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_top_right_r18', [[300, 250], [336, 280]], 'div-gpt-ad-1597961111008-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_r18', [[336, 280], [300, 250]], 'div-gpt-ad-1597961677347-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_r18', [[300, 250], [336, 280]], 'div-gpt-ad-1597961771258-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_r18', [[300, 250], [336, 280]], 'div-gpt-ad-1597961864627-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_left_R18', [300, 250], 'div-gpt-ad-1597964764341-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_center_R18', [300, 250], 'div-gpt-ad-1597964832589-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_right_r18', [300, 250], 'div-gpt-ad-1597964525272-0').addService(googletag.pubads());
<%}%>
		googletag.pubads().enableSingleRequest();
		googletag.enableServices();
	});
</script>
<%}%>