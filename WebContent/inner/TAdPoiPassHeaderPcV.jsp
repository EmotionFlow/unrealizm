<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.Common"%>
<%
final String poipassHeaderBenefitMessage;
final int poipassHeaderBenefitMessageRnd = (int)(Math.random()*5.0);
%>
<%if(!checkLogin.m_bLogin){%>
<div class="HeaderPoiPassAd" style="width: 100%;">
	<div class="CreateAccountInfo">
		<div class="CreateAccountBenefit">
			<%
				poipassHeaderBenefitMessage = switch (poipassHeaderBenefitMessageRnd) {
					case 0 -> _TEX.T("TAdPoiPassHeader.CreateAccountBenefit01");
					case 1 -> _TEX.T("TAdPoiPassHeader.CreateAccountBenefit02");
					case 2 -> _TEX.T("TAdPoiPassHeader.CreateAccountBenefit03");
					default -> _TEX.T("TAdPoiPassHeader.CreateAccountBenefit04");
				};
			%>
			<%=poipassHeaderBenefitMessage%>
		</div>
		<div class="CreateAccountButtons">
			<a class="BtnBase LoginButton" href="javascript:login_from_twitter_tmenupc_00.submit()">
				<span class="typcn typcn-social-twitter"></span>
			</a>
			- or -
			<a class="BtnBase LoginButton" href="/LoginFormEmailPcV.jsp">
				<span class="typcn typcn-mail"></span>
			</a>
		</div>
	</div>
</div>
<%}else if((checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) && checkLogin.m_nUserId!=315) {%>
<div class="HeaderPoiPassAd" style="width: 100%;">
	<a class="HeaderPoiPassAdBanner" href="/MyEditSettingPcV.jsp?MENUID=POIPASS">
		<img src="/img/poipiku_passport_logo3_60.png" alt="POIPASS"/>
		<%
			poipassHeaderBenefitMessage = switch (poipassHeaderBenefitMessageRnd) {
				case 0 -> _TEX.T("TAdPoiPassHeader.Message02");
				case 1 -> _TEX.T("TAdPoiPassHeader.Message03");
				case 2 -> _TEX.T("TAdPoiPassHeader.Message04");
				case 3 -> _TEX.T("TAdPoiPassHeader.Message05");
				case 4 -> _TEX.T("TAdPoiPassHeader.Message06");
				default -> _TEX.T("TAdPoiPassHeader.Message01");
			};
		%>
		<span><%=poipassHeaderBenefitMessage%></span>
	</a>
</div>
<%}%>
