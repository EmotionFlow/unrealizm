<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="SideBarMid Wide">
	<%if(Util.isSmartPhone(request)) {%>
		<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
			<script type="text/javascript">
			google_ad_client = "ca-pub-2810565410663306";
			/* adx_poipikumobile_336x280_mid */
			google_ad_slot = "adx_poipikumobile_336x280_mid";
			google_ad_width = 336;
			google_ad_height = 280;
			</script>
			<script type="text/javascript" src="//pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
		<%}else{%>
		<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
		<%}%>
	<%} else {%>
		<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
			<script type="text/javascript">
			<script type="text/javascript">
			google_ad_client = "ca-pub-2810565410663306";
			/* adx_poipiku_728x90_mid */
			google_ad_slot = "adx_poipiku_728x90_mid";
			google_ad_width = 728;
			google_ad_height = 90;
			</script>
			<script type="text/javascript" src="//pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
		<%}else{%>
		<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
		<%}%>
	<%}%>
</div>
