<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">

    function DeregistTwitter() {
        $.ajaxSingle({
            "type": "post",
            "data": { "ID":<%=cCheckLogin.m_nUserId%>},
            "url": "/f/DeregistTwitterF.jsp",
            "dataType": "json",
            "success": function(data) {
                location.reload(true);
            },
            "error": function(req, stat, ex){
                DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
            }
        });
        return false;
    }

    function UpdateAutoTweet() {
        var bAutoTweet = $('#AutoTweet').prop('checked');
        var nAutoTweetWeekDay = parseInt($('#AutoTweetWeekDay').val(), 10);
        var nAutoTweetTime = parseInt($('#AutoTweetTime').val(), 10);
        var strAutoTweetTxt = $.trim($("#AutoTweetTxt").val());
        var nAutoTweetThumbNum = ($('#AutoTweetThumb').prop('checked'))?9:0;
        if(!bAutoTweet) {
            nAutoTweetWeekDay = -1;
            nAutoTweetTime = -1;
        }
        $.ajaxSingle({
            "type": "post",
            "data": {
                "ID": <%=cCheckLogin.m_nUserId%>,
                "AW": nAutoTweetWeekDay,
                "AT": nAutoTweetTime,
                "AD": strAutoTweetTxt,
                "ATN": nAutoTweetThumbNum},
            "url": "/f/UpdateAutoTweetF.jsp",
            "dataType": "json",
            "success": function(data) {
                DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
                sendObjectMessage("reloadParent");
            },
            "error": function(req, stat, ex){
                DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
            }
        });
        return false;
    }

    function DispAutoTweetCharNum() {
        var nCharNum = 100 - $("#AutoTweetTxt").val().length;
        $("#AutoTweetTxtNum").html(nCharNum);
    }

    $(function () {
        DispAutoTweetCharNum();
    })
</script>

<div class="SettingList">
    <div class="SettingListItem" style="border: none;">
        <a id="TwitterSetting" name="TwitterSetting"></a>
        <div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter")%></div>
        <div class="SettingBody">
            <%=_TEX.T("EditSettingV.Twitter.Info")%>
            <div class="SettingBodyCmd">
                <div class="RegistMessage" >[<%=(cResults.m_cUser.m_bTweet)?String.format(_TEX.T("EditSettingV.Twitter.Info.State.On"), cResults.m_cUser.m_strTwitterScreenName):_TEX.T("EditSettingV.Twitter.Info.State.Off")%>]</div>
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="location.href='/TokenFormTwitterPc.jsp'"><%=_TEX.T("EditSettingV.Twitter.Button")%></a>
            </div>
            <%if(cResults.m_cUser.m_bTweet){%>
            <!--
						<div class="SettingBodyCmd">
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="DeregistTwitter()"><%=_TEX.T("EditSettingV.Twitter.Button.Deregist")%></a>
						</div>
						-->
            <%}%>
        </div>
    </div>

    <%if(cResults.m_cUser.m_bTweet){%>
    <div id="SectionAutoTweet" class="SettingListItem">
        <div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.Auto")%></div>
        <div class="SettingBody">
            <%=_TEX.T("EditSettingV.Twitter.Auto.Info")%>
            <div class="SettingBodyCmd">
                <div class="onoffswitch OnOff">
                    <input type="checkbox" name="AutoTweet" class="onoffswitch-checkbox" id="AutoTweet" value="1" <%if(cResults.m_cUser.m_nAutoTweetTime>=0){%>checked="checked"<%}%> />
                    <label class="onoffswitch-label" for="AutoTweet">
                        <span class="onoffswitch-inner"></span>
                        <span class="onoffswitch-switch"></span>
                    </label>
                </div>
                <script>
                    $('#AutoTweet').change(function(){
                        var bAutoTweet = $('#AutoTweet').prop('checked');
                        $('#AutoTweetWeekDay').prop('disabled', !bAutoTweet);
                        $('#AutoTweetTime').prop('disabled', !bAutoTweet);
                        $('#AutoTweetTxt').prop('disabled', !bAutoTweet);
                        $('#AutoTweetThumb').prop('disabled', !bAutoTweet);
                        //UpdateAutoTweet();
                    });
                </script>
            </div>
            <div class="SettingBodyCmd">
                <select id="AutoTweetWeekDay" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
                    <option value="-1"><%=_TEX.T("EditSettingV.Twitter.Auto.WeekDay.DayEvery")%></option>
                    <%for(int nTime=0; nTime<7; nTime++) {%>
                    <option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetWeekDay==nTime){%>selected="selected"<%}%>><%=_TEX.T(String.format("EditSettingV.Twitter.Auto.WeekDay.Day%d", nTime))%></option>
                    <%}%>
                </select>
            </div>
            <div class="SettingBodyCmd">
                <select id="AutoTweetTime" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
                    <%for(int nTime=0; nTime<24; nTime++) {%>
                    <option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetTime==nTime){%>selected="selected"<%}%>><%=nTime%><%=_TEX.T("EditSettingV.Twitter.Auto.Unit")%></option>
                    <%}%>
                </select>
            </div>
            <div class="SettingBodyCmd">
                <%if(cResults.m_cUser.m_strAutoTweetDesc.isEmpty()) {
                    cResults.m_cUser.m_strAutoTweetDesc = String.format("%s%s%s https://poipiku.com/%d/ #%s",
                            _TEX.T("EditSettingV.Twitter.Auto.AutoTxt"),
                            cResults.m_cUser.m_strNickName,
                            _TEX.T("Twitter.UserAddition"),
                            cResults.m_cUser.m_nUserId,
                            _TEX.T("Common.Title"));
                }%>
                <textarea id="AutoTweetTxt" class="SettingBodyTxt" rows="6" onkeyup="DispAutoTweetCharNum()" maxlength="100"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strAutoTweetDesc)%></textarea>
            </div>
            <div class="SettingBodyCmd">
                <div id="AutoTweetTxtNum" class="RegistMessage" >100</div>
            </div>
            <div class="SettingBodyCmd">
                <%=_TEX.T("EditSettingV.Twitter.Auto.ThumbNum")%>&nbsp;
                <div class="onoffswitch OnOff">
                    <input type="checkbox" name="AutoTweetThumb" class="onoffswitch-checkbox" id="AutoTweetThumb" value="1" <%if(cResults.m_cUser.m_nAutoTweetThumbNum>0){%>checked="checked"<%}%> />
                    <label class="onoffswitch-label" for="AutoTweetThumb">
                        <span class="onoffswitch-inner"></span>
                        <span class="onoffswitch-switch"></span>
                    </label>
                </div>
            </div>
            <div class="SettingBodyCmd">
                <div class="RegistMessage" ></div>
                <a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateAutoTweet()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
            </div>
        </div>
    </div>
    <%}%>
</div>
