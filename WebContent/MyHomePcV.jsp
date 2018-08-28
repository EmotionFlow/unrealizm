
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/MyHomeC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

MyHomeCParam cParam = new MyHomeCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

MyHomeC cResults = new MyHomeC();
boolean bRtn = cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyHomePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<script>
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
						var $objItemCommentItem = CreateCommentItemPc(nId, <%=cCheckLogin.m_nUserId%>, '<%=cCheckLogin.m_strNickName%>', nToUserId, strToUserNickName, strDescription);
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
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>

		<div class="TabMenu">
			<a class="TabMenuItem Selected" href="/"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
			<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
			<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div id="IllustItemList" class="IllustItemList">
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 160px 0; text-align: center;">
					ポイピクへようこそ<br />
					ポイピクはアナログイラストを愛する人のためのSNSです。<br />
					<br />
					<br />
					<a class="BtnBase" href="/NewArrivalPcV.jsp">
						フォローする人を探す
					</a>
				</div>
				<%}%>
				<%for(CContent cContent : cResults.m_vContentList) {%>
				<div class="IllustItem" id="IllustItem_<%=cContent.m_nContentId%>">
					<div class="IllustItemUser">
						<a class="IllustItemUserThumb" href="/IllustListPcV.jsp?ID=<%=cContent.m_nUserId%>">
							<img class="IllustItemUserThumbImg" src="<%=cContent.m_cUser.m_strFileName%>_120.jpg" />
						</a>
						<a class="IllustItemUserName" href="/IllustListPcV.jsp?ID=<%=cContent.m_nUserId%>">
							<%=Common.ToStringHtml(cContent.m_cUser.m_strNickName)%>
						</a>
					</div>

					<span class="Category C<%=cContent.m_nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))%></span>

					<a class="IllustItemThumb" href="/IllustDetailPcV.jsp?TD=<%=cContent.m_nContentId%>" target="_blank">
						<img class="IllustItemThumbImg" src="<%=Common.GetUrl(cContent.m_strFileName)%>_640.jpg" />
					</a>

					<div class="IllustItemCommand">
						<a class="IllustItemCommandComment typcn typcn-message" href="/IllustCommentPcV.jsp?TD=<%=cContent.m_nContentId%>"></a>
						<a id="IllustItemCommandCommentNum_<%=cContent.m_nContentId%>" class="IllustItemCommandCommentNum" href="/IllustCommentPcV.jsp?TD=<%=cContent.m_nContentId%>">&nbsp;<%=cContent.m_nCommentNum%></a>
						<%String strHeartClass = (cContent.m_bBookmark)?"typcn-heart-full-outline Selected":"typcn-heart-outline"; %>
						<a id="IllustItemCommandHeart_<%=cContent.m_nContentId%>" class="IllustItemCommandHeart typcn <%=strHeartClass%>" href="javascript:void(0)" onclick="UpdateBookmark(<%=cContent.m_nContentId%>)"></a>
						<a class="IllustItemCommandHeartNum" id="IllustItemCommandHeartNum_<%=cContent.m_nContentId%>" href="/IllustHeartPcV.jsp?ID=<%=cContent.m_nUserId%>&amp;TD=<%=cContent.m_nContentId%>">&nbsp;<%=cContent.m_nBookmarkNum%></a>
						<div class="IllustItemCommandSub">
							<%String strUrl = URLEncoder.encode("https://poipiku.com/"+cContent.m_nUserId+"/"+cContent.m_nContentId+".html", "UTF-8"); %>
							<a class="social-icon Twitter" href="https://twitter.com/share?url=<%=strUrl%>">&#229;</a>
							<%if(cContent.m_nUserId==cCheckLogin.m_nUserId) {%>
							<a class="IllustItemCommandDelete typcn typcn-trash" href="javascript:void(0)" onclick="DeleteContent(<%=cContent.m_nContentId%>)"></a>
							<%}%>
							<a class="IllustItemCommandInfo typcn typcn-info-large" href="/ReportFormPcV.jsp?TD=<%=cContent.m_nContentId%>"></a>
						</div>
					</div>
					<div class="ItemComment Home">
						<%boolean bReply = false;%>
						<%for(CComment cComment : cContent.m_vComment) {%>
						<div class="ItemCommentItem">
							<a class="CommentName" href="/IllustListPcV.jsp?ID=<%=cComment.m_nUserId%>">
								<%=Common.ToStringHtml(cComment.m_strNickName)%>
							</a>
							<span class="CommentDesc">
								<%if(cComment.m_nToUserId>0) {%>
								<a class="CommentName" href="/IllustListPcV.jsp?ID=<%=cComment.m_nToUserId%>">
									&gt; <%=Common.ToStringHtml(cComment.m_strToNickName)%>
								</a>
								<%}%>
								<a href="/IllustCommentPcV.jsp?TD=<%=cComment.m_nContentId%>">
									<%=Common.AutoLinkPc(Common.ToStringHtml(cComment.m_strDescription))%>
								</a>
								<span class="CommentCmd">
									<a class="fa fa-reply" onclick="ResComment(<%=cContent.m_nContentId%>, <%=cComment.m_nUserId%>, '<%=Common.ToStringHtml(cComment.m_strNickName)%>')"></a>
								</span>
							</span>
						</div>
						<%
							bReply = (cContent.m_nUserId==cCheckLogin.m_nUserId && cComment.m_nUserId!=cCheckLogin.m_nUserId);
						}
						%>
						<div class="CommentTo" id="CommentTo_<%=cContent.m_nContentId%>">
							<span>&gt; </span>
							<span class="CommentToTxt" id="CommentToTxt_<%=cContent.m_nContentId%>"></span>
							<input id="CommentToId_<%=cContent.m_nContentId%>" type="hidden" value="0" />
							<span class="typcn typcn-times" onclick="DeleteRes(<%=cContent.m_nContentId%>)"></span>
						</div>
						<div class="ItemCommentItem">
							<%
							String strComment = "";
							if(bReply) {
								CComment cComment = cContent.m_vComment.get(cContent.m_vComment.size()-1);
								strComment = "> " + Common.ToStringHtml(cComment.m_strNickName);
							}
							%>
							<input class="CommentDescTxt" id="CommentDescTxt_<%=cContent.m_nContentId%>" type="text" maxlength="200" value="<%=Common.ToStringHtml(strComment)%>" />
							<div class="CommentDescBtn">
								<a class="BtnBase typcn typcn-message" data-id="<%=cContent.m_nContentId%>" onclick="SendComment(<%=cContent.m_nContentId%>)"></a>
							</div>
						</div>
					</div>
				</div>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/MyHomePcV.jsp", "", cParam.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>