<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.Common" %>

<style>
</style>
<script type="text/javascript">
	function toggleSwitchUserList(){
		$("#SwitchUserList").stop(true).animate({'height': 'toggle'});
	}

	function switchUser(userId){
		if (userId < 0) return false;
		$.ajax({
			"type": "post",
			"data": {"SWID" : userId},
			"url": "/f/SwitchUserF.jsp",
			"dataType": "json"
		})
		.then(
			data => {
				if (data.result === <%=Common.API_OK%>) {
					location.href = "/MyIllustListPcV.jsp?ID=" + userId;
					return true;
				} else {
					DispMsg("Error.");
				}
			},
			error => {
				DispMsg("error.");
			}
		);
		return false;
	}

	function _getAddSwitchUserHtml(){
		return `
<style>
	.SwitchUserDlgTitle{padding: 10px 0 0 0; color: #3498db;}
	.SwitchUserDlgInfo{font-size: 13px; text-align: left;}
	.SwitchUserDlgInfo ul {padding-inline-start: 25px;}
	.SwitchUserDlgInfo ol {padding-inline-start: 25px;}
	.swal2-popup .swal2-footer {font-size: 0.75em;}
	.swal2-popup .swal2-actions {margin-top: 0}
	.SwitchUserInputInfo {
		margin-top: 3px;
		margin-bottom: 18px;
		font-size: 13px;
		padding: 8px;
		width: 95%;
		border: 1px solid #3185d6;
		border-radius: 5px;
		text-align: left;
		color: #000000;
	}
</style>
<div class="SwitchUserDlg">

<h2 class="SwitchUserDlgTitle">ユーザー切り替え(β)</h2>
<div class="SwitchUserDlgInfo">
<ul>
	<li>アカウントをグループ化して簡単に切り替えられるようになりました。</li>
	<li>アカウントごとに別のTwitterアカウントと連携しておけば、投稿・閲覧で使い分けることができます。</li>
	<li>紐付けにはメールアドレスとパスワードの登録が必要です。</li>
	<li>１つのアカウントは１つのグループのみ所属できます、別のアカウントと組み合わせたい場合は、一度グループから外す必要があります。</li>
</ul>
</div>

<div class="SwitchUserDlgInfo" style="font-size: 15px; font-weight: 500;">
グループ化したいアカウント
</div>
<div class="SwitchUserInputInfo">
<label for="SwitchUserEmail">email</label>
<input id="SwitchUserEmail" type="email" class="swal2-input">
<label for="SwitchUserPassword">password</label>
<input id="SwitchUserPassword" type="password" class="swal2-input">
</div>

</div>
`;
	}

	function _verifyAddSwitchUserDlgInput(){
		const vals = {
			email: $("#SwitchUserEmail").val(),
			password: $("#SwitchUserPassword").val(),
		}
		if (vals.email === '') {
			return Swal.showValidationMessage('<%=_TEX.T("AddSwitchUserDlg.Validation.Email.Empty")%>');
		}
		if (vals.password === '') {
			return Swal.showValidationMessage('<%=_TEX.T("AddSwitchUserDlg.Validation.Password.Empty")%>');
		}
		return vals;
	}

	function addSwitchUser(loginUserId) {
		if (loginUserId<0) return false;
		Swal.fire({
			html: _getAddSwitchUserHtml(),
			focusConfirm: false,
			showConfirmButton: true,
			showCloseButton: true,
			confirmButtonText: '<%=_TEX.T("AddSwitchUserDlg.Submit")%>',
			preConfirm: _verifyAddSwitchUserDlgInput,
		}).then(formValues => {
			// キャンセル
			if(formValues.dismiss){return false;}

			const email = String(formValues.value.email);
			const password = String(formValues.value.password);

			$.ajax({
				"type": "post",
				"data": {"ID": loginUserId, "EM": email, "PW": password},
				"url": "/f/AddSwitchUserF.jsp",
				"dataType": "json"
			})
			.then(
				data => {
					if (data.result === <%=Common.API_OK%>) {
						location.href = "/MyIllustListPcV.jsp?ID=" + userId;
						return true;
					} else {
						DispMsg("Error.");
					}
				},
				error => {
					DispMsg("error.");
				}
			);


		});
	}
</script>