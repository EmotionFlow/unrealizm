<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if(checkLogin.m_nPassportId == Common.PASSPORT_OFF){%>
<script>
	function showRecommendPoipassDlg(msg) {
		const html = `
<style>
.TwitterFollowerLimitInfoDlgTitle{padding: 10px 0 0 0; color: #3498db;font-weight: 500;}
.TwitterFollowerLimitInfoDlgInfo{font-size: 14px; text-align: left;}
</style>
<div class="TwitterFollowerLimitInfoDlg">
<div class="TwitterFollowerLimitInfoDlgTitle"><img height="40px" src="/img/poipiku_passport_logo3_60.png"/></div>
<div class="TwitterFollowerLimitInfoDlgInfo" style="margin: 15px 0 15px 0;">
<p style="font-weight: 400; text-align: center;">` + msg + `</p>
<%if(!isApp){%>
<a style="color:#3498db; display:block; text-align:center;" href="/MyEditSettingPcV.jsp?MENUID=POIPASS">
<i class="far fa-thumbs-up"></i><%=_TEX.T("RecommendPoipass.Info01")%></a>
<%}else{%>
<p><%=_TEX.T("RecommendPoipass.Info02")%></p>
<%}%>
</div>
</div>
`;
	Swal.fire({
		html: html,
		showCloseButton: true,
		showCancelButton: false,
		showConfirmButton: false,
	});
}
</script>
<%}%>
<nav id="SortFilterMenu" class="SortFilterMenu" <%=isGridPc ? "style=\"width:400px;margin:0 auto;\"" : ""%>>
	<span class="SortMenuIcon" onclick="showMyBoxSortFilterSubMenu('SortMenu');">
		<%
			String sortMenuIconClass = "";
			String sortMenuDirectionIcon = null;
			if (cResults.sortBy == IllustListC.SortBy.None) {
				sortMenuIconClass = "fas fa-sort-amount-down";
			} else if (cResults.sortBy == IllustListC.SortBy.Description) {
				sortMenuIconClass = cResults.sortOrderAsc ? "fas fa-sort-alpha-down" : "fas fa-sort-alpha-up";
			} else if (cResults.sortBy == IllustListC.SortBy.CreatedAt) {
				sortMenuIconClass = "far fa-calendar WithDirection";
				sortMenuDirectionIcon = cResults.sortOrderAsc ? "fas fa-sort-up" : "fas fa-sort-down";
			} else if (cResults.sortBy == IllustListC.SortBy.UpdatedAt) {
				sortMenuIconClass = "fas fa-pen WithDirection";
				sortMenuDirectionIcon = cResults.sortOrderAsc ? "fas fa-sort-up" : "fas fa-sort-down";
			}
		%>
		<%if(sortMenuDirectionIcon!=null){%><i class="SortDirection <%=sortMenuDirectionIcon%>"></i><%}%>
		<i class="<%=sortMenuIconClass%>"></i>
	</span>
	<span onclick="showMyBoxSortFilterSubMenu('CategoryFilterMenu');"
		  class="CategoryFilter <%="Category C"+cResults.categoryFilterId%>"
		  style="border-color: #ffffff">
					<%=cResults.categoryFilterId<0?_TEX.T("Category.All"):_TEX.T(String.format("Category.C%d", cResults.categoryFilterId))%>
				</span>
	<span onclick="showMyBoxSortFilterSubMenu('KeywordFilterMenu');">
		<i class="fas fa-search"></i>
	</span>
<%--	<a class="fas fa-search" href="javascript:void(0);"></a>--%>
</nav>
<nav id="SortFilterSubMenu" class="SortFilterSubMenu" <%=isGridPc ? "style=\"width:500px;margin:0 auto;\"" : ""%>>
	<div id="SortMenu" class="SortMenu" style="display: none;">
		<%
			keyValues = cResults.getParamKeyValueMap();
			keyValues.remove("PG");
			keyValues.remove("SBY");
			keyValues.remove("SASC");
			strCgiParam = Common.getCgiParamStr(keyValues);
		%>
		<a class="fas fa-sort-amount-down"
		   href="<%=String.format("%s?%s", thisPagePath, strCgiParam)%>"></a>
		<a class="fas fa-sort-alpha-down"
		   href="<%=String.format("%s?%s", thisPagePath,
					   			strCgiParam +
					   			"&SBY=" + IllustListC.SortBy.Description.getCode() +
					   			cResults.getSortAscParam(IllustListC.SortBy.Description))
					   			%>"></a>
		<a class="far fa-calendar"
		   <%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF){%>
		   href="javascript:void(0)" onclick="showRecommendPoipassDlg('<%=_TEX.T("RecommendPoipass.CreatedAt")%>');"
		   <%}else{%>
		   href="<%=String.format("%s?%s", thisPagePath,
					   			strCgiParam +
					   			"&SBY=" + IllustListC.SortBy.CreatedAt.getCode() +
					   			cResults.getSortAscParam(IllustListC.SortBy.Description))
					   			%>"
			<%}%>
		></a>
		<a class="fas fa-pen"
		   <%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF){%>
		   href="javascript:void(0)" onclick="showRecommendPoipassDlg('<%=_TEX.T("RecommendPoipass.UpdatedAt")%>');"
		   <%}else{%>
		   href="<%=String.format("%s?%s", thisPagePath,
					   			strCgiParam +
					   			"&SBY=" + IllustListC.SortBy.UpdatedAt.getCode() +
					   			cResults.getSortAscParam(IllustListC.SortBy.Description))
					   			%>"

			<%}%>
		></a>
	</div>
	<div id="CategoryFilterMenu" class="CategoryFilterMenu" style="display: none;">
		<a class="Category C-1" href="<%=String.format("%s?PG=%d", thisPagePath, cResults.m_nPage)%>">
			<%=_TEX.T("Category.All")%>
		</a>
		<%
			keyValues = cResults.getParamKeyValueMap();
			keyValues.remove("CAT");
			keyValues.remove("PG");
			strCgiParam = Common.getCgiParamStr(keyValues);
			for(int categoryId: Common.CATEGORY_ID) {
		%>
		<a class="Category C<%=categoryId%>" href="<%=String.format("%s?%s", thisPagePath, strCgiParam + "&CAT=" + categoryId)%>">
			<%=_TEX.T(String.format("Category.C%d", categoryId))%>
		</a>
		<%
			}
			keyValues.clear();
		%>
	</div>
	<div id="KeywordFilterMenu" class="KeywordFilterMenu" style="display: none;">
		<%
			keyValues = cResults.getParamKeyValueMap();
			keyValues.remove("TXT");
			keyValues.remove("PG");
			strCgiParam = Common.getCgiParamStr(keyValues);
		%>
		<form id="MyBoxSearchWrapper" class="MyBoxSearchWrapper" method="get" action="<%=thisPagePath%>">
			<div class="MyBoxSearch">
				<% for(Map.Entry<String, String> entry: keyValues.entrySet()) { %>
					<input name="<%=entry.getKey()%>" type="hidden" value="<%=Util.toStringHtml(entry.getValue())%>">
				<% } %>
				<!--TODO: ↓検索実行後は現在の検索ワードを初期値へ-->
				<input name="TXT" id="MyBoxSearchBox" class="MyBoxSearchBox" type="text" placeholder="<%=_TEX.T("MyIllustListV.SearchKeyword.PlaceHolder")%>" value="<%=Util.toStringHtml(g_strSearchWord)%>" />
				<div id="MyBoxSearchBtn" class="MyBoxSearchBtn"><%=_TEX.T("MyIllustListV.SearchKeyword.Search")%></div>
			</div>
		</form>
	</div>
</nav>
<script>
	$("#MyBoxSearchBtn").on('click', () => $("#MyBoxSearchWrapper").submit());
</script>
