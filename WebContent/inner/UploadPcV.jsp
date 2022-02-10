<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.util.CTweet"%>
<%@ page import="twitter4j.UserList"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

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
		<script type="text/javascript" src="/js/flatpickr/flatpickr.min.js"></script>
		<script src="/js/upload-46.js" type="text/javascript"></script>

		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuUpload').addClass('Selected');
		});
		</script>

		<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			<link href="/js/fine-uploader/fine-uploader-gallery-0.3.css" type="text/css" rel="stylesheet" />
			<%@ include file="/js/fine-uploader/templates/gallery-0.2.html"%>
			<script type="text/javascript" src="/js/fine-uploader/fine-uploader.js"></script>
		<%}%>

		<%@ include file="UpPcV.jsp"%>
		<script>
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
				var nImageNum = 0;
				$('.imgView').each(function(){
					var strSrc = $.trim($(this).attr('src'));
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
			});
			<%} else if(nEditorId==Common.EDITOR_TEXT){%>
			function UploadTextCheck(user_id) {
				var strTextBody = $.trim($("#EditTextBody").val());
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
				initOption();
				DispDescCharNum();
				onClickOptionItem();
			});
		</script>

		<style>
			body {padding-top: 79px !important;}
			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			.qq-gallery.qq-uploader {width: 100%;box-sizing: border-box; margin: 0; border: none; padding: 0; min-height: 113px; background: #fff; color: #6d6965; max-height: none;}
			.qq-gallery .qq-upload-list {padding: 0; max-height: none;}
			.qq-gallery .qq-total-progress-bar-container {display: none;}
			.qq-gallery .qq-upload-list li {margin: 6px; height: 101px; padding: 0; box-shadow: none; max-width: 101px; background-color: #f3f3f3; border-radius: 4px;}
			.qq-gallery .qq-file-info {display: none;}
			.qq-upload-retry-selector qq-upload-retry {display: none;}
			.qq-gallery .qq-upload-fail .qq-upload-status-text {display: none;}
			.qq-gallery .qq-upload-retry {display: none;}
			.qq-gallery .qq-thumbnail-wrapper {height: 101px; width: 101px; border-radius: 6px;}
			.qq-gallery .qq-upload-cancel {right: -8px; top: -8px; width: 26px; height: 26px; line-height: 20px; font-size: 12px; padding: 0; border: solid 3px #fafafa; border-radius: 30px;}
				<%if(!Util.isSmartPhone(request)) {%>
				.qq-gallery.qq-uploader {min-height: 193px;}
				.qq-gallery .qq-upload-list li {margin: 8px; height: 177px; max-width: 177px;}
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
				width: 15px;
				height: 15px;
				margin-right: 3px;
				background: url(/img/loading.gif);
				background-size: contain;
				background-repeat: no-repeat;
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
						href="/UploadFilePcV.jsp<%=cgiParams%>">
					<%=_TEX.T("UploadFilePc.Tab.File")%>
				</a></li>
				<li><a class="TabMenuItem <%=nEditorId == Common.EDITOR_TEXT ? "Selected" : ""%>"
						href="/UploadTextPcV.jsp<%=cgiParams%>">
					<%=_TEX.T("UploadFilePc.Tab.Text")%>
				</a></li>
				<li><a class="TabMenuItem <%=nEditorId == Common.EDITOR_PASTE ? "Selected" : ""%>"
						href="/UploadPastePcV.jsp<%=cgiParams%>">
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

		<article class="Wrapper">
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
					<select id="EditCategory">
						<%for(int nCategoryId : Common.CATEGORY_ID) {%>
						<option value="<%=nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></option>
						<%}%>
					</select>
					<%if(requestId>0){%>
					<script>
						$(()=>{$('.CategoryDesc option[value="6"]').prop('selected', true);})
					</script>
					<%}%>

					<span class="PrivateNote" onclick="privateNote.showEditDlg()">
						<i class="far fa-sticky-note"></i>
						<span id="PrivateNoteSummary"><%=_TEX.T("PrivateNote")%></span>
					</span>
					<script>
						privateNote.setSummaryElement($("#PrivateNoteSummary"));
						privateNote.setPlaceholder('<%=_TEX.T("PrivateNote.Placeholder")%>');
					</script>
				</div>

				<div class="Description">
					<textarea id="EditDescription" class="EditDescription" maxlength="<%=Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum"><%=Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>

				<%if(nEditorId==Common.EDITOR_TEXT){%>
				<div class="TextBody">
					<input id="EditTextTitle" class="EditTextTitle" type="text" maxlength="50" placeholder="<%=_TEX.T("UploadFilePc.Text.Title")%>" />
					<textarea id="EditTextBody" class="EditTextBody" maxlength="<%=Common.EDITOR_TEXT_MAX[nEditorId][checkLogin.m_nPassportId]%>" placeholder="<%=_TEX.T("IllustV.Description.AddText")%>" onkeyup="DispTextCharNum()"></textarea>
					<div id="TextBodyCharNum" class="TextBodyCharNum"><%=Common.EDITOR_TEXT_MAX[nEditorId][checkLogin.m_nPassportId]%></div>
				</div>
				<%}%>

				<div class="TagList">
					<input id="EditTagList" class="EditTagList" type="text" maxlength="100" placeholder="<%=_TEX.T("IllustV.Description.Tag")%>" onkeyup="DispTagListCharNum()" <%if(!strTag.isEmpty()){%>value="#<%=Util.toStringHtml(strTag)%>"<%}%> />
					<div id="EditTagListCharNum" class="TagListCharNum">100</div>
				</div>
				<div class="UoloadCmdOption">
					<div class="OptionItem" style="display: <%=nEditorId==Common.EDITOR_TEXT ? "block" : "none"%>">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Text.Direction")%></div>
						<div class="OptionPublish">
							<label><input type="radio" name="EditTextDirection" value="0" checked="checked" /><%=_TEX.T("UploadFilePc.Text.Direction.Horizontal")%></label>
							<label><input type="radio" name="EditTextDirection" value="1" /><%=_TEX.T("UploadFilePc.Text.Direction.Vertical")%></label>
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
								<option value="<%=nPublishId%>"><%=_TEX.T(String.format("Publish.C%d", nPublishId))%></option>
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

					<%if(requestId>0){%><div style="display: none;"><%}%>
					<div id="ItemPassword" class="OptionItem" style="display: none;">
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<input id="EditPassword" class="EditPassword" type="text" maxlength="16" placeholder="<%=_TEX.T("UploadFilePc.Option.Publish.Pass.Input")%>" />
						</div>
					</div>
					<div id="ItemTwitterList" style="display: none;">
						<div class="OptionItem">
							<div class="OptionPublish">
								<span id="TwitterListLoading"></span>
								<span id="TwitterListNotFound" style="display: none;"><%=_TEX.T("UploadFilePc.Option.Publish.T_List.NotFound")%></span>
								<select id="EditTwitterList" class="EditPublish" style="display: none;">
								</select>
							</div>
						</div>
						<div class="OptionItem">
							<div class="OptionPublish" style="font-size: 11px;">
								<span><%=_TEX.T("UploadFilePc.Option.Publish.TwitterListInfo")%></span>
							</div>
						</div>
					</div>

					<%if(nEditorId!=Common.EDITOR_TEXT){%>
					<div id="ItemShowAllFirst" class="OptionItem" style="display: none">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.ShowAllFirst")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionShowAllFirst" id="OptionShowAllFirst" value="0" />
							<label class="onoffswitch-label" for="OptionShowAllFirst">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<%}%>

					<div id="ItemTimeLimitedFlg" class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Title")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionLimitedTimePublish" id="OptionLimitedTimePublish" value="0" onchange="updateOptionLimitedTimePublish()"/>
							<label class="onoffswitch-label" for="OptionLimitedTimePublish">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="ItemTimeLimitedVal" class="OptionItem" style="display: none;">
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
					</div>

					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Recent")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionRecent" id="OptionRecent" value="0" />
							<label class="onoffswitch-label" for="OptionRecent">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Tweet")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionTweet" id="OptionTweet" value="0" onchange="updateTweetButton()" />
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
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionImage" id="OptionImage" value="0"  onchange="updateTweetButton()"/>
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
							/>
							<label class="onoffswitch-label" for="OptionTwitterCardThumbnail">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="OptionTwitterCardThumbnailSwitchInfo" class="OptionInfo">
						<%=_TEX.T("UploadFilePc.Option.TwitterCardThumbnail.Info")%>
					</div>
					<%}%>
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("Cheer.Upload.Label")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionCheerNg" id="OptionCheerNg" value="0" />
							<label class="onoffswitch-label" for="OptionCheerNg">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
				</div>
				<%if(requestId>0){%></div><%}%>

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
						<%if(requestId < 0){%>
						<%=_TEX.T("UploadFilePc.UploadBtn")%>
						<%}else{%>
						納品する
						<%}%>
					</a>
				</div>
			</div>
		</article>
		<%if(requestId<0){%>
		<%@ include file="/inner/TFooter.jsp"%>
		<%}%>
	</body>
</html>
