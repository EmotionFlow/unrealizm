<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	function SendEmojiAjax(emojiInfo, nCheerAmount, agentInfo, cardInfo, elCheerNowPayment) {
		// let amount = -1;
		// if(nCheerAmount && nCheerAmount>0){amount = nCheerAmount;}

		$.ajax({
			"type": "post",
			"data": {
				"IID": emojiInfo.contentId,
				"EMJ": emojiInfo.emoji,
				"UID": emojiInfo.userId,
				<%if(false){%>
				"AMT": amount,
				"AID": agentInfo == null ? '' :  agentInfo.agentId,
				"TKN": agentInfo == null ? '' : agentInfo.token,
				"EXP": cardInfo == null ? '' : cardInfo.expire,
				<%}%>
			},
			"url": "/f/SendEmojiF.jsp",
			"dataType": "json",
		}).then( data => {
				// cardInfo = null;
				if (data.result_num > 0) {
					const $objResEmoji = $("<span/>").addClass("ResEmoji").html(data.result);
					$("#ResEmojiAdd_" + emojiInfo.contentId).before($objResEmoji);
					if (vg) vg.vgrefresh();
					if(nCheerAmount>0) {
						DispMsg(<%=_TEX.T("CheerDlg.Thanks")%>);
						if (elCheerNowPayment != null) {
							elCheerNowPayment.hide();
						}
					}

					const $UserInfoCmdFollow = $("#IllustItem_" + emojiInfo.contentId + " > .IllustItemUser .UserInfoCmdFollow");
					if ($UserInfoCmdFollow.length > 0 && !$UserInfoCmdFollow.hasClass("Selected")) {
						setTimeout(()=>{
							$("#EncourageFollowUp_" + emojiInfo.contentId).show(500);
						}, 550);
					}

				} else {
					switch (data.error_code) {
						case -10:
							DispMsg("<%=_TEX.T("CheerDlg.Err.CardAuth")%>");
							break;
						case -20:
							alert("<%=_TEX.T("CheerDlg.Err.AuthCritical")%>");
							break;
						case -30:
							DispMsg("<%=_TEX.T("CheerDlg.Err.CardAuth")%>");
							break;
						case -40:
							<%if(false){%>
<%--						<%if(checkLogin.m_nPassportId==0){%>--%>
							showIntroductionPoipassDlgHtml(
								'<%=_TEX.T("TSendEmoji.IntroductionPoipass.Title")%>',
								'<%=_TEX.T("TSendEmoji.IntroductionPoipass.Description")%>',
								'<%=_TEX.T("IntroductionPoipass.ShowButton")%>',
								'<%=_TEX.T("IntroductionPoipass.FooterHtml")%>'
							);
							<%}else{%>
							DispMsg('<%=_TEX.T("TSendEmoji.Limit")%>');
							<%}%>
							break;
						case -99:
							DispMsg("<%=_TEX.T("CheerDlg.Err.AuthOther")%>");
							break;
					}
					if (elCheerNowPayment != null) {
						elCheerNowPayment.hide();
					}
				}},
			error => {
				// cardInfo = null;
				DispMsg("<%=_TEX.T("CheerDlg.Err.UnrealizmSrv")%>");
				if (elCheerNowPayment != null) {
					elCheerNowPayment.hide();
				}
			}
		);
	}



	function SendEmoji(nContentId, strEmoji, nUserId, elThis) {
		const emojiInfo = {
			"contentId": nContentId,
			"emoji": strEmoji,
			"userId": nUserId,
		};

		const emojiImgTag = $(elThis).children('img.Twemoji').prop('outerHTML');
		SendEmojiAjax(emojiInfo, null, null, null, null);

		return false;
	}
</script>
