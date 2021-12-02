<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache"/>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="Expires" content="0"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta http-equiv="Content-Language" content="ja">
<meta name="robots" content="index,follow" />
<meta name="pinterest" content="nopin" />
<link rel="icon" href="/favicon_2.ico" />
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
<link href="/css/TBase-40.css" type="text/css" rel="stylesheet" />
<link href="/css/TMaking-163.css" type="text/css" rel="stylesheet" />
<link href="/css/TBasePc-71.css" type="text/css" rel="stylesheet" />
<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
<link rel="apple-touch-icon" sizes="114x114" href="/img/apple-touch-icon-114x114_2.png" />
<link rel="apple-touch-icon" sizes="72x72" href="/img/apple-touch-icon-72x72_2.png" />
<link rel="apple-touch-icon" sizes="57x57" href="/img/apple-touch-icon_2.png" />
<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/js/jquery.creditCardValidator.js"></script>
<script type="text/javascript" src="/js/dayjs-1.8.27.min.js"></script>
<script type="text/javascript" src="/js/common-82.js"></script>
<script type="text/javascript" src="/js/commonPc-03.js"></script>
<%@ include file="/inner/TSweetAlert.jsp"%>
<%@ include file="/inner/TGoogleAnalytics.jsp"%>
<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
<script>window.googletag = window.googletag || {cmd: []};</script>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<script data-ad-client="ca-pub-0260822034407772" async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<%}%>
<%if(Util.isSmartPhone(request)) {%>
<meta name="viewport" content="width=360" />
<%} else {%>
<link href="/css/TPcAppend-74.css" type="text/css" rel="stylesheet" />
<%}%>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<script>window.gnshbrequest = window.gnshbrequest || {cmd:[]};</script>
	<%if(g_nSafeFilter==Common.AD_ID_ALL) {	// 一般%>
		<%if(checkLogin.m_nLangId==1) {	// 国内%>
<script>
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
