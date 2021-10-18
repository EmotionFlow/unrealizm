<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if(isNotMember) {%>
<div class="SettingBodyCmd" style="justify-content: center;">
	<a class="BtnBase SettingBodyCmdRegist BuyPassportButton" style="margin-left: 0" href="javascript:void(0)" onclick="BuyPassport(this)">
		<%=_TEX.T("MyEditSettingPassportV.BuySubscription" + (existsBuyHistory ? "" : ".FreePeriod"))%>
	</a>
</div>
<div class="NowPayment" style="display:none">
	<span class="PoiPassLoading"></span><span><%=_TEX.T("MyEditSettingPassportV.PurchaseInProcess")%></span>
</div>
<%}%>