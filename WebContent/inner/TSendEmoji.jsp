<%@page import="jp.pipa.poipiku.Common"%>
<%@page import="jp.pipa.poipiku.CheckLogin"%>
<%@page import="jp.pipa.poipiku.controller.SendEmojiC"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="TCreditCard.jsp"%>
<script>
	function SendEmojiAjax(emojiInfo, nCheerAmount, agentInfo, cardInfo, elCheerNowPayment) {
		let amount = -1;
		if(nCheerAmount && nCheerAmount>0){amount = nCheerAmount;}

		$.ajax({
			"type": "post",
			"data": {
				"IID": emojiInfo.contentId,
				"EMJ": emojiInfo.emoji,
				"UID": emojiInfo.userId,
				"AMT": amount,
				"AID": agentInfo == null ? '' :  agentInfo.agentId,
				"TKN": agentInfo == null ? '' : agentInfo.token,
				"EXP": cardInfo == null ? '' : cardInfo.expire,
				"SEC": cardInfo == null ? '' : cardInfo.securityCode,
			},
			"url": "/f/SendEmojiF.jsp",
			"dataType": "json",
		}).then( data => {
				cardInfo = null;
				if (data.result_num > 0) {
					var $objResEmoji = $("<span/>").addClass("ResEmoji").html(data.result);
					$("#ResEmojiAdd_" + emojiInfo.contentId).before($objResEmoji);
					if (vg) vg.vgrefresh();
					if(nCheerAmount>0) {
						DispMsg(<%=_TEX.T("CheerDlg.Thanks")%>);
						if (elCheerNowPayment != null) {
							elCheerNowPayment.hide();
						}
					}
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
					if (elCheerNowPayment != null) {
						elCheerNowPayment.hide();
					}
				}},
			error => {
				cardInfo = null;
				DispMsg("<%=_TEX.T("CheerDlg.Err.PoipikuSrv")%>");
				if (elCheerNowPayment != null) {
					elCheerNowPayment.hide();
				}
			}
		);
	}

	function getCheerAmountOptionHtml(){
		return `
<select id="cheer_amount" style="vertical-align: bottom;">
<option value="100">100</option>
<option value="200">200</option>
<option value="300">300</option>
<option value="400">400</option>
<option value="500">500</option>
<option value="600">600</option>
<option value="700">700</option>
<option value="800">800</option>
<option value="900">900</option>
<option value="1000">1,000</option>
<option value="2000">2,000</option>
<option value="3000">3,000</option>
<option value="4000">4,000</option>
<option value="5000">5,000</option>
<option value="6000">6,000</option>
<option value="7000">7,000</option>
<option value="8000">8,000</option>
<option value="9000">9,000</option>
<option value="10000">10,000</option>
</select>
		`;
	}

	function getAmountDlgHtml(emojiImgTag){
		return <%=_TEX.T("CheerDlg.Text")%>;
	}

	// epsilonPayment - epsilonTrade間で受け渡しする変数。
	let g_epsilonInfo = {
		"emojiInfo": null,
		"cheerAmount": null,
		"cardInfo": null,
		"elCheerNowPayment": null,
	};

	function epsilonTrade(response){
		// もう使うことはないので、カード番号を初期化する。
		if(g_epsilonInfo.cardInfo.number){
			g_epsilonInfo.cardInfo.number = null;
		}

		if( response.resultCode !== '000' ){
			window.alert("購入処理中にエラーが発生しました");
			console.log(response.resultCode);
			g_epsilonInfo.elCheerNowPayment.hide();
		}else{
			const agentInfo = createAgentInfo(
				AGENT.EPSILON, response.tokenObject.token,
				response.tokenObject.toBeExpiredAt);
			SendEmojiAjax(g_epsilonInfo.emojiInfo, g_epsilonInfo.nCheerAmount,
				agentInfo, g_epsilonInfo.cardInfo, g_epsilonInfo.elCheerNowPayment);
		}
	}

	function epsilonPayment(_emojiInfo, _nCheerAmount, _cardInfo, _elCheerNowPayment){
		if(_cardInfo == null){ // カード登録済
			SendEmojiAjax(_emojiInfo, _nCheerAmount, createAgentInfo(AGENT.EPSILON, null, null),
			null, _elCheerNowPayment);
		} else { // 初回
			g_epsilonInfo.emojiInfo = _emojiInfo;
			g_epsilonInfo.nCheerAmount = _nCheerAmount;
			g_epsilonInfo.cardInfo = _cardInfo;
			g_epsilonInfo.elCheerNowPayment = _elCheerNowPayment;

			const contructCode = "68968190";
			// var cardObj = {cardno: "411111111111111", expire: "202202", securitycode: "123", holdername: "TARO NAMAA"};
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

	function getAmountDlgFooter(isApp) {
		let strLandingPageUrl = isApp ? "/PochiAppS.jsp" : "/PochiPcS.jsp";
		return '<div style="font-size: 12px;"><div><a href="' + strLandingPageUrl +
		'" style="text-decoration: underline; text-decoration-color: #ccc; color: #888;">' +
		'<%=_TEX.T("CheerDlg.Whatis")%>' +
		'</a></div>' + '<div style="margin-top: 5px;"><%=_TEX.T("CheerDlg.PaymentNotice")%></div>'
			+ '</div>';
	}

	function SendEmoji(nContentId, strEmoji, nUserId, elThis) {
		const emojiInfo = {
			"contentId": nContentId,
			"emoji": strEmoji,
			"userId": nUserId,
		};

		<%if(checkLogin.m_bLogin){%>
		let cardInfo = {
			"number": null,
			"expire": null,
			"securityCode": null,
			"holderName": null,
		};

		let elCheerNowPayment = $(elThis).parent().parent().children('div.ResEmojiCheerNowPayment');
		if(elCheerNowPayment.css('display') !== 'none'){
			console.log("決済処理中");
			return;
		}
		<%}%>

		const emojiImgTag = $(elThis).children('img.Twemoji').prop('outerHTML');

		if(!$(elThis).parent().hasClass('Cheer')) {
			SendEmojiAjax(emojiInfo, null, null, null, null);
		} else {
			<%if(checkLogin.m_bLogin){%>
			Swal.fire({
				html: getAmountDlgHtml(emojiImgTag),
				focusConfirm: false,
				showCloseButton: true,
				showCancelButton: false,
				confirmButtonText: "<%=_TEX.T("CheerDlg.Send")%>",
				footer: getAmountDlgFooter($(elThis).parent().hasClass('App')),
				preConfirm: () => {
					return {
						amount: $("#cheer_amount").val(),
					};
				},
			}).then(formValues => {
				// キャンセル
				if(formValues.dismiss){return false;}

				if($(elThis).parent().hasClass('App')) {
					Swal.fire({
						type: "info",
						text: "<%=_TEX.T("Cheer.BrowserOnly")%>",
						focusConfirm: true,
						showCloseButton: true,
						showCancelButton: false,
					});
					return false;
				}

				const nCheerAmount = Number(formValues.value.amount);
				elCheerNowPayment.show();
				// 代理店にカード情報を登録済であるかを検索
				$.ajax({
					"type": "get",
					"url": "/f/CheckCreditCardF.jsp",
					"dataType": "json",
				}).then(function (data) {
					const result = Number(data.result);
					if (typeof (result) === "undefined" || result == null || result === -1) {
						return false;
					} else if (result == 1) {
						epsilonPayment(emojiInfo, nCheerAmount, null, elCheerNowPayment);
					} else if (result === 0) {
						const titleEmojiImgTag = emojiImgTag.replace(">", ' style="height: 32px">');
						const title = "" + <%=_TEX.T("TSendEmoji.CardInfoDlg.Title")%>;
						const description = "<%=_TEX.T("TSendEmoji.CardInfoDlg.Description")%>";
						// クレジットカード情報入力ダイアログを表示、
						// 入力内容を代理店に送信し、Tokenを取得する。
						Swal.fire({
							html: getRegistCreditCardDlgHtml(title, description),
							focusConfirm: false,
							showCloseButton: true,
							showCancelButton: true,
							preConfirm: verifyCardDlgInput,
						}).then( formValues => {
							// キャンセルボタンがクリックされた
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

							// 念のため不要になった変数を初期化
							formValues.value.cardNum = '';
							formValues.value.cardExp = '';
							formValues.value.cardSec = '';

							epsilonPayment(emojiInfo, nCheerAmount, cardInfo, elCheerNowPayment);
						});

					} else {
						DispMsg("<%=_TEX.T("CardInfoDlg.Err.PoipikuSrv")%>");
					}
				}, function (err) {
					console.log("CheckCreditCardF error" + err);
					DispMsg("<%=_TEX.T("CardInfoDlg.Err.PoipikuSrv")%>");
				});
			});
			<%} //if(checkLogin.m_bLogin)%>
		}
		return false;
	}
</script>
