<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="SideBarMid">
	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<div data-cptid="1508577">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508577", "[data-cptid='1508577']");
	});
</script>
</div>

			<%} else {	// 女性%>
<div data-cptid="1508581">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508581", "[data-cptid='1508581']");
	});
</script>
</div>
			<%}%>
		<%} else {	// 海外%>
<div data-cptid="1508570">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508570", "[data-cptid='1508570']");
	});
</script>
</div>
		<%}%>
	<%} else {	// R18%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/579/a1508579.js"></script>
			<%} else {	// 女性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/586/a1508586.js"></script>
			<%}%>
		<%} else {	// 海外%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/586/a1508586.js"></script>
		<%}%>
	<%}%>
</div>
<%}%>