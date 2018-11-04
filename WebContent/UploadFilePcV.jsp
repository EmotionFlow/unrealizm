<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

Cookie cCookies[] = request.getCookies();
if(cCookies != null) {
	for(int i = 0; i < cCookies.length; i++) {
		if(cCookies[i].getName().equals("MOD")) {
			int nDispMode = Common.ToInt(cCookies[i].getValue());
			if(nDispMode == 1) {
				response.sendRedirect("/UploadPastePcV.jsp");
				return;
			}
		}
	}
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<script src="/js/upload-14.js" type="text/javascript"></script>
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

			function completeMsg() {
				DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
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
		<div id="DispMsg"></div>

		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem Selected" href="javascript:void(0);" onclick="OnChangeTab(0)"><%=_TEX.T("UploadFilePc.Tab.File")%></a>
				<a class="TabMenuItem" href="javascript:void(0);" onclick="OnChangeTab(1)"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
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
				<div class="UoloadCmdOption">
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
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.OneCushion")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionOneCushion" id="OptionOneCushion" value="0" onchange="updateOneCushionButton()" />
							<label class="onoffswitch-label" for="OptionOneCushion">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
					<div id="R18Switch" class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.R18")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionR18" id="OptionR18" value="0" />
							<label class="onoffswitch-label" for="OptionR18">
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
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>