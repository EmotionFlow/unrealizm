<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    FollowListC cFollowListResults = new FollowListC();
    cFollowListResults.getParam(request);
    cFollowListResults.m_nMode = 0;
    cFollowListResults.m_nPage = cResults.m_nListPage;
    cFollowListResults.SELECT_MAX_GALLERY = 8;
    cFollowListResults.getResults(cCheckLogin);
%>
<script type="application/javascript">
    $(function(){
        $(document).on("click", "#FollowListPageBar .PageBarItem", function(ev){
           const pageNum = $(ev.target).attr("data-page");
           $.ajax({
               "type": "POST",
               "url": "/f/FollowListF.jsp",
               "data": "MAX=<%=cFollowListResults.SELECT_MAX_GALLERY%>&MD=0&PG=" + pageNum,
           }).then(
               function(htmlList){
                   $.ajax({
                       "type": "POST",
                       "url": "/f/PageBarF.jsp",
                       "data": "TOTAL=<%=cFollowListResults.m_nContentsNum%>&PARPAGE=<%=cFollowListResults.SELECT_MAX_GALLERY%>&PG=" + pageNum,
                   }).then(
                       function(htmlPageBar){
                           $("#FollowListPageBar").empty();
                           $("#FollowListPageBar").append(htmlPageBar);
                       }
                   )
                   $("#FollowList").html(htmlList);
                   $("*").scrollTop(0);
               },
               function(msg) {
                   console.log(msg);
               }
           );
       });
    });
</script>

<div class="SettingList">
    <div id="FollowList" class="IllustItemList">
        <%for(int nCnt = 0; nCnt< cFollowListResults.m_vContentList.size(); nCnt++) {
            CUser cUser = cFollowListResults.m_vContentList.get(nCnt);%>
        <%=CCnv.toHtml(cUser, CCnv.MODE_PC, _TEX)%>
        <%if(bSmartPhone && (nCnt+1)%18==0) {%>
        <%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
        <%}%>
        <%}%>
    </div>

    <%if(!bSmartPhone) {%>
    <div class="PcSideBar" style="margin-top: 16px;">
        <div class="FixFrame">
            <div class="PcSideBarItem">
                <%@ include file="/inner/TAdPc300x250_top_right.jsp"%>
            </div>

            <div class="PcSideBarItem">
                <%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
            </div>
        </div>
    </div>
    <%}%>

    <nav id="FollowListPageBar" class="PageBar">
        <%=CPageBar.CreatePageBar(null, null, cFollowListResults.m_nPage, cFollowListResults.m_nContentsNum, cFollowListResults.SELECT_MAX_GALLERY)%>
    </nav>
</div>
