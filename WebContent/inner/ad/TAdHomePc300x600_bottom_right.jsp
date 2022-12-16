<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd && false) {%>
<div class="PcSideBarAd">
	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<div data-cptid="1508593">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508593", "[data-cptid='1508593']");
	});
</script>
</div>
			<%} else {	// 女性%>
<div data-cptid="1508594">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508594", "[data-cptid='1508594']");
	});
</script>
</div>
			<%}%>
		<%} else {	// 海外%>
<div data-cptid="1508603">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508603", "[data-cptid='1508603']");
	});
</script>
</div>
		<%}%>
	<%} else {	// R18%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/609/a1508609.js"></script>
			<%} else {	// 女性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/610/a1508610.js"></script>
			<%}%>
		<%} else {	// 海外%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/610/a1508610.js"></script>
		<%}%>
	<%}%>
</div>
<%}%>