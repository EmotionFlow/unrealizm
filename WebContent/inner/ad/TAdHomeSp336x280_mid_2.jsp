<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF || g_bShowAd) {%>
<div class="SideBarMid">
	<!-- /4789880/poipiku/poipiku_336x280_mid -->
	<!-- /4789880/poipiku/poipikumobile_336x280_mid_R18 -->

	<%@ include file="/inner/TAdBaseAdponAll.jsp"%>

	<!--
	<div id='div-gpt-ad-1597961771258-0'>
		<script>
			googletag.cmd.push(function() { googletag.display('div-gpt-ad-1597961771258-0'); });
		</script>
	</div>
	-->
</div>
<%}%>