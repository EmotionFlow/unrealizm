<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByTagGridC cResults = new SearchIllustByTagGridC();
cResults.getParam(request);
cResults.m_strKeyword = "星座占い";
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(checkLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - ポイピク星座占い</title>
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
					"data": {"PG" : g_nPage, "KWD" : decodeURIComponent("<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"), "MD" : <%=CCnv.MODE_PC%>},
					"dataType": "json",
					"url": "/f/SearchIllustByTagGridF.jsp",
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
			.AnalogicoInfo {display: none;}
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
		<style>
			<% int SEIZA_TOP = 867;%>
			.SettingBody.Seiza {display: block; height:12290px; background: top center url('/event/20190804/seiza_20191004.png') no-repeat; background-size: 600px; position: relative;}
			.SettingBody {font-size: 20px;}
			.SeizaLinkList {display: flex; flex-flow: row wrap; width: 580px; margin: 0 10px; position: absolute; z-index: 1; top: <%=SEIZA_TOP%>px;}
			.SeizaLinkList .SeizaLink {display: block; width: 25%; height: 145px;}
			.temp_dl_btn {display: block; position: absolute; width: 570px; height: 77px; left: 15px; z-index: 1;}
			.SeizaCmdUp {display: block; position: absolute; width: 500px; height: 90px; top: 12126px; left: 50px; z-index: 1;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody Seiza">
					<div class="SeizaLinkList">
						<%
						int POS=SEIZA_TOP+525;
						int DIFF=874;
						int MARG=-100;
						%>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*0%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*1%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*2%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*3%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*4%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*5%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*6%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*7%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*8%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*9%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*10%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*11%>});"></a>
					</div>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*1+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_ohitsuji.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*2+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_oushi.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*3+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_futago.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*4+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_kani.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*5+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_shishi.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*6+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_otome.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*7+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_tenbin.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*8+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_sasori.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*9+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_ite.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*10+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_yagi.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*11+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_mizugame.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*12+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_uo.png"></a>

					<a class="SeizaCmdUp" style="top: <%=POS+DIFF*12+10%>px" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:0});"></a>
				</div>
			</div>
		</article>

		<article class="Wrapper GridList">
			<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px; float: none;">
				<h2 class="Keyword">#<%=Util.toStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!checkLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%if(nCnt==1) {%>
					<%@ include file="/inner/TAdPc336x280_right_top.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>