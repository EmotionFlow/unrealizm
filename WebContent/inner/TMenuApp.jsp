<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="Header">
	<div id="HeaderSlider"></div>
	<div class="HeaderWrapper">
	</div>
</header>

<%if(checkLogin.m_bLogin) {%>
<script>
	function UpdateNotify() {
		$.getJSON("/f/CheckNotifyF.jsp", {}, (data) => {
			const notifyNum = Math.min(
				data.check_comment +
				data.check_comment_reply +
				data.check_follow +
				data.check_heart +
				data.check_request +
				data.check_gift +
				data.check_wave_emoji +
				data.check_wave_emoji_message +
				data.check_wave_emoji_message_reply,
				99);
			<%//var strNotifyNum = (ntfy_num>99)?"9+":""+ntfy_num;%>
			$('#InfoNumAct').html(notifyNum);
			if(notifyNum>0) {
				$('#InfoNumAct').show();
			} else {
				$('#InfoNumAct').hide();
			}
		});
	}
	var g_timerUpdateNotify = null;
	$(function(){
		UpdateNotify();
		g_timerUpdateNotify = setInterval(UpdateNotify, 1000*60*5);
	});
</script>
<%}%>
