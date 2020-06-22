<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="PcSideBarAd">
<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
<!-- /4789880/poipiku/poipiku_336x280_top_right -->
<div id='div-gpt-ad-1592860319519-0'>
	<script>
	googletag.cmd.push(function() {
		googletag.defineSlot('/4789880/poipiku/poipiku_336x280_top_right', [[300, 250], [336, 280]], 'div-gpt-ad-1592860319519-0').addService(googletag.pubads());
		googletag.enableServices();
		googletag.display('div-gpt-ad-1592860319519-0');
	});
	</script>
</div>
<%}else{%>
	<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
<%}%>
</div>
