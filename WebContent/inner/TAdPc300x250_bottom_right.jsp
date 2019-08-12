<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(Util.isSmartPhone(request)) {%>
<div class="SideBarMid">

<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
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

</div>
<%} else {%>
<div class="PcSideBarAd">

<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
	<!-- poipiku_300x250_bottom_right -->
	<ins class="adsbygoogle"
		style="display:inline-block;width:300px;height:250px"
		data-ad-client="ca-pub-9388519601000159"
		data-ad-slot="6315134980"></ins>
	<script>
	(adsbygoogle = window.adsbygoogle || []).push({});
	</script>
<%}else{%>
<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
<%}%>

</div>
<%}%>