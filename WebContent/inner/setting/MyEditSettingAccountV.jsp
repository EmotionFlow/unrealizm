<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
    function Logout() {
        $.ajaxSingle({
            "type": "post",
            "data": {"ID":<%=cCheckLogin.m_nUserId%>},
            "url": "/f/LogioutF.jsp",
            "dataType": "json",
            "success": function(data) {
                if(data.result>0) {
                    deleteCookie('POIPIKU_LK');
                    location.href="/";
                }
            },
            "error": function(req, stat, ex){
                DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
            }
        });
    }

    function CheckDeregist(){
        if(!$("#CheckDeregistCheckBox").prop('checked')) return;
        if(window.confirm('<%=_TEX.T("EditSettingV.DeleteAccount.CheckDeregist")%>')){
            $.ajaxSingle({
                "type": "post",
                "data": {"ID":<%=cCheckLogin.m_nUserId%>},
                "url": "/f/DeleteUserF.jsp",
                "dataType": "json",
                "success": function(data) {
                    if(data.result>0) {
                        deleteCookie('POIPIKU_LK');
                        location.href="/";
                    }
                },
                "error": function(req, stat, ex){
                    DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
                }
            });
        }
    }

    function CheckDeregist_checkbox() {
        if ($("#CheckDeregistCheckBox").prop('checked')) {
            $("#CheckDeregist").prop("disabled", false);
            $("#CheckDeregist").removeClass("Disabled");
        } else {
            $("#CheckDeregist").prop("disabled", true);
            $("#CheckDeregist").addClass("Disabled");
        }
    }
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle"><%=_TEX.T("EditSettingV.Logout")%></div>
        <div class="SettingBody">
            <div class="SettingBodyCmd ">
                <div class="RegistMessage" ></div>
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="Logout()"><%=_TEX.T("EditSettingV.Logout")%></a>
            </div>
        </div>
    </div>

    <div class="SettingListItem">
        <div class="SettingListTitle"><%=_TEX.T("EditSettingV.DeleteAccount")%></div>
        <div class="SettingBody">
            <%if(cResults.m_cPassport.m_status != Passport.Status.NotMember){%>
            ポイパス購入中のため、退会処理ができません。まずポイパスの定期購入を解除していただいたのち、会員期間が終わりましたら、再度こちらのページへアクセスしてください。
            <%}else if(cResults.m_bCardInfoExist){%>
            支払いカード情報が登録されているため、退会処理ができません。支払情報画面からカード情報を削除していただいたのち、再度こちらのページへアクセスしてください。
            <%}else{%>
            <%=_TEX.T("EditSettingV.DeleteAccount.Message")%>
            <div class="SettingBodyCmd">
                <div id="DeleteAccountMessage" class="RegistMessage" >
                    <label>
                        <input id="CheckDeregistCheckBox" type="checkbox" onclick="CheckDeregist_checkbox();" />
                        <%=_TEX.T("EditSettingV.DeleteAccount.CheckButton")%>
                    </label>
                </div>
                <a id="CheckDeregist" class="BtnBase SettingBodyCmdRegist Disabled" onclick="CheckDeregist()"><%=_TEX.T("EditSettingV.DeleteAccount.Button")%></a>
            </div>
            <% } %>
        </div>
    </div>
</div>
