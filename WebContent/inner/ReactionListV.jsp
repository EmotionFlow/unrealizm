<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartUnrealizmAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartUnrealizmPcV.jsp").forward(request,response);
	}
	return;
}

ReactionListC results = new ReactionListC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);

final boolean isSmartPhone = Util.isSmartPhone(request);

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>
		<title>follow</title>
		<script>
			let lastCommentId = <%=results.endId%>;

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
					"data": {"UID": <%=results.ownerUserId%>,  "CID": <%=results.contentId%> ,"SD": lastCommentId},
					"dataType": "json",
					"url": "/<%=isApp?"api":"f"%>/ReactionListF.jsp",
				}).then((data) => {
					if (data.end_id > 0) {
						lastCommentId = data.end_id;
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
				initContents();
			});
		</script>
	</head>

	<body>
		<%if(!isApp){%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%}%>
		<article class="Wrapper GridList">
			<div class="FollowListHeader">
				<a class="FollowListTitle" href="/<%=results.ownerUserId%>/<%=results.contentId%>.html">
					<i class="FollowListBackLink fas fa-arrow-left"></i>
				</a>
				<%=_TEX.T("ReactionListV.Title")%>
			</div>
			<section id="IllustThumbList" class="IllustThumbList">
				<%=CCnv.toReactionDetailListHtml(results.reactionDetails, checkLogin, _TEX, isSmartPhone)%>
			</section>
		</article>
		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>