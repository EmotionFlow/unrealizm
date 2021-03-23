<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/inner/Common.jsp" %>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if (!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request, response);
	return;
}

boolean bSmartPhone = Util.isSmartPhone(request);

RequestNewC results = new RequestNewC();
results.getParam(request);

if (!results.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>
	<%@ include file="/inner/TSweetAlert.jsp"%>
	<%@ include file="/inner/TCreditCard.jsp"%>
	<title><%=_TEX.T("THeader.Title")%> - Request </title>
	<script>
		function _validate() {
			if ($("#EditRequestText").val().length <= 10) {
				DispMsg("リクエスト本文が短すぎます");
				return false;
			}
			const amount = parseInt($("#EditAmmount").val(), 10);
			if (!amount) {
				DispMsg("金額を入力してください");
				return false;
			}
			if (amount < <%=results.requestCreator.amountMinimum%> ||
				amount > <%=RequestCreator.AMOUNT_LEFT_TO_ME_MAX%>){
				DispMsg("金額が範囲外です");
				return false;
			}
			return true;
		}

		function SendRequestAjax(requestInfo, agentInfo, cardInfo) {
			let postInfo = requestInfo;
			postInfo["AID"] = agentInfo.agentId;
			if (agentInfo.token) {
				postInfo["TKN"] = agentInfo.token;
			}
			if (cardInfo) {
				postInfo["EXP"] = cardInfo.expire;
				postInfo["SEC"] = cardInfo.securityCode;
			}

			$.ajax({
				"type": "post",
				"data": requestInfo,
				"url": "/f/SendRequestF.jsp",
				"dataType": "json",
			}).then( data => {
					cardInfo = null;
					HideMsgStatic();
					if (data.result === 0) {
						if(requestInfo.AMOUNT>0) {
							DispMsg("リクエストを送信しました！クリエイターが承認した時点で、指定した金額が決済されます。");
							window.setTimeout(() => {
								location.href = "/" + parseInt(requestInfo.CREATOR, 10);
							}, 2300);
						}
					} else {
						switch (data.result) {
							case <%=Request.ErrorKind.CardAuth.getCode()%>:
								DispMsg("クレジットカードの認証に失敗しました");
								break;
							case <%=Request.ErrorKind.NeedInquiry.getCode()%>:
								alert("<%=_TEX.T("PassportDlg.Err.AuthCritical")%>");
								break;
							case <%=Request.ErrorKind.DoRetry.getCode()%>:
								DispMsg("システムエラーが発生しました");
								break;
							case <%=Request.ErrorKind.Unknown.getCode()%>:
								DispMsg("不明なエラーが発生しました");
								break;
							default:
								DispMsg("その他エラーが発生しました");
								break;
						}
					}
					// setTimeout(()=>location.reload(), 5000);
				},
				error => {
					cardInfo = null;
					DispMsg("<%=_TEX.T("PassportDlg.Err.PoipikuSrv")%>");
				}
			);
		}

		// epsilonPayment - epsilonTrade間で受け渡しする変数。
		let g_epsilonInfo = {
			"requestInfo": null,
			"cardInfo": null,
		};

		function epsilonPayment(_requestInfo, _cardInfo){
			if(_cardInfo == null){ // カード登録済
				SendRequestAjax(_requestInfo, createAgentInfo(AGENT.EPSILON, null, null), null);
			} else { // 初回
				g_epsilonInfo.requestInfo = _requestInfo;
				g_epsilonInfo.cardInfo = _cardInfo;

				const contructCode = "68968190";
				//let cardObj = {cardno: "411111111111111", expire: "202202", securitycode: "123", holdername: "POI PASS"};
				let cardObj = {
					"cardno": String(_cardInfo.number),
					"expire": String('20' + _cardInfo.expire.split('/')[1] +  _cardInfo.expire.split('/')[0]),
					"securitycode": String(_cardInfo.securityCode),
					// "holdername": "DUMMY",
				};

				EpsilonToken.init(contructCode);

				// epsilonTradeを無名関数で定義するとコールバックしてくれない。
				// global領域に関数を定義し、関数名を引数指定しないとダメ。
				EpsilonToken.getToken(cardObj , epsilonTrade);
			}
		}

		function epsilonTrade(response){
			// もう使うことはないので、カード番号を初期化する。
			if(g_epsilonInfo.cardInfo.number){
				g_epsilonInfo.cardInfo.number = null;
			}

			if( response.resultCode !== '000' ){
				window.alert("リクエスト送信処理中にエラーが発生しました");
				console.log(response.resultCode);
				g_epsilonInfo.elPassportNowPayment.hide();
			}else{
				const agentInfo = createAgentInfo(
					AGENT.EPSILON, response.tokenObject.token,
					response.tokenObject.toBeExpiredAt);
				SendRequestAjax(g_epsilonInfo.requestInfo, agentInfo, g_epsilonInfo.cardInfo);
			}
		}
		function sendRequest() {
			if (!_validate()) {
				return false;
			}
			let cardInfo = {
				"number": null,
				"expire": null,
				"securityCode": null,
				"holderName": null,
			};
			const requestInfo = {
				"CLIENT": <%=checkLogin.m_nUserId%>,
				"CREATOR": <%=results.creatorUserId%>,
				"MEDIA": $("#OptionMedia").val(),
				"TEXT": $("#EditRequestText").val(),
				"CATEGORY": $("#OptionRequestCategory").prop("checked") ? 1 : 0,
				"AMOUNT": $("#EditAmmount").val()
			}
			if (requestInfo.CLIENT === requestInfo.CREATOR) {
				alert('自分宛にはリクエストできません');
				return false;
			}
			$('#SendRequestBtn').addClass('Disabled').html('リクエスト送信中');
			DispMsgStatic('リクエスト送信中');

			$.ajax({
				"type": "get",
				"url": "/f/CheckCreditCardF.jsp",
				"dataType": "json",
			}).then(function (data) {
				const result = Number(data.result);

				if (typeof (result) === "undefined" || result == null || result === -1) {
					return false;
				} else if (result === 1) {
					console.log("epsilonPayment");
					if (confirm("このリクエストが" +
						"承認されると、登録済みのクレジットカードに" + requestInfo.AMOUNT + "円が課金されます。" +
						"よろしいですか？")) {
						epsilonPayment(requestInfo, null);
					} else {
						HideMsgStatic(0);
						$('#SendRequestBtn').removeClass('Disabled').html('リクエストを送信する');
					}
				} else if (result === 0) {
					const title = "リクエスト送信";
					const description = "クレジットカード情報を入力してください。" +
						"リクエストが承認されると、入力されたカードに対し、" +
						"<b>" + requestInfo.AMOUNT + "円</b>(税込)が課金されます。";
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
							HideMsgStatic(0);
							$('#SendRequestBtn').removeClass('Disabled').html('リクエストを送信する');
							return false;
						}

						cardInfo.number = String(formValues.value.cardNum);
						cardInfo.expire = String(formValues.value.cardExp);
						cardInfo.securityCode = String(formValues.value.cardSec);

						<%// 念のため不要になった変数を初期化%>
						formValues.value.cardNum = '';
						formValues.value.cardExp = '';
						formValues.value.cardSec = '';

						epsilonPayment(requestInfo, cardInfo);
					});

				} else {
					DispMsg("<%=_TEX.T("CardInfoDlg.Err.PoipikuSrv")%>");
					HideMsgStatic(0);
					$('#SendRequestBtn').removeClass('Disabled').html('リクエストを送信する');
				}
			});

		}

		function dispRequestTextCharNum() {
			const nCharNum = 1000 - $("#EditRequestText").val().length;
			$("#RequestTextCharNum").html(nCharNum);
		}

		$(function () {
			dispRequestTextCharNum();
		});

	</script>

	<style>
		.RequestTitle {
            text-align: center;
            font-weight: bold;
            width: 100%;
            margin-top: 10px;
            margin-bottom: 10px;
            font-size: 16px;
		}
		.RequestRule {
            background-color: #f6fafd;
            color: #6d6965;
            border-radius: 10px;
            margin: 4px;
            padding: 8px;
			font-size: 13px;
		}
	</style>

</head>
<body>
<%@ include file="/inner/TMenuPc.jsp" %>

<article class="Wrapper" <%if(!bSmartPhone){%>style="width: 100%;"<%}%>>
	<div class="UserInfo Float">
		<div class="UserInfoBg"></div>
		<section class="UserInfoUser">
			<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(results.user.m_strFileName)%>')" href="/<%=results.user.m_nUserId%>/"></a>
			<h2 class="UserInfoUserName"><a href="/<%=results.user.m_nUserId%>/"><%=results.user.m_strNickName%></a></h2>
			<h3 class="UserInfoProgile"><%=Common.AutoLink(Util.toStringHtml(results.user.m_strProfile), results.user.m_nUserId, CCnv.MODE_PC)%></h3>
		</section>
	</div>

	<div class="UploadFile"
		 style="<%if(!bSmartPhone){%>width: 60%; max-width: 60%; margin: 0 20%;<%}%>padding-bottom: 100px;">
		<div class="RequestTitle">
			<%if(results.user.m_bRequestEnabled){%>
			<%=results.user.m_strNickName%>さんへのリクエスト
			<%}else{%>
			現在、リクエストを受け付けていません
			<%}%>
		</div>

		<%if(results.user.m_bRequestEnabled){%>
		<div class="UoloadCmdOption">
			<div class="OptionItem">
				<div class="OptionLabel">メディア</div>
				<div class="OptionPublish">
					<select id="OptionMedia">
						<option value="1">イラスト</option>
						<option value="10">小説</option>
					</select>
				</div>
			</div>
		</div>
		<div class="TextBody">
			リクエストメッセージ
			<textarea id="EditRequestText" class="EditTextBody"
					  maxlength="1000" placeholder="改行含め1000字まで"
					  onkeyup="dispRequestTextCharNum()"></textarea>
			<div id="RequestTextCharNum" class="TextBodyCharNum">1</div>
		</div>

		<div class="UoloadCmdOption">
			<div class="OptionItem">
				<div class="OptionLabel">ワンクッション・R18相当リクエスト</div>
				<div class="onoffswitch OnOff <%=results.requestCreator.allowSensitive() ? "" : "disabled"%> ">
					<input type="checkbox" class="onoffswitch-checkbox"
						   name="OptionRecent"
						   id="OptionRequestCategory"
						   value="0"
							<%=results.requestCreator.allowSensitive() ? "" : "onclick=\"return false;\""%>
					/>
					<label class="onoffswitch-label" for="OptionRequestCategory">
						<span class="onoffswitch-inner"></span>
						<span class="onoffswitch-switch"></span>
					</label>
				</div>
			</div>
			<div class="OptionNotify">
				<%if (results.requestCreator.allowSensitive()) {%>
				センシティブなリクエストは必ずON
				<%}else{%>
				このクリエイターはセンシティブな内容を受け付けません
				<%}%>
			</div>

			<div id="ItemPassword" class="OptionItem">
				<div class="OptionLabel">リクエスト金額</div>
				<div class="OptionPublish">
					<input id="EditAmmount" class="EditPassword" type="number" maxlength="6"
						   value="<%=results.requestCreator.amountLeftToMe%>"
						   placeholder="お任せ金額<%=results.requestCreator.amountLeftToMe%>円"/>
				</div>
			</div>
			<div class="OptionNotify">
				¥<%=String.format("%,d", results.requestCreator.amountMinimum)%>〜¥<%=String.format("%,d", RequestCreator.AMOUNT_MINIMUM_MAX)%>
			</div>

			<div class="OptionItem">
				<div class="OptionLabel">承認期限</div>
				<div class="OptionPublish">リクエスト送信から<%=results.requestCreator.returnPeriod%>日後</div>
			</div>
			<div class="OptionItem">
				<div class="OptionLabel">納品期限</div>
				<div class="OptionPublish">リクエスト送信から<%=results.requestCreator.deliveryPeriod%>日後</div>
			</div>
			<div class="OptionNotify">期限を過ぎると自動でキャンセルされます</div>

		</div>

		<div class="TextBody" style="margin-bottom: 10px">
			ルール
			<div class="RequestRule">
				クリエイターが承認した時点で、指定した金額で決済されます。<br/>
				金額の見積もり・打ち合わせ・リテイク・著作権譲渡はできません。<br/>
				クリエイターとはリクエスト本文以外での連絡はできません。<br/>
				リクエストを報酬の送金手段として使用することはできません。<br/>
				個人鑑賞(SNSへの掲載・使用は含む)を超えた利用には本文へ用途の説明が必要。<br/>
				納品されなかった場合、各支払方法を通して返金されます。
			</div>
		</div>

		<div class="UoloadCmd">
			<a id="SendRequestBtn" class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="sendRequest();">リクエストを送信する</a>
		</div>

		<%} // if(results.user.m_bRequestEnabled)%>
	</div>
</article>
</body>
</html>
