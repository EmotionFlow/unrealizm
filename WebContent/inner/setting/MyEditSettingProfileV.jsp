<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
    function CheckInput() {
        var bRtn = true;
        var strMessage = "&nbsp;";
        try {
            var strUserName = $.trim($("#RegistUserName").val());
            if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
                strMessage = "<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>";
                bRtn = false;
            }
        } finally {
            $("#UserNameMessage").html(strMessage);
        }
        return bRtn;
    }

    function UpdateNickName() {
        var strUserName = $.trim($("#RegistUserName").val());
        if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
            DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>");
            return;
        }
        $.ajaxSingle({
            "type": "post",
            "data": { "ID":<%=cCheckLogin.m_nUserId%>, "NN":strUserName},
            "url": "/f/UpdateNickNameF.jsp",
            "dataType": "json",
            "success": function(data) {
                DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Ok")%>");
            },
            "error": function(req, stat, ex){
                DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
            }
        });
        return false;
    }

    function updateFile(url, objTarg){
        if (objTarg.files.length>0 && objTarg.files[0].type.match('image.*')) {
            DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
            var fileReader = new FileReader();
            fileReader.onloadend = function() {
                var strEncodeImg = fileReader.result;
                var mime_pos = strEncodeImg.substring(0, 100).indexOf(",");
                if(mime_pos==-1) return;
                strEncodeImg = strEncodeImg.substring(mime_pos+1);
                $.ajaxSingle({
                    "type": "post",
                    "data": {"UID":<%=cCheckLogin.m_nUserId%>, "DATA":strEncodeImg},
                    "url": url,
                    "dataType": "json",
                    "success": function(res) {
                        switch(res.result) {
                            case 0:
                                // complete
                                DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
                                sendObjectMessage("reloadParent");
                                location.reload(true);
                                break;
                            case -1:
                                // file size error
                                DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>");
                                break;
                            case -2:
                                // file type error
                                DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>");
                                break;
                            default:
                                DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + res.result);
                                break;
                        }
                    },
                    "error": function(req, stat, ex){
                        DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
                    }
                });
            }
            fileReader.readAsDataURL(objTarg.files[0]);
        }
        return false;
    }

    function UpdateProfileFile(objTarg){
        updateFile("/f/UpdateProfileFileF.jsp", objTarg);
    }

    function UpdateProfileHeaderFile(objTarg){
        updateFile("/f/UpdateProfileHeaderFileF.jsp", objTarg);
    }

    function UpdateProfileBgFile(objTarg){
        updateFile("/f/UpdateProfileBgFileF.jsp", objTarg);
    }

    function ResetProfileFile(nMode){
        $.ajaxSingle({
            "type": "post",
            "data": { "ID":<%=cCheckLogin.m_nUserId%>, "MD":nMode},
            "url": "/f/ResetProfileFileF.jsp",
            "dataType": "json",
            "success": function(data) {
                sendObjectMessage("reloadParent");
                location.reload(true);
            },
            "error": function(req, stat, ex){
                DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
            }
        });
        return false;
    }

    function DispDescCharNum() {
    	var nCharNum = 1000 - $("#EditBio").val().length;
    	$("#ProfileTextMessage").html(nCharNum);
    }

    function UpdateProfileTxt() {
        var strProfileTxt = $.trim($("#EditBio").val());
        $.ajaxSingle({
            "type": "post",
            "data": { "ID":<%=cCheckLogin.m_nUserId%>, "DES":strProfileTxt},
            "url": "/f/UpdateProfileTxtF.jsp",
            "dataType": "json",
            "success": function(data) {
                DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
                sendObjectMessage("reloadParent");
            },
            "error": function(req, stat, ex){
                DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
            }
        });
        return false;
    }

    $(function () {
        DispDescCharNum();
    })
</script>

<style>
    .UserInfo {
        background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');
    }
    .UserInfo .UserInfoUser .UserInfoUserThumbEdit {
        display: block;
        width: 84px;
        height: 84px;
        overflow: hidden;
        margin: -42px auto 0 auto;
        background-size: cover;
        position: relative;
    }

    .UserInfo .UserInfoUser .UserInfoUserThumbEdit .UserInfoUserImg {
        background-image: url(//img.poipiku.com/img/default_user.jpg);
        border-radius: 80px;
        border: solid 2px #ccc;
        width: 80px;
        height: 80px;
        background-color: #fff;
        margin: 0 auto 0 auto;
        background-position: 50% 50%;
    }

    .UserInfo .UserInfoUser .UserInfoUserThumbEdit .UserInfoUserImgUpload{
        background: url(/img/menu_pc-03.png) no-repeat;
        background-position: -30px 0px;
        background-size: 450px;
        background-color: #fff;
        width: 30px;
        height: 30px;
        top: 50px;
        left: 50px;
        overflow: overlay;
        position: absolute;
        border-radius: 30px;
        border: solid 2px #ccc;
    }
    .SelectFile{
        opacity: 0;
        width: 30px;
        height: 30px;
    }
    .UserInfo .UserInfoBg .UserInfoPreview {
        top: 9px;
        left: 7px;
        overflow: overlay;
        position: absolute;
    }
    .UserInfo .UserInfoBg .UserInfoHeaderUpload {
        background: url(/img/menu_pc-03.png) no-repeat;
        background-position: -30px 0px;
        background-size: 450px;
        background-color: #fff;
        width: 30px;
        height: 30px;
        top: 5px;
        right: 7px;
        overflow: overlay;
        position: absolute;
        border-radius: 30px;
        border: solid 2px #ccc;
    }
</style>

<div class="SettingList">
    <div class="UserInfo Float">
        <div class="UserInfoBg" style="position: relative;">
            <div class="UserInfoHeaderUpload">
                <input class="SelectFile" type="file" name="file_header" id="file_header" onchange="UpdateProfileHeaderFile(this)" />
            </div>
        </div>
        <section class="UserInfoUser">
            <div class="UserInfoUserThumbEdit">
                <%if(!cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
                <div class="UserInfoUserImg" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>');"></div>
                <%} else { %>
                <div class="UserInfoUserImg"></div>
                <%}%>

                <div class="UserInfoUserImgUpload">
                    <input class="SelectFile" type="file" name="file_thumb" id="file_thumb" onchange="UpdateProfileFile(this)" />
                </div>
            </div>
            <h2 class="UserInfoUserName">
                <div class="SettingBody">
                    <input id="RegistUserName" class="SettingBodyTxt" type="text" placeholder="<%=_TEX.T("EditSettingV.NickName.PlaceHolder")%>" value="<%=Common.ToStringHtml(cResults.m_cUser.m_strNickName)%>" maxlength="16" onkeyup="CheckInput()" />
                    <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNickName()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
                    <div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
                </div>
            </h2>
            <span class="UserInfoCmd">
                <%
                    String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
                            URLEncoder.encode(String.format("%s%s %s #%s",
                                    cResults.m_cUser.m_strNickName,
                                    _TEX.T("Twitter.UserAddition"),
                                    String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nPublishedContentsTotal),
                                    _TEX.T("Common.Title")), "UTF-8"),
                            URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"));
                %>
                <span class="IllustItemCommandSub">
                    <a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
                </span>
            </span>
        </section>
        <section class="UserInfoState">
            <a class="UserInfoStateItem Selected" href="/<%=cResults.m_cUser.m_nUserId%>/">
                <span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
                <span class="UserInfoStateItemNum"><%=cResults.m_nPublishedContentsTotal%></span>
            </a>
            <a class="UserInfoStateItem" href="/FollowListPcV.jsp">
                <span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
                <span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
            </a>
        </section>
    </div>

    <div class="SettingListItem">
        <div class="SettingBody" style="text-align: center;">
            <div class="SettingBodyCmd">
                <div id="ProfileImageMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.Image")%><br/>
                    (<%=_TEX.T("EditSettingV.Image.Format")%>)
                    <%if(!cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
                    <br/><a class="BtnBase" href="javascript:void(0)" onclick="ResetProfileFile(1)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
                    <%}%>
                </div>
            </div>
            <div class="SettingBodyCmd">
                <div id="ProfileImageMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.HeaderImage")%><br/>
                    (<%=_TEX.T("EditSettingV.HeaderImage.Format")%>)
                    <%if(!cResults.m_cUser.m_strHeaderFileName.equals("/img/default_transparency.gif")) {%>
                    <br/><a class="BtnBase" href="javascript:void(0)" onclick="ResetProfileFile(2)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
                    <%}%>
                </div>
            </div>
        </div>
    </div>

    <div class="SettingListItem" style="display: none;">
        <div class="SettingListTitle"><%=_TEX.T("EditSettingV.BgImage")%></div>
        <div class="SettingBody">
            <div class="FileSelectFrame" style="border: solid 1px #eee;">
                <div style="position: absolute; top:0; left: 0; width: 100%; height: 100%; background-size: cover; background-repeat: no-repeat; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strBgFileName)%>?<%=Math.random()%>');"></div>
                <input class="SelectFile" type="file" name="file_bg" id="file_bg" onchange="UpdateProfileBgFile(this)" />
                <%if(cResults.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {%>
                <span class="typcn typcn-plus-outline"></span>
                <%} else {%>
                <span style="text-shadow: none; color: #6d6965;"><%=_TEX.T("EditSettingV.Image.Saving")%></span>
                <%}%>
            </div>
            <div class="SettingBodyCmd">
                <div id="ProfileImageMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.HeaderImage.Format")%></div>
                <%if(!cResults.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {%>
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(3)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
                <%}%>
            </div>
        </div>
    </div>
    <div class="SettingListItem">
        <div class="SettingListTitle"><%=_TEX.T("EditSettingV.Bio")%></div>
        <div class="SettingBody">
            <textarea id="EditBio" class="SettingBodyTxt" rows="6" onkeyup="DispDescCharNum()" maxlength="1000"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strProfile)%></textarea>
            <div class="SettingBodyCmd">
                <div id="ProfileTextMessage" class="RegistMessage" >1000</div>
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateProfileTxt()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
            </div>
        </div>
    </div>

    <div class="SettingListItem">
        <div class="SettingListTitle">
            <a style="text-decoration: underline;" href="https://poipiku.com/<%=cResults.m_cUser.m_nUserId%>/">公開用イラスト箱</a>
        </div>
        <div class="SettingBody">
            <div style="display: table; width:100%">
                <div style="display: table-cell; text-align: left; vertical-align: top;">
                <input style="width: 100%;" id="MyBoxUrlTxt" type="text" readonly="" value="https://poipiku.com/<%=cResults.m_cUser.m_nUserId%>/">
                </div>
                <div style="display: table-cell; text-align: right; vertical-align: top;width: 76px;">
                <a id="CopyMyBoxUrlBtn" class="BtnBase" href="javascript:void(0);">コピー</a>
                </div>
            </div>
        </div>
    </div>
</div>