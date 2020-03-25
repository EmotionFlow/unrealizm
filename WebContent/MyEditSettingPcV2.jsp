<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@include file="/inner/Common.jsp"%>
<%!
	enum EmailStatus {
		UNDEF,
		UNREGISTED,
		COMFIRMATION,
		REGISTED
	}
%>
<%
//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

//パラメータの取得
//検索結果の取得
MyEditSettingC cResults = new MyEditSettingC();
cResults.GetParam(request);
cResults.GetResults(cCheckLogin);

EmailStatus emailState = EmailStatus.UNDEF;
boolean bNotEmailAddress = false;

if(cResults.m_cUser.m_strEmail.contains("@")){
	bNotEmailAddress = false;
	emailState = EmailStatus.REGISTED;
} else {
	bNotEmailAddress = true;
	emailState = EmailStatus.UNREGISTED;
}

String strEmailState = "";
if(cResults.m_bUpdate) {
	strEmailState = _TEX.T("EditSettingV.Email.EmailState.Confirmation") + cResults.m_strNewEmail;
	emailState = EmailStatus.COMFIRMATION;
}

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
			$.ajaxSetup({
				cache: false,
			});
			function CheckInput() {
				var bRtn = true;
				var strMessage = "&nbsp;";
				try {
					var strUserName = $.trim($("#RegistUserName").val());
					if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
						strMessage = "<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>";
						bRtn = false;
					}
				} finally {
					$("#UserNameMessage").html(strMessage);
				}
				return bRtn;
			}

			function UpdateNickName() {
				var strUserName = $.trim($("#RegistUserName").val());
				if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
					DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>");
					return;
				}
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "NN":strUserName},
					"url": "/f/UpdateNickNameF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Ok")%>");
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function updateFile(url, objTarg){
				if (objTarg.files.length>0 && objTarg.files[0].type.match('image.*')) {
					DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
					var fileReader = new FileReader();
					fileReader.onloadend = function() {
						var strEncodeImg = fileReader.result;
						var mime_pos = strEncodeImg.substring(0, 100).indexOf(",");
						if(mime_pos==-1) return;
						strEncodeImg = strEncodeImg.substring(mime_pos+1);
						$.ajaxSingle({
							"type": "post",
							"data": {"UID":<%=cCheckLogin.m_nUserId%>, "DATA":strEncodeImg},
							"url": url,
							"dataType": "json",
							"success": function(res) {
								switch(res.result) {
								case 0:
									// complete
									DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
									sendObjectMessage("reloadParent");
									location.reload(true);
									break;
								case -1:
									// file size error
									DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>");
									break;
								case -2:
									// file type error
									DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>");
									break;
								default:
									DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + res.result);
									break;
								}
							},
							"error": function(req, stat, ex){
								DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
							}
						});
					}
					fileReader.readAsDataURL(objTarg.files[0]);
				}
				return false;
			}

			function UpdateProfileFile(objTarg){
				updateFile("/f/UpdateProfileFileF.jsp", objTarg);
			}

			function UpdateProfileHeaderFile(objTarg){
				updateFile("/f/UpdateProfileHeaderFileF.jsp", objTarg);
			}

			function UpdateProfileBgFile(objTarg){
				updateFile("/f/UpdateProfileBgFileF.jsp", objTarg);
			}

			function ResetProfileFile(nMode){
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "MD":nMode},
					"url": "/f/ResetProfileFileF.jsp",
					"dataType": "json",
					"success": function(data) {
						sendObjectMessage("reloadParent");
						location.reload(true);
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function DispDescCharNum() {
				var nCharNum = 1000 - $("#EditBio").val().length;
				$("#ProfileTextMessage").html(nCharNum);
			}

			function UpdateProfileTxt() {
				var strProfileTxt = $.trim($("#EditBio").val());
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "DES":strProfileTxt},
					"url": "/f/UpdateProfileTxtF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
						sendObjectMessage("reloadParent");
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function DispMuteCharNum() {
				var nCharNum = 100 - $("#MuteKeywordText").val().length;
				$("#MuteKeywordTextNum").html(nCharNum);
			}

			function UpdateMuteKeyword() {
				var strMuteKeywordTxt = $.trim($("#MuteKeywordText").val());
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "DES": strMuteKeywordTxt },
					"url": "/f/UpdateMuteKeywordF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function UpdateNgReaction() {
				var bMode = $('#NgReaction').prop('checked');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.REACTION_HIDE%>:<%=CUser.REACTION_SHOW%> },
					"url": "/f/UpdateNgReactionF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function DeregistTwitter() {
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>},
					"url": "/f/DeregistTwitterF.jsp",
					"dataType": "json",
					"success": function(data) {
						location.reload(true);
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function UpdateAutoTweet() {
				var bAutoTweet = $('#AutoTweet').prop('checked');
				var nAutoTweetWeekDay = parseInt($('#AutoTweetWeekDay').val(), 10);
				var nAutoTweetTime = parseInt($('#AutoTweetTime').val(), 10);
				var strAutoTweetTxt = $.trim($("#AutoTweetTxt").val());
				var nAutoTweetThumbNum = ($('#AutoTweetThumb').prop('checked'))?9:0;
				if(!bAutoTweet) {
					nAutoTweetWeekDay = -1;
					nAutoTweetTime = -1;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {
						"ID": <%=cCheckLogin.m_nUserId%>,
						"AW": nAutoTweetWeekDay,
						"AT": nAutoTweetTime,
						"AD": strAutoTweetTxt,
						"ATN": nAutoTweetThumbNum},
					"url": "/f/UpdateAutoTweetF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function DispAutoTweetCharNum() {
				var nCharNum = 100 - $("#AutoTweetTxt").val().length;
				$("#AutoTweetTxtNum").html(nCharNum);
			}

			function getEmail() {
				var strEmail = $("#EM").val();
				if(!strEmail.match(/^([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+$/)) {
					DispMsg("<%=_TEX.T("EditSettingV.Email.Message.Empty")%>");
					strEmail = null;
				}
				return strEmail;
			}

			function getPasswords() {
				var PW = $("#PW").val();
				var PW1 = $("#PW1").val();
				var PW2 = $("#PW2").val();
				if(PW1.length<4 || PW1.length>16) {
					DispMsg("<%=_TEX.T("EditSettingV.Password.Message.Empty")%>");
					return null;
				}
				if(PW1!==PW2) {
					DispMsg("<%=_TEX.T("EditSettingV.Password.Message.NotMatch")%>");
					return null;
				}

				return [PW, PW1, PW2];
			}

			function UpdateEmailAddress(){
				var strEmail = getEmail();
				if(strEmail===null) return false;
				$.ajaxSingle({
					"type": "post",
					"data": {"ID": <%=cCheckLogin.m_nUserId%>, "EM": strEmail},
					"url": "/f/UpdateEmailAddressF.jsp",
					"dataType": "json",
					"success": function(data) {
						console.log(data);
						if(data.result>0) {
							DispMsg("<%=_TEX.T("EditSettingV.Email.Message.Confirmation")%>");
						} else {
							DispMsg("<%=_TEX.T("EditSettingV.Email.Message.Exist")%>");
						}
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
			}

			function UpdatePassword(){
				var pw = getPasswords();
				if(pw===null) return false;

				$.ajaxSingle({
					"type": "post",
					"data": {"ID": <%=cCheckLogin.m_nUserId%>, "PW": pw[0], "PW1": pw[1], "PW2": pw[2]},
					"url": "/f/UpdatePasswordF.jsp",
					"dataType": "json",
					"success": function(data) {
						console.log(data);
						if(data.result>0) {
							DispMsg("<%=_TEX.T("EditSettingV.Password.Message.Ok")%>");
						} else {
							DispMsg("<%=_TEX.T("EditSettingV.Password.Message.Wrong")%>");
						}
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
			}

			function Logout() {
				$.ajaxSingle({
					"type": "post",
					"data": {"ID":<%=cCheckLogin.m_nUserId%>},
					"url": "/f/LogioutF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result>0) {
							deleteCookie('POIPIKU_LK');
							location.href="/";
						}
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
			}

			function CheckDeregist(){
				if(!$("#CheckDeregistCheckBox").prop('checked')) return;
				if(window.confirm("<%=_TEX.T("EditSettingV.DeleteAccount.CheckDeregist")%>")){
					$.ajaxSingle({
						"type": "post",
						"data": {"ID":<%=cCheckLogin.m_nUserId%>},
						"url": "/f/DeleteUserF.jsp",
						"dataType": "json",
						"success": function(data) {
							if(data.result>0) {
								deleteCookie('POIPIKU_LK');
								location.href="/";
							}
						},
						"error": function(req, stat, ex){
							DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
						}
					});
				}
			}

			function CheckDeregist_checkbox() {
				if ($("#CheckDeregistCheckBox").prop('checked')) {
					$("#CheckDeregist").prop("disabled", false);
					$("#CheckDeregist").removeClass("Disabled");
				} else {
					$("#CheckDeregist").prop("disabled", true);
					$("#CheckDeregist").addClass("Disabled");
				}
			}
			$(function(){
				<%if(Util.isSmartPhone(request)){%>
				$("#MenuMe").addClass("Selected");
				<%}else{%>
				$("#MenuSettings").addClass("Selected");
				<%}%>

				DispDescCharNum();
				DispMuteCharNum();
				DispAutoTweetCharNum();

				<%if(cResults.m_strMessage.length()>0) {%>
				DispMsg("<%=Common.ToStringHtml(cResults.m_strMessage)%>");
				<%}%>
			});
		</script>

		<style>
		.UserInfo {
			background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');
		}
		.UserInfo .UserInfoUser .UserInfoUserThumbEdit {
			display: block;
			width: 84px;
			height: 84px;
			overflow: hidden;
			margin: -42px auto 0 auto;
			background-size: cover;
			position: relative;
		}

		.UserInfo .UserInfoUser .UserInfoUserThumbEdit .UserInfoUserImg {
			background-image: url(//img.poipiku.com/img/default_user.jpg);
			border-radius: 80px;
			border: solid 2px #ccc;
			width: 80px;
			height: 80px;
			background-color: #fff;
			margin: 0 auto 0 auto;
			background-position: 50% 50%;
		}

		.UserInfo .UserInfoUser .UserInfoUserThumbEdit .UserInfoUserImgUpload{
			background: url(/img/menu_pc-03.png) no-repeat;
			background-position: -30px 0px;
			background-size: 450px;
			background-color: #fff;
			width: 30px;
			height: 30px;
			top: 50px;
			left: 50px;
			overflow: overlay;
			position: absolute;
			border-radius: 30px;
			border: solid 2px #ccc;
		}
		.SelectFile{
			opacity: 0;
			width: 30px;
			height: 30px;
		}
		.UserInfo .UserInfoBg .UserInfoPreview {
			top: 9px;
			left: 7px;
			overflow: overlay;
			position: absolute;
		}
		.UserInfo .UserInfoBg .UserInfoHeaderUpload {
			background: url(/img/menu_pc-03.png) no-repeat;
			background-position: -30px 0px;
			background-size: 450px;
			background-color: #fff;
			width: 30px;
			height: 30px;
			top: 5px;
			right: 7px;
			overflow: overlay;
			position: absolute;
			border-radius: 30px;
			border: solid 2px #ccc;
		}
		.SettingBody .SettingBodyCmdRegist {
			font-size: 14px;
		}
		.SettingMenuItemLink{
			min-height: calc(41.625px);
			width: 100%;
			display: block;
			line-height: 40px;
		}

		.SettingMenuItem{
			width: 100%;
		}

		.SettingMenuItemTitle {

		}

			.SettingMenuItemArrow{
				display: inline-block;
				float: right;
				position: relative;
				top: 10px;
				padding: 0 9px;
			}

		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingMenu">
				<a class="SettingMenuItemLink" ><span class="SettingMenuItemTitle">ふぁぼ一覧</span><i class="SettingMenuItemArrow fas fa-angle-right"></i></a>
				<div class="SettingMenuItem" >ブロック一覧</div>
				<div class="SettingMenuItem" >プロフィール</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>