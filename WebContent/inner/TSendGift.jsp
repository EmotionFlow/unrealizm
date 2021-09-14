<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
function _getGiftIntroductionHtml(nickName){
	return `
<style>
	.GiftIntroDlgTitle{padding: 10px 0 0 0; color: #3498db;}
	.GiftIntroDlgInfo{font-size: 13px; text-align: left;}
	.GiftIntroDlgInfo ul {padding-inline-start: 25px;}
	.GiftIntroDlgInfo ol {padding-inline-start: 25px;}
	.swal2-popup .swal2-footer {font-size: 0.75em;}
	.swal2-popup .swal2-actions {margin-top: 0}
	.GiftCampaignInfo {
		margin-top: 23px;
		margin-bottom: 18px;
		font-size: 13px;
		padding: 8px;
		width: 95%;
		border: 1px solid #3185d6;
		border-radius: 5px;
		text-align: left;
		color: #000000;
	}
	.GiftCampaignTitle {
		font-weight: 400;
		text-align: center;
		font-size: 14px;
		color: #3185d6;
	}
</style>
<div class="GiftIntroDlg">

<h2 class="GiftIntroDlgTitle"><i class="fas fa-gift"></i> <%=_TEX.T("Ofuse")%>(β)</h2>
<div class="GiftIntroDlgInfo" style="margin-top: 11px;">
	<p style="text-align:center; font-weight: normal; font-size:17px; color: #3498db;"><%=_TEX.T("TSendGift.LetsGift")%></p>
</div>
<div class="GiftIntroDlgInfo">
<ul>
	<li><%=_TEX.T("TSendGift.Intro.List01")%></li>
	<li><%=_TEX.T("TSendGift.Intro.List02")%></li>
	<li><%=_TEX.T("TSendGift.Intro.List03")%></li>
	<li><%=_TEX.T("TSendGift.Intro.List04")%></li>
</ul>
</div>

<div class="GiftIntroDlgInfo" style="margin-top: 11px; font-size: 11px;">
	<p><a style="color: inherit; text-decoration: underline" href="/MyEditSettingPcV.jsp?MENUID=POIPASS"><%=_TEX.T("TSendGift.WhatIsPoipass01")%></a><%=_TEX.T("TSendGift.WhatIsPoipass02")%></p>
</div>

<%if(!isApp){%>
<div class="GiftIntroDlgInfo" style="text-align: center; font-size: 16px;">
<%=_TEX.T("TSendGift.SendTo01")%>
</div>
<%} else {%>
<div class="GiftIntroDlgInfo" style="text-align: center; font-size: 16px;">
	<%=_TEX.T("TSendGift.AppInfo")%>
</div>
<%}%>

</div>
`;
}

<%// epsilonPayment - epsilonTrade間で受け渡しする変数。%>
let g_giftEpsilonInfo = {
	"giftInfo": null,
	"cardInfo": null,
};

function _giftEpsilonTrade(response){
	<%// もう使うことはないので、カード番号を初期化する。 %>
	if(g_giftEpsilonInfo.cardInfo.number){
		g_giftEpsilonInfo.cardInfo.number = null;
	}

	if( response.resultCode !== '000' ){
		window.alert("<%=_TEX.T("TSendGift.ErrorOccurred")%>");
		console.log(response.resultCode);
		g_giftEpsilonInfo.elCheerNowPayment.hide();
	}else{
		const agentInfo = createAgentInfo(
			AGENT.EPSILON, response.tokenObject.token,
			response.tokenObject.toBeExpiredAt);
		_sendGiftAjax(g_giftEpsilonInfo.giftInfo, agentInfo, g_giftEpsilonInfo.cardInfo);
	}
}

function _giftEpsilonPayment(_giftInfo, _cardInfo){
	DispMsgStatic("<%=_TEX.T("TSendGift.ProcessingPayment")%>");
	if(_cardInfo == null){
		_sendGiftAjax(_giftInfo, createAgentInfo(AGENT.EPSILON, null, null), null);
	} else {
		g_giftEpsilonInfo.giftInfo = _giftInfo;
		g_giftEpsilonInfo.cardInfo = _cardInfo;

		const contructCode = "68968190";
		let cardObj = {
			"cardno": String(_cardInfo.number),
			"expire": String('20' + _cardInfo.expire.split('/')[1] +  _cardInfo.expire.split('/')[0]),
			"securitycode": String(_cardInfo.securityCode),
		};
		EpsilonToken.init(contructCode);
		EpsilonToken.getToken(cardObj , _giftEpsilonTrade);
	}
}

function _sendGiftAjax(giftInfo, agentInfo, cardInfo) {
	$.ajax({
		"type": "post",
		"data": {
			"TOID": giftInfo.userId,
			"AID": agentInfo == null ? '' :  agentInfo.agentId,
			"TKN": agentInfo == null ? '' : agentInfo.token,
			"EXP": cardInfo == null ? '' : cardInfo.expire,
			"SEC": cardInfo == null ? '' : cardInfo.securityCode,
		},
		"url": "/f/SendGiftF.jsp",
		"dataType": "json",
	}).then( data => {
			$("#DispMsg").slideUp(200, () => {
				cardInfo = null;
				if (data.result > 0) {
					DispMsg(<%=_TEX.T("TSendGift.Done")%>, 4000);
				} else {
					switch (data.error_code) {
						case -10:
							DispMsg("<%=_TEX.T("CheerDlg.Err.CardAuth")%>");
							break;
						case -20:
							alert("<%=_TEX.T("CheerDlg.Err.AuthCritical")%>");
							break;
						case -30:
							DispMsg("<%=_TEX.T("CheerDlg.Err.CardAuth")%>");
							break;
						case -99:
							DispMsg("<%=_TEX.T("CheerDlg.Err.AuthOther")%>");
							break;
					}
				}
			});
		},
		error => {
			cardInfo = null;
			DispMsg("<%=_TEX.T("CheerDlg.Err.PoipikuSrv")%>");
			return false;
		}
	);
}

function SendGift(userId, nickName){
	const giftInfo = {
		"userId": userId,
		"nickName": nickName,
	};

	let cardInfo = {
		"number": null,
		"expire": null,
		"securityCode": null,
		"holderName": null,
	};

	Swal.fire({
		html: _getGiftIntroductionHtml(nickName),
		focusConfirm: false,
		showConfirmButton: <%=isApp?"false":"true"%>,
		showCloseButton: true,
		<%if(!isApp){%>
		confirmButtonText: '<%=_TEX.T("TSendGift.SendTo02")%>',
		footer:'<%=_TEX.T("CheerDlg.PaymentNotice")%>',
		<%}%>
	}).then(formValues => {
		// キャンセル
		if(formValues.dismiss){return false;}

		<%if(!checkLogin.m_bLogin){%>
		DispMsg("<%=_TEX.T("TSendGift.NeedToSignIn")%>");
		return false;
		<%} else {%>
		$.ajax({
			"type": "get",
			"url": "/f/CheckCreditCardF.jsp",
			"dataType": "json",
		}).then( (data) => {
			const result = Number(data.result);
			if (typeof (result) === "undefined" || result == null || result === -1) {
				return false;
			} else if (result === 1) {
				_giftEpsilonPayment(giftInfo, null);
			} else if (result === 0) {
				const title = "<%=_TEX.T("Ofuse")%>";
				const description = "<%=_TEX.T("TSendGift.SubmitDescription")%>";
				Swal.fire({
					html: getRegistCreditCardDlgHtml(title, description),
					focusConfirm: false,
					showCloseButton: true,
					showCancelButton: true,
					preConfirm: verifyCardDlgInput,
				}).then( formValues => {
					if(formValues.dismiss){
						elCheerNowPayment.hide();
						formValues.value.cardNum = '';
						formValues.value.cardExp = '';
						formValues.value.cardSec = '';
						return false;
					}

					cardInfo.number = String(formValues.value.cardNum);
					cardInfo.expire = String(formValues.value.cardExp);
					cardInfo.securityCode = String(formValues.value.cardSec);

					formValues.value.cardNum = '';
					formValues.value.cardExp = '';
					formValues.value.cardSec = '';

					_giftEpsilonPayment(giftInfo, cardInfo);
				});

			} else {
				DispMsg("<%=_TEX.T("CardInfoDlg.Err.PoipikuSrv")%>");
			}
		}, function (err) {
			console.log("CheckCreditCardF error" + err);
			DispMsg("<%=_TEX.T("CardInfoDlg.Err.PoipikuSrv")%>");
		});
		<%}%>
	});
}
</script>
