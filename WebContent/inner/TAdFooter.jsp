<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="FooterAd">
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- poipiku_footer_display -->
<ins class="adsbygoogle"
		style="display:block"
		data-ad-client="ca-pub-0260822034407772"
		data-ad-slot="6972560397"
		data-ad-format="auto"
		data-full-width-responsive="true"></ins>
<script>
		(adsbygoogle = window.adsbygoogle || []).push({});
</script>
	<%}else{%>
	<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
	<%}%>
</div>
