// extension
$(function(){
	jQuery.extend({
		ajaxSingle: (function(options){
			var ajaxSending = false;
			return function(options){
				try{
					if(!ajaxSending){
						ajaxSending = true;
						options.complete = (function(){
							var complete = typeof(options.complete)=="function" ? options.complete : function(a,b){} ;
							return function(a,b){
								ajaxSending = false;
							};
						})();
						$.ajax(options);
					} else {
						;
					}
				}catch(e){
					ajaxSending = false;
				}
			};
		})()
	});
});

// for v-grid;
var vg = null;

function setCookie(key, val, tmp) {
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	tmp += "expires=Tue, 31-Dec-2030 23:59:59; ";
	document.cookie = tmp;
}

function setCookieOneTime(key, val, tmp) {
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	document.cookie = tmp;
}

function setCookieWeek(key, val, tmp) {
	let dateExp = new Date();
	dateExp.setTime(dateExp.getTime()+(7*1000*60*60*24));
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	tmp += "expires="+dateExp.toGMTString();
	document.cookie = tmp;
}

function setCookieOneDay(key, val, tmp) {
	let dateExp = new Date();
	dateExp.setTime(dateExp.getTime()+(1000*60*60*24));
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	tmp += "expires="+dateExp.toGMTString();
	document.cookie = tmp;
}

function getCookie(key) {
	const cookieName = key + '=';
	const allcookies = document.cookie;
	const position = allcookies.indexOf(cookieName);

	if(position<0) return null;

	const startIndex = position + cookieName.length;
	let endIndex = allcookies.indexOf(';', startIndex);
	if( endIndex === -1 ) endIndex = allcookies.length;

	return decodeURIComponent(allcookies.substring(startIndex, endIndex));
}

function deleteCookie(key, tmp) {
	let dTime = new Date();
	dTime.setTime(0);
	tmp = key + "=" + encodeURIComponent("0") + "; ";
	tmp += "path=/; ";
	tmp += "expires=" + dTime.toGMTString() + "; ";
	document.cookie = tmp;
}

function setTimeZoneOffsetCookie() {
	const key = "TZ_OFFSET"; // Common.CLIENT_TIMEZONE_OFFSET
	const cookieOffset = getCookie(key);
	const d = new Date();
	const nowOffset = String(d.getTimezoneOffset() / 60) ;
	if (!cookieOffset || cookieOffset !== nowOffset) {
		setCookie(key, nowOffset);
		if (getCookie(key) === nowOffset) {
			location.reload();
		}
	}
}

function ChLang(l,isLogin){
	if(l.length>0) {
		setCookie('LANG',l);
	} else {
		deleteCookie('LANG');
		location.reload();
		return;
	}

	if(isLogin){
		$.ajaxSingle({
			"type": "post",
			"data": { "LD":l },
			"url": "/f/UpdateLanguageF.jsp",
			"success": function(data) {
				location.reload();
			}
		});
	}else{
		location.reload();
	}
}

function setLocalStrage(key, val) {
	var obj = {'val': val};
	var obj = JSON.stringify(obj);
	localStorage.setItem(key, obj);
}

function getLocalStrage(key) {
	var obj = localStorage.getItem(key);
	if(!obj) return null;
	var obj = JSON.parse(obj);
	if(!obj) return null;
	return obj.val;
}

function SearchIllustByKeyword() {
	var keyword = $('#HeaderSearchBox').val();
	location.href="/SearchIllustByKeywordPcV.jsp?KWD="+encodeURIComponent(keyword);
}

function SearchTagByKeyword() {
	var keyword = $('#HeaderSearchBox').val();
	location.href="/SearchTagByKeywordPcV.jsp?KWD="+encodeURIComponent(keyword);
}

function SearchUserByKeyword() {
	var keyword = $('#HeaderSearchBox').val();
	location.href="/SearchUserByKeywordPcV.jsp?KWD="+encodeURIComponent(keyword);
}

var sendObjectMessage = function(parameters) {
	var iframe = document.createElement('iframe');
	iframe.setAttribute('src', "myurlscheme://"+parameters);
	document.documentElement.appendChild(iframe);
	iframe.parentNode.removeChild(iframe);
	iframe = null;
}

$.fn.autoLink = function(nMode){
	// nMode : 0-app, 1-pc & smart phone
	var SEARCH_TAG = (nMode==0)?"/SearchIllustByTagV.jsp":"/SearchIllustByTagPcV.jsp";

	return this.each(function(){
		var srcText = this.innerHTML;
		//this.innerHTML = srcText.replace(/(#)([\w|[\u2E80-\u2E99\u2E9B-\u2EF3\u2F00-\u2FD5\u3005\u3007\u3021-\u3029\u3038-\u303B\u3400-\u4DB5\u4E00-\u9FCC\uF900-\uFA6D\uFA70-\uFAD9]|[\uD840-\uD868][\uDC00-\uDFFF]|\uD869[\uDC00-\uDED6\uDF00-\uDFFF]|[\uD86A-\uD86C][\uDC00-\uDFFF]|\uD86D[\uDC00-\uDF34\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1D]|\uD87E[\uDC00-\uDE1D]]+)/gi,"<a class='AutoLink' href='/SearchIllustByTagV.jsp?KWD=$2'>#$2</a>");
		srcText = srcText.replace(/((http|https):\/\/[\w\.\-\/:;&?,=#!~]+)/gi,"<a class='AutoLink' href='$1' target='_blank'>$1</a>");
		//this.innerHTML = srcText.replace(/[#＃]+[A-Za-z0-9-_ぁ-ヶ亜-黑]+/g, function(hash) {
		this.innerHTML = srcText.replace(/(#|＃)[\w]*[a-zA-Z0-9ぁ-ヾー-龥豈-鶴]+/g, function(hash) {
			var no_mark_hash = hash.replace(/[#＃]/, "");
			return " <a class='AutoLink' href='"+SEARCH_TAG+"?KWD="+encodeURIComponent(no_mark_hash)+"'>#"+no_mark_hash+"</a>";
			});
	});
}

function GotoLogin() {
	location.href = "/LoginFormV.jsp";
}

function DispMsg(strMessage, timeout=3000) {
	if($('#DispMsg').length<=0) {
		$('body').append($("<div/>").attr("id", "DispMsg"));
	}
	$("#DispMsg").html(strMessage);
	$("#DispMsg").slideDown(200, function() {
		setTimeout(function() {
			$("#DispMsg").slideUp(200);
		}, timeout);
	});
}

function DispMsgStatic(strMessage) {
	if($('#DispMsg').length<=0) {
		$('body').append($("<div/>").attr("id", "DispMsg"));
	}
	setTimeout(function(){
		$("#DispMsg").html(strMessage);
		$("#DispMsg").slideDown(200);
	}, 0);
}

function HideMsgStatic(timeout=1000) {
	if (timeout <= 0) {
		$("#DispMsg").slideUp(200);
 	} else {
		setTimeout(function(){
			$("#DispMsg").slideUp(200);
		}, timeout);
	}
}

function DeleteContentInteractive(nUserId, nContentId, bPreviousTweetExist,
	strCheckDeleteMsg, strCheckDeleteYesMsg, strCheckDeleteNoMsg,
	strDeleteTweetMsg, strDeleteTweetYesMsg, strDeleteTweetNoMsg) {
	Swal.fire({
		title: '',
		html: strCheckDeleteMsg,
		type: 'question',
		showCancelButton: true,
		confirmButtonText: strCheckDeleteYesMsg,
		cancelButtonText: strCheckDeleteNoMsg,
	}).then((result) => {
		if (result.value) {
			if(bPreviousTweetExist){
				Swal.fire({
					title: '',
					text: strDeleteTweetMsg,
					type: 'question',
					showCancelButton: true,
					confirmButtonText: strDeleteTweetYesMsg,
					cancelButtonText: strDeleteTweetNoMsg,
				}).then((result) => {
					if(result.value){
						DeleteContentBase(nUserId, nContentId, true);
					}else{
						DeleteContentBase(nUserId, nContentId, false);
					}
				});
			}else{
				DeleteContentBase(nUserId, nContentId, false);
			}
		}
	});
}

function DeleteContentBase(nUserId, nContentId, bDeleteTweet) {
	$.ajaxSingle({
		"type": "post",
		"data": { "UID":nUserId, "CID":nContentId, "DELTW":bDeleteTweet?1:0 },
		"url": "/f/DeleteContentF.jsp",
		"dataType": "json",
		"success": function(data) {
			$('#IllustItem_'+nContentId).slideUp(300, function(){
				$('#IllustItem_'+nContentId).remove();
				if(vg)vg.vgrefresh();
			});
		},
		"error": function(req, stat, ex){
			DispMsg('Delete Error');
		}
	});
}

function switchEmojiKeyboard(obj, nContentId, nSelected) {
	var $ResEmojiBtnList = $(obj).parent().parent().children('.ResEmojiBtnList');
	$ResEmojiBtnList.hide();
	var $ResEmojiBtnListTarg = $ResEmojiBtnList.eq(nSelected);
	if(!$ResEmojiBtnListTarg.loading) {
		$ResEmojiBtnListTarg.loading = true;
		var $objMessage = $("<div/>").addClass("Waiting");
		$ResEmojiBtnListTarg.empty();
		$ResEmojiBtnListTarg.append($objMessage);
		$.ajax({
			"type": "post",
			"data": { "IID": nContentId, "CAT": nSelected},
			"url": "/f/GetEmojiListF.jsp",
			"dataType": "html",
			"success": function(data) {
				$ResEmojiBtnListTarg.html(data);
				$ResEmojiBtnListTarg.loading = false;
				if(vg)vg.vgrefresh();
			},
			"error": function(req, stat, ex){
				$(".Waiting").remove();
				DispMsg('emoji loading Error');
				$ResEmojiBtnListTarg.loading = false;
			}
		});
	}
	$ResEmojiBtnListTarg.show();
	$(obj).parent().children('.ResBtnSetItem').removeClass('Selected');
	$(obj).addClass('Selected');
}

function EditDesc(content_id) {
	$("#IllustItemDesc_"+content_id).hide();
	$("#IllustItemTag_"+content_id).hide();
	$("#IllustItemDescEdit_"+content_id).show();
	$("#IllustItemCategory_"+content_id).hide();
	$("#IllustItemCategoryEdit_"+content_id).show();
}

function UpdateDesc(nUserId, content_id, mode) {
	var nCategoryId = $('#EditCategory_'+content_id).val();
	var strDescription = $.trim($("#IllustItemDescEdit_"+content_id+" .IllustItemDescEditTxt").val());
	strDescription = strDescription.substr(0 , 200);
	var strTagList = $.trim($("#IllustItemDescEdit_"+content_id+" .IllustItemTagEditTxt").val());
	strTagList = strTagList.substr(0 , 100);

	$.ajaxSingle({
		"type": "post",
		"data": { "UID": nUserId, "IID": content_id, "CAT":nCategoryId, "DES": strDescription, "TAG": strTagList, "MOD": mode },
		"url": "/f/UpdateDescF.jsp",
		"dataType": "json",
		"success": function(data) {
			$("#IllustItemDesc_"+content_id).html(data.html);
			$("#IllustItemDescEdit_"+content_id+" .IllustItemDescEditTxt").val(data.text);
			$("#IllustItemTag_"+content_id).html(data.htmlTag);
			$("#IllustItemDescEdit_"+content_id+" .IllustItemTagEditTxt").val(data.textTag);
			$("#IllustItemDesc_"+content_id).show();
			$("#IllustItemTag_"+content_id).show();
			$("#IllustItemDescEdit_"+content_id).hide();

			$("#IllustItemCategory_"+content_id+" .Category").removeClass().addClass('Category C'+nCategoryId).text(data.category_name);
			var link = $("#IllustItemCategory_"+content_id+" .Category").attr('href');
			link = link.replace(/CD=\d+/i, 'CD='+nCategoryId);
			$("#IllustItemCategory_"+content_id+" .Category").attr('href', link);
			$("#IllustItemCategory_"+content_id).show();
			$("#IllustItemCategoryEdit_"+content_id).hide();
		},
		"error": function(req, stat, ex){
			DispMsg('Connection error');
		}
	});
}

function UpdateFollowUser(userId, followUserId) {
	$.ajaxSingle({
		"type": "post",
		"data": { "UID": userId, "IID": followUserId },
		"url": "/f/UpdateFollowUserF.jsp",
		"dataType": "json",
		"success": function(data) {
			const $UserInfoCmdFollow = $('.UserInfoCmdFollow_'+followUserId);
			if (data.result === 1) {
				$UserInfoCmdFollow.addClass('Selected');
			} else if (data.result === 2) {
				$UserInfoCmdFollow.removeClass('Selected');
			} else {
				DispMsg(data.err_msg);
			}
			$UserInfoCmdFollow.html(data.btn_label);
		},
		"error": function(req, stat, ex){
			DispMsg('Connection error');
		}
	});
}

function UpdateFollowGenre(userId, genreId) {
	$.ajaxSingle({
		"type": "post",
		"data": {"UID": userId, "GD": genreId},
		"url": "/api/UpdateFollowGenreF.jsp",
		"dataType": "json",
		"success": function(data) {
			if(data.result==1) {
				$('.TitleCmdFollow').addClass('Selected');
				DispMsg(data.message);
			} else if(data.result==0) {
				$('.TitleCmdFollow').removeClass('Selected');
				DispMsg(data.message);
			} else {
				DispMsg(data.message);
			}
		},
		"error": function(req, stat, ex){
			DispMsg('Connection error');
		}
	});
}

function UpdateFollowTag(nUserId, strTagTxt) {
	$.ajaxSingle({
		"type": "post",
		"data": {"UID": nUserId, "TXT": strTagTxt},
		"url": "/api/UpdateFollowTagF.jsp",
		"dataType": "json",
		"success": function(data) {
			if(data.result<0) {
				DispMsg(data.message);
			} else if(data.result==1) {
				$('.TitleCmdFollow').addClass('Selected');
			} else if(data.result==0) {
				$('.TitleCmdFollow').removeClass('Selected');
			} else {
				DispMsg('You need to login');
			}
		},
		"error": function(req, stat, ex){
			DispMsg('Connection error');
		}
	});
}

function UpdateFollowTagFromTagList(nUserId, strTagTxt, thisElement) {
	$.ajaxSingle({
		"type": "post",
		"data": {"UID": nUserId, "TXT": strTagTxt},
		"url": "/api/UpdateFollowTagF.jsp",
		"dataType": "json",
		"success": function(data) {
			if(data.result<0) {
				DispMsg(data.message);
			} else if(data.result===1) {
				$(thisElement).children("i").removeClass('far');
				$(thisElement).children("i").addClass('fas');
			} else if(data.result===0) {
				$(thisElement).children("i").removeClass('fas');
				$(thisElement).children("i").addClass('far');
			} else {
				DispMsg('<%=_TEX.T("UpdateFollowTagC.ERR_NOT_LOGIN")%>>');
			}
		},
		"error": function(req, stat, ex){
			DispMsg('Connection error');
		}
	});
}

function UpdateBookmark(user_id, content_id) {
	$.ajaxSingle({
		"type": "post",
		"data": { "UID": user_id, "IID": content_id},
		"url": "/api/UpdateBookmarkF.jsp",
		"dataType": "json",
		"success": function(data) {
			if (data.result === 0) {
				$('#IllustItemBookmarkBtn_' + content_id).removeClass('Selected');
			} else if (data.result === 1) {
				$('#IllustItemBookmarkBtn_' + content_id).addClass('Selected');
			} else if (data.result === 2) { // UpdateBookmarkC.BOOKMARK_LIMIT
				DispMsg(data.msg);
			} else if (data.result === -2) { // UpdateBookmarkC.USER_INVALID
				DispMsg(data.msg);
			}
		},
		"error": function(req, stat, ex){
			DispMsg('Connection error');
		}
	});
}

function fixedEncodeURIComponent (str) {
	return encodeURIComponent(str).replace(/[!'()*]/g, function(c) {
		return '%' + c.charCodeAt(0).toString(16);
	});
}

function moveTagSearch(url, str) {
	location.href = url+fixedEncodeURIComponent(str);
}

function updateCategoryMenuPos(duration) {
	if($('#CategoryMenu').length && $('#CategoryMenu .CategoryBtn.Selected').length) {
		var frame_width = $('#CategoryMenu').outerWidth();
		var frame_scroll_left = $('#CategoryMenu').scrollLeft();
		var item_width = $('#CategoryMenu .CategoryBtn.Selected').outerWidth();
		var item_left = $('#CategoryMenu .CategoryBtn.Selected').position().left + frame_scroll_left;
		var item_pos = item_left + (item_width - frame_width)/2
		$('#CategoryMenu').animate({scrollLeft:item_pos}, duration);
	}
}

function ShowAllReaction(content_id, elm) {
	$.ajax({
		"type": "post",
		"data": {"IID": content_id},
		"url": "/f/ShowAllReactionF.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log(data);
			if(data.result_num>0) {
				$(elm).hide();
				$('#IllustItemResList_'+content_id + " .ResEmoji").remove();
				$("#ResEmojiAdd_"+content_id).before(data.html);
				if(vg)vg.vgrefresh();
			} else {
				$(elm).html(data.html);
			}
		}
	});
	return false;
}

function _retweetContentF(userId, contentId, mode, elm) {
	$.ajax({
		"type": "post",
		"data": {"TD":contentId},
		"url": "/f/RetweetContentF.jsp",
		"dataType": "json",
	}).then(
		data => {
			if (data.result === 1) { // Common.API_OK
				ShowAppendFile(userId, contentId, mode, elm);
			}
			DispRetweetMsg(data);
		},err => {
			console.log(err);
			const data = {result: -888};
			DispRetweetMsg(data);
		}
	);
}

function generateShowAppendFile(){
	var tw_friendships = {}; // target user id -> friendship id (see CTweet)
	return function(user_id, content_id, mode, elm) {
		const password = $('#IllustItem_' + content_id + ' input[name="PAS"]').val();
		let tw_f = tw_friendships[user_id];
		if(!tw_f){
			tw_f = -1;
		}

		$.ajax({
			"type": "post",
			"data": {"UID":user_id, "IID":content_id, "PAS":password, "MD":mode, "TWF":tw_f},
			"url": "/f/ShowAppendFileF.jsp",
			"dataType": "json",
		}).then(
			data => {
				console.log(data.result_num);
				if(data.result_num>0) {
					const $IllustItemThubExpand = $('#IllustItem_' + content_id + ' .IllustItemThubExpand');
					$IllustItemThubExpand.html(data.html);
					$(elm).parent().hide();
					$('#IllustItem_' + content_id).removeClass('R15 R18 R18G Password Login Follower TFollower TFollow TEach TList TRT');
					$IllustItemThubExpand.slideDown(300, function(){if(vg)vg.vgrefresh();});

					//for text
					const $IllustItemText = $('#IllustItemText_' + content_id);
					$IllustItemText.css('max-height','500px');
					$IllustItemText.css('overflow','scroll');
				} else if(data.result_num===-20) { // need retweet
					if (!getLocalStrage('not_show_retweet_confirm')) {
						showRetweetContentDlg().then(
							formValues => {
								if (formValues.dismiss) {
									return;
								}
								setLocalStrage('not_show_retweet_confirm', formValues.value.NotDisplayFeature);
								_retweetContentF(user_id, content_id, mode, elm);
							}
						);
					} else {
						_retweetContentF(user_id, content_id, mode, elm);
					}
					return;
				} else if(data.result_num === -5) {
					showTwitterFollowerLimitInfoDlg();
				} else {
					DispMsg(data.html, 5000);
				}
				if(data.tw_friendship >= 0){
					tw_friendships[user_id] = data.tw_friendship;
				}
			},err => {
				console.log(err);
			}
		);
	}
}

var ShowAppendFile = generateShowAppendFile();

function TweetMyBox(strMyBoxURL, strTweetURL, hMessages, bIsSmartPhone,) {
	let strHtml =
		'<h2 class="TweetMyBoxTitle" style="padding: 10px 0 0 0;">' +
		hMessages.TweetTitle +
		'</h2>' +
		'<h3 class="TweetMyBoxSubTitle">' +
		hMessages.TweetStep1 +
		'</h3>' +
		'<div class="TweetMyBoxInfo">' +
		'<a class="BtnBase Selected TweetMyBoxBtn" href="' + strTweetURL + '" target="_blank">' +
		'<i class="fab fa-twitter"></i> ' +
		hMessages.TweetTweet +
		'</a>' +
		'<i class="fa fa-info-circle"></i> ' +
		hMessages.TweetInfo1 +
		'</div>' +
		'<h3 class="TweetMyBoxSubTitle">' +
		hMessages.TweetStep2 +
		'</h3>' +
		'<div class="TweetMyBoxInfoStep2">' +
		hMessages.TweetInfo2 +
		'</div>' +
		'<div class="TweetMyBoxPinLink">' +
		'<a href="/how_to/TwPinPcV.jsp" target="_blank">' +
		hMessages.TweetHowToPin +
		'</a>' +
		'</div>' +
		'<hr class="TweetMyBoxHr"/>' +
		'<h2 class="TweetMyBoxTitle">' +
		hMessages.ShareURLTitle +
		'</h2>' +
		'<div>' +
		'<input id="MyBoxUrlTxt" type="text" readonly value="' + strMyBoxURL + '">' +
		'<a id="CopyMyBoxUrlBtn" class="BtnBase Selected" href="javascript:void(0);">' +
		hMessages.ShareURLCopy +
		'</a>' +
		'</div>' +
		'<h2 class="TweetMyBoxTitle">' +
		hMessages.ShareQRTitle +
		'</h2>' +
		'<div class="MyBoxQRCode">' +
		'<div class="QRCode"><span id="QRCodeImg"></span>';
		if(!bIsSmartPhone){
			strHtml +=
				'<span class="DownloadMyBoxQR"><a id="DownloadMyBoxQRBtn" class="BtnBase Selected" href="javascript:void(0);">' +
				hMessages.ShareQRDownload +
				'</a></span>';
		}
		strHtml += '</div>' +
		'</div>';

	Swal.fire({
		html: strHtml,
		showCloseButton: true,
		showCancelButton: false,
		showConfirmButton: false,
		onOpen: () => {
			$("#QRCodeImg").qrcode({width: 64, height: 64, text: $("#MyBoxUrlTxt").val()});
			$("#CopyMyBoxUrlBtn").click(() => {
				$("#MyBoxUrlTxt").select();
				document.execCommand("Copy");
				alert(hMessages.ShareURLCopied);
			});
			$("#DownloadMyBoxQRBtn").click(() => {
				let canvas = $('#QRCodeImg canvas')[0];
				let link = document.createElement("a");
				link.href = canvas.toDataURL("image/png");
				link.download = "poipiku_qrcode.png";
				link.click();
			});
		}
	});
}
var g_chartAnalyze;
function initGraph(ctx) {
	return new Chart(ctx, {
		type: 'doughnut',
		data: {
			labels : ["https://img.poipiku.com/img/pc_top_title-03.png"],
			datasets: [{
				data: [100],
				backgroundColor: ["#3498db"]
			}]
		},
		options: {
			legend: {
				position: 'top',
				display: false,
			},
			animation: {
				animateScale: true,
				animateRotate: true
			},
			tooltips: {
				enabled: false,
			},
			events: [],
		},
		plugins: [{
			afterRender: function(chart) {
				var ctx = chart.ctx;
				chart.data.datasets.forEach(function(dataset, i) {
					var meta = chart.getDatasetMeta(i);
					if (!meta.hidden) {
						meta.data.forEach(function(element, j) {
							const imgSrc = chart.data.labels[j];
							if(!imgSrc) return;
							var dataString = dataset.data[j].toString()+'%';
							const fontSize = 14;
							ctx.fillStyle = "#ffffff";
							ctx.font = Chart.helpers.fontString(fontSize, "normal", "Verdana");
							ctx.textAlign = 'center';
							ctx.textBaseline = 'middle';
							var position = element.tooltipPosition();
							const image = new Image();
							image.src = chart.data.labels[j];
							image.onload = () => {
								const width = 24;
								const height = 24;
								ctx.drawImage(image, position.x-width/2, position.y - height, width, height);
							}
							ctx.fillText(dataString, position.x, position.y+10);
						});
					}
				});
				console.log("afterRender");
			}
		}]
	});
}

function setGraphData(data) {
	g_chartAnalyze.data = data
}
function updateGraph() {
	g_chartAnalyze.clear();
	g_chartAnalyze.update();
}

function readMoreDescription(el) {
	$(el).hide();
	$(el).next().show();
}

function showSelectLangDlg(isLogin) {
	Swal.fire({
		html: `
		<dl class="HeaderSelectLangList">
			<dd><a hreflang="en" onclick="ChLang('en', ` + isLogin + `)" href="javascript:void(0);">English</a></dd>
			<dd><a hreflang="ru" onclick="ChLang('ru', ` + isLogin + `)" href="javascript:void(0);">русский</a></dd>
			<dd><a hreflang="ko" onclick="ChLang('ko', ` + isLogin + `)" href="javascript:void(0);">한국</a></dd>
			<dd><a hreflang="zh-cmn-Hans" onclick="ChLang('zh_CN', ` + isLogin + `)" href="javascript:void(0);">简体中文</a></dd>
			<dd><a hreflang="zh-cmn-Hant" onclick="ChLang('zh_TW', ` + isLogin + `)" href="javascript:void(0);">繁體中文</a></dd>
			<dd><a hreflang="th" onclick="ChLang('th', ` + isLogin + `)" href="javascript:void(0);">ไทย</a></dd>
			<dd><a hreflang="ja" onclick="ChLang('ja', ` + isLogin + `)" href="javascript:void(0);">日本語</a></dd>
		</dl>
		`,
		showCloseButton: true,
		showCancelButton: false,
		showConfirmButton: false,
	});
}

function appendLoadingSpinner(appendTo, spinnerClassName){
	const LOADING_SPINNER_HTML = '<div class="' + spinnerClassName + '"><div class="rect1"></div><div class="rect2"></div><div class="rect3"></div><div class="rect4"></div><div class="rect5"></div></div>';
	$(appendTo).append(LOADING_SPINNER_HTML);
}

function removeLoadingSpinners(spinnerClassName){
	$("." + spinnerClassName).remove();
}

function visibleContentPassword(el) {
	$(el).prev().attr('type','text');
	$(el).next().show();
	$(el).hide();
}

function hideContentPassword(el) {
	$(el).prev().prev().attr('type','password');
	$(el).prev().show();
	$(el).hide();
}

function getIntroductionPoipassDlgHtml(strTitle, strDescription){
	return `<style>
.RecommendedPoipassDlgTitle{padding: 10px 0 0 0;}
.RecommendedPoipassDlgInfo{font-size: 14px; text-align: left;}
.RecommendedPoipassDlgInfo strong{color:#ff7272}
</style>
<img src="/img/poipiku_passport_logo3_60.png" height="45px" alt="poipass"/>
<h2 class="RecommendedPoipassDlgTitle">` + strTitle + `</h2>
<div class="RecommendedPoipassDlgInfo">	<p>` + strDescription + `</p></div>`;
}

function showIntroductionPoipassDlgHtml(title, description, showButtonLabel, footerHtml) {
	Swal.fire({
		html: getIntroductionPoipassDlgHtml(title, description),
		focusConfirm: false,
		showCloseButton: true,
		showCancelButton: false,
		confirmButtonText: showButtonLabel,
		footer: footerHtml,
	}).then(formValues => {
		if(formValues.dismiss){
			return false;
		} else {
			location.href = "/MyEditSettingPcV.jsp?MENUID=POIPASS";
		}
	});
}

/**
 * 指定要素の表示上の高さを、指定要素sytleのheightに設定する。
 * imgタグのonloadと組み合わせて使う。
 *
 * [背景]
 * Cache APIを用いたコンテンツリストのキャッシュをリストアする際、
 * DOMを流し込んでスクロール位置を指定している。
 *
 * このとき、サムネ画像のimgタグにheight指定が無いと、画像がロード
 * されるまで高さが定まらい。
 * すると、流し込んだDOMのheightが想定より短くなっているタイミングで、
 * スクロール位置指定が動いてしまい、位置がうまく復元できない。
 *
 * そこで、サムネ画像読み込みのタイミングで、imgタグのstyle属性にheight
 * を指定することで、キャッシュに格納する前に高さを指定しておくことにした。
 *
 * @param element imgタグの要素
 */
function setImgHeightStyle(element) {
	$(element).css('height', $(element).height());
}

/******** Cache API ********/
/* https://developer.mozilla.org/ja/docs/Web/API/Cache */
const CURRENT_CACHES_INFO = {
	MyHomeContents: {
		name: 'my-home-contents-v' + 1,
		request_prefix: '/_/IllustItemList/',
		maxAgeMin:  15,
	},
	MyHomeTagContents: {
		name: 'my-home-tag-contents-v' + 1,
		request_prefix: '/_/IllustItemList/',
		maxAgeMin:  15,
	},
	MyBookmarkListContents: {
		name: 'my-bookmark-list-contents-v' + 1,
		request_prefix: '/_/IllustThumbList/',
		maxAgeMin:  15,
	}
};

class CacheApiHtmlCache {
	constructor(cacheInfo, userId) {
		this.name = cacheInfo.name;
		this.request = cacheInfo.request_prefix + userId;
		this.maxAge = cacheInfo.maxAgeMin * 60 * 1000;
		this.header = {
			scrollTop: 0,
			scrollHeight: 0,
			lastContentId: -1,
			page: 0,
			updatedAt: 0,
		}
	}

	addClickEventListener(triggerSelector, contentsElementName) {
		$(document).on('click', triggerSelector,
			async () => {
				await this.put($(contentsElementName).html());
			});
	}

	put(html) {
		return caches.open(this.name).then((cache) => {
			const now = Date.now();
			const response = new Response(
				html,
				{headers: new Headers({
						"scrollTop": $(window).scrollTop(),
						"scrollHeight": $("body").get(0).scrollHeight,
						"lastContentId": this.header.lastContentId,
						"page": this.header.page,
						"updatedAt": now,
					})}
			);
			cache.put(this.request, response)
				.then(()=>{this.header.updatedAt = now;});
		});
	}

	pull(restoreCallback, notFoundCallback) {
		caches.open(this.name).then((cache) => {
			cache.match(this.request).then((res) => {
				if (res) {
					res.text().then((html) => {
						if (html && parseInt(res.headers.get("lastContentId"))>0) {
							this.header.scrollTop = parseInt(res.headers.get("scrollTop"));
							this.header.scrollHeight = parseInt(res.headers.get("scrollHeight"));
							this.header.lastContentId = parseInt(res.headers.get("lastContentId"));
							this.header.page = parseInt(res.headers.get("page"));
							this.header.updatedAt = parseInt(res.headers.get("updatedAt"));
							restoreCallback(html);
						} else {
							notFoundCallback();
						}
					});
				} else {
					notFoundCallback();
				}
			}, () => {notFoundCallback();});
		}, () => {notFoundCallback();});
	}

	delete(callBack) {
		caches.open(this.name).then((cache) => {
			cache.delete(this.request).then(r => {console.log('cache deleted.')});
		}, () => {
			console.log("cache delete error");
		}).finally(() => {
			if (callBack) callBack();
		});
	}
}

function deleteOldVersionCache() {
	let expectedCacheNamesSet = new Set(Object.values(CURRENT_CACHES_INFO).map(e => e.name));
	caches.keys().then(function(cacheNames) {
		return Promise.all(
			cacheNames.map(function(cacheName) {
				if (!expectedCacheNamesSet.has(cacheName)) {
					console.log('Deleting out of date cache:', cacheName);
					return caches.delete(cacheName);
				}
			})
		);
	});
}
/******** Cache API ********/

/******** 無限スクロール *******/
function createIntersectionObserver(callback) {
	return new IntersectionObserver(entries => {
		entries.forEach(entry => {
			if (!entry.isIntersecting) return;
			observer.unobserve(entry.target);
			callback();
		});
	});
}
/******** 無限スクロール *******/

/******** DetailV オーバーレイ表示*******/
function createDetailToucheMoveHandler(detailOverlay) {
	return (event) => {
		// 画像のみをスクロールさせ、ページ全体がスクロールされないようにする。
		// 画像部分のスクロールが上端or下端であったら、どの要素もスクロールさせない。
		if ($(event.target).hasClass('DetailIllustItemImage')
			&& detailOverlay.scrollTop !== 0
			&& detailOverlay.scrollTop + detailOverlay.clientHeight !== detailOverlay.scrollHeight) {
			event.stopPropagation();
		} else {
			if(event.cancelable){
				event.preventDefault();
			}
		}
	}
}

function createDetailScrollHandler(detailOverlay) {
	// 表示画像が一番上OR一番下にスクロールされたら、1pxだけ戻す。
	return () => {
		if (detailOverlay.scrollTop === 0) {
			detailOverlay.scrollTop = 1;
		}
		else if (detailOverlay.scrollTop + detailOverlay.clientHeight === detailOverlay.scrollHeight) {
			detailOverlay.scrollTop = detailOverlay.scrollTop - 1;
		}
	}
}

function detailIllustItemImageOnload(el) {
	$("#DetailOverlayLoading").hide();
}

function _showIllustDetail(ownerUserId, contentId, appendId) {
	$.ajax({
		"type": "post",
		"data": {"ID":ownerUserId, "TD":contentId, "AD":appendId},
		"url": "/f/ShowIllustDetailF.jsp",
		"dataType": "json",
	}).then(
		data => {
			if (data.result === 1) {
				document.getElementById('DetailOverlay').scrollTop = 1;
				$("#DetailOverlayInner").html(data.html);
				detailOverlay.classList.add('overlay-on');
				$("#DetailOverlayLoading").show();
				document.addEventListener('touchmove', detailToucheMoveHandler, { passive: false });
				document.addEventListener('mousewheel', detailToucheMoveHandler, { passive: false });
				detailOverlay.addEventListener('scroll', detailScrollHandler, { passive: false });
			} else {
				switch (data.error_code) {
					case -1:
						location.href = 'StartPoipikuPcV.jsp';
						break;
					case -2:
						DispNeedLoginMsg();
						break;
					default:
						DispUnknownErrorMsg();
				}
			}
		},err => {
			DispUnknownErrorMsg();
		}
	);
}

function showIllustDetail(ownerUserId, contentId, appendId) {
	_showIllustDetail(ownerUserId, contentId, appendId);
}

function closeDetailOverlay() {
	document.getElementById('DetailOverlay').classList.remove('overlay-on');
	document.removeEventListener('touchmove', detailToucheMoveHandler);
	document.removeEventListener('mousewheel', detailToucheMoveHandler);
	detailOverlay.removeEventListener('scroll', detailScrollHandler);
	document.getElementById('DetailOverlayInner').style.height = 16 + "px";
}

function initDetailOverlay() {
	document.getElementById('DetailOverlayClose').addEventListener('click', closeDetailOverlay, false);
	const overlayInner = document.getElementById('DetailOverlayInner');
	overlayInner.addEventListener('click', (ev)=>{ev.stopPropagation()}, false);
	overlayInner.style.minHeight = (screen.height + 100) + "px";
}
/******** DetailV オーバーレイ表示*******/
