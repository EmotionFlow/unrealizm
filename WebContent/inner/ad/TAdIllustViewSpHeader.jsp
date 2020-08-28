<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>

<script>
	googletag.cmd.push(function() {
		<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
		googletag.defineSlot('/4789880/poipiku/poipikumobile_300x250_footer_left', [[336, 280], [300, 250]], 'div-gpt-ad-1598037992742-0').addService(googletag.pubads());
		<%}else{%>
		googletag.defineSlot('/4789880/poipiku/poipikumobile_336x280_footer_R18', [[300, 250], [336, 280]], 'div-gpt-ad-1598037992742-0').addService(googletag.pubads());
		<%}%>
		googletag.pubads().enableSingleRequest();
		googletag.enableServices();
	});
</script>
