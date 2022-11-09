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

ReactionListC cResults = new ReactionListC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin);

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
			let lastCommentId = <%=cResults.endId%>;

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
					"data": {"UID": <%=cResults.ownerUserId%>,  "CID": <%=cResults.contentId%> ,"SD": lastCommentId},
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
				<a class="FollowListTitle" href="/<%=cResults.ownerUserId%>/<%=cResults.contentId%>.html">
					<i class="FollowListBackLink fas fa-arrow-left"></i>
				</a>
				<%=_TEX.T("ReactionListV.Title")%>
			</div>
			<section id="IllustThumbList" class="IllustThumbList">

			<style>
                .ReactionDetail {
                    margin: 9px 8px;
                    display: flex;
                    align-items: center;
                    border-bottom: 1px solid #ededed;
				}
                .ReactionDetail > .ReactionDetailEmoji > img{
					width: 32px;
				}
                .ReactionDetail > .ReactionDetailUserThumb {
					padding: 0 4px 0 6px;
				}
                .ReactionDetail > .ReactionDetailUserThumb .UserInfoUserThumb {
					display: block;
                    width: 30px;
                    height: 30px;
                    overflow: hidden;
                    border: solid 1px #ccc;
                    border-radius: 80px;
                    background-size: cover;
                    background-position: 50% 50%;
                    background-color: #fff;
                }

                .ReactionDetail > .ReactionDetailUserNickName {
					overflow: hidden;
                }
                .ReactionDetail > .ReactionDetailUserFollow {
                    margin-left: auto;
                }
                .ReactionDetail > .ReactionDetailUserFollow > a {
                    font-size: 14px;
                }
			</style>

			<%for(int count = 0; count<cResults.reactionDetails.size(); count++) {%>
				<% ReactionListC.ReactionDetail r = cResults.reactionDetails.get(count); %>
				<div class="ReactionDetail">
					<div class="ReactionDetailEmoji"><%=CEmoji.parse(r.comment)%></div>
					<div class="ReactionDetailUserThumb">
						<%if(r.fromUserNickname != null){%>
						<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(r.fromUserProfileFile)%>')" href="/<%=r.fromUserId%>/"></a>
						<%}else{%>
						<div class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl("/img/default_user.jpg_120.jpg")%>')"></div>
						<%}%>
					</div>
					<%if(r.fromUserNickname != null){%>
					<a class="ReactionDetailUserNickName" href="/<%=r.fromUserId%>/"><%=r.fromUserNickname%></a>
					<%}else{%>
					<div class="ReactionDetailUserNickName"><%=_TEX.T("ReactionListV.AnonymousUser")%></div>
					<%}%>
					<div class="ReactionDetailUserFollow">
						<%if(r.fromUserId < 0 || r.fromUserId == checkLogin.m_nUserId){%>
						<div></div>
						<%}else if(r.isFollowing){%>
						<div class="ReactionDetailFollowing"><%=_TEX.T("ReactionListV.Following")%></div>
						<%}else{%>
						<a class="BtnBase ReactionDetailFollow UserInfoCmdFollow_<%=r.fromUserId%>"
						   onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>,<%=r.fromUserId%>)"><%=_TEX.T("IllustV.Follow")%></a>
						<%}%>
					</div>
				</div>
			<%}%>
			</section>
		</article>
		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>