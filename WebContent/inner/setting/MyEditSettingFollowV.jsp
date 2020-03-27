<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    FollowListC cFollowListResults = new FollowListC();
    cFollowListResults.getParam(request);
    cFollowListResults.m_nMode = 0;
    cFollowListResults.m_nPage = cResults.m_nListPage;
    cFollowListResults.getResults(cCheckLogin);
%>
<div class="SettingList">
    <div id="IllustThumbList" class="IllustItemList">
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

    <nav class="PageBar">
        <%=CPageBar.CreatePageBar(null, null, cFollowListResults.m_nPage, cFollowListResults.m_nContentsNum, cFollowListResults.SELECT_MAX_GALLERY)%>
    </nav>
</div>
