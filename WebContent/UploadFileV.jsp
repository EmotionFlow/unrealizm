<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartAnalogicoV.jsp");
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
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<script src="/js/jquery.upload-1.0.2.min.js" type="text/javascript"></script>
		<script src="/js/exif.js" type="text/javascript"></script>
		<script src="/js/megapix-image.js" type="text/javascript"></script>
		<title>upload</title>
		<script>
			$.ajaxSetup({
				cache : false,
			});
			function UploadFile() {
				DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
				var strDescription = $.trim($("#EditDescription").val());
				$("#file_thumb").upload('/f/UploadFileF.jsp', {
					"UID":<%=cCheckLogin.m_nUserId%>,
					"DES":strDescription},
						function(res) {
							var nResId = parseInt($.trim(res), 10);
							if(nResId > 0) {
								// complete
								DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
								sendObjectMessage("uploaded");
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
						'html');
			}

			function DispDescCharNum() {
				var nCharNum = 200 - $("#EditDescription").val().length;
				$("#DescriptionCharNum").html(nCharNum);
			}

			$(function() {
				$('#file_thumb').on("change",function(){
					DispMsgStatic('画像ファイル読込中...');
					var file = $(this).prop("files")[0];
					if (this.files.length && file.type.match('image.*')) {
						EXIF.getData(file, function(){
							var orientation = file.exifdata.Orientation;
							var mpImg = new MegaPixImage(file);
							mpImg.render($("#imgView")[0], { orientation: orientation });
							$('.OrgMessage').hide();
							$('#imgView').css("display", "block");
							HideMsgStatic();
						});
					} else {
						HideMsgStatic();
					}
				});
			});
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<div class="Wrapper">
			<div class="UploadFile">
				<div class="InputFile">
					<div class="OrgMessage">
						<span class="typcn typcn-plus-outline"></span>画像を選択
					</div>
					<img id="imgView" class="imgView" src="" />
					<input id="file_thumb" type="file" name="file_thumb" />
				</div>
				<div class="Description">
					<textarea id="EditDescription" class="EditDescription" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum">200</div>
				</div>
				<div class="UoloadCmd">
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UploadFile()">アップロード</a>
				</div>
			</div>
		</div>
	</body>
</html>