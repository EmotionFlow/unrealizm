<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");
int nUserId = Util.toInt(request.getParameter("ID"));
int nContentId	= Util.toInt(request.getParameter("TD"));

// login check
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>問題の報告</title>
		<style>
			.SettingBodyCmdRegist {
				min-width: 60px;
			}
		</style>
	</head>
	<script>
		$.ajaxSetup({
			cache: false,
		});
		function Login() {
			var strDesc = $.trim($("#ReportDesc").val());
			$.ajaxSingle({
				"type": "post",
				"data": {"ID":<%=nUserId%>, "TD":<%=nContentId%>, "DES":strDesc},
				"url": "/f/ReportF.jsp",
				"dataType": "json",
				"success": function(data) {
					if(data.result>0) {
						DispMsg('送信しました');
						sendObjectMessage("back");
					} else {
						DispMsg('Connection error');
					}
				},
				"error": function(req, stat, ex){
					DispMsg('Connection error');
				}
			});
			return false;
		}
	</script>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingListItem" style="margin-top: 50px;">
					<div class="SettingListTitle">問題の報告</div>
					<div class="SettingBody">
						<div class="SettingBodyTxt" style="margin-top: 30px;">
							問題点を具体的に記載してください。
						</div>
						<textarea id="ReportDesc" class="SettingBodyTxt" type="text"></textarea>
						<div class="SettingBodyCmd" style="margin-top: 30px;">
							<div id="ProfileTextMessage" class="RegistMessage" ></div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="Login()">送信する</a>
						</div>
					</div>
				</div>
			</div>
		</article><!--Wrapper-->
	</body>
</html>
