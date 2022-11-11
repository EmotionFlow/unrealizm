<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache"/>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="Expires" content="0"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="robots" content="noindex" />
<meta name="pinterest" content="nopin" />
<meta name="viewport" content="width=360, user-scalable=no" />
<%/*
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
*/%>
<link href="/css/TBase-44.css" type="text/css" rel="stylesheet" />
<link href="/css/TMaking-220.css" type="text/css" rel="stylesheet" />
<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css?family=Noto+Serif+JP" rel="stylesheet" />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/js/jquery.creditCardValidator.js"></script>
<script type="text/javascript" src="/js/dayjs-1.8.27.min.js"></script>
<script type="text/javascript" src="/js/common-125.js"></script>
<%@ include file="/inner/TSweetAlert.jsp"%>
<%@ include file="/inner/TGoogleAnalytics.jsp"%>
<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
<script>window.googletag = window.googletag || {cmd: []};</script>
<%if(false /*checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd*/) {%>
<script data-ad-client="ca-pub-0260822034407772" async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<%}%>
<style>
body {user-select:none; -webkit-user-select: none; -moz-user-select: none; -ms-user-select:none; -webkit-touch-callout: none;}
</style>
<%if(false) {%>
<%--<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>--%>
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
