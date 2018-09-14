<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

if(cCheckLogin.m_strNickName.equals("no_name")) {
	getServletContext().getRequestDispatcher("/SetUserNameV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<script src="/js/paste.js" type="text/javascript"></script>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuUpload').addClass('Selected');
		});
		</script>

		<script>
			$.ajaxSetup({
				cache : false,
			});
			function UploadFile() {
				DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
				var nCategory = $('#EditCategory').val();
				var strDescription = $.trim($("#EditDescription").val());
				var nTweet = ($('#OptionTweet').prop('checked'))?1:0;
				var strEncodeImg = $('#imgView').attr('src').replace('data:image/png;base64,', '');
				setTweetSetting($('#OptionTweet').prop('checked'));

				$.ajaxSingle({
					"type": "post",
					"data": {
						"UID":<%=cCheckLogin.m_nUserId%>,
						"DES":strDescription,
						"TWI":nTweet,
						"CAT":nCategory,
						"DATA" : strEncodeImg},
					"url": "/f/UploadPasteF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result > 0) {
							// complete
							DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
							setTimeout(function(){
								location.href="/MyHomePcV.jsp";
							}, 1000);
						} else if(data.result == -1) {
							// file size error
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>');
						} else if(data.result == -2) {
							// file type error
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>');
						} else {
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + data.result);
						}
					}
				});
			}

			function DispDescCharNum() {
				var nCharNum = 200 - $("#EditDescription").val().length;
				$("#DescriptionCharNum").html(nCharNum);
			}

			function OnChangeTab(nIndex) {
				setCookie("MOD", nIndex);
				if(nIndex==0) {
					window.location.href="/UploadFilePcV.jsp?TS=<%=System.currentTimeMillis()%>";
				}else{
					window.location.href="/UploadPastePcV.jsp?TS=<%=System.currentTimeMillis()%>";
				}
			}

			function setTweetSetting(val) {
				setLocalStrage('upload_tweet', val);
			}

			function getTweetSetting() {
				var upload_tweet = getLocalStrage('upload_tweet');
				if(upload_tweet) return true;
				return false;
			}

			$(function() {
				$('#OptionTweet').prop('checked', getTweetSetting());

				$('#InputFile').pastableNonInputable();
				$('#InputFile').on('pasteImage', function(ev, data){
					$('.OrgMessage').hide();
					$('#imgView').attr('src', data.dataURL).show();
				}).on('pasteImageError', function(ev, data){
					if(data.url){
						alert('error data : ' + data.url)
					}
				}).on('pasteText', function(ev, data){
					;
				});
				//$('#InputFile').focus();
			});
		</script>

		<style>
			#InputFile {border: solid 3px #eee;}
			#InputFile:hover {border-color: #ccc;}
			#InputFile.pastable-focus {border-color: #5bd;}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<div class="TabMenu">
			<a class="TabMenuItem" href="javascript:void(0);" onclick="OnChangeTab(0)"><%=_TEX.T("UploadFilePc.Tab.File")%></a>
			<a class="TabMenuItem Selected" href="javascript:void(0);" onclick="OnChangeTab(1)"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div class="UploadFile">
				<div id="InputFile" class="InputFile">
					<div class="OrgMessage">
						<%=_TEX.T("UploadFilePc.PasteImg")%>
					</div>
					<img id="imgView" class="imgView" src="" />
				</div>
				<div class="CategorDesc">
					<select id="EditCategory">
						<option value="0"><%=_TEX.T("Category.C0")%></option>
						<option value="10"><%=_TEX.T("Category.C10")%></option>
						<option value="1"><%=_TEX.T("Category.C1")%></option>
						<option value="2"><%=_TEX.T("Category.C2")%></option>
						<option value="3"><%=_TEX.T("Category.C3")%></option>
						<option value="4"><%=_TEX.T("Category.C4")%></option>
						<option value="5"><%=_TEX.T("Category.C5")%></option>
						<option value="6"><%=_TEX.T("Category.C6")%></option>
						<option value="7"><%=_TEX.T("Category.C7")%></option>
						<option value="8"><%=_TEX.T("Category.C8")%></option>
						<option value="9"><%=_TEX.T("Category.C9")%></option>
					</select>
				</div>
				<div class="Description">
					<textarea id="EditDescription" class="EditDescription" maxlength="200" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum">200</div>
				</div>
				<div class="UoloadCmdOption">
					<div class="OptionItem">
						<div class="OptionLabel"><%=_TEX.T("UploadFilePc.Option.Tweet")%></div>
						<div class="onoffswitch OnOff">
							<input type="checkbox" class="onoffswitch-checkbox" name="OptionTweet" id="OptionTweet" value="0" />
							<label class="onoffswitch-label" for="OptionTweet">
								<span class="onoffswitch-inner"></span>
								<span class="onoffswitch-switch"></span>
							</label>
						</div>
					</div>
				</div>
				<div class="UoloadCmd">
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UploadFile()"><%=_TEX.T("UploadFilePc.UploadBtn")%></a>
				</div>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>