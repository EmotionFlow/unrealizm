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


if(cCheckLogin.m_strNickName.equals("no_name")) {
	getServletContext().getRequestDispatcher("/SetUserNameV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<script src="/js/jquery.upload-1.0.2.min.js" type="text/javascript"></script>
		<script src="/js/exif.js" type="text/javascript"></script>
		<script src="/js/megapix-image.js" type="text/javascript"></script>
		<script src="/js/upload-01.js" type="text/javascript"></script>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("UploadFilePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuUpload').addClass('Selected');
		});
		</script>

		<script>
			function UploadFile() {
				DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
				var nCategory = $('#EditCategory').val();
				var strDescription = $.trim($("#EditDescription").val());
				var nTweet = ($('#OptionTweet').prop('checked'))?1:0;
				setTweetSetting($('#OptionTweet').prop('checked'));
				$("#file_thumb").upload(
					'/f/UploadFileF.jsp',
					{
						"UID":<%=cCheckLogin.m_nUserId%>,
						"DES":strDescription,
						"TWI":nTweet,
						"CAT":nCategory
					},
					function(res) {
						var nResId = parseInt($.trim(res), 10);
						if(nResId > 0) {
							// complete
							DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
							setTimeout(function(){
								location.href="/MyHomePcV.jsp";
							}, 1000);
						} else if(nResId == -1) {
							// file size error
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>');
						} else if(nResId == -2) {
							// file type error
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>');
						} else {
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + nResId);
						}
					},
					'html'
				);
			}

			$(function() {
				initUploadFile();
			});
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<div class="TabMenu">
			<a class="TabMenuItem Selected" href="javascript:void(0);" onclick="OnChangeTab(0)"><%=_TEX.T("UploadFilePc.Tab.File")%></a>
			<a class="TabMenuItem" href="javascript:void(0);" onclick="OnChangeTab(1)"><%=_TEX.T("UploadFilePc.Tab.Paste")%></a>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div class="UploadFile">
				<div class="InputFile">
					<div class="OrgMessage">
						<span class="typcn typcn-plus-outline"></span><%=_TEX.T("UploadFilePc.SelectImg")%>
					</div>
					<img id="imgView" class="imgView" src="" />
					<input id="file_thumb" type="file" name="file_thumb" />
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