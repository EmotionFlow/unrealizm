<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="SideBarMid Wide">
	<%if(Util.isSmartPhone(request)) {%>
		<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
			<%/*@ include file="/inner/TAdBaseAdponAll.jsp"*/%>
			<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
			<!-- poipiku_320x250_sp_mid -->
			<ins class="adsbygoogle"
				style="display:inline-block;width:300px;height:250px"
				data-ad-client="ca-pub-9388519601000159"
				data-ad-slot="8188361534"></ins>
			<script>
			(adsbygoogle = window.adsbygoogle || []).push({});
			</script>
		<%}else{%>
		<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
		<%}%>
	<%} else {%>
		<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
			<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
			<!-- poipiku_728x90_bottom -->
			<ins class="adsbygoogle"
				style="display:inline-block;width:728px;height:90px"
				data-ad-client="ca-pub-9388519601000159"
				data-ad-slot="2681176223"></ins>
			<script>
			(adsbygoogle = window.adsbygoogle || []).push({});
			</script>
		<%}else{%>
		<!-- admax -->
		<script src="https://adm.shinobi.jp/s/78215ffd0e6eea00cde55cfaed03e0ef"></script>
		<!-- admax -->
		<%//@ include file="/inner/TAdBaseAdponR18.jsp"%>
		<%}%>
	<%}%>
</div>
