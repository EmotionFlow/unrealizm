<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ include file="/IllustViewC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustViewCParam cParam = new IllustViewCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

IllustViewC cResults = new IllustViewC();
if(!cResults.GetResults(cParam)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

DateFormat cContentDateFromat = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT, request.getLocale());
cContentDateFromat.setTimeZone(Common.GetTimeZone(request));
SimpleDateFormat cImgArg = new SimpleDateFormat("yyyyMMddHHmmss");
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%
		String strTitle = cResults.m_cContent.m_cUser.m_strNickName;
		String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
		if(strs.length>0 && strs[0].length()>0) {
			strTitle = strs[0];
		}
		strTitle = Common.SubStrNum(strTitle, 10);
		%>
		<title><%=strTitle%></title>
		<script type="text/javascript">
			var g_nNextId = <%=cResults.m_cContent.m_nContentId%>;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": { "SID" : nStartId, "ID" :  <%=cResults.m_cContent.m_nUserId%>},
					"url": "/f/IllustListTimeLineF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						if(g_nNextId == -1) {
							$('#InfoMsg').show();
						}
						for(var nCnt=0; nCnt<data.result.length; nCnt++) {
							var cItem = data.result[nCnt];
							var $objItem = CreateIllustItem(cItem, <%=cCheckLogin.m_nUserId%>);
							var $objUserInfoCmdFollow = $("#UserInfoCmdFollow").clone(true).attr('id', '');
							$objItem.find('.IllustItemUser').append($objUserInfoCmdFollow);

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
						$('#IllustItemCommandHeartNum_'+nContentId).html(data.bookmark_num);
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
						sendObjectMessage("deleted");
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

			function UpdateFollow() {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bFollow)?0:1 },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow').addClass('Selected');
							$('.UserInfoCmdFollow').html("フォロー中");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow').removeClass('Selected');
							$('.UserInfoCmdFollow').html("フォローする");
						} else {
							DispMsg('フォローできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				<%
				if(cResults.m_bReply) {
					CComment cComment = cResults.m_cContent.m_vComment.get(cResults.m_cContent.m_vComment.size()-1);
				%>
				ResComment(<%=cResults.m_cContent.m_nContentId%>, <%=cComment.m_nUserId%>, '<%=Common.ToStringHtml(cComment.m_strNickName)%>');
				<%}%>
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
		<div class="Wrapper">

			<div class="IllustItemList">
				<div class="IllustItem" id="IllustItem_<%=cResults.m_cContent.m_nContentId%>">
					<div class="IllustItemUser">
						<a class="IllustItemUserThumb" href="/IllustListV.jsp?ID=<%=cResults.m_cContent.m_nUserId%>">
							<img class="IllustItemUserThumbImg" src="<%=Common.GetUrl(cResults.m_cContent.m_cUser.m_strFileName)%>_120.jpg" />
						</a>
						<a class="IllustItemUserName" href="/IllustListV.jsp?ID=<%=cResults.m_cContent.m_nUserId%>"><%=cResults.m_cContent.m_cUser.m_strNickName%></a>

						<%if(!cResults.m_bOwner){
							if(cResults.m_bFollow){%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow Selected" onclick="UpdateFollow()">フォロー中</span>
						<%	} else {%>
						<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" onclick="UpdateFollow()">フォローする</span>
						<%	}
						}%>
					</div>

					<div class="IllustItemThumb">
						<img class="IllustItemThumbImg" src="<%=Common.GetUrl(cResults.m_cContent.m_strFileName)%>" />
					</div>

					<div class="IllustItemCommand">
						<a class="IllustItemCommandComment typcn typcn-message" href="/IllustCommentV.jsp?TD=<%=cResults.m_cContent.m_nContentId%>"></a>
						<a class="IllustItemCommandCommentNum" href="/IllustCommentV.jsp?TD=<%=cResults.m_cContent.m_nContentId%>"><%=cResults.m_cContent.m_nCommentNum%></a>
						<span id="IllustItemCommandHeart_<%=cResults.m_cContent.m_nContentId%>" class="IllustItemCommandHeart typcn <%if(cResults.m_bBookmark){%>typcn-heart-full-outline Selected<%}else{%>typcn-heart-outline<%}%>" onclick="UpdateBookmark(<%=cResults.m_cContent.m_nContentId%>)"></span>
						<a id="IllustItemCommandHeartNum_<%=cResults.m_cContent.m_nContentId%>" class="IllustItemCommandHeartNum" href="/IllustHeartV.jsp?ID=<%=cResults.m_cContent.m_nUserId%>&TD=<%=cResults.m_cContent.m_nContentId%>"><%=cResults.m_cContent.m_nBookmarkNum%></a>
						<div class="IllustItemCommandSub">
							<%String strUrl = URLEncoder.encode(String.format("https://analogico.pipa.jp/%d/%d.html", cResults.m_cContent.m_nUserId, cResults.m_cContent.m_nContentId), "UTF-8");%>
							<a class="social-icon Twitter" href="https://twitter.com/share?url=<%=strUrl%>">&#229;</a>
							<%if(cResults.m_bOwner || cCheckLogin.m_nUserId==1) {%>
							<a class="IllustItemCommandDelete typcn typcn-trash" href="javascript:void(0)" onclick="DeleteContent(<%=cResults.m_cContent.m_nContentId%>)"></a>
							<%} else {%>
							<a class="IllustItemCommandInfo typcn typcn-info-large" href="/ReportFormV.jsp?TD=<%=cResults.m_cContent.m_nContentId%>"></a>
							<%}%>
						</div>
					</div>

					<div class="ItemComment Home">
						<%if(!cResults.m_cContent.m_strDescription.isEmpty()) {%>
						<div class="ItemCommentItem">
							<span class="CommentName">
								<%=Common.ToStringHtml(cResults.m_cContent.m_cUser.m_strNickName)%>
							</span>
							<span class="CommentDesc">
								<span>
									<%=Common.AutoLinkPc(Common.ToStringHtml(cResults.m_cContent.m_strDescription))%>
								</span>
								<span class="CommentCmd">
									<a class="fa fa-reply" href="javascript:void(0)" onclick="ResComment(<%=cResults.m_cContent.m_nContentId%>, <%=cResults.m_cContent.m_cUser.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_cContent.m_cUser.m_strNickName)%>')"></a>
								</span>
							</span>
						</div>
						<%}%>
						<%for(CComment cComment : cResults.m_cContent.m_vComment) {%>
						<div class="ItemCommentItem">
							<a class="CommentName" href="/IllustListV.jsp?ID=<%=cComment.m_nUserId%>">
								<%=Common.ToStringHtml(cComment.m_strNickName)%>
							</a>
							<span class="CommentDesc">
								<%if(cComment.m_nToUserId>0) {%>
								<a class="CommentName" href="/IllustListV.jsp?ID=<%=cComment.m_nToUserId%>">
									&gt; <%=Common.ToStringHtml(cComment.m_strToNickName)%>
								</a>
								<%}%>
								<a href="/IllustCommentV.jsp?TD=<%=cResults.m_cContent.m_nContentId%>">
									<%=Common.ToStringHtml(cComment.m_strDescription)%>
								</a>
								<span class="CommentCmd">
									<a class="fa fa-reply" href="javascript:void(0)" onclick="ResComment(<%=cResults.m_cContent.m_nContentId%>, <%=cComment.m_nUserId%>, '<%=Common.ToStringHtml(cComment.m_strNickName)%>')"></a>
								</span>
							</span>
						</div>
						<%}%>
						<div id="CommentTo_<%=cResults.m_cContent.m_nContentId%>" class="CommentTo">
							<span>&gt; </span>
							<span id="CommentToTxt_<%=cResults.m_cContent.m_nContentId%>"></span>
							<input id="CommentToId_<%=cResults.m_cContent.m_nContentId%>" type="hidden" value="0" />
							<span class="typcn typcn-times" onclick="DeleteRes(<%=cResults.m_cContent.m_nContentId%>)"></span>
						</div>
						<div class="ItemCommentItem">
							<input id="CommentDescTxt_<%=cResults.m_cContent.m_nContentId%>" class="CommentDescTxt" type="text" maxlength="200" />
							<div class="CommentDescBtn">
								<a class="BtnBase typcn typcn-message" onclick="SendComment(<%=cResults.m_cContent.m_nContentId%>)"></a>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div id="IllustItemList" class="IllustItemList">
			</div>
		</div>
	</body>
</html>