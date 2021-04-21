<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%!
	static String getSettingMenuItem(String id, String title){
		StringBuilder sb = new StringBuilder();
		sb.append("<a data-to=\"").append(id).append("\" class=\"SettingMenuItemLink SettingChangePageLink\" >")
				.append("<span class=\"SettingMenuItemTitle\">")
				.append(title)
				.append("</span>")
				.append("<i class=\"SettingMenuItemArrow fas fa-angle-right\"></i>")
				.append("</a>");
		return sb.toString();
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
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

boolean bSmartPhone = isApp ? true : Util.isSmartPhone(request);

//パラメータの取得
//検索結果の取得
MyEditSettingC cResults = new MyEditSettingC();
cResults.getParam(request);
cResults.getResults(checkLogin);

HashMap<String, String> MENU = new HashMap<>();
MENU.put("RECEIVED", "受信したリクエスト");
MENU.put("SENT", "送信済みリクエスト");

String[][] menuOrder = {
		{
		"RECEIVED",
		"SENT",
		}
};

int statusCode = 1;
if (request.getParameter("ST") != null) {
	statusCode= Util.toIntN(request.getParameter("ST"), -2, 3);
}

int requestId = Util.toInt(request.getParameter("RID"));

RequestCreator requestCreator = new RequestCreator(checkLogin.m_nUserId);

%>

<!DOCTYPE html>
<html>
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<%@ include file="/inner/TRequestIntroduction.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
			$.ajaxSetup({
				cache: false,
			});

			const licenses = {
				<%for (int i : Request.LICENSE_IDS) {%>
				"<%=i%>": "<%=_TEX.T(String.format("Request.License.%d.txt",i))%>" ,
				<%}%>
			}

			function dispLicense(id) {
				alert(licenses[id]);
			}

			$(function(){
				<%if(bSmartPhone){%>
				$('#MenuRequest').addClass('Selected');
				<%}else{%>
				$('#MenuMyRequests').addClass('Selected');
				<%}%>
				$('#MenuSearch').hide();

				<%if(cResults.m_strMessage.length()>0) {%>
					DispMsg("<%=Util.toStringHtml(cResults.m_strMessage)%>");
				<%}%>

				$(".SettingChangePageLink").click((ev)=>{
					const el = $(ev.currentTarget);
					let jsp = location.href;
					jsp = jsp.split('/');
					jsp = jsp[jsp.length-1];
					jsp = jsp.split('?')[0];
					location.href = "/" + jsp + "?MENUID=" + el.attr("data-to");
					return true;
				});

				<%if(bSmartPhone){%>
					<%if(cResults.m_strSelectedMenuId.isEmpty()){%>
						$("#MENUROOT").show();
					<%}else{%>
						$("#<%=cResults.m_strSelectedMenuId%>").show();
					<%}%>
				<%}else{%>
					$("#MENUROOT").show();
					const menuId = "<%=cResults.m_strSelectedMenuId%>";
					if(menuId===""){
						menuId = "RECEIVED";
					}
					$(".SettingMenu>a[data-to="+menuId+"]").addClass("Selected");
					$("#"+menuId).show();
				<%}%>
			});
		</script>

		<style>
		<%if(!isApp && bSmartPhone){%>
        .Wrapper {padding-bottom: 200px;}
		<%}%>
		<%if(bSmartPhone){%>
		.Wrapper.ItemList .IllustItemList {margin-top: 6px;}
		<%} else {%>
		.Wrapper.ItemList .IllustItemList {margin-top: 16px;}
		<%}%>

		.SettingList .SettingListItem .SettingListTitle {border-bottom: 1px solid #6d6965;}

		.SettingMenuHeader{
			height: 27px;
			font-size: 18px;
			font-weight: 400;
			padding: 7px;
			background-color: #fff;
			color: #6d6965;
			border-bottom: 1px solid #555;
		}

		.SettingBody {display: block; float: left; background: #fff; color: #6d6965;width: 100%;}

		.SettingListItem {color: #6d6965;}
		.SettingListItem a {color: #6d6965;}

		.SettingBody .SettingBodyCmdRegist {
			font-size: 14px;
		}

		.SettingMenuItemLink {
			background-color: #fff;
			min-height: calc(41.625px);
			width: 100%;
			display: block;
			line-height: 40px;
			border-bottom: 1px solid #ccc;
			color: #6d6965;
		}

		.SettingMenuItem{
			width: 100%;
		}

		.SettingMenuItemTitle {
			margin-left: 8px;
		}
		.SettinMenuTitle .SettingChangePageLink {
			color: #3498db;
		}

		.SettingMenuItemArrow{
			display: inline-block;
			float: right;
			position: relative;
			top: 10px;
			padding: 0 9px;
		}

		.SettingMenuReturnArrow{
			color: #3498db;
		}

		<%if(!bSmartPhone){%>
		.Wrapper{
			width: 850px;
		}
		#MENUROOT{
			width: 249px;
			display: inline-block;
			float: left;
			border-left: 1px solid #fff;
		}
		#SettingContent{
			display: inline-block;
			background: #fff;
			width: 598px;
			min-height: 425px;
			border: 1px solid #ccc;
			border-top: 0;
		}
		.SettingListItem {
			color: #6d6965;
		}
		.SettingListItem a {
			color: #6d6965;
		}
		.SettingMenuItemLink:hover,
		.SettingMenuItemLink.Selected{
			color: #000;
			background-color: #f3f3f3;
		}
		<%}%>

        .SettingMenu > .WhatIsRequest {
            background-color: #fff;
            min-height: calc(41.625px);
            width: 100%;
            display: block;
            line-height: 40px;
            border-bottom: 1px solid #ccc;
            color: #6d6965;
            text-align: center;
        }
        .SettingMenu > .RequestCreatorStatus {
            background-color: #f6f6f7;
            width: 100%;
            display: block;
            line-height: 30px;
            border-bottom: 1px solid #ccc;
            color: #6d6965;
            text-align: center;
        }
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>

		<%if(!isApp){%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/TMenuApp.jsp" %>
		<%}%>

		<article class="Wrapper">
			<div id="MENUROOT" class="SettingPage" style="display: none;">
				<div class="SettingMenu">
					<div class="RequestCreatorStatus">
						<a href="/MyEditSettingPcV.jsp?MENUID=REQUEST" style="color:#6d6965;">
						<%=requestCreator.status== RequestCreator.Status.Enabled ? "リクエスト募集：受付中" : "リクエスト募集：停止中"%>
						</a>
					</div>
					<%for(String m : menuOrder[0]){%>
						<%if(MENU.get(m)!=null){%>
							<%=getSettingMenuItem(m, MENU.get(m))%>
						<%}%>
					<%}%>
					<div class="WhatIsRequest">
						<i class="fas fa-info-circle" style="font-size: 14px"></i>
						<a href="javascript: void(0);" style="color:#6d6965; text-decoration: underline" onclick="dispRequestIntroduction()">
							リクエストとは？
						</a>
					</div>
				</div>
			</div>

			<%if(!bSmartPhone){%>
			<div id="SettingContent">
			<%}%>

			<%String category = "";%>

			<%category = "RECEIVED";%>
			<%if(category.equals(cResults.m_strSelectedMenuId)){%>
			<div id="<%=category%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(category), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/request/MyRequestListV.jsp"%>
				</div>
			</div>
			<%}%>

			<%category = "SENT";%>
			<%if(category.equals(cResults.m_strSelectedMenuId)){%>
			<div id="<%=category%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(category), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/request/MyRequestListV.jsp"%>
				</div>
			</div>
			<%}%>


			<%if(!bSmartPhone){%>
			</div>
			<%}%>
		</article><!--Wrapper-->

		<%if(!isApp){%>
		<%@ include file="/inner/TFooter.jsp"%>
		<%}%>
	</body>
</html>
