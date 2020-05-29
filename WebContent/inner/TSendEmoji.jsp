<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
    function SendEmojiAjax(nContentId, strEmoji, nUserId, nAmount, strMdkToken, strCardExp, strCardSec, elNagesen) {
        let amount = -1;
        let token = "";
        let exp = "";
        let sec = "";
        if(nAmount!=null) {amount=nAmount}
        if(strMdkToken!=null) {token=strMdkToken;}
        if(strCardExp!=null) {exp=strCardExp;}
        if(strCardSec!=null) {sec=strCardSec;}

        let elNagesenNowPayment = null;
        if(elNagesen!=null){
            elNagesenNowPayment = elNagesen.parent().children('div.ResEmojiNagesenNowPayment');
        }

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
                        DispMsg(nAmount + "円のポチ袋 ありがとうございました！");
                        if (elNagesen != null) {
                            elNagesenNowPayment.hide();
                            elNagesen.show();
                        }
                    }
                } else {
                    switch (data.error_code) {
                        case -10:
                            DispMsg("カード認証でエラーが発生しました。もう一度試すか、別のカードをご利用ください。");
                            break;
                        case -20:
                            alert("決済中に深刻なエラーが発生し、決済されているか不明な状態です。大変恐れ入りますが、問い合わせページからご連絡をお願いいたします。");
                            break;
                        case -99:
                            DispMsg("サーバエラーが発生しました。");
                            break;
                    }
                    if (elNagesen != null) {
                        elNagesenNowPayment.hide();
                        elNagesen.show();
                    }
                }},
            error => {
                DispMsg("ポイピクサーバにてエラーが発生しました。");
                if (elNagesen != null) {
                    elNagesenNowPayment.hide();
                    elNagesen.show();
                }
            }
        );
    }

    function getPaymentDlgHtml(strEmoji, nNagesenAmount){
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
` + strEmoji + "と一緒に" + nNagesenAmount + "円分のポチ袋を送ろう！" + `
</h2>
<div class="CardInfoDlgInfo">
	<p>カード情報を入力してOKボタンをクリックすると、指定した金額を、リアクションと一緒に送ることができます。
        ポチ袋は、一度運営にてまとめさせていただいたのち、クリエイターの方に還元されます。</p>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel">クレジットカード番号</div>
	<img src="/img/credit_card_logos.png" width="170px"/>
	<input id="card_number" class="swal2-input" style="margin-top: 4px;" maxlength="16" value="4111111111111111"/>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel">有効期限(MM/YY)</div>
	<input id="cc_exp" class="swal2-input" style="margin-top: 4px;" maxlength="5" value="02/22"/>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel">セキュリティーコード<div/>
	<input id="cc_csc" class="swal2-input" style="margin-top: 4px;" maxlength="4"  value="012"/>
</div>
<div class="CardInfoDlgInfoCheckList">
<label><input id="cc_agree1" type="checkbox"/>利用規約に同意します</label>
</div>
<div class="CardInfoDlgInfoCheckList">
<label><input id="cc_agree2" type="checkbox"/>今後、リアクションするとでこのカードで自動決済することに同意します</label>
</div>
`;
    }


    function SendEmoji(nContentId, strEmoji, nUserId, elThis) {
        let elNagesen = $(elThis).parent().parent().children('.ResEmojiNagesen');
        let elNagesenAmount = elNagesen.children('.NagesenAmount');
        const nNagesenAmount = elNagesenAmount.val();

        let elNagesenNowPayment = elNagesen.parent().children('div.ResEmojiNagesenNowPayment');
        if(elNagesenNowPayment.css('display') !== 'none'){
            console.log("決済処理中");
            return;
        }

        if(elNagesen.css('display')!=='none' && nNagesenAmount > 0){
            if(elNagesen!=null){
                elNagesen.hide();
                elNagesenNowPayment.show();
                elNagesen.children('.NagesenAmount').val("0");
            }

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
                        html: getPaymentDlgHtml(strEmoji, nNagesenAmount),
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
                                return Swal.showValidationMessage('カード番号を入力してください');
                            }
                            const result = $("#card_number").validateCreditCard(
                                { accept: [
                                        'visa', 'mastercard', 'jcb', 'amex', 'diners_club_international'
                                    ] });
                            if(!result.valid){
                                return Swal.showValidationMessage('カード番号に誤りがあるか、取り扱えないカードブランドです。');
                            }
                            if (vals.cardExp === '') {
                                return Swal.showValidationMessage('有効期限を入力してください');
                            }

                            // 有効期限 use dayjs
                            const MM = Number(vals.cardExp.split('/')[0]);
                            const YY = Number(vals.cardExp.split('/')[1]);
                            const expDay = dayjs(`20${YY}-${MM}-01`);
                            if(isNaN(MM)||isNaN(YY)||!expDay){
                                return Swal.showValidationMessage('有効期限は半角で、MM/YYの形式で入力してください。');
                            }
                            const now = dayjs();
                            const limit = now.add(60, 'day');
                            if(limit>expDay){
                                return Swal.showValidationMessage('有効期限が切れているか迫っているため、このカードは登録できません。');
                            }

                            // セキュリティーコード
                            if (vals.cardSec === ''){
                                return Swal.showValidationMessage('セキュリティーコードを入力してください');
                            }
                            if (/^\d+$/.exec(vals.cardSec) == null){
                                return Swal.showValidationMessage('セキュリティーコードは半角数字を入力してください');
                            }
                            if (vals.cardSec.length < 3){
                                return Swal.showValidationMessage('セキュリティーコードの桁数がたりません');
                            }

                            // 同意チェックボックス
                            if(!$("#cc_agree1").prop('checked')||!$("#cc_agree2").prop('checked')){
                                return Swal.showValidationMessage('上記２点に同意のチェックをいただくと、登録と決済ができます。');
                            }

                            return vals;
                        },
                    }).then( formValues => {
                        // キャンセルボタンクック
                        if(formValues.dismiss){
                            if (elNagesen != null) {
                                elNagesenNowPayment.hide();
                                elNagesen.show();
                            }
                            return false;
                        }

                        const postData = {
                            "token_api_key": "cd76ca65-7f54-4dec-8ba3-11c12e36a548",
                            "card_number": formValues.value.cardNum,
                            "card_expire": formValues.value.cardExp,
                            "security_code": formValues.value.cardSec,
                            "lang": "ja",
                        };
                        console.log(postData);
                        const apiUrl = "https://api.veritrans.co.jp/4gtoken";

                        // $.ajaxがクロスドメインでうまく動かなかったので、XMLHttpRequestを使っている。
                        let xhr = new XMLHttpRequest();
                        xhr.open('POST', apiUrl, true);
                        xhr.setRequestHeader('Accept', 'application/json');
                        xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
                        xhr.addEventListener('loadend', function () {
                            if (xhr.status === 0) {
                                DispMsg("決済代行サービスのサーバに接続できませんでした。恐れ入りますが、問い合わせページからご報告いただければ幸いです。");
                                return;
                            }
                            const response = JSON.parse(xhr.response);
                            if (xhr.status == 200) {
                                SendEmojiAjax(nContentId, strEmoji, nUserId, nNagesenAmount, response.token,
                                    formValues.value.cardExp, formValues.value.cardSec, elNagesen);
                            } else {
                                //console.log(response);
                                DispMsg(`カード情報の登録に失敗しました。(${response.message})`);
                                if (elNagesen != null) {
                                    elNagesenNowPayment.hide();
                                    elNagesen.show();
                                }
                            }
                        });
                        xhr.send(JSON.stringify(postData));
                    });
                } else if (result == 1) {
                    console.log("与信済み");
                    SendEmojiAjax(nContentId, strEmoji, nUserId, nNagesenAmount,
                        null, null, null, elNagesen);
                } else {
                    DispMsg("ポイピクのサーバで不明なエラーが発生しました。恐れ入りますが、問い合わせページからご報告いただければ幸いです。");
                }
            }, function (err) {
                console.log("CheckCreditCardF error" + err);
                DispMsg("ポイピクのサーバでエラーが発生しました。恐れ入りますが、問い合わせページからご報告いただければ幸いです。");
            });
        } else {
            SendEmojiAjax(nContentId, strEmoji, nUserId, null, null, null);
        }
        return false;
    }
</script>
