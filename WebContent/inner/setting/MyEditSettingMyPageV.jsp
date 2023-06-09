<%@page import="jp.pipa.poipiku.CUser"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
	function UpdateProfileHeaderFile(objTarg){
		updateFile("/f/UpdateProfileHeaderFileF.jsp", objTarg, 2.0);
	}

	function UpdateProfileBgFile(objTarg){
		updateFile("/f/UpdateProfileBgFileF.jsp", objTarg, 2.0);
	}

	function UpdateNgAdMode() {
		var bMode = $('#NgAdMode').prop('checked');
		$.ajaxSingle({
			"type": "post",
			"data": { "UID": <%=checkLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.AD_MODE_SHOW%>:<%=CUser.AD_MODE_HIDE%> },
			"url": "/f/UpdateNgAdModeF.jsp",
			"dataType": "json",
			"success": function(data) {
				DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
			},
			"error": function(req, stat, ex){
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
		return false;
	}

	function UpdateNgDownload() {
		var bMode = $('#NgDownload').prop('checked');
		$.ajaxSingle({
			"type": "post",
			"data": { "UID": <%=checkLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.DOWNLOAD_ON%>:<%=CUser.DOWNLOAD_OFF%> },
			"url": "/f/UpdateNgDownloadF.jsp",
			"dataType": "json",
			"success": function(data) {
				DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
			},
			"error": function(req, stat, ex){
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
		return false;
	}

	function UpdateNgReaction() {
		var bMode = $('#NgReaction').prop('checked');
		$.ajaxSingle({
			"type": "post",
			"data": { "UID": <%=checkLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.REACTION_HIDE%>:<%=CUser.REACTION_SHOW%> },
			"url": "/f/UpdateNgReactionF.jsp",
			"dataType": "json",
			"success": function(data) {
				DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
			},
			"error": function(req, stat, ex){
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
		return false;
	}
</script>

<div class="SettingList">

	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.HeaderImage")%></div>
		<div class="SettingBody">
			<div class="PreviewImgFrame">
				<%if(results.m_cUser.m_strHeaderFileName.equals("/img/default_transparency.gif")) {%>
				<span class="PreviewMessage"><%=_TEX.T("EditSettingV.Image.NoImage")%></span>
				<%} else {%>
				<img class="PreviewImg" src="<%=Common.GetUrl(results.m_cUser.m_strHeaderFileName)%>" />
				<%}%>
			</div>
			<div id="RegistMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.HeaderImage.Format")%></div>
			<div class="SettingBodyCmd">
				<span class="BtnBase SettingBodyCmdRegist">
					<%=_TEX.T("EditSettingV.Image.Select")%>
					<input class="CmdRegistSelectFile" type="file" name="file_header" id="file_header" onchange="UpdateProfileHeaderFile(this)" />
				</span>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(2)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
			</div>
		</div>
	</div>

<%--	<div class="SettingListItem">--%>
<%--		<div class="SettingListTitle">--%>
<%--			<%@include file="PoipassLogoLink.jsp"%>--%>
<%--			<%=_TEX.T("EditSettingV.BgImage")%>--%>
<%--		</div>--%>
<%--		<div class="SettingBody" <%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF) {%>style="opacity: 0.3"<%}%>>--%>
<%--			<div class="PreviewImgFrame">--%>
<%--				<%if(results.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {%>--%>
<%--				<span class="PreviewMessage"><%=_TEX.T("EditSettingV.Image.NoImage")%></span>--%>
<%--				<%} else {%>--%>
<%--				<img class="PreviewImg" src="<%=Common.GetUrl(results.m_cUser.m_strBgFileName)%>" />--%>
<%--				<%}%>--%>
<%--			</div>--%>
<%--			<div class="RegistMessage" ><%=_TEX.T("EditSettingV.HeaderImage.Format")%></div>--%>
<%--			<%if(checkLogin.m_nPassportId >= Common.PASSPORT_ON) {%>--%>
<%--			<div class="SettingBodyCmd">--%>
<%--				<span class="BtnBase SettingBodyCmdRegist">--%>
<%--					<%=_TEX.T("EditSettingV.Image.Select")%>--%>
<%--					<input class="CmdRegistSelectFile" type="file" name="file_bg" id="file_bg" onchange="UpdateProfileBgFile(this)" />--%>
<%--				</span>--%>
<%--				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(3)"><%=_TEX.T("EditSettingV.Image.Default")%></a>--%>
<%--			</div>--%>
<%--			<%}%>--%>
<%--		</div>--%>
<%--	</div>--%>

<%--	<div class="SettingListItem">--%>
<%--		<div class="SettingListTitle">--%>
<%--			<%@include file="PoipassLogoLink.jsp"%>--%>
<%--			<%=_TEX.T("EditSettingV.MyPage.AdMode")%>--%>
<%--		</div>--%>
<%--		<div class="SettingBody"  <%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF) {%>style="opacity: 0.3"<%}%>>--%>
<%--			<%=_TEX.T("EditSettingV.MyPage.AdMode.Message")%>--%>
<%--			<%if(checkLogin.m_nPassportId >= Common.PASSPORT_ON) {%>--%>
<%--			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">--%>
<%--				<div class="RegistMessage" >--%>
<%--					<div class="onoffswitch OnOff">--%>
<%--						<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="NgAdMode" value="0" <%if(results.m_cUser.m_nAdMode!=CUser.AD_MODE_HIDE){%>checked="checked"<%}%> />--%>
<%--						<label class="onoffswitch-label" for="NgAdMode">--%>
<%--							<span class="onoffswitch-inner"></span>--%>
<%--							<span class="onoffswitch-switch"></span>--%>
<%--						</label>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNgAdMode()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--			</div>--%>
<%--			<%}%>--%>
<%--		</div>--%>
<%--	</div>--%>

<%--	<div class="SettingListItem">--%>
<%--		<div class="SettingListTitle">--%>
<%--			<%@include file="PoipassLogoLink.jsp"%>--%>
<%--			<%=_TEX.T("EditSettingV.MyPage.Download")%>--%>
<%--		</div>--%>
<%--		<div class="SettingBody"  <%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF) {%>style="opacity: 0.3"<%}%>>--%>
<%--			<%=_TEX.T("EditSettingV.MyPage.Download.Message")%>--%>
<%--			<%if(checkLogin.m_nPassportId >= Common.PASSPORT_ON) {%>--%>
<%--			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">--%>
<%--				<div class="RegistMessage" >--%>
<%--					<div class="onoffswitch OnOff">--%>
<%--						<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="NgDownload" value="0" <%if(results.m_cUser.m_nDownload!=CUser.DOWNLOAD_OFF){%>checked="checked"<%}%> />--%>
<%--						<label class="onoffswitch-label" for="NgDownload">--%>
<%--							<span class="onoffswitch-inner"></span>--%>
<%--							<span class="onoffswitch-switch"></span>--%>
<%--						</label>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNgDownload()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--			</div>--%>
<%--			<%}%>--%>
<%--		</div>--%>
<%--	</div>--%>

<%--	<div class="SettingListItem">--%>
<%--		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.ReactionMode")%></div>--%>
<%--		<div class="SettingBody">--%>
<%--			<%=_TEX.T("EditSettingV.ReactionMode.Message")%>--%>
<%--			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">--%>
<%--				<div class="RegistMessage" >--%>
<%--					<div class="onoffswitch OnOff">--%>
<%--						<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="NgReaction" value="0" <%if(results.m_cUser.m_nReaction!=CUser.REACTION_SHOW){%>checked="checked"<%}%> />--%>
<%--						<label class="onoffswitch-label" for="NgReaction">--%>
<%--							<span class="onoffswitch-inner"></span>--%>
<%--							<span class="onoffswitch-switch"></span>--%>
<%--						</label>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNgReaction()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--			</div>--%>
<%--		</div>--%>
<%--	</div>--%>
</div>
