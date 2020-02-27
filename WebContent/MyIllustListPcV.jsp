<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

IllustListGridC cResults = new IllustListGridC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}

cResults.m_bDispUnPublished = true;

if(!cResults.getResults(cCheckLogin) || !cResults.m_bOwner) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

String strUrl = "https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/";
String strTitle = Common.ToStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName)) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal);
String strFileUrl = cResults.m_cUser.m_strFileName;
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<title><%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
			updateCategoryMenuPos(0);
		});

		$(function(){
			$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');
			<%if(!bSmartPhone) {%>
			$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Poipiku.Info.RegistNow")%>');
			<%}%>
			/*
			$(window).bind("scroll.slideHeader", function() {
				$('.UserInfo.Float').css('background-position-y', $(this).scrollTop()/5 + 'px');
			});
			*/
		});
		</script>

		<%@ include file="/inner/TDeleteContent.jsp"%>

		<script>
		var g_nPage = 1;
		var g_strKeyword = '<%=cResults.m_strKeyword%>';
		var g_bAdding = false;
		function addContents() {
			if(g_bAdding) return;
			g_bAdding = true;
			var $objMessage = $("<div/>").addClass("Waiting");
			$("#IllustThumbList").append($objMessage);
			$.ajax({
				"type": "post",
				"data": {"ID": <%=cResults.m_nUserId%>, "KWD": g_strKeyword, "PG" : g_nPage, "MD" : <%=CCnv.MODE_PC%>},
				"url": "/f/MyIllustListPcF.jsp",
				"success": function(data) {
					if($.trim(data).length>0) {
						g_nPage++;
						$("#IllustThumbList").append(data);
						$(".Waiting").remove();
						if(vg)vg.vgrefresh();
						g_bAdding = false;
						if(g_nPage>0) {
							console.log(location.pathname+'/'+g_nPage+'.html');
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						}
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
				if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 600) {
					addContents();
				}
			});
		});
		</script>

		<style>
			.IllustThumb .IllustInfo {bottom: 0; background: #fff;}
			.CategoryMenu {float: none;}
			#IllustThumbList {opacity: 0; float: none;}
			.IllustItem .IllustItemUser {display: none;}
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
			.IllustItem .IllustItemThumb { position: relative; }
			.NoContents {display: block; padding: 250px 0; width: 100%; text-align: center;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper GridList">
			<%if(cResults.m_vCategoryList.size()>0) {%>
			<nav id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(cResults.m_strKeyword.isEmpty()){%> Selected<%}%>" href="/MyIllustListPcV.jsp?ID=<%=cResults.m_nUserId%>"><%=_TEX.T("Category.All")%></a>
				<%for(CTag cTag : cResults.m_vCategoryList) {%>
				<a class="BtnBase CategoryBtn <%if(cTag.m_strTagTxt.equals(cResults.m_strKeyword)){%> Selected<%}%>" href="/MyIllustListPcV.jsp?ID=<%=cResults.m_nUserId%>&KWD=<%=URLEncoder.encode(cTag.m_strTagTxt, "UTF-8")%>"><%=Util.toDescString(cTag.m_strTagTxt)%></a>
				<%}%>
			</nav>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%if(cResults.m_vContentList.size()>0){%>
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%=CCnv.toMyThumbHtmlPc(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%}%>
				<%}else{%>
					<span class="NoContents"><%=_TEX.T("IllustListV.NoContents.Me")%></span>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
		<%//@ include file="/inner/TFooter.jsp"%>
	</body>
</html>