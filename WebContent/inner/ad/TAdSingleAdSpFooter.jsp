<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF || g_bShowAd) {%>
<div class="FooterAd">
	<div class="SideBarMid">
		<!-- /4789880/poipiku/poipikumobile_300x250_footer_left -->
		<!-- /4789880/poipiku/poipikumobile_336x280_footer_R18 -->

		<%@ include file="/inner/TAdBaseAdponAll.jsp"%>
<!--
		<div id='div-gpt-ad-1598037992742-0'>
			<script>
				googletag.cmd.push(function() { googletag.display('div-gpt-ad-1598037992742-0'); });
			</script>
		</div>
-->
	</div>
</div>
<%}%>