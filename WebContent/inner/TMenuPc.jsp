<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
{
	String URL_HOME		= (cCheckLogin.m_bLogin)?"/MyHomePcV.jsp":"/";
	String URL_SEARCH	= (cCheckLogin.m_bLogin)?"/NewArrivalPcV.jsp":"/NewArrivalPcV.jsp";
	String URL_UPLOAD	= (cCheckLogin.m_bLogin)?"/UploadFilePcV.jsp":"/";
	String URL_ACT		= (cCheckLogin.m_bLogin)?"/ActivityListPcV.jsp":"/";
	String URL_ME		= (cCheckLogin.m_bLogin)?"/"+cCheckLogin.m_nUserId+"/":"/";
%>
<header class="Header">
	<div id="HeaderTitleWrapper" class="HeaderTitleWrapper">
		<a id="HeaderLink" class="HeaderLink" href="<%=URL_HOME%>">
			<img  class="HeaderImg" src="/img/pc_top_title.jpg" alt="<%=_TEX.T("THeader.Title")%>" />
		</a>
		<a class="HeaderTitleSearch fa fa-search" href="javascript:void(0);" onclick="$('#HeaderTitleWrapper').hide();$('#HeaderSearchWrapper').show();"></a>
	</div>
	<form id="HeaderSearchWrapper" class="HeaderSearchWrapper" method="get" action="/SearchIllustByKeywordPcV.jsp" >
		<div class="HeaderSearch">
			<input name="KWD" id="HeaderSearchBox" class="HeaderSearchBox" type="text" placeholder="" />
			<div class="HeaderSearchBtn" onclick="SearchIllustByKeyword()">
				<span class="fa fa-search"></span>
			</div>
		</div>
	</form>
</header>

<div class="FooterMenuWrapper">
	<nav class="FooterMenu">
		<a id="MenuHome" class="FooterMenuItem" href="<%=URL_HOME%>">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Home")%></span>
		</a>
		<a id="MenuUpload" class="FooterMenuItem" href="<%=URL_UPLOAD%>">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Upload")%></span>
		</a>
		<a id="MenuAct" class="FooterMenuItem" href="<%=URL_ACT%>">
			<span class="FooterMenuItemIcon">
				<div id="InfoNumAct" class="InfoNum">0</div>
			</span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Act")%></span>
		</a>
		<a id="MenuMe" class="FooterMenuItem" href="<%=URL_ME%>">
			<span class="FooterMenuItemIcon"></span>
			<span class="FooterMenuItemName"><%=_TEX.T("THeader.Menu.Me")%></span>
		</a>
	</nav>
</div>
<%
}
%>
<%if(cCheckLogin.m_bLogin) {%>
<script>
	function UpdateNotify() {
		$.getJSON("/f/CheckNotifyF.jsp", {}, function(data){
			var ntfy_num = data.check_comment + data.check_follow + data.check_heart;
			var strNotifyNum = (ntfy_num>9)?"9+":ntfy_num;
			$('#InfoNumAct').html(strNotifyNum);
			if(strNotifyNum>0) {
				$('#InfoNumAct').show();
			} else if(strNotifyNum<1) {
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

<%if(!cCheckLogin.m_bLogin) {%>
<div id="AnalogicoInfo" class="AnalogicoInfo">
	<div class="Wrapper">
		<h1 class="AnalogicoInfoTitle">
			描くのに飽きたらポイポイ<br />
			ポイポイしたら誰かがきっと励ましてくれる<br />
			「イラストSNS ポイピク」
		</h1>
		<div class="AnalogicoInfoRegist">
			<a class="BtnBase" href="/LoginFormTwitterPc.jsp">
				<span class="typcn typcn-social-twitter"></span> Twitterで新規登録/ログイン
			</a>
		</div>
	</div>
</div>
<%}%>
