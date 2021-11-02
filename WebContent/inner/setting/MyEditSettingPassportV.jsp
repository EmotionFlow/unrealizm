<%@ page import="java.time.LocalDate" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
final PassportPayment payment = new PassportPayment(checkLogin);
final PassportSubscription subscription = new PassportSubscription(checkLogin);
final boolean existsBuyHistory = subscription.existsBuyHistory();
final PoiTicket ticket = new PoiTicket(checkLogin);
%>
<%@ include file="../TCreditCard.jsp"%>
<script type="text/javascript">
	function BuyPassportAjax(passportInfo, nPassportAmount, agentInfo, cardInfo, elPassportNowPayment) {
		let amount = -1;
		if(nPassportAmount && nPassportAmount>0){amount = nPassportAmount;}

		$.ajax({
			"type": "post",
			"data": {
				"PID": passportInfo.passportId,
				"UID": passportInfo.userId,
				"AMT": amount,
				"AID": agentInfo == null ? '' :  agentInfo.agentId,
				"TKN": agentInfo == null ? '' : agentInfo.token,
				"EXP": cardInfo == null ? '' : cardInfo.expire,
				"SEC": cardInfo == null ? '' : cardInfo.securityCode,
			},
			"url": "/f/BuyPassportF.jsp",
			"dataType": "json",
		}).then( data => {
			cardInfo = null;
			if (data.result === 1) {
				if(nPassportAmount>0) {
					DispMsg("<%=_TEX.T("PassportDlg.Thanks")%>");
					if (elPassportNowPayment != null) {
						elPassportNowPayment.hide();
					}
				}
			} else {
				switch (data.error_code) {
					case -10:
						DispMsg('<%=_TEX.T("PassportDlg.Err.CardAuth")%>');
						break;
					case -20:
						alert('<%=_TEX.T("PassportDlg.Err.AuthCritical")%>');
						break;
					case -30:
						DispMsg('<%=_TEX.T("PassportDlg.Err.CardAuth")%>');
						break;
					case -99:
						DispMsg('<%=_TEX.T("PassportDlg.Err.AuthOther")%>');
						break;
				}
				if (elPassportNowPayment != null) {
					elPassportNowPayment.hide();
				}
			}
			setTimeout(()=>location.reload(), 5000);
			},
			error => {
				cardInfo = null;
				DispMsg("<%=_TEX.T("PassportDlg.Err.PoipikuSrv")%>");
				if (elPassportNowPayment != null) {
					elPassportNowPayment.hide();
				}
				setTimeout(()=>location.reload(), 5000);
			}
		);
	}

	<%// epsilonPayment - epsilonTrade間で受け渡しする変数。%>
	let g_epsilonInfo = {
		"passportInfo": null,
		"passportAmount": null,
		"cardInfo": null,
		"elPassportNowPayment": null,
	};

	function epsilonPayment(_passportInfo, _nPassportAmount, _cardInfo, _elPassportNowPayment){
		if(_cardInfo == null){ // カード登録済
			BuyPassportAjax(_passportInfo, _nPassportAmount, createAgentInfo(AGENT.EPSILON, null, null),
				null, _elPassportNowPayment);
		} else { // 初回
			g_epsilonInfo.passportInfo = _passportInfo;
			g_epsilonInfo.nPassportAmount = _nPassportAmount;
			g_epsilonInfo.cardInfo = _cardInfo;
			g_epsilonInfo.elPassportNowPayment = _elPassportNowPayment;

			const contructCode = "68968190";
			<%//let cardObj = {cardno: "411111111111111", expire: "202202", securitycode: "123", holdername: "POI PASS"};%>
			let cardObj = {
				"cardno": String(_cardInfo.number),
				"expire": String('20' + _cardInfo.expire.split('/')[1] +  _cardInfo.expire.split('/')[0]),
				"securitycode": String(_cardInfo.securityCode),
				<%// "holdername": "DUMMY",%>
			};

			EpsilonToken.init(contructCode);

			<%// epsilonTradeを無名関数で定義するとコールバックしてくれない。%>
			<%// global領域に関数を定義し、関数名を引数指定しないとダメ。%>
			EpsilonToken.getToken(cardObj , epsilonTrade);
		}
	}

	function epsilonTrade(response){
		if(g_epsilonInfo.cardInfo.number){
			g_epsilonInfo.cardInfo.number = null;
		}

		if( response.resultCode !== '000' ){
			window.alert("<%=_TEX.T("MyEditSettingPassportV.BuySubscription.ErrorOccured")%>");
			console.log(response.resultCode);
			g_epsilonInfo.elPassportNowPayment.hide();
		}else{
			const agentInfo = createAgentInfo(
				AGENT.EPSILON, response.tokenObject.token,
				response.tokenObject.toBeExpiredAt);
			BuyPassportAjax(g_epsilonInfo.passportInfo, g_epsilonInfo.nPassportAmount,
				agentInfo, g_epsilonInfo.cardInfo, g_epsilonInfo.elPassportNowPayment);
		}
	}

	function BuyPassport() {
		$(".BuyPassportButton").hide();
		const passportInfo = {
			"passportId": 1,
			"userId": <%=checkLogin.m_nUserId%>,
		};
		let cardInfo = {
			"number": null,
			"expire": null,
			"securityCode": null,
			"holderName": null,
		};
		let elPassportNowPayment = $('.NowPayment').first();

		if($('.BuyPassportButton').first() === 'none'){
			alert("<%=_TEX.T("MyEditSettingPassportV.PurchaseInProcess")%>");
			return;
		}

		$('.NowPayment').show();

		$.ajax({
			"type": "get",
			"url": "/f/CheckCreditCardF.jsp",
			"dataType": "json",
		}).then(function (data) {
			const result = Number(data.result);
			const nPassportAmount = 300;
			if (typeof (result) === "undefined" || result == null || result === -1) {
				return false;
			} else if (result === 1) {
				if (confirm("<%=_TEX.T("MyEditSettingPassportV.BuySubscription.Confirm01" + (existsBuyHistory ? "" : ".FreePeriod"))%>")) {
					epsilonPayment(passportInfo, nPassportAmount, null, elPassportNowPayment);
				} else {
					$('.NowPayment').hide();
					$(".BuyPassportButton").show();
				}
			} else if (result === 0) {
				const title = "<%=_TEX.T("MyEditSettingPassportV.BuySubscription")%>";
				const description = "<%=_TEX.T("MyEditSettingPassportV.BuySubscription.Confirm02" + (existsBuyHistory ? "" : ".FreePeriod"))%>";
				<%// クレジットカード情報入力ダイアログを表示、%>
				<%// 入力内容を代理店に送信し、Tokenを取得する。%>
				Swal.fire({
					html: getRegistCreditCardDlgHtml(title, description),
					focusConfirm: false,
					showCloseButton: true,
					showCancelButton: true,
					preConfirm: verifyCardDlgInput,
				}).then(formValues => {
					<%// キャンセルボタンがクリックされた%>
					if (formValues.dismiss) {
						$('.NowPayment').hide();
						$(".BuyPassportButton").show();
						return false;
					}

					cardInfo.number = String(formValues.value.cardNum);
					cardInfo.expire = String(formValues.value.cardExp);
					cardInfo.securityCode = String(formValues.value.cardSec);

					<%// 念のため不要になった変数を初期化%>
					formValues.value.cardNum = '';
					formValues.value.cardExp = '';
					formValues.value.cardSec = '';

					epsilonPayment(passportInfo, nPassportAmount, cardInfo, elPassportNowPayment);
				});

			} else {
				DispMsg("<%=_TEX.T("CardInfoDlg.Err.PoipikuSrv")%>");
			}
		});
	}

	function CancelPassport() {
		const jstNow = new Date(Date.now() + ((new Date().getTimezoneOffset() + (9 * 60)) * 60 * 1000));
		if (jstNow.getDate() >= 25) {
			DispMsg("<%=_TEX.T("MyEditSettingPassportV.SubscriptionCancel.OutOfPeriod")%>", 4000);
			return;
		}
		Swal.fire({
			title: '<%=_TEX.T("MyEditSettingPassportV.SubscriptionCancel")%>',
			text: '<%=_TEX.T("MyEditSettingPassportV.SubscriptionCancel.Confirm")%>',
			focusConfirm: false,
			showCloseButton: true,
			showCancelButton: true,
			type: 'info',
		}).then(evt => {
			// キャンセルボタンがクリックされた
			if (evt.dismiss) {
				return false;
			}
			$("#CancelPassportButton").hide();
			$("#PassportNowCancelling").show();
			$.ajax({
				"type": "post",
				"data": {
					"PID": <%=checkLogin.m_nPassportId%>,
					"UID": <%=checkLogin.m_nUserId%>,
				},
				"url": "/f/CancelPassportF.jsp",
				"dataType": "json",
			}).then( data => {
					$("#PassportNowCancelling").hide();
					if (data.result === 1) {
						DispMsg("<%=_TEX.T("MyEditSettingPassportV.SubscriptionCancel.Done")%>");
					} else {
						switch (data.error_code) {
							case -10:
								DispMsg('<%=_TEX.T("PassportDlg.Err.CardAuth")%>');
								break;
							case -20:
								alert('<%=_TEX.T("PassportDlg.Err.AuthCritical")%>');
								break;
							case -30:
								DispMsg('<%=_TEX.T("PassportDlg.Err.CardAuth")%>');
								break;
							case -99:
								DispMsg('<%=_TEX.T("PassportDlg.Err.AuthOther")%>');
								break;
						}
					}
					setTimeout(()=>location.reload(), 5000);
				},
				error => {
					DispMsg("<%=_TEX.T("PassportDlg.Err.PoipikuSrv")%>");
					setTimeout(()=>location.reload(), 5000);
				}
			);
		});
	}
</script>

<style>
	.PoiPassLoading {
		width: 20px;
		height: 20px;
		display: inline-block;
		background: no-repeat url(/img/loading.gif);
		background-size: cover;
		position: relative;
		top: 4px;
		margin: 0 2px 0 4px;
	}
	.PoipikuPassportLogoFrame {display: block; float: left; width: 100%;}
	.PoipikuPassportLogoFrame .PoipikuPassportLogo {display: block; height: 45px;}
	.BenefitTable {
			width: 100%;
			text-align: center;
			border-collapse: collapse;
	}
	.BenefitTable td {height: 100px;}
	.BenefitTable td, table th {
			border: solid 1px #ddd;
			padding: 5px 8px;
			vertical-align: middle;
	}
	.BenefitTable .ListCell {background: #eee;}
	.BenefitTable td {height: 100px;}
	.BenefitTable .NormalCell {}
	.BenefitTable .BenefitCell {font-weight: bold;}
	.BenefitTable .BenefitDetail {
			font-size: 0.85em;
			color: #62605c;
	}
	.CEOMessage {
        float: left; width: 100%; border-bottom: 1px solid #6d6965; padding: 0 0 5px 0; margin: 0 0 5px 0; font-size: 12px;
	}

</style>

<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Title")%></div>
		<%{
			Passport.Status passportStatus = cResults.m_cPassport.status;
			boolean isNotMember = passportStatus == Passport.Status.NotYet || passportStatus == Passport.Status.InActive;
		%>
		<div class="SettingBody">
			<%//ポイパス%>
			<%if(passportStatus == Passport.Status.Cancelling){%>
			<%=_TEX.T("MyEditSettingPassportV.Cancelling")%>
			<%}else if(isNotMember) {%>
			<div class="CEOMessage">
				<p class="HeadLine">
					<%=_TEX.T("MyEditSettingPassportV.CEOMessage.HeadLine")%>
					<a class="AutoLink" href="javascript: void(0)" onclick="$('#CEOMessageMore').toggle();">more...</a>
				</p>
				<p id="CEOMessageMore" style="display: none;">
					<%=_TEX.T("MyEditSettingPassportV.CEOMessage.More")%>
				</p>
			</div>
			<%}else{%>
			<div class="SettingBody"><%=_TEX.T("MyEditSettingPassportV.Joining")%></div>
			<%}%>

			<%//金額%>
			<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Fee.Title")%></div>
			<div class="SettingBody"><%=_TEX.T("MyEditSettingPassportV.Fee.Amount")%></div>

			<%if (isNotMember) {%>
			<%if (existsBuyHistory) {%>
			<div class="SettingBody" style="margin-top: 18px;"><%=_TEX.T("MyEditSettingPassportV.WhenYouJoin")%></div>
			<%} else {%>
			<%//初月無料キャンペーン%>
			<div class="SettingListTitle" style="background: #fffff0;text-align: center;"><%=_TEX.T("MyEditSettingPassportV.Campaign.FirstMonthFree.Title")%></div>
			<div class="SettingBody"><%=_TEX.T("MyEditSettingPassportV.Campaign.FirstMonthFree.Description")%></div>
			<div class="SettingBodyCmd" style="border: solid 1px #999999; border-radius: 6px;">
				<ul style="list-style-type: circle;padding-inline: 25px; font-size: 12px">
					<li><%=_TEX.T("MyEditSettingPassportV.Campaign.FirstMonthFree.List01")%></li>
					<li><%=_TEX.T("MyEditSettingPassportV.Campaign.FirstMonthFree.List02")%></li>
					<li><%=_TEX.T("MyEditSettingPassportV.Campaign.FirstMonthFree.List03")%></li>
				</ul>
			</div>
			<%}%>
			<%@ include file="MyEditSettingPassportBuyButton.jsp"%>
			<%}%>
		</div>
	</div>

	<%//チケット%>
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Ticket")%>: <%=ticket.exists?ticket.amount:0%> <%=_TEX.T("MyEditSettingPassportV.Ticket.Amount")%></div>
		<%=_TEX.T("MyEditSettingPassportV.Ticket.Description")%> <a class="AutoLink" href="javascript: void(0)" onclick="$('#TicketInfoList').toggle();">more...</a>
		<ul id="TicketInfoList" style="display: none;">
			<li><%=_TEX.T("MyEditSettingPassportV.Ticket.List01")%></li>
			<li><%=_TEX.T("MyEditSettingPassportV.Ticket.List02")%></li>
			<li><%=_TEX.T("MyEditSettingPassportV.Ticket.List03")%></li>
		</ul>
	</div>

	<%if(!isNotMember){%>
	<%//今月のお支払い%>
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.ThisMonthPayment.Title")%></div>
		<%if(payment.exists){%>
			<%if(payment.by == PassportPayment.By.Ticket){%>
				<%=_TEX.T("MyEditSettingPassportV.ThisMonthPayment.ByTicket")%>
				<%if(subscription.getStatus() == PassportSubscription.Status.UnderContraction){%>
				<%=_TEX.T("MyEditSettingPassportV.ThisMonthPayment.NotToPayByCreditCard")%>
				<%}%>
			<%}else if(payment.by == PassportPayment.By.CreditCard){%>
				<%=_TEX.T("MyEditSettingPassportV.ThisMonthPayment.ByCreditCard")%>
			<%}else if(payment.by == PassportPayment.By.FreePeriod){%>
				<%=_TEX.T("MyEditSettingPassportV.ThisMonthPayment.ByFreePeriod")%>
			<%}else{%>
				<%=_TEX.T("MyEditSettingPassportV.ThisMonthPayment.Processing")%>
			<%}%>
		<%}else{%>
		<%=_TEX.T("MyEditSettingPassportV.ThisMonthPayment.Processing")%>
		<%}%>
	</div>
	<%}%>

	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Features.Title")%></div>
			<div class="SettingBody">
				<div class="SettingBodyCmd">
					<table class="BenefitTable">
						<tbody>
						<tr class="ListCell">
							<th style="width: 20%"></th>
							<th class="NormalCell" style="width: 30%"><%=_TEX.T("MyEditSettingPassportV.Features.Header.Normal")%></th>
							<th class="BenefitCell" style="width: 30%"><%=_TEX.T("MyEditSettingPassportV.Features.Header.Benefit")%></th>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List01")%></td>
							<td class="NormalCell"><%=String.format(_TEX.T("MyEditSettingPassportV.Features.List01.Normal"), Common.UPLOAD_FILE_MAX[0], Common.UPLOAD_FILE_TOTAL_SIZE[0])%></td>
							<td class="BenefitCell"><%=String.format(_TEX.T("MyEditSettingPassportV.Features.List01.Benefit"), Common.UPLOAD_FILE_MAX[1], Common.UPLOAD_FILE_TOTAL_SIZE[1])%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List02")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List02.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List02.Benefit")%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List03")%></td>
							<td class="NormalCell"><%=String.format(_TEX.T("MyEditSettingPassportV.Features.List03.Normal"), Common.EDITOR_DESC_MAX[0][0])%></td>
							<td class="BenefitCell"><%=String.format(_TEX.T("MyEditSettingPassportV.Features.List03.Benefit"), Common.EDITOR_DESC_MAX[0][1])%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List04")%></td>
							<td class="NormalCell"><%=String.format(_TEX.T("MyEditSettingPassportV.Features.List04.Normal"), Common.EDITOR_TEXT_MAX[3][0]/10000)%></td>
							<td class="BenefitCell"><%=String.format(_TEX.T("MyEditSettingPassportV.Features.List04.Benefit"), Common.EDITOR_TEXT_MAX[3][1]/10000)%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List05")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List05.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List05.Benefit")%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List06")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List06.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List06.Benefit")%></td>
						</tr>
						<%if(isNotMember){%>
						<tr>
							<td colspan="3">
								<%@ include file="MyEditSettingPassportBuyButton.jsp"%>
							</td>
						</tr>
						<%}%>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List07")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List07.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List07.Benefit")%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List08")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List08.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List08.Benefit")%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List09")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List09.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List09.Benefit")%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List10")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List10.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List10.Benefit")%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List11")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List11.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List11.Benefit")%></td>
						</tr>
						<tr>
							<td class="ListCell"><%=_TEX.T("MyEditSettingPassportV.Features.List12")%></td>
							<td class="NormalCell"><%=_TEX.T("MyEditSettingPassportV.Features.List12.Normal")%></td>
							<td class="BenefitCell"><%=_TEX.T("MyEditSettingPassportV.Features.List12.Benefit")%></td>
						</tr>
						</tbody>
					</table>
				</div>

				<div class="SettingBodyCmd" style="font-size:12px;">
					<ul style="list-style-type: circle;">
						<li><%=_TEX.T("MyEditSettingPassportV.SubscriptionInfo01")%></li>
						<li><%=_TEX.T("MyEditSettingPassportV.SubscriptionInfo02")%></li>
						<li><%=_TEX.T("MyEditSettingPassportV.SubscriptionInfo03")%></li>
						<li><%=_TEX.T("MyEditSettingPassportV.SubscriptionInfo04")%></li>
					</ul>
				</div>
				<%@ include file="MyEditSettingPassportBuyButton.jsp"%>
				<%if(subscription.getStatus() == PassportSubscription.Status.UnderContraction) {%>
				<% boolean isCancelOutOfPeriod = LocalDate.now().getDayOfMonth() >= 25; %>

				<%if(isCancelOutOfPeriod){%>
				<div class="SettingBodyCmd">
				<%=_TEX.T("MyEditSettingPassportV.SubscriptionCancel.OutOfPeriod")%>
				</div>
				<%}%>

				<div class="SettingBodyCmd">
					<a id="CancelPassportButton"
					   class="BtnBase SettingBodyCmdRegist <%=isCancelOutOfPeriod?"Disabled":""%>"
					   href="javascript:void(0)"
					   <%if(!isCancelOutOfPeriod){%>onclick="CancelPassport()"<%}%>
					>
						<%=_TEX.T("MyEditSettingPassportV.SubscriptionCancel")%>
					</a>
					<div id="PassportNowCancelling" style="display:none">
						<span class="PoiPassLoading"></span><span><%=_TEX.T("MyEditSettingPassportV.SubscriptionCancelling")%></span>
					</div>
				</div>
				<%}%>
			</div>
		<%}//Passport.Status passportStatus = cResults.m_cPassport.m_status;%>
	</div>
</div>
