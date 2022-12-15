<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.util.CTweet"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

boolean isCreateContent = true;
final CContent content = null;

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

CTweet cTweet = new CTweet();
boolean bTwRet = cTweet.GetResults(checkLogin.m_nUserId);

String strTag = "";
int requestId = -1;
try {
	request.setCharacterEncoding("UTF-8");
	strTag = Common.TrimAll(request.getParameter("TAG"));
	requestId = Util.toInt(request.getParameter("RID"));
} catch(Exception e) {
	;
}

Request poipikuRequest = null;
if (requestId > 0) {
	poipikuRequest = new Request(requestId);
	if (poipikuRequest.creatorUserId != checkLogin.m_nUserId || poipikuRequest.status != Request.Status.InProgress) {
		return;
	}
}

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<link href="/js/flatpickr/flatpickr.min.css" type="text/css" rel="stylesheet" />
		<link href="/css/upload-206-5.css" type="text/css" rel="stylesheet" />

		<script type="text/javascript" src="/js/exifr/exifr.7.1.3.full.umd.min.js"></script>
		<script type="text/javascript" src="/js/flatpickr/flatpickr.min.js"></script>
		<script src="/js/upload-51-10.js" type="text/javascript"></script>

		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			<link href="/js/fine-uploader/fine-uploader-gallery-0.3.css" type="text/css" rel="stylesheet" />
			<%@ include file="/js/fine-uploader/templates/gallery-0.2.html"%>
			<script type="text/javascript" src="/js/fine-uploader/fine-uploader.js"></script>
		<%}%>

		<%@ include file="UpPcV.jsp"%>
		<script>
			let transList = {
				'Description' : {
					'default': '',
					<%for(UserLocale userLocale: SupportedLocales.list) {%>
					'<%=userLocale.id%>': '',
					<%}%>
				}
			}

			let selected = {
				'Description' : 'default',
			}

			function onCompleteUpload(){
				<%if(requestId<0){%>
				location.href = "/MyIllustListPcV.jsp";
				<%}else{%>
				location.href = "/MyRequestListPcV.jsp?MENUID=RECEIVED&ST=3";
				<%}%>
			}

			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			function UploadFileCheck(user_id) {
				if(!multiFileUploader) return;
				if(multiFileUploader.getSubmittedNum()<=0){
					DispMsg('<%=_TEX.T("UploadFilePc.Image.NeedImage")%>');
					return;
				}
				UploadFile(user_id, <%=requestId%>);
			}
			function completeAddFile() {
				$('#UploadBtn').html('<%=_TEX.T("UploadFilePc.AddtImg")%>');
			}
			$(function(){
				initUploadFile(<%=Common.UPLOAD_FILE_MAX[checkLogin.m_nPassportId]%>, <%=Common.UPLOAD_FILE_TOTAL_SIZE[checkLogin.m_nPassportId]%>);
			});
			<%}else if(nEditorId==Common.EDITOR_PASTE){%>
			function UploadPasteCheck(user_id) {
				let nImageNum = 0;
				$('.imgView').each(function(){
					const strSrc = $.trim($(this).attr('src'));
					if(strSrc.length>0) nImageNum++;
				});
				if(nImageNum<=0) {
					DispMsg('<%=_TEX.T("UploadFilePc.Paste.NeedImage")%>');
					return;
				}
				UploadPaste(user_id);
			}
			$(function() {
				initUploadPaste();
				switchTransTxt('Description', 'default');
			});
			<%} else if(nEditorId==Common.EDITOR_TEXT){%>
			function UploadTextCheck(user_id) {
				const strTextBody = $.trim($("#EditTextBody").val());
				if(!strTextBody) {
					DispMsg('<%=_TEX.T("UploadFilePc.Text.NeedBody")%>');
					return;
				}
				UploadText(user_id, <%=requestId%>);
			}
			$(function() {
				DispTextCharNum();
			});
			<%}%>

			$(function() {
				<%if(Util.isSmartPhone(request)){%>
				$('#MenuUpload').addClass('Selected');
				<%}else{%>
				$('#HeaderMenuUpload').addClass('Selected');
				<%}%>
				initUploadParams(<%=cTweet.m_bIsTweetEnable%>);
				DispDescCharNum();
			});
		</script>

		<style>
			body {padding-top: 51px !important; background-color: #f5f5f5; color: #000}
			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			.qq-gallery.qq-uploader {width: 100%;box-sizing: border-box; margin: 0; padding: 0; min-height: 113px; background: #fff; color: #000; max-height: none; border: solid;}
			.qq-gallery .qq-upload-list {padding: 0; max-height: none;}
			.qq-gallery .qq-total-progress-bar-container {display: none;}
			.qq-gallery .qq-upload-list li {margin: 5px; height: 101px; padding: 0; box-shadow: none; max-width: 101px; background-color: #f3f3f3; border-radius: 4px;}
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
			<%}else if(nEditorId==Common.EDITOR_PASTE){%>
				<%if(!Util.isSmartPhone(request)) {%>
				.PasteZone {min-height: 193px;}
				.UploadFile .InputFile {margin: 8px; height: 177px; width: 177px;}
				<%}%>
			<%}%>
			#TwitterListLoading {
				display: block;
				width: 100%;
				height: 15px;
				margin-right: 3px;
				background: url(/img/loading.gif);
				background-size: contain;
				background-repeat: no-repeat;
				background-position: center;
			}
		</style>
	</head>
	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%if(requestId<0){%>
		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
			<%
				String cgiParams = "?TAG=" + strTag;
				if(requestId>0){
					cgiParams += String.format("&RID=%d", requestId);
				}
			%>
				<li><a class="TabMenuItem <%=nEditorId == Common.EDITOR_UPLOAD ? "Selected" : ""%>"
						href="/UploadFilePcV2.jsp<%=cgiParams%>">
					<%=_TEX.T("UploadFilePc.Tab.File")%>
				</a></li>
<%--				<li><a class="TabMenuItem <%=nEditorId == Common.EDITOR_TEXT ? "Selected" : ""%>"--%>
<%--						href="/UploadTextPcV2.jsp<%=cgiParams%>">--%>
<%--					<%=_TEX.T("UploadFilePc.Tab.Text")%>--%>
<%--				</a></li>--%>
				<li><a class="TabMenuItem <%=nEditorId == Common.EDITOR_PASTE ? "Selected" : ""%>"
						href="/UploadPastePcV2.jsp<%=cgiParams%>">
					<%=_TEX.T("UploadFilePc.Tab.Paste")%>
				</a></li>
			</ul>
		</nav>
		<%}%>

		<%if(requestId<0){%>
		<%if(nEditorId==Common.EDITOR_TEXT){%>
		<%@ include file="/inner/TAdPoiPassHeaderUploadTextPcV.jsp"%>
		<%}else{%>
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		<%}%>
		<%}%>

		<article class="Wrapper" style="padding-top: 10px">
			<div class="UploadFile" <%if(requestId>0){%>style="padding-bottom: 80px"<%}%>>
				<%if(requestId>0){%>
				<div class="RequestText">
					<%=Util.toStringHtml(poipikuRequest.requestText)%>
				</div>
				<%}%>
				<%if(nEditorId==Common.EDITOR_UPLOAD){%>
				<div class="TimeLineIllustCmd">
					<span id="file-drop-area"></span>
					<span id="TotalSize" class="TotalSize">(jpeg|png|gif, <%=Common.UPLOAD_FILE_MAX[checkLogin.m_nPassportId]%>files, total <%=Common.UPLOAD_FILE_TOTAL_SIZE[checkLogin.m_nPassportId]%>MByte)</span>
					<div id="TimeLineAddImage" class="SelectImageBtn BtnBase Rev">
						<i class="far fa-images"></i>
						<span id="UploadBtn"><%=_TEX.T("UploadFilePc.SelectImg")%></span>
					</div>
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
					<span>
						<label id="EditCategoryLabel" for="EditCategory"><i class="fas fa-terminal"></i></label>
						<select id="EditCategory">
							<%for(int nCategoryId : Common.CATEGORY_ID) {%>
							<option value="<%=nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></option>
							<%}%>
						</select>
					</span>

					<span class="PrivateNote" onclick="privateNote.showEditDlg()">
					<i class="far fa-sticky-note"></i>
					<span id="PrivateNoteSummary"><%=_TEX.T("PrivateNote")%></span>
					</span>
					<script>
						privateNote.setSummaryElement($("#PrivateNoteSummary"));
						privateNote.setPlaceholder('<%=_TEX.T("PrivateNote.Placeholder")%>');
						privateNote.setFooter('<%=_TEX.T("PrivateNote.Footer")%>');
					</script>
				</div>


				<div class="Prompt">
					<textarea id="EditPrompt" class="EditPrompt" maxlength="<%=Common.EDITOR_PROMPT_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Prompt.Add")%>" onkeyup="DispPromptCharNum()"></textarea>
					<div id="PromptCharNum" class="PromptCharNum"><%=Common.EDITOR_PROMPT_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>

				<div class="Prompt">
					<textarea id="EditNegativePrompt" class="EditNegativePrompt" maxlength="<%=Common.EDITOR_PROMPT_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.NegativePrompt.Add")%>" onkeyup="DispNegativePromptCharNum()"></textarea>
					<div id="NegativePromptCharNum" class="PromptCharNum"><%=Common.EDITOR_PROMPT_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>

				<div class="OtherParams">
					<textarea id="EditOtherParams" class="EditOtherParams" maxlength="<%=Common.EDITOR_OTHER_PARAMS_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.OtherParams.Add")%>" onkeyup="DispOtherParamsCharNum()"></textarea>
					<div class="OtherParamsCharNum"><span id="OtherParamsCharNum"><%=Common.EDITOR_OTHER_PARAMS_MAX[nEditorId][checkLogin.m_nPassportId]%></span></div>
				</div>

				<div class="Description">
					<div class="SettingListTitle WithLangSelector" style="text-align: right; display: none">
						<span class="SelectTransLang">
							<i class="fas fa-language" style="font-size: 20px;" onclick="showTransDescMsg();"></i>
							<select id="EditTransDescLang" style="font-size: 12px;" onchange="switchTransTxt('Description', $(this).val())">
								<option value="default" selected><%=_TEX.T("EditGenreInfo.Translation.Default")%></option>
								<%for(UserLocale userLocale: SupportedLocales.list) {%>
								<option value="<%=userLocale.id%>"><%=userLocale.label%></option>
								<%}%>
							</select>
						</span>
					</div>
					<textarea id="EditDescription" class="EditDescription" maxlength="<%=Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum"><%=Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>

				<%if(nEditorId==Common.EDITOR_TEXT){%>
				<div class="TextBody">
					<input id="EditTextTitle" class="EditTextTitle" type="text" maxlength="50" placeholder="<%=_TEX.T("UploadFilePc.Text.Title")%>" />
					<textarea id="EditTextBody" class="EditTextBody" maxlength="<%=Common.EDITOR_TEXT_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Description.AddText")%>" onkeyup="DispTextCharNum()"></textarea>
					<div id="TextBodyCharNum" class="TextBodyCharNum"><%=Common.EDITOR_TEXT_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>
				<div class="OptionItem" style="display: block">
					<div class="OptionPublish">
						<label><input type="radio" name="NOVEL_DIRECTION_VAL" value="<%=CContent.NOVEL_DIRECTION_HORIZONTAL%>" id="RadioHorizontal" /><%=_TEX.T("UploadFilePc.Text.Direction.Horizontal")%></label>
						<label><input type="radio" name="NOVEL_DIRECTION_VAL" value="<%=CContent.NOVEL_DIRECTION_VERTICAL%>" id="RadioVertical" /><%=_TEX.T("UploadFilePc.Text.Direction.Vertical")%></label>
					</div>
				</div>
				<%}%>

				<div class="TagList">
					<input id="EditTagList" class="EditTagList" type="text" placeholder="<%=_TEX.T("IllustV.Description.Tag")%>" <%if(!strTag.isEmpty()){%>value="#<%=Util.toStringHtml(strTag)%>"<%}%> readonly onclick="showSetTagDlg({placeholder: '<%=_TEX.T("IllustV.Description.Tag.Info")%>', header: '<%=_TEX.T("IllustV.Description.Tag.ListHeader")%>', addTag: '<%=_TEX.T("IllustV.Description.Tag.Add")%>', blankMsg: '<%=_TEX.T("IllustV.Description.Tag.Blank")%>', doneMsg: '<%=_TEX.T("IllustV.Description.Tag.Done")%>'})" data-tag-max-num="<%=Common.TAG_MAX_NUM%>" data-tag-max-length="<%=Common.TAG_MAX_LENGTH%>"/>
				</div>

				<div class="UoloadCmdOption">
					<%@include file="UpCmdOptions.jsp"%>

					<div class="UoloadCmd">
					<a id="UoloadCmdBtn"
						class="BtnBase UoloadCmdBtn"
						href="javascript:void(0)"
					<%if(nEditorId==Common.EDITOR_UPLOAD){%>
						onclick="UploadFileCheck(<%=checkLogin.m_nUserId%>)"
					<%}else if(nEditorId==Common.EDITOR_PASTE){%>
						onclick="UploadPasteCheck(<%=checkLogin.m_nUserId%>)"
					<%}else if(nEditorId==Common.EDITOR_TEXT){%>
						onclick="UploadTextCheck(<%=checkLogin.m_nUserId%>)"
					<%}%>
					>
						<i class="fas fa-upload"></i> <%=_TEX.T("UploadFilePc.UploadBtn")%>
					</a>
				</div>
			</div>
		</article>
		<%if(requestId<0){%>
		<%@ include file="/inner/TFooter.jsp"%>
		<%}%>
	</body>
	<%@ include file="TTranslateDescDlg.jsp"%>
</html>
