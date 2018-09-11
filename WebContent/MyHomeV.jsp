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
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>home</title>
		<script>
			var g_nPage = 0;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage},
					"url": "/f/MyHomeF.jsp",
					"success": function(data) {
						if(data) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustItemList").append(data);
							g_bAdding = false;
						} else {
							$(window).unbind("scroll.addContents");
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
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				addContents();
			});

			$(document).ready(function() {
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 200) {
						addContents();
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
			<div id="IllustItemList" class="IllustItemList"></div>

		</div>
	</body>
</html>