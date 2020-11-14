<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
		function UpdateNgReaction() {
				var bMode = $('#NgReaction').prop('checked');
				$.ajaxSingle({
						"type": "post",
						"data": { "UID": <%=cCheckLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.REACTION_HIDE%>:<%=CUser.REACTION_SHOW%> },
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
				<div class="SettingListTitle"><%=_TEX.T("EditSettingV.ReactionMode")%></div>
				<div class="SettingBody">
						<%=_TEX.T("EditSettingV.ReactionMode.Message")%>
						<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
								<div class="RegistMessage" >
										<div class="onoffswitch OnOff">
												<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="NgReaction" value="0" <%if(cResults.m_cUser.m_nReaction!=CUser.REACTION_SHOW){%>checked="checked"<%}%> />
												<label class="onoffswitch-label" for="NgReaction">
														<span class="onoffswitch-inner"></span>
														<span class="onoffswitch-switch"></span>
												</label>
										</div>
										<script>
												$('#NgReaction').change(function(){
														//UpdateDispFollowerLink();
												});
										</script>
								</div>
								<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNgReaction()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
				</div>
		</div>
</div>
