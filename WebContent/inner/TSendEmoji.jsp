<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
    function SendEmojiAjax(nContentId, strEmoji, nUserId, nAmount, strMdkToken, strCardExp, strCardSec, elCheerNowPayment) {
        let amount = -1;
        let token = "";
        let exp = "";
        let sec = "";
        if(nAmount!=null) {amount=nAmount}
        if(strMdkToken!=null) {token=strMdkToken;}
        if(strCardExp!=null) {exp=strCardExp;}
        if(strCardSec!=null) {sec=strCardSec;}

        $.ajax({
            "type": "post",
            "data": {
                "IID": nContentId, "EMJ": strEmoji,
                "UID": nUserId, "AMT": nAmount,
                "MDK": token, "EXP": exp, "SEC": sec,
            },
            "url": "/f/SendEmojiF.jsp",
            "dataType": "json",
        }).then( data => {
                if (data.result_num > 0) {
                    var $objResEmoji = $("<span/>").addClass("ResEmoji").html(data.result);
                    $("#ResEmojiAdd_" + nContentId).before($objResEmoji);
                    if (vg) vg.vgrefresh();
                    if(nAmount>0) {
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
                        case -99:
                            DispMsg("<%=_TEX.T("CheerDlg.Err.AuthOther")%>");
                            break;
                    }
                    if (elCheerNowPayment != null) {
                        elCheerNowPayment.hide();
                    }
                }},
            error => {
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
	<img src="/img/credit_card_logos.png" width="170px"/>
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
<label><input id="cc_agree1" type="checkbox"/><%=_TEX.T("CardInfoDlg.Agree")%></label>
</div>
`;
    }


    function SendEmoji(nContentId, strEmoji, nUserId, elThis) {
        let elCheerNowPayment = $(elThis).parent().parent().children('div.ResEmojiCheerNowPayment');
        if(elCheerNowPayment.css('display') !== 'none'){
            console.log("決済処理中");
            return;
        }

        if(!$(elThis).parent().hasClass('Cheer')) {
            SendEmojiAjax(nContentId, strEmoji, nUserId, null, null, null);
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
                // 与信済みであるかを検索
                $.ajax({
                    "type": "get",
                    "url": "/f/CheckCreditCardF.jsp",
                    "dataType": "json",
                }).then(function (data) {
                    const result = Number(data.result);
                    if (typeof (result) === "undefined" || result == null || result === -1) {
                        return false;
                    } else if (result === 0) {
                        // クレカ入力ダイアログを表示して、MDKToken取得
                        Swal.fire({
                            html: getRegistCreditCardDlgHtml(strEmoji, nCheerAmount),
                            focusConfirm: false,
                            showCloseButton: true,
                            showCancelButton: true,
                            preConfirm: () => {
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
                                            'visa', 'mastercard', 'jcb', 'amex', 'diners_club_international'
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
                            // キャンセルボタンクック
                            if(formValues.dismiss){
                                elCheerNowPayment.hide();
                                return false;
                            }

                            const postData = {
                                "token_api_key": "cd76ca65-7f54-4dec-8ba3-11c12e36a548",
                                "card_number": formValues.value.cardNum,
                                "card_expire": formValues.value.cardExp,
                                "security_code": formValues.value.cardSec,
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
                                if (xhr.status == 200) {
                                    SendEmojiAjax(nContentId, strEmoji, nUserId, nCheerAmount, response.token,
                                        formValues.value.cardExp, formValues.value.cardSec, elCheerNowPayment);
                                } else {
                                    //console.log(response);
                                    DispMsg("<%=_TEX.T("CardInfoDlg.Err.MDKTokenErr")%>" + "(" + response.message + ")");
                                    if (elCheer != null) {
                                        elCheerNowPayment.hide();
                                    }
                                }
                            });
                            xhr.send(JSON.stringify(postData));
                        });
                    } else if (result == 1) {
                        console.log("登録済み");
                        SendEmojiAjax(nContentId, strEmoji, nUserId, nCheerAmount,
                            null, null, null, elCheerNowPayment);
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
