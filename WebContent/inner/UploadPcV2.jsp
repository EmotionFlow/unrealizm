<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jp.pipa.poipiku.util.CTweet"%>
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
		<link href="/css/upload-206-1.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="/js/flatpickr/flatpickr.min.js"></script>
		<script src="/js/upload-50-2.js" type="text/javascript"></script>

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
			let transList = {
				'Description' : {
					'default': '',
					<%for(UserLocale userLocale: SupportedLocales.list) {%>
					'<%=userLocale.id%>': '',
					<%}%>
				}
			}

			let selected = {
				'Description' : 'default',
			}

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
				switchTransTxt('Description', 'default');
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
				initUploadParams();
				DispDescCharNum();
			});
		</script>

		<style>
			body {padding-top: 79px !important; background-color: #f5f5f5; color: #6d6965}
			<%if(nEditorId==Common.EDITOR_UPLOAD){%>
			.qq-gallery.qq-uploader {width: 100%;box-sizing: border-box; margin: 0; border: none; padding: 0; min-height: 113px; background: #fff; color: #6d6965; max-height: none; border: solid;}
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
				width: 100%;
				height: 15px;
				margin-right: 3px;
				background: url(/img/loading.gif);
				background-size: contain;
				background-repeat: no-repeat;
				background-position: center;
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
						privateNote.setFooter('<%=_TEX.T("PrivateNote.Footer")%>');
					</script>
				</div>

				<div class="Description">
					<div class="SettingListTitle WithLangSelector" style="text-align: right; display: <%=nEditorId==Common.EDITOR_TEXT?"none":""%>">
<%--					<div class="SettingListTitle WithLangSelector" style="text-align: right; <%=checkLogin.isStaff()?"":"display: none"%>">--%>
						<span class="SelectTransLang">
							<i class="fas fa-language" style="font-size: 20px;" onclick="showTransDescMsg();"></i>
							<select id="EditTransDescLang" style="font-size: 12px;" onchange="switchTransTxt('Description', $(this).val())">
								<option value="default" selected><%=_TEX.T("EditGenreInfo.Translation.Default")%></option>
								<%for(UserLocale userLocale: SupportedLocales.list) {%>
								<option value="<%=userLocale.id%>"><%=userLocale.label%></option>
								<%}%>
							</select>
						</span>
					</div>
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
					<div class="TagListCharNum"><span><%=_TEX.T("IllustV.Description.Tag.Info")%></span><span id="EditTagListCharNum">100</span></div>
				</div>


				<div class="UoloadCmdOption">
					<style>
                        .UploadFile .UoloadCmdOption .OptionItem.Sub {
							padding: 4px 0;
                        }


                        /* Switch starts here */
                        .rocker {
                            display: inline-block;
                            position: relative;
                            font-size: 1em;
                            text-align: center;
                            color: #888;
                            width: 100%;
                            height: 2.5em;
                            padding: 4px 0;
                            overflow: hidden;
                            margin: 0 12px;
                        }

                        .rocker.sub {
                            font-size: 0.9em;
                            height: 2em;
                            padding: 3px 0;
                            margin: -5px 12px 0 12px;
                        }

                        .rocker::before {
                            content: "";
                            position: absolute;
                            background-color: #999;
                        }

                        .rocker input {
                            opacity: 0;
                            width: 0;
                            height: 0;
                        }

                        .switch-left,
                        .switch-right {
                            cursor: pointer;
                            position: absolute;
							top: 0;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            width: 50%;
							height: 100%;
                            transition: 0.3s;
                        }

                        .switch-left {
                            background-color: #ddd;
							border-radius: 4px 0 0 4px;
                        }

                        .switch-right {
                            right: 0;
                            background-color: #3498da;
                            color: #fff;
                            border-radius: 0 4px 4px 0;
                        }

                        input:checked + .switch-left {
                            background-color: #3498da;
                            color: #fff;
                        }

                        input:checked + .switch-left + .switch-right {
                            background-color: #ddd;
                            color: #888;
                            right: 0;
                        }

                        /* Keyboard Users */
                        input:focus + .switch-left {
                            color: #888;
                        }

                        input:checked:focus + .switch-left {
                            color: #fff;
                        }

                        input:focus + .switch-left + .switch-right {
                            color: #fff;
                        }

                        input:checked:focus + .switch-left + .switch-right {
                            color: #888;
                        }

                        .OptionItem input[type=radio] {
                            display: none;
                        }
                        .OptionItem input[type=radio]:checked + label {
                            border: 2px solid #00A0BA;
                        }
                        .OptionItem input[type=radio] + label {
                            border: 2px solid rgba(0,0,0,0);
                        }

                        .OptionToggle {
                            width: 100%;
                            height: 35px;
                            margin: 7px;
                            display: flex;
                            border: solid 1px #3498da;
                            border-radius: 4px;
                            text-align: center;
                            line-height: 35px;
                            color: #a7a7a7;
                        }
                        .OptionToggle > div{
                            width: 50%;
                            text-align: center;
                        }
                        .OptionToggle .Selected {
                            background-color: #3498da;
                            color: #ffffff;
                        }
						#ItemOneCushionVal {
							padding-top: 0;
                            justify-content: center;
						}
						.OptionPublishOneCushionList {
							display: flex;
                            justify-content: center;
                            margin:	0 12px;
						}
						.OptionPublishOneCushion {
                            display: flex;
                            flex-direction: column;
                            background: #fff;
                            margin: 4px 2px;
                            border-radius: 4px;
						}
                        .OneCushionImage{
                            display: block;
                            width: 148px;
                            height: 65px;
							border-radius: 4px;
                            background-size: 90%;
                        }
                        .OneCushionName{
                            display: block;
							width: 100%;
							font-size: 12px;
                            text-align: center;
						}
                        .OneCushionImage.OneCushion {
                            background-image: url("/img/warning.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }
                        .OneCushionImage.R18 {
                            background-image: url("/img/R-18.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }

                        .OptionPublishShowLimitList {
                            display: flex;
							justify-content: center;
                            margin:	0 12px;
                            flex-direction: row;
                            flex-wrap: wrap;
                        }
                        .OptionPublishShowLimit {
                            display: flex;
                            flex-direction: column;
							background: #fff;
                            margin: 2px 3px;
                            border-radius: 4px;
                        }
                        .ShowLimitImage {
                            display: block;
                            width: 148px;
                            height: 65px;
                            background-size: 90%;
                        }
                        .ShowLimitImage.PoipikuLogin {
                            background-image: url("/img/publish_login.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }
                        .ShowLimitImage.PoipikuFollower {
                            background-image: url("/img/publish_follower.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }
                        .ShowLimitImage.TwitterFollower {
                            background-image: url("/img/publish_t_follower.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }
                        .ShowLimitImage.TwitterList {
                            background-image: url("/img/publish_t_list.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }
                        .ShowLimitImage.TwitterFollowee {
                            background-image: url("/img/publish_t_follow.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }
                        .ShowLimitImage.TwitterEach {
                            background-image: url("/img/publish_t_each.png_360.jpg");
                            background-repeat: no-repeat;
                            background-position: 50% 50%;
                        }
                        .ShowLimitName {
                            display: block;
                            width: 100%;
							font-size: 12px;
                            text-align: center;
                        }
                        .UploadFile .UoloadCmdOption .OptionOther {
                            border-top: 1px solid rgb(172, 172, 172);
						}
                        #TwitterList {
							text-align: center;
                        }
                        #TwitterList select{
                            width: 145px;
                            margin: 2px auto;
                            font-size: 12px;
                            padding: 1px;
						}
						#TwitterListNotFound {
                            display: block;
                            width: 140px;
                            font-size: 11px;
                            text-align: left;
						}
					</style>

					<div class="OptionItem" style="font-weight: bold;">
						<label class="rocker">
							<input id="OptionPublish" type="checkbox" checked>
							<span class="switch-left">公開する</span>
							<span class="switch-right">公開しない</span>
						</label>
					</div>
					<div class="OptionItem">
						<label class="rocker" onclick="updateOptionLimitedTimePublish2()">
							<input id="OptionLimitedTimePublish" type="checkbox" checked>
							<span class="switch-left">常時</span>
							<span class="switch-right">期間指定</span>
						</label>
					</div>
					<div class="OptionItem" id="ItemTimeLimitedVal" style="padding-top: 0; display: none;">
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
						<label class="rocker" onclick="updateOptionPublishOneCushion()">
							<input id="OptionPublishOneCushion" type="checkbox" checked>
							<span class="switch-left">配慮・NSFW不要</span>
							<span class="switch-right">指定する</span>
						</label>
					</div>
					<div class="OptionItem" id="ItemOneCushionVal" style="display: none;">
						<div class="OptionPublishOneCushionList">
							<input type="radio" name="RadioOneCushionVal" value="OneCushion" id="RadioOneCushion">
							<label for="RadioOneCushion" class="OptionPublishOneCushion">
								<span class="OneCushionImage OneCushion"></span>
								<span class="OneCushionName">ワンクッション</span>
							</label>
							<input type="radio" name="RadioOneCushionVal" value="R18" id="RadioR18">
							<label for="RadioR18" class="OptionPublishOneCushion">
								<span class="OneCushionImage R18"></span>
								<span class="OneCushionName">R18</span>
							</label>
						</div>
					</div>

					<div class="OptionItem">
						<label class="rocker" onclick="updateOptionPublishShowLimit()">
							<input id="OptionPublishShowLimit" type="checkbox" checked>
							<span class="switch-left">誰でも閲覧OK</span>
							<span class="switch-right">限定する</span>
						</label>
					</div>
					<div class="OptionItem" id="ItemShowLimitVal" style="padding-top: 0; display: none;">
						<div class="OptionPublishShowLimitList">
							<input type="radio" name="RadioShowLimitVal" value="PoipikuLogin" id="RadioPoipikuLogin">
							<label for="RadioPoipikuLogin" class="OptionPublishShowLimit">
								<span class="ShowLimitImage PoipikuLogin"></span>
								<span class="ShowLimitName">ログイン限定</span>
							</label>
							<input type="radio" name="RadioShowLimitVal" value="PoipikuFollower" id="RadioPoipikuFollower">
							<label for="RadioPoipikuFollower" class="OptionPublishShowLimit">
								<span class="ShowLimitImage PoipikuFollower"></span>
								<span class="ShowLimitName">こそフォロ限定</span>
							</label>
							<input type="radio" name="RadioShowLimitVal" value="TwitterFollower" id="RadioTwitterFollower">
							<label for="RadioTwitterFollower" class="OptionPublishShowLimit">
								<span class="ShowLimitImage TwitterFollower"></span>
								<span class="ShowLimitName"><i class="fab fa-twitter"></i>フォロワー限定</span>
							</label>
							<input type="radio" name="RadioShowLimitVal" value="TwitterList" id="RadioTwitterList">
							<label for="RadioTwitterList" class="OptionPublishShowLimit" onclick="updateMyTwitterListF(<%=checkLogin.m_nUserId%>)">
								<span class="ShowLimitImage TwitterList"></span>
								<span class="ShowLimitName"><i class="fab fa-twitter"></i>リスト限定</span>
								<span class="ShowLimitName" id="TwitterList">
									<span id="TwitterListLoading" style="display: none"></span>
									<span id="TwitterListNotFound" style="display: none;"><%=_TEX.T("UploadFilePc.Option.Publish.T_List.NotFound")%></span>
									<select id="EditTwitterList" class="EditPublish" style="display: none;"></select>
								</span>
							</label>
							<input type="radio" name="RadioShowLimitVal" value="TwitterFollowee" id="RadioTwitterFollowee">
							<label for="RadioTwitterFollowee" class="OptionPublishShowLimit">
								<span class="ShowLimitImage TwitterFollowee"></span>
								<span class="ShowLimitName"><i class="fab fa-twitter"></i>フォロー限定</span>
							</label>
							<input type="radio" name="RadioShowLimitVal" value="TwitterEach" id="RadioTwitterEach">
							<label for="RadioTwitterEach" class="OptionPublishShowLimit">
								<span class="ShowLimitImage TwitterEach"></span>
								<span class="ShowLimitName"><i class="fab fa-twitter"></i>相互限定</span>
							</label>
						</div>
					</div>

					<div class="OptionItem">
						<label class="rocker" onclick="updateOptionPublishPassword()">
							<input id="OptionPublishPassword" type="checkbox" checked>
							<span class="switch-left">パスワードなし</span>
							<span class="switch-right">あり</span>
						</label>
					</div>
					<div id="ItemPassword" class="OptionItem" style="padding-top: 0; display: none;">
						<label for="EditPassword"><i class="fas fa-key" style="margin-right: 5px"></i></label>
						<input id="EditPassword" class="EditPassword" type="text" maxlength="16" />
					</div>

					<%if(nEditorId!=Common.EDITOR_TEXT){%>
					<div class="OptionItem" id="OptionItemShowAllFirst" style="display: none">
						<label class="rocker">
							<input id="ItemShowAllFirst" type="checkbox" checked>
							<span class="switch-left">最初の１枚見せる</span>
							<span class="switch-right">見せない</span>
						</label>
					</div>
					<%}%>

					<div class="OptionItem" style="margin-top: 13px">
						<label class="rocker" onclick="updateOptionTweet()">
							<input id="OptionTweet" type="checkbox" checked>
							<span class="switch-left">同時にツイート</span>
							<span class="switch-right">しない</span>
						</label>
					</div>

					<%if(nEditorId==Common.EDITOR_UPLOAD || nEditorId==Common.EDITOR_PASTE || nEditorId==Common.EDITOR_BASIC_PAINT){%>
					<div class="OptionItem Sub" id="OptionItemTweetImage" style="display: none">
						<label class="rocker sub">
							<input id="OptionTweetImage" type="checkbox" checked>
							<span class="switch-left">画像もツイート</span>
							<span class="switch-right">しない</span>
						</label>
					</div>

					<div class="OptionItem">
						<label class="rocker" onclick="updateOptionPublishPassword()">
							<input id="OptionTwitterCardThumbnail" type="checkbox">
							<span class="switch-left" style="font-size:0.8em">Twitterカードにサムネ表示</span>
							<span class="switch-right">表示しない</span>
						</label>
					</div>
					<%}%>

					<div class="OptionItem" style="margin-top: 13px">
						<label class="rocker" onclick="updateOptionPublishPassword()">
							<input id="OptionCheerNg" type="checkbox" checked>
							<span class="switch-left">ポチ袋OFF</span>
							<span class="switch-right">ON</span>
						</label>
					</div>

					<div class="OptionItem" style="margin-top: 13px">
						<label class="rocker">
							<input id="OptionRecent" type="checkbox" checked>
							<span class="switch-left">新着に載せる</span>
							<span class="switch-right">避ける</span>
						</label>
					</div>

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
						<i class="fas fa-upload"></i> <%=_TEX.T("UploadFilePc.UploadBtn")%>
					</a>
				</div>
			</div>
		</article>
		<%if(requestId<0){%>
		<%@ include file="/inner/TFooter.jsp"%>
		<%}%>
	</body>
	<%@ include file="TTranslateDescDlg.jsp"%>
</html>
