<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	function UpdateBlock() {
		var bBlocked = $("#UserInfoCmdBlock").hasClass('Selected');
		$.ajaxSingle({
			"type": "post",
			"data": { "UID": <%=checkLogin.m_nUserId%>, "IID": <%=results.m_cUser.m_nUserId%>, "CHK": (bBlocked)?0:1 },
			"url": "/f/UpdateBlockF.jsp",
			"dataType": "json",
			"success": function(data) {
				if(data.result==1) {
					$('.UserInfoCmdBlock').addClass('Selected');
					$('.UserInfoCmdFollow').removeClass('Selected');
					$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
					$('.UserInfoCmdFollow').hide();
					location.reload(true);
				} else if(data.result==2) {
					$('.UserInfoCmdBlock').removeClass('Selected');
					$('.UserInfoCmdFollow').removeClass('Selected');
					$('.UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
					$('.UserInfoCmdFollow').show();
					location.reload(true);
				} else {
					DispMsg('ブロックできませんでした');
				}
			},
			"error": function(req, stat, ex){
				DispMsg('Connection error');
			}
		});
	}
</script>
<%if(!checkLogin.m_bLogin) {%>
<a id="UserInfoCmdBlock" class="typcn typcn-cancel UserInfoCmdBlock" href="/"></a>
<%} else if(results.m_bOwner){
	// 何も表示しない
} else if(results.m_bBlocking){ // ブロックしている %>
<span id="UserInfoCmdBlock"
	  class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected"
	  style="text-shadow: none;"
	  onclick="UpdateBlock()">
					<span id="UserInfoCmdBlockLabel"><%=_TEX.T("IllustV.Unblocking")%></span>
				</span>
<%} else if(results.m_bBlocked){ // ブロックされている%>
<span id="UserInfoCmdBlock" class="typcn typcn-cancel UserInfoCmdBlock" onclick="UpdateBlock()"></span>
<span class="UserInfoCmdBlocked"><span><%=_TEX.T("IllustV.Blocked")%></span></span>
<%} else if(results.m_bFollow){%>
<span id="UserInfoCmdBlock" class="typcn typcn-cancel UserInfoCmdBlock " onclick="UpdateBlock()"></span>
<%} else {%>
<span id="UserInfoCmdBlock" class="typcn typcn-cancel UserInfoCmdBlock" onclick="UpdateBlock()"></span>
<%}%>