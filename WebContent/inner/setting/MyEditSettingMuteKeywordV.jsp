<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%if (checkLogin.m_nPassportId >= Common.PASSPORT_ON) {%>
<script type="text/javascript">
	function DispMuteCharNum() {
		var nCharNum = 100 - $("#MuteKeywordText").val().length;
		$("#MuteKeywordTextNum").html(nCharNum);
	}

	function UpdateMuteKeyword() {
		var strMuteKeywordTxt = $.trim($("#MuteKeywordText").val());
		$.ajaxSingle({
			"type": "post",
			"data": {"UID": <%=checkLogin.m_nUserId%>, "DES": strMuteKeywordTxt},
			"url": "/f/UpdateMuteKeywordF.jsp",
			"dataType": "json",
			"success": function (data) {
				DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
			},
			"error": function (req, stat, ex) {
				DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
			}
		});
		return false;
	}

	$(function () {
		DispMuteCharNum();
	});
</script>
<%}%>

<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle">
			<img class="SettingListTitlePoipikuPass" src="/img/poipiku_passport_logo2_60.png" />
			<%=_TEX.T("EditSettingV.MuteKeyowrd.Keywords")%>
		</div>
		<div class="SettingBody" <%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF || g_bShowAd) {%>style="opacity: 0.3"<%}%>>
			<%=_TEX.T("EditSettingV.MuteKeyowrd.Message")%>
			<textarea id="MuteKeywordText" class="SettingBodyTxt" rows="6" onkeyup="DispMuteCharNum()" maxlength="100"
					  placeholder="<%=_TEX.T("EditSettingV.MuteKeyowrd.PlaceHolder")%>"><%=Util.toStringHtmlTextarea(cResults.m_cUser.m_strMuteKeyword)%></textarea>
			<%if (checkLogin.m_nPassportId >= Common.PASSPORT_ON) {%>
			<div class="SettingBodyCmd">
				<div id="MuteKeywordTextNum" class="RegistMessage">100</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
				   onclick="UpdateMuteKeyword()"><%=_TEX.T("EditSettingV.Button.Update")%>
				</a>
			</div>
			<%}%>
		</div>
	</div>
</div>
