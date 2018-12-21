<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<script src="/js/upload-16.js" type="text/javascript"></script>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuUpload').addClass('Selected');
		});
		</script>

		<script>
			function startMsg() {
				DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
			}

			function completeMsg() {
				DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
			}

			function errorMsg(result) {
				if(data.result == -1) {
					// file size error
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>');
				} else if(data.result == -2) {
					// file type error
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>');
				} else {
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + data.result);
				}
			}

			$(function() {
				initUploadPaste();
			});
		</script>

		<style>
			body {padding-top: 83px !important;}
			<%if(!Util.isSmartPhone(request)) {%>
			.PasteZone {min-height: 193px;}
			.UploadFile .InputFile {margin: 8px; height: 177px; width: 177px;}
			<%}%>
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>

		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="javascript:void(0);" onclick="OnChangeTab(0)"><%=_TEX.T("UploadFilePc.Tab.File")%></a>
				<a class="TabMenuItem Selected" href="javascript:void(0);" onclick="OnChangeTab(1)"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="Wrapper">
			<div class="UploadFile">
				<div class="TimeLineIllustCmd">
					<div id="PasteZone" class="PasteZone"></div>
					<span id="TotalSize" class="TotalSize">(multi ver. 0.2beta. 10pastes)</span>
					<div id="TimeLineAddImage" class="SelectImageBtn BtnBase Rev" contenteditable>
						<i class="fas fa-paste"></i>
						<%=(Util.isSmartPhone(request))?_TEX.T("UploadFilePc.PasteImg.SP"):_TEX.T("UploadFilePc.PasteImg")%>
					</div>
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
					<input id="EditTagList" class="EditTagList" type="text" maxlength="100" placeholder="<%=_TEX.T("IllustV.Description.Tag")%>" onkeyup="DispTagListCharNum()" />
					<div id="EditTagListCharNum" class="TagListCharNum">100</div>
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
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UploadPaste(<%=cCheckLogin.m_nUserId%>)"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				</div>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>