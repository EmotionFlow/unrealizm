<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    boolean deletableCreditCardInfo = true;
    Request poipikuRequest = new Request();
    poipikuRequest.clientUserId = checkLogin.m_nUserId;
    final int countOfRequests = poipikuRequest.getCountOfRequestsByStatus(Request.Status.WaitingApproval);
%>

<%if(checkLogin.m_nPassportId==0 && countOfRequests == 0){%>
<script type="text/javascript">
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
</script>
<%}%>

<div class="SettingList">
    <div class="SettingListItem">
        <%if(cResults.m_bCardInfoExist){%>
        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Title")%></div>
        <div class="SettingBody">
            <%if(checkLogin.m_nPassportId==0 && countOfRequests == 0){%>
            <%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Text")%>
            <div class="SettingBodyCmd">
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="DeleteCreditCardInfo()"><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Submit")%></a>
            </div>
            <%}else{%>
            <%if(checkLogin.m_nPassportId > 0){%>
            <p>カード情報がポイパスの加入に使われているため、削除できません。</p>
            <p>ポイパスの加入を解除していただいたのち、解除の翌月に再度こちらのページにアクセスしてください。</p>
            <%}else if(countOfRequests > 0){%>
            <p>承認待ちの送信リクエストがあるため、削除できません。</p>
            <%}%>
            <%}%>
        </div>
        <%}else{%>
        <%=_TEX.T("MyEditSettingPaymentV.CardInfoNotRegisterd")%>
        <%}%>
    </div>
</div>
