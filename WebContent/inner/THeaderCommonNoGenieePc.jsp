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
<link rel="icon" href="/favicon.ico" />
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<link href="/css/TBase-45.css" type="text/css" rel="stylesheet" />
<link href="/css/TMaking-222.css" type="text/css" rel="stylesheet" />
<link href="/css/TBasePc-84.css" type="text/css" rel="stylesheet" />
<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
<link rel="apple-touch-icon" sizes="114x114" href="/img/apple-touch-icon-114x114.png" />
<link rel="apple-touch-icon" sizes="72x72" href="/img/apple-touch-icon-72x72.png" />
<link rel="apple-touch-icon" sizes="57x57" href="/img/apple-touch-icon.png" />
<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/js/jquery.creditCardValidator.js"></script>
<script type="text/javascript" src="/js/dayjs-1.8.27.min.js"></script>
<script type="text/javascript" src="/js/common-127.js"></script>
<%@ include file="/inner/TSweetAlert.jsp"%>
<%@ include file="/inner/TGoogleAnalytics.jsp"%>

<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-9388519601000159" crossorigin="anonymous"></script>

<%if(Util.isSmartPhone(request)) {%>
<meta name="viewport" content="width=360" />
<%} else {%>
<link href="/css/TPcAppend-91.css" type="text/css" rel="stylesheet" />
<%}%>
