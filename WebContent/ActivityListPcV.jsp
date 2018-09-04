<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/ActivityListC.jsp"%>
<%
String strDebug = "";

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

//パラメータの取得
ActivityListCParam cParam = new ActivityListCParam();
cParam.GetParam(request);
cParam.m_nUserId = cCheckLogin.m_nUserId;

//検索結果の取得
ActivityListC cResults = new ActivityListC();
cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("ActivityList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuAct').addClass('Selected');
		});
		</script>

		<script>
		$(function(){
			$.ajaxSingle({
				"type": "post",
				"data": {},
				"url": "/f/UpdateNotifyF.jsp",
				"dataType": "json",
				"success": function(data) {
					// clear notify
					UpdateNotify();
				},
				"error": function(req, stat, ex){
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
				}
			});
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<%@ include file="/inner/TAdTop.jspf"%>

			<%if(cResults.m_vComment.size()<=0) {%>
			<div style="float: left; width: 100%; padding: 250px 0 0 0; text-align: center;">
				<%if(cParam.m_nMode<=0){%>
				コメントやフォローがあると<br />
				ここに表示されます！
				<%}else{%>
				最近行ったコメントやフォローが<br />
				ここに表示されます！
				<%}%>
			</div>
			<%}%>
			<div class="IllustItemList" style="min-height: 600px;">
				<div class="ItemComment">
					<%for(CComment cComment : cResults.m_vComment) {%>
					<%if(cComment.m_nCommentType==CComment.TYPE_COMMENT) {%>
					<a class="ItemCommentItem" href="/IllustViewPcV.jsp?TD=<%=cComment.m_nContentId%>">
						<span class="CommentThumb Heart">
							<span class="Emoji"><%=Common.ToStringHtml(cComment.m_strDescription)%></span>
						</span>
						<span class="CommentDetail Heart">
							<span class="CommentName">
								<%=Common.ToStringHtml(cComment.m_strNickName)%>
							</span>
						</span>
					</a>
					<%} else if(cComment.m_nCommentType==CComment.TYPE_FOLLOW) {%>
					<a class="UserThumb" href="/IllustListPcV.jsp?ID=<%=cComment.m_nUserId%>">
						<span class="UserThumbImg">
							<img src="<%=Common.GetUrl(cComment.m_strFileName)%>_120.jpg" />
						</span>
						<span class="UserThumbName">
							<%=Common.ToStringHtml(cComment.m_strNickName)%>
							<span class="UserThumbNameAdditional">
								<%if(cParam.m_nMode<=0){%>にフォローされました<%}else{%>をフォローしました<%}%>
							</span>
						</span>
					</a>
					<%} else if(cComment.m_nCommentType==CComment.TYPE_HEART) {%>
					<a class="ItemCommentItem" href="/IllustViewPcV.jsp?TD=<%=cComment.m_nContentId%>">
						<span class="CommentThumb Heart">
							<span class="typcn typcn-heart-full-outline"></span>
						</span>
						<span class="CommentDetail Heart">
							<span class="CommentName">
								<%=Common.ToStringHtml(cComment.m_strNickName)%>
							</span>
						</span>
					</a>
					<%}%>
					<%}%>
				</div>
			</div>

			<%@ include file="/inner/TAdBottom.jspf"%>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>