<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div class="FooterAd">
<%if(Util.isSmartPhone(request)) {%>
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<div>
		<script type="text/javascript">
		google_ad_client = "ca-pub-2810565410663306";
		/* adx_poipikumobile_336x280_footer */
		google_ad_slot = "adx_poipikumobile_336x280_footer";
		google_ad_width = 336;
		google_ad_height = 280;
		</script>
		<script type="text/javascript" src="//pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
	</div>
	<%} else {%>
	<div>
		<%@ include file="/inner/TAdBaseAdponR18.jsp"%>
	</div>
	<%}%>
<%} else {%>
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<div>
		<script type="text/javascript">
		google_ad_client = "ca-pub-2810565410663306";
		/* adx_poipiku_336x280_footer_left */
		google_ad_slot = "adx_poipiku_336x280_footer_left";
		google_ad_width = 336;
		google_ad_height = 280;
		</script>
		<script type="text/javascript" src="//pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
	</div>
	<div>
		<script type="text/javascript">
		google_ad_client = "ca-pub-2810565410663306";
		/* adx_poipiku_336x280_footer_center */
		google_ad_slot = "adx_poipiku_336x280_footer_center";
		google_ad_width = 336;
		google_ad_height = 280;
		</script>
		<script type="text/javascript" src="//pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
	</div>
	<div>
		<script type="text/javascript">
		google_ad_client = "ca-pub-2810565410663306";
		/* adx_poipiku_336x280_footer_right */
		google_ad_slot = "adx_poipiku_336x280_footer_right";
		google_ad_width = 336;
		google_ad_height = 280;
		</script>
		<script type="text/javascript" src="//pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
	</div>
	<%} else {%>
	<div>
		<%@ include file="/inner/TAdBaseAdponR18Pc.jsp"%>
	</div>
	<div>
		<%@ include file="/inner/TAdBaseAdponR18Pc.jsp"%>
	</div>
	<div>
		<%@ include file="/inner/TAdBaseAdponR18Pc.jsp"%>
	</div>
	<%}%>
<%}%>
</div>
