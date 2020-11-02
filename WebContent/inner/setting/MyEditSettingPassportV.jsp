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
                }},
            error => {
                cardInfo = null;
                DispMsg("<%=_TEX.T("PassportDlg.Err.PoipikuSrv")%>");
                if (elPassportNowPayment != null) {
                    elPassportNowPayment.hide();
                }
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
            SendEmojiAjax(_passportInfo, _nPassportAmount, createAgentInfo(AGENT.EPSILON, null, null),
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
        const passportInfo = {
            "passportId": 1,
            "userId": <%=cCheckLogin.m_nUserId%>,
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
                // epsilonPayment(passportInfo, nPassportAmount, cardInfo, elPassportNowPayment);
            } else if (result === 0) {
                const title = "ポイパス定期購入";
                const description = "定期購入するためのカード情報を入力してください。入力されたカード情報から、毎月300円(税込)が課金されます。";
                // クレジットカード情報入力ダイアログを表示、
                // 入力内容を代理店に送信し、Tokenを取得する。
                Swal.fire({
                    html: getRegistCreditCardDlgHtml(title, description),
                    focusConfirm: false,
                    showCloseButton: true,
                    showCancelButton: true,
                    // TODO comment in
                    //preConfirm: verifyCardDlgInput,
                }).then(formValues => {
                    // キャンセルボタンがクリックされた
                    if (formValues.dismiss) {
                        elPassportNowPayment.hide();
                        formValues.value.cardNum = '';
                        formValues.value.cardExp = '';
                        formValues.value.cardSec = '';
                        return false;
                    }

                    // cardInfo.number = String(formValues.value.cardNum);
                    // cardInfo.expire = String(formValues.value.cardExp);
                    // cardInfo.securityCode = String(formValues.value.cardSec);
                    // TODO 元に戻す
                    cardInfo.number = '4111111111111111';
                    cardInfo.expire = '01/24';
                    cardInfo.securityCode = '012';

                    // 念のため不要になった変数を初期化
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
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Title")%></div>
        <%if(cResults.m_cPassport.m_status == Passport.Status.NotMember) {%>
        <div class="SettingBody">
            <%=_TEX.T("MyEditSettingPassportV.Text")%>
            <div class="SettingBodyCmd">
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="BuyPassport()">
                    ポイパスを購入する
                </a>
            </div>
            <div id="PassportNowPayment" style="display:none">
                <span class="CheerLoading"></span><span>支払処理中</span>
            </div>
        </div>
        <%}%>
    </div>
</div>
