<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	static String getSettingMenuItem(String id, String title){
		return "<a data-to=\"" + id + "\" class=\"SettingMenuItemLink SettingChangePageLink\" >" +
				"<span class=\"SettingMenuItemTitle\">" +
				title +
				"</span>" +
				"<i class=\"SettingMenuItemArrow fas fa-angle-right\"></i>" +
				"</a>";
	}
	static String getSettingMenuHeader(String title, boolean bSmartPhone){
		StringBuilder sb = new StringBuilder();
		sb.append("<div class=\"SettingMenuHeader\">\n")
				.append("<h2 class=\"SettinMenuTitle\">\n");
		if(bSmartPhone){
			sb.append("<i data-to=\"MENUROOT\" class=\"SettingChangePageLink fas fa-arrow-left\"></i>\n");
		}
		sb.append(title)
				.append("</h2>\n")
				.append("</div>\n");
		return sb.toString();
	}
%>

<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request,response);
	return;
}

//パラメータの取得
//検索結果の取得
MyEditSettingC results = new MyEditSettingC();
results.getParam(request);
results.getResults(checkLogin);

HashMap<String, String> MENU = new HashMap<>();
MENU.put("PROFILE", "<i class=\"fas fa-address-card\"></i> " + _TEX.T("EditSettingV.Profile"));
MENU.put("MYPAGE", _TEX.T("EditSettingV.MyPage"));
MENU.put("EMOJI", _TEX.T("EditSettingV.Emoji"));
//MENU.put("FOLLOW", "<i class=\"fas fa-star\"></i> " + _TEX.T("EditSettingV.FavoList"));
MENU.put("FOLLOWTAG", "<i class=\"fas fa-tag\"></i> " + _TEX.T("EditSettingV.FollowTagList"));
MENU.put("BLOCK", _TEX.T("EditSettingV.BlockList"));
//MENU.put("MUTEKEYWORD", _TEX.T("EditSettingV.MuteKeyowrd"));
MENU.put("TWITTER", "<i class=\"fab fa-twitter\"></i> " + _TEX.T("EditSettingV.Twitter"));
MENU.put("MAIL", "<i class=\"fas fa-envelope\"></i> " + _TEX.T("EditSettingV.Email"));
//MENU.put("REQUEST", "<span class=\"RequestIcon\"></span>" + _TEX.T("Request"));
//MENU.put("POIPASS", "<img style=\"height: 30px;vertical-align: middle; margin: 0 5px 0 0;}\" src=\"/img/poipiku_passport_logo3_60.png\" />" + _TEX.T("EditSettingV.Passport"));
//MENU.put("PAYMENT", _TEX.T("EditSettingV.Payment"));
//MENU.put("CHEER", _TEX.T("EditSettingV.Cheer"));
MENU.put("ACCOUNT", "<i class=\"fas fa-user\"></i> " + _TEX.T("EditSettingV.Account"));
MENU.put("INFO", "<i class=\"fas fa-info-circle\"></i> " + _TEX.T("EditSettingV.Usage"));
MENU.put("LANGUAGE", "<i class=\"fas fa-globe\"></i> " + _TEX.T("EditSettingV.Language"));

String[][] menuOrder = {
		{
		"PROFILE",
		"MYPAGE",
		"EMOJI",
//		"FOLLOW",
		"FOLLOWTAG",
		"BLOCK",
//		"MUTEKEYWORD",
		"TWITTER",
		"MAIL",
//		"PAYMENT",
//		"REQUEST",
//		"POIPASS",
//		"CHEER",
		"ACCOUNT",
		"INFO",
		"LANGUAGE",
		}
};
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
			$.ajaxSetup({
				cache: false,
			});

			function updateFile(url, objTarg, limitMiByte){
				if (objTarg.files.length>0 && objTarg.files[0].type.match('image.*')) {
					DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
					let fileReader = new FileReader();
					fileReader.onloadend = function() {
						let strEncodeImg = fileReader.result;
						const mime_pos = strEncodeImg.substring(0, 100).indexOf(",");
						if (mime_pos === -1) return;
						if (strEncodeImg.length > limitMiByte * 1e6 * 1.3) {
							DispMsg("<%=_TEX.T("EditSettingV.Image.TooLarge")%>");
							return;
						}
						strEncodeImg = strEncodeImg.substring(mime_pos+1);
						$.ajaxSingle({
							"type": "post",
							"data": {"UID":<%=checkLogin.m_nUserId%>, "DATA":strEncodeImg},
							"url": url,
							"dataType": "json",
							"success": function(res) {
								switch(res.result) {
									case 0:
										// complete
										DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
										sendObjectMessage("reloadParent");
										location.reload();
										break;
									case -1:
										// file size error
										DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>");
										break;
									case -2:
										// file type error
										DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>");
										break;
									default:
										DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + res.result);
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

			function ResetProfileFile(nMode){
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=checkLogin.m_nUserId%>, "MD":nMode},
					"url": "/f/ResetProfileFileF.jsp",
					"dataType": "json",
					"success": function(data) {
						sendObjectMessage("reloadParent");
						location.reload();
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
				return false;
			}

			function UpdateTwitterPublishAccount() {
				const bPublishAccount = $('#PublishAccount').prop('checked');
				$.ajaxSingle({
					"type": "post",
					"data": {"ID":<%=checkLogin.m_nUserId%>, "MD": bPublishAccount?1:0},
					"url": "/f/UpdateTwitterPublishAccountF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>', 1000);
					},
					"error": function(req, stat, ex){
						DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
					}
				});
			}

			$(function(){
				$("#MenuSettings").addClass("Selected");

				<%if(results.m_strMessage.length()>0) {%>
					DispMsg("<%=Util.toStringHtml(results.m_strMessage)%>");
				<%}%>

				$(".SettingChangePageLink").click((ev)=>{
					const el = $(ev.currentTarget);
					location.href = "/MyEditSettingPcV.jsp?MENUID=" + el.attr("data-to");
					return true;
				});

				$("#MenuMe").addClass("Selected");
				$("#MenuSearch").hide();
				$("#MenuSettings").show();
				<%if(results.m_strSelectedMenuId.isEmpty()){%>
					$("#MENUROOT").show();
				<%}else{%>
					$("#<%=results.m_strSelectedMenuId%>").show();
				<%}%>
			});
		</script>

		<style>
		.Wrapper.ItemList .IllustItemList {margin-top: 6px;}
		.SettingList .SettingListItem .SettingListTitle {border-bottom: 1px solid #000;}
		.SettingMenuHeader{
			height: 27px;
			font-size: 18px;
			font-weight: 400;
			padding: 7px;
			background-color: #ffffff;
			color: #000;
			border-bottom: 1px solid #555;
		}
		.SettingBody {display: block; float: left; background: #fff; color: #000;width: 100%;}
		.SettingListItem {color: #000;}
		.SettingListItem a {color: #000;}
		.SettingBody .SettingBodyCmdRegist {font-size: 14px;}
		.SettingMenuItemLink {
			background-color: #ffffff;
			min-height: calc(41.625px);
			width: 100%;
			display: block;
			line-height: 40px;
			border-bottom: 1px solid #ccc;
			color: #000;
		}
		.SettingMenuItem {width: 100%;}
		.SettingMenuItemTitle {	margin-left: 8px;}
		.SettinMenuTitle .SettingChangePageLink {color: #000000;}
		.SettingMenuItemArrow {display: inline-block; float: right; position: relative; top: 10px; padding: 0 9px;}
		.SettingMenuReturnArrow {color: #3498db;}
		.RequestIcon {
				display: inline-block;
				width: 20px;
				height: 20px;
				margin-right: 4px;
				background: url(/img/menu_pc-12.png) no-repeat;
				background-size: 1054%;
				position: relative;
				background-position: -160px -21px;
				top: 2px;
		}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div id="MENUROOT" class="SettingPage" style="display: none;">
				<div class="SettingList">
					<%for(String m : menuOrder[0]){%>
						<%if(MENU.get(m)!=null){%>
							<%=getSettingMenuItem(m, MENU.get(m))%>
						<%}%>
					<%}%>
				</div>
			</div>
			<%
				String strPageId = "";
				final String selectedMenuId = results.m_strSelectedMenuId;
			%>
			<%strPageId = "PROFILE";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingProfileV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "MYPAGE";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingMyPageV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "EMOJI";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingEmojiV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "FOLLOW";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingFollowV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "FOLLOWTAG";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingFollowTagV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "BLOCK";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingBlockV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "MUTEKEYWORD";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingMuteKeywordV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "TWITTER";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingTwitterV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "MAIL";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingMailV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "POIPASS";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingPassportV.jsp"%>
				</div>
			</div>

			<%}%>
				<%strPageId = "REQUEST";%>
				<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
				<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
					<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
					<div class="SettingBody">
						<%@include file="/inner/setting/MyEditSettingRequestV.jsp"%>
					</div>
				</div>
			<%}%>

			<%strPageId = "PAYMENT";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingPaymentV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "CHEER";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingCheerV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "ACCOUNT";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingAccountV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "INFO";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingInfoV.jsp"%>
				</div>
			</div>
			<%}%>

			<%strPageId = "LANGUAGE";%>
			<%if(selectedMenuId.isEmpty() || selectedMenuId.equals(strPageId)){%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), true)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingLanguageV.jsp"%>
				</div>
			</div>
			<%}%>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
