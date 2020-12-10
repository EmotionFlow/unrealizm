<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF) {%>
<div class="FooterAd">
<%if(Util.isSmartPhone(request)) {%>
	<div class="SideBarMid">
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
		<!-- /4789880/poipiku/poipikumobile_300x250_footer_left -->
		<div id='div-gpt-ad-1597754220273-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() {
					googletag.defineSlot('/4789880/poipiku/poipikumobile_300x250_footer_left', [300, 250], 'div-gpt-ad-1597754220273-0').addService(googletag.pubads());
					googletag.enableServices();
					googletag.display('div-gpt-ad-1597754220273-0');
				});
			</script>
		</div>
		<%} else {%>
		<!-- /4789880/poipiku/poipikumobile_336x280_footer_R18 -->
		<div id='div-gpt-ad-1597758615399-0'>
			<script>
				googletag.cmd.push(function() {
					googletag.defineSlot('/4789880/poipiku/poipikumobile_336x280_footer_R18', [300, 250], 'div-gpt-ad-1597758615399-0').addService(googletag.pubads());
					googletag.enableServices();
					googletag.display('div-gpt-ad-1597758615399-0');
				});
			</script>
		</div>
	<%}%>
	</div>
<%} else {%>
	<%if(g_nSafeFilter==Common.AD_ID_ALL){%>
	<div class="PcSideBarAd">
		<!-- /4789880/poipiku/poipiku_300x250_footer_right -->
		<div id='div-gpt-ad-1597754835442-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() {
						googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_right', [300, 250], 'div-gpt-ad-1597754835442-0').addService(googletag.pubads());
						googletag.enableServices();
						googletag.display('div-gpt-ad-1597754835442-0');
					});
			</script>
		</div>
	</div>
	<div class="PcSideBarAd">
		<!-- /4789880/poipiku/poipiku_300x250_footer_center -->
		<div id='div-gpt-ad-1597754920798-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() {
						googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_center', [300, 250], 'div-gpt-ad-1597754920798-0').addService(googletag.pubads());
						googletag.enableServices();
						googletag.display('div-gpt-ad-1597754920798-0');
					});
			</script>
		</div>
	</div>
	<div class="PcSideBarAd">
		<!-- /4789880/poipiku/poipiku_300x250_footer_left -->
		<div id='div-gpt-ad-1597754630625-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() {
						googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_left', [300, 250], 'div-gpt-ad-1597754630625-0').addService(googletag.pubads());
						googletag.enableServices();
						googletag.display('div-gpt-ad-1597754630625-0');
					});
			</script>
		</div>
	</div>
	<%} else {%>
	<div class="PcSideBarAd">
	<!-- /4789880/poipiku/poipiku_300x250_footer_left_R18 -->
	<div id='div-gpt-ad-1597758318848-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() {
						googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_left_R18', [300, 250], 'div-gpt-ad-1597758318848-0').addService(googletag.pubads());
						googletag.enableServices();
						googletag.display('div-gpt-ad-1597758318848-0');
					});
			</script>
		</div>
	</div>
	<div class="PcSideBarAd">
<!-- /4789880/poipiku/poipiku_300x250_footer_center_R18 -->
<div id='div-gpt-ad-1597758388146-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() {
						googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_center_R18', [300, 250], 'div-gpt-ad-1597758388146-0').addService(googletag.pubads());
						googletag.enableServices();
						googletag.display('div-gpt-ad-1597758388146-0');
					});
			</script>
		</div>
	</div>
	<div class="PcSideBarAd">
		<!-- /4789880/poipiku/poipiku_300x250_footer_right_r18 -->
		<div id='div-gpt-ad-1597758103567-0' style='width: 300px; height: 250px;'>
			<script>
				googletag.cmd.push(function() {
						googletag.defineSlot('/4789880/poipiku/poipiku_300x250_footer_right_r18', [300, 250], 'div-gpt-ad-1597758103567-0').addService(googletag.pubads());
						googletag.enableServices();
						googletag.display('div-gpt-ad-1597758103567-0');
					});
			</script>
		</div>
	</div>
	<%}%>
<%}%>
</div>
<%}%>