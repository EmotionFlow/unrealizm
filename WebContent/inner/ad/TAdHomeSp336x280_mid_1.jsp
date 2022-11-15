<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="SideBarMid">
	<a class="PassAd" href="/MyEditSettingPcV.jsp?MENUID=POIPASS"><%=_TEX.T("Common.Ad.Hide")%> &nbsp; <i class="fas fa-times"></i></a>

	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<div data-cptid="1508569">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508569", "[data-cptid='1508569']");
	});
</script>
</div>
			<%} else {	// 女性%>
<div data-cptid="1508573">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508573", "[data-cptid='1508573']");
	});
</script>
</div>
			<%}%>
		<%} else {	// 海外%>
<div data-cptid="1508566">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508566", "[data-cptid='1508566']");
	});
</script>
</div>
		<%}%>
	<%} else {	// R18%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/571/a1508571.js"></script>
			<%} else {	// 女性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/575/a1508575.js"></script>
			<%}%>
		<%} else {	// 海外%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/575/a1508575.js"></script>
		<%}%>
	<%}%>
</div>
<%}%>