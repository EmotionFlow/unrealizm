<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
    function checkEmpty(str, strItemName) {
        if (!str) {
            DispMsg(strItemName + "を入力してください");
            return false;
        } else {
            return true;
        }
    }
    function checkNumberOnly(str, strItemName) {
        if (!/^[0-9]+$/.exec(str)) {
            DispMsg(strItemName + "は半角数字で入力してください");
            return false;
        } else {
            return true;
        }
    }
    function UpdateReceivableAccount(){
        const formData = {
            'FCD' : $("#FCD").val(),
            'FNM' : $("#FNM").val(),
            'FSUBCD' : $("#FSUBCD").val(),
            'ACTYPE' : $("#ACTYPE").val(),
            'ACCD' : $("#ACCD").val(),
            'ACNM' : $("#ACNM").val(),
        }
        if (!checkEmpty(formData.FCD, '金融機関コード')) return false;
        if (!checkNumberOnly(formData.FCD, '金融機関コード')) return false;
        if (!checkEmpty(formData.FNM, '金融機関名')) return false;
        if (!checkEmpty(formData.FSUBCD, '支店コード')) return false;
        if (!checkNumberOnly(formData.FSUBCD, '支店コード')) return false;
        if (!checkEmpty(formData.ACTYPE, '預金種別')) return false;
        if (!checkEmpty(formData.ACCD, '口座番号')) return false;
        if (!checkNumberOnly(formData.ACCD, '口座番号')) return false;
        if (!checkEmpty(formData.ACNM, '口座名義')) return false;

        DispMsg("OK");
        return;
        /*
        $.ajaxSingle({
            "type": "post",
            "data": formData,
            "url": "/f/UpdateRecievableAccountF.jsp",
            "dataType": "json",
            "success": function(data) {
                console.log(data);
                if(data.result>0) {
                    DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Ok")%>');
                } else {
                    DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Wrong")%>');
                }
            },
            "error": function(req, stat, ex){
                DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
            }
        });
        */
    }
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle">振込先口座設定</div>
        <div class="SettingBody">
            <div class="SettingBodyTxt" style="margin-top: 10px;">
                金融機関コード
            </div>
            <input id="FCD" type="tel" maxlength="4" class="SettingBodyTxt" />

            <div class="SettingBodyTxt" style="margin-top: 10px;">
                金融機関名
            </div>
            <input id="FNM" maxlength="32" class="SettingBodyTxt" />

            <div class="SettingBodyTxt" style="margin-top: 10px;">
                支店コード
            </div>
            <input id="FSUBCD" type="tel" max="3" class="SettingBodyTxt" />

            <div class="SettingBodyTxt" style="margin-top: 10px;">
                預金種別
            </div>
            <input id="ACTYPE" class="SettingBodyTxt" />

            <div class="SettingBodyTxt" style="margin-top: 10px;">
                口座番号
            </div>
            <input id="ACCD" type="tel" maxlength="7" class="SettingBodyTxt" />

            <div class="SettingBodyTxt" style="margin-top: 10px;">
                口座名義
            </div>
            <input id="ACNM" maxlength="32" class="SettingBodyTxt" />

            <div class="SettingBodyCmd" style="margin-top: 20px;">
                <div id="PasswordMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateReceivableAccount()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
            </div>
        </div>
    </div>
</div>
