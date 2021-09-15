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
<link href="/css/TBase-39.css" type="text/css" rel="stylesheet" />
<link href="/css/TMaking-149.css" type="text/css" rel="stylesheet" />
<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css?family=Noto+Serif+JP" rel="stylesheet">
<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/js/jquery.creditCardValidator.js"></script>
<script type="text/javascript" src="/js/dayjs-1.8.27.min.js"></script>
<script type="text/javascript" src="/js/common-54.js"></script>
<%@ include file="/inner/TSweetAlert.jsp"%>
<%@ include file="/inner/TGoogleAnalytics.jsp"%>
<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js"></script>
<script>window.googletag = window.googletag || {cmd: []};</script>
<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
<script data-ad-client="ca-pub-0260822034407772" async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<%}%>
<style>
body {user-select:none; -webkit-user-select: none; -moz-user-select: none; -ms-user-select:none; -webkit-touch-callout: none;}
</style>
