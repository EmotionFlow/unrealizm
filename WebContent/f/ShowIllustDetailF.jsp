<%@ page import="sun.util.resources.cldr.te.CurrencyNames_te" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	String createDetailVHtml(final IllustDetailC cResults, final ResourceBundleControl _TEX){
		String html = "";

		if (cResults.m_cContent.m_nEditorId == Common.EDITOR_TEXT) {
			html += "    <script>\n" +
					"      $(function () {\n";
			if (cResults.m_cContent.novelDirection == 0) {
				html += "if (window.innerWidth< $(\".NovelSection\").width()){\n" +
						"          $(\".IllustItemLink\").css(\"width\", String(window.innerWidth - 10) +\"px\");\n" +
						"        }";
			} else {
				html += "        $(\".IllustItemTextDetail\").css(\"width\", (window.innerWidth - 10) + \"px\");\n" +
						"        $(\".IllustItemTextDetail\").scrollLeft(100000);\n" +
						"        const h = $(\"body\").height();\n" +
						"        if (h < $(\".IllustItemTextDetail.Vertical\").height()){\n" +
						"          $(\".IllustItemLink\").css(\"height\", String(h - 10) +\"px\");\n" +
						"          $(\".IllustItemLink\").css(\"padding\", 0);\n" +
						"          $(\".IllustItemTextDetail.Vertical\").css(\"height\", String(h - 10) +\"px\");\n" +
						"        }\n";
			}
			html += "</script>";
		}

		html += "<style>.IllustItemLink {\n";
		if (cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT && cResults.m_cContent.novelDirection==0) {
			html += "margin: 0 auto;width: 25em;\n";
		} else {
			html += "padding: 4px;text-align: center;";
		}
		html += "} </style>";

		if(!cResults.m_cContent.m_strFileName.isEmpty()) {
			String downloadAreaDiv = "";
			if(cResults.isDownloadable) {
				downloadAreaDiv += "<div class=\"IllustItemTProhibit\">";
				downloadAreaDiv += "        <a href=\"/DownloadImageFile?TD=" + cResults.contentId + "&AD=" + cResults.appendId + "\"><i class=\"fas fa-download\"></i> " + _TEX.T("IllustView.Download") + "</a>\n";
				if (cResults.isOwner) {
					downloadAreaDiv += "<br><span>";
					if (cResults.m_nDownload == CUser.DOWNLOAD_OFF) {
						downloadAreaDiv += "" + _TEX.T("IllustView.DownloadInfo.Disallow") + "";
					} else {
						downloadAreaDiv += "" + _TEX.T("IllustView.DownloadInfo.Allow") + "";
					}
					downloadAreaDiv += "</span>";
				}
				downloadAreaDiv += "</div>";
				html += downloadAreaDiv;
			}

			html += "      <div class=\"IllustItemLink\" style=\"display: block;\">\n" +
					"        <img class=\"IllustItemImage\" src=\"" + Common.GetOrgImgUrl(cResults.m_cContent.m_strFileName) + "\" />\n" +
					"      </div>\n";

			if(cResults.isDownloadable) {
				html += downloadAreaDiv;
			}

			html += "      <div class=\"IllustItemTProhibit\">\n" + _TEX.T("IllustView.ProhibitMsg.Long") + "      </div>\n";

		} else if(cResults.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {
			html += "<div class=\"IllustItemLink\">";
			html += "        <div class=\"IllustItemTextDetail " + (cResults.m_cContent.novelDirection==1 ? "Vertical" : "") + "\">\n" +
					"          " + Util.replaceForGenEiFont(cResults.m_cContent.novelHtml) +
					"        </div>\n";
			html += "</div>";
		} else {
			html += "Not found";
		}
		return html;
	}
%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

String html = "";
int result = Common.API_NG;
int errorCode = 0;

final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("poipiku.com")) {
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
if(!cResults.getResults(checkLogin)) {
	errorCode = -3;
}

if (errorCode == 0) {
	html = createDetailVHtml(cResults, _TEX);
	result = Common.API_OK;
}

%>
{"result":<%=result%>,"html":"<%=CEnc.E(html)%>","error_code":<%=errorCode%>}