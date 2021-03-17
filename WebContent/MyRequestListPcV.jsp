<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
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

if(!checkLogin.isStaff()){
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

boolean bSmartPhone = Util.isSmartPhone(request);

//パラメータの取得
//検索結果の取得
MyEditSettingC cResults = new MyEditSettingC();
cResults.getParam(request);
cResults.getResults(checkLogin);

HashMap<String, String> MENU = new HashMap<>();
MENU.put("SENT", "送信済みリクエスト");
MENU.put("RECEIVED", "受信したリクエスト");


String[][] menuOrder = {
		{
		"SENT",
		"RECEIVED",
		}
};
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
			$.ajaxSetup({
				cache: false,
			});

			$(function(){
				<%if(cResults.m_strMessage.length()>0) {%>
					DispMsg("<%=Util.toStringHtml(cResults.m_strMessage)%>");
				<%}%>

				$(".SettingChangePageLink").click((ev)=>{
					const el = $(ev.currentTarget);
					location.href = "/MyRequestListPcV.jsp?MENUID=" + el.attr("data-to");
					return true;
				});

				<%if(bSmartPhone){%>
					$("#MenuMe").addClass("Selected");
					<%if(cResults.m_strSelectedMenuId.isEmpty()){%>
						$("#MENUROOT").show();
					<%}else{%>
						$("#<%=cResults.m_strSelectedMenuId%>").show();
					<%}%>
				<%}else{%>
					$("#MenuSettings").addClass("Selected");
					$("#MENUROOT").show();
					var menuId = "<%=cResults.m_strSelectedMenuId%>";
					if(menuId===""){
						menuId = "SENT";
					}
					$(".SettingMenu>a[data-to="+menuId+"]").addClass("Selected");
					$("#"+menuId).show();
				<%}%>
			});
		</script>

		<style>
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
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div id="MENUROOT" class="SettingPage" style="display: none;">
				<div class="SettingMenu">
					<%for(String m : menuOrder[0]){%>
						<%if(MENU.get(m)!=null){%>
							<%=getSettingMenuItem(m, MENU.get(m))%>
						<%}%>
					<%}%>
				</div>
			</div>

			<%if(!bSmartPhone){%>
			<div id="SettingContent">
			<%}%>

			<%String category = "";%>

			<%category = "SENT";%>
			<%if(category.equals(cResults.m_strSelectedMenuId)){%>
			<div id="<%=category%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(category), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/request/MyRequestListV.jsp"%>
				</div>
			</div>
			<%}%>

			<%category = "RECEIVED";%>
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

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
