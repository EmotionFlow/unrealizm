<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>tag</title>
		<script>
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId },
					"url": "/f/PopularTagListF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							var cItem = data.result[nCnt];
							var $objItem = $("<a/>").addClass("TagItem").attr("href", "/SearchIllustByTagV.jsp?KWD="+cItem.keyword).text('#'+cItem.keyword);
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
		<div class="Wrapper">
			<div id="IllustThumbList" class="IllustItemList">
			</div>
		</div>
	</body>
</html>