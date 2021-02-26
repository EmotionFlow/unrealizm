<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(SP_REVIEW && !checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	return;
}

NewArrivalC cResults = new NewArrivalC();
cResults.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(checkLogin);


String categoryInfo = "";
if(cResults.m_nCategoryId>=0) categoryInfo = _TEX.T(String.format("Category.C%d.Info", cResults.m_nCategoryId)).trim();
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>recent</title>
		<script>
			var g_nPage = 1;
			var g_nCategory = <%=cResults.m_nCategoryId%>;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage, "CD" : g_nCategory},
					"url": "/f/NewArrivalAppF.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nCategory+'/'+g_nPage+'.html'});
						} else {
							//$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			var categoryInfos = [];
			<%for(int i=0; i<=Common.CATEGORY_ID_MAX; i++) {%>
			categoryInfos[<%=i%>] = '<%=_TEX.T(String.format("Category.C%d.Info", i)).trim()%>';
			<%}%>
			categoryInfos[29] = '<span style="display: flex; flex-flow: column; justify-content: center; align-items: center;"><a href="/event/2021_02_18_blskip/TopV.jsp"><img style="width: 300px; margin: 0 0 10px 0;" src="/event/2021_02_18_blskip/poipiku_blskip_bn.png" /></a><iframe width="300" height="168" src="https://www.youtube.com/embed/v7d6hUxqMIs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><a style="margin: 10px 0 0 0;" href="http://bit.ly/3ug09mp" target="_blank"><img src="/event/2021_02_18_blskip/poipiku_blskip_button.png" /></a></span>';

			function changeCategory(elm, param) {
				g_nPage = 0;
				g_nCategory = param;
				if(g_nCategory>=0) {
					$('#CategoryInfo').empty();
					$('#CategoryInfo').html(categoryInfos[g_nCategory])
				}
				$("#IllustThumbList").empty();
				$('#CategoryMenu .CategoryBtn').removeClass('Selected');
				$(elm).addClass('Selected');
				updateCategoryMenuPos(300);
				g_bAdding = false;
				addContents();
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				$(window).bind("scroll.addContents", function() {
					if(g_bAdding) return;
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
			});

			$(function(){
				updateCategoryMenuPos(0);
			});
		</script>
	</head>

	<body>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

		<article class="Wrapper">
			<nav id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(cResults.m_nCategoryId<0){%> Selected<%}%>" onclick="changeCategory(this, -1)"><%=_TEX.T("Category.All")%></a>
				<%for(int nCategoryId : Common.CATEGORY_ID) {%>
				<a class="BtnBase CategoryBtn CC<%=nCategoryId%> <%if(nCategoryId==cResults.m_nCategoryId){%> Selected<%}%>" onclick="changeCategory(this, <%=nCategoryId%>)"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></a>
				<%}%>
			</nav>

			<header id="CategoryInfo" class="CategoryInfo">
				<%if(!categoryInfo.isEmpty()) {%>
				<%if(cResults.m_nCategoryId==29) {%>
				<span style="display: flex; flex-flow: column; justify-content: center; align-items: center;">
					<a href="/event/2021_02_18_blskip/TopV.jsp">
						<img style="width: 300px; margin: 0 0 10px 0;" src="/event/2021_02_18_blskip/poipiku_blskip_bn.png" />
					</a>
					<iframe width="300" height="168" src="https://www.youtube.com/embed/v7d6hUxqMIs" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
					<a style="margin: 10px 0 0 0;" href="http://bit.ly/3ug09mp" target="_blank">
						<img src="/event/2021_02_18_blskip/poipiku_blskip_button.png" />
					</a>
				</span>
				<%} else {%>
					<%=categoryInfo%>
				<%}%>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
				<%}%>
				<%@ include file="/inner/TAd336x280_mid.jsp"%>
			</section>
		</article>
	</body>
</html>
