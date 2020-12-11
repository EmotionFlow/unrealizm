<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
						DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
						break;
					case -20:
						alert("<%=_TEX.T("PassportDlg.Err.AuthCritical")%>");
						break;
					case -30:
						DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
						break;
					case -99:
						DispMsg("<%=_TEX.T("PassportDlg.Err.AuthOther")%>");
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

	// epsilonPayment - epsilonTrade間で受け渡しする変数。
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
			window.alert("購入処理中にエラーが発生しました");
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
		let elPassportNowPayment = $('#PassportNowPayment');
		if(elPassportNowPayment.css('display') !== 'none'){
			console.log("決済処理中");
			return;
		}
		elPassportNowPayment.show();
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
				console.log("epsilonPayment");
				if (confirm("登録済みのカード情報で決済します。よろしいですか？")) {
					epsilonPayment(passportInfo, nPassportAmount, null, elPassportNowPayment);
				} else {
					elPassportNowPayment.hide();
					$(".BuyPassportButton").show();
				}
			} else if (result === 0) {
				const title = "ポイパス定期購入";
				const description = "定期購入するためのカード情報を入力してください。入力されたカード情報から、毎月300円(税込)が課金されます。";
				<%// クレジットカード情報入力ダイアログを表示、%>
				<%// 入力内容を代理店に送信し、Tokenを取得する。%>
				Swal.fire({
					html: getRegistCreditCardDlgHtml(title, description),
					focusConfirm: false,
					showCloseButton: true,
					showCancelButton: true,
					preConfirm: verifyCardDlgInput,
				}).then(formValues => {
					// キャンセルボタンがクリックされた
					if (formValues.dismiss) {
						elPassportNowPayment.hide();
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
		Swal.fire({
			title: 'ポイパス購入解除',
			text: 'ポイパスの定期購入を解除します。特典は今月いっぱい有効で、来月から失効します。よろしいですか？',
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
						DispMsg("定期購入を解除しました。これまでポイパスをご購入いただき、ありがとうございました！");
					} else {
						switch (data.error_code) {
							case -10:
								DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
								break;
							case -20:
								alert("<%=_TEX.T("PassportDlg.Err.AuthCritical")%>");
								break;
							case -30:
								DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
								break;
							case -99:
								DispMsg("<%=_TEX.T("PassportDlg.Err.AuthOther")%>");
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
</style>

<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Title")%></div>
		<%{Passport.Status passportStatus = cResults.m_cPassport.m_status;%>
			<div class="SettingBody">
				<%if(passportStatus == Passport.Status.Cancelling){%>
				ポイパス定期購入の解除を承りました。今までお使いいただきありがとうございました。
				なお、ポイパスでプラスされている機能は今月末まで利用できます。
				<%}%>

				<%if(passportStatus == Passport.Status.NotMember) {%>
				<%//_TEX.T("MyEditSettingPassportV.Text")%>
				ポイピクパスポート（ポイパス）を毎月300円で定期購入すると、ポイピクをより楽しくお使いいただけます！
				<%}else if(passportStatus == Passport.Status.Billing){%>
				ポイパスを定期購入いただきありがとうございます。
				<%}%>

				<%if(passportStatus == Passport.Status.NotMember) {%>
				<div class="SettingBodyCmd">
					<div class="RegistMessage"></div>
					<a class="BtnBase SettingBodyCmdRegist BuyPassportButton" href="javascript:void(0)" onclick="BuyPassport(this)">
						ポイパスを定期購入する
					</a>
				</div>
				<%}%>

				<div class="SettingBodyCmd" style="font-size: 1.2em">
					<%if(passportStatus == Passport.Status.NotMember) {%>
					ポイパスでプラスされる機能
					<%}else{%>
					ポイパスでプラスされている機能
					<%}%>
				</div>
				<div class="SettingBodyCmd">
					<style>
                        .BenifitTable {
                            width:100%;
                            text-align: center;
                            border-collapse: collapse;
						}
                        .BenifitTable td {
                            height: 100px;
                        }
                        .BenifitTable td, table th {
                            border: solid 1px #ddd;
                            padding: 5px 8px;
                            vertical-align: middle;
                        }
                        .BenifitTable .ListCell {
                            background: #eee;
                        }
                        .BenifitTable td {
                            height: 100px;
                        }
                        .BenifitTable .NormalCell {
                            color: #aaaaaa;
                        }
                        .BenifitTable .BenefitCell {
                            color: #464441;
                        }
                        .BenifitTable .BenefitDetail {
                            font-size: 0.85em;
							color: #62605c;
                        }
					</style>
					<table class="BenifitTable">
						<tbody><tr class="ListCell">
							<th style="width: 20%"></th>
							<th class="NormalCell" style="width: 30%">ポイパスなし</th>
							<th class="BenefitCell" style="width: 30%">ポイパスあり</th>
						</tr>
						<tr>
							<td class="ListCell">広告表示</td>
							<td class="NormalCell">あり</td>
							<td class="BenefitCell">一切なし！</td>
						</tr>
						<tr>
							<td class="ListCell">ミュートキーワード</td>
							<td class="NormalCell">なし</td>
							<td class="BenefitCell">あり<br>
								<span class="BenefitDetail">
									避けたいコンテンツをキーワード指定して検索結果などから省くことができます。
								</span>
							</td>
						</tr>
						<tr>
							<td class="ListCell">定期ツイート<br>(前ツイート自動削除つき)</td>
							<td class="NormalCell">なし</td>
							<td class="BenefitCell">あり<br>
								<span class="BenefitDetail">
									最近の自分のコンテンツを１画像にまとめて自動ツイートできます。<br>
									一つ前のツイートは自動削除できるので、TLをスッキリ保てます！<br>
									(Androidアプリ版は準備中)
								</span></td>
						</tr>
						<tr>
							<td class="ListCell">送れる絵文字の数</td>
							<td class="NormalCell">1作品あたり10個/日</td>
							<td class="BenefitCell">1作品あたり100個/日<br>
						</tr>
						<tr>
							<td class="ListCell">もらった絵文字解析</td>
							<td class="NormalCell">過去一週間分</td>
							<td class="BenefitCell">過去30日分、全期間も対応<br>
						</tr>
						<tr>
							<td class="ListCell">投稿時のキャプション文字数</td>
							<td class="NormalCell">200文字<br></td>
							<td class="BenefitCell">500文字</td>
						</tr>
						<tr>
							<td class="ListCell">文章投稿時の文字数</td>
							<td class="NormalCell">1万文字<br></td>
							<td class="BenefitCell">10万文字</td>
						</tr>
						</tbody>
					</table>
				</div>

				<%if(passportStatus == Passport.Status.NotMember) {%>
				<div class="SettingBodyCmd">
					<div class="RegistMessage"></div>
					<a class="BtnBase SettingBodyCmdRegist BuyPassportButton" href="javascript:void(0)" onclick="BuyPassport(this)">
						ポイパスを定期購入する
					</a>
				</div>
				<div id="PassportNowPayment" style="display:none">
					<span class="PoiPassLoading"></span><span>購入処理中</span>
				</div>
				<%}%>
				<%if(passportStatus == Passport.Status.Billing){%>
				<div class="SettingBodyCmd">
					<a id="CancelPassportButton" class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="CancelPassport()">
						ポイパス定期購入を解除する
					</a>
					<div id="PassportNowCancelling" style="display:none">
						<span class="PoiPassLoading"></span><span>定期購入解除処理中</span>
					</div>
				</div>
				<%}%>
			</div>
		<%}//Passport.Status passportStatus = cResults.m_cPassport.m_status;%>
	</div>
</div>
