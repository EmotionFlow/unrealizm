<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%if(false) {%>
<%--<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>--%>
<div class="SideBarMid">
	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<div data-cptid="1508496">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508496", "[data-cptid='1508496']");
	});
</script>
</div>
			<%} else {	// 女性%>
<div data-cptid="1508565">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508565", "[data-cptid='1508565']");
	});
</script>
</div>
			<%}%>
		<%} else {	// 海外%>
<div data-cptid="1508562">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508562", "[data-cptid='1508562']");
	});
</script>
</div>
		<%}%>
	<%} else {	// R18%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/563/a1508563.js"></script>
			<%} else {	// 女性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/567/a1508567.js"></script>
			<%}%>
		<%} else {	// 海外%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/567/a1508567.js"></script>
		<%}%>
	<%}%>
</div>
<%}%>