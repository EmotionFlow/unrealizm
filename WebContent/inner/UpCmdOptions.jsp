<%@ page import="twitter4j.UserList" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<script>
function DispR18PlusMsg() {
	DispMsg(`<%=_TEX.T("R18Plus.Msg")%><br><br>
<a href="javascript:void(0)" style="text-decoration: underline" onclick="DispR18PlusDlg()">
<i class="fas fa-info-circle"></i><%=_TEX.T("R18Plus.Msg.ShowDetail")%></a>`, 4000);
}
</script>

<div class="OptionItem" style="font-weight: bold;">
	<label class="rocker" onclick="updateOptionPublish()">
		<input id="OPTION_PUBLISH" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.Publish.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.Publish.UnChecked")%></span>
	</label>
</div>
<div class="OptionItem" id="ItemTimeLimited">
	<label class="rocker" onclick="updateOptionLimitedTimePublish()">
		<input id="OPTION_NOT_TIME_LIMITED" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.NotTimeLimited.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.NotTimeLimited.UnChecked")%></span>
	</label>
</div>
<div class="OptionItem" id="ItemTimeLimitedVal" style="padding-top: 0; display: none;">
	<div class="OptionPublish">
		<%if(Util.isSmartPhone(request)) {%>
		<div style="display: block;">
			<span><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.Start")%></span>
			<input id="TIME_LIMITED_START" class="EditTimeLimited" type="text" />
		</div>
		<div style="display: block;">
			<span><%=_TEX.T("UploadFilePc.Option.Publish.LimitedTime.End")%></span>
			<input id="TIME_LIMITED_END" class="EditTimeLimited" type="text" />
		</div>
		<%}else{%>
		<input id="TIME_LIMITED_START" class="EditTimeLimitedPc" type="text" maxlength="15" />
		<span class="EditTimeLimitedPcTo">〜</span>
		<input id="TIME_LIMITED_END" class="EditTimeLimitedPc" type="text" maxlength="15" />
		<%}%>
	</div>
	<%if(!isCreateContent && content.m_bLimitedTimePublish){
		final String strStartDateTime = Util.toYMDHMString(content.m_timeUploadDate);
		final String strEndDateTime = Util.toYMDHMString(content.m_timeEndDate);
	%>
	<input id="EditTimeLimitedStartPresent" value="<%=strStartDateTime%>" type="hidden" />
	<input id="EditTimeLimitedEndPresent" value="<%=strEndDateTime%>" type="hidden" />
	<script>
		initStartDatetime("<%=strStartDateTime%>");
		initEndDatetime("<%=strEndDateTime%>");
	</script>
	<%}%>

</div>
<div class="OptionItem" style="margin-top: 13px">
	<label class="rocker" onclick="updateOptionPublishNsfw()">
		<input id="OPTION_NOT_PUBLISH_NSFW" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.NoNsfw.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.NoNsfw.UnChecked")%></span>
	</label>
</div>
<div class="OptionItem" id="ItemNsfwVal" style="display: none;">
	<div class="OptionPublishNsfwList">
		<input type="radio" name="NSFW_VAL" value="<%=Common.SAFE_FILTER_R15%>" id="RadioOneCushion">
		<label for="RadioOneCushion" class="OptionPublishNsfw">
			<span class="OneCushionImage OneCushion"></span>
			<span class="OneCushionName"><%=_TEX.T("UpCmdOptions.Nsfw.OneCushion")%></span>
		</label>
		<input type="radio" name="NSFW_VAL" value="<%=Common.SAFE_FILTER_R18%>" id="RadioR18">
		<label for="RadioR18" class="OptionPublishNsfw">
			<span class="OneCushionImage R18"></span>
			<span class="OneCushionName"><%=_TEX.T("UpCmdOptions.Nsfw.R18")%></span>
		</label>
		<input type="radio" name="NSFW_VAL" value="<%=Common.SAFE_FILTER_R18_PLUS%>" id="RadioR18Plus">
		<label for="RadioR18Plus" class="OptionPublishNsfw" onclick="DispR18PlusMsg()">
			<span class="OneCushionImage R18Plus"></span>
			<span class="OneCushionName"><%=_TEX.T("UpCmdOptions.Nsfw.R18Plus")%></span>
		</label>
	</div>
</div>

<div class="OptionItem">
	<label class="rocker" onclick="updateOptionShowLimit()">
		<input id="OPTION_NO_CONDITIONAL_SHOW" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.NoConditionalShow.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.NoConditionalShow.UnChecked")%></span>
	</label>
</div>
<div class="OptionItem" id="ItemShowLimitVal" style="padding-top: 0; display: none;">
	<div class="OptionPublishShowLimitList">
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_LOGIN%>" id="RadioUnrealizmLogin">
		<label for="RadioUnrealizmLogin" class="OptionShowLimit">
			<span class="ShowLimitImage UnrealizmLogin"></span>
			<span class="ShowLimitName"><%=_TEX.T("UpCmdOptions.Condition.UnrealizmLogin")%></span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_FOLLOWER%>" id="RadioUnrealizmFollower">
		<label for="RadioUnrealizmFollower" class="OptionShowLimit">
			<span class="ShowLimitImage UnrealizmFollower"></span>
			<span class="ShowLimitName"><%=_TEX.T("UpCmdOptions.Condition.UnrealizmFollower")%></span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_T_FOLLOWER%>" id="RadioTwitterFollower">
		<label for="RadioTwitterFollower" class="OptionShowLimit"
			<%if(!cTweet.m_bIsTweetEnable){%>
			   onclick="DispMsg('<%=_TEX.T("UploadFilePc.Option.Publish.T_Disabled")%>');return false;"
			<%}%>
		>
			<span class="ShowLimitImage TwitterFollower"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i><%=_TEX.T("UpCmdOptions.Condition.TwitterFollower")%></span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_T_LIST%>" id="RadioTwitterList">
		<label for="RadioTwitterList" class="OptionShowLimit"
			<%if(!cTweet.m_bIsTweetEnable){%>
			   onclick="DispMsg('<%=_TEX.T("UploadFilePc.Option.Publish.T_Disabled")%>');return false;"
			<%}else{%>
			   onclick="updateMyTwitterListF(<%=checkLogin.m_nUserId%>)"
		    <%}%>
		>
			<span class="ShowLimitImage TwitterList"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i><%=_TEX.T("UpCmdOptions.Condition.TwitterList")%></span>
			<span class="ShowLimitName" id="TwitterList">
				<span id="TwitterListLoading" style="display: none"></span>
				<span id="TwitterListNotFound" style="display: none;"><%=_TEX.T("UploadFilePc.Option.Publish.T_List.NotFound")%></span>

				<%-- 更新画面におけるリスト限定のリスト復元 ここから --%>
				<%
					int nTwLstRet = -1;
					boolean bTwListFound = false;
				%>
				<select id="TWITTER_LIST_ID" class="EditPublish" style="display: none;">
					<%if(!isCreateContent && content != null && content.m_nPublishId == Common.PUBLISH_ID_T_LIST){%>
					<%
						if(bTwRet && cTweet.m_bIsTweetEnable){
							nTwLstRet = cTweet.GetMyOpenLists();
						}
						if(cTweet.m_listOpenList!=null){
							for(UserList l:cTweet.m_listOpenList){
					%>
							<option value="<%=l.getId()%>"
									<%if(!content.m_strListId.isEmpty() && l.getId() == Long.parseLong(content.m_strListId)) {
										bTwListFound = true;
									%> selected
									<%}%>
							><%=l.getName()%></option>
							<%} // for()%>
						<%} // if()%>
					<%}%>
				</select>
				<%if (!isCreateContent) {%>
					<%if(nTwLstRet==CTweet.ERR_RATE_LIMIT_EXCEEDED){%>
					<script>twitterListRateLimiteExceededMsg()</script>
					<%}else if(nTwLstRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){%>
					<script>twitterListInvalidTokenMsg()</script>
					<%}else if(nTwLstRet==CTweet.ERR_OTHER){%>
					<script>twitterListOtherErrMsg()</script>
					<%}else if(nTwLstRet==CTweet.OK && !bTwListFound){%>
					<script>twitterListNotFoundMsg()</script>
					<%}else if(nTwLstRet==CTweet.OK && bTwListFound){%>
					<script>$("#TWITTER_LIST_ID").show()</script>
					<%}%>
				<%}%>
				<%-- 更新画面におけるリスト限定のリスト復元 ここまで --%>

			</span>
		</label>
		<%--							<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_T_FOLLOWEE%>" id="RadioTwitterFollowee">--%>
		<%--							<label for="RadioTwitterFollowee" class="OptionShowLimit">--%>
		<%--								<span class="ShowLimitImage TwitterFollowee"></span>--%>
		<%--								<span class="ShowLimitName"><i class="fab fa-twitter"></i>フォロー限定</span>--%>
		<%--							</label>--%>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_T_EACH%>" id="RadioTwitterEach">
		<label for="RadioTwitterEach" class="OptionShowLimit"
			<%if(!cTweet.m_bIsTweetEnable){%>
			   onclick="DispMsg('<%=_TEX.T("UploadFilePc.Option.Publish.T_Disabled")%>');return false;"
			<%}%>
		>
			<span class="ShowLimitImage TwitterEach"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i><%=_TEX.T("UpCmdOptions.Condition.TwitterEach")%></span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_T_RT%>" id="RadioTwitterRetweet"
			<%if(!cTweet.m_bIsTweetEnable){%>
			   onclick="DispMsg('<%=_TEX.T("UploadFilePc.Option.Publish.T_Disabled")%>');return false;"
			<%}%>
		>
		<label for="RadioTwitterRetweet" class="OptionShowLimit">
			<span class="ShowLimitImage TwitterRetweet"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i><%=_TEX.T("UpCmdOptions.Condition.TwitterRetweet")%></span>
		</label>
	</div>
</div>

<div class="OptionItem">
	<label class="rocker" onclick="updateOptionPassword()">
		<input id="OPTION_NO_PASSWORD" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.NoPassword.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.NoPassword.UnChecked")%></span>
	</label>
</div>
<div id="ItemPassword" class="OptionItem" style="padding-top: 0; display: none;">
	<label for="PASSWORD_VAL"><i class="fas fa-key" style="margin-right: 5px"></i></label>
	<input id="PASSWORD_VAL" class="EditPassword" type="text" maxlength="16" />
</div>

<%if(nEditorId!=Common.EDITOR_TEXT){%>
<div class="OptionItem" id="OptionItemShowAllFirst" style="display: none">
	<label class="rocker">
		<input id="OPTION_SHOW_FIRST" type="checkbox" checked="checked">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.ShowFirst.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.ShowFirst.UnChecked")%></span>
	</label>
</div>
<%}%>

<div class="OptionItem" style="margin-top: 13px">
	<label class="rocker"
		<%if(!cTweet.m_bIsTweetEnable){%>
		   onclick="DispMsg('<%=_TEX.T("UploadFilePc.Option.Publish.T_Disabled")%>');return false;"
		<%}else{%>
		   onclick="updateOptionTweet()"
		<%}%>
	>
		<input id="OPTION_TWEET" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.Tweet.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.Tweet.UnChecked")%></span>
	</label>
</div>

<%if(nEditorId==Common.EDITOR_UPLOAD || nEditorId==Common.EDITOR_PASTE || nEditorId==Common.EDITOR_BASIC_PAINT){%>
<div class="OptionItem Sub" id="OptionItemTweetImage" style="display: none">
	<label class="rocker sub">
		<input id="OPTION_TWEET_IMAGE" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.TweetImage.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.TweetImage.UnChecked")%></span>
	</label>
</div>
<%}%>

<%if(!isCreateContent && cTweet.m_bIsTweetEnable){%>
<div class="OptionItem">
	<label class="rocker">
		<input id="OPTION_DELETE_TWEET" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.DeleteTweet.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.DeleteTweet.UnChecked")%></span>
	</label>
</div>
<%}%>

<%if(nEditorId==Common.EDITOR_UPLOAD || nEditorId==Common.EDITOR_PASTE || nEditorId==Common.EDITOR_BASIC_PAINT){%>
<div class="OptionItem">
	<label class="rocker" onclick="updateOptionPassword()">
		<input id="OPTION_TWITTER_CARD_THUMBNAIL" type="checkbox">
		<span class="switch-left" style="font-size:0.8em"><%=_TEX.T("UpCmdOptions.TwitterCardThumbnail.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.TwitterCardThumbnail.UnChecked")%></span>
	</label>
</div>
<%}%>

<%--<div class="OptionItem" style="margin-top: 13px">--%>
<%--	<label class="rocker" onclick="updateOptionPassword()">--%>
<%--		<input id="OPTION_CHEER_NG" type="checkbox">--%>
<%--		<span class="switch-left"><%=_TEX.T("UpCmdOptions.CheerNg.Checked")%></span>--%>
<%--		<span class="switch-right"><%=_TEX.T("UpCmdOptions.CheerNg.UnChecked")%></span>--%>
<%--	</label>--%>
<%--</div>--%>

<div class="OptionItem" style="margin-top: 13px">
	<label class="rocker">
		<input id="OPTION_RECENT" type="checkbox">
		<span class="switch-left"><%=_TEX.T("UpCmdOptions.Recent.Checked")%></span>
		<span class="switch-right"><%=_TEX.T("UpCmdOptions.Recent.UnChecked")%></span>
	</label>
</div>
