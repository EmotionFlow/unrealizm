<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.lang3.RandomStringUtils" %>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin checkLogin = new CheckLogin(request, response);

String strRequestUri = (String)request.getAttribute("javax.servlet.forward.request_uri");
String strRequestQuery = (String)request.getAttribute("javax.servlet.forward.query_string");

final String strRegistUserFToken = RandomStringUtils.randomAlphanumeric(64);
session.setAttribute("RegistUserFToken", strRegistUserFToken);

String strMessage = "";
session.removeAttribute("LoginUri");
if(strRequestUri != null) {
	if(strRequestQuery != null) {
		strRequestUri += "?" + strRequestQuery;
	}
	session.setAttribute("LoginUri", strRequestUri);
}

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("TopV.ContentsTitle.Login")%></title>
		<%=ReCAPTCHA.getScriptTag("reCAPTCHAonLoad")%>
		<script>
			function RegistUser() {
				const strEmail = $.trim($("#RegistEmail").val());
				const strPassword = $.trim($("#RegistPassword").val());
				const strNickname = $.trim($("#RegistNickname").val());
				if(!strEmail.match(/.+@.+\..+/)) {
					DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Empty")%>');
					return false;
				}
				if(strPassword.length<4 || strPassword.length>16) {
					DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Empty")%>');
					return false;
				}
				if(strNickname.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strNickname.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
					DispMsg('<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>');
					return false;
				}

				grecaptcha.ready( () => {
					grecaptcha.execute('<%=ReCAPTCHA.SITE_KEY%>', {action: 'register_app'}).then((reCAPTCHAtoken) => {
						$.ajaxSingle({
							"type": "post",
							"data": {
								"NN":strNickname,
								"EM":strEmail,
								"PW":strPassword,
								"TK":"<%=strRegistUserFToken%>",
								"RTK":reCAPTCHAtoken,
							},
							"url": "/f/RegistUserF.jsp",
							"dataType": "json",
							"success": function(data) {
								if(data.result>0) {
									DispMsg('<%=_TEX.T("LoginV.Success.Regist.Message")%>');
									sendObjectMessage("restart");
								} else if(data.result===<%=UserAuthUtil.ERROR_USER_EXIST%>) {
									DispMsg('<%=_TEX.T("LoginV.Faild.Regist.ExistEmail")%>');
								} else {
									DispMsg('<%=_TEX.T("LoginV.Faild.Regist.Message")%>');
								}
							},
							"error": function(req, stat, ex){
								DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
							}
						});
					});
				});
				return false;
			}

			function LoginUser() {
				const strEmail = $.trim($("#LoginEmail").val());
				const strPassword = $.trim($("#LoginPassword").val());
				grecaptcha.ready( () => {
					grecaptcha.execute('<%=ReCAPTCHA.SITE_KEY%>', {action: 'login_app'}).then((reCAPTCHAtoken) => {
						$.ajaxSingle({
							"type": "post",
							"data": {
								"EM":strEmail,
								"PW":strPassword,
								"RTK": reCAPTCHAtoken,
							},
							"url": "/f/LoginUserF.jsp",
							"dataType": "json",
							"success": function(data) {
								if(data.result>0) {
									DispMsg('<%=_TEX.T("LoginV.Success.Message")%>');
									sendObjectMessage("restart");
								} else {
									DispMsg('<%=_TEX.T("LoginV.Faild.Message")%>');
								}
							},
							"error": function(req, stat, ex){
								DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
							}
						});
					});
				});
				return false;
			}

			function reCAPTCHAonLoad() {
				let badge = $(".grecaptcha-badge");
				badge.css("bottom", "50px");
				// badge.css("left", "54px");
				badge.css("position", "fixed");
			}
		</script>
		<style>
		.Wrapper {width: 360px;}
		.AnalogicoInfo {display: none;}
		#RegistForm {display: block; float: left; width: 100%;}
		#LoginForm {display: none; float: left; width: 100%;}
		.SettingList .SettingListItem {color: #fff;}
		.SettingList .BtnBase {border: 1px solid #fff; background: #3498db; color: #fff;}
		.SettingList .BtnBase.Selected, SettingList .BtnBase:hover {border: 1px solid #3498db; background: #fff; color: #3498db;}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div class="SettingList" style="margin-top: 50px;">
				<div class="SettingListItem">
					<form id="RegistForm" onsubmit="return RegistUser()">
						<div class="RegistItem">
							<div class="SettingListTitle"><%=_TEX.T("LoginFormV.Label.Regist")%></div>
						</div>
						<div class="SettingBody">
							<div class="SettingBodyTxt" style="margin-top: 10px;">
								<%=_TEX.T("LoginFormV.Label.Email")%>
							</div>
							<input id="RegistEmail" class="SettingBodyTxt" type="email" />
							<div class="SettingBodyTxt" style="margin-top: 10px;">
								<%=_TEX.T("LoginFormV.Label.Password")%>
							</div>
							<input id="RegistPassword" class="SettingBodyTxt" type="password" />
							<div class="RegistItem">
								<div class="SettingBodyTxt" style="margin-top: 10px;">
									<%=_TEX.T("LoginFormV.Label.Nickname")%>
									<span style="font-size: 9px;"> (<%=_TEX.T("LoginFormV.Label.Nickname.Info")%>)</span>
								</div>
								<input id="RegistNickname" class="SettingBodyTxt" type="text" />
								<div style="margin-top: 20px; text-align: center;">
									<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
									<input class="BtnBase Rev SettingBodyCmdRegist" type="submit" value="<%=_TEX.T("LoginFormV.Button.Regist")%>" />
								</div>
								<div style="margin-top: 15px; text-align: center;">
									<div class="RegistMessage"></div>
									<a href="javascript:void(0);" onclick="$('#RegistForm').slideUp();$('#LoginForm').slideDown();"><i class="fas fa-sign-in-alt"></i> <%=_TEX.T("LoginFormV.Label.Login")%></a>
								</div>
							</div>
						</div>
					</form>

					<form id="LoginForm" onsubmit="return LoginUser()">
						<div class="LoginItem">
							<div class="SettingListTitle"><%=_TEX.T("LoginFormV.Label.Login")%></div>
						</div>
						<div class="SettingBody">
							<div class="SettingBodyTxt" style="margin-top: 10px;">
								<%=_TEX.T("LoginFormV.Label.Email")%>
							</div>
							<input id="LoginEmail" class="SettingBodyTxt" type="email" />
							<div class="SettingBodyTxt" style="margin-top: 10px;">
								<%=_TEX.T("LoginFormV.Label.Password")%>
							</div>
							<input id="LoginPassword" class="SettingBodyTxt" type="password" />
							<div class="LoginItem">
								<div style="margin-top: 20px; text-align: center;">
									<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
									<input class="BtnBase Rev SettingBodyCmdRegist" type="submit" value="<%=_TEX.T("LoginFormV.Button.Login")%>" />
								</div>
								<div style="margin-top: 15px; text-align: center;">
									<div class="RegistMessage"></div>
									<a href="javascript:void(0);" onclick="$('#LoginForm').slideUp();$('#RegistForm').slideDown();"><i class="fas fa-user-plus"></i> <%=_TEX.T("LoginFormV.Label.Regist")%></a>
								</div>
								<div style="margin-top: 10px; text-align: center;">
									<div class="RegistMessage"></div>
									<a href="/ForgetPasswordPcV.jsp"><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></a>
								</div>
							</div>
						</div>
					</form>
				</div>
			</div>
		</article><!--Wrapper-->
	</body>
</html>
