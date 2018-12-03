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
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title><%=_TEX.T("TopV.ContentsTitle.Login")%></title>
	</head>
	<script>
		$.ajaxSetup({
			cache: false,
		});
		function Login() {
			var strPassword = $.trim($("#RegistPassword").val());
			$.ajaxSingle({
				"type": "post",
				"data": {"PW":strPassword},
				"url": "/f/LoginF.jsp",
				"dataType": "json",
				"success": function(data) {
					if(data.result>0) {
						DispMsg('<%=_TEX.T("LoginV.Success.Message")%>');
						sendObjectMessage("restart");
						//location.href="/MyHomeV.jsp";
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

	<body>
		<div id="DispMsg"></div>
		<div class="Wrapper">
			<div class="SettingList">
				<div class="SettingListItem" style="margin-top: 50px;">
					<div class="SettingListTitle"><%=_TEX.T("TopV.ContentsTitle.Login")%></div>
					<div class="SettingBody">
						<div class="SettingBodyTxt" style="margin-top: 30px;">
							<%=_TEX.T("LoginFormV.Label.Password")%>
						</div>
						<input id="RegistPassword" class="SettingBodyTxt" type="text" />
						<div class="SettingBodyCmd" style="margin-top: 30px;">
							<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="Login()"><%=_TEX.T("LoginFormV.Button.Login")%></a>
						</div>
					</div>
				</div>
			</div>
		</div><!--Wrapper-->
	</body>
</html>
