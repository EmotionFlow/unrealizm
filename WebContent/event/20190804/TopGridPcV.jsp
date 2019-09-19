<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByTagGridC cResults = new SearchIllustByTagGridC();
cResults.getParam(request);
cResults.m_strKeyword = "星座占い";
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(cCheckLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
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
			.SettingBody.Seiza {display: block; height:12640px; background: top center url('/event/20190804/seiza_20190920.png') no-repeat; background-size: 600px;}
			.SettingBody {font-size: 20px;}
			.SeizaLinkList {display: flex; flex-flow: row wrap; width: 580px; margin: 0 10px; position: absolute; z-index: 1; top: 1158px;}
			.SeizaLinkList .SeizaLink {display: block; width: 25%; height: 145px;}
			.temp_dl_btn {display: block; position: absolute; width: 570px; height: 77px; left: 15px; z-index: 1;}
			.SeizaCmdUp {display: block; position: absolute; width: 500px; height: 90px; top: 12499px; left: 50px; z-index: 1;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody Seiza">
					<div class="SeizaLinkList">
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:1740});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:2640});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:3540});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:4440});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:5340});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:6235});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:7135});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:8035});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:8930});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:9830});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:10725});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:11625});"></a>
					</div>
					<a class="temp_dl_btn" style="top: 2500px" href="/event/20190804/seiza_20190920/seiza_tenp_ohitsuji.png"></a>
					<a class="temp_dl_btn" style="top: 3400px" href="/event/20190804/seiza_20190920/seiza_tenp_oushi.png"></a>
					<a class="temp_dl_btn" style="top: 4300px" href="/event/20190804/seiza_20190920/seiza_tenp_futago.png"></a>
					<a class="temp_dl_btn" style="top: 5200px" href="/event/20190804/seiza_20190920/seiza_tenp_kani.png"></a>
					<a class="temp_dl_btn" style="top: 6100px" href="/event/20190804/seiza_20190920/seiza_tenp_shishi.png"></a>
					<a class="temp_dl_btn" style="top: 6995px" href="/event/20190804/seiza_20190920/seiza_tenp_otome.png"></a>
					<a class="temp_dl_btn" style="top: 7895px" href="/event/20190804/seiza_20190920/seiza_tenp_tenbin.png"></a>
					<a class="temp_dl_btn" style="top: 8795px" href="/event/20190804/seiza_20190920/seiza_tenp_sasori.png"></a>
					<a class="temp_dl_btn" style="top: 9690px" href="/event/20190804/seiza_20190920/seiza_tenp_ite.png"></a>
					<a class="temp_dl_btn" style="top: 10590px" href="/event/20190804/seiza_20190920/seiza_tenp_yagi.png"></a>
					<a class="temp_dl_btn" style="top: 11485px" href="/event/20190804/seiza_20190920/seiza_tenp_mizugame.png"></a>
					<a class="temp_dl_btn" style="top: 12385px" href="/event/20190804/seiza_20190920/seiza_tenp_uo.png"></a>

					<a class="SeizaCmdUp" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:0});"></a>
				</div>
			</div>
		</article>

		<article class="Wrapper GridList">
			<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px; float: none;">
				<h2 class="Keyword">#<%=Common.ToStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!cCheckLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%if(nCnt==1 && !bSmartPhone) {%>
					<%@ include file="/inner/TAdPc336x280_top_right.jsp"%>
					<%}%>
					<%if(nCnt==8 && bSmartPhone) {%>
					<%@ include file="/inner/TAdPc336x280_bottom_right.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>