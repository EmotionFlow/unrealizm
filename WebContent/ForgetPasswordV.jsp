<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></title>
		<script>
			function SendPassword() {
				var strEmail = $.trim($("#RegistEmail").val());
				if(!strEmail.match(/.+@.+\..+/)) {
					DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Empty")%>');
					return false;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {"EM":strEmail},
					"url": "/f/SendPasswordF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg('<%=_TEX.T("LoginFormV.Message.EmailForget")%>');
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div class="SettingList" style="margin-top: 50px;">
				<div class="SettingListItem">
					<div class="LoginItem">
						<div class="SettingListTitle"><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></div>
					</div>
					<div class="SettingBody">
						<div class="SettingBodyTxt" style="margin-top: 10px;">
							<%=_TEX.T("LoginFormV.Label.EmailForget")%>
						</div>
						<input id="RegistEmail" class="SettingBodyTxt" type="email" />
						<div class="RegistItem">
							<div class="SettingBodyCmd" style="margin-top: 20px;">
								<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
								<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="SendPassword()"><%=_TEX.T("LoginFormV.Button.EmailForget")%></a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</article><!--Wrapper-->
	</body>
</html>
