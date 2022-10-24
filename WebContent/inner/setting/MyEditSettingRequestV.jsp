<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
RequestCreator requestCreator = new RequestCreator(checkLogin);
%>
<script type="text/javascript">
	function _getJudgeOkHtml() {
		return `
		<h1>エアスケブ受付を開始しました</h1>
		<p style="text-align: left">エアスケブ受付開始のメールを、Unrealizmに登録されているメールアドレス宛に送信しました。</p>
		`;
	}

	function _getJudgeFailureHtml() {
		return `
		<h1>エアスケブ受付を開始できませんでした</h1>
		<p style="text-align: left">有償によるエアスケブ受付を開始するには、以下の条件が必須です。</p>
		<ul style="text-align: left">
		<li>メールアドレスとパスワードが登録・確認されていること(メールログイン設定)</li>
		</ul>
		<p style="text-align: left">加えて、Unrealizmの利用歴から総合的に判定させていただいております。</p>
		`;
	}

	function _getPaidRequestJudgeFailureHtml() {
		return `
		<h1>有償の受付を開始できませんでした</h1>
		<p style="text-align: left">有償によるエアスケブ受付を開始するには、以下の条件が必須です。</p>
		<ul style="text-align: left">
		<li>Twitterアカウントと連携していること(Twitter設定)</li>
		<li>メールアドレスとパスワードが登録・確認されていること(メールログイン設定)</li>
		</ul>
		<p style="text-align: left">加えて、unrealizm・Twitterの利用歴から総合的に判定させていただいております。</p>
		<p style="text-align: left">複数の連絡先確保と、不正利用防止の観点から、ご協力よろしくお願いいたします。</p>
		`;
	}

	function _updateRequestSetting(attribute, variable, apiOkCallback, judgeFailureCallback){
		$.ajax({
			"type": "post",
			"data": {"ID":<%=checkLogin.m_nUserId%>, "ATTR":attribute, "VAL":variable},
			"url": "/f/UpdateSettingRequestF.jsp",
			"dataType": "json"
		})
		.then(
			(data) => {
				if (data.result === <%=Common.API_OK%>) {
					apiOkCallback ? apiOkCallback() : DispMsg("保存しました");
				} else if (data.error_code === <%=Controller.ErrorKind.JudgeFailure.getCode()%>) {
					if (judgeFailureCallback) judgeFailureCallback();
				} else {
					DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
				}
			},
			(error) => {
				DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
			}
		);
	}

	function updateRequestEnabled(){
		const checked = $("#RequestEnabled").prop("checked") ? 1 : 0;
		_updateRequestSetting("RequestEnabled", checked, () => {
			if (checked === 1) {
				Swal.fire({
					type: "info",
					html: _getJudgeOkHtml(),
				}).then(()=>{location.reload();});
			} else {
				alert("エアスケブの受付を停止しました");
				location.reload();
			}
		}, () => {
			$("#RequestEnabled").removeAttr("checked");
			Swal.fire({
				'type': "info",
				'html': _getJudgeFailureHtml(),
			}).then(()=>{location.reload();});
		});
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
	function updateAllowAnonymous(){
		_updateRequestSetting("AllowAnonymous", $("#AllowAnonymous").prop("checked") ? 1 : 0);
	}

	function updateSelectPaidRequest(){
		const selected = $("#SelectPaidRequest").val();
		const $SettingAmountItems = $('#SettingAmountItems');
		if (selected === 'FREE') {
			_updateRequestSetting("AllowFreeRequest", 1);
			_updateRequestSetting("AllowPaidRequest", 0);
			$SettingAmountItems.hide();
		} else {
			_updateRequestSetting("AllowPaidRequest", 1, () => {
				_updateRequestSetting("AllowFreeRequest", 0);
				$SettingAmountItems.show();
			}, () => {
				$("#SelectPaidRequest").val('FREE');
				Swal.fire({
					'type': "info",
					'html': _getPaidRequestJudgeFailureHtml(),
				}).then(()=>{location.reload();});
			});
		}
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
			DispMsg("お渡し期限以下の日数を指定してください");
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
			DispMsg("返答期限以上の日数を指定してください");
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
	function updateProfile(){
		const profileTxt = $("#CreatorProfile").val();
		_updateRequestSetting("Profile", profileTxt);
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
	.RequestVarLimit {margin-left: 3px;font-size: 12px;}
	.RequestListLink {
		width: 100%;
		display: block;
		text-align: right;
		margin-top: 2px;
		text-decoration: underline;
	}
	.RequestWhatIs {
        margin: 10px 0;
        display: flex;
        justify-content: center;
	}
</style>

<div class="SettingList">
	<div class="SettingListItem">
		<div class="RequestWhatIs">
			<i class="fas fa-info-circle" style="font-size: 16px; line-height: 21px; margin-right: 2px;"></i>
			<a href="javascript: void(0);"
			   onclick="dispRequestIntroduction()">
				エアスケブとは？
			</a>
		</div>


		<div class="SettingListTitle">エアスケブの依頼を受け付ける</div>
		<div class="SettingBody">
			<%if(requestCreator.status!=RequestCreator.Status.Enabled){%>
			<div style="border: solid 2px lightgrey;border-radius: 5px; font-size: 12px; text-align: center; padding: 5px 0; margin: 0 16px 7px 16px;">
				<span style="color: coral; font-weight: bold">NEW!</span><br>Twitter連携なし(メアド登録のみ)でも<br>はじめられるようになりました</div>
			<%}%>
			<%if(requestCreator.status!=RequestCreator.Status.Enabled){%>
			クリエイターとしてUnrealizmユーザーからエアスケブの依頼を受け付けます。
			<%}else{%>
			受け付けを停止していても、現在受信している依頼は承認したり、制作物をお渡ししたりできます。
			<%}%>
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
				<div class="SettingListTitle">受付ページURL</div>
				<div class="SettingBody">
					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
						<div class="RegistMessage" style="margin: 0; width:100%;">
							<input id="RequestPageUrl" style="width: 100%;" type="text" readonly value="https://unrealizm.com/RequestNewPcV.jsp?ID=<%=checkLogin.m_nUserId%>">
						</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="copyMyRequestPageUrl()">コピー</a>
					</div>
					<a style="text-decoration: underline;" href="https://unrealizm.com/RequestNewPcV.jsp?ID=<%=checkLogin.m_nUserId%>">プレビュー</a>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">クリエイターメッセージ</div>
				得意なジャンルなど、依頼する方に向けてのメッセージを設定できます。受付ページの上部に表示されます。<br>
				<div class="SettingBody">
					<textarea id="CreatorProfile" class="SettingBodyTxt" rows="12" maxlength="5000" placeholder="空欄にするとプロフィールの自己紹介が表示されます"><%=Util.toStringHtmlTextarea(requestCreator.profile)%></textarea>
					<div class="SettingBodyCmd">
						<div id="CreatorProfileMessage" class="RegistMessage">5000文字まで</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateProfile()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
<%--			<div class="SettingListItem">--%>
<%--				<div class="SettingListTitle">メディア</div>--%>
<%--				依頼を受け付けるメディアを設定します。--%>
<%--				<div class="SettingBody">--%>
<%--					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">--%>
<%--						<div class="RegistMessage">--%>
<%--						<label>--%>
<%--							<input id="RequestMediaIllust" type="checkbox" <%if(requestCreator.allowIllust()){%>checked="checked"<%}%> >イラスト--%>
<%--						</label>--%>
<%--						<label>--%>
<%--							<input id="RequestMediaNovel" type="checkbox" <%if(requestCreator.allowNovel()){%>checked="checked"<%}%> >小説--%>
<%--						</label>--%>
<%--						</div>--%>
<%--						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateRequestMedia()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--			<div class="SettingListItem">--%>
<%--				<div class="SettingListTitle">NSFW許可</div>--%>
<%--				<div class="SettingBody">--%>
<%--					ワンクッション・R18に相当するセンシティブな内容の依頼を許可します。--%>
<%--					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">--%>
<%--						<div class="RegistMessage">--%>
<%--							<div class="onoffswitch OnOff">--%>
<%--								<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="AllowSensitive" value="0" <%if(requestCreator.allowSensitive()){%>checked="checked"<%}%> />--%>
<%--								<label class="onoffswitch-label" for="AllowSensitive">--%>
<%--									<span class="onoffswitch-inner"></span>--%>
<%--									<span class="onoffswitch-switch"></span>--%>
<%--								</label>--%>
<%--							</div>--%>
<%--						</div>--%>
<%--						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAllowSensitive()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>
			<div class="SettingListItem">
				<div class="SettingListTitle">匿名許可</div>
				<div class="SettingBody">
					匿名クライアントからの依頼を許可します。
					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
						<div class="RegistMessage">
							<div class="onoffswitch OnOff">
								<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="AllowAnonymous" value="0" <%if(requestCreator.allowAnonymous()){%>checked="checked"<%}%> />
								<label class="onoffswitch-label" for="AllowAnonymous">
									<span class="onoffswitch-inner"></span>
									<span class="onoffswitch-switch"></span>
								</label>
							</div>
						</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAllowAnonymous()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">返答期限</div>
				<div class="SettingBody">
					<div>
						<input id="ReturnPeriod" type="number" placeholder="<%=RequestCreator.RETURN_PERIOD_DEFAULT%>" value="<%=requestCreator.returnPeriod%>" maxlength="3" />
						<span class="RequestVarUnit">日</span><span class="RequestVarLimit">(<%=RequestCreator.RETURN_PERIOD_MIN%> - <%=RequestCreator.RETURN_PERIOD_MAX%>)</span>
					</div>
					<div class="RegistMessage">
						依頼の返答期限を設定します。 返答期限を過ぎた依頼はキャンセル扱いとなります。無償依頼の際は依頼主には表示されません。
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateReturnPeriod()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">お渡し期限</div>
				<div class="SettingBody">
					<div>
						<input id="DeliveryPeriod" type="number" placeholder="<%=RequestCreator.DELIVERY_PERIOD_DEFAULT%>" value="<%=requestCreator.deliveryPeriod%>" maxlength="3" />
						<span class="RequestVarUnit">日</span><span class="RequestVarLimit">(<%=RequestCreator.DELIVERY_PERIOD_MIN%> - <%=RequestCreator.DELIVERY_PERIOD_MAX%>)</span>
					</div>
					<div class="RegistMessage">
						依頼日からのお渡し(納品)期限を設定します。お渡し期限を過ぎた依頼はキャンセル扱いとなります。無償依頼の際は依頼主には表示されません。
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateDeliveryPeriod()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>

<%--			<div id="PaidSetting" class="SettingListItem">--%>
<%--				<div class="SettingListTitle">無償 / 有償</div>--%>
<%--				<div class="SettingBody">--%>
<%--					依頼を無償とするか、有償にするかを選択します。有償依頼では、クリエイターが指定した範囲内で、依頼主が金額を提示します。--%>
<%--					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">--%>
<%--						<div class="RegistMessage" style="margin: 0">--%>
<%--							<select id="SelectPaidRequest">--%>
<%--								<option value="FREE" <%=requestCreator.allowFreeRequest ? "selected": ""%>>無償にする</option>--%>
<%--								<option value="PAID" <%=requestCreator.allowPaidRequest ? "selected": ""%>>有償の依頼を受け付ける</option>--%>
<%--							</select>--%>
<%--						</div>--%>
<%--						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateSelectPaidRequest()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>

<%--			<div id="SettingAmountItems" style="display: <%=requestCreator.allowPaidRequest?"block":"none"%>">--%>
<%--			<div class="SettingListItem">--%>
<%--				<div class="SettingListTitle">おまかせ金額</div>--%>
<%--				<div class="SettingBody">--%>
<%--					<div>--%>
<%--						<span class="RequestVarUnit">¥</span>--%>
<%--						<input id="AmountLeftToMe" type="number" placeholder="<%=RequestCreator.AMOUNT_LEFT_TO_ME_DEFAULT%>" value="<%=requestCreator.amountLeftToMe%>" maxlength="5" />--%>
<%--					</div>--%>
<%--					<div class="RegistMessage">--%>
<%--						依頼画面で初期表示する金額を設定します。--%>
<%--						¥<%=String.format("%,d", RequestCreator.AMOUNT_LEFT_TO_ME_MIN)%>〜¥<%=String.format("%,d", RequestCreator.AMOUNT_LEFT_TO_ME_MAX)%>の間で設定できます。--%>
<%--					</div>--%>
<%--					<div class="SettingBodyCmd">--%>
<%--						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAmountLeftToMe()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--			<div class="SettingListItem">--%>
<%--				<div class="SettingListTitle">最低金額</div>--%>
<%--				<div class="SettingBody">--%>
<%--					<div>--%>
<%--						<span class="RequestVarUnit">¥</span>--%>
<%--						<input id="AmountMinimum" type="number" placeholder="<%=RequestCreator.AMOUNT_MINIMUM_DEFAULT%>" value="<%=requestCreator.amountMinimum%>" maxlength="16" />--%>
<%--					</div>--%>
<%--					<div class="RegistMessage">--%>
<%--						最低金額を設定します。--%>
<%--						¥<%=String.format("%,d", RequestCreator.AMOUNT_MINIMUM_MIN)%>〜¥<%=String.format("%,d", RequestCreator.AMOUNT_MINIMUM_MAX)%>の間で設定できます。--%>
<%--					</div>--%>
<%--					<div class="SettingBodyCmd">--%>
<%--						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAmountMinimum()"><%=_TEX.T("EditSettingV.Button.Update")%></a>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--			</div>--%>

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
