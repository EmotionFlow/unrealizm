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
<meta name="robots" content="index,follow" />
<meta name="pinterest" content="nopin" />
<link rel="icon" href="/favicon_2.ico" />
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
<link href="/css/TBase-37.css" type="text/css" rel="stylesheet" />
<link href="/css/TMaking-137.css" type="text/css" rel="stylesheet" />
<link href="/css/TBasePc-69.css" type="text/css" rel="stylesheet" />
<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
<link rel="apple-touch-icon" sizes="114x114" href="/img/apple-touch-icon-114x114_2.png" />
<link rel="apple-touch-icon" sizes="72x72" href="/img/apple-touch-icon-72x72_2.png" />
<link rel="apple-touch-icon" sizes="57x57" href="/img/apple-touch-icon_2.png" />
<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/js/jquery.creditCardValidator.js"></script>
<script type="text/javascript" src="/js/dayjs-1.8.27.min.js"></script>
<script type="text/javascript" src="/js/common-49.js"></script>
<script type="text/javascript" src="/js/commonPc-03.js"></script>
<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
<script>window.googletag = window.googletag || {cmd: []};</script>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<script data-ad-client="ca-pub-0260822034407772" async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<%}%>
<%if(Util.isSmartPhone(request)) {%>
<meta name="viewport" content="width=360" />
<%} else {%>
<link href="/css/TPcAppend-73.css" type="text/css" rel="stylesheet" />
<%}%>
<%@ include file="/inner/TGoogleAnalytics.jsp"%>
