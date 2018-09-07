<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@ include file="/MyEditSettingC.jsp"%>
<%
String strDebug = "";

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

//パラメータの取得
MyEditSettingCParam cParam = new MyEditSettingCParam();
cParam.GetParam(request);

cParam.m_nUserId = cCheckLogin.m_nUserId;

//検索結果の取得
MyEditSettingC cResults = new MyEditSettingC();
strDebug = cResults.GetResults(cParam);

String strEmailState = "";
if(cResults.m_bUpdate) {
	strEmailState = _TEX.T("EditSettingV.Email.EmailState.Confirmation") + cResults.m_strNewEmail;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
		});
		</script>

		<script type="text/javascript">
			$.ajaxSetup({
				cache: false,
			});
			function CheckInput() {
				var bRtn = true;
				var strMessage = "&nbsp;";
				try {
					var strUserName = $.trim($("#RegistUserName").val());

					if(strUserName.length<5) {
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
				if(strUserName.length<5) {
					DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>");
					return;
				}
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "NN":strUserName},
					"url": "/f/UpdateNickNameF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg('ユーザ名を変更しました。');
						sendObjectMessage("reloadParent");
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
									DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>');
									break;
								case -2:
									// file type error
									DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>');
									break;
								default:
									DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + res.result);
									break;
								}
							},
							"error": function(req, stat, ex){
								DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
						DispMsg('保存しました。');
						sendObjectMessage("reloadParent");
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
						DispMsg('保存しました。');
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function UpdateAutoTweet() {
				var bAutoTweet = $('#AutoTweet').prop('checked');
				var nAutoTweetWeekDay = parseInt($('#AutoTweetWeekDay').val(), 10);
				var nAutoTweetTime = parseInt($('#AutoTweetTime').val(), 10);
				var strAutoTweetTxt = $.trim($("#AutoTweetTxt").val());
				if(!bAutoTweet) {
					nAutoTweetWeekDay = -1;
					nAutoTweetTime = -1;
				}
				$.ajaxSingle({
					"type": "post",
					"data": { "ID": <%=cCheckLogin.m_nUserId%>, "AW": nAutoTweetWeekDay, "AT": nAutoTweetTime, "AD": strAutoTweetTxt },
					"url": "/f/UpdateAutoTweetF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg('保存しました。');
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function DispAutoTweetCharNum() {
				var nCharNum = 100 - $("#AutoTweetTxt").val().length;
				$("#AutoTweetTxtNum").html(nCharNum);
			}

			function GetAccountCode() {
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>},
					"url": "/f/GetAccountCodeF.jsp",
					"dataType": "json",
					"success": function(data) {
						$("#AccountCodeMessage").html(data.account_code);
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
							deleteCookie('ANALOGICO_LK');
							location.href="/";
						}
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
			}

			function CheckDeregist(){
				if(!$("#CheckDeregistCheckBox").prop('checked')) return;
				if(window.confirm('<%=_TEX.T("EditSettingV.DeleteAccount.CheckDeregist")%>')){
					$.ajaxSingle({
						"type": "post",
						"data": {"ID":<%=cCheckLogin.m_nUserId%>},
						"url": "/f/DeleteUserF.jsp",
						"dataType": "json",
						"success": function(data) {
							if(data.result>0) {
								deleteCookie('ANALOGICO_LK');
								location.href="/";
							}
						},
						"error": function(req, stat, ex){
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
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
				$("#MySetting").addClass("Selected");

				DispDescCharNum();
				DispMuteCharNum();
				DispAutoTweetCharNum();

				<%if(cParam.m_strMessage.length()>0) {%>
				DispMsg("<%=Common.ToStringHtml(cParam.m_strMessage)%>");
				<%}%>
			});
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div class="SettingList">
				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.NickName")%></div>
					<div class="SettingBody">
						<input id="RegistUserName" class="SettingBodyTxt" type="text" placeholder="ユーザ名" value="<%=Common.ToStringHtml(cResults.m_cUser.m_strNickName)%>" maxlength="16" onkeyup="CheckInput()" />
						<div class="SettingBodyCmd">
							<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNickName()">変更</a>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Image")%></div>
					<div class="SettingBody" style="text-align: center;">
						<div class="FileSelectFrame" style="display: inline-block; width: 124px;height: 124px;border: solid 2px #eee; border-radius: 120px; overflow: hidden;display: inline-block;float: none;">
							<%if(!cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
							<div style="position: absolute; top:0; left: 0; width: 100%; height: 100%; background-size: 124px 124px;border-radius: 120px; overflow: hidden; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>?<%=Math.random()%>');"></div>
							<%}%>
							<input class="SelectFile" type="file" name="file_thumb" id="file_thumb" onchange="UpdateProfileFile(this)" />
							<%if(cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
							<span class="typcn typcn-plus-outline"></span>
							<%} else {%>
							<span style="text-shadow: none; color: #6d6965;">画像保存中...</span>
							<%}%>
						</div>
						<div class="SettingBodyCmd">
							<div id="ProfileImageMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.Image.Format")%></div>
							<%if(!cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(1)">デフォルトに戻す</a>
							<%}%>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">ヘッダー画像</div>
					<div class="SettingBody">
						<div class="FileSelectFrame" style="border: solid 1px #eee;">
							<div style="position: absolute; top:0; left: 0; width: 100%; height: 100%; background-size: 360px auto; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>?<%=Math.random()%>');"></div>
							<input class="SelectFile" type="file" name="file_header" id="file_header" onchange="UpdateProfileHeaderFile(this)" />
							<%if(cResults.m_cUser.m_strHeaderFileName.equals("/img/default_transparency.gif")) {%>
							<span class="typcn typcn-plus-outline"></span>
							<%} else {%>
							<span style="text-shadow: none; color: #6d6965;">画像保存中...</span>
							<%}%>
						</div>
						<div class="SettingBodyCmd">
							<div id="ProfileImageMessage" class="RegistMessage" >幅600px推奨 jpg, png, gif 1MByteまで</div>
							<%if(!cResults.m_cUser.m_strHeaderFileName.equals("/img/default_transparency.gif")) {%>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(2)">デフォルトに戻す</a>
							<%}%>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">背景画像</div>
					<div class="SettingBody">
						<div class="FileSelectFrame" style="border: solid 1px #eee;">
							<div style="position: absolute; top:0; left: 0; width: 100%; height: 100%; background-size: 360px auto; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strBgFileName)%>?<%=Math.random()%>');"></div>
							<input class="SelectFile" type="file" name="file_bg" id="file_bg" onchange="UpdateProfileBgFile(this)" />
							<%if(cResults.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {%>
							<span class="typcn typcn-plus-outline"></span>
							<%} else {%>
							<span style="text-shadow: none; color: #6d6965;">画像保存中...</span>
							<%}%>
						</div>
						<div class="SettingBodyCmd">
							<div id="ProfileImageMessage" class="RegistMessage" >幅600px推奨 jpg, png, gif 1MByteまで</div>
							<%if(!cResults.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {%>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(3)">デフォルトに戻す</a>
							<%}%>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Bio")%></div>
					<div class="SettingBody">
						<textarea id="EditBio" class="SettingBodyTxt" rows="6" onkeyup="DispDescCharNum()" maxlength="1000"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strProfile)%></textarea>
						<div class="SettingBodyCmd">
							<div id="ProfileTextMessage" class="RegistMessage" >1000</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateProfileTxt()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.MuteKeyowrd")%></div>
					<div class="SettingBody">
						<textarea id="MuteKeywordText" class="SettingBodyTxt" rows="6" onkeyup="DispMuteCharNum()" maxlength="100"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strMuteKeyword)%></textarea>
						<div class="SettingBodyCmd">
							<div id="MuteKeywordTextNum" class="RegistMessage" >100</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateMuteKeyword()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem" style="border: none;">
					<a id="TwitterSetting" name="TwitterSetting"></a>
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.Twitter.Info")%>
						<div class="SettingBodyCmd">
							<div class="RegistMessage" >[<%=(cResults.m_cUser.m_bTweet)?_TEX.T("EditSettingV.Twitter.Info.State.On"):_TEX.T("EditSettingV.Twitter.Info.State.Off")%>]</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="location.href='/TokenFormTwitter.jsp'"><%=_TEX.T("EditSettingV.Twitter.Button")%></a>
						</div>
						<%if(cResults.m_cUser.m_bTweet){%>
						<!--
						<div class="SettingBodyCmd">
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="DeregistTwitter()"><%=_TEX.T("EditSettingV.Twitter.Button.Deregist")%></a>
						</div>
						-->
						<%}%>
					</div>
				</div>

				<%if(cResults.m_cUser.m_bTweet){%>
				<div id="SectionAutoTweet" class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.Auto")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.Twitter.Auto.Info")%>
						<div class="SettingBodyCmd">
							<div class="onoffswitch OnOff">
								<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="AutoTweet" value="1" <%if(cResults.m_cUser.m_nAutoTweetTime>=0){%>checked="checked"<%}%> />
								<label class="onoffswitch-label" for="AutoTweet">
									<span class="onoffswitch-inner"></span>
									<span class="onoffswitch-switch"></span>
								</label>
							</div>
							<script>
							$('#AutoTweet').change(function(){
								var bAutoTweet = $('#AutoTweet').prop('checked');
								console.log(bAutoTweet);
								$('#AutoTweetWeekDay').prop('disabled', !bAutoTweet);
								$('#AutoTweetTime').prop('disabled', !bAutoTweet);
								$('#AutoTweetTxt').prop('disabled', !bAutoTweet);
							});
							</script>
						</div>
						<div class="SettingBodyCmd">
							<select id="AutoTweetWeekDay" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
								<option value="-1"><%=_TEX.T("EditSettingV.Twitter.Auto.WeekDay.DayEvery")%></option>
								<%for(int nTime=0; nTime<7; nTime++) {%>
								<option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetWeekDay==nTime){%>selected="selected"<%}%>><%=_TEX.T(String.format("EditSettingV.Twitter.Auto.WeekDay.Day%d", nTime))%></option>
								<%}%>
							</select>
						</div>
						<div class="SettingBodyCmd">
							<select id="AutoTweetTime" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
								<%for(int nTime=0; nTime<24; nTime++) {%>
								<option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetTime==nTime){%>selected="selected"<%}%>><%=nTime%><%=_TEX.T("EditSettingV.Twitter.Auto.Unit")%></option>
								<%}%>
							</select>
						</div>
						<div class="SettingBodyCmd">
							<%if(cResults.m_cUser.m_strAutoTweetDesc.length()<=0){cResults.m_cUser.m_strAutoTweetDesc=_TEX.T("EditSettingV.Twitter.Auto.AutoTxt")+_TEX.T("THeader.Title")+String.format(" https://poipiku.com/%d/", cResults.m_cUser.m_nUserId);}%>
							<textarea id="AutoTweetTxt" class="SettingBodyTxt" rows="6" onkeyup="DispAutoTweetCharNum()" maxlength="100"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strAutoTweetDesc)%></textarea>
						</div>
						<div class="SettingBodyCmd">
							<div id="AutoTweetTxtNum" class="RegistMessage" >100</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateAutoTweet()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>
				<%}%>

				<%if(cResults.m_cUser.m_bTweet){%>
				<div class="SettingListItem">
					<div class="SettingListTitle">ログアウト</div>
					<div class="SettingBody">
						再度ログインする際は最初の画面で「Twitterで新規登録/ログイン」を押してログインしてください。
						<div class="SettingBodyCmd ">
							<div class="RegistMessage" ></div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="Logout()">ログアウト</a>
						</div>
					</div>
				</div>
				<%}%>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.DeleteAccount")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.DeleteAccount.Message")%>
						<div class="SettingBodyCmd">
							<div id="DeleteAccountMessage" class="RegistMessage" >
								<label>
									<input id="CheckDeregistCheckBox" type="checkbox" onclick="CheckDeregist_checkbox();" />
									<%=_TEX.T("EditSettingV.DeleteAccount.CheckButton")%>
								</label>
							</div>
							<a id="CheckDeregist" class="BtnBase SettingBodyCmdRegist Disabled" onclick="CheckDeregist()"><%=_TEX.T("EditSettingV.DeleteAccount.Button")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem" style="margin-bottom: 15px; border-bottom: none;">
					<div class="SettingListTitle">利用規約およびプライバシーポリシー</div>
					<div class="SettingBody" style="text-align: center;">
						<p><a href="/RulePcS.jsp" style="font-size: 14px; text-decoration: underline;">利用規約</a></p>
						<p><a href="/PrivacyPolicyPcS.jsp" style="font-size: 14px; text-decoration: underline;">プライバシーポリシー</a></p>
					</div>
				</div>
			</div>

			<%@ include file="/inner/TAdBottom.jspf"%>
		</div><!--Wrapper-->

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>