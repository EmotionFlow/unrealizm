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
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("LoginFormV.Button.ForgotPassword")%> | <%=_TEX.T("THeader.Title")%></title>
		<script>
			function toHalfWidth(value) {
				return value.replace(/[^\x01-\x7E\xA1-\xDF]/g, function (s) {
					return String.fromCharCode(s.charCodeAt(0) - 0xfee0)
				})
			}
			function SendPassword() {
				var strEmail = $.trim($("#RegistEmail").val());
				var strTwScreenName = $.trim($("#RegistTwScreenName").val());
				if(strEmail.length==0 && strTwScreenName.length==0){
					DispMsg("ツイッターのユーザー名かメールアドレスを入力してください");
					return false;
				}
				if(strEmail.length>0 && !strEmail.match(/.+@.+\..+/)) {
					DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Empty")%>');
					return false;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {"EM":toHalfWidth(strEmail), "TW":toHalfWidth(strTwScreenName)},
					"url": "/f/SendPasswordF.jsp",
					"dataType": "json",
					"success": function(data) {
						$("#InquiryPage").hide();
						$("#MessagePage").show();
						// DispMsg('<%=_TEX.T("LoginFormV.Message.EmailForget")%>');
						return false;
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
				width: 200px;
			}
			input{
				color: #6d6965;
			}
			input::placeholder {
				color: lightgray;
				font-style: italic;
				font-weight: normal;
			}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div id="InquiryPage" class="SettingList">
				<div class="SettingListItem">
					<div class="LoginItem">
						<div class="SettingListTitle"><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></div>
					</div>
					<div class="SettingBody">
						<div class="SettingBodyInfo" style="margin-top: 10px;">
							<p>ツイッターアカウントのユーザー名かメールアドレスを入力して、 送信ボタンをクリックしてください。<br/>(どちらか片方でも可)</p>
							<p>メールにて、パスワードを再送します。</p>
						</div>
						<div class="SettingBodyTxt" style="margin-top: 30px;">
							連携したツイッターアカウントのユーザー名
						</div>
						<div class="InputArea">
							<div class="TwitterAtMark">@</div>
							<div class="TwitterScreenName"><input id="RegistTwScreenName" class="SettingBodyTxt" placeholder="poipiku" /></div>
						</div>
					</div>
					<div class="SettingBody">
						<div class="SettingBodyTxt" style="margin-top: 30px;">
							<%=_TEX.T("LoginFormV.Label.EmailForget")%>
						</div>
						<div class="InputArea">
							<input id="RegistEmail" class="SettingBodyTxt" type="email" placeholder="poipiku@example.com"/>
						</div>
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdSendBtn" href="javascript:void(0)" onclick="SendPassword()"><%=_TEX.T("LoginFormV.Button.EmailForget")%></a>
					</div>
				</div>
			</div>
			<div id="MessagePage" class="SettingList" style="display: none">
				<div class="SettingListItem">
					<div class="LoginItem">
						<div class="SettingListTitle"><%=_TEX.T("LoginFormV.Button.ForgotPassword")%></div>
					</div>
					<div class="SettingBody">
						<div class="SettingBodyInfo">
							<p>poipiku.comより、メールにて、アカウント情報を送信しました。</p>
							<p>ツイッターに登録しているアドレス、またはポイピクに登録しているアドレスのメールをチェックしてください。</p>
						</div>
					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
