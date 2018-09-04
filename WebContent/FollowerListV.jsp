<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
String strDebug = "";

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>フォロワー</title>
		<script>
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId },
					"url": "/f/FollowerListF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							var cItem = data.result[nCnt];
							console.log(cItem.nickname);
							var $objItem = $("<a/>").addClass("UserThumb").attr("href", "/IllustListV.jsp?ID="+cItem.user_id);
							var $objItemImgFrame = $("<span/>").addClass("UserThumbImg");
							var $objItemImg = $("<img/>").attr("src", cItem.file_name+"_120.jpg");
							var $objItemName = $("<span/>").addClass("UserThumbName").html(cItem.nickname);
							$objItemImgFrame.append($objItemImg);
							$objItem.append($objItemImgFrame);
							$objItem.append($objItemName);
							$("#IllustThumbList").append($objItem);
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				addContents(g_nNextId);
			});

			$(document).ready(function() {
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 200) {
						addContents(g_nNextId);
					}
				});
			});
		</script>
	</head>

	<body>
		<div class="Wrapper">
			<%@ include file="/inner/TAdTop.jspf"%>

			<div id="IllustThumbList" class="IllustItemList"></div>

			<%@ include file="/inner/TAdBottom.jspf"%>
		</div>
	</body>
</html>