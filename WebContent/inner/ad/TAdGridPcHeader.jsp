<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<!-- Geniee Wrapper Head Tag -->
	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
<script>
	window.gnshbrequest = window.gnshbrequest || {cmd:[]};
	gnshbrequest.cmd.push(function(){
		gnshbrequest.registerPassback("1508593");
		gnshbrequest.registerPassback("1508597");
		gnshbrequest.registerPassback("1508598");
		gnshbrequest.registerPassback("1508599");
		gnshbrequest.registerPassback("1508600");
		gnshbrequest.registerPassback("1508596");
		gnshbrequest.registerPassback("1508595");
		gnshbrequest.registerPassback("1508496");
		gnshbrequest.registerPassback("1508565");
		gnshbrequest.registerPassback("1508569");
		gnshbrequest.registerPassback("1508573");
		gnshbrequest.registerPassback("1508577");
		gnshbrequest.registerPassback("1508581");
		gnshbrequest.registerPassback("1508582");
		gnshbrequest.registerPassback("1508583");
		gnshbrequest.registerPassback("1508584");
		gnshbrequest.registerPassback("1508585");
		gnshbrequest.registerPassback("1508591");
		gnshbrequest.registerPassback("1508592");
		gnshbrequest.registerPassback("1508594");
		gnshbrequest.registerPassback("1508662");
		gnshbrequest.registerPassback("1508690");
		gnshbrequest.registerPassback("1508857");
		gnshbrequest.registerPassback("1508858");
	});
</script>
<script async src="https://cpt.geniee.jp/hb/v1/213456/426/wrapper.min.js"></script>
		<%} else {	// 海外%>
<script>
	window.gnshbrequest = window.gnshbrequest || {cmd:[]};
	gnshbrequest.cmd.push(function(){
		gnshbrequest.registerPassback("1508562");
		gnshbrequest.registerPassback("1508566");
		gnshbrequest.registerPassback("1508570");
		gnshbrequest.registerPassback("1508574");
		gnshbrequest.registerPassback("1508578");
		gnshbrequest.registerPassback("1508601");
		gnshbrequest.registerPassback("1508603");
		gnshbrequest.registerPassback("1508604");
		gnshbrequest.registerPassback("1508605");
		gnshbrequest.registerPassback("1508606");
		gnshbrequest.registerPassback("1508663");
		gnshbrequest.registerPassback("1508691");
	});
</script>
<script async src="https://cpt.geniee.jp/hb/v1/213495/433/wrapper.min.js"></script>
		<%}%>
	<%} else {	// R18%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
		<%} else {	// 海外%>
		<%}%>
	<%}%>
<%}%>
