<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="com.emotionflow.poipiku.*"%>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache"/>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="Expires" content="0"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link href="https://fonts.googleapis.com/earlyaccess/roundedmplus1c.css" rel="stylesheet" />
<link href="/css/TBase-07.css" type="text/css" rel="stylesheet" />
<link href="/css/TMaking-10.css" type="text/css" rel="stylesheet" />
<link href="/css/TBasePc-08.css" type="text/css" rel="stylesheet" />
<link href="/font/typicons.min.css" type="text/css" rel="stylesheet" />
<link href="/webfonts/all.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="/js/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/js/common-09.js"></script>
<%if(Common.isSmartPhone(request)) {%>
<meta name="viewport" content="width=360" />
<%} else {%>
<style>
.Wrapper {width: 600px;}
.IllustThumb {width: 198px; height: 198px;}
.IllustItem .IllustItemUser {padding: 5px 0px;}
.IllustThumb .Category {top: 7px; left: 7px; font-size: 13px; min-width: 60px; height: 24px; line-height: 24px; max-width: none;}
.IllustItem .Category {margin: 0px 0 3px 0px;}
.IllustItem {margin: 40px auto;}
.IllustItem .IllustItemResBtnList {padding: 3px 4px;}
.IllustItem .IllustItemResBtnList .ResEmojiBtn {margin: 4px 1px;}
</style>
<%}%>
<%@ include file="/inner/TGoogleAnalytics.jsp"%>
