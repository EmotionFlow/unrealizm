<%@page import="jp.pipa.poipiku.util.Util"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="DetailOverlay">
	<div id="DetailOverlayLoading" class="loadingSpinner2"><div class="rect1"></div><div class="rect2"></div><div class="rect3"></div><div class="rect4"></div><div class="rect5"></div></div>
	<%// バツ印アイコン%>
	<div class="DetailOverlayHeader"><div id="DetailOverlayClose" class="DetailOverlayClose">
		<svg x="0px" y="0px" viewBox="0 0 512 512" style="width: 15px; height: 15px; opacity: 1;" xml:space="preserve">
		<style type="text/css">.st0{fill:#4B4B4B;}</style>
			<g><polygon class="st0" points="512,52.535 459.467,0.002 256.002,203.462 52.538,0.002 0,52.535 203.47,256.005 0,459.465 52.533,511.998 256.002,308.527 459.467,511.998 512,459.475 308.536,256.005" style="fill: rgb(243, 243, 243);"></polygon></g>
		</svg>
	</div></div>
	<div id="DetailOverlayInner"></div>
	<div class="DetailIllustItemAd">
		<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
		<%=(bSmartPhone)?Util.poipiku_336x280_sp_overlay(checkLogin, g_nSafeFilter):Util.poipiku_336x280_pc_overlay(checkLogin, g_nSafeFilter)%>
		<%}%>
	</div>
</div>

<script type="text/javascript">
	function DispNeedLoginMsg() {
		DispMsg("<%=_TEX.T("ShowDetail.NeedLogin")%>", 3000);
	}
	function DispUnknownErrorMsg() {
		DispMsg("<%=_TEX.T("Common.Error.ERR_UNKNOWN")%>");
	}
	const detailOverlay = document.getElementById('DetailOverlay');
	const detailToucheMoveHandler = createDetailToucheMoveHandler(detailOverlay);
	const detailScrollHandler = createDetailScrollHandler(detailOverlay);
	$(function(){initDetailOverlay();});
</script>
