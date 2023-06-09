<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request,response);
	return;
}

FollowListC results = new FollowListC();
results.getParam(request);
results.m_nMode = followMode;
boolean bRtn = results.getResults(checkLogin);

final String title;
if (results.m_nMode == FollowListC.MODE_FOLLOWING) {
	title = _TEX.T("FollowListV.Title");
} else {
	title = _TEX.T("FollowerListV.Title");
}
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>follow</title>
		<script>
			let lastUserId = <%=results.endId%>;

			const loadingSpinner = {
				appendTo: "#IllustThumbList",
				className: "loadingSpinner",
			}
			const observer = createIntersectionObserver(addContents, {threshold: 0.5});

			function addContents(){
				console.log("addContents");
				appendLoadingSpinner(loadingSpinner.appendTo, loadingSpinner.className);
				return $.ajax({
					"type": "post",
					"data": {"ID": <%=results.userId%> ,"SD": lastUserId, "PG": 0},
					"dataType": "json",
					<%if(followMode == FollowListC.MODE_FOLLOWING){%>
					"url": "/<%=g_isApp?"api":"f"%>/FollowListF.jsp",
					<%}else{%>
					"url": "/<%=g_isApp?"api":"f"%>/FollowerListF.jsp",
					<%}%>
				}).then((data) => {
					if (data.end_id > 0) {
						lastUserId = data.end_id;
						const contents = document.getElementById('IllustThumbList');
						$(contents).append(data.html);
						observer.observe(contents.lastElementChild);
					}
					removeLoadingSpinners(loadingSpinner.className);
				}, (error) => {
					DispMsg('Connection error');
				});
			}


			function initContents(){
				<%if(!Util.isBot(request)){%>
				const contents = document.getElementById('IllustThumbList');
				setTimeout(()=>{observer.observe(contents.lastElementChild);}, 1000);
				<%}%>
			}

			$(function(){
				$('#MenuMe').addClass('Selected');
				initContents();
			});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="FollowListHeader">
				<a class="FollowListTitle" href="/<%=results.userId%>">
					<i class="FollowListBackLink fas fa-arrow-left"></i>
				</a>
				<%=results.nickName%> <%=title%>
			</div>
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt = 0; nCnt<results.userList.size(); nCnt++) {
					CUser cUser = results.userList.get(nCnt);%>

					<%if(g_isApp){%>
					<%=CCnv.toHtmlUserMini(cUser)%>
					<%}else{%>
					<%=CCnv.toHtmlUserMini(cUser)%>
					<%}%>
				<%}%>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
