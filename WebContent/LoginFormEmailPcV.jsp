<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.lang3.RandomStringUtils" %>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin checkLogin = new CheckLogin(request, response);

String strRequestUri = Util.toString((String)request.getAttribute("javax.servlet.forward.request_uri"));
String strRequestQuery = Util.toString((String)request.getAttribute("javax.servlet.forward.query_string"));

final String strRegistUserFToken = RandomStringUtils.randomAlphanumeric(64);
session.setAttribute("RegistUserFToken", strRegistUserFToken);

String strMessage = "";
session.removeAttribute("LoginUri");
if(!strRequestUri.isEmpty()) {
	if(!strRequestQuery.isEmpty()) {
		strRequestUri += "?" + strRequestQuery;
	}
	session.setAttribute("LoginUri", strRequestUri);
}


String strNextUrl = "";
String strReturnUrl = "";
if(Util.toBoolean(request.getParameter("INQUIRY"))) {
	strReturnUrl = Util.toString(request.getParameter("RET"));
	if(strReturnUrl.isEmpty() || strReturnUrl.equals("/")){
		strNextUrl = "/GoToInquiryPcV.jsp?RET=" + URLEncoder.encode("/MyHomePcV.jsp?ID="+checkLogin.m_nUserId,"UTF-8");;
	} else {
		strNextUrl = "/GoToInquiryPcV.jsp?RET=" + URLEncoder.encode(strReturnUrl,"UTF-8");
	}
} else if(strRequestUri.isEmpty()) {
	strNextUrl = strRequestUri;
} else {
	strNextUrl = "/MyHomePcV.jsp?ID="+checkLogin.m_nUserId;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("TopV.ContentsTitle.Login")%> | <%=_TEX.T("THeader.Title")%></title>
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
					grecaptcha.execute('<%=ReCAPTCHA.SITE_KEY%>', {action: 'register_browser'}).then((reCAPTCHAtoken) => {
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
							"success": (data) => {
								if(data.result>0) {
									DispMsg('<%=_TEX.T("LoginV.Success.Regist.Message")%>');
									location.href = "<%=strNextUrl%>";
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
					grecaptcha.execute('<%=ReCAPTCHA.SITE_KEY%>', {action: 'login_browser'}).then((reCAPTCHAtoken) => {
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
									location.href = "<%=strNextUrl%>";
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
				<%if(Util.isSmartPhone(request)){%>
				badge.css("bottom", "-15px");
				badge.css("left", "54px");
				badge.css("position", "absolute");
				$(".Footer").css("margin-top", "90px");
				<%}%>
			}
		</script>
		<style>
		.Wrapper {width: 360px;}
		.AnalogicoInfo {display: none;}
		#RegistForm {display: block; float: left; width: 100%;}
		#LoginForm {display: none; float: left; width: 100%;}
		.SettingList .SettingListItem {color: #fff;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div class="SettingList" style="margin-top: 50px;">
				<div class="SettingListItem">
					<div style="text-align: center;">
						<form method="post" name="login_from_twitter_loginfromemailpcv_00" action="/LoginFormTwitter.jsp">
							<input id="login_from_twitter_loginfromemailpcv_callback_00" type="hidden" name="CBPATH" value="<%=strNextUrl%>"/>
							<a class="BtnBase Rev AnalogicoInfoRegistBtn" href="javascript:login_from_twitter_loginfromemailpcv_00.submit()">
								<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login")%>
							</a>
						</form>
					</div>

					<div style="display: flex; line-height: 15px; margin: 30px 0;">
						<div style="flex: 1 0; height: 1px; background-color: #fff; margin: 7px 0;"></div>
						<div style="flex: 0 0; padding: 0px 12px;">or</div>
						<div style="flex: 1 0; height: 1px; background-color: #fff; margin: 7px 0;"></div>
					</div>

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
								<div class="SettingBodyCmd" style="margin-top: 20px;">
									<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
									<input class="BtnBase Rev SettingBodyCmdRegist" type="submit" value="<%=_TEX.T("LoginFormV.Button.Regist")%>" />
								</div>
								<div class="SettingBodyCmd" style="margin-top: 15px; text-align: right;">
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
								<div class="SettingBodyCmd" style="margin-top: 20px;">
									<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
									<input class="BtnBase Rev SettingBodyCmdRegist" type="submit" value="<%=_TEX.T("LoginFormV.Button.Login")%>" />
								</div>
								<div class="SettingBodyCmd" style="margin-top: 15px; text-align: right;">
									<div class="RegistMessage"></div>
									<a href="javascript:void(0);" onclick="$('#LoginForm').slideUp();$('#RegistForm').slideDown();"><i class="fas fa-user-plus"></i> <%=_TEX.T("LoginFormV.Label.Regist")%></a>
								</div>
								<div class="SettingBodyCmd" style="margin-top: 10px; text-align: right;">
									<div class="RegistMessage"></div>
									<a href="/ForgetPasswordPcV.jsp"><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></a>
								</div>
							</div>
						</div>
					</form>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>
