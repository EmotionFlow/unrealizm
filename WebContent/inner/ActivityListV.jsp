<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	if(isApp){
		response.sendRedirect("/StartPoipikuAppV.jsp");
	} else {
		response.sendRedirect("/StartPoipikuV.jsp");
	}
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
		<title><%=_TEX.T("ActivityList.Title")%></title>
	</head>

	<body>
		<article class="Wrapper">
			<%if(cResults.m_vComment.size()<=0) {%>
			<div style="float: left; width: 100%; padding: 250px 0 0 0; text-align: center;">
				<%=(cParam.m_nMode<=0)?_TEX.T("ActivityList.Message.Default.Recive"):_TEX.T("ActivityList.Message.Default.Send")%>
			</div>
			<%}%>
			<div class="IllustItemList">
				<div class="ItemComment">
					<%for(int nCnt=0; nCnt<cResults.m_vComment.size(); nCnt++) {
						CComment cComment = cResults.m_vComment.get(nCnt);%>
					<%if(cComment.m_nCommentType==CComment.TYPE_COMMENT) {%>
					<a class="ItemCommentItem" href="/IllustView<%=isApp?"App":"Pc"%>V.jsp?ID=<%=cCheckLogin.m_nUserId%>&TD=<%=cComment.m_nContentId%>">
						<span class="CommentThumb Heart">
							<span class="Emoji"><%=CEmoji.parse(cComment.m_strDescription)%></span>
						</span>
						<span class="CommentDetail Heart">
							<span class="CommentName">
								<%//=Common.ToStringHtml(cComment.m_strNickName)%>
								<%=_TEX.T("ActivityList.Message.Comment")%>
							</span>
						</span>
					</a>
					<%} else if(cComment.m_nCommentType==CComment.TYPE_FOLLOW) {%>
					<a class="UserThumb" href="/IllustList<%=isApp?"App":"Pc"%>V.jsp?ID=<%=cComment.m_nUserId%>">
						<span class="UserThumbImg" style="background-image: url('<%=Common.GetUrl(cComment.m_strFileName)%>_120.jpg')"></span>
						<span class="UserThumbName">
							<%//=Common.ToStringHtml(cComment.m_strNickName)%>
							<span class="UserThumbNameAdditional">
								<%=String.format((cParam.m_nMode<=0)?_TEX.T("ActivityList.Message.Followed"):_TEX.T("ActivityList.Message.Following"),
										Common.ToStringHtml(cComment.m_strNickName))%>
							</span>
						</span>
					</a>
					<%} else if(cComment.m_nCommentType==CComment.TYPE_HEART) {%>
					<a class="ItemCommentItem" href="/IllustView<%=isApp?"App":"Pc"%>V.jsp?TD=<%=cComment.m_nContentId%>">
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
					<%@ include file="/inner/TAdMid.jsp"%>
					<%}%>
					<%}%>
				</div>
			</div>
		</article>
	</body>
</html>