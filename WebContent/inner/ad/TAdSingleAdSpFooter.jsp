<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="FooterAd">
	<div class="SideBarMid">
	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<div data-cptid="1508584">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508584", "[data-cptid='1508584']");
	});
</script>
</div>
			<%} else {	// 女性%>
<div data-cptid="1508585">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508585", "[data-cptid='1508585']");
	});
</script>
</div>
			<%}%>
		<%} else {	// 海外%>
<div data-cptid="1508578">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508578", "[data-cptid='1508578']");
	});
</script>
</div>
		<%}%>
	<%} else {	// R18%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/589/a1508589.js"></script>
			<%} else {	// 女性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/590/a1508590.js"></script>
			<%}%>
		<%} else {	// 海外%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/590/a1508590.js"></script>
		<%}%>
	<%}%>
	</div>
</div>
<%}%>