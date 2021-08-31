<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
	function UnlinkTwitter() {
		<%if(cResults.m_cUser.m_strEmail!=null && cResults.m_cUser.m_strEmail.contains("@")){%>
		$.ajaxSingle({
				"type": "post",
				"data": { "ID":<%=checkLogin.m_nUserId%>},
				"url": "/f/UnlinkTwitterF.jsp",
				"dataType": "json",
				"success": function(data) {
						location.reload();
				},
				"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
				}
		});
		<%}else{%>
		Swal.fire({
				type: "info",
				text: "<%=_TEX.T("EditSettingV.Twitter.Deregist.NeedEmail")%>",
		});
		<%}%>
		return false;
	}

	function UpdateTwitterCash() {
		$.ajaxSingle({
			"type": "post",
			"data": { "ID":<%=checkLogin.m_nUserId%>},
			"url": "/f/UpdateTwitterCashF.jsp",
			"dataType": "json",
			"success": function(data) {
				setCookieOneDay('UPTW', 'UpdateTwitterCash')
				location.reload();
			},
			"error": function(req, stat, ex){
					DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
			}
	});
	}

	function UpdateAutoTweet() {
		var bAutoTweet = $('#AutoTweet').prop('checked');
		var nAutoTweetWeekDay = parseInt($('#AutoTweetWeekDay').val(), 10);
		var nAutoTweetTime = parseInt($('#AutoTweetTime').val(), 10);
		var strAutoTweetTxt = $.trim($("#AutoTweetTxt").val());
		var nAutoTweetThumbNum = ($('#AutoTweetThumb').prop('checked'))?9:0;
		if(!bAutoTweet) {
				nAutoTweetWeekDay = -1;
				nAutoTweetTime = -1;
		}
		$.ajaxSingle({
				"type": "post",
				"data": {
						"ID": <%=checkLogin.m_nUserId%>,
						"AW": nAutoTweetWeekDay,
						"AT": nAutoTweetTime,
						"AD": strAutoTweetTxt,
						"ATN": nAutoTweetThumbNum},
				"url": "/f/UpdateAutoTweetF.jsp",
				"dataType": "json",
				"success": function(data) {
						DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
						sendObjectMessage("reloadParent");
				},
				"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
				}
		});
		return false;
	}

	function DispAutoTweetCharNum() {
		const nCharNum = 100 - $("#AutoTweetTxt").val.length;
		$("#AutoTweetTxtNum").html(nCharNum);
	}

	$(function () {
			<%if(cResults.m_strErr.equals("TW_LINKED")){%>
			Swal.fire({
					type: "info",
					title: "<%=_TEX.T("EditSettingV.Twitter.Regist.Error.Title")%>",
					text: "<%=_TEX.T("EditSettingV.Twitter.Regist.Error.FoundLinkedUser")%>",
			});
			<%}%>
			<%if(cResults.m_cUser.m_bTweet){%>
			DispAutoTweetCharNum();
			<%}%>
	})
</script>
<style>
	p:first-child {margin-top: 0}
	p {margin-bottom: 0}
	.RegistStatus{
		font-size: 14px;
		background-color: #efefef;
		padding: 4px 0px;
		text-align: center;
	}
</style>

<div class="SettingList">
	<div class="RegistStatus"><%=(cResults.m_cUser.m_bTweet)?String.format(_TEX.T("EditSettingV.Twitter.Info.State.On"), checkLogin.m_strNickName, cResults.m_cUser.m_strTwitterScreenName):_TEX.T("EditSettingV.Twitter.Info.State.Off")%></div>

	<%if(cResults.m_cUser.m_bTweet){%>
	<div class="SettingListItem" style="background-color: #f5f5f5;border: none; padding: 10px;">
		<div class="SettingBody" style="background-color: #f5f5f5; font-size: 13px">
			<p><%=_TEX.T("EditSettingV.Twitter.Link.Note1")%></p>
			<p><%=_TEX.T("EditSettingV.Twitter.Link.Note2")%></p>
			<p><%=_TEX.T("EditSettingV.Twitter.Link.Note3")%></p>
		</div>
	</div>
	<%}%>

	<div class="SettingListItem" style="border: none;">
		<a id="TwitterSetting"></a>
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.Regist")%></div>
		<div class="SettingBody">
			<%if(!cResults.m_cUser.m_bTweet){%>
			<%=_TEX.T("EditSettingV.Twitter.Info1")%>
			<%}%>
			<%=_TEX.T("EditSettingV.Twitter.Info2")%>
			<%if(cResults.m_cUser.m_bTweet){%>
			<%=_TEX.T("EditSettingV.Twitter.Info3")%>
			<%}%>
			<div class="SettingBodyCmd">
				<div class="RegistMessage" ></div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="location.href='/TokenFormTwitterPc.jsp'"><%=_TEX.T("EditSettingV.Twitter.Button")%></a>
			</div>
		</div>
	</div>

	<%if(cResults.m_cUser.m_bTweet){%>
	<div class="SettingListItem" style="border: none;">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.Deregist")%></div>
		<div class="SettingBody">
			<p><%=_TEX.T("EditSettingV.Twitter.Deregist.Info1")%></p>
			<p><%=_TEX.T("EditSettingV.Twitter.Deregist.Info2")%></p>
			<div class="SettingBodyCmd">
				<div class="RegistMessage" ></div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UnlinkTwitter()"><%=_TEX.T("EditSettingV.Twitter.Button.Deregist")%></a>
			</div>
		</div>
	</div>
	<%}%>

	<%if(cResults.m_cUser.m_bTweet){%>
	<div class="SettingListItem" style="border: none;">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.Cache")%></div>
		<div class="SettingBody">
			<p><%=_TEX.T("EditSettingV.Twitter.Cache.info1")%></p>
			<div class="SettingBodyCmd">
				<div class="RegistMessage" ></div>
				<%if(Util.getCookie(request, "UPTW")==null) {%>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateTwitterCash()"><%=_TEX.T("EditSettingV.Twitter.Button.Update")%></a>
				<%} else {%>
				<a class="BtnBase SettingBodyCmdRegist Disabled" href="javascript:void(0)" ><%=_TEX.T("EditSettingV.Twitter.Button.Update")%></a>
				<%}%>
			</div>
		</div>
	</div>
	<%}%>

	<%if(cResults.m_cUser.m_bTweet && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {%>
	<div id="SectionAutoTweet" class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.Auto")%></div>
		<div class="SettingBody">
			<%=_TEX.T("EditSettingV.Twitter.Auto.Info")%>
			<div class="SettingBodyCmd">
				<div class="onoffswitch OnOff">
					<input type="checkbox" name="AutoTweet" class="onoffswitch-checkbox" id="AutoTweet" value="1" <%if(cResults.m_cUser.m_nAutoTweetTime>=0){%>checked="checked"<%}%> />
					<label class="onoffswitch-label" for="AutoTweet">
						<span class="onoffswitch-inner"></span>
						<span class="onoffswitch-switch"></span>
					</label>
				</div>
				<script>
					$('#AutoTweet').change(function(){
							var bAutoTweet = $('#AutoTweet').prop('checked');
							$('#AutoTweetWeekDay').prop('disabled', !bAutoTweet);
							$('#AutoTweetTime').prop('disabled', !bAutoTweet);
							$('#AutoTweetTxt').prop('disabled', !bAutoTweet);
							$('#AutoTweetThumb').prop('disabled', !bAutoTweet);
							//UpdateAutoTweet();
					});
				</script>
			</div>
			<div class="SettingBodyCmd">
				<select id="AutoTweetWeekDay" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
					<%for(int nTime=0; nTime<7; nTime++) {%>
					<option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetWeekDay==nTime){%>selected="selected"<%}%>><%=_TEX.T(String.format("EditSettingV.Twitter.Auto.WeekDay.Day%d", nTime))%></option>
					<%}%>
				</select>
			</div>
			<div class="SettingBodyCmd">
				<select id="AutoTweetTime" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
					<%for(int nTime=0; nTime<24; nTime++) {%>
					<option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetTime==nTime){%>selected="selected"<%}%>><%=nTime%><%=_TEX.T("EditSettingV.Twitter.Auto.Unit")%></option>
					<%}%>
				</select>
			</div>
			<div class="SettingBodyCmd">
				<%if(cResults.m_cUser.m_strAutoTweetDesc.isEmpty()) {
					cResults.m_cUser.m_strAutoTweetDesc = String.format("%s%s%s https://poipiku.com/%d/ #%s",
							_TEX.T("EditSettingV.Twitter.Auto.AutoTxt"),
							cResults.m_cUser.m_strNickName,
							_TEX.T("Twitter.UserAddition"),
							cResults.m_cUser.m_nUserId,
							_TEX.T("Common.Title"));
				}%>
				<textarea id="AutoTweetTxt" class="SettingBodyTxt" rows="6" onkeyup="DispAutoTweetCharNum()" maxlength="100"><%=Util.toStringHtmlTextarea(cResults.m_cUser.m_strAutoTweetDesc)%></textarea>
			</div>
			<div class="SettingBodyCmd">
					<div id="AutoTweetTxtNum" class="RegistMessage" >100</div>
			</div>
			<div class="SettingBodyCmd">
				<%=_TEX.T("EditSettingV.Twitter.Auto.ThumbNum")%>&nbsp;
				<div class="onoffswitch OnOff">
						<input type="checkbox" name="AutoTweetThumb" class="onoffswitch-checkbox" id="AutoTweetThumb" value="1" <%if(cResults.m_cUser.m_nAutoTweetThumbNum>0){%>checked="checked"<%}%> />
						<label class="onoffswitch-label" for="AutoTweetThumb">
							<span class="onoffswitch-inner"></span>
							<span class="onoffswitch-switch"></span>
						</label>
				</div>
			</div>
			<div class="SettingBodyCmd">
				<div class="RegistMessage" ></div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateAutoTweet()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
			</div>
		</div>
	</div>
	<%}%>
</div>
