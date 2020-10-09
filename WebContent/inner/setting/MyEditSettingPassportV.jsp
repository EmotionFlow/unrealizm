<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<script type="text/javascript">
    function DeleteCreditCardInfo(){
    }
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Title")%></div>
        <%if(cResults.m_cPassport.m_status == Passport.Status.NotMember) {%>
        <div class="SettingBody">
            <%=_TEX.T("MyEditSettingPassportV.Text")%>
            <div class="SettingBodyCmd">
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="">
                    ポイパスを購入する
                </a>
            </div>
        </div>
        <%}%>
    </div>
</div>
