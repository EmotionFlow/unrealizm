<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
%>

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
                    DispMsg('自動決済に使っていたカード情報を削除しました。');
                }else{
                    DispMsg('エラーが発生しました');
                }
            },
            error => {
                DispMsg('エラーが発生しました');
            }
        )
    }
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <%if(cResults.m_bCardInfoExist){%>
        <div class="SettingListTitle">カード情報削除</div>
        <div class="SettingBody">
            決済に使用しているクレジットカードカード情報を削除します。
            <div class="SettingBodyCmd">
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="DeleteCreditCardInfo()">削除する</a>
            </div>
        </div>
        <%}else{%>
            現在カード情報が登録されていません。リアクションと一緒にポチ袋を送ると、カード情報が登録されます。
        <%}%>
    </div>
</div>
