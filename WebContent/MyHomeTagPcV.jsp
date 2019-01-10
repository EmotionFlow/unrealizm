<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

MyHomeTagC cResults = new MyHomeTagC();
cResults.getParam(request);
cResults.SELECT_MAX_EMOJI = (bSmartPhone)?60:100;
boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyHomePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

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
				"data": {"SD" : g_nEndId, "MD" : <%=CCnv.MODE_PC%>},
				"dataType": "json",
				"url": "/f/MyHomeTagF.jsp",
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

		function DeleteContent(nUserId, nContentId) {
			if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
			DeleteContentBase(nUserId, nContentId);
			return false;
		}

		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){if(!$(e.target).is(".MyUrl")){return false;}});
			});
			$(window).bind("scroll.addContents", function() {
				$(window).height();
				if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 600) {
					addContents();
				}
			});
		});
		</script>

		<style>
			body {padding-top: 83px !important;}
			<%if(!Util.isSmartPhone(request)) {%>
			.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 113px;}
			.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
			<%}%>
		</style>

		<%if(!bSmartPhone){%>
		<script type="text/javascript" src="/js/jquery.easing.1.3.js"></script>
		<script type="text/javascript" src="/js/jquery.vgrid.min.js"></script>
		<script>
		$(function() {
			vg = $("#IllustThumbList").vgrid({
				easing: "easeOutQuint",
				useLoadImageEvent: true,
				useFontSizeListener: true,
				time: 1,
				delay: 1,
				wait: 1,
				fadeIn: {time: 1, delay: 1}
			});
		});
		</script>
		<%}%>
		<script>
		$(function() {
			$("#IllustThumbList").css('opacity', 1);
		});
		</script>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem Selected" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="Wrapper GridList">
			<div id="IllustThumbList" class="IllustThumbList">
				<div style="width: 100%; box-sizing: border-box; padding: 10px 15px 0 15px; font-size: 16px; text-align: right;">
					<a style="color: #5bd;" href="/MyHomeTagSettingPcV.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyHomeTagSetting.Title")%></a>
				</div>
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 150px 10px 50px 10px; text-align: center; box-sizing: border-box;">
					タグや検索キーワードを「お気に入り」登録するとここに最新情報が表示されるようになります。
				</div>
				<%}%>

				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%if(nCnt==1 && !bSmartPhone) {%>
					<%@ include file="/inner/TAdPc336x280_top_right.jsp"%>
					<%}%>
					<%if(nCnt==8 && bSmartPhone) {%>
					<%@ include file="/inner/TAdPc336x280_bottom_right.jsp"%>
					<%}%>
				<%}%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>