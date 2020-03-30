<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
    function DispMuteCharNum() {
        var nCharNum = 100 - $("#MuteKeywordText").val().length;
        $("#MuteKeywordTextNum").html(nCharNum);
    }

    function UpdateMuteKeyword() {
        var strMuteKeywordTxt = $.trim($("#MuteKeywordText").val());
        $.ajaxSingle({
            "type": "post",
            "data": { "UID": <%=cCheckLogin.m_nUserId%>, "DES": strMuteKeywordTxt },
            "url": "/f/UpdateMuteKeywordF.jsp",
            "dataType": "json",
            "success": function(data) {
                DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
            },
            "error": function(req, stat, ex){
                DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
            }
        });
        return false;
    }

    $(function(){
       DispMuteCharNum();
    });
</script>

<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle">キーワード設定</div>
        <div class="SettingBody">
            <%=_TEX.T("EditSettingV.MuteKeyowrd.Message")%>
            <textarea id="MuteKeywordText" class="SettingBodyTxt" rows="6" onkeyup="DispMuteCharNum()" maxlength="100" placeholder="<%=_TEX.T("EditSettingV.MuteKeyowrd.PlaceHolder")%>"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strMuteKeyword)%></textarea>
            <div class="SettingBodyCmd">
                <div id="MuteKeywordTextNum" class="RegistMessage" >100</div>
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateMuteKeyword()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
            </div>
        </div>
    </div>
</div>
