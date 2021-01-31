<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%if((checkLogin.m_nPassportId==Common.PASSPORT_OFF || g_bShowAd) && checkLogin.m_nUserId!=315) {%>
<div class="HeaderPoiPassAd" style="width: 100%;">
	<a href="/MyEditSettingPcV.jsp?MENUID=POIPASS" style="display: flex; flex-flow: row; padding: 3px 0 ; justify-content: center;background-image: linear-gradient( 135deg, #5EFCE8 10%, #736EFE 100%);">
		<img style="height: 25px; margin: 0 10px 0 0;" src="/img/poipiku_passport_logo2_60.png" />
		<%
		String message = "ポイパスで絵文字100連打！";
		int nRnd = (int)(Math.random()*5.0);
		switch(nRnd) {
		case 0:
			message = "ポイパスでもらった絵文字解析！";
			break;
		case 1:
			message = "ポイパスで広告非表示！";
			break;
		case 2:
			message = "ポイパスで400枚まとめて投稿！";
			break;
		case 3:
			message = "ポイパスで自分のページの背景を設定！";
			break;
		default:
			break;
		}
		%>
		<span style="font-weight: bold; font-size: 13px; line-height: 25px; text-decoration: underline;"><%=message%></span>
	</a>
</div>
<%}%>
