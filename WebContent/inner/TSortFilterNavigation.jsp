<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
	nav#SortFilterMenu > div {
		display: inline-flex;
		justify-content: center;
		width: calc(100% / 3);
		padding: 0px 4px;
		overflow-x: hidden;
	}
	span.CategoryFilter {
		display: block;
	}
	span.KeywordFilter {
		max-width: 100%;
		white-space: nowrap;
        overflow: hidden;
        /*text-shadow: 0 0 5px #787878;*/
	}
	span.currentKeyword {
		font-size: 11px;
	}
</style>
<% String myBoxKeyword = Util.toStringHtml(results.searchKeyword); %>
<nav id="SortFilterMenu" class="SortFilterMenu" <%=isGridPc ? "style=\"width:400px;margin:0 auto;\"" : ""%>>
	<div>
		<span class="SortMenuIcon" onclick="showMyBoxSortFilterSubMenu('SortMenu');">
			<%
				String sortMenuIconClass = "";
				String sortMenuDirectionIcon = null;
				if (results.sortBy == IllustListC.SortBy.None) {
					sortMenuIconClass = "fas fa-sort-amount-down";
				} else if (results.sortBy == IllustListC.SortBy.Description) {
					sortMenuIconClass = results.sortOrderAsc ? "fas fa-sort-alpha-down" : "fas fa-sort-alpha-up";
				} else if (results.sortBy == IllustListC.SortBy.CreatedAt) {
					sortMenuIconClass = "far fa-calendar WithDirection";
					sortMenuDirectionIcon = results.sortOrderAsc ? "fas fa-sort-up" : "fas fa-sort-down";
				} else if (results.sortBy == IllustListC.SortBy.UpdatedAt) {
					sortMenuIconClass = "fas fa-pen WithDirection";
					sortMenuDirectionIcon = results.sortOrderAsc ? "fas fa-sort-up" : "fas fa-sort-down";
				}
			%>
			<%if(sortMenuDirectionIcon!=null){%><i class="SortDirection <%=sortMenuDirectionIcon%>"></i><%}%>
			<i class="<%=sortMenuIconClass%>"></i>
		</span>
	</div>
</nav>
<nav id="SortFilterSubMenu" class="SortFilterSubMenu" <%=isGridPc ? "style=\"width:500px;margin:0 auto;\"" : ""%>>
	<div id="SortMenu" class="SortMenu" style="display: none;">
		<%
			keyValues = results.getParamKeyValueMap();
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
					   			results.getSortAscParam(IllustListC.SortBy.Description))
					   			%>"></a>
	</div>
</nav>
<script>
	$("#MyBoxSearchBtn").on('click', () => $("#MyBoxSearchWrapper").submit());
	$("#MyBoxSearchWrapper").on('submit', () => {
		if (!$("#MyBoxSearchBox").val()) return false;
	});
</script>
