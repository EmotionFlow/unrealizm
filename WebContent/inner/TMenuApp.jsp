<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.cache.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.settlement.*"%>
<%@page import="jp.pipa.poipiku.settlement.epsilon.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="Header">
	<div id="HeaderSlider"></div>
	<div class="HeaderWrapper">
	</div>
</header>

<%if(checkLogin.m_bLogin) {%>
<script>
	function UpdateNotify() {
		$.getJSON("/f/CheckNotifyF.jsp", {}, function(data){
			const ntfy_num = Math.min(data.check_comment + data.check_follow + data.check_heart + data.check_request, 99);
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
		g_timerUpdateNotify = setInterval(UpdateNotify, 1000*60*2);
	});
</script>
<%}%>
