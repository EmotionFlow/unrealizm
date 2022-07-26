<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

ActivityListC summaryResults = new ActivityListC();
summaryResults.getSummaryResults(checkLogin);
boolean existUnreadReactionInfo = false;
boolean existUnreadRequestInfo = false;

if (summaryResults.activityCounts.containsKey(InfoList.InfoType.Emoji)) {
	existUnreadReactionInfo = true;
} else if(summaryResults.activityCounts.containsKey(InfoList.InfoType.Gift)) {
	existUnreadReactionInfo = true;
}
if (summaryResults.activityCounts.containsKey(InfoList.InfoType.Request)) {
	existUnreadRequestInfo = true;
}

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>_TEX.T("THeader.Title")%> - <%=_TEX.T("ActivityList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuAct').addClass('Selected');
		});
		</script>

		<script>
			var g_nCategory = 0;

			function addContents() {
				g_chartAnalyze.stop();	//g_bAdding代わり
				const $objMessage = $("<div/>").addClass("Waiting");
				$("#AnalyzeGraph").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"ID" : <%=checkLogin.m_nUserId%>, "MD" : g_nCategory},
					"url": "/api/ActivityAnalyzeF.jsp",
					"dataType": "json",
					"success": function(json) {
						if(json.result>=0) {
							// graph
							setGraphData(json.data);
							updateGraph();
							// list
							$('#AnalyzeList').empty();
							json.list.forEach(function(element, i) {
								var $item = $('<div />').addClass('AnalyzeItem');
								$item.append($('<div />').addClass('AnalyzeItemDesc').html(element.description));
								$item.append($('<div />').addClass('AnalyzeItemRate').html(element.emoji_num+'%'));
								$('#AnalyzeList').append($item);
							});
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function changeCategory(elm, param) {
				<%if(checkLogin.m_nPassportId == Common.PASSPORT_OFF) {%>
				if (param > 0) {
					showIntroductionPoipassDlgHtml(
						'',
						"<%=_TEX.T("ActivityAnalyze.IntroductionPoipass")%>",
						'<%=_TEX.T("IntroductionPoipass.ShowButton")%>',
						'<%=_TEX.T("IntroductionPoipass.FooterHtml")%>'
					);
					return;
				}
				<%}%>
				g_nPage = 0;
				g_nCategory = param;
				$("#IllustThumbList").empty();
				$('#CategoryMenu .CategoryBtn').removeClass('Selected');
				$(elm).addClass('Selected');
				updateCategoryMenuPos(300);
				addContents();
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
			});
		</script>

		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.css" integrity="sha512-/zs32ZEJh+/EO2N1b0PEdoA10JkdC3zJ8L5FTiQu82LR9S/rOQNfQN7U59U9BC12swNeRAz3HSzIL2vpp4fv3w==" crossorigin="anonymous" />
		<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.bundle.js" integrity="sha512-zO8oeHCxetPn1Hd9PdDleg5Tw1bAaP0YmNvPY8CwcRyUk7d7/+nyElmFrB6f7vg4f7Fv4sui1mcep8RIEShczg==" crossorigin="anonymous"></script>
		<script>
			var g_chartAnalyze;
			$(function(){
				g_chartAnalyze = initGraph(document.getElementById('AnalyzeChart').getContext('2d'));
				updateCategoryMenuPos(0);
				addContents();
			});
		</script>
		<style>
			body {padding-top: 79px !important;}
			.IllustItemList {background: #fff;}
			#AnalyzeList {display: flex; flex-flow: column; align-items: center;}
			.AnalyzeItem {flex: 0 0 80%; width: 80%; display: flex; flex-flow: row nowrap; background: #3498db; margin: 5px 0; box-sizing: border-box; padding: 5px 10px;}
			.AnalyzeItem .AnalyzeItemDesc {flex: 1 1;}
			.AnalyzeItem .AnalyzeItemDesc .Twemoji {display: block; width: 24px; height: 24px; line-height: 24px;}
			.AnalyzeItem .AnalyzeItemRate {flex: 0 0 100px;text-align: right; line-height: 24px;}
		</style>
	</head>
	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/ActivityListPcV.jsp?TY=1"><%=existUnreadReactionInfo?"<span class=\"ActivityListBadge\"></span>":""%><%=_TEX.T("THeader.Menu.Act.Reaction")%>
				</a></li>
				<li><a class="TabMenuItem" href="/ActivityListPcV.jsp?TY=3"><%=existUnreadRequestInfo?"<span class=\"ActivityListBadge\"></span>":""%><%=_TEX.T("THeader.Menu.Act.Request")%>
				</a></li>
				<li><a class="TabMenuItem Selected" href="/ActivityAnalyzePcV.jsp"><%=_TEX.T("THeader.Menu.Act.Analyze")%>
				</a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper">
			<nav id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn Selected" onclick="changeCategory(this, 0)"><%=_TEX.T("ActivityList.Category.7days")%></a>
				<a class="BtnBase CategoryBtn" onclick="changeCategory(this, 1)"><%=_TEX.T("ActivityList.Category.30days")%></a>
				<a class="BtnBase CategoryBtn" onclick="changeCategory(this, 2)"><%=_TEX.T("ActivityList.Category.Total")%></a>
			</nav>
			<section id="AnalyzeGraph" class="IllustItemList" style="padding: 10px;">
				<canvas id="AnalyzeChart" width="340" height="340"></canvas>
			</section>
			<section id="AnalyzeList" class="IllustItemList">
			</section>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>