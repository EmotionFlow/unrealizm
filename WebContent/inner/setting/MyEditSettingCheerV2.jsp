<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String strCheerPointTotal = String.format("%,d",cResults.m_nCheerPoint);
    String strPaymentYenTotal = String.format("%,d",cResults.m_nCheerPoint-300);
%>
<script>
    const LOCAL_STORAGE_KEY_RECV_ACC_INFO = 'RECV_ACC_INFO';

    function getReceiveCheerPointDlgHtml(amount){
        return `
<style>
	.BankInfoTitle{padding: 10px 0 0 0;}
	.BankInfoInfo{font-size: 12px; text-align: left;}
	.BankInfoInputItem{margin: 4px;}
	.BankInfoInputLabel{font-size: 16px;}
	.BankInfoInputLabel:first-child{padding-top:10px;}
	.BankInfoInfoCheckList{text-align: left; font-size: 16px;}
	.swal2-popup .BankInfoInputItem .swal2-input{margin-top: 4px; font-size: 0.9em; height: 1.825em;}
	.swal2-popup .BankInfoInputItem .swal2-input::placeholder{font-style: italic;}
</style>
<h2 class="BankInfoTitle">
` + '受取口座の指定' + `
</h2>
<div class="BankInfoInfo">
<p>`+ <%=strCheerPointTotal%> + 'ポイントから手数料300ポイントを除いた' + <%=strPaymentYenTotal%> + '円を指定口座に振り込むことができます。'
+`なお、指定できるのは日本国内の銀行口座のみです。</p>
</div>
<div class="BankInfoInputItem">
	<div class="BankInfoInputLabel">金融機関コード</div>
	<input id="FCD" class="swal2-input" style="margin-top: 4px;" maxlength="4" placeholder="0000"/>
	<div class="BankInfoInputLabel">銀行名(日本国内のみ)</div>
	<input id="FNM" class="swal2-input" style="margin-top: 4px;" maxlength="32" placeholder="ポイピク銀行"/>
	<div class="BankInfoInputLabel">支店コード</div>
	<input id="FSUBCD" class="swal2-input" style="margin-top: 4px;" maxlength="3" placeholder="000"/>
	<div class="BankInfoInputLabel">支店名(本店の場合は「本店」)</div>
	<input id="FSUBNM" class="swal2-input" style="margin-top: 4px;" maxlength="3" placeholder="ポイポイ支店"/>
	<div class="BankInfoInputLabel">預金種別</div>
    <select id="ACTYPE" class="swal2-input">
    <option value="0">普通</option>
    <option value="1">当座</option>
    </select>
	<div class="BankInfoInputLabel">口座番号(7桁)</div>
	<input id="ACCD" class="swal2-input" style="margin-top: 4px;" maxlength="7" placeholder="1234567"/>
	<div class="BankInfoInputLabel">口座名義(全角カナ)</div>
	<input id="ACNM" class="swal2-input" style="margin-top: 4px;" maxlength="64" placeholder="ポイピクタロウ"/>
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
    function checkZenKatakanaSwal(str, strItemName){
        str = (str==null)?"":str;
        if(str.match(/^[ァ-ヶー　]+$/)){    //"ー"の後ろの文字は全角スペースです。
            return true;
        }else{
            Swal.showValidationMessage(strItemName + "は全角のカタカナで入力してください");
            return false;
        }
    }

    var g_ChearPointReceived = false;
    function ReceiveCheerPoint() {
        $("#CheerPointExRequest").hide();
        $("#CheerPointExRequesting").show();

        Swal.fire({
            html: getReceiveCheerPointDlgHtml(),
            focusConfirm: false,
            showCloseButton: true,
            showCancelButton: false,
            confirmButtonText: '<%=strPaymentYenTotal%>円を振込申請する',
            onBeforeOpen: () => {
                let storageData = localStorage.getItem(LOCAL_STORAGE_KEY_RECV_ACC_INFO);
                if (storageData) {
                    formData = JSON.parse(storageData);
                    $("#FCD").val(formData.FCD);
                    $("#FNM").val(formData.FNM);
                    $("#FSUBCD").val(formData.FSUBCD);
                    $("#FSUBNM").val(formData.FSUBNM);
                    $("#ACTYPE").val(formData.ACTYPE);
                    $("#ACCD").val(formData.ACCD);
                    $("#ACNM").val(formData.ACNM);
                }
            },
            preConfirm: () => {
                const formData = {
                    'ID'  : <%=cCheckLogin.m_nUserId%>,
                    'FCD' : $("#FCD").val(),
                    'FNM' : $("#FNM").val(),
                    'FSUBCD' : $("#FSUBCD").val(),
                    'FSUBNM' : $("#FSUBNM").val(),
                    'ACTYPE' : $("#ACTYPE").val(),
                    'ACCD' : $("#ACCD").val(),
                    'ACNM' : $("#ACNM").val(),
                    'PT'   : <%=cResults.m_nCheerPoint%>,
                }
                if (!checkEmptySwal(formData.FCD, '金融機関コード')) return false;
                if (!checkNumberOnlySwal(formData.FCD, '金融機関コード')) return false;
                if (!checkEmptySwal(formData.FNM, '金融機関名')) return false;
                if (!checkEmptySwal(formData.FSUBCD, '支店コード')) return false;
                if (!checkNumberOnlySwal(formData.FSUBCD, '支店コード')) return false;
                if (!checkEmptySwal(formData.FSUBNM, '支店名')) return false;
                if (!checkEmptySwal(formData.ACTYPE, '預金種別')) return false;
                if (!checkEmptySwal(formData.ACCD, '口座番号')) return false;
                if (!checkNumberOnlySwal(formData.ACCD, '口座番号')) return false;
                if (!checkEmptySwal(formData.ACNM, '口座名義')) return false;
                if (!checkZenKatakanaSwal(formData.ACNM, '口座名義')) return false;

                let storageData = JSON.stringify(formData);
                localStorage.setItem(LOCAL_STORAGE_KEY_RECV_ACC_INFO, storageData);

                return formData;
            },
        }).then( formData => {
            if(g_ChearPointReceived){
                return false;
            }
            if(formData.dismiss){
                $("#CheerPointExRequesting").hide();
                $("#CheerPointExRequest").show();
                return false;
            }

            g_ChearPointReceived = true;
            $.ajax({
                "type": "post",
                "data": formData.value,
                "dataType": "json",
                "url": "/f/RequestExchangeCheerPointF.jsp",
            }).then(
                data => {
                    if(data.result===0){
                        DispMsg("振込申請を受け付けました");
                        $("#CheerPointExRequesting").hide();
                        $("#CheerPointExRequested").show();
                    } else {
                        DispMsg("エラーが発生しました");
                        $("#CheerPointExRequesting").hide();
                    }
                },
                error => {
                    DispMsg("エラーが発生しました");
                    $("#CheerPointExRequesting").hide();
                    console.log(error);
                }
            )
        });
    }

</script>

<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle">現在のポチ袋ポイント</div>
        <div class="SettingBody">
            <p style="text-align: center; font-size: 17px; margin-bottom: 8px;">
                <%=strCheerPointTotal%>ポイント
            </p>
            <%if(cResults.m_bExchangeCheerPointRequested){%>
                <%=cResults.m_nExchangePoint%>ポイント（<%=cResults.m_nExchangeFee%>円分）について、指定口座への振り込み申請を受付中です。
            <%}else{%>
            <%if(cResults.m_nCheerPoint>=400){%>
            <div style="text-align: center">
                <a id="CheerPointExRequest" class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ReceiveCheerPoint()">
                    ポイントを指定口座に振り込む
                </a>
                <span id="CheerPointExRequesting" style="display: none">申請処理中</span>
                <div id="CheerPointExRequested" style="display: none; text-align: left">
                    <p>振込申請を受け付けました。申請は月末に取りまとめたのち、翌月末までに指定口座へお振込みいたします。</p>
                    <p>なお、申請内容について運営よりメールにてお問い合わせすることがありますので、
                        <a href="/MyEditSettingPcV.jsp?MENUID=MAIL">メールログイン設定画面にて、メールアドレスの登録・確認</a>をお願いいたします。
                    </p>
                </div>
            </div>
            <%}else{%>
                400ポイント以上たまると、振込手数料300ポイント分を引いた金額について、指定口座に振り込むことができます。
            <%}%>
            <%}%>
        </div>
    </div>
</div>
