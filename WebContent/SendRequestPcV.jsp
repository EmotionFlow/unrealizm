<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/inner/Common.jsp" %>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if (!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request, response);
	return;
}

boolean bSmartPhone = Util.isSmartPhone(request);

// TODO write controller
IllustListC cResults = new IllustListC();
cResults.getParam(request);

if(!cResults.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>

	<title><%=_TEX.T("THeader.Title")%> - Request </title>

	<script>
		function startMsg() {
			$('#UoloadCmdBtn').addClass('Disabled').html('<%=_TEX.T("EditIllustVCommon.Uploading")%>');
			DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
		}

		function completeMsg() {
			DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
		}

		function errorMsg(result) {
			DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + data.result);
		}

		$(function () {
			initOption();
			DispDescCharNum();
		});

	</script>

	<style>
		.RequestTitle {
            text-align: center;
            font-weight: bold;
            width: 100%;
            margin-top: 10px;
            margin-bottom: 10px;
            font-size: 16px;
		}
		.RequestRule {
            background-color: #f6fafd;
            color: #6d6965;
            border-radius: 10px;
            margin: 4px;
            padding: 8px;
			font-size: 13px;
		}
	</style>

</head>
<body>
<%@ include file="/inner/TMenuPc.jsp" %>

<article class="Wrapper" <%if(!bSmartPhone){%>style="width: 100%;"<%}%>>
	<div class="UserInfo Float">
		<div class="UserInfoBg"></div>
		<section class="UserInfoUser">
			<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
			<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>
			<h3 class="UserInfoProgile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
		</section>
	</div>

	<div class="UploadFile"
		 style="<%if(!bSmartPhone){%>width: 60%; max-width: 60%; margin: 0 20%;<%}%>padding-bottom: 100px;">
		<div class="RequestTitle">
			<%=cResults.m_cUser.m_strNickName%>さんへリクエスト
		</div>
		<div class="UoloadCmdOption">
			<div class="OptionItem">
				<div class="OptionLabel">メディア</div>
				<div class="OptionPublish">
					<select id="EditMedia">
						<option value="1">イラスト</option>
					</select>
				</div>
			</div>
		</div>
		<div class="TextBody">
			リクエスト文
			<textarea id="EditTextBody" class="EditTextBody" maxlength="1" placeholder=""
					  onkeyup="DispTextCharNum()"></textarea>
			<div id="TextBodyCharNum" class="TextBodyCharNum">1</div>
		</div>

		<div class="UoloadCmdOption">
			<div class="OptionItem">
				<div class="OptionLabel">ワンクッション・R18相当リクエスト</div>
				<div class="onoffswitch OnOff">
					<input type="checkbox" class="onoffswitch-checkbox" name="OptionRecent" id="OptionRecent"
						   value="0"/>
					<label class="onoffswitch-label" for="OptionRecent">
						<span class="onoffswitch-inner"></span>
						<span class="onoffswitch-switch"></span>
					</label>
				</div>
			</div>
			<div class="OptionNotify">センシティブなリクエストは必ずON</div>

			<div id="ItemPassword" class="OptionItem">
				<div class="OptionLabel">リクエスト金額</div>
				<div class="OptionPublish">
					<input id="EditPassword" class="EditPassword" type="number" maxlength="6"
						   placeholder=""/>
				</div>
			</div>
			<div class="OptionNotify">¥3,000〜¥5,000</div>

			<div id="ItemPassword" class="OptionItem">
				<div class="OptionLabel">承認期限</div>
				<div class="OptionPublish">リクエスト送信から7日間</div>
			</div>
			<div id="ItemPassword" class="OptionItem">
				<div class="OptionLabel">納品期限</div>
				<div class="OptionPublish">リクエスト送信から60日間</div>
			</div>
			<div class="OptionNotify">期限を過ぎると自動でキャンセルされます</div>

		</div>

		<div class="TextBody" style="margin-bottom: 10px">
			ルール
			<div class="RequestRule">
				金額の見積もり・打ち合わせ・リテイク・著作権譲渡はできません。<br/>
				クリエイターとはリクエスト本文以外での連絡はできません。<br/>
				リクエストを報酬の送金手段として使用することはできません。<br/>
				個人鑑賞(SNSへの掲載・使用は含む)を超えた利用には本文へ用途の説明が必要。<br/>
				納品されなかった場合、各支払方法を通して返金されます。
			</div>
		</div>

		<div class="UoloadCmd">
			<a id="UoloadCmdBtn" class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="">リクエストを送信する</a>
		</div>

	</div>
</article>
</body>
</html>
