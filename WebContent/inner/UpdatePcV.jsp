<%@ page import="jp.pipa.poipiku.util.CTweet"%>
<%@ page import="twitter4j.UserList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

IllustViewC cResults = new IllustViewC();
cResults.getParam(request);

if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

CTweet cTweet = new CTweet();
boolean bTwRet = cTweet.GetResults(cCheckLogin.m_nUserId);
int nTwLstRet = 0;
if(bTwRet && cTweet.m_bIsTweetEnable && cResults.m_cContent.m_nPublishId == Common.PUBLISH_ID_T_LIST){
	nTwLstRet = cTweet.GetMyOpenLists();
}

final int[] PUBLISH_ID = {
		0,			// 全体
		1,			// ワンクッション
		2,			// R18
		4,			// パスワード
		5,			// ログイン限定
		6,			// ふぁぼ限定
		7,			// ツイッターフォロワー限定
		8,			// ツイッターフォロー限定
		9,			// ツイッター相互フォロー限定
		10,			// ツイッターリスト限定
		99			// 非公開
};

response.setHeader("Access-Control-Allow-Origin", "https://img.poipiku.com");
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<link href="/js/flatpickr/flatpickr.min.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="/js/flatpickr/flatpickr.min.js"></script>
		<script src="/js/upload-21.js" type="text/javascript"></script>
		<script src="/js/update-03.js" type="text/javascript"></script>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuUpload').addClass('Selected');
		});
		</script>
		<link href="/js/fine-uploader/fine-uploader-gallery-0.3.css" type="text/css" rel="stylesheet" />

		<%if(nEditorId==0){%>
			<%@ include file="/js/fine-uploader/templates/gallery-0.2.html"%>
		<%}%>

		<script type="text/javascript" src="/js/fine-uploader/fine-uploader.js"></script>

		<%if(nEditorId==1){%>
		<!-- 画像並び替え用 -->
		<script src="/js/jquery-ui.js"></script>
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

		<script>
			function startMsg() {
				DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
			}

			function errorMsg() {
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + data.content_id);
			}

			function dateTimeEmptyMsg() {
				DispMsg('<%=_TEX.T("EditIllustVCommon.EditTimeLimited.EmptyError")%>');
			}

			function dateTimePastMsg() {
				DispMsg('<%=_TEX.T("EditIllustVCommon.EditTimeLimited.PastError")%>');
			}

			function dateTimeReverseMsg() {
				DispMsg('<%=_TEX.T("EditIllustVCommon.EditTimeLimited.ReverseError")%>');
			}

			function twtterListRateLimiteExceededMsg() {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.RateLimiteExceeded")%>");
			}
			function twtterListInvalidTokenMsg() {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.InvalidToken")%>");
			}
			function twitterListNotFoundMsg() {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.NotFound")%>");
			}
			function twtterListOtherErrMsg(nErrCode) {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.OtherErr")%>: " + nErrCode);
			}

			function twtterTweetInvalidTokenMsg() {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.InvalidToken")%>");
			}
			function twtterTweetRateLimitMsg() {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.RateLimiteExceeded")%>");
			}
			function twtterTweetTooMuchMsg() {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.TooMuch")%>");
			}
			function twtterTweetOtherErrMsg(nErrCode) {
				DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.OtherErr")%>: " + nErrCode);
			}

			function completeMsg() {
				DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
			}

			function completeAddFile() {
				$('#UploadBtn').html('<%=_TEX.T("UploadFilePc.AddtImg")%>');
			}

			function errorMsg(result) {
				if(result == -1) {
					// file size error
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>');
				} else if(result == -2) {
					// file type error
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>');
				} else {
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + data.result);
				}
			}
			<%if(nEditorId==0){%>
			$(function() {
				initUpdateFile(<%=cResults.m_nUserId%>, <%=cResults.m_nContentId%>);
			});
			<%}else if(nEditorId==1){%>
			$(function() {
				$('#PasteZone').sortable();
				initUpdatePaste(<%=cResults.m_nUserId%>, <%=cResults.m_nContentId%>);
			});
			<%}%>
		</script>

		<style>
			body {padding-top: 83px !important;}

		<%if(nEditorId==0){%>
			.qq-gallery.qq-uploader {width: 100%;box-sizing: border-box; margin: 0; border: none; padding: 0; min-height: 113px; background: #fff; max-height: none;}
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
			#FineUploaderPane { display:visible; }
		<%}else if(nEditorId==1){%>
			<%if(!Util.isSmartPhone(request)) {%>
			.PasteZone {min-height: 193px;}
			.UploadFile .InputFile {margin: 8px; height: 177px; width: 177px;}
			<%}%>
		<%}%>
		</style>
		<%if(nEditorId==0){%>
		<!-- 画像並び替え用 -->
		<script src="/js/jquery-ui.js"></script>
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
			<%if(nEditorId==0){%>
				<li><a class="TabMenuItem Selected" href="/UpdateFilePcV.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_cContent.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.File")%></a></li>
			<%}else if(nEditorId==1){%>
				<li><a class="TabMenuItem Selected" href="/UpdatePastePcV.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a></li>
			<%}%>
			</ul>
		</nav>

		<article class="Wrapper">
			<div class="UploadFile">
				<%if(nEditorId==0){%>
				<div id="jQueryUploaderPane" class="TimeLineIllustCmd">
				</div>
				<!-- 元々の方式 -->
				<div id="FineUploaderPane" class="TimeLineIllustCmd">
					<span id="file-drop-area"></span>
					<span id="TotalSize" class="TotalSize">(jpeg|png|gif, 200files, total 50MByte)</span>
					<a id="TimeLineAddImage" class="SelectImageBtn BtnBase Rev" href="javascript:void(0)">
						<i class="far fa-images"></i>
						<span id="UploadBtn"><%=_TEX.T("UploadFilePc.SelectImg")%></span>
					</a>
				</div>
				<%}else if(nEditorId==1){%>
				<div class="TimeLineIllustCmd">
					<div id="PasteZone" class="PasteZone"></div>
					<span id="TotalSize" class="TotalSize">(multi ver. 0.2beta. 10pastes)</span>
					<div id="TimeLineAddImage" class="SelectImageBtn BtnBase Rev" contenteditable>
						<i class="fas fa-paste"></i>
						<%=(Util.isSmartPhone(request))?_TEX.T("UploadFilePc.PasteImg.SP"):_TEX.T("UploadFilePc.PasteImg")%>
					</div>
				</div>
				<%}%>

				<div class="CategorDesc">
					<select id="EditCategory">
						<%for(int nCategoryId : Common.CATEGORY_ID) {%>
						<option value="<%=nCategoryId%>" <%if(nCategoryId==cResults.m_cContent.m_nCategoryId){%>selected<%}%>><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></option>
						<%}%>
					</select>
				</div>
				<div class="Description">
					<textarea id="EditDescription" class="EditDescription" maxlength="200" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"><%=cResults.m_cContent.m_strDescription%></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum">200</div>
				</div>
				<div class="TagList">
					<input id="EditTagList" class="EditTagList" type="text" maxlength="100" placeholder="<%=_TEX.T("IllustV.Description.Tag")%>" onkeyup="DispTagListCharNum()" <%if(!cResults.m_cContent.m_strTagList.isEmpty()){%>value="<%=Common.ToStringHtml(cResults.m_cContent.m_strTagList)%>"<%}%> />
					<div id="EditTagListCharNum" class="TagListCharNum">100</div>
				</div>
				<div class="UoloadCmdOption">
					<input id="ContentOpenId" value="<%=cResults.m_cContent.m_nOpenId%>" type="hidden"/>
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Publish")%></div>
						<div class="OptionPublish">
							<select id="EditPublish" class="EditPublish" onchange="updatePublish(<%=cCheckLogin.m_nUserId%>)">
								<%for(int nPublishId : PUBLISH_ID) {
									if(7<=nPublishId && nPublishId<=10 && !cTweet.m_bIsTweetEnable){
										continue;
									}
								%>
								<option value="<%=nPublishId%>" <%if(nPublishId==cResults.m_cContent.m_nPublishId){%>selected<%}%> ><%=_TEX.T(String.format("Publish.C%d", nPublishId))%></option>
								<%}%>
							</select>
						</div>
					</div>
					<div id="ItemPassword" class="OptionItem"
						<%if(cResults.m_cContent.m_nPublishId!=Common.PUBLISH_ID_PASS){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<input id="EditPassword" class="EditPassword" type="text" maxlength="16"
								<%if(cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_PASS){%>value="<%=cResults.m_cContent.m_strPassword%>"<%}%>
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
								<script>twtterListRateLimiteExceededMsg()</script>
								<%}else if(nTwLstRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){%>
								<script>twtterListInvalidTokenMsg()</script>
								<%}else if(nTwLstRet==CTweet.ERR_OTHER){%>
								<script>twtterListOtherErrMsg()</script>
								<%}else if(nTwLstRet==CTweet.OK && !bTwListFound){%>
								<script>twtterListNotFoundMsg()</script>
								<%}%>
							<%}%>
						</div>
					</div>
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
							String strStartDateTime = Common.ToYMDHMString(cResults.m_cContent.m_timeUploadDate);
							String strEndDateTime = Common.ToYMDHMString(cResults.m_cContent.m_timeEndDate);
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
						<div class="OptionLabel"><%=_TEX.T("Cheer.Upload.Label")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionCheerNg" id="OptionCheerNg" value="0" <%if(cResults.m_cContent.m_bCheerNg){%>checked<%}%> />
							<label class="onoffswitch-label" for="OptionCheerNg">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
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
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionTweet" id="OptionTweet" value="0" onchange="updateTweetButton()" <%if(cResults.m_cContent.m_nTweetWhenPublished%2==1){%>checked<%}%> />
							<label class="onoffswitch-label" for="OptionTweet">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="ImageSwitch" class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.TweetImage")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionImage" id="OptionImage" value="0" <%if(cResults.m_cContent.m_nTweetWhenPublished==3){%>checked<%}%>/>
							<label class="onoffswitch-label" for="OptionImage">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
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

				<div class="UoloadCmd">
				<%if(nEditorId==0){%>
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UpdateFile(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_nContentId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				<%}else if(nEditorId==1){%>
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UpdatePaste(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_nContentId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				<%}%>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>