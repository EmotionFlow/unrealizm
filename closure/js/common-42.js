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
	dateExp = new Date();
	dateExp.setTime(dateExp.getTime()+(7*1000*60*60*24));
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	tmp += "expires="+dateExp.toGMTString();
	document.cookie = tmp;
}

function setCookieOneDay(key, val, tmp) {
	dateExp = new Date();
	dateExp.setTime(dateExp.getTime()+(1000*60*60*24));
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	tmp += "expires="+dateExp.toGMTString();
	document.cookie = tmp;
}

function getCookie(key) {
	var cookieName = key + '=';
	var allcookies = document.cookie;
	var position = allcookies.indexOf(cookieName);

	if(position<0) return null;

	var startIndex = position + cookieName.length;
	var endIndex = allcookies.indexOf(';', startIndex);
	if( endIndex == -1 ) endIndex = allcookies.length;

	return decodeURIComponent(allcookies.substring(startIndex, endIndex));
}

function deleteCookie(key, tmp) {
	dTime = new Date();
	dTime.setTime(0);
	tmp = key + "=" + encodeURIComponent("0") + "; ";
	tmp += "path=/; ";
	tmp += "expires=" + dTime.toGMTString() + "; ";
	document.cookie = tmp;
}

function ChLang(l){
	if(l.length>0) {
		setCookie('LANG',l);
	} else {
		deleteCookie('LANG');
	}
	var nLangId = (l=="ja")?1:0;
	$.ajaxSingle({
		"type": "post",
		"data": { "LD":nLangId },
		"url": "/f/UpdateLanguageF.jsp",
		"success": function(data) {
			location.reload(true);
		}
	});
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

function DispMsg(strMessage) {
	if($('#DispMsg').length<=0) {
		$('body').append($("<div/>").attr("id", "DispMsg"));
	}
	$("#DispMsg").html(strMessage);
	$("#DispMsg").slideDown(200, function() {
		setTimeout(function() {
			$("#DispMsg").slideUp(200);
		}, 3000);
	});
}

function DispMsgStatic(strMessage) {
	setTimeout(function(){
		$("#DispMsg").html(strMessage);
		$("#DispMsg").show();
	}, 0);
}

function HideMsgStatic() {
	setTimeout(function(){
		$("#DispMsg").hide();
	}, 1000);
}

function DeleteContentInteractive(nUserId, nContentId, bPreviousTweetExist,
	strCheckDeleteMsg, strCheckDeleteYesMsg, strCheckDeleteNoMsg,
	strDeleteTweetMsg, strDeleteTweetYesMsg, strDeleteTweetNoMsg) {
	Swal.fire({
		title: '',
		text: strCheckDeleteMsg,
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

function UpdateFollowTag(nUserId, strTagTxt, nTypeId) {
	$.ajaxSingle({
		"type": "post",
		"data": { "UID": nUserId, "TXT": strTagTxt, "TYP": nTypeId},
		"url": "/f/UpdateFollowTagF.jsp",
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

function UpdateBookmark(user_id, content_id) {
	$.ajaxSingle({
		"type": "post",
		"data": { "UID": user_id, "IID": content_id},
		"url": "/f/UpdateBookmarkF.jsp",
		"dataType": "json",
		"success": function(data) {
			if(data.result==1) {
				$('#IllustItemBookmarkBtn_'+content_id).addClass('Selected');
			} else if(data.result==0) {
				$('#IllustItemBookmarkBtn_'+content_id).removeClass('Selected');
			} else {
				DispMsg('You need to login');
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

function generateShowAppendFile(){
	var tw_friendships = {}; // target user id -> friendship id (see CTweet)
	return function(user_id, content_id, mode, elm) {
		console.log(user_id, content_id, mode);
		console.log("twitter friendships: " + tw_friendships);
		var password = $('#IllustItem_' + content_id + ' input[name="PAS"]').val();
		var tw_f = tw_friendships[user_id];
		if(!tw_f){
			tw_f = -1;
		};

		$.ajax({
			"type": "post",
			"data": {"UID":user_id, "IID":content_id, "PAS":password, "MD":mode, "TWF":tw_f},
			"url": "/f/ShowAppendFileF.jsp",
			"dataType": "json",
			"success": function(data) {
				if(data.result_num>0) {
					$('#IllustItem_' + content_id + ' .IllustItemThubExpand').html(data.html);
					$(elm).parent().hide();
					$('#IllustItem_' + content_id).removeClass('R15 R18 R18G Password Login Follower TFollower TFollow TEach TList');
					$('#IllustItem_' + content_id + ' .IllustItemThubExpand').slideDown(300, function(){if(vg)vg.vgrefresh();});
					//for text
					$('#IllustItemText_' + content_id).css('max-height','none');
				} else {
					DispMsg(data.html);
				}
				if(data.tw_friendship >= 0){
					tw_friendships[user_id] = data.tw_friendship;
				}
						},
						"error": function(err){
								console.log(err);
						}
		});

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

function initGraph(ctx) {
	return new Chart(ctx, {
		type: 'doughnut',
		data: {
			labels : ["https://img-cdn.poipiku.com/img/pc_top_title-03.png"],
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
			afterDatasetsDraw: function(chart) {
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
			}
		}]
	});
}