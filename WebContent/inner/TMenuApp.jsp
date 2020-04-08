<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="Header">
	<div id="HeaderSlider"></div>
	<div class="HeaderWrapper">
		<div id="HeaderTitleWrapper" class="HeaderTitleWrapper">
			<h1 class="HeaderTitle">
				<a id="HeaderLink" class="HeaderLink" href="/">
					<img  class="HeaderImg" src="//img-cdn.poipiku.com/img/pc_top_title-02.png" alt="<%=_TEX.T("THeader.Title")%>" />
				</a>
			</h1>
			<%if(Util.isSmartPhone(request) && !cCheckLogin.m_bLogin) {%>
				<form method="post" name="login_from_twitter_tmenupc_00" action="/LoginFormTwitter.jsp">
					<input id="login_from_twitter_tmenupc_callback_00" type="hidden" name="CBPATH" value=""/>
					<script>{
						let s = document.URL.split("/");
						for(let i=0; i<3; i++){s.shift();}
						$('#login_from_twitter_tmenupc_callback_00').val("/" + s.join("/"));
					}</script>
					<a class="BtnBase Rev HeaderLoginBtn" href="javascript:login_from_twitter_tmenupc_00.submit()">
						<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login.Short")%>
					</a>
				</form>
			<%}else{%>
			<a class="HeaderTitleSearch fas fa-search" href="javascript:void(0);" onclick="$('#HeaderTitleWrapper').hide();$('#HeaderSearchWrapper').show();"></a>
			<%}%>
		</div>
		<form id="HeaderSearchWrapper" class="HeaderSearchWrapper" method="get">
			<div class="HeaderSearch">
				<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text" placeholder="<%=_TEX.T("THeader.Search.PlaceHolder")%>" value="<%=Common.ToStringHtml(g_strSearchWord)%>" />
				<div id="HeaderSearchBtn" class="HeaderSearchBtn">
					<i class="fas fa-search"></i>
				</div>
			</div>
		</form>

		<script>
			$('#HeaderSearchWrapper').attr("action","/SearchIllustByKeywordPcV.jsp");
			$('#HeaderSearchBtn').on('click', SearchIllustByKeyword);
		</script>
	</div>
</header>

<%if(cCheckLogin.m_bLogin) {%>
<script>
	function UpdateNotify() {
		$.getJSON("/f/CheckNotifyF.jsp", {}, function(data){
			var ntfy_num = Math.min(data.check_comment + data.check_follow + data.check_heart, 99);
			//var strNotifyNum = (ntfy_num>99)?"9+":""+ntfy_num;
			$('#InfoNumAct').html(ntfy_num);
			if(ntfy_num>0) {
				$('#InfoNumAct').show();
			} else {
				$('#InfoNumAct').hide();
			}
		});
	}
	var g_timerUpdateNotify = null;
	$(function(){
		UpdateNotify();
		g_timerUpdateNotify = setInterval(UpdateNotify, 1000*60);
	});
</script>
<%}%>
