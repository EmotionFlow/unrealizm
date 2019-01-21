<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

String strRequestUri = (String)request.getAttribute("javax.servlet.forward.request_uri");
String strRequestQuery = (String)request.getAttribute("javax.servlet.forward.query_string");

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
		<script>
			function RegistUser() {
				var strNickname = $.trim($("#RegistNickname").val());
				var strEmail = $.trim($("#RegistEmail").val());
				var strPassword = $.trim($("#RegistPassword").val());
				if(strNickname.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strNickname.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
					DispMsg('<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>');
					return false;
				}
				if(!strEmail.match(/.+@.+\..+/)) {
					DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Empty")%>');
					return false;
				}
				if(strPassword.length<4 || strPassword.length>16) {
					DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Empty")%>');
					return false;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {"NN":strNickname, "EM":strEmail, "PW":strPassword},
					"url": "/f/RegistUserF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result>0) {
							DispMsg('<%=_TEX.T("LoginV.Success.Regist.Message")%>');
							sendObjectMessage("restart");
						} else {
							DispMsg('<%=_TEX.T("LoginV.Faild.Regist.Message")%>');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function LoginUser() {
				var strEmail = $.trim($("#RegistEmail").val());
				var strPassword = $.trim($("#RegistPassword").val());
				$.ajaxSingle({
					"type": "post",
					"data": {"EM":strEmail, "PW":strPassword},
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
				return false;
			}
		</script>
		<style>
		.LoginItem {display: none;}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div class="SettingList" style="margin-top: 50px;">
				<div id="RegistForm" class="SettingListItem">
					<div class="RegistItem">
						<div class="SettingListTitle"><%=_TEX.T("LoginFormV.Label.Regist")%></div>
					</div>
					<div class="LoginItem">
						<div class="SettingListTitle"><%=_TEX.T("LoginFormV.Label.Login")%></div>
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
								<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="RegistUser()"><%=_TEX.T("LoginFormV.Button.Regist")%></a>
							</div>
							<div class="SettingBodyCmd" style="margin-top: 15px; text-align: right;">
								<div class="RegistMessage"></div>
								<a style="color: #5bd;" href="javascript:void(0);" onclick="$('.RegistItem').slideUp();$('.LoginItem').slideDown();"><i class="fas fa-sign-in-alt"></i> <%=_TEX.T("LoginFormV.Label.Login")%></a>
							</div>
						</div>
						<div class="LoginItem">
							<div class="SettingBodyCmd" style="margin-top: 20px;">
								<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
								<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="LoginUser()"><%=_TEX.T("LoginFormV.Button.Login")%></a>
							</div>
							<div class="SettingBodyCmd" style="margin-top: 15px; text-align: right;">
								<div class="RegistMessage"></div>
								<a style="color: #5bd;" href="javascript:void(0);" onclick="$('.LoginItem').slideUp();$('.RegistItem').slideDown();"><i class="fas fa-user-plus"></i> <%=_TEX.T("LoginFormV.Label.Regist")%></a>
							</div>
							<div class="SettingBodyCmd" style="margin-top: 10px; text-align: right;">
								<div class="RegistMessage"></div>
								<a style="color: #5bd;" href="/ForgetPasswordPcV.jsp"><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</article><!--Wrapper-->
	</body>
</html>
