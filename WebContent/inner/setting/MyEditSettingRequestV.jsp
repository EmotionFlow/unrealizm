<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	RequestCreator requestCreator = new RequestCreator(checkLogin);
%>
<% if (checkLogin.isStaff()) { %>
<script type="text/javascript">
	function _getJudgeOkHtml() {
		return `
		<h1>募集を開始しました</h1>
		<p style="text-align: left">募集開始のメールを、ポイピクに登録されているメールアドレス宛に送信しました。ご確認くださいませ。</p>
		<p style="text-align: left">また、いま一度、予備のログイン手段として、メールとパスワードの組合せでログインできることをご確認願います。</p>
		`;
	}

	function _getJudgeFailureHtml() {
		return `
		<h1>募集を開始できませんでした</h1>
		<p style="text-align: left">リクエスト募集を開始するには、以下の条件が必須です。</p>
		<ul style="text-align: left">
		<li>Twitterアカウントと連携していること(Twitter設定)</li>
		<li>メールアドレスとパスワードが登録・確認されていること(メールログイン設定)</li>
		</ul>
		<p style="text-align: left">加えて、ポイピク・Twitterの利用歴から総合的に判定させていただいております。</p>
		<p style="text-align: left">不正利用防止の観点から、ご協力よろしくお願いいたします。</p>
		`;
	}

	function _updateRequestSetting(attribute, variable){
		$.ajax({
			"type": "post",
			"data": {"ID":<%=checkLogin.m_nUserId%>, "ATTR":attribute, "VAL":variable},
			"url": "/f/UpdateSettingRequestF.jsp",
			"dataType": "json"
		})
		.then(
			(data) => {
				if (data.result === <%=Common.API_OK%>) {
					Swal.fire({
						type: "info",
						html: _getJudgeOkHtml(),
					});
				} else if (data.error_code === <%=Controller.ErrorKind.JudgeFailure.getCode()%>) {
					Swal.fire({
						type: "warning",
						html: _getJudgeFailureHtml(),
					});
				}
			},
			(error) => {
				DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
			}
		);
	}

	function updateRequestEnabled(){
		const checked = $("#RequestEnabled").prop("checked") ? 1 : 0;
		_updateRequestSetting("RequestEnabled", checked);
		$("#RequestSettingItems").css('opacity', checked ? 1.0 : 0.5);
	}
	function updateRequestMedia(){
		const allowIllust = $("#RequestMediaIllust").prop("checked") ? 1 : 0;
		const allowNovel = $("#RequestMediaNovel").prop("checked") ? 1 : 0;
		if (allowIllust===0 && allowNovel===0) {
			DispMsg("メディアは１つ以上チェックしてください");
			return false;
		}
		_updateRequestSetting("RequestMedia", String(allowIllust) + "," + String(allowNovel));
	}
	function updateAllowSensitive(){
		_updateRequestSetting("AllowSensitive", $("#AllowSensitive").prop("checked") ? 1 : 0);
	}

	function _validateRange(min, max, value) {
		if (value < min || value > max) {
			DispMsg(String(min) + "から" + String(max) + "の範囲で入力してください");
			return false;
		}
		return true;
	}
	function _validateEmpty(value) {
		if (!value) {
			DispMsg("設定したい値を数字で入力してください");
			return false;
		}
		return true;
	}
	function updateReturnPeriod(){
		const returnPeriod = parseInt($("#ReturnPeriod").val(), 10);
		console.log(returnPeriod);
		if (!_validateEmpty(returnPeriod)) {
			return;
		}
		if (returnPeriod > parseInt($("#DeliveryPeriod").val(), 10)) {
			DispMsg("納品締切日数以下の日数を指定してください");
			return;
		}
		if (_validateRange(
				<%=RequestCreator.RETURN_PERIOD_MIN%>,
				<%=RequestCreator.RETURN_PERIOD_MAX%>,
				returnPeriod
			)){
			_updateRequestSetting("ReturnPeriod", returnPeriod);
		}
	}
	function updateDeliveryPeriod(){
		const deliveryPeriod = parseInt($("#DeliveryPeriod").val(), 10);
		if (!_validateEmpty(deliveryPeriod)) {
			return;
		}
		if (deliveryPeriod < parseInt($("#ReturnPeriod").val(), 10)) {
			DispMsg("返答締切日数以上の日数を指定してください");
			return;
		}
		if (_validateRange(
			<%=RequestCreator.DELIVERY_PERIOD_MIN%>,
			<%=RequestCreator.DELIVERY_PERIOD_MAX%>,
			deliveryPeriod
		)){
			_updateRequestSetting("DeliveryPeriod", deliveryPeriod);
		}
	}
	function updateAmountLeftToMe(){
		const amountLeftToMe = parseInt($("#AmountLeftToMe").val(), 10);
		if (!_validateEmpty(amountLeftToMe)) {
			return;
		}
		if (amountLeftToMe < parseInt($("#AmountMinimum").val(), 10)) {
			DispMsg("最低金額以上の金額を指定してください");
			return;
		}
		if (_validateRange(
			<%=RequestCreator.AMOUNT_LEFT_TO_ME_MIN%>,
			<%=RequestCreator.AMOUNT_LEFT_TO_ME_MAX%>,
			amountLeftToMe
		)){
			_updateRequestSetting("AmountLeftToMe", amountLeftToMe);
		}
	}
	function updateAmountMinimum(){
		const amountMinimum = parseInt($("#AmountMinimum").val(), 10);
		if (!_validateEmpty(amountMinimum)) {
			return;
		}
		if (amountMinimum > parseInt($("#AmountLeftToMe").val(), 10)) {
			DispMsg("おまかせ金額以下のの金額を指定してください");
			return;
		}
		if (_validateRange(
			<%=RequestCreator.AMOUNT_MINIMUM_MIN%>,
			<%=RequestCreator.AMOUNT_MINIMUM_MAX%>,
			amountMinimum
		)){
			_updateRequestSetting("AmountMinimum", amountMinimum);
		}
	}
	function updateCommercialTransactionLawTxt(){
		const lawTxt = $("#CommercialTransactionLaw").val();
		_updateRequestSetting("CommercialTransactionLaw", lawTxt);
	}
	function copyMyRequestPageUrl(){
		$("#RequestPageUrl").select();
		document.execCommand("Copy");
		alert('コピーしました');
	}
</script>
<%@include file="../TRequestIntroduction.jsp"%>

<style>
	.RequestVarUnit {font-size: 18px;line-height: 28px;}
	.RequestListLink {
		width: 100%;
		display: block;
		text-align: right;
		margin-top: 2px;
		text-decoration: underline;
	}
</style>

<div class="SettingList">
	<div class="SettingListItem">
		<a class="RequestListLink" href="/MyRequestListPcV.jsp?MENUID=RECEIVED"><i class="far fa-clipboard"></i> マイリクエスト →</a>

		<a href="javascript: void(0);"
		   style="text-decoration: underline"
		   onclick="dispRequestIntroduction()">
			<i class="fas fa-info-circle"></i>リクエストとは
		</a>

		<div class="SettingListTitle">リクエストを募集する</div>
		<div class="SettingBody">
			クリエイターとしてポイピクユーザーからのリクエストを受け付けます。
			<ul>
				<li>募集を開始するにはメールアドレスの確認が必要です。</li>
				<li>リクエスト報酬を受け取るには日本の銀行口座が必要です。</li>
			</ul>
			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
				<div class="RegistMessage" >
					<div class="onoffswitch OnOff">
						<input type="checkbox"
							   name="onoffswitch"
							   class="onoffswitch-checkbox"
							   id="RequestEnabled"
							   value="0"
							   <%if(requestCreator.status==RequestCreator.Status.Enabled){%>checked="checked"<%}%> />
						<label class="onoffswitch-label" for="RequestEnabled">
							<span class="onoffswitch-inner"></span>
							<span class="onoffswitch-switch"></span>
						</label>
					</div>
				</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateRequestEnabled()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
			</div>
		</div>

		<div id="RequestSettingItems" <%if(requestCreator.status!=RequestCreator.Status.Enabled){%>style="opacity: 0.5;"<%}%> >
			<div class="SettingListItem">
				<div class="SettingListTitle">リクエストページURL</div>
				<div class="SettingBody">
					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
						<div class="RegistMessage" style="margin: 0; width:100%;">
							<input id="RequestPageUrl" style="width: 100%;" type="text" readonly value="https://poipiku.com/RequestNewPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
						</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="copyMyRequestPageUrl()">コピー</a>
					</div>
					<a style="text-decoration: underline;" href="https://poipiku.com/RequestNewPcV.jsp?ID=<%=checkLogin.m_nUserId%>">プレビュー</a>
				</div>

			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">メディア</div>
				リクエストを受け付けるメディアを設定します。
				<div class="SettingBody">
					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
						<div class="RegistMessage">
						<label>
							<input id="RequestMediaIllust" type="checkbox" <%if(requestCreator.allowIllust()){%>checked="checked"<%}%> >イラスト
						</label>
						<label>
							<input id="RequestMediaNovel" type="checkbox" <%if(requestCreator.allowNovel()){%>checked="checked"<%}%> >テキスト
						</label>
						</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateRequestMedia()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">ワンクッション・R18リクエスト</div>
				<div class="SettingBody">
					センシティブな内容のリクエストを許可します
					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
						<div class="RegistMessage">
							<div class="onoffswitch OnOff">
								<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="AllowSensitive" value="0" <%if(requestCreator.allowSensitive()){%>checked="checked"<%}%> />
								<label class="onoffswitch-label" for="AllowSensitive">
									<span class="onoffswitch-inner"></span>
									<span class="onoffswitch-switch"></span>
								</label>
							</div>
						</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAllowSensitive()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">返答締切日数</div>
				<div class="SettingBody">
					<div>
						<input id="ReturnPeriod" type="number" placeholder="<%=RequestCreator.RETURN_PERIOD_DEFAULT%>" value="<%=requestCreator.returnPeriod%>" maxlength="3" />
						<span class="RequestVarUnit">日</span>
					</div>
					<div class="RegistMessage" >リクエストの返答期限を設定します。<%=RequestCreator.RETURN_PERIOD_MIN%>日から<%=RequestCreator.RETURN_PERIOD_MAX%>日の間で設定できます。</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateReturnPeriod()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">納品締切日数</div>
				<div class="SettingBody">
					<div>
						<input id="DeliveryPeriod" type="number" placeholder="<%=RequestCreator.DELIVERY_PERIOD_DEFAULT%>" value="<%=requestCreator.deliveryPeriod%>" maxlength="3" />
						<span class="RequestVarUnit">日</span>
					</div>
					<div class="RegistMessage">リクエストを得た日からの納品期限を設定します。<%=RequestCreator.DELIVERY_PERIOD_MIN%>日から<%=RequestCreator.DELIVERY_PERIOD_MAX%>日の間で設定できます。返答締切日数より短くすることはできません。</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateDeliveryPeriod()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">おまかせ金額</div>
				<div class="SettingBody">
					<div>
						<span class="RequestVarUnit">¥</span>
						<input id="AmountLeftToMe" type="number" placeholder="<%=RequestCreator.AMOUNT_LEFT_TO_ME_DEFAULT%>" value="<%=requestCreator.amountLeftToMe%>" maxlength="5" />
					</div>
					<div class="RegistMessage">
						おまかせでリクエストされた時の金額を設定します。
						¥<%=String.format("%,d", RequestCreator.AMOUNT_LEFT_TO_ME_MIN)%>〜¥<%=String.format("%,d", RequestCreator.AMOUNT_LEFT_TO_ME_MAX)%>の間で設定できます。
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAmountLeftToMe()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">最低金額</div>
				<div class="SettingBody">
					<div>
						<span class="RequestVarUnit">¥</span>
						<input id="AmountMinimum" type="number" placeholder="<%=RequestCreator.AMOUNT_MINIMUM_DEFAULT%>" value="<%=requestCreator.amountMinimum%>" maxlength="16" />
					</div>
					<div class="RegistMessage">
						リクエスト最低金額を設定します。
						¥<%=String.format("%,d", RequestCreator.AMOUNT_MINIMUM_MIN)%>〜¥<%=String.format("%,d", RequestCreator.AMOUNT_MINIMUM_MAX)%>の間で設定できます。
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAmountMinimum()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<%if(false){ // まだなくても良い気がするので、非表示にしておく。%>
			<div class="SettingListItem">
				<div class="SettingListTitle">特定商取引法に基づく表記</div>
				特定商取引法で定められた内容を記載してください。特定商取引法に基づく表記を設定するべきかどうかはクリエイターガイドラインを確認してください。
				<div class="SettingBody">
					<textarea id="CommercialTransactionLaw" class="SettingBodyTxt" rows="6" maxlength="1000"><%=Util.toStringHtmlTextarea(requestCreator.commercialTransactionLaw)%></textarea>
					<div class="SettingBodyCmd">
						<div id="ProfileTextMessage" class="RegistMessage">1000文字まで</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateCommercialTransactionLawTxt()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<%}%>
		</div>
	</div>
</div>
<%}%>
