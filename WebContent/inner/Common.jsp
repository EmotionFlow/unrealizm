<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.io.*" %>
<%@page import="java.lang.*"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.security.MessageDigest"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.regex.*" %>
<%@page import="javax.naming.*"%>
<%@page import="javax.sql.*"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%
ResourceBundleControl _TEX = new ResourceBundleControl(request, response);
int g_nSafeFilter = Common.AD_ID_ALL;
String g_strSearchWord = "";
boolean SP_REVIEW = true;
boolean g_bShowAd = true;
%>