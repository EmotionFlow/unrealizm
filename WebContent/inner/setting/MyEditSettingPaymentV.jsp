<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Request poipikuRequest = new Request();
    poipikuRequest.clientUserId = checkLogin.m_nUserId;
    final int countOfRequests = poipikuRequest.getCountOfRequestsByStatus(Request.Status.WaitingApproval);
    CreditCard creditCard = null;
    if (cResults.m_bCardInfoExist) {
        creditCard = new CreditCard(checkLogin.m_nUserId, Agent.EPSILON);
        creditCard.selectByUserIdAgentId();
    }
%>

<%@ include file="/inner/TCreditCard.jsp"%>
<script type="text/javascript">
    <%if(checkLogin.m_nPassportId==0 && countOfRequests == 0){%>
    function DeleteCreditCardInfo() {
        $.ajax({
            "type": "post",
            "data": {"ID": <%=checkLogin.m_nUserId%>},
            "url": "/f/DeleteCreditCardInfoF.jsp",
            "dataType": "json",
        }).then(
            data => {
                if (data) {
                    DispMsg("<%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Success")%>");
                    setTimeout("location.reload()", 2000);
                } else {
                    DispMsg("<%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Err")%>");
                }
            },
            error => {
                DispMsg("<%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Err")%>");
            }
        )
    }
    <%}%>
    <%if(checkLogin.m_nPassportId > 0){%>
    let g_changeCardEpsilonInfo = { "cardInfo": null };
    function _sendGiftAjax(giftInfo, agentInfo, cardInfo) {
        $.ajax({
            "type": "post",
            "data": {
                "AID": agentInfo == null ? '' :  agentInfo.agentId,
                "TKN": agentInfo == null ? '' : agentInfo.token,
                "EXP": cardInfo == null ? '' : cardInfo.expire,
                "SEC": cardInfo == null ? '' : cardInfo.securityCode,
            },
            "url": "/f/ChangeCreditCardInfoF.jsp",
            "dataType": "json",
        }).then( data => {
                $("#DispMsg").slideUp(200, () => {
                    cardInfo = null;
                    if (data.result > 0) {
                        DispMsg('<%=_TEX.T("MyEditSettingPaymentV.ChangeCard.Done")%>', 4000);
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
                setTimeout(()=>{location.reload()}, 3000);
            },
            error => {
                cardInfo = null;
                DispMsg("<%=_TEX.T("CheerDlg.Err.PoipikuSrv")%>");
                return false;
            }
        );
    }
    function _changeCardEpsilonTrade(response){
        if(g_changeCardEpsilonInfo.cardInfo.number){
            g_changeCardEpsilonInfo.cardInfo.number = null;
        }

        if( response.resultCode !== '000' ){
            window.alert("<%=_TEX.T("TSendGift.ErrorOccurred")%>");
            console.log(response.resultCode);
            g_changeCardEpsilonInfo.elCheerNowPayment.hide();
        }else{
            const agentInfo = createAgentInfo(
                    AGENT.EPSILON, response.tokenObject.token,
                    response.tokenObject.toBeExpiredAt);
            _sendGiftAjax(g_changeCardEpsilonInfo.giftInfo, agentInfo, g_changeCardEpsilonInfo.cardInfo);
        }
    }

    function _changeCardEpsilon(_cardInfo){
        DispMsgStatic("<%=_TEX.T("MyEditSettingPaymentV.ChangeCard.Processing")%>");
        g_changeCardEpsilonInfo.cardInfo = _cardInfo;

        const contractCode = "68968190";
        let cardObj = {
            "cardno": String(_cardInfo.number),
            "expire": String('20' + _cardInfo.expire.split('/')[1] +  _cardInfo.expire.split('/')[0]),
            "securitycode": String(_cardInfo.securityCode),
        };
        EpsilonToken.init(contractCode);
        EpsilonToken.getToken(cardObj , _changeCardEpsilonTrade);
    }

    function changeCreditCardInfo() {
        let cardInfo = {
            "number": null,
            "expire": null,
            "securityCode": null,
            "holderName": null,
        };
        const title = "<%=_TEX.T("MyEditSettingPaymentV.ChangeCard.Dlg.Title")%>";
        const description = "<%=_TEX.T("MyEditSettingPaymentV.ChangeCard.Dlg.Description")%>";
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

            _changeCardEpsilon(cardInfo);
        });
    }
    <%}%>
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <%if(creditCard != null && creditCard.isExist){%>
        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPaymentV.CardExpire.Title")%></div>
        <div class="SettingBody">
            <%=creditCard.getExpireDateTime().format(DateTimeFormatter.ofPattern("MM/yyyy"))%>
            <%if(creditCard.isInvalid){%>
            <span style="color: #f27474"><%=_TEX.T("MyEditSettingPaymentV.CardExpire.Invalid")%></span>
            <div><%=_TEX.T("MyEditSettingPaymentV.CardExpire.Invalid.Message")%></div>
            <%}else if(creditCard.isExpired(0)){%>
            <span style="color: #f27474"><%=_TEX.T("MyEditSettingPaymentV.CardExpire.Expired")%></span>
            <%if(checkLogin.m_nPassportId > 0){%>
            <div><%=_TEX.T("MyEditSettingPaymentV.CardExpire.Expired.Message")%></div>
            <%}%>
            <%}%>
        </div>

        <%if(checkLogin.m_nPassportId > 0){%>
        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPaymentV.ChangeCard.Title")%></div>
        <div class="SettingBody">
            <%=_TEX.T("MyEditSettingPaymentV.ChangeCard.Text")%>
            <div class="SettingBodyCmd">
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="changeCreditCardInfo()"><%=_TEX.T("MyEditSettingPaymentV.ChangeCard.Submit")%></a>
            </div>
        </div>
        <%}%>

        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Title")%></div>
        <div class="SettingBody">
            <%if(checkLogin.m_nPassportId==0 && countOfRequests == 0){%>
            <%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Text")%>
            <div class="SettingBodyCmd">
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="DeleteCreditCardInfo()"><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Submit")%></a>
            </div>
            <%}else{%>
            <%if(checkLogin.m_nPassportId > 0){%>
            <p><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Cannot.Poipass01")%></p>
            <p><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Cannot.Poipass02")%></p>
            <%}else if(countOfRequests > 0){%>
            <p><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Cannot.Request")%></p>
            <%}%>
            <%}%>
        </div>
        <%}else{%>
        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPaymentV.CardInfo")%></div>
        <div class="SettingBody">
        <%=_TEX.T("MyEditSettingPaymentV.CardInfoNotRegisterd")%>
        </div>
        <%}%>
    </div>
</div>
