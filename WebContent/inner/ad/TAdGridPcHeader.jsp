<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>

<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
<script>
	window.googletag = window.googletag || {cmd: []};
	googletag.cmd.push(function() {
<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_top_right', [[300, 250], [336, 280]], 'div-gpt-ad-1597961111008-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid', [[300, 250], [336, 280]], 'div-gpt-ad-1597961677347-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid', [[336, 280], [300, 250]], 'div-gpt-ad-1597961771258-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid', [[300, 250], [336, 280]], 'div-gpt-ad-1597961864627-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_left', [300, 250], 'div-gpt-ad-1597964764341-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_center', [300, 250], 'div-gpt-ad-1597964832589-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_right', [300, 250], 'div-gpt-ad-1597964525272-0').addService(googletag.pubads());
<%}else{%>
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_top_right_r18', [[300, 250], [336, 280]], 'div-gpt-ad-1597961321668-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_r18', [[336, 280], [300, 250]], 'div-gpt-ad-1597962599656-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_r18', [[300, 250], [336, 280]], 'div-gpt-ad-1597962684851-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_mid_r18', [[300, 250], [336, 280]], 'div-gpt-ad-1597962726937-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_left_R18', [300, 250], 'div-gpt-ad-1597964924883-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_center_R18', [300, 250], 'div-gpt-ad-1597965018358-0').addService(googletag.pubads());
		googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_right_r18', [300, 250], 'div-gpt-ad-1597965094671-0').addService(googletag.pubads());
<%}%>
		googletag.pubads().enableSingleRequest();
		googletag.enableServices();
	});
</script>
