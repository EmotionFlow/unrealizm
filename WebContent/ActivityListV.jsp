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
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title>アクティビティ</title>
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
					<%for(int nCnt=0; nCnt<cResults.m_vComment.size(); nCnt++) {
						CComment cComment = cResults.m_vComment.get(nCnt);%>
					<%if(cComment.m_nCommentType==CComment.TYPE_COMMENT) {%>
					<a class="ItemCommentItem" href="/IllustViewV.jsp?TD=<%=cComment.m_nContentId%>">
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
					<%} else if(cComment.m_nCommentType==CComment.TYPE_HEART) {%>
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
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMid.jspf"%>
					<%}%>
					<%}%>
				</div>
			</div>
		</div>
	</body>
</html>