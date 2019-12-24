<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="FooterAd">
	<%if(Util.isSmartPhone(request)) {%>

<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<%@ include file="/inner/TAdBaseAdponAll.jsp"%>
	<%/*
	<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
	<!-- poipiku_sp_footer -->
	<ins class="adsbygoogle"
		style="display:block"
		data-ad-client="ca-pub-9388519601000159"
		data-ad-slot="5140544959"
		data-ad-format="rectangle"
		data-full-width-responsive="true"></ins>
	<script>
	(adsbygoogle = window.adsbygoogle || []).push({});
	</script>
	*/%>
<%}else{%>
<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
<%}%>

	<%} else {%>

<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<%@ include file="/inner/TAdBaseAdponAll.jsp"%>
	<%/*
	<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
	<!-- poipiku_pc_footer -->
	<ins class="adsbygoogle"
		style="display:block"
		data-ad-client="ca-pub-9388519601000159"
		data-ad-slot="6398728253"
		data-ad-format="rectangle"
		data-full-width-responsive="true"></ins>
	<script>
	(adsbygoogle = window.adsbygoogle || []).push({});
	</script>
	*/%>
<%}else{%>
<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
<%}%>
	<%}%>
</div>
