<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/IllustCommentC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(cCheckLogin.m_strNickName.equals("no_name")) {
	getServletContext().getRequestDispatcher("/SetUserNameV.jsp").forward(request,response);
	return;
}

IllustCommentCParam cParam = new IllustCommentCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

IllustCommentC cResults = new IllustCommentC();
if(!cResults.GetResults(cParam)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

SimpleDateFormat cContentDateFromat = new SimpleDateFormat("MM/dd HH:mm");
SimpleDateFormat cImgArg = new SimpleDateFormat("yyyyMMddHHmmss");
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>コメント</title>
		<script type="text/javascript">
			function ResComment(nToUserId, strToUserName) {
				$("#CommentTo").show();
				$("#CommentToTxt").html(strToUserName);
				$("#CommentToId").val(nToUserId);
			}

			function DeleteRes() {
				$("#CommentTo").hide();
				$("#CommentToTxt").html("");
				$("#CommentToId").val(0);
			}

			function SendComment() {
				var strDescription = $("#CommentDescTxt").val();
				var nToUserId = $("#CommentToId").val();
				if(strDescription.length <= 0) return;
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cContent.m_nContentId%>, "DES": strDescription, "TOD":nToUserId },
					"url": "/f/SendCommentF.jsp",
					"success": function(data) {
						location.reload(true);
					}
				});
			}

			$(function(){
				<%
				if(cResults.m_bReply) {
					CComment cComment = cResults.m_cContent.m_vComment.get(cResults.m_cContent.m_vComment.size()-1);
				%>
				ResComment(<%=cComment.m_nUserId%>, '<%=Common.ToStringHtml(cComment.m_strNickName)%>');
				<%}%>
			});
		</script>
	</head>

	<body>
		<div class="Wrapper">

			<div class="IllustItemList">
				<div class="ItemComment">
					<%for(CComment cComment : cResults.m_cContent.m_vComment) {%>
					<div class="ItemCommentItem">
						<a class="CommentThumb" href="/IllustListV.jsp?ID=<%=cComment.m_nUserId%>">
							<img src="<%=Common.GetUrl(cComment.m_strFileName)%>_120.jpg" />
						</a>
						<div class="CommentDetail">
							<a class="CommentName" href="/IllustListV.jsp?ID=<%=cComment.m_nUserId%>">
								<%=Common.ToStringHtml(cComment.m_strNickName)%>
								<span class="CommentDate"><%=cContentDateFromat.format(cComment.m_timeUploadDate)%></span>
							</a>
							<span class="CommentDesc">
								<%if(cComment.m_nToUserId>0) {%>
								<a class="CommentName" href="/IllustListV.jsp?ID=<%=cComment.m_nToUserId%>">
									&gt; <%=Common.ToStringHtml(cComment.m_strToNickName)%>
								</a>
								<%}%>
								<%=Common.ToStringHtml(cComment.m_strDescription)%>
								<span class="CommentCmd">
									<a class="fa fa-reply" href="javascript:void(0)" onclick="ResComment(<%=cComment.m_nUserId%>, '<%=Common.ToStringHtml(cComment.m_strNickName)%>')"></a>
								</span>
							</span>
						</div>
					</div>
					<%}%>
					<div id="CommentTo" class="CommentTo">
						<span id="CommentToTxt"></span>
						<input id="CommentToId" type="hidden" value="0" />
						<span class="typcn typcn-times" onclick="DeleteRes()"></span>
					</div>
					<div class="ItemCommentItem" style="border: none;">
						<input id="CommentDescTxt" class="CommentDescTxt" type="text" maxlength="200" />
						<div class="CommentDescBtn">
							<a class="BtnBase typcn typcn-message" onclick="SendComment()"></a>
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>