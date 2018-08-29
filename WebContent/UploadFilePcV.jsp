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
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<script src="/js/jquery.upload-1.0.2.min.js" type="text/javascript"></script>
		<script src="/js/exif.js" type="text/javascript"></script>
		<script src="/js/megapix-image.js" type="text/javascript"></script>
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
				var nCategory = $('input:radio[name="CAT"]:checked').val();
				var strDescription = $.trim($("#EditDescription").val());
				var nTweet = ($('#OptionTweet').prop('checked'))?1:0;
				console.log(nCategory, strDescription, nTweet);
				return;
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
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div class="UploadFile">
				<div class="InputFile">
					<div class="OrgMessage">
						<span class="typcn typcn-plus-outline"></span>画像を選択
					</div>
					<img id="imgView" class="imgView" src="" />
					<input id="file_thumb" type="file" name="file_thumb" />
				</div>
				<div class="CategorDesc">
					<label><input class="CategoryRadio" type="radio" name="CAT" value="0"><span class="CategoryLabel"><%=_TEX.T("Category.C0")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="1"><span class="CategoryLabel"><%=_TEX.T("Category.C1")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="2"><span class="CategoryLabel"><%=_TEX.T("Category.C2")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="3"><span class="CategoryLabel"><%=_TEX.T("Category.C3")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="4"><span class="CategoryLabel"><%=_TEX.T("Category.C4")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="5"><span class="CategoryLabel"><%=_TEX.T("Category.C5")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="6"><span class="CategoryLabel"><%=_TEX.T("Category.C6")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="7"><span class="CategoryLabel"><%=_TEX.T("Category.C7")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="8"><span class="CategoryLabel"><%=_TEX.T("Category.C8")%></span></label>
					<label><input class="CategoryRadio" type="radio" name="CAT" value="9"><span class="CategoryLabel"><%=_TEX.T("Category.C9")%></span></label>
				</div>
				<div class="Description">
					<textarea id="EditDescription" class="EditDescription" maxlength="200" placeholder="<%=_TEX.T("IllustV.Description.Add")%>" onkeyup="DispDescCharNum()"></textarea>
					<div id="DescriptionCharNum" class="DescriptionCharNum">200</div>
				</div>
				<div class="UoloadCmdOption">
					<div class="OptionItem">
						<div class="OptionLabel">Twitterに投稿</div>
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
					<a class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="UploadFile()">アップロード</a>
				</div>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>