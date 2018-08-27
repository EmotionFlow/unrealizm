<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartAnalogicoV.jsp");
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
							var cItem = data.result[nCnt];
							var $objItem = CreateIllustItem(cItem, <%=cCheckLogin.m_nUserId%>);
							$("#IllustItemList").append($objItem);
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function UpdateBookmark(nContentId) {
				var bBookmark = $("#IllustItemCommandHeart_"+nContentId).hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "CID": nContentId, "CHK": (bBookmark)?0:1 },
					"url": "/f/UpdateBookmarkF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(bBookmark) {
							$("#IllustItemCommandHeart_"+nContentId).addClass('typcn-heart-outline').removeClass('typcn-heart-full-outline').removeClass('Selected');
						} else {
							$("#IllustItemCommandHeart_"+nContentId).removeClass('typcn-heart-outline').addClass('typcn-heart-full-outline').addClass('Selected');
						}
						$('#IllustItemCommandHeartNum_'+nContentId).html("&nbsp;"+data.bookmark_num);
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
			}

			function DeleteContent(nContentId) {
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				$.ajaxSingle({
					"type": "post",
					"data": { "UID":<%=cCheckLogin.m_nUserId%>, "CID":nContentId },
					"url": "/f/DeleteContentF.jsp",
					"dataType": "json",
					"success": function(data) {
						$('#IllustItem_'+nContentId).remove();
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function ResComment(nId, nToUserId, strToUserName) {
				$("#CommentTo_"+nId).show();
				$("#CommentToTxt_"+nId).html(strToUserName);
				$("#CommentToId_"+nId).val(nToUserId);
			}

			function DeleteRes(nId) {
				$("#CommentTo_"+nId).hide();
				$("#CommentToTxt_"+nId).html("");
				$("#CommentToId_"+nId).val(0);
			}

			function SendComment(nId) {
				var strDescription = $("#CommentDescTxt_"+nId).val();
				var nToUserId = $("#CommentToId_"+nId).val();
				var strToUserNickName = $("#CommentToTxt_"+nId).html();
				if(strDescription.length <= 0) return;
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": nId, "DES": strDescription, "TOD":nToUserId },
					"url": "/f/SendCommentF.jsp",
					"success": function(data) {
						var $objItemCommentItem = CreateCommentItem(nId, <%=cCheckLogin.m_nUserId%>, '<%=cCheckLogin.m_strNickName%>', nToUserId, strToUserNickName, strDescription);
						$('#IllustItem_'+nId + ' .ItemComment .ItemCommentItem:last').before($objItemCommentItem);
						DeleteRes(nId);
						$("#CommentDescTxt_"+nId).val('');
						//location.reload(true);
					}
				});
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
				ポイピクはアナログイラストを愛する人のためのSNSです。<br />
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