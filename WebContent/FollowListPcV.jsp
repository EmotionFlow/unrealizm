<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
String strDebug = "";

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>フォロー</title>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
		});
		</script>

		<script>
			var ILLUST_LIST = "IllustListPcV.jsp";
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId },
					"url": "/f/FollowListF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							var cItem = data.result[nCnt];
							console.log(cItem.nickname);
							var $objItem = $("<a/>").addClass("UserThumb").attr("href", ILLUST_LIST+"?ID="+cItem.user_id);
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
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 100) {
						addContents(g_nNextId);
					}
				});
			});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="Wrapper">
			<div id="IllustThumbList" class="IllustItemList">
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>