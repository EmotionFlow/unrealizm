<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<script type="text/javascript">
    function DeleteCreditCardInfo(){
        $.ajax({
            "type": "post",
            "data": {"ID": <%=cCheckLogin.m_nUserId%>},
            "url": "/f/DeleteCreditCardInfoF.jsp",
            "dataType": "json",
        }).then(
            data => {
                if(data){
                    DispMsg("<%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Success")%>");
                    location.reload();
                }else{
                    DispMsg("<%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Err")%>");
                }
            },
            error => {
                DispMsg("<%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Err")%>");
            }
        )
    }
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <%if(cResults.m_bCardInfoExist){%>
        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Title")%></div>
        <div class="SettingBody">
            <%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Text")%>
            <div class="SettingBodyCmd">
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="DeleteCreditCardInfo()"><%=_TEX.T("MyEditSettingPaymentV.DeleteCardInfo.Submit")%></a>
            </div>
        </div>
        <%}else{%>
        <%=_TEX.T("MyEditSettingPaymentV.CardInfoNotRegisterd")%>
        <%}%>
    </div>
</div>
