<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	String getImgTag(final String fileName) {
		return "        <img class=\"DetailIllustItemImage\" src=\"" + Common.GetOrgImgUrl(fileName) + "\" onload=\"detailIllustItemImageOnload(this)\" />\n";
	}
	String createDetailVHtml(final IllustDetailC cResults, final ResourceBundleControl _TEX){
		StringBuilder html = new StringBuilder();

		if (cResults.content.m_nEditorId == Common.EDITOR_TEXT) {
			html.append("    <script>\n" + "      $(function () {\n");
			if (cResults.content.novelDirection == 0) {
				html.append("if (window.innerWidth< $(\".NovelSection\").width()){\n" + "          $(\".IllustItemLink\").css(\"width\", String(window.innerWidth - 10) +\"px\");\n" + "        }");
			} else {
				html.append("        $(\".IllustItemTextDetail\").css(\"width\", (window.innerWidth - 10) + \"px\");\n" + "        $(\".IllustItemTextDetail\").scrollLeft(100000);\n" + "        const h = $(\"body\").height();\n" + "        if (h < $(\".IllustItemTextDetail.Vertical\").height()){\n" + "          $(\".IllustItemLink\").css(\"height\", String(h - 10) +\"px\");\n" + "          $(\".IllustItemLink\").css(\"padding\", 0);\n" + "          $(\".IllustItemTextDetail.Vertical\").css(\"height\", String(h - 10) +\"px\");\n" + "        }\n");
			}
			html.append("</script>");
		}

		html.append("<style>.IllustItemLink {\n");
		if (cResults.content.m_nEditorId==Common.EDITOR_TEXT && cResults.content.novelDirection==0) {
			html.append("margin: 0 auto;width: 25em;\n");
		}
		html.append("} </style>");

		if(!cResults.content.m_strFileName.isEmpty()) {
			String downloadAreaDiv = "";

			html.append("      <div class=\"DetailIllustItemLink\">\n");

			if(cResults.isDownloadable) {
				downloadAreaDiv += "<div class=\"DetailIllustItemDownload\">";
				downloadAreaDiv += "        <a href=\"/DownloadImageFile?TD=" + cResults.contentId + "&AD=" + cResults.appendId + "\"><i class=\"fas fa-download\"></i> " + _TEX.T("IllustView.Download") + "</a>\n";
				if (cResults.isOwner) {
					downloadAreaDiv += "<br><span>";
					if (cResults.downloadCode == CUser.DOWNLOAD_OFF) {
						downloadAreaDiv += _TEX.T("IllustView.DownloadInfo.Disallow");
					} else {
						downloadAreaDiv += _TEX.T("IllustView.DownloadInfo.Allow");
					}
					downloadAreaDiv += "</span>";
				} else {
					downloadAreaDiv += "<br><span>" + _TEX.T("IllustView.DownloadInfo.Allow") + "</span>";
				}
				downloadAreaDiv += "</div>";
				html.append(downloadAreaDiv);
			}

			if (cResults.appendId < 0) {
				html.append(getImgTag(cResults.content.m_strFileName));
			}

			for (CContentAppend contentAppend : cResults.contentAppendList) {
				html.append(getImgTag(contentAppend.m_strFileName));
			}

			html.append("\t<div class=\"DetailIllustItemProhibit\">").append(_TEX.T("IllustView.ProhibitMsg.Long")).append("</div>\n");

			html.append("      </div>\n");
		} else if(cResults.content.m_nEditorId==Common.EDITOR_TEXT) {
			html.append("<div class=\"IllustItemLink\">");
			html.append("        <div class=\"IllustItemTextDetail ").append(cResults.content.novelDirection == 1 ? "Vertical" : "").append("\">\n").append("          ").append(Util.replaceForGenEiFont(cResults.content.novelHtml)).append("        </div>\n");
			html.append("</div>");
		} else {
			html.append("Not found");
		}
		return html.toString();
	}
%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

String html = "";
int result = Common.API_NG;
int errorCode = 0;

final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("ai.poipiku.com")) {
	Log.d("ShowIllustDetailFへの不正アクセス(referer不一致):" + referer);
	errorCode = -1;
}

if(Util.isBot(request)) {
	errorCode = -1;
}

if(!checkLogin.m_bLogin) {
	errorCode = -2;
}

IllustDetailC cResults = new IllustDetailC();
cResults.getParam(request);
cResults.showMode = 1;
if(!cResults.getResults(checkLogin)) {
	errorCode = -3;
}

if (errorCode == 0) {
	html = createDetailVHtml(cResults, _TEX);
	result = Common.API_OK;
}

%>
{"result":<%=result%>,"html":"<%=CEnc.E(html)%>","error_code":<%=errorCode%>}