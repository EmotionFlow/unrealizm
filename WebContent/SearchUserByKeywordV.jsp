<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
String strKeyword = Common.ToString(request.getParameter("KWD"));
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title><%=Common.ToStringHtml(strKeyword)%></title>
		<script>
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId, "KWD" : decodeURIComponent("<%=URLEncoder.encode(strKeyword, "UTF-8")%>")},
					"url": "/f/SearchUserByKeywordF.jsp",
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