<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
	<%if(Util.isSmartPhone(request)) {%>

<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<%=Util.jikoku_hyou(request)%>
	<%//=Util.poipiku_320x250_sp_mid()%>
<%}else{%>
<div class="SideBarMid">
<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
</div>
<%}%>

	<%} else {%>

<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
<div class="SideBarMid">
	<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
	<!-- poipiku_468x60_bottom -->
	<ins class="adsbygoogle"
		style="display:inline-block;width:468px;height:60px"
		data-ad-client="ca-pub-9388519601000159"
		data-ad-slot="6254316070"></ins>
	<script>
	(adsbygoogle = window.adsbygoogle || []).push({});
	</script>
</div>
<%}else{%>
<div class="SideBarMid">
<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
</div>
<%}%>

	<%}%>
