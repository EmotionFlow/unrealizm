<%@ page import="twitter4j.UserList" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="OptionItem" style="font-weight: bold;">
	<label class="rocker" onclick="updateOptionPublish()">
		<input id="OPTION_PUBLISH" type="checkbox">
		<span class="switch-left">公開する</span>
		<span class="switch-right">公開しない</span>
	</label>
</div>
<div class="OptionItem" id="ItemTimeLimited">
	<label class="rocker" onclick="updateOptionLimitedTimePublish()">
		<input id="OPTION_NOT_TIME_LIMITED" type="checkbox">
		<span class="switch-left">常時</span>
		<span class="switch-right">期間指定</span>
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
		<span class="switch-left">配慮・NSFW不要</span>
		<span class="switch-right">指定する</span>
	</label>
</div>
<div class="OptionItem" id="ItemNsfwVal" style="display: none;">
	<div class="OptionPublishNsfwList">
		<input type="radio" name="NSFW_VAL" value="<%=Common.SAFE_FILTER_R15%>" id="RadioOneCushion">
		<label for="RadioOneCushion" class="OptionPublishNsfw">
			<span class="OneCushionImage OneCushion"></span>
			<span class="OneCushionName">ワンクッション</span>
		</label>
		<input type="radio" name="NSFW_VAL" value="<%=Common.SAFE_FILTER_R18%>" id="RadioR18">
		<label for="RadioR18" class="OptionPublishNsfw">
			<span class="OneCushionImage R18"></span>
			<span class="OneCushionName">R18</span>
		</label>
	</div>
</div>

<div class="OptionItem">
	<label class="rocker" onclick="updateOptionShowLimit()">
		<input id="OPTION_NO_CONDITIONAL_SHOW" type="checkbox">
		<span class="switch-left">誰でも閲覧OK</span>
		<span class="switch-right">限定する</span>
	</label>
</div>
<div class="OptionItem" id="ItemShowLimitVal" style="padding-top: 0; display: none;">
	<div class="OptionPublishShowLimitList">
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_LOGIN%>" id="RadioPoipikuLogin">
		<label for="RadioPoipikuLogin" class="OptionShowLimit">
			<span class="ShowLimitImage PoipikuLogin"></span>
			<span class="ShowLimitName">ログイン限定</span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_FOLLOWER%>" id="RadioPoipikuFollower">
		<label for="RadioPoipikuFollower" class="OptionShowLimit">
			<span class="ShowLimitImage PoipikuFollower"></span>
			<span class="ShowLimitName">こそフォロ限定</span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_T_FOLLOWER%>" id="RadioTwitterFollower">
		<label for="RadioTwitterFollower" class="OptionShowLimit">
			<span class="ShowLimitImage TwitterFollower"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i>フォロワー限定</span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_T_LIST%>" id="RadioTwitterList">
		<label for="RadioTwitterList" class="OptionShowLimit" onclick="updateMyTwitterListF(<%=checkLogin.m_nUserId%>)">
			<span class="ShowLimitImage TwitterList"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i>リスト限定</span>
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
					<script>twtterListRateLimiteExceededMsg()</script>
					<%}else if(nTwLstRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){%>
					<script>twtterListInvalidTokenMsg()</script>
					<%}else if(nTwLstRet==CTweet.ERR_OTHER){%>
					<script>twtterListOtherErrMsg()</script>
					<%}else if(nTwLstRet==CTweet.OK && !bTwListFound){%>
					<script>twtterListNotFoundMsg()</script>
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
		<label for="RadioTwitterEach" class="OptionShowLimit">
			<span class="ShowLimitImage TwitterEach"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i>相互限定</span>
		</label>
		<input type="radio" name="SHOW_LIMIT_VAL" value="<%=Common.PUBLISH_ID_T_RT%>" id="RadioTwitterRetweet">
		<label for="RadioTwitterRetweet" class="OptionShowLimit">
			<span class="ShowLimitImage TwitterRetweet"></span>
			<span class="ShowLimitName"><i class="fab fa-twitter"></i>リツイート限定</span>
		</label>
	</div>
</div>

<div class="OptionItem">
	<label class="rocker" onclick="updateOptionPassword()">
		<input id="OPTION_NO_PASSWORD" type="checkbox">
		<span class="switch-left">パスワードなし</span>
		<span class="switch-right">あり</span>
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
		<span class="switch-left">最初の１枚見せる</span>
		<span class="switch-right">見せない</span>
	</label>
</div>
<%}%>

<div class="OptionItem" style="margin-top: 13px">
	<label class="rocker" onclick="updateOptionTweet()">
		<input id="OPTION_TWEET" type="checkbox">
		<span class="switch-left">同時にツイート</span>
		<span class="switch-right">しない</span>
	</label>
</div>

<%if(nEditorId==Common.EDITOR_UPLOAD || nEditorId==Common.EDITOR_PASTE || nEditorId==Common.EDITOR_BASIC_PAINT){%>
<div class="OptionItem Sub" id="OptionItemTweetImage" style="display: none">
	<label class="rocker sub">
		<input id="OPTION_TWEET_IMAGE" type="checkbox">
		<span class="switch-left">画像もツイート</span>
		<span class="switch-right">しない</span>
	</label>
</div>
<%}%>

<%if(!isCreateContent){%>
<div class="OptionItem">
	<label class="rocker">
		<input id="OPTION_DELETE_TWEET" type="checkbox">
		<span class="switch-left">前のツイート削除</span>
		<span class="switch-right">残す</span>
	</label>
</div>
<%}%>

<%if(nEditorId==Common.EDITOR_UPLOAD || nEditorId==Common.EDITOR_PASTE || nEditorId==Common.EDITOR_BASIC_PAINT){%>
<div class="OptionItem">
	<label class="rocker" onclick="updateOptionPassword()">
		<input id="OPTION_TWITTER_CARD_THUMBNAIL" type="checkbox">
		<span class="switch-left" style="font-size:0.8em">Twitterカードにサムネ表示</span>
		<span class="switch-right">表示しない</span>
	</label>
</div>
<%}%>

<div class="OptionItem" style="margin-top: 13px">
	<label class="rocker" onclick="updateOptionPassword()">
		<input id="OPTION_CHEER_NG" type="checkbox">
		<span class="switch-left">ポチ袋OFF</span>
		<span class="switch-right">ON</span>
	</label>
</div>

<div class="OptionItem" style="margin-top: 13px">
	<label class="rocker">
		<input id="OPTION_RECENT" type="checkbox">
		<span class="switch-left">新着に載せる</span>
		<span class="switch-right">避ける</span>
	</label>
</div>
