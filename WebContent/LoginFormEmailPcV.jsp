<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.lang3.RandomStringUtils" %>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin checkLogin = new CheckLogin(request, response);

String strRequestUri = Util.toString((String)request.getAttribute("javax.servlet.forward.request_uri"));
String strRequestQuery = Util.toString((String)request.getAttribute("javax.servlet.forward.query_string"));

String strRegistUserFToken = RandomStringUtils.randomAlphanumeric(64);
session.setAttribute("RegistUserFToken", strRegistUserFToken);

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

if (strNextUrl.isEmpty()) {
	String referer = Util.toString(request.getHeader("Referer"));
	if (referer.contains("ai.poipiku.com")) {
		strNextUrl = referer.replace("https://ai.poipiku.com", "");
	} else {
		strNextUrl = "/";
	}
}

String infoMsgKey = null;
if (strRequestUri.indexOf("/MyHome") == 0) {
	infoMsgKey = "MyHome";
} else if(strRequestUri.indexOf("/ActivityList") == 0){
	infoMsgKey = "ActivityList";
} else if(strRequestUri.indexOf("/MyIllustList") == 0){
	infoMsgKey = "MyIllustList";
} else if(strRequestUri.indexOf("/IllustDetail") == 0){
	infoMsgKey = "IllustDetail";
}

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("TopV.ContentsTitle.Login")%> | <%=_TEX.T("THeader.Title")%></title>
		<%=ReCAPTCHA.getScriptTag("reCAPTCHAonLoad")%>
		<script>
			function RegistUser() {
				const strEmail = $.trim($("#RegistEmail").val());
				const strPassword = $.trim($("#RegistPassword").val());
				const strNickname = $.trim($("#RegistNickname").val());
				if(!isEmailValid(strEmail)) {
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
				badge.css("bottom", "52px");
				//badge.css("left", "54px");
				badge.css("position", "fixed");
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
			<div class="SettingList" style="margin-top: 30px;">
				<div class="SettingListItem">
					<%if(infoMsgKey != null){%>
					<div class="LoginFormInfoMsg"><%=_TEX.T("LoginFormV.Info." + infoMsgKey)%></div>
					<%}%>
					<div style="text-align: center;">
						<div style="margin-bottom: 10px;"><%=_TEX.T("LoginFormV.Label.RegisterByTwitter")%></div>
						<form method="post" name="login_from_twitter_loginfromemailpcv_00" action="/LoginFormTwitter.jsp">
							<input id="login_from_twitter_loginfromemailpcv_callback_00" type="hidden" name="CBPATH" value="<%=strNextUrl%>"/>

							<a class="BtnBase Rev AnalogicoInfoRegistBtn"
							   style="margin: 10px 0 10px 0"
							   href="javascript:login_from_twitter_loginfromemailpcv_00.submit()">
								<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Unrealizm.Info.Login")%>
							</a>

							<div style="font-size: 9px;">
								<a  style="text-decoration: underline;"
									href="javascript:void(0)"
									onclick="$('#twitter_authorize_info').show(); $('#login_from_twitter_loginfromemailpcv_callback_00_auth').prop('checked',true);">
									<i class="fas fa-info-circle"></i> <%=_TEX.T("LoginFormV.TwitterAuthInfo01")%>
								</a>
								<div id="twitter_authorize_info" style="display: none; margin-top: 10px;">
									<div>
										<input id="login_from_twitter_loginfromemailpcv_callback_00_auth" type="checkbox" name="AUTH" value="authorize"/>
										<label for="login_from_twitter_loginfromemailpcv_callback_00_auth"><%=_TEX.T("LoginFormV.TwitterAuthInfo02")%></label>
									</div>
									<div style="text-align: left;">
										<p><%=_TEX.T("LoginFormV.TwitterAuthInfo03")%></p>
										<p><%=_TEX.T("LoginFormV.TwitterAuthInfo04")%></p>
									</div>
								</div>
							</div>
						</form>
					</div>

					<div class="LoginFormSeparator">
						<div class="SeparatorLine"></div>
						<div class="SeparatorLabel">or</div>
						<div class="SeparatorLine"></div>
					</div>

					<script>
						function toggleEmailForm() {
							if ($('#RegistForm').css('display') === 'block') {
								$('#RegistForm').slideUp();
								$('#LoginForm').slideDown();
								if(!$('#LoginEmail').val())$('#LoginEmail').val($('#RegistEmail').val());
								if(!$('#LoginPassword').val())$('#LoginPassword').val($('#RegistPassword').val());
							} else {
								$('#LoginForm').slideUp();
								$('#RegistForm').slideDown();
							}
						}
					</script>
					<form id="RegistForm" onsubmit="return RegistUser()">
						<div class="SettingBody">
							<div class="SettingBodyTxt" style="margin-top: 10px;">
								<span class="typcn typcn-mail"></span>
								<%=_TEX.T("LoginFormV.Label.Email")%>
							</div>
							<input id="RegistEmail" class="SettingBodyTxt" type="email" />
							<div class="SettingBodyTxt" style="margin-top: 10px;">
								<i class="fas fa-key"></i>
								<%=_TEX.T("LoginFormV.Label.Password")%>
							</div>
							<input id="RegistPassword" class="SettingBodyTxt" type="password" />
							<div class="RegistItem">
								<div class="SettingBodyTxt" style="margin-top: 10px;">
									<i class="fas fa-user"></i>
									<%=_TEX.T("LoginFormV.Label.Nickname")%>
									<span style="font-size: 9px;"> (<%=_TEX.T("LoginFormV.Label.Nickname.Info")%>)</span>
								</div>
								<input id="RegistNickname" class="SettingBodyTxt" type="text" />
								<div style="text-align: center;">
									<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
									<input class="BtnBase Rev SettingBodyCmdRegist" type="submit" value="<%=_TEX.T("LoginFormV.Button.Regist")%>" />
								</div>
								<div style="margin-top: 10px; text-align: center;">
									<div class="RegistMessage"></div>
									<a href="javascript:void(0);"
									   onclick="toggleEmailForm();">
										<i class="fas fa-sign-in-alt"></i> <%=_TEX.T("LoginFormV.Label.Login")%>
									</a>
								</div>
							</div>
						</div>
					</form>

					<form id="LoginForm" onsubmit="return LoginUser()">
						<div class="LoginItem">
							<div class="SettingListTitle" style="margin-top: 0"><%=_TEX.T("LoginFormV.Label.Login")%></div>
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
							<div class="SettingListItem">
								<div style="margin-top: 20px; text-align: center;">
									<input class="BtnBase Rev SettingBodyCmdRegist" type="submit" value="<%=_TEX.T("LoginFormV.Button.Login")%>" />
									<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
								</div>
								<div style="margin-top: 15px; text-align: center;">
									<a href="javascript:void(0);" onclick="toggleEmailForm()"><i class="fas fa-user-plus"></i> <%=_TEX.T("LoginFormV.Label.Regist")%></a>
									<div class="RegistMessage"></div>
								</div>
								<div style="margin-top: 10px; text-align: center;">
									<a href="/ForgetPasswordPcV.jsp"><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></a>
									<div class="RegistMessage"></div>
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
