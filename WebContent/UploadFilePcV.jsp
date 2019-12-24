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

String strTag = "";
try {
	request.setCharacterEncoding("UTF-8");
	strTag = Common.TrimAll(request.getParameter("TAG"));
} catch(Exception e) {
	;
}

/*
Cookie cCookies[] = request.getCookies();
if(cCookies != null) {
	for(int i = 0; i < cCookies.length; i++) {
		if(cCookies[i].getName().equals("MOD")) {
			int nDispMode = Common.ToInt(cCookies[i].getValue());
			if(nDispMode == 1) {
				String strUrl = "/UploadPastePcV.jsp";
				if(!strTag.isEmpty()) {strUrl+="?TAG="+URLEncoder.encode(strTag, "UTF-8");}
				response.sendRedirect(strUrl);
				return;
			}
		}
	}
}
*/
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<link href="/js/flatpickr/flatpickr.min.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="/js/flatpickr/flatpickr.min.js"></script>
		<script src="/js/upload-20.js" type="text/javascript"></script>

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
				DispMsgStatic('<%=_TEX.T("EditIllustVCommon.Uploading")%>');
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

			function completeMsg() {
				DispMsg('<%=_TEX.T("EditIllustVCommon.Uploaded")%>');
			}

			function completeAddFile() {
				$('#UploadBtn').html('<%=_TEX.T("UploadFilePc.AddtImg")%>');
			}

			$(function(){
				initUploadFile();
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
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/UploadFilePcV.jsp?TAG=<%=strTag%>"><%=_TEX.T("UploadFilePc.Tab.File")%></a></li>
				<li><a class="TabMenuItem" href="/UploadPastePcV.jsp?TAG=<%=strTag%>"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper">
			<div class="UploadFile">
				<div class="TimeLineIllustCmd">
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
						<option value="<%=nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", nCategoryId))%></option>
						<%}%>
					</select>
				</div>
				<div class="Description">
					<textarea id="EditDescription" class="EditDescription" maxlength="200" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum">200</div>
				</div>
				<div class="TagList">
					<input id="EditTagList" class="EditTagList" type="text" maxlength="100" placeholder="<%=_TEX.T("IllustV.Description.Tag")%>" onkeyup="DispTagListCharNum()" <%if(!strTag.isEmpty()){%>value="#<%=Common.ToStringHtml(strTag)%>"<%}%> />
					<div id="EditTagListCharNum" class="TagListCharNum">100</div>
				</div>
				<div class="UoloadCmdOption">
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Publish")%></div>
						<div class="OptionPublish">
							<select id="EditPublish" class="EditPublish" onchange="updatePublish()">
								<option value="<%=Common.PUBLISH_ID_ALL%>" selected="selected"><%=_TEX.T("UploadFilePc.Option.Publish.All")%></option>
								<option value="<%=Common.PUBLISH_ID_R15%>"><%=_TEX.T("UploadFilePc.Option.Publish.R15")%></option>
								<option value="<%=Common.PUBLISH_ID_R18%>"><%=_TEX.T("UploadFilePc.Option.Publish.R18")%></option>
								<option value="<%=Common.PUBLISH_ID_PASS%>"><%=_TEX.T("UploadFilePc.Option.Publish.Pass")%></option>
								<option value="<%=Common.PUBLISH_ID_LOGIN%>"><%=_TEX.T("UploadFilePc.Option.Publish.Login")%></option>
								<option value="<%=Common.PUBLISH_ID_FOLLOWER%>"><%=_TEX.T("UploadFilePc.Option.Publish.Follower")%></option>
								<%if(cTweet.m_bIsTweetEnable){%>
								<option value="<%=Common.PUBLISH_ID_T_FOLLOWER%>"><%=_TEX.T("UploadFilePc.Option.Publish.T_Follower")%></option>
								<option value="<%=Common.PUBLISH_ID_T_FOLLOW%>"><%=_TEX.T("UploadFilePc.Option.Publish.T_Follow")%></option>
								<option value="<%=Common.PUBLISH_ID_T_EACH%>"><%=_TEX.T("UploadFilePc.Option.Publish.T_Each")%></option>
								<%if(cTweet.m_listOpenList!=null && cTweet.m_listOpenList.size()>0){%>
								<option value="<%=Common.PUBLISH_ID_T_LIST%>"><%=_TEX.T("UploadFilePc.Option.Publish.T_List")%></option>
								<%}%>
								<%}%>
								<option value="<%=Common.PUBLISH_ID_LIMITED_TIME%>"><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Title")%></option>
								<option value="<%=Common.PUBLISH_ID_HIDDEN%>"><%=_TEX.T("UploadFilePc.Option.Publish.Hidden")%></option>
							</select>
						</div>
					</div>
					<div id="ItemPassword" class="OptionItem" style="display: none;">
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<input id="EditPassword" class="EditPassword" type="text" maxlength="16" placeholder="<%=_TEX.T("UploadFilePc.Option.Publish.Pass.Input")%>" />
						</div>
					</div>
					<%if(cTweet.m_listOpenList!=null && cTweet.m_listOpenList.size()>0){%>
					<div id="ItemTwitterList" class="OptionItem" style="display: none;">
						<div class="OptionLabel"></div>
						<div class="OptionPublish">
							<select id="EditTwitterList" class="EditPublish">
								<%for(UserList l:cTweet.m_listOpenList){%>
								<option value="<%=l.getId()%>"><%=l.getName()%></option>
								<%}%>
							</select>
						</div>
					</div>
					<%}%>
					
					<div id="ItemTimeLimited" class="OptionItem" style="display: none;">
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
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UploadFile(<%=cCheckLogin.m_nUserId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>