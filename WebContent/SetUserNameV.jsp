<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
		<title>ユーザ名の設定</title>
		<script>
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
					$("#RegistMessage").html(strMessage);
				}
				return bRtn;
			}

			function UpdateNickName() {
				var strUserName = $.trim($("#RegistUserName").val());
				if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
					$("#RegistMessage").html("<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>");
					return;
				}
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "NN":strUserName},
					"url": "/f/UpdateNickNameF.jsp",
					"dataType": "json",
					"success": function(data) {
						//DispMsg('ユーザ名を設定しました。');
						location.reload(true);
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
			<%@ include file="/inner/TAdTop.jsp"%>

			<div style="box-sizing: border-box; width: 100%; float: left; text-align: center; padding: 130px 10px;">
				<p>ユーザ名を設定してください</p>
				<div id="RegistMessage" style="font-size: 12px; margin: 40px 0 10px 0; text-align: left; color: red;">&nbsp;</div>
				<input id="RegistUserName" style="box-sizing: border-box; width: 100%; margin: 0 0 60px 0;" type="text" placeholder="ユーザ名" maxlength="16" onkeyup="CheckInput()" />
				<a class="BtnBase" href="javascript:void(0)" onclick="UpdateNickName()">設定</a>
			</div>

			<%@ include file="/inner/TAdBottom.jsp"%>
		</article>
	</body>
</html>
