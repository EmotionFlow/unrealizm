<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
    const LOCAL_STORAGE_KEY_RECV_ACC_INFO = 'RECV_ACC_INFO';

    function getReceiveCheerPointDlgHtml(){
        return `
<style>
	.BankInfoTitle{padding: 10px 0 0 0;}
	.BankInfoInfo{font-size: 12px; text-align: left;}
	.BankInfoInputItem{margin: 4px;}
	.BankInfoInputLabel{font-size: 16px;}
	.BankInfoInfoCheckList{text-align: left; font-size: 16px;}
	.swal2-popup .BankInfoInputItem .swal2-input{margin-top: 4px; font-size: 1.1em; height: 1.825em;}
	.swal2-popup .BankInfoInputItem .swal2-input::placeholder{font-style: italic;}
</style>
<h2 class="BankInfoTitle">
` + '受取口座の指定' + `
</h2>
<div class="BankInfoInfo">
	<p>日本国内の口座のみ指定いただけます</p>
</div>
<div class="BankInfoInputItem">
	<div class="BankInfoInputLabel">金融機関コード</div>
	<input id="FCD" class="swal2-input" style="margin-top: 4px;" maxlength="4" placeholder="0000"/>
	<div class="BankInfoInputLabel">金融機関名</div>
	<input id="FNM" class="swal2-input" style="margin-top: 4px;" maxlength="32" placeholder="ポイピク銀行"/>
	<div class="BankInfoInputLabel">支店コード</div>
	<input id="FSUBCD" class="swal2-input" style="margin-top: 4px;" maxlength="3" placeholder="000"/>
	<div class="BankInfoInputLabel">預金種別</div>
    <select id="ACTYPE" class="swal2-input">
    <option value="0">普通</option>
    <option value="1">当座</option>
    </select>
	<div class="BankInfoInputLabel">口座番号</div>
	<input id="ACCD" class="swal2-input" style="margin-top: 4px;" maxlength="7" placeholder="1234567"/>
	<div class="BankInfoInputLabel">口座名義</div>
	<input id="ACNM" class="swal2-input" style="margin-top: 4px;" maxlength="64" placeholder="ポイピク タロウ"/>
</div>
`;
    }

    function checkEmptySwal(str, strItemName) {
        if (!str) {
            Swal.showValidationMessage(strItemName + "を入力してください");
            return false;
        } else {
            return true;
        }
    }
    function checkNumberOnlySwal(str, strItemName) {
        if (!/^[0-9]+$/.exec(str)) {
            Swal.showValidationMessage(strItemName + "は半角数字で入力してください");
            return false;
        } else {
            return true;
        }
    }


    function ReceiveCheerPoint() {
        Swal.fire({
            html: getReceiveCheerPointDlgHtml(),
            focusConfirm: false,
            showCloseButton: true,
            showCancelButton: false,
            confirmButtonText: 'この口座に振り込む',
            onBeforeOpen: () => {
                let storageData = localStorage.getItem(LOCAL_STORAGE_KEY_RECV_ACC_INFO);
                if (storageData) {
                    formData = JSON.parse(storageData);
                    $("#FCD").val(formData.FCD);
                    $("#FNM").val(formData.FNM);
                    $("#FSUBCD").val(formData.FSUBCD);
                    $("#ACTYPE").val(formData.ACTYPE);
                    $("#ACCD").val(formData.ACCD);
                    $("#ACNM").val(formData.ACNM);
                }
            },
            preConfirm: () => {
                const formData = {
                    'FCD' : $("#FCD").val(),
                    'FNM' : $("#FNM").val(),
                    'FSUBCD' : $("#FSUBCD").val(),
                    'ACTYPE' : $("#ACTYPE").val(),
                    'ACCD' : $("#ACCD").val(),
                    'ACNM' : $("#ACNM").val(),
                }
                if (!checkEmptySwal(formData.FCD, '金融機関コード')) return false;
                if (!checkNumberOnlySwal(formData.FCD, '金融機関コード')) return false;
                if (!checkEmptySwal(formData.FNM, '金融機関名')) return false;
                if (!checkEmptySwal(formData.FSUBCD, '支店コード')) return false;
                if (!checkNumberOnlySwal(formData.FSUBCD, '支店コード')) return false;
                if (!checkEmptySwal(formData.ACTYPE, '預金種別')) return false;
                if (!checkEmptySwal(formData.ACCD, '口座番号')) return false;
                if (!checkNumberOnlySwal(formData.ACCD, '口座番号')) return false;
                if (!checkEmptySwal(formData.ACNM, '口座名義')) return false;

                let storageData = JSON.stringify(formData);
                localStorage.setItem(LOCAL_STORAGE_KEY_RECV_ACC_INFO, storageData);

                return formData;
            },
        }).then( formData => {
            // call api
        });
    }

</script>


<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle">現在のポチ袋ポイント</div>
        <div class="SettingBody">
            <p>
                <%=String.format("%,d",cResults.m_nCheerPoint)%>ポイント
            </p>
            <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ReceiveCheerPoint()">
                ポイントを指定口座に振り込む
            </a>
            <p>
                ポチ袋ポイントは、毎月X日に更新されます。
            </p>
        </div>
    </div>
</div>
