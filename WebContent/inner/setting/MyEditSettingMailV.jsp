<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%!
enum EmailStatus {
	UNDEF,
	UNREGISTED,
	COMFIRMATION,
	REGISTED
}
%>
<%
EmailStatus emailState = EmailStatus.UNDEF;
boolean bNotEmailAddress = false;

if (cResults.m_cUser.m_strEmail.contains("@")) {
	bNotEmailAddress = false;
	emailState = EmailStatus.REGISTED;
} else {
	bNotEmailAddress = true;
	emailState = EmailStatus.UNREGISTED;
}

String strEmailState = "";
if (cResults.m_bUpdate) {
	strEmailState = _TEX.T("EditSettingV.Email.EmailState.Confirmation") + cResults.m_strNewEmail;
	emailState = EmailStatus.COMFIRMATION;
}
%>

<script type="text/javascript">
	function getEmail() {
		let strEmail = $("#EM").val();
		if (!strEmail.match(/^([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+$/)) {
			DispMsg("<%=_TEX.T("EditSettingV.Email.Message.Empty")%>");
			strEmail = null;
		}
		return strEmail;
	}

	function getPasswords() {
		const PW = $("#PW").val();
		const PW1 = $("#PW1").val();
		const PW2 = $("#PW2").val();
		if (PW1.length < 4 || PW1.length > 16) {
			DispMsg("<%=_TEX.T("EditSettingV.Password.Message.Empty")%>");
			return null;
		}
		if (PW1 !== PW2) {
			DispMsg("<%=_TEX.T("EditSettingV.Password.Message.NotMatch")%>");
			return null;
		}

		return [PW, PW1, PW2];
	}

	function UpdateEmailAddress() {
		const strEmail = $("#EM").val();
		if (!strEmail.match(/^([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+$/)) {
			DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Empty")%>');
			return false;
		}
		$.ajaxSingle({
			"type": "post",
			"data": {"ID": <%=checkLogin.m_nUserId%>, "EM": strEmail},
			"url": "/f/UpdateEmailAddressF.jsp",
			"dataType": "json",
			"success": function (data) {
				console.log(data);
				if (data.result > 0) {
					DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Confirmation")%>');
				} else {
					DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Exist")%>');
				}
			},
			"error": function (req, stat, ex) {
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
	}

	function UpdatePassword() {
		const PW = $("#PW").val();
		const PW1 = $("#PW1").val();
		const PW2 = $("#PW2").val();
		if (PW1.length < 4 || PW1.length > 16) {
			DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Empty")%>');
			return false;
		}
		if (PW1 !== PW2) {
			DispMsg('<%=_TEX.T("EditSettingV.Password.Message.NotMatch")%>');
			return false;
		}
		$.ajaxSingle({
			"type": "post",
			"data": {"ID": <%=checkLogin.m_nUserId%>, "PW": PW, "PW1": PW1, "PW2": PW2},
			"url": "/api/UpdatePasswordF.jsp",
			"dataType": "json",
			"success": function (data) {
				console.log(data);
				if (data.result > 0) {
					DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Ok")%>');
				} else {
					DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Wrong")%>');
				}
			},
			"error": function (req, stat, ex) {
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
	}

	function UpdateSendEmailMode() {
		const bMode = $('#SendEmailMode').prop('checked');
		$.ajaxSingle({
			"type": "post",
			"data": { "UID": <%=checkLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.SEND_EMAIL_ON%>:<%=CUser.SEND_EMAIL_OFF%> },
			"url": "/f/UpdateSendEmailModeF.jsp",
			"dataType": "json",
			"success": function(data) {
				DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
			},
			"error": function(req, stat, ex){
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
		return false;
	}

</script>

<div class="SettingList">
	<%if (emailState == EmailStatus.UNREGISTED) {%>
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Email.Address")%>
		</div>
		<div class="SettingBody">
			<%=_TEX.T("EditSettingV.Email.Message.Info")%>
			<input id="EM" class="SettingBodyTxt" type="text" value=""/>
			<div class="SettingBodyCmd">
				<div id="MailAdressMessage" class="RegistMessage" style="color: red;"><%=strEmailState%>
				</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
				   onclick="UpdateEmailAddress()"><%=_TEX.T("EditSettingV.Button.Register")%>
				</a>
			</div>
		</div>
	</div>
	<%} else {%>
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Email.Address")%>
		</div>
		<div class="SettingBody">
			<%=_TEX.T("EditSettingV.Email.Message.Info")%>
			<input id="EM" class="SettingBodyTxt" type="text"
				   value="<%=bNotEmailAddress?"":Util.toStringHtmlTextarea(cResults.m_cUser.m_strEmail)%>"/>
			<div class="SettingBodyCmd">
				<div id="MailAdressMessage" class="RegistMessage" style="color: red;"><%=strEmailState%>
				</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
				   onclick="UpdateEmailAddress()"><%=_TEX.T("EditSettingV.Button.Update")%>
				</a>
			</div>
		</div>
	</div>
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Password")%>
		</div>
		<div class="SettingBody">
			<%=_TEX.T("EditSettingV.Password.Message.Info")%>
			<div class="SettingBodyTxt" style="margin-top: 10px;">
				<%=_TEX.T("EditSettingV.Password.CurrentPassword")%>
			</div>
			<input id="PW" class="SettingBodyTxt" type="password"/>
			<div class="SettingBodyTxt" style="margin-top: 10px;">
				<%=_TEX.T("EditSettingV.Password.NewPassword")%>
			</div>
			<input id="PW1" class="SettingBodyTxt" type="password"/>
			<div class="SettingBodyTxt" style="margin-top: 10px;">
				<%=_TEX.T("EditSettingV.Password.NewPasswordConfirm")%>
			</div>
			<input id="PW2" class="SettingBodyTxt" type="password"/>
			<div class="SettingBodyCmd" style="margin-top: 20px;">
				<div id="PasswordMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
				   onclick="UpdatePassword()"><%=_TEX.T("EditSettingV.Button.Update")%>
				</a>
			</div>
		</div>
	</div>
	<div class="SettingListItem">
		<div class="SettingListTitle">
			<%=_TEX.T("EditSettingV.SendEmail")%>
		</div>
		<div class="SettingBody">
			<%=_TEX.T("EditSettingV.SendEmail.Message")%>
			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
				<div class="RegistMessage" >
					<div class="onoffswitch OnOff">
						<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="SendEmailMode" value="0" <%if(cResults.m_cUser.m_nSendEmailMode==CUser.SEND_EMAIL_ON){%>checked="checked"<%}%> />
						<label class="onoffswitch-label" for="SendEmailMode">
							<span class="onoffswitch-inner"></span>
							<span class="onoffswitch-switch"></span>
						</label>
					</div>
				</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateSendEmailMode()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
			</div>
		</div>
	</div>

	<%}%>
</div>
