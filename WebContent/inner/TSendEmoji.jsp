<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- for EPSILON -->
<!--
<script src='https://secure.epsilon.jp/js/token.js'></script>
-->
<script src='https://beta.epsilon.jp/js/token.js'></script>
<script>
    const AGENT = {
        "VERITRANS": 1,
        "EPSILON": 2,
    };

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
<select id="cheer_amount">
<option value="100">100</option>
<option value="1000">1,000</option>
<option value="10000">10,000</option>
</select>
        `;
    }

    function getAmountDlgHtml(strEmoji){
        return <%=_TEX.T("CheerDlg.Text")%>;
    }

    function getRegistCreditCardDlgHtml(strEmoji, nCheerAmount){
        return `
<style>
	.CardInfoDlgTitle{padding: 10px 0 0 0;}
	.CardInfoDlgInfo{font-size: 12px; text-align: left;}
	.CardInfoDlgInputItem{margin: 4px;}
	.CardInfoDlgInputLabel{font-size: 16px;}
	.CardInfoDlgInfoCheckList{text-align: left; font-size: 16px;}
	.swal2-popup .CardInfoDlgInputItem .swal2-input{margin-top: 4px; font-size: 1.1em; height: 1.825em;}
</style>
<h2 class="CardInfoDlgTitle">
` + <%=_TEX.T("CardInfoDlg.Title")%> + `
</h2>
<div class="CardInfoDlgInfo">
	<p><%=_TEX.T("CardInfoDlg.Description")%></p>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel"><%=_TEX.T("CardInfoDlg.CardNumber")%></div>
	<span>
	<span style="font-size: 11px;position: relative;top: -9px;">Only</span>
	<img src="/img/credit_card_logo_visa.png" width="40px" style="padding-top: 4px;"/>
	</span>
	<input id="card_number" class="swal2-input" style="margin-top: 4px;" maxlength="16" value="4111111111111111"/>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel"><%=_TEX.T("CardInfoDlg.CardExpire")%></div>
	<input id="cc_exp" class="swal2-input" style="margin-top: 4px;" maxlength="5" value="02/22"/>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel"><%=_TEX.T("CardInfoDlg.CardSecCode")%><div/>
	<input id="cc_csc" class="swal2-input" style="margin-top: 4px;" maxlength="4"  value="012"/>
</div>
<div class="CardInfoDlgInfoCheckList">
<label><input id="cc_agree1" type="checkbox" checked="checked"/><%=_TEX.T("CardInfoDlg.Agree")%></label>
</div>
`;
    }

    function createAgentInfo(agent, token, tokenExpire){
        return {
            "agentId": agent,
            "token": token,
            "tokenExpire": tokenExpire,
        };
    }

    /**
    function veritransPayment(emojiInfo, nCheerAmount, cardInfo, elCheerNowPayment) {
        const postData = {
            "token_api_key": "cd76ca65-7f54-4dec-8ba3-11c12e36a548",
            "card_number": cardInfo.number,
            "card_expire": cardInfo.expire,
            "security_code": cardInfo.securityCode,
            "lang": "ja",
        };
        const apiUrl = "https://api.veritrans.co.jp/4gtoken";

        // $.ajaxがクロスドメインでうまく動かなかったので、XMLHttpRequestを使っている。
        let xhr = new XMLHttpRequest();
        xhr.open('POST', apiUrl, true);
        xhr.setRequestHeader('Accept', 'application/json');
        xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
        xhr.addEventListener('loadend', function () {
            if (xhr.status === 0) {
                DispMsg("<%=_TEX.T("CardInfoDlg.Err.MDKTokenConnection")%>");
                elCheerNowPayment.hide();
                return false;
            }
            const response = JSON.parse(xhr.response);
            const agentInfo = createAgentInfo(AGENT.VERITRANS, response.token, null);
            if (xhr.status === 200) {
                SendEmojiAjax(emojiInfo, nCheerAmount, agentInfo, cardInfo, elCheerNowPayment);
            } else {
                //console.log(response);
                DispMsg("<%=_TEX.T("CardInfoDlg.Err.MDKTokenErr")%>" + "(" + response.message + ")");
                if (elCheerNowPayment != null) {
                    elCheerNowPayment.hide();
                }
            }
        });
        xhr.send(JSON.stringify(postData));
    }
     */

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
                "holdername": "DUMMY",
            };

            EpsilonToken.init(contructCode);

            // epsilonTradeを無名関数で定義するとコールバックしてくれない。
            // global領域に関数を定義し、関数名を引数指定しないとダメ。
            EpsilonToken.getToken(cardObj , epsilonTrade);
        }
    }


    function SendEmoji(nContentId, strEmoji, nUserId, elThis) {
        const emojiInfo = {
            "contentId": nContentId,
            "emoji": strEmoji,
            "userId": nUserId,
        };

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

        if(!$(elThis).parent().hasClass('Cheer')) {
            SendEmojiAjax(emojiInfo, null, null, null, null);
        } else {
            Swal.fire({
                html: getAmountDlgHtml(strEmoji),
                focusConfirm: false,
                showCloseButton: true,
                showCancelButton: false,
                confirmButtonText: "<%=_TEX.T("CheerDlg.Send")%>",
                preConfirm: () => {
                    return {
                        amount: $("#cheer_amount").val(),
                    };
                },
            }).then(formValues => {
                // キャンセル
                if(formValues.dismiss){return false;}

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
                        // クレジットカード情報入力ダイアログを表示、
                        // 入力内容を代理店に送信し、Tokenを取得する。
                        Swal.fire({
                            html: getRegistCreditCardDlgHtml(strEmoji, nCheerAmount),
                            focusConfirm: false,
                            showCloseButton: true,
                            showCancelButton: true,
                            preConfirm: () => {
                                // 入力内容の検証
                                const vals = {
                                    cardNum: $("#card_number").val(),
                                    cardExp: $("#cc_exp").val(),
                                    cardSec: $("#cc_csc").val(),
                                }

                                // カード番号
                                if (vals.cardNum === '') {
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardNumber.Empty")%>');
                                }
                                const validateCreditCardResult = $("#card_number").validateCreditCard(
                                    { accept: [
                                            'visa', //'mastercard', 'jcb', 'amex', 'diners_club_international'
                                        ] });
                                if(!validateCreditCardResult.valid){
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardNumber.Invalid")%>');
                                }
                                if (vals.cardExp === '') {
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardExp.Empty")%>');
                                }

                                // 有効期限 use dayjs
                                const MM = Number(vals.cardExp.split('/')[0]);
                                const YY = Number(vals.cardExp.split('/')[1]);
                                const expDay = dayjs("20" + YY + "-" + MM + "-01");
                                if(isNaN(MM)||isNaN(YY)||!expDay){
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardExp.FormatErr")%>');
                                }
                                const now = dayjs();
                                const limit = now.add(60, 'day');
                                if(limit>expDay){
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardExp.Invalid")%>');
                                }

                                // セキュリティーコード
                                if (vals.cardSec === ''){
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardSecCode.Empty")%>');
                                }
                                if (/^\d+$/.exec(vals.cardSec) == null){
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardSecCode.CharKindErr")%>');
                                }
                                if (vals.cardSec.length < 3){
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardSecCode.LengthErr")%>');
                                }

                                // 同意チェックボックス
                                if(!$("#cc_agree1").prop('checked')){
                                    return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.Agree")%>');
                                }

                                return vals;
                            },
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
        }
        return false;
    }
</script>
