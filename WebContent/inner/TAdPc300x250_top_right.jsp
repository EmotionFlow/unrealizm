<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="PcSideBarAd">
<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
	<!-- poipiku_300x250_top_right -->
	<ins class="adsbygoogle"
		style="display:inline-block;width:300px;height:250px"
		data-ad-client="ca-pub-9388519601000159"
		data-ad-slot="3221519041"></ins>
	<script>
	(adsbygoogle = window.adsbygoogle || []).push({});
	</script>
<%}else{%>
	<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
<%}%>
</div>
