<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	String getImgTag(final String fileName) {
		return "        <img class=\"DetailIllustItemImage\" src=\"" + Common.GetOrgImgUrl(fileName) + "\" onload=\"detailIllustItemImageOnload(this)\" />\n";
	}
	String createDetailVHtml(final IllustDetailC results, final ResourceBundleControl _TEX){
		StringBuilder html = new StringBuilder();

		if (results.content.m_nEditorId == Common.EDITOR_TEXT) {
			html.append("    <script>\n" + "      $(function () {\n");
			if (results.content.novelDirection == 0) {
				html.append("if (window.innerWidth< $(\".NovelSection\").width()){\n" + "          $(\".IllustItemLink\").css(\"width\", String(window.innerWidth - 10) +\"px\");\n" + "        }");
			} else {
				html.append("        $(\".IllustItemTextDetail\").css(\"width\", (window.innerWidth - 10) + \"px\");\n" + "        $(\".IllustItemTextDetail\").scrollLeft(100000);\n" + "        const h = $(\"body\").height();\n" + "        if (h < $(\".IllustItemTextDetail.Vertical\").height()){\n" + "          $(\".IllustItemLink\").css(\"height\", String(h - 10) +\"px\");\n" + "          $(\".IllustItemLink\").css(\"padding\", 0);\n" + "          $(\".IllustItemTextDetail.Vertical\").css(\"height\", String(h - 10) +\"px\");\n" + "        }\n");
			}
			html.append("</script>");
		}

		html.append("<style>.IllustItemLink {\n");
		if (results.content.m_nEditorId==Common.EDITOR_TEXT && results.content.novelDirection==0) {
			html.append("margin: 0 auto;width: 25em;\n");
		}
		html.append("} </style>");

		if(!results.content.m_strFileName.isEmpty()) {
			String downloadAreaDiv = "";

			html.append("      <div class=\"DetailIllustItemLink\">\n");

			if(results.isDownloadable) {
				downloadAreaDiv += "<div class=\"DetailIllustItemDownload\">";
				downloadAreaDiv += "        <a href=\"/DownloadImageFile?TD=" + results.contentId + "&AD=" + results.appendId + "\"><i class=\"fas fa-download\"></i> " + _TEX.T("IllustView.Download") + "</a>\n";
				if (results.isOwner) {
					downloadAreaDiv += "<br><span>";
					if (results.downloadCode == CUser.DOWNLOAD_OFF) {
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

			if (results.appendId < 0) {
				html.append(getImgTag(results.content.m_strFileName));
			}

			for (CContentAppend contentAppend : results.contentAppendList) {
				html.append(getImgTag(contentAppend.m_strFileName));
			}

//			html.append("\t<div class=\"DetailIllustItemProhibit\">").append(_TEX.T("IllustView.ProhibitMsg.Long")).append("</div>\n");

			html.append("      </div>\n");
		} else if(results.content.m_nEditorId==Common.EDITOR_TEXT) {
			html.append("<div class=\"IllustItemLink\">");
			html.append("        <div class=\"IllustItemTextDetail ").append(results.content.novelDirection == 1 ? "Vertical" : "").append("\">\n").append("          ").append(Util.replaceForGenEiFont(results.content.novelHtml)).append("        </div>\n");
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
if (!referer.contains("unrealizm.com")) {
	Log.d("ShowIllustDetailFへの不正アクセス(referer不一致):" + referer);
	errorCode = -1;
}

if(Util.isBot(request)) {
	errorCode = -1;
}

if(!checkLogin.m_bLogin) {
	errorCode = -2;
}

IllustDetailC results = new IllustDetailC();
results.getParam(request);
results.showMode = 1;
if(!results.getResults(checkLogin)) {
	errorCode = -3;
}

if (errorCode == 0) {
	html = createDetailVHtml(results, _TEX);
	result = Common.API_OK;
}

%>
{"result":<%=result%>,"html":"<%=CEnc.E(html)%>","error_code":<%=errorCode%>}