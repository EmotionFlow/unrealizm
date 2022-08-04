<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%if((checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) && checkLogin.m_nUserId!=315) {%>
<div class="HeaderPoiPassAd" style="width: 100%;">
	<a href="/MyEditSettingPassportAppV.jsp" style="display: flex; flex-flow: row; padding: 3px 0 ; justify-content: center;background-image: linear-gradient( 135deg, #5EFCE8 10%, #736EFE 100%);">
		<img style="height: 25px; margin: 0 10px 0 0;" src="/img/poipiku_passport_logo3_60.png" />
		<%
		final String message ;
		int nRnd = (int)(Math.random()*5.0);
		switch(nRnd) {
			case 0:
				message = _TEX.T("TAdPoiPassHeader.Message02");
				break;
			case 1:
				message = _TEX.T("TAdPoiPassHeader.Message03");
				break;
			case 2:
				message = _TEX.T("TAdPoiPassHeader.Message04");
				break;
			case 3:
				message = _TEX.T("TAdPoiPassHeader.Message05");
				break;
			case 4:
				message = _TEX.T("TAdPoiPassHeader.Message06");
				break;
			default:
				message = _TEX.T("TAdPoiPassHeader.Message01");
		}
		%>
		<span style="font-weight: bold; font-size: 13px; line-height: 25px; text-decoration: underline;"><%=message%></span>
	</a>
</div>
<%}%>
