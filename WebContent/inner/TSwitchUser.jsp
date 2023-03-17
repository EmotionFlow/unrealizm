<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.Common" %>

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
					clearSearchCache();
					location.href = "/MyIllustListV.jsp?ID=" + userId;
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
	.SwitchUserForgetPassword{
		text-align: right;
		display: block;color: #3498db;
		width: 100%;
	}
</style>
<div class="SwitchUserDlg">

<h2 class="SwitchUserDlgTitle"><%=_TEX.T("SwitchAccountDlg.Title")%></h2>

<div class="SwitchUserDlgInfo" style="margin: 6px 0 16px 0;">
<%=_TEX.T("SwitchAccountDlg.Info01")%>
</div>

<div class="SwitchUserDlgInfo" style="font-size: 15px; font-weight: 500;">
<%=_TEX.T("SwitchAccountDlg.Info02")%>
</div>
<div class="SwitchUserInputInfo">
<div style="margin: 0 0 18px 0;">
</div>
<label for="SwitchUserEmail"><%=_TEX.T("SwitchAccountDlg.Info03")%></label>
<input id="SwitchUserEmail" type="email" class="swal2-input">
<label for="SwitchUserPassword"><%=_TEX.T("SwitchAccountDlg.Info04")%></label>
<input id="SwitchUserPassword" type="password" class="swal2-input">
<a href="/ForgetPasswordPcV.jsp" class="SwitchUserForgetPassword"><%=_TEX.T("SwitchAccountDlg.Info05")%></a>
</div>
</div>
`;
	}

	function _getAddSwitchUserFooterHtml(){
		return `<ul>
	<li><%=_TEX.T("SwitchAccountDlg.Footer01")%></li>
	<li><%=_TEX.T("SwitchAccountDlg.Footer02")%></li>
	<li><%=_TEX.T("SwitchAccountDlg.Footer03")%></li>
</ul>
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
			footer: _getAddSwitchUserFooterHtml(),
			focusConfirm: false,
			showConfirmButton: true,
			showCloseButton: true,
			confirmButtonText: '<%=_TEX.T("AddSwitchUserDlg.Submit")%>',
			preConfirm: _verifyAddSwitchUserDlgInput,
		}).then(formValues => {
			if(formValues.dismiss){return false;}

			const email = String(formValues.value.email);
			const password = String(formValues.value.password);

			DispMsgStatic("<%=_TEX.T("SwitchAccount.Processing")%>");

			$.ajax({
				"type": "post",
				"data": {"ID": loginUserId, "EM": email, "PW": password},
				"url": "/f/AddSwitchUserF.jsp",
				"dataType": "json"
			})
			.then(
				data => {
					if (data.result === <%=Common.API_OK%>) {
						HideMsgStatic();
						clearSearchCache();
						location.href = "/MyIllustListV.jsp?ID=" + data.user_id;
						return true;
					} else {
						switch (data.error_detail_code) {
							case <%=AddSwitchUserC.ErrorDetail.AuthError.getCode()%> :
								DispMsg("<%=_TEX.T("SwitchAccount.Error.AuthError")%>");
								break;
							case <%=AddSwitchUserC.ErrorDetail.FoundMe.getCode()%> :
								DispMsg("<%=_TEX.T("SwitchAccount.Error.FoundMe")%>");
								break;
							case <%=AddSwitchUserC.ErrorDetail.FoundOtherGroup.getCode()%> :
								DispMsg("<%=_TEX.T("SwitchAccount.Error.FoundOtherGroup")%>");
								break;
							default:
								break;
						}
						return false;
					}
				},
				error => {
					DispMsg("error.");
					return false;
				}
			);
		});
	}

	function removeSwitchUser(removeUserId, elThis) {
		if (removeUserId<0) return false;

		if (!window.confirm("<%=_TEX.T("SwitchAccount.Remove.Confirm")%>")){
			return false;
		}

		$.ajax({
			"type": "post",
			"data": {"ID": removeUserId},
			"url": "/f/RemoveSwitchUserF.jsp",
			"dataType": "json"
		})
		.then(
			data => {
				if (data.result === <%=Common.API_OK%>) {
					$(elThis).parents(".SwitchUserItem").stop(true).animate({'height': 'hide'});
					let elAddUser = $("#SwitchUserItemAddUser");
					elAddUser.show(400, () => {elAddUser.css('display', 'flex');});
					return true;
				} else {
					switch (data.error_detail_code) {
						case <%=RemoveSwitchUserC.ErrorDetail.RemoveMe.getCode()%> :
							DispMsg("RemoveMe.");
							break;
						case <%=RemoveSwitchUserC.ErrorDetail.NotFound.getCode()%> :
							DispMsg("NotFound.");
							break;
						default:
							DispMsg("Error.");
							break;
					}
					return false;
				}
			},
			error => {
				DispMsg("error.");
				return false;
			}
		);
	}
</script>
