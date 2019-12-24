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

CTweet cTweet = new CTweet();
boolean bTwRet = cTweet.GetResults(cCheckLogin.m_nUserId);
if(bTwRet && cTweet.m_bIsTweetEnable){
	cTweet.GetMyOpenLists();
}

IllustViewC cResults = new IllustViewC();
cResults.getParam(request);

if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
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
		11,			// 期間限定
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
		<script src="/js/upload-20.js" type="text/javascript"></script>
		<script src="/js/update-02.js" type="text/javascript"></script>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuUpload').addClass('Selected');
		});
		</script>

		<link href="/js/fine-uploader/fine-uploader-gallery-0.3.css" type="text/css" rel="stylesheet" />
		<%@ include file="/js/fine-uploader/templates/gallery-0.2.html"%>
		<script type="text/javascript" src="/js/fine-uploader/fine-uploader.js"></script>
		<script>
			function startMsg() {
				DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
			}

			function errorMsg() {
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + data.content_id);
			}

			function twtterListNotFoundMsg(){
				DispMsg('<%=_TEX.T("EditIllustVCommon.Update.Error.TwListNotFond")%>');
			}

			function completeMsg() {
				DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
			}

			function completeAddFile() {
				$('#UploadBtn').html('<%=_TEX.T("UploadFilePc.AddtImg")%>');
			}

			$(function() {
				initUpdateFile(<%=cResults.m_nUserId%>, <%=cResults.m_nContentId%>);
			});
		</script>

		<style>
			body {padding-top: 83px !important;}

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
		</style>

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
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/UpdateFilePcV.jsp?ID=<%=cResults.m_nUserId%>&TD=<%=cResults.m_cContent.m_nContentId%>"><%=_TEX.T("UploadFilePc.Tab.File")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper">
			<div class="UploadFile">
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
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Publish")%></div>
						<div class="OptionPublish">
							<select id="EditPublish" class="EditPublish" onchange="updatePublish()">
								<%for(int nPublishId : PUBLISH_ID) {%>
								<option value="<%=nPublishId%>" <%if(nPublishId==cResults.m_cContent.m_nPublishId){%>selected<%}%>><%=_TEX.T(String.format("Publish.C%d", nPublishId))%></option>
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
					<%if(cTweet.m_listOpenList!=null && cTweet.m_listOpenList.size()>0){%>
					<div id="ItemTwitterList" class="OptionItem"
						<%if(cResults.m_cContent.m_nPublishId!=Common.PUBLISH_ID_T_LIST){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<select id="EditTwitterList" class="EditPublish">
								<%
								boolean bTwListFound = false;
								for(UserList l:cTweet.m_listOpenList){
								%>
								<option value="<%=l.getId()%>"
									<%if(!cResults.m_cContent.m_strListId.isEmpty() && l.getId()==Long.parseLong(cResults.m_cContent.m_strListId)){ 
										bTwListFound = true;
										%> selected<%}%>　><%=l.getName()%></option>
								<%}%>
							</select>
							<%if(cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_T_LIST && !bTwListFound){%>
							<script>twtterListNotFoundMsg()</script>
							<%}%>
						</div>
					</div>
					<%}%>
					<div id="ItemTimeLimited" class="OptionItem" 
						<%if(cResults.m_cContent.m_nPublishId!=Common.PUBLISH_ID_LIMITED_TIME){%>style="display: none;"<%}%>
						>
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<%if(Util.isSmartPhone(request)) {%>
							<div style="display: block;">
								<span><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Start")%></span>
								<input id="EditTimeLimitedStart" class="EditTimeLimited" type="text" maxlength="15" placeholder="<%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Start")%>" />
							</div>
							<div style="display: block;">
								<span><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.End")%></span>
								<input id="EditTimeLimitedEnd" class="EditTimeLimited" type="text" maxlength="15" placeholder="<%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.End")%>" />
							</div>
							<%}else{%>
								<input id="EditTimeLimitedStart" class="EditTimeLimited" type="text" maxlength="15" placeholder="<%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Start")%>" />
								<input id="EditTimeLimitedEnd" class="EditTimeLimited" type="text" maxlength="15" placeholder="<%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.End")%>" />
							<%}%>
						</div>
						<%if(cResults.m_cContent.m_nPublishId==Common.PUBLISH_ID_LIMITED_TIME){%>
						<script>
							initStartDatetime("<%=Common.ToYMDHMString(cResults.m_cContent.m_timeUploadDate)%>");
							initEndDatetime("<%=Common.ToYMDHMString(cResults.m_cContent.m_timeEndDate)%>");
						</script>
						<%}%>
					</div>
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Recent")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionRecent" id="OptionRecent" value="0" <%if(cResults.m_cContent.m_nOpenId==1){%>checked<%}%> />
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
					<div id="ImageSwitch" class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.TweetImage")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionImage" id="OptionImage" value="0" />
							<label class="onoffswitch-label" for="OptionImage">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
				</div>
				<div class="UoloadCmd">
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UpdateFile(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_nContentId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>