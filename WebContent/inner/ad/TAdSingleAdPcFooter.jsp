<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="FooterAd">
	<%if(Util.isSmartPhone(request)) {%>
	<div class="SideBarMid">
		<!-- /4789880/poipiku/poipikumobile_300x250_footer_left -->
		<!-- /4789880/poipiku/poipikumobile_336x280_footer_R18 -->

		<div id='div-gpt-ad-1598037992742-0'>
			<script>
				googletag.cmd.push(function() { googletag.display('div-gpt-ad-1598037992742-0'); });
			</script>
		</div>
	</div>
	<%}else{%>
<div style="width: 1140px; height: 280px;">
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-0260822034407772"
		crossorigin="anonymous"></script>
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
</div>
	<%}%>
</div>
<%}%>