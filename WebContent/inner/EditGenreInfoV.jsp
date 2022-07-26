<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.stream.Collectors" %>
<%@include file="/inner/Common.jsp"%>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
	boolean bSmartPhone = Util.isSmartPhone(request);

	request.setCharacterEncoding("UTF-8");
	int userId	= Util.toInt(request.getParameter("ID"));
	int genreId	= Util.toInt(request.getParameter("GD"));

	if(!checkLogin.m_bLogin || userId!=checkLogin.m_nUserId) {
		getServletContext().getRequestDispatcher("/LoginFormEmail%sV.jsp".formatted(isApp?"App":"Pc")).forward(request,response);
		return;
	}

/*
if(checkLogin.m_nPassportId <= Common.PASSPORT_OFF) {
	getServletContext().getRequestDispatcher("/MyEditSettingPcV.jsp?MENUID=POIPASS").forward(request,response);
	return;
}
*/

	EditGenreInfoC results = new EditGenreInfoC();
	results.getParam(request);
	if (!results.getResults(checkLogin)) {
		return;
	}
	final Genre genre = results.genre;
	final List<GenreTranslation> translationList = results.translationList;

	String strTitle = String.format(_TEX.T("EditGenreInfo.Title"), genre.genreName) + " | " + _TEX.T("THeader.Title");
	String strUrl = "https://poipiku.com/EditGenreInfo" + (isApp?"App":"Pc") + "V.jsp?GD="+genre.genreId;
	boolean editable = (genre.genreId>=1);
	String disable = (editable)?"":"Disabled";
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%if(!isApp){%>
	<%@ include file="/inner/THeaderCommonPc.jsp"%>
	<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
	<%}else{%>
	<%@ include file="/inner/THeaderCommon.jsp"%>
	<%}%>

	<link rel="canonical" href="<%=strUrl%>" />
	<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
	<title><%=_TEX.T("THeader.Title")%> - <%=Util.toDescString(strTitle)%></title>

	<script type="text/javascript">
		$(function(){
			<%if(!isApp){%>
			$('#MenuGenre').addClass('Selected');
			<%}%>
			switchTransTxt('Name', '<%=checkLogin.m_nLangId%>');
			switchTransTxt('Desc', 'default');
			switchTransTxt('Detail', 'default');
		});
	</script>

	<script>
		let transList = {
			'Name' : {
				<%=translationList.stream()
					.filter(e->e.columnType==Genre.ColumnType.Name)
					.map(e->String.format("'%d': `%s`", e.langId, e.transTxt))
					.collect(Collectors.joining(","))%>
			},
			'Desc' : {
				'default': `<%=genre.genreDesc%>`,
				<%=translationList.stream()
					.filter(e->e.columnType==Genre.ColumnType.Description)
					.map(e->String.format("'%d': `%s`", e.langId, e.transTxt))
					.collect(Collectors.joining(","))%>
			},
			'Detail' : {
				'default': `<%=genre.genreDetail%>`,
				<%=translationList.stream()
					.filter(e->e.columnType==Genre.ColumnType.Detail)
					.map(e->String.format("'%d': `%s`", e.langId, e.transTxt))
					.collect(Collectors.joining(","))%>
			}
		};

		function switchTransTxt(name, langId) {
			let txt = transList[name][langId];
			$("#Edit"+name).val(txt ?  txt : "");
		}

		function updateFile(url, objTarg, limitMiByte){
			if (objTarg.files.length>0 && objTarg.files[0].type.match('image.*')) {
				DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
				var fileReader = new FileReader();
				fileReader.onloadend = function() {
					var strEncodeImg = fileReader.result;
					var mime_pos = strEncodeImg.substring(0, 100).indexOf(",");
					if (mime_pos === -1) return;
					if (strEncodeImg.length > limitMiByte * 1e6 * 1.3) {
						DispMsg("<%=_TEX.T("EditSettingV.Image.TooLarge")%>");
						return;
					}
					strEncodeImg = strEncodeImg.substring(mime_pos+1);
					$.ajaxSingle({
						"type": "post",
						"data": {"UID":<%=checkLogin.m_nUserId%>, "GID":<%=genre.genreId%>, "DATA":strEncodeImg},
						"url": url,
						"dataType": "json",
						"success": function(res) {
							console.log(res);
							DispMsg(res.message);
							switch(res.result) {
								case 0:
									// complete
									sendObjectMessage("reloadParent");
								if(<%=genreId%> === -1) {
									location.href = "/EditGenreInfo<%=isApp?"App":"Pc"%>V.jsp?ID=" + <%=checkLogin.m_nUserId%> + "&GD=" + res.genre_id;
								} else {
									location.reload();
								}
									break;
								default:
									break;
							}
						},
						"error": function(req, stat, ex){
							DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
						}
					});
				}
				fileReader.readAsDataURL(objTarg.files[0]);
			}
			return false;
		}

		function UpdateGenreInfo(typeId, langId, txt) {
			let postLangId = langId === 'default' ? -1 : parseInt(langId, 10);
			const data = $.trim(txt);
			$.ajaxSingle({
				"type": "post",
				"data": { "TY":typeId, "LANGID": postLangId, "UID":<%=checkLogin.m_nUserId%>, "GID":<%=genre.genreId%>, "DATA":data},
				"url": '/api/UpdateGenreInfoF.jsp',
				"dataType": "json",
				"success": function(res) {
					DispMsg(res.message);
					switch(res.result) {
						case 0:
							// complete
							sendObjectMessage("reloadParent");
							setTimeout(()=>{
								location.reload();
							}, 1000);
							break;
						default:
							break;
					}
				},
				"error": function(req, stat, ex){
					DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
				}
			});
			return false;
		}

		function UpdateGenreFile(objTarg){
			updateFile("/api/UpdateGenreFileF.jsp?TY=0", objTarg, 1.0);
		}

		function UpdateGenreFileBg(objTarg){
			updateFile("/api/UpdateGenreFileF.jsp?TY=1", objTarg, 2.0);
		}

		function DispCharNum(inId, outId, maxLength) {
			var nCharNum = maxLength - $("#"+inId).val().length;
			$("#"+outId).html(nCharNum);
		}

		$(function() {
			DispCharNum('EditDesc', 'EditDescNum', 64);
			DispCharNum('EditDetail', 'EditDetailNum', 1000);
		})

	</script>

	<style>
        .SettingList {background: #fff; max-width: none;}
        .SettingList .SettingListItem .SettingListTitle {border-bottom: 1px solid #6d6965;}
        .SettingBody {display: block; float: left; background: #fff; color: #6d6965;width: 100%;}
        .SettingListItem {color: #6d6965;}
        .SettingListItem a {color: #6d6965;}
        .SettingBody .SettingBodyCmdRegist {font-size: 14px;}
        .SettingListItem {color: #6d6965;}
        .SettingListItem a {color: #6d6965;}
        .SettingListItem.Disabled , .SettingList .SettingListItem.Disabled .SettingBody .SettingBodyTxt, .SettingList .SettingListItem.Disabled .SettingBody {background: #eee;}
        .SelectTransLang > select {
            height: 30px;
            margin-bottom: 3px;}
        .SettingList .SettingListItem .SettingListTitle.WithLangSelector {
            display: flex;
            justify-content: space-between;
        }

        .SettingList .SettingListItem .SettingListTitle.WithLangSelector i {
            font-size: 13px;
            position: relative;
            top: -6px;
            left: 3px;
        }
	</style>
</head>

<body>

<%if(!isApp){%>
<%@ include file="/inner/TMenuPc.jsp"%>
<%}%>
<article class="Wrapper <%=isApp?"":"ViewPc"%>">
	<div class="SettingList">
		<div class="SettingListItem" style="padding-bottom: 0">
			<div class="SettingListTitle" style="text-align: center"><%=_TEX.T("EditGenreInfo.Info.Title")%></div>
			<div class="SettingBody">
				<div class="SettingBodyTxt"><%=_TEX.T("EditGenreInfo.Info.Info")%></div>
			</div>
		</div>
		<div class="SettingListItem">
			<div class="SettingListTitle"><%=_TEX.T("EditGenreInfo.Name")%></div>
			<div class="SettingBody">
				<div class="SettingBodyTxt" style="font-size: 17px"><%=Util.toStringHtml(genre.genreName)%></div>
				<div class="SettingListItem" style="padding-bottom: 0">
					<div class="SettingListTitle WithLangSelector">
						<span><%=_TEX.T("EditGenreInfo.Translation")%></span>
						<span class="SelectTransLang">
							<i class="fas fa-language"></i>
							<select id="EditTransNameLang" onchange="switchTransTxt('Name', $(this).val())">
								<%for(UserLocale userLocale: SupportedLocales.list) {%>
								<option value="<%=userLocale.id%>" <%=userLocale.id==checkLogin.m_nLangId?"selected":""%>><%=userLocale.label%></option>
								<%}%>
							</select>
							</span>
					</div>
					<input id="EditName" class="SettingBodyTxt" type="text" value="" maxlength="50" />
					<div class="SettingBodyCmd">
						<div id="EditNameNum" class="RegistMessage"></div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
						   onclick="UpdateGenreInfo(<%=Genre.ColumnType.Name.getCode()%>, $('#EditTransNameLang').val(), $('#EditName').val())">
							<%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
		</div>

		<div class="SettingListItem <%=disable%>">
			<div class="SettingListTitle WithLangSelector">
				<span><%=_TEX.T("EditGenreInfo.Desc")%></span>
				<span class="SelectTransLang">
						<i class="fas fa-language"></i>
						<select id="EditTransDescLang" onchange="switchTransTxt('Desc', $(this).val())">
							<option value="default" selected><%=_TEX.T("EditGenreInfo.Translation.Default")%></option>
							<%for(UserLocale userLocale: SupportedLocales.list) {%>
							<option value="<%=userLocale.id%>"><%=userLocale.label%></option>
							<%}%>
						</select>
						</span>
			</div>
			<div class="SettingBody">
				<textarea id="EditDesc" class="SettingBodyTxt" rows="3" onkeyup="DispCharNum('EditDesc', 'EditDescNum', 64)" maxlength="64"></textarea>
				<div class="SettingBodyCmd">
					<%if(editable) {%>
					<div id="EditDescNum" class="RegistMessage"></div>
					<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
					   onclick="UpdateGenreInfo(<%=Genre.ColumnType.Description.getCode()%>, $('#EditTransDescLang').val(), $('#EditDesc').val())">
						<%=_TEX.T("EditSettingV.Button.Update")%>
					</a>
					<%} else {%>
					<span class="BtnBase SettingBodyCmdRegist <%=disable%>"><%=_TEX.T("EditSettingV.Button.Update")%></span>
					<%}%>
				</div>
			</div>
		</div>

		<div class="SettingListItem <%=disable%>">
			<div class="SettingListTitle WithLangSelector">
				<span><%=_TEX.T("EditGenreInfo.Detail")%></span>
				<span class="SelectTransLang">
						<i class="fas fa-language"></i>
						<select id="EditTransDetailLang" onchange="switchTransTxt('Detail', $(this).val())">
							<option value="default" selected><%=_TEX.T("EditGenreInfo.Translation.Default")%></option>
							<%for(UserLocale userLocale: SupportedLocales.list) {%>
							<option value="<%=userLocale.id%>"><%=userLocale.label%></option>
							<%}%>
						</select>
						</span>
			</div>
			<div class="SettingBody">

				<textarea id="EditDetail" class="SettingBodyTxt" rows="6" onkeyup="DispCharNum('EditDetail', 'EditDetailNum', 1000)" maxlength="1000"><%=Util.toStringHtmlTextarea(genre.genreDetail)%></textarea>
				<div class="SettingBodyCmd">
					<div id="EditDetailNum" class="RegistMessage"></div>
					<%if(editable) {%>
					<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)"
					   onclick="UpdateGenreInfo(<%=Genre.ColumnType.Detail.getCode()%>, $('#EditTransDetailLang').val(), $('#EditDetail').val())">
						<%=_TEX.T("EditSettingV.Button.Update")%></a>
					<%} else {%>
					<span class="BtnBase SettingBodyCmdRegist <%=disable%>"><%=_TEX.T("EditSettingV.Button.Update")%></span>
					<%}%>
				</div>
			</div>
		</div>

		<div class="SettingListItem <%=disable%>">
			<div class="SettingListTitle"><%=_TEX.T("EditGenreInfo.GenreImage")%></div>
			<div class="SettingBody">
				<div class="PreviewImgFrame">
					<%if(genre.genreImage.equals("/img/default_genre.png")) {%>
					<span class="PreviewMessage"><%=_TEX.T("EditSettingV.Image.NoImage")%></span>
					<%} else {%>
					<img class="PreviewImg" src="<%=Common.GetUrl(genre.genreImage)%>" />
					<%}%>
				</div>
				<div class="RegistMessage" ><%=_TEX.T("EditGenreInfo.GenreImage.Format")%></div>
				<div class="SettingBodyCmd">
					<span class="BtnBase SettingBodyCmdRegist <%=disable%>">
						<%=_TEX.T("EditSettingV.Image.Select")%>
						<%if(editable) {%>
						<input class="CmdRegistSelectFile" type="file" name="file_thumb" id="file_thumb" onchange="UpdateGenreFile(this)" />
						<%}%>
					</span>
				</div>
			</div>
		</div>

		<div class="SettingListItem <%=disable%>">
			<div class="SettingListTitle"><%=_TEX.T("EditGenreInfo.GenreImageBg")%></div>
			<div class="SettingBody">
				<div class="PreviewImgFrame">
					<%if(genre.genreImageBg.isEmpty()) {%>
					<span class="PreviewMessage"><%=_TEX.T("EditSettingV.Image.NoImage")%></span>
					<%} else {%>
					<img class="PreviewImg" src="<%=Common.GetUrl(genre.genreImageBg)%>" />
					<%}%>
				</div>
				<div class="RegistMessage" ><%=_TEX.T("EditGenreInfo.GenreImageBg.Format")%></div>
				<div class="SettingBodyCmd">
					<span class="BtnBase SettingBodyCmdRegist <%=disable%>">
						<%=_TEX.T("EditSettingV.Image.Select")%>
						<%if(editable) {%>
						<input class="CmdRegistSelectFile" type="file" name="file_thumb" id="file_thumb" onchange="UpdateGenreFileBg(this)" />
						<%}%>
					</span>
				</div>
			</div>
		</div>

	</div>
</article>

<%if(!isApp){%>
<%@ include file="/inner/TFooterSingleAd.jsp"%>
<%}%>
</body>
</html>
