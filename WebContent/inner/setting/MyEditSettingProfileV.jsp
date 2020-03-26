<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="UserInfo Float">
    <div class="UserInfoBg" style="position: relative;">
        <div class="UserInfoPreview">
            <a class="BtnBase UserInfoCmdFollow" href="/<%=cResults.m_cUser.m_nUserId%>/"><i class="fas fa-home"></i> プレビュー</a>
        </div>
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
        <!--
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					-->
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
						<a class="BtnBase UserInfoCmdFollow" href="/FollowListPcV.jsp">★ 一覧</a>
						<a class="BtnBase UserInfoCmdFollow" href="/FollowListPcV.jsp?MD=1"><i class="typcn typcn-cancel"></i>一覧</a>
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
