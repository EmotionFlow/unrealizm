<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>home</title>
		<script>
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId },
					"url": "/f/MyHomeF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						if(g_nNextId == -1) {
							$('#InfoMsg').show();
						}
						for(var nCnt=0; nCnt<data.result.length; nCnt++) {
							$("#IllustItemList").append(CreateIllustItem(data.result[nCnt], <%=cCheckLogin.m_nUserId%>));
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function DeleteContent(nContentId) {
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				DeleteContentBase(<%=cCheckLogin.m_nUserId%>, nContentId);
				return false;
			}

			function MoveTab() {
				sendObjectMessage("moveTabNewArrival")
			}

			$(function(){
				addContents(g_nNextId);
			});

			$(document).ready(function() {
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 100) {
						addContents(g_nNextId);
					}
				});
			});
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<div class="Wrapper">
			<div id="InfoMsg" style="display:none; float: left; width: 100%; padding: 160px 0 0 0; text-align: center;">
				ポイピクへようこそ<br />
				<br />
				描くのに飽きたらポイポイ<br />
				ポイポイしたら誰かがきっと励ましてくれる<br />
				<br />
				<br />
				<a class="BtnBase" href="javascript:void(0)" onclick="MoveTab()">
					フォローする人を探す
				</a>
			</div>
			<div id="IllustItemList" class="IllustItemList">
			</div>
		</div>
	</body>
</html>