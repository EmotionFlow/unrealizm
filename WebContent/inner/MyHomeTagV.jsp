<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartPoipikuV.jsp").forward(request,response);
	}
	return;
}

MyHomeTagC cResults = new MyHomeTagC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TCreditCard.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<title>home</title>

		<%@ include file="/inner/TDeleteContent.jsp"%>
		<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<script>
		var g_nEndId = <%=cResults.m_nEndId%>;
		var g_bAdding = false;
		function addContents() {
			if(g_bAdding) return;
			g_bAdding = true;
			var $objMessage = $("<div/>").addClass("Waiting");
			$("#IllustThumbList").append($objMessage);
			$.ajax({
				"type": "post",
				"data": {"SD" : g_nEndId, "MD" : <%=CCnv.MODE_SP%>, "VD" : <%=CCnv.VIEW_DETAIL%>},
				"dataType": "json",
				"url": "/f/MyHomeTag<%=isApp?"App":""%>F.jsp",
				"success": function(data) {
					if(data.end_id>0) {
						g_nEndId = data.end_id;
						$("#IllustThumbList").append(data.html);
						$(".Waiting").remove();
						if(vg)vg.vgrefresh();
						g_bAdding = false;
						console.log(location.pathname+'/'+g_nEndId+'.html');
						gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nEndId+'.html'});
					} else {
						$(window).unbind("scroll.addContents");
					}
					$(".Waiting").remove();
				},
				"error": function(req, stat, ex){
					DispMsg('Connection error');
				}
			});
		}

		$(function(){
			$(window).bind("scroll.addContents", function() {
				$(window).height();
				if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
					addContents();
				}
			});
		});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

		<article class="Wrapper ItemList">
			<div id="IllustThumbList" class="IllustThumbList">
				<div style="width: 100%; box-sizing: border-box; padding: 10px 15px 0 15px; font-size: 16px; text-align: right;">
					<a href="/MyHomeTagSetting<%=isApp?"App":""%>V.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyHomeTagSetting.Title")%></a>
				</div>
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 150px 10px 50px 10px; text-align: center; box-sizing: border-box;">
					<%=_TEX.T("MyHomeTag.FirstMsg")%>
				</div>
				<%}%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%if(isApp){%>
						<%= CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
					<%}else{%>
						<%= CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult, CCnv.VIEW_DETAIL)%>
					<%}%>
					<%if((nCnt+1)%5==0) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</div>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
</html>