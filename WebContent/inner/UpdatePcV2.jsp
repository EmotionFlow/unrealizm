<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.util.CTweet"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

boolean isCreateContent = false;

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

final CContent content = cResults.m_cContent;

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

response.setHeader("Access-Control-Allow-Origin", "https://img.unrealizm.com");
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<link href="/js/flatpickr/flatpickr.min.css" type="text/css" rel="stylesheet" />
		<link href="/css/upload-206-4.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="/js/flatpickr/flatpickr.min.js"></script>
		<script src="/js/upload-51-8.js" type="text/javascript"></script>
		<script src="/js/update-25-3.js" type="text/javascript"></script>

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
			function UpdateFileCheck(user_id) {
				if(!multiFileUploader) return;
				if(getPreviewAreaImageNum()<=0) {
					DispMsg('<%=_TEX.T("UploadFilePc.Image.NeedImage")%>');
					return;
				}
				UpdateFile(user_id, <%=content.m_nContentId%>);
			}
			$(function() {
				initUpdateFile(<%=Common.UPLOAD_FILE_MAX[checkLogin.m_nPassportId]%>, <%=Common.UPLOAD_FILE_TOTAL_SIZE[checkLogin.m_nPassportId]%>, <%=cResults.m_nUserId%>, <%=cResults.m_nContentId%>);
				<%if(noContentModification){%>
				multiFileUploader._options.callbacks.onValidateBatch = (arr, btn) => {return false;};
				<%}%>
			});
			<%}else if(nEditorId==Common.EDITOR_PASTE){%>
			function UpdatePasteCheck(user_id) {
				UpdatePaste(user_id, <%=content.m_nContentId%>);
			}
			$(function() {
				$('#PasteZone').sortable();
				initUpdatePaste(<%=cResults.m_nUserId%>, <%=cResults.m_nContentId%>);
			});
			<%} else if(nEditorId==Common.EDITOR_TEXT){%>
			function UpdateTextCheck(user_id) {
				UpdateText(user_id, <%=content.m_nContentId%>);
			}
			$(function() {
				DispTextCharNum();
			});
			<%}%>

			let contentParams = UPLOAD_PARAMS_DEFAULT;
			contentParams.OPTION_PUBLISH.value = <%=content.nowAvailable() || content.m_bLimitedTimePublish%>;
			contentParams.OPTION_NOT_TIME_LIMITED.value = <%=!content.m_bLimitedTimePublish%>;
			contentParams.TIME_LIMITED_START.value = "<%=Util.toYMDHMString(content.m_timeUploadDate)%>";
			contentParams.TIME_LIMITED_END.value = "<%=Util.toYMDHMString(content.m_timeEndDate)%>";

			contentParams.OPTION_NOT_PUBLISH_NSFW.value = <%=content.m_nSafeFilter==Common.SAFE_FILTER_ALL%>;
			<%if (content.isValidSafeFilterId() && content.m_nSafeFilter!=Common.SAFE_FILTER_ALL) {%>
				contentParams.NSFW_VAL.value = <%=content.m_nSafeFilter%>;
			<%}else{%>
				contentParams.NSFW_VAL.value = <%=Common.SAFE_FILTER_R15%>;
			<%}%>

			contentParams.OPTION_NO_CONDITIONAL_SHOW.value = <%=content.m_nPublishId==Common.PUBLISH_ID_ALL%>;
			<%if (content.isValidPublishId() && content.m_nPublishId!=Common.PUBLISH_ID_ALL) {%>
				contentParams.SHOW_LIMIT_VAL.value = <%=content.m_nPublishId%>;
			<%}else{%>
				contentParams.SHOW_LIMIT_VAL.value = <%=Common.PUBLISH_ID_LOGIN%>;
			<%}%>

			contentParams.OPTION_NO_PASSWORD.value = <%=!content.passwordEnabled%>;
			contentParams.PASSWORD_VAL.value = "<%=content.m_strPassword%>";
			contentParams.OPTION_SHOW_FIRST.value = <%=content.publishAllNum>0%>;
			contentParams.OPTION_TWEET.value = <%=content.isTweetConcurrent()%>;
			contentParams.OPTION_TWEET_IMAGE.value = <%=content.isTweetWithThumbnail()%>;
			contentParams.OPTION_TWITTER_CARD_THUMBNAIL.value = <%=content.isTwitterCardThumbnail()%>;
			contentParams.OPTION_CHEER_NG.value = <%=content.m_bCheerNg%>;
			contentParams.OPTION_RECENT.value = <%=!content.m_bNotRecently%>;
			<%if (nEditorId == Common.EDITOR_TEXT){ %>
				contentParams.NOVEL_DIRECTION_VAL.value = <%=content.novelDirection%>;
			<%}%>

			$(function() {
				DispDescCharNum();
				setUploadParams(contentParams);
			});
		</script>

		<style>
            body {padding-top: 79px !important; background-color: #f5f5f5; color: #6d6965}
			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			.qq-gallery.qq-uploader {width: 100%;box-sizing: border-box; margin: 0; padding: 0; min-height: 113px; background: #fff; max-height: none; border: solid;}
			.qq-gallery .qq-upload-list {padding: 0; max-height: none;}
			.qq-gallery .qq-total-progress-bar-container {display: none;}
			.qq-gallery .qq-upload-list li {margin: 5px; height: 100px; padding: 0; box-shadow: none; max-width: 100px; background-color: #f3f3f3; border-radius: 4px;}
			.qq-gallery .qq-file-info {display: none;}
			.qq-upload-retry-selector .qq-upload-retry {display: none;}
			.qq-gallery .qq-upload-fail .qq-upload-status-text {display: none;}
			.qq-gallery .qq-upload-retry {display: none;}
			.qq-gallery .qq-thumbnail-wrapper {height: 101px; width: 101px; border-radius: 6px;}
			.qq-gallery .qq-upload-cancel {right: -8px; top: -8px; width: 26px; height: 26px; line-height: 20px; font-size: 12px; padding: 0; border: solid 3px #fafafa; border-radius: 30px;}

			<%if(!Util.isSmartPhone(request)) {%>
			.qq-gallery.qq-uploader {min-height: 193px;}
			.qq-gallery .qq-upload-list li {margin: 7px; height: 177px; max-width: 177px;}
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
				opacity: 0.6,
			});
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
				<li><a class="TabMenuItem Selected" href="/UpdateFilePcV2.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_cContent.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.File")%></a></li>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Text")%></span></li>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Paste")%></span></li>
<%--			<%}else if(nEditorId==Common.EDITOR_TEXT){%>--%>
<%--				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.File")%></span></li>--%>
<%--				<li><a class="TabMenuItem Selected" href="/UpdateTextPcV2.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.Text")%></a></li>--%>
<%--				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Paste")%></span></li>--%>
			<%}else if(nEditorId==Common.EDITOR_PASTE){%>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.File")%></span></li>
				<li><span class="TabMenuItem"><%=_TEX.T("UploadFilePc.Tab.Text")%></span></li>
				<li><a class="TabMenuItem Selected" href="/UpdatePastePcV2.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a></li>
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

				<div class="Prompt">
					<textarea id="EditPrompt" class="EditPrompt" maxlength="<%=Common.EDITOR_PROMPT_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Prompt.Add")%>" onkeyup="DispPromptCharNum()"><%=Util.toDescString(cResults.m_cContent.aiPrompt)%></textarea>
					<div id="PromptCharNum" class="PromptCharNum"><%=Common.EDITOR_PROMPT_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>

				<div class="OtherParams">
					<input id="EditOtherParams" class="EditOtherParams" type="text" maxlength="100" placeholder="<%=_TEX.T("IllustV.OtherParams.Add")%>" onkeyup="DispOtherParamsCharNum()" <%if(!cResults.m_cContent.aiOtherParams.isEmpty()){%>value="<%=Util.toStringHtml(cResults.m_cContent.aiOtherParams)%>"<%}%>/>
					<div class="OtherParamsCharNum"><span id="OtherParamsCharNum">100</span></div>
				</div>

				<div class="CategoryDesc" style="display: none;">
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
				<div class="OptionItem">
					<div class="OptionPublish">
						<label><input type="radio" name="NOVEL_DIRECTION_VAL" value="<%=CContent.NOVEL_DIRECTION_HORIZONTAL%>" id="RadioHorizontal" /><%=_TEX.T("UploadFilePc.Text.Direction.Horizontal")%></label>
						<label><input type="radio" name="NOVEL_DIRECTION_VAL" value="<%=CContent.NOVEL_DIRECTION_VERTICAL%>" id="RadioVertical" /><%=_TEX.T("UploadFilePc.Text.Direction.Vertical")%></label>
					</div>
				</div>
				<%}%>

				<div class="TagList">
					<input id="EditTagList" class="EditTagList" type="text" maxlength="100" placeholder="<%=_TEX.T("IllustV.Description.Tag")%>" onkeyup="DispTagListCharNum()" <%if(!cResults.m_cContent.m_strTagList.isEmpty()){%>value="<%=Util.toStringHtml(cResults.m_cContent.m_strTagList)%>"<%}%> />
					<div id="EditTagListCharNum" class="TagListCharNum">100</div>
				</div>
				<div class="UoloadCmdOption">
					<input id="ContentOpenId" value="<%=cResults.m_cContent.m_nOpenId%>" type="hidden"/>

					<%@include file="UpCmdOptions.jsp"%>

					<div class="UoloadCmd">
						<a id="UoloadCmdBtn"
						   class="BtnBase UoloadCmdBtn"
						   href="javascript:void(0)"
								<%if(nEditorId==Common.EDITOR_UPLOAD){%>
						   onclick="UpdateFileCheck(<%=checkLogin.m_nUserId%>)"
								<%}else if(nEditorId==Common.EDITOR_PASTE){%>
						   onclick="UpdatePasteCheck(<%=checkLogin.m_nUserId%>)"
								<%}else if(nEditorId==Common.EDITOR_TEXT){%>
						   onclick="UpdateTextCheck(<%=checkLogin.m_nUserId%>)"
								<%}%>
						>
							<i class="fas fa-upload"></i> <%=_TEX.T("UploadFilePc.UploadBtn")%>
						</a>
					</div>
				</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
