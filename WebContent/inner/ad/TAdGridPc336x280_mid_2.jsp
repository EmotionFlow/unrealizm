<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="PcSideBarAd">
	<a class="PassAd" href="/MyEditSettingPcV.jsp?MENUID=POIPASS">ポイパスで広告非表示! &nbsp; <i class="fas fa-times"></i></a>

	<!-- /4789880/poipiku/poipiku_336x280_mid_2 -->
	<!-- /4789880/poipiku/poipiku_336x280_mid_r18 -->
	<div id='div-gpt-ad-1597961771258-0'>
		<script>
			//googletag.cmd.push(function() { googletag.display('div-gpt-ad-1597961771258-0'); });
		</script>
<script type="text/javascript">
google_ad_client = "ca-pub-2810565410663306";
/* adx_poipikumobile_336x280_mid_2 */
google_ad_slot = "adx_poipikumobile_336x280_mid_2";
google_ad_width = 336;
google_ad_height = 280;
</script>
<script type="text/javascript" src="//pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
	</div>
</div>
<%}%>