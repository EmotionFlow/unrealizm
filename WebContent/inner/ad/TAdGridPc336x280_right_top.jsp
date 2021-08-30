<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="PcSideBarAd" style="float: right;">
	<a class="PassAd" href="/MyEditSettingPcV.jsp?MENUID=POIPASS">ポイパスで広告非表示! &nbsp; <i class="fas fa-times"></i></a>

	<!-- /4789880/poipiku/poipiku_336x280_top_right -->
	<!-- /4789880/poipiku/poipiku_336x280_top_right_r18 -->
	<div id='div-gpt-ad-1597961111008-0'>
		<script>
			googletag.cmd.push(function() { googletag.display('div-gpt-ad-1597961111008-0'); });
		</script>
	</div>
</div>
<%}%>