<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    FollowListC cBlockListResults = new FollowListC();
    cBlockListResults.getParam(request);
    cBlockListResults.m_nMode = 1;
    cBlockListResults.m_nPage = cResults.m_nListPage;
    cBlockListResults.getResults(cCheckLogin);
%>
<div class="SettingList">
    <div id="IllustThumbList" class="IllustItemList">
        <%for(int nCnt = 0; nCnt< cBlockListResults.m_vContentList.size(); nCnt++) {
            CUser cUser = cBlockListResults.m_vContentList.get(nCnt);%>
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
        <%=CPageBar.CreatePageBar("", "", cBlockListResults.m_nPage, cBlockListResults.m_nContentsNum, cBlockListResults.SELECT_MAX_GALLERY)%>
    </nav>
</div>
