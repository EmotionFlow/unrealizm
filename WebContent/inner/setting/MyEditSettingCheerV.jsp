<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String strCheerPointTotal = String.format("%,d",cResults.m_nCheerPoint);
String strPaymentYenTotal = String.format("%,d",cResults.m_nCheerPoint-300);
CheerPointExchangeRequest exchangeRequest = cResults.exchangeRequest;
%>
<script>
const LOCAL_STORAGE_KEY_RECV_ACC_INFO = 'RECV_ACC_INFO';

function getReceiveCheerPointDlgHtml(amount){
return `
<style>
	.AccountInfoTitle{padding: 10px 0 0 0;}
	.AccountInfoInfo{font-size: 12px; text-align: left;}
	.AccountInfoInputItem{margin: 4px;}
	.AccountInfoInputLabel{font-size: 16px;}
	.AccountInfoInputLabel:first-child{padding-top:10px;}
	.AccountInfoInfoCheckList{text-align: left; font-size: 16px;}
	.swal2-popup .AccountInfoInputItem .swal2-input{margin-top: 4px; font-size: 0.9em; height: 1.825em;}
	.swal2-popup .AccountInfoInputItem .swal2-input::placeholder{font-style: italic;}
</style>
<h2 class="AccountInfoTitle">
` + '受取口座の指定' + `
</h2>
<div class="AccountInfoInfo">
<p>`+ '<%=strCheerPointTotal%>' + 'ポイントから金融機関への振込手数料300円を除いた' + '<%=strPaymentYenTotal%>' + '円を指定口座に振り込むことができます。'
						+`なお、指定できるのは日本国内の銀行口座のみです。銀行口座情報が間違っていた場合、手数料＋銀行から請求される組戻手数料の実費(銀行により異なりますが700円〜1000円程度)をご負担頂くことになります。十分ご確認の上、申請をお願いします。</p>
</div>
<div class="AccountInfoInputItem">
	<div class="AccountInfoInputLabel">金融機関コード</div>
	<input id="FCD" class="swal2-input" style="margin-top: 4px;" maxlength="4" placeholder="0000"/>
	<div class="AccountInfoInputLabel">銀行名(日本国内のみ)</div>
	<input id="FNM" class="swal2-input" style="margin-top: 4px;" maxlength="32" placeholder="ポイピク銀行"/>
	<div class="AccountInfoInputLabel">支店コード</div>
	<input id="FSUBCD" class="swal2-input" style="margin-top: 4px;" maxlength="3" placeholder="000"/>
	<div class="AccountInfoInputLabel">支店名(本店の場合は「本店」)</div>
	<input id="FSUBNM" class="swal2-input" style="margin-top: 4px;" maxlength="3" placeholder="ポイポイ支店"/>
	<div class="AccountInfoInputLabel">預金種別</div>
		<select id="ACTYPE" class="swal2-input">
		<option value="1">普通</option>
		<option value="2">当座</option>
		</select>
	<div class="AccountInfoInputLabel">口座番号(7桁)</div>
	<input id="ACCD" class="swal2-input" style="margin-top: 4px;" maxlength="7" placeholder="1234567"/>
	<div class="AccountInfoInputLabel">口座名義(全角カナ)</div>
	<input id="ACNM" class="swal2-input" style="margin-top: 4px;" maxlength="64" placeholder="ポイピクタロウ"/>
</div>
`;
}

function getAccountInfoDlgHtml() {
return `
<style>
.AccountInfoDlg {border-collapse: collapse; border: 1px #6d6965 solid; width: 100%; text-align: left}
.AccountInfoDlg tr {border: 1px #6d6965 solid;}
.AccountInfoDlg tr td {border: 1px #6d6965 solid;}
</style>
<table class="AccountInfoDlg">
	<tbody>
	<tr><td>金融機関コード</td><td><%=exchangeRequest.fCode%></td></tr>
	<tr><td>銀行名</td><td><%=exchangeRequest.fName%></td></tr>
	<tr><td>支店コード</td><td><%=exchangeRequest.fSubcode%></td></tr>
	<tr><td>支店名</td><td><%=exchangeRequest.fSubname%></td></tr>
	<tr><td>預金種別</td><td><%=exchangeRequest.acType==1?"普通":"当座"%></td></tr>
	<tr><td>口座番号</td><td><%=exchangeRequest.acCode%></td></tr>
	<tr><td>口座名</td><td><%=exchangeRequest.acName%></td></tr>
	</tbody>
<table>
`;
}

function dispAccountInfo(){
	Swal.fire({
		html: getAccountInfoDlgHtml(),
		focusConfirm: false,
		showCloseButton: true,
		showCancelButton: false,
		showConfirmButton: false,
	});
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

function checkZenKatakanaSwal(str, strItemName) {
	str = (str == null) ? "" : str;
	if (str.match(/^[ァ-ヶー　]+$/)) {    //"ー"の後ろの文字は全角スペースです。
		return true;
	} else {
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
				'ID': <%=checkLogin.m_nUserId%>,
				'FCD': $("#FCD").val(),
				'FNM': $("#FNM").val(),
				'FSUBCD': $("#FSUBCD").val(),
				'FSUBNM': $("#FSUBNM").val(),
				'ACTYPE': $("#ACTYPE").val(),
				'ACCD': $("#ACCD").val(),
				'ACNM': $("#ACNM").val(),
				'PT': <%=cResults.m_nCheerPoint%>,
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
	}).then(formData => {
		if (g_ChearPointReceived) {
			return false;
		}
		if (formData.dismiss) {
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
				if (data.result === 0) {
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

	<%if (exchangeRequest.messageFromStaff!=null && !exchangeRequest.messageFromStaff.isEmpty()){%>
		<div class="SettingListItem">
			<div class="SettingListTitle">お知らせ (<%=exchangeRequest.updatedAt.toString().substring(0, 10)%>)</div>
			<div class="SettingBody">
				<%=exchangeRequest.messageFromStaff%>
			</div>
			<div style="text-align: right;">
				<a style="text-decoration: underline;" href="javascript:void(0);" onclick="dispAccountInfo();">申請内容を確認する</a>
			</div>
		</div>
	<%}%>

	<div class="SettingListItem">
		<div class="SettingListTitle">現在のポイント</div>
		<div class="SettingBody">
			<p style="text-align: center; font-size: 17px; margin-bottom: 8px;">
				<%=strCheerPointTotal%>ポイント
			</p>
			<%if (exchangeRequest.status == CheerPointExchangeRequest.Status.Waiting) {%>
			<p>
				<%=cResults.m_nExchangePoint%>ポイント（<%=cResults.m_nExchangeFee%>円分）について、指定口座への振り込み申請を受付中です。
			</p>
			<p>申請内容について運営よりメールにてお問い合わせすることがありますので、
				<a href="/MyEditSettingPcV.jsp?MENUID=MAIL" style="text-decoration: underline;">メールログイン設定画面にて、メールアドレスの登録・確認</a>をお願いいたします。
			</p>
			<div style="text-align: right;">
				<a style="text-decoration: underline;" href="javascript:void(0);" onclick="dispAccountInfo();">申請内容を確認する</a>
			</div>
			<%} else {%>
			<%if (cResults.m_nCheerPoint >= 400) {%>
			<div style="text-align: center">
				<a id="CheerPointExRequest" class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
				   onclick="ReceiveCheerPoint()">
					ポイントを指定口座に振り込む
				</a>
				<span id="CheerPointExRequesting" style="display: none">申請処理中</span>
				<div id="CheerPointExRequested" style="display: none; text-align: left">
					<p>振込申請を受け付けました。申請は月末に取りまとめたのち、翌月末までに指定口座へお振込みいたします。</p>
					<p>なお、申請内容について運営よりメールにてお問い合わせすることがありますので、
						<a href="/MyEditSettingPcV.jsp?MENUID=MAIL" style="text-decoration: underline;">メールログイン設定画面にて、メールアドレスの登録・確認</a>をお願いいたします。
					</p>
				</div>
			</div>
			<%} else {%>
			400ポイント以上たまると、指定口座に振り込むことができます。
			<%}%>
			<%}%>
		</div>
	</div>
</div>
