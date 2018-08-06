<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.net.URLDecoder"%>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
String strKeyword = Common.TrimAll(Common.ToString(request.getParameter("KWD")));
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=Common.ToStringHtml(strKeyword)%></title>
		<script>
			var g_nNextId = -1;
			function addContentsUser(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": { "SID" : nStartId, "PNM" : 100, "KWD" :  decodeURIComponent("<%=URLEncoder.encode(strKeyword, "UTF-8")%>")},
					"url": "/f/SearchUserByKeywordF.jsp",
					"dataType": "json",
					"success": function(data) {
						//g_nNextId = data.end_id;
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
						
						addContentsIllust(g_nNextId);
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}
			
			function addContentsIllust(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": { "SID" : nStartId, "KWD" :  decodeURIComponent("<%=URLEncoder.encode(strKeyword, "UTF-8")%>")},
					"url": "/f/SearchIllustByKeywordF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							var cItem = data.result[nCnt];
							var $objItem = $("<a/>").addClass("IllustThumb").attr("href", "/IllustViewV.jsp?ID="+cItem.user_id+"&TD="+cItem.content_id);
							var $objItemImg = $("<img/>").addClass("IllustThumbImg").attr("src", cItem.file_name+"_360.jpg");
							$objItem.append($objItemImg);
							$("#IllustThumbList").append($objItem);
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}
			
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": { "SID" : nStartId },
					"url": "/f/NewArrivalF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							var cItem = data.result[nCnt];
							var $objItem = $("<a/>").addClass("IllustThumb").attr("href", "/IllustViewV.jsp?ID="+cItem.user_id+"&TD="+cItem.content_id);
							var $objItemImg = $("<img/>").addClass("IllustThumbImg").attr("src", cItem.file_name+"_360.jpg");
							$objItem.append($objItemImg);
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
				<%if(strKeyword.length()<=0) {%>
				addContents(g_nNextId);
				<%} else {%>
				addContentsUser(g_nNextId);
				<%}%>
			});
			
			$(document).ready(function() {
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 100) {
						<%if(strKeyword.length()<=0) {%>
						addContents(g_nNextId);
						<%} else {%>
						addContentsIllust(g_nNextId);
						<%}%>
					}
				});
			});
		</script>
	</head>

	<body>
		<div class="Wrapper">
			<form id="SearchKeyword" class="SearchKeyword" action="/SearchAllV.jsp" method="get">
				<input class="SearchKeywordInput" type="text" name="KWD" value="<%=Common.ToStringHtml(strKeyword)%>" />
			</form>
			<div id="IllustThumbList" class="IllustThumbList">
			</div>
		</div>
	</body>
</html>