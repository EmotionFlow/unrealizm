<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	request.getRequestDispatcher("/MyIllustListPcV.jsp").forward(request,response);
	return;
}

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	if(!cCheckLogin.m_bLogin) {
		if(isApp){
			response.sendRedirect("/StartPoipikuAppV.jsp");
		} else {
			getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
		}
		return;
	}
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}

if(isApp){
	cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}

cResults.m_bDispUnPublished = true;
if(!cResults.getResults(cCheckLogin) || !cResults.m_bOwner) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%=isApp?"<!-- ":""%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%=isApp?" -->":""%>
		<%=!isApp?"<!-- ":""%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%=!isApp?" -->":""%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<title><%=cResults.m_cUser.m_strNickName%></title>
		<%@ include file="/inner/TTweetMyBox.jsp"%>
		<script>
			var g_nPage = 1; // start 1
			var g_strKeyword = '<%=cResults.m_strKeyword%>';
			var g_bAdding = false;
			function addMyContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"ID": <%=cResults.m_nUserId%>, "KWD": g_strKeyword,  "PG" : g_nPage},
					"url": "/f/MyIllustList<%=isApp?"App":""%>F.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addMyContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function changeCategory(elm, param) {
				g_nPage = 0;
				g_strKeyword = param;
				g_bAdding = false;
				$("#IllustThumbList").empty();
				$('#CategoryMenu .CategoryBtn').removeClass('Selected');
				$(elm).addClass('Selected');
				updateCategoryMenuPos(300);
				$(window).unbind("scroll.addMyContents");
				<%if(!cResults.m_bBlocking && !cResults.m_bBlocked){%>
				$(window).bind("scroll.addMyContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addMyContents();
					}
				});
				addMyContents();
				<%}%>
			}

			$(function(){
				updateCategoryMenuPos(0);
				$(window).bind("scroll.addMyContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 600) {
						addMyContents();
					}
				});
			});
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		.HeaderSetting {text-align: center; position: absolute; top: 12px; right: 10px;}
		.NoContents {display: block; padding: 250px 0; width: 100%; text-align: center;}

		.TweetMyBox {padding-top: 5px; text-align: center;}

		</style>
	</head>

	<body>
		<%if(!isApp){%>
			<%@ include file="/inner/TMenuPc.jsp" %>
			<%if(bSmartPhone){%>
			<script>$(function () {
				$("#MenuSearch").hide();
				$("#MenuSettings").show();
			})</script>
			<%}%>
		<%}else{%>
			<%@ include file="/inner/TMenuApp.jsp" %>
		<%}%>

		<article class="Wrapper">
			<div class="TweetMyBox">
				<a id="OpenTweetMyBoxDlgBtn" href="javascript:void(0);" class="BtnBase">
					<i class="fab fa-twitter"></i> <%=_TEX.T("MyIllustListV.TweetMyBox")%>
				</a>
			</div>
			<%if(cResults.m_vCategoryList.size()>0) {%>
			<nav id="CategoryMenu" class="CategoryMenu">
				<span class="BtnBase CategoryBtn <%if(cResults.m_strKeyword.isEmpty()){%> Selected<%}%>" onclick="changeCategory(this, '')"><%=_TEX.T("Category.All")%></span>
				<%for(CTag cTag : cResults.m_vCategoryList) {%>
				<span class="BtnBase CategoryBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strKeyword)){%> Selected<%}%>" onclick="changeCategory(this, '<%=cTag.m_strTagTxt%>')"><%=Util.toDescString(cTag.m_strTagTxt)%></span>
				<%}%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()>0){%>
					<%if(isApp){%>
						<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
							CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%=CCnv.toMyThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, cCheckLogin, CCnv.SP_MODE_APP)%>
						<%}%>
					<%}else{%>
						<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
							CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%=CCnv.toMyThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, cCheckLogin)%>
						<%}%>
					<%}%>

				<%}else{%>
					<span class="NoContents"><%=_TEX.T("IllustListV.NoContents.Me")%></span>
				<%}%>
			</section>
		</article>
	</body>
</html>