<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

PopularIllustListGridC cResults = new PopularIllustListGridC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("PopularIllustList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
			$('#MenuHotIllust').addClass('Selected');
		});
		</script>
		<script>
			var g_nPage = 1;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage, "MD" : <%=CCnv.MODE_PC%>},
					"dataType": "json",
					"url": "/f/PopularIllustListGridF.jsp",
					"success": function(data) {
						if(data.end_id>0) {
							g_nPage++;
							$("#IllustThumbList").append(data.html);
							$(".Waiting").remove();
							if(vg)vg.vgrefresh();
							g_bAdding = false;
							console.log(location.pathname+'/'+g_nPage+'.html');
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
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

			function UpdateFollow(nUserId, nFollowUserId) {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": nUserId, "IID": nFollowUserId },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow_'+nFollowUserId).addClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Following")%>");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow_'+nFollowUserId).removeClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Follow")%>");
						} else {
							DispMsg('フォローできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
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
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
		</style>

		<script type="text/javascript" src="/js/jquery.easing.1.3.js"></script>
		<script type="text/javascript" src="/js/jquery.vgrid.min.js"></script>
		<script>
		//setup
		$(function() {
			vg = $("#IllustThumbList").vgrid({
				easing: "easeOutQuint",
				useLoadImageEvent: true,
				useFontSizeListener: true,
				time: 1,
				delay: 1,
				wait: 1,
				fadeIn: {
					time: 1,
					delay: 1
				},
				onStart: function(){
					$("#message1")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				},
				onFinish: function(){
					$("#message2")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				}
			});

			//$(window).load(function(e){
				$("#IllustThumbList").css('opacity', 1);
				//vg.vgrefresh();
			//});
		});
		</script>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
				<a class="TabMenuItem Selected" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper GridList">

			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%if(nCnt==1 && !bSmartPhone) {%>
					<%@ include file="/inner/TAdPc300x250_top_right.jspf"%>
					<%}%>
					<%if(nCnt==8 && bSmartPhone) {%>
					<%@ include file="/inner/TAdPc300x250_bottom_right.jspf"%>
					<%}%>
				<%}%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>