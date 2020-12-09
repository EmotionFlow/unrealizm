<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>recent</title>
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
					"url": "/f/NewArrivalF_SP.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
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

			$(function(){
				addContents();
			});

			$(document).ready(function() {
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
			});
		</script>

		<style>
		.SideBarMid {margin: 0; height: 0; overflow: hidden;}
		</style>
	</head>

	<body>
		<article class="Wrapper">
			<div id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn Selected" onclick="changeCategory(this, -1)"><%=_TEX.T("Category.All")%></a>
				<%for(int nCategoryId : Common.CATEGORY_ID) {%>
				<a class="BtnBase CategoryBtn" onclick="changeCategory(this, <%=nCategoryId%>)"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></a>
				<%}%>
			</div>

			<div id="IllustThumbList" class="IllustThumbList"></div>
		</article>
	</body>
</html>
