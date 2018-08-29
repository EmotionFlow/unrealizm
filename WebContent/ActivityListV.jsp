<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/ActivityListC.jsp"%>
<%
String strDebug = "";

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
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
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>アクティビティ</title>
		<style>
			.ItemCommentItem {
				border-bottom: solid 1px #ccc;
				padding-bottom: 5px;
			}
		</style>
	</head>

	<body>
		<div class="Wrapper">
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
			<div class="IllustItemList">
				<div class="ItemComment">
					<%for(CComment cComment : cResults.m_vComment) {%>
					<%if(cComment.m_nCommentType==0) {%>
					<a class="ItemCommentItem" href="/IllustViewV.jsp?TD=<%=cComment.m_nContentId%>">
						<span class="CommentThumb">
							<img src="<%=Common.GetUrl(cComment.m_strFileName)%>_120.jpg" />
						</span>
						<span class="CommentDetail">
							<span class="CommentName">
								<%=Common.ToStringHtml(cComment.m_strNickName)%>
							</span>
							<span class="CommentDesc">
								<%if(cComment.m_nToUserId>0) {%>
								<span class="CommentName">
									&gt; <%=Common.ToStringHtml(cComment.m_strToNickName)%>
								</span>
								<%}%>
								<%=Common.ToStringHtml(cComment.m_strDescription)%>
							</span>
						</span>
					</a>
					<%} else if(cComment.m_nCommentType==1) {%>
					<a class="UserThumb" href="/IllustListV.jsp?ID=<%=cComment.m_nUserId%>">
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
					<%} else if(cComment.m_nCommentType==2) {%>
					<a class="ItemCommentItem" href="/IllustViewV.jsp?TD=<%=cComment.m_nContentId%>">
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
		</div>
	</body>
</html>