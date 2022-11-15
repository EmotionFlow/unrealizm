<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<div class="PcSideBarAd" style="float: right;">
	<a class="PassAd" href="/MyEditSettingPcV.jsp?MENUID=POIPASS"><%=_TEX.T("Common.Ad.Hide")%> &nbsp; <i class="fas fa-times"></i></a>

	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<div data-cptid="1508591">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508591", "[data-cptid='1508591']");
	});
</script>
</div>
			<%} else {	// 女性%>
<div data-cptid="1508592">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508592", "[data-cptid='1508592']");
	});
</script>
</div>
			<%}%>
		<%} else {	// 海外%>
<div data-cptid="1508601">
<script>
	gnshbrequest.cmd.push(function() {
		gnshbrequest.applyPassback("1508601", "[data-cptid='1508601']");
	});
</script>
</div>
		<%}%>
	<%} else {	// R18%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
			<%if(Math.random()>0.8) {	// 男性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/607/a1508607.js"></script>
			<%} else {	// 女性%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/608/a1508608.js"></script>
			<%}%>
		<%} else {	// 海外%>
<script type="text/javascript" src="https://js.gsspcln.jp/t/508/608/a1508608.js"></script>
		<%}%>
	<%}%>
</div>
<%}%>