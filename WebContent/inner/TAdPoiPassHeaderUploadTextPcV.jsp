<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.Common"%>
<%if((checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) && checkLogin.m_nUserId!=315) {%>
<div class="HeaderPoiPassAd" style="width: 100%;">
	<a href="/MyEditSettingPcV.jsp?MENUID=POIPASS" style="display: flex; flex-flow: row; padding: 3px 0 ; justify-content: center;background-image: linear-gradient( 135deg, #5EFCE8 10%, #736EFE 100%);">
		<img style="height: 25px; margin: 0 10px 0 0;" src="/img/poipiku_passport_logo2_60.png" />
		<span style="font-weight: bold; font-size: 13px; line-height: 25px; text-decoration: underline;">ポイパスでテキスト10万文字投稿！</span>
	</a>
</div>
<%}%>
