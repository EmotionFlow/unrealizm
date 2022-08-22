<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.util.CTweet"%>
<%@ page import="twitter4j.UserList"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

IllustViewC cResults = new IllustViewC();
cResults.getParam(request);

if(!cResults.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

// V2 -> V1 convert
if (cResults.m_cContent.m_nOpenId == Common.OPEN_ID_HIDDEN && !cResults.m_cContent.m_bLimitedTimePublish) {
	cResults.m_cContent.m_nPublishId = Common.PUBLISH_ID_HIDDEN;
} else if (cResults.m_cContent.m_nPublishId == Common.PUBLISH_ID_ALL && cResults.m_cContent.isPasswordEnabled()) {
	cResults.m_cContent.m_nPublishId = Common.PUBLISH_ID_PASS;
}

Request poipikuRequest = new Request();
poipikuRequest.selectByContentId(cResults.m_nContentId, null);
// 納品済かつ納品期限を過ぎている
boolean noContentModification = false;
if (poipikuRequest.id > 0 &&
	poipikuRequest.status == Request.Status.Done &&
	poipikuRequest.isDeliveryExpired()
) {
	noContentModification = true;
}


CTweet cTweet = new CTweet();
boolean bTwRet = cTweet.GetResults(checkLogin.m_nUserId);
int nTwLstRet = 0;
if(bTwRet && cTweet.m_bIsTweetEnable && cResults.m_cContent.m_nPublishId == Common.PUBLISH_ID_T_LIST){
	nTwLstRet = cTweet.GetMyOpenLists();
}

response.setHeader("Access-Control-Allow-Origin", "https://img.poipiku.com");
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<link href="/js/flatpickr/flatpickr.min.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="/js/flatpickr/flatpickr.min.js"></script>
		<script src="/js/upload-51.js" type="text/javascript"></script>
		<script src="/js/update-25.js" type="text/javascript"></script>

		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuUpload').addClass('Selected');
		});
		</script>
		<link href="/js/fine-uploader/fine-uploader-gallery-0.3.css" type="text/css" rel="stylesheet" />
		<%if(noContentModification){%>
		<style>
			.qq-upload-cancel-selector {
				display: none;
			}
			#TimeLineAddImage {
				display: none;
			}
		</style>
		<%}%>

		<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			<%@ include file="/js/fine-uploader/templates/gallery-0.2.html"%>
		<%}%>

		<script type="text/javascript" src="/js/fine-uploader/fine-uploader.js"></script>

		<%if(nEditorId==Common.EDITOR_PASTE){%>
		<!-- 画像並び替え用 -->
		<script src="/js/jquery-ui-1.12.1.min.js"></script>
		<script src="/js/jquery.ui.touch-punch.min.js"></script>
		<script type="text/javascript">
		$(function(){
			$(".qq-upload-list-selector.qq-upload-list").sortable({
				placeholder: 'placeholder',
				opacity: 0.6,
				update: function(event, ui) {
						$.each($('.qq-upload-list-selector.qq-upload-list').sortable('toArray'), function(i, item) {
					});
				}
			})
			.disableSelection();
		});
		</script>
		<!-- 画像並び替え用 -->
		<%}%>

		<%@ include file="UpPcV.jsp"%>
		<script>
			let transList = {
				'Description' : {
					'default': '',
					<%
					for(UserLocale userLocale: SupportedLocales.list) {
						String transTxt = cResults.descTransList.get(userLocale.id);
						if (transTxt == null) {
							transTxt = "";
						}
					%>
					'<%=userLocale.id%>': '<%=Util.escapeJavascriptString(transTxt, true)%>',
					<%}%>
				}
			}

			let selected = {
				'Description' : 'default',
			}

			function completeAddFile() {
				$('#UploadBtn').html('<%=_TEX.T("UploadFilePc.AddtImg")%>');
			}


			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			function UpdateFileCheck(user_id, content_id) {
				if(!multiFileUploader) return;
				if(getPreviewAreaImageNum()<=0) {
					DispMsg('<%=_TEX.T("UploadFilePc.Image.NeedImage")%>');
					return;
				}
				UpdateFile(user_id, content_id);
			}
			$(function() {
				initUpdateFile(<%=Common.UPLOAD_FILE_MAX[checkLogin.m_nPassportId]%>, <%=Common.UPLOAD_FILE_TOTAL_SIZE[checkLogin.m_nPassportId]%>, <%=cResults.m_nUserId%>, <%=cResults.m_nContentId%>);
				<%if(noContentModification){%>
				multiFileUploader._options.callbacks.onValidateBatch = (arr, btn) => {return false;};
				<%}%>
			});
			<%}else if(nEditorId==Common.EDITOR_PASTE){%>
			function UpdatePasteCheck(user_id, content_id) {
				UpdatePaste(user_id, content_id);
			}
			$(function() {
				$('#PasteZone').sortable();
				initUpdatePaste(<%=cResults.m_nUserId%>, <%=cResults.m_nContentId%>);
			});
			<%} else if(nEditorId==Common.EDITOR_TEXT){%>
			function UpdateTextCheck(user_id, content_id) {
				UpdateText(user_id, content_id);
			}
			$(function() {
				DispTextCharNum();
			});
			<%}%>
			$(function() {
				DispDescCharNum();
				onClickOptionItem();
			});
		</script>

		<style>
			body {padding-top: 79px !important;}

			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			.qq-gallery.qq-uploader {width: 100%;box-sizing: border-box; margin: 0; border: none; padding: 0; min-height: 113px; background: #fff; max-height: none;}
			.qq-gallery .qq-upload-list {padding: 0; max-height: none;}
			.qq-gallery .qq-total-progress-bar-container {display: none;}
			.qq-gallery .qq-upload-list li {margin: 6px; height: 100px; padding: 0; box-shadow: none; max-width: 100px; background-color: #f3f3f3; border-radius: 4px;}
			.qq-gallery .qq-file-info {display: none;}
			.qq-upload-retry-selector .qq-upload-retry {display: none;}
			.qq-gallery .qq-upload-fail .qq-upload-status-text {display: none;}
			.qq-gallery .qq-upload-retry {display: none;}
			.qq-gallery .qq-thumbnail-wrapper {height: 101px; width: 101px; border-radius: 6px;}
			.qq-gallery .qq-upload-cancel {right: -8px; top: -8px; width: 26px; height: 26px; line-height: 20px; font-size: 12px; padding: 0; border: solid 3px #fafafa; border-radius: 30px;}

			<%if(!Util.isSmartPhone(request)) {%>
			.qq-gallery.qq-uploader {min-height: 193px;}
			.qq-gallery .qq-upload-list li {margin: 8px; height: 177px; max-width: 177px;}
			.qq-gallery .qq-thumbnail-wrapper {height: 177px; width: 177px;}
			<%}%>

			#FineUploaderPane { display:block; }
			<%}else if(nEditorId==Common.EDITOR_PASTE){%>
			<%if(!Util.isSmartPhone(request)) {%>
			.PasteZone {min-height: 193px;}
			.UploadFile .InputFile {margin: 8px; height: 177px; width: 177px;}
			<%}%>
			<%}%>
		</style>

		<%if(nEditorId==Common.EDITOR_UPLOAD){%>
		<!-- 画像並び替え用 -->
		<script src="/js/jquery-ui-1.12.1.min.js"></script>
		<script src="/js/jquery.ui.touch-punch.min.js"></script>

		<script type="text/javascript">
		$(function(){
			$(".qq-upload-list-selector.qq-upload-list").sortable({
				placeholder: 'placeholder',
				opacity: 0.6,
				update: function(event, ui) {
						$.each($('.qq-upload-list-selector.qq-upload-list').sortable('toArray'), function(i, item) {
					});
				}
			})
			.disableSelection();
		});
		</script>
		<!-- 画像並び替え用 -->
		<%}%>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
				<li><a class="TabMenuItem Selected" href="/UpdateFilePcV.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_cContent.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.File")%></a></li>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Text")%></span></li>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Paste")%></span></li>
			<%}else if(nEditorId==Common.EDITOR_TEXT){%>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.File")%></span></li>
				<li><a class="TabMenuItem Selected" href="/UploadTextPcV.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.Text")%></a></li>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Paste")%></span></li>
			<%}else if(nEditorId==Common.EDITOR_PASTE){%>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.File")%></span></li>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Text")%></span></li>
				<li><a class="TabMenuItem Selected" href="/UpdatePastePcV.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a></li>
			<%}%>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper">
			<div class="UploadFile">
				<%if(poipikuRequest.id>0){%>
				<div class="RequestText">
					<%=Util.toStringHtml(poipikuRequest.requestText)%>
				</div>
				<%}%>
				<%if(nEditorId==Common.EDITOR_UPLOAD){%>
				<%if(noContentModification){%>
				<div class="OptionItem">
					<div class="OptionLabel">
						エアスケブお渡し期限後、タイトル・タグ・公開範囲等は変更はできますが、アップロードした画像は変更できません。
					</div>
				</div>
				<%}%>
				<div id="jQueryUploaderPane" class="TimeLineIllustCmd">
				</div>
				<!-- 元々の方式 -->
				<div id="FineUploaderPane" class="TimeLineIllustCmd">
					<span id="file-drop-area"></span>
					<span id="TotalSize" class="TotalSize">(jpeg|png|gif, <%=Common.UPLOAD_FILE_MAX[checkLogin.m_nPassportId]%>files, total <%=Common.UPLOAD_FILE_TOTAL_SIZE[checkLogin.m_nPassportId]%>MByte)</span>
					<a id="TimeLineAddImage" class="SelectImageBtn BtnBase Rev" href="javascript:void(0)">
						<i class="far fa-images"></i>
						<span id="UploadBtn"><%=_TEX.T("UploadFilePc.SelectImg")%></span>
					</a>
				</div>
				<%}else if(nEditorId==Common.EDITOR_PASTE){%>
				<div class="TimeLineIllustCmd">
					<div id="PasteZone" class="PasteZone"></div>
					<span id="TotalSize" class="TotalSize">(multi ver. 0.2beta. 10pastes)</span>
					<div id="TimeLineAddImage" class="SelectImageBtn BtnBase Rev" contenteditable>
						<i class="fas fa-paste"></i>
						<%=(Util.isSmartPhone(request))?_TEX.T("UploadFilePc.PasteImg.SP"):_TEX.T("UploadFilePc.PasteImg")%>
					</div>
				</div>
				<%}%>

				<div class="CategoryDesc">
					<select id="EditCategory">
						<%for(int nCategoryId : Common.CATEGORY_ID) {%>
						<option value="<%=nCategoryId%>" <%if(nCategoryId==cResults.m_cContent.m_nCategoryId){%>selected<%}%>><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></option>
						<%}%>
					</select>

					<span class="PrivateNote" onclick="privateNote.showEditDlg()">
						<i class="far fa-sticky-note"></i>
						<span id="PrivateNoteSummary"></span>
					</span>
					<script>
						privateNote.setSummaryElement($("#PrivateNoteSummary"));
						privateNote.setPlaceholder('<%=_TEX.T("PrivateNote.Placeholder")%>');
						privateNote.setFooter('<%=_TEX.T("PrivateNote.Footer")%>');
						<%if(cResults.m_cContent.privateNote.isEmpty()){%>
						$("#PrivateNoteSummary").text('<%=_TEX.T("PrivateNote")%>');
						<%}else{%>
						privateNote.setText('<%=Util.toQuotedString(cResults.m_cContent.privateNote, "'")%>');
						<%}%>
					</script>
				</div>

				<div class="Description">
					<div class="SettingListTitle WithLangSelector" style="text-align: right; display: <%=nEditorId==Common.EDITOR_TEXT?"none":""%>">
<%--					<div class="SettingListTitle WithLangSelector" style="text-align: right; <%=checkLogin.isStaff()?"":"display: none"%>">--%>
						<span class="SelectTransLang">
							<i class="fas fa-language" style="font-size: 20px;"></i>
							<select id="EditTransDescLang" style="font-size: 12px;" onchange="switchTransTxt('Description', $(this).val())">
								<option value="default" selected><%=_TEX.T("EditGenreInfo.Translation.Default")%></option>
								<%for(UserLocale userLocale: SupportedLocales.list) {%>
								<option value="<%=userLocale.id%>"><%=userLocale.label%></option>
								<%}%>
							</select>
						</span>
					</div>
					<textarea id="EditDescription" class="EditDescription" maxlength="<%=Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"><%=Util.toDescString(cResults.m_cContent.m_strDescription)%></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum"><%=Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>

				<%if(nEditorId==Common.EDITOR_TEXT){%>
				<%if(noContentModification){%>
				<div class="OptionItem">
					<div class="OptionLabel">
						エアスケブお渡し期限後、タイトル・タグ・公開範囲等は変更はできますが、本文は変更できません。
					</div>
				</div>
				<%}%>
				<div class="TextBody">
					<input <%if(noContentModification){%>readonly<%}%> id="EditTextTitle" class="EditTextTitle" type="text" maxlength="50" placeholder="<%=_TEX.T("UploadFilePc.Text.Title")%>" value="<%=Util.toStringHtml(cResults.m_cContent.title)%>" />
					<textarea <%if(noContentModification){%>readonly<%}%> id="EditTextBody" class="EditTextBody" maxlength="<%=Common.EDITOR_TEXT_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Description.AddText")%>" onkeyup="DispTextCharNum()"><%=Util.toDescString(cResults.m_cContent.m_strTextBody)%></textarea>
					<div id="TextBodyCharNum" class="TextBodyCharNum"><%=Common.EDITOR_TEXT_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>
				<%}%>

				<div class="TagList">
					<input id="EditTagList" class="EditTagList" type="text" maxlength="100" placeholder="<%=_TEX.T("IllustV.Description.Tag")%>" onkeyup="DispTagListCharNum()" <%if(!cResults.m_cContent.m_strTagList.isEmpty()){%>value="<%=Util.toStringHtml(cResults.m_cContent.m_strTagList)%>"<%}%> />
					<div id="EditTagListCharNum" class="TagListCharNum">100</div>
				</div>
				<div class="UoloadCmdOption">
					<input id="ContentOpenId" value="<%=cResults.m_cContent.m_nOpenId%>" type="hidden"/>
					<div class="OptionItem" style="display: <%=nEditorId==Common.EDITOR_TEXT ? "block" : "none"%>">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Text.Direction")%></div>
						<div class="OptionPublish">
							<label><input type="radio" name="EditTextDirection" value="0" <%if(cResults.m_cContent.novelDirection==0){%>checked="checked"<%}%> /><%=_TEX.T("UploadFilePc.Text.Direction.Horizontal")%></label>
							<label><input type="radio" name="EditTextDirection" value="1" <%if(cResults.m_cContent.novelDirection==1){%>checked="checked"<%}%> /><%=_TEX.T("UploadFilePc.Text.Direction.Vertical")%></label>
						</div>
					</div>

					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Publish")%></div>
						<div class="OptionPublish">
							<select id="EditPublish" class="EditPublish" onchange="updatePublish(<%=checkLogin.m_nUserId%>)">
								<%for(int nPublishId : Common.PUBLISH_ID) {
									if(Common.PUBLISH_ID_T_FOLLOWER<=nPublishId && nPublishId<=Common.PUBLISH_ID_T_RT && !cTweet.m_bIsTweetEnable){
										continue;
									}
								%>
								<option value="<%=nPublishId%>" <%if(nPublishId==cResults.m_cContent.m_nPublishId){%>selected<%}%> ><%=_TEX.T(String.format("Publish.C%d", nPublishId))%></option>
								<%}%>
							</select>
						</div>
					</div>

					<div id="PublishInfo">
						<div class="OptionLabel"></div>
						<div class="OptionPublish" style="font-size: 11px;">
							<span id="PublishHiddenInfo" style="display: none"><%=_TEX.T("UploadFilePc.Option.Publish.HiddenInfo")%></span>
							<span id="PublishFollowerInfo" style="display: none"><%=_TEX.T("UploadFilePc.Option.Publish.FollowerInfo")%></span>
							<span id="PublishTwitterFollowerInfo" style="display: none"><%=_TEX.T("UploadFilePc.Option.Publish.TwitterFollowerInfo")%></span>
							<span id="PublishTwitterFollowingInfo" style="display: none"><%=_TEX.T("UploadFilePc.Option.Publish.TwitterFollowingInfo")%></span>
							<span id="PublishTwitterFollowEachInfo" style="display: none"><%=_TEX.T("UploadFilePc.Option.Publish.TwitterFollowEachInfo")%></span>
							<span id="PublishTwitterRTInfo" style="display: none"><%=_TEX.T("UploadFilePc.Option.Publish.TwitterRTInfo")%></span>
							<span id="PublishLoginInfo" style="display: none"><%=_TEX.T("UploadFilePc.Option.Publish.LoginInfo")%></span>
						</div>
					</div>

					<div id="ItemPassword" class="OptionItem"
						<%if(!(cResults.m_cContent.m_nPublishId == Common.PUBLISH_ID_PASS  && cResults.m_cContent.isPasswordEnabled())){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<input id="EditPassword" class="EditPassword" type="text" maxlength="16"
								<%if(cResults.m_cContent.isPasswordEnabled()){%>value="<%=cResults.m_cContent.m_strPassword%>"<%}%>
								placeholder="<%=_TEX.T("UploadFilePc.Option.Publish.Pass.Input")%>" />
						</div>
					</div>
					<div id="ItemTwitterList" class="OptionItem"
						<% boolean bPublishTwitterList = cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_T_LIST; %>
						<%if(!bPublishTwitterList){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<span id="TwitterListLoading"
								<%if(!bPublishTwitterList){%>style="display: none;"<%}%>
							></span>
							<span id="TwitterListNotFound"
								<%if(!bPublishTwitterList || bPublishTwitterList && cTweet.m_listOpenList!=null && cTweet.m_listOpenList.size()>0) { %>
									style="display: none;"
								<%}%>
								><%=_TEX.T("UploadFilePc.Option.Publish.T_List.NotFound")%></span>
							<select id="EditTwitterList" class="EditPublish"
								<%
								if(!bPublishTwitterList || (bPublishTwitterList && (cTweet.m_listOpenList==null || cTweet.m_listOpenList.size()==0))){%>style="display: none;"<%}%>
							>
								<%
								boolean bTwListFound = false;
								if(cTweet.m_listOpenList!=null){
									for(UserList l:cTweet.m_listOpenList){
								%>
								<option value="<%=l.getId()%>"
									<%if(!cResults.m_cContent.m_strListId.isEmpty() && l.getId() == Long.parseLong(cResults.m_cContent.m_strListId)) {
										bTwListFound = true;
									%> selected
									<%}%>
									><%=l.getName()%></option>
								<%	}%>
								<%}%>
							</select>
							<%if(cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_T_LIST){%>
								<%if(nTwLstRet==CTweet.ERR_RATE_LIMIT_EXCEEDED){%>
								<script>twitterListRateLimiteExceededMsg()</script>
								<%}else if(nTwLstRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){%>
								<script>twitterListInvalidTokenMsg()</script>
								<%}else if(nTwLstRet==CTweet.ERR_OTHER){%>
								<script>twitterListOtherErrMsg()</script>
								<%}else if(nTwLstRet==CTweet.OK && !bTwListFound){%>
								<script>twitterListNotFoundMsg()</script>
								<%}%>
							<%}%>
						</div>
					</div>

					<%if(nEditorId!=Common.EDITOR_TEXT){%>
					<div id="ItemShowAllFirst" class="OptionItem"
						 style="<%=(cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_ALL||cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_HIDDEN) ? "display: none" : ""%>">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.ShowAllFirst")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox"
								   name="OptionShowAllFirst" id="OptionShowAllFirst"
								   value="0" <%if(cResults.m_cContent.publishAllNum>0){%>checked<%}%>
							/>
							<label class="onoffswitch-label" for="OptionShowAllFirst">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<%}%>

					<div id="ItemTimeLimitedFlg" class="OptionItem"
						<%if(cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_HIDDEN){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Title")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionLimitedTimePublish"
									id="OptionLimitedTimePublish" value="0"
									onchange="updateOptionLimitedTimePublish()"
									<%if(cResults.m_cContent.m_bLimitedTimePublish){%>checked<%}%> />
							<label class="onoffswitch-label" for="OptionLimitedTimePublish">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="ItemTimeLimitedVal" class="OptionItem"
						<%if(cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_HIDDEN || !cResults.m_cContent.m_bLimitedTimePublish){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<%if(Util.isSmartPhone(request)) {%>
							<div style="display: block;">
								<span><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Start")%></span>
								<input id="EditTimeLimitedStart" class="EditTimeLimited" type="text" />
							</div>
							<div style="display: block;">
								<span><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.End")%></span>
								<input id="EditTimeLimitedEnd" class="EditTimeLimited" type="text" />
							</div>
							<%}else{%>
								<input id="EditTimeLimitedStart" class="EditTimeLimitedPc" type="text" maxlength="15" />
								<span class="EditTimeLimitedPcTo">〜</span>
								<input id="EditTimeLimitedEnd" class="EditTimeLimitedPc" type="text" maxlength="15" />
							<%}%>
						</div>
						<%if(cResults.m_cContent.m_bLimitedTimePublish){
							String strStartDateTime = Util.toYMDHMString(cResults.m_cContent.m_timeUploadDate);
							String strEndDateTime = Util.toYMDHMString(cResults.m_cContent.m_timeEndDate);
							%>
						<input id="EditTimeLimitedStartPresent" value="<%=strStartDateTime%>" type="hidden" />
						<input id="EditTimeLimitedEndPresent" value="<%=strEndDateTime%>" type="hidden" />
						<script>
							initStartDatetime("<%=strStartDateTime%>");
							initEndDatetime("<%=strEndDateTime%>");
						</script>
						<%}%>
					</div>
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Recent")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionRecent" id="OptionRecent" value="0" <%if(cResults.m_cContent.m_bNotRecently){%>checked<%}%> />
							<label class="onoffswitch-label" for="OptionRecent">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Tweet")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionTweet" id="OptionTweet" value="0" onchange="updateTweetButton()" <%if(cResults.m_cContent.isTweetConcurrent()){%>checked<%}%> />
							<label class="onoffswitch-label" for="OptionTweet">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="OptionTweetInfo" class="OptionInfo">
						<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.Info")%>
					</div>

					<%if(nEditorId==Common.EDITOR_UPLOAD || nEditorId==Common.EDITOR_PASTE || nEditorId==Common.EDITOR_BASIC_PAINT){%>
					<div id="ImageSwitch" class="OptionItem" style="display: none;">
						<div class="OptionLabelSub"><%=_TEX.T("UploadFilePc.Option.TweetImage")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionImage" id="OptionImage" value="0" onchange="updateTweetButton()" <%if(cResults.m_cContent.isTweetWithThumbnail()){%>checked<%}%>/>
							<label class="onoffswitch-label" for="OptionImage">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="OptionImageSwitchInfo" class="OptionInfo">
						<%=_TEX.T("UploadFilePc.Option.TweetImage.Info")%>
					</div>

					<div id="TwitterCardThumbnailSwitch" class="OptionItem">
						<div class="OptionLabel">
							<%=_TEX.T("UploadFilePc.Option.TwitterCardThumbnail")%>
						</div>
						<div class="onoffswitch OnOff">
							<input type="checkbox"
								   class="onoffswitch-checkbox"
								   name="OptionTwitterCardThumbnail"
								   id="OptionTwitterCardThumbnail"
								   value="0"
								   onchange="const $info=$('#OptionTwitterCardThumbnailSwitchInfo'); $(this).prop('checked') ? $info.show() : $info.hide()"
								   <%if(cResults.m_cContent.isTwitterCardThumbnail()){%>checked<%}%>/>
							<label class="onoffswitch-label" for="OptionTwitterCardThumbnail">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="OptionTwitterCardThumbnailSwitchInfo"
						 class="OptionInfo"
						 <%if(cResults.m_cContent.isTwitterCardThumbnail()){%>style="display: block"<%}%>
					>
						<%=_TEX.T("UploadFilePc.Option.TwitterCardThumbnail.Info")%>
					</div>

					<%}%>
					<div id="DeleteTweetSwitch" class="OptionItem"
						<%if(cResults.m_cContent.m_strTweetId.isEmpty()){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.DeleteTweet")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionDeleteTweet" id="OptionDeleteTweet" value="0" />
							<label class="onoffswitch-label" for="OptionDeleteTweet">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("Cheer.Upload.Label")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionCheerNg" id="OptionCheerNg" value="0" <%if(!cResults.m_cContent.m_bCheerNg){%>checked<%}%> />
							<label class="onoffswitch-label" for="OptionCheerNg">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
				</div>

				<div class="UoloadCmd">
				<%if(nEditorId==Common.EDITOR_UPLOAD){%>
					<a id="UoloadCmdBtn" class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UpdateFileCheck(<%=checkLogin.m_nUserId%>, <%=cResults.m_nContentId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				<%}else if(nEditorId==Common.EDITOR_PASTE){%>
					<a id="UoloadCmdBtn" class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UpdatePasteCheck(<%=checkLogin.m_nUserId%>, <%=cResults.m_nContentId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				<%}else if(nEditorId==Common.EDITOR_TEXT){%>
					<a id="UoloadCmdBtn" class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UpdateTextCheck(<%=checkLogin.m_nUserId%>, <%=cResults.m_nContentId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				<%}%>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
