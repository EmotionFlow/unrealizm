<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.lang3.RandomStringUtils" %>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

// login check
CheckLogin checkLogin = new CheckLogin(request, response);

String strSendPasswordFToken = RandomStringUtils.randomAlphanumeric(64);
session.setAttribute("SendPasswordFToken", strSendPasswordFToken);

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("LoginFormV.Button.ForgotPassword")%> | <%=_TEX.T("THeader.Title")%></title>
		<script>
			function toHalfWidth(value) {
				return value.replace(/[^\x01-\x7E\xA1-\xDF]/g, function (s) {
					return String.fromCharCode(s.charCodeAt(0) - 0xfee0)
				});
			}
			function SendPassword() {
				var strEmail = $.trim($("#RegistEmail").val());
				var strTwScreenName = $.trim($("#RegistTwScreenName").val());
				if(strEmail.length==0 && strTwScreenName.length==0){
					DispMsg("<%=_TEX.T("ForgetPassword.Err.Empty")%>");
					return false;
				}
				if(strEmail.length>0 && !isEmailValid(strEmail)) {
					DispMsg('<%=_TEX.T("ForgetPassword.Err.InvalidEmail")%>');
					return false;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {
						"EM":toHalfWidth(strEmail),
						"TW":toHalfWidth(strTwScreenName).replace(/^@/, ''),
						"TK":"<%=strSendPasswordFToken%>"
					},
					"url": "/f/SendPasswordF.jsp",
					"dataType": "json",
					"success": function(data) {
						$("#InquiryPage").hide();
						$("#MessagePage").show();
						return false;
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("ForgetPassword.Err.UploadErr")%>');
					}
				});
				return false;
			}
		</script>
		<style>
			.AboutFrame{display: none !important;}
			.InputArea {
				text-align: left;
				margin: 0px 30px;
			}
			.TwitterAtMark {
				display: inline-block;
				position: relative;
				top: 2px;
				width: 20px;
				text-align: right;
			}
			.TwitterScreenName{
				display: inline-block;
			}
			#RegistEmail{
				width: 100%;
			}
			.SettingBodyTxt{
				font-weight: 600;
			}
			.SettingBodyCmd{
				width: 100%;
				text-align: center;
				display: block;
				margin-top: 30px;
				float: left;
			}
			.SettingBodyCmdSendBtn{
				padding-left: 50px;
				padding-right: 50px;
			}
			input{
				color: #6d6965;
			}
			input::placeholder {
				color: lightgray;
				font-style: italic;
				font-weight: normal;
			}
			.SettingList .SettingListItem {color: #fff;}
		</style>
	</head>

	<body>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div id="InquiryPage" class="SettingList">
				<div class="SettingListItem">
					<div class="LoginItem">
						<div class="SettingListTitle"><%=_TEX.T("ForgetPassword.Title")%></div>
					</div>
					<div class="SettingBody">
						<div class="SettingBodyInfo" style="margin-top: 10px;">
							<%=_TEX.T("ForgetPassword.Message.Info")%>
						</div>
						<div class="SettingBodyTxt" style="margin-top: 30px;">
							<%=_TEX.T("ForgetPassword.Title.TwScreenName")%>
						</div>
						<div class="InputArea">
							<div class="TwitterAtMark">@</div>
							<div class="TwitterScreenName"><input id="RegistTwScreenName" class="SettingBodyTxt" placeholder="poipiku" /></div>
						</div>
					</div>
					<div class="SettingBody">
						<div class="SettingBodyTxt" style="margin-top: 30px;">
							<%=_TEX.T("ForgetPassword.Title.Email")%>
						</div>
						<div class="InputArea">
							<input id="RegistEmail" class="SettingBodyTxt" type="email" placeholder="poipiku@example.com"/>
						</div>
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase Rev SettingBodyCmdSendBtn" href="javascript:void(0)" onclick="SendPassword()"><%=_TEX.T("LoginFormV.Button.EmailForget")%></a>
					</div>
				</div>
			</div>
			<div id="MessagePage" class="SettingList" style="display: none">
				<div class="SettingListItem">
					<div class="LoginItem">
						<div class="SettingListTitle"><%=_TEX.T("ForgetPassword.Title")%></div>
					</div>
					<div class="SettingBody">
						<div class="SettingBodyInfo">
							<%=_TEX.T("ForgetPassword.Message.Thanks")%>
						</div>
					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
