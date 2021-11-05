//並べ替え情報の送信
function UpdateFileOrderAjax(user_id, content_id) {
	let json_array = [];
	$.each($('.qq-upload-list-selector.qq-upload-list').sortable('toArray'), function(i, item) {
		json_array.push(parseInt(item))
	});

	return $.ajax({
		"type": "post",
		"data": {
			UID: user_id,
			IID: content_id,
			AID: JSON.stringify(json_array)
		},
		"url": "/f/UpdateFileOrderF.jsp",
		"dataType": "json",
	});
}

function UpdatePasteOrderAjax(user_id, content_id, append_ids){
	return $.ajax({
		"type": "post",
		"data": {
			UID: user_id,
			IID: content_id,
			AID: JSON.stringify(append_ids),
		},
		"url": "/f/UpdateFileOrderF.jsp",
		"dataType": "json",
	});
}

//ファイル選択エリアの初期化
function initUpdateFile(fileNumMax, fileSizeMax, userid, contentid) {
	updateTweetButton();
	multiFileUploader = new qq.FineUploader({
		session: {
			endpoint: '/f/GetIllustFileListF.jsp?TD=' + contentid + '&ID=' + userid,
			refreshOnRequest: true
		},
		element: document.getElementById("file-drop-area"),
		autoUpload: false,
		button: document.getElementById('TimeLineAddImage'),
		maxConnections: 1,
		messages: FINE_UPLOADER_ERROR,
		showMessage: function() {
			// FineUploader側で実装されているDlg表示をしないようにする。
			// エラーダイアログ表示は、onValidate(), onErrror()で実装する。
		},
		validation: {
			allowedExtensions: ['jpeg', 'jpg', 'gif', 'png'],
			itemLimit: fileNumMax,
			sizeLimit: fileSizeMax*1024*1024,
			stopOnFirstInvalidFile: false
		},
		retry: {
			enableAuto: false
		},
		callbacks: {
			onUpload: function(id, name) {
				if (this.newfile_num && this.newfile_num > 0) {
					this.setEndpoint('/f/UpdateFileAppendF.jsp', id);
					this.setParams({
						UID: this.user_id,
						IID: this.content_id,
					}, id);
				}
			},
			onComplete: function(id, name, response, xhr) {
				//画像追加アップによって払い出されたappend_idをDOMに設定
				$('.qq-file-id-' + id).attr('id', response.append_id);
			},
			onAllComplete: function(succeeded, failed) {
				console.log("onAllComplete", succeeded, failed, this.tweet);
				if (this.newfile_num && this.newfile_num > 0) {
					//並べ替え情報の送信
					const deferred = UpdateFileOrderAjax(this.user_id, this.content_id);
					deferred.done( () => {
						if(this.tweet === 1) {
							Tweet(this.user_id, this.content_id, this.tweet_image, this.delete_tweet);
						} else {
							completeMsg();
							setTimeout(function(){
								location.href="/MyIllustListPcV.jsp";
							}, 2000);
						}
					}).fail(()=>{console.log("UpdateFileOrderAjax failed")});
				} else {
					$("li.qq-upload-success").removeClass("qq-upload-success");
					$("button.qq-upload-cancel").removeClass("qq-hide");
				}
			},
			onValidate: function(data) {
				let total = this.getSubmittedSize();
				const submit_num = this.getSubmittedNum();
				this.showTotalSize(total, submit_num);
				total += data.size;
				if (total > this._options.validation.sizeLimit) {
					showFineUploaderErrorDialog(FINE_UPLOADER_ERROR.totalSizeError);
					return false;
				}
				this.showTotalSize(total, submit_num+1);
			},
			onStatusChange: function(id, oldStatus, newStatus) {
				if (this.newfile_num && this.newfile_num > 0) {
					this.showTotalSize(this.getSubmittedSize(), this.getSubmittedNum());
				}
			},
			onError: function(id, name, errorReason, xhrOrXdr) {
				showFineUploaderErrorDialog(errorReason);
			}
		}
	});
	multiFileUploader.getSubmittedNum = function() {
		const uploads = this.getUploads({
			status: qq.status.SUBMITTED
		});
		return uploads.length;
	};
	multiFileUploader.getSubmittedSize = function() {
		const uploads = this.getUploads({
			status: qq.status.SUBMITTED
		});
		let total = 0;
		$.each(uploads,function(){
			total+=this.size;
		});
		return total;
	};
	multiFileUploader.showTotalSize = function(total, submit_num) {
		var strTotal = "(jpeg|png|gif, "+fileNumMax+"files, total "+fileSizeMax+"MByte)";
		if(total>0) {
			strTotal="("+ submit_num+"/"+fileNumMax + "files " + Math.ceil(total/1024.0/1024.0) + "/" + fileSizeMax + "MByte)";
			$('#TimeLineAddImage').removeClass('Light');
			completeAddFile();
		}
		$('#TotalSize').html(strTotal);
	};
	multiFileUploader.sessionRequestComplete = function (event, response, success, rawData) {
				alert(response);
		};
	multiFileUploader.total_size = 50*1024*1024;
}

function Tweet(nUserId, nContentId, nTweetImage, nDeleteTweet) {
	$.ajax({
		"type": "post",
		"data": {
			UID: nUserId,
			IID: nContentId,
			IMG: nTweetImage,
			DELTW: nDeleteTweet,
		},
		"url": "/api/UploadFileTweetF.jsp",
		"dataType": "json",
		"success": function (data) {
			tweetSucceeded(data.result);
		}
	});
}

//画像ファイルの更新アップロード
function UpdateFile(user_id, content_id) {
	if(!multiFileUploader) return;
	if($('.qq-upload-list-selector.qq-upload-list').children('li').length<=0) return;
	let genre = $('#TagInputItemData').val();
	const nCategory = parseInt($('#EditCategory').val(), 10);
	const strDescription = $.trim($("#EditDescription").val());
	let strTagList = $.trim($("#EditTagList").val());
	strTagList = strTagList.substr(0 , 100);
	const nOpenId = parseInt($('#ContentOpenId').val(), 10);
	const nPublishId = parseInt($('#EditPublish').val(), 10);
	let strPassword = $('#EditPassword').val();
	const nCheerNg = ($('#OptionCheerNg').prop('checked'))?0:1;
	const nRecent = ($('#OptionRecent').prop('checked'))?1:0;
	let nTweet = ($('#OptionTweet').prop('checked'))?1:0;
	const nTweetImage = ($('#OptionImage').prop('checked'))?1:0;
	const nDeleteTweet = ($('#OptionDeleteTweet').prop('checked'))?1:0;
	let nTwListId = null;
	const nLimitedTime = getLimitedTimeFlg('EditPublish', 'OptionLimitedTimePublish');
	let strPublishStart = null;
	let strPublishEnd = null;
	if(nPublishId === 10){
		if($("#TwitterListNotFound").is(':visible')){
			twitterListNotFoundMsg();
			return;
		}
		nTwListId = $('#EditTwitterList').val();
	}
	if(nLimitedTime === 1){
		strPublishStart = getPublishDateTime($('#EditTimeLimitedStart').val());
		strPublishEnd = getPublishDateTime($('#EditTimeLimitedEnd').val());
		strPublishStartPresent = $('#EditTimeLimitedStartPresent').val();
		strPublishEndPresent = $('#EditTimeLimitedEndPresent').val();
		if(!checkPublishDatetime(strPublishStart, strPublishEnd, true, strPublishStartPresent, strPublishEndPresent)){
			bEntered = false;
			return;
		}
	}

	console.log(multiFileUploader.getSubmittedNum());
	const nPublishAllNum = $('#OptionAnyoneCanViewFirst').prop('checked') ? 1 : 0;
	if (nPublishAllNum > 0 && multiFileUploader.getSubmittedNum() < 2) {
		anyoneCanViewFirstErrMsg();
		return;
	}

	if(!($('#TagInputItemData').length)) genre=1;

	setTweetSetting($('#OptionTweet').prop('checked'));
	setTweetImageSetting($('#OptionImage').prop('checked'));
	setTwitterCardThumbnailSetting($('#OptionTwitterCardThumbnail').prop('checked'));
	setLastCategorySetting(nCategory);
	if(nPublishId === 99) {
		nTweet = 0;
	}
	startMsg();

	let nTweetNow = nTweet;
	if(nLimitedTime === 1){
		if(nOpenId !== 2 && (strPublishStartPresent==null||strPublishEndPresent==null)){
			nTweetNow = 0;
		} else if(nTweet === 1 && nOpenId !== 2 && comparePublishDate(strPublishStartPresent,strPublishStart) && comparePublishDate(strPublishEndPresent, strPublishEnd)){
			nTweetNow = 1;
		} else {
			nTweetNow = 0;
		}
	}

	startMsg();

	$.ajaxSingle({
		"type": "post",
		"data": {
			"IID":content_id,
			"UID":user_id,
			"GD" :genre,
			"CAT":nCategory,
			"DES":strDescription,
			"TAG":strTagList,
			"PID":nPublishId,
			"PPW":strPassword,
			"PLD":nTwListId,
			"LTP":nLimitedTime,
			"REC":nRecent,
			"PST":strPublishStart,
			"PED":strPublishEnd,
			"TWT":getTweetSetting(),
			"TWI":getTweetImageSetting(),
			"TWCT":getTwitterCardThumbnailSetting(),
			"DELTW":nDeleteTweet,
			"ED":0,
			"CNG":nCheerNg,
			"PUBALL":nPublishAllNum,
		},
		"url": "/f/UpdateFileRefTwitterF.jsp",
		"dataType": "json",
		"success": function(data) {
			if (data && data.content_id > 0) {
				if (multiFileUploader.getSubmittedNum()>0) {
					multiFileUploader.user_id = user_id;
					multiFileUploader.content_id = data.content_id;
					multiFileUploader.tweet = nTweetNow;
					multiFileUploader.tweet_image = nTweetImage;
					multiFileUploader.delete_tweet = nDeleteTweet;
					multiFileUploader.newfile_num = multiFileUploader.getSubmittedNum();
					multiFileUploader.uploadStoredFiles();
				} else {
					const deferred = UpdateFileOrderAjax(user_id, data.content_id);
					deferred.done(()=>{
						if(nTweetNow === 1){
							Tweet(user_id, data.content_id, nTweetImage, nDeleteTweet);
						}else{
							completeMsg();
							setTimeout(function(){
								location.href="/MyIllustListPcV.jsp";
							}, 2000);
						}
					});
				}
			} else {
				errorMsg();
			}
		}
	});
}

//画像ペーストエリアの初期化
function initUpdatePaste(user_id, content_id) {
	updateTweetButton();

	var cCategory = getLastCategorySetting();
	$('#EditCategory option').each(function(){
		if($(this).val()==cCategory) {
			$('#EditCategory').val(cCategory);
		}
	});

	g_strPasteMsg = $('#TimeLineAddImage').html();
	$('#TimeLineAddImage').pastableContenteditable();
	$('#TimeLineAddImage').on('pasteImage', function(ev, data){
		if($('.InputFile').length<10) {
			var $elmPaste = createPasteElm(data.dataURL);
			$('#PasteZone').append($elmPaste);
			$('#TimeLineAddImage').html(g_strPasteMsg);
		}
		updatePasteNum();
	}).on('pasteImageError', function(ev, data){
		if(data.url){
			alert('error data : ' + data.url)
		}
	}).on('pasteText', function(ev, data){
		$('#TimeLineAddImage').html(g_strPasteMsg);
	});

	$.ajax({
		"type": "post",
		"data": {
			ID: user_id,
			TD: content_id
		},
		"url": "/f/GetIllustFileListF.jsp",
		"dataType": "json",
		"success": function(data) {
			$.each(data, function(index, value) {
				if($('.InputFile').length<10) {
					var $elmPaste = createPasteListItem(value.thumbnailUrl, value.append_id);
					$('#PasteZone').append($elmPaste);
					$('#TimeLineAddImage').html(g_strPasteMsg);
				}
				updatePasteNum();
			});
		}
	});
}

function UpdatePasteAppendFAjax(img_element, user_id, content_id){
	img_element.parent().addClass('Done');
	var strEncodeImg = img_element.attr('src').replace('data:image/png;base64,', '');
	if(strEncodeImg.length<=0) return null;

	return $.ajax({
		"type": "post",
		"data": {
			"UID":user_id,
			"IID":content_id,
			"DATA":strEncodeImg,
		},
		"url": "/f/UpdatePasteAppendF.jsp",
		"dataType": "json",
		"async": false,
	});
}

function UpdateFileRefTwitterFAjax(data){
	return $.ajax({
		"type": "post",
		"data": data,
		"url": "/f/UpdateFileRefTwitterF.jsp",
		"dataType": "json",
	});
}


function UploadTextRefTwitterFAjax(data){
	return $.ajax({
		"type": "post",
		"data": data,
		"url": "/f/UpdateTextRefTwitterF.jsp",
		"dataType": "json",
	});
}

function UploadFileTweetFAjax(user_id, content_id, nTweetImage, nDeleteTweet){
	return $.ajax({
		"type": "post",
		"data": {
			UID: user_id,
			IID: content_id,
			IMG: nTweetImage,
			DELTW: nDeleteTweet,
		},
		"url": "/api/UploadFileTweetF.jsp",
		"dataType": "json",
	});
}

//ペースト画像の更新
function createUpdatePaste(){
	var bEntered = false;
	return function UpdatePaste(user_id, content_id) {
		if(bEntered) return;
		bEntered = true;

		// check image
		var nImageNum = 0;
		$('.imgView').each(function(){
			var strSrc = $.trim($(this).attr('src'));
			if(strSrc.length>0) nImageNum++;
		});
		if(nImageNum<=0){
			bEntered = false;
			return;
		}
		let genre = $('#TagInputItemData').val();
		const nCategory = parseInt($('#EditCategory').val(), 10);
		const strDescription = $.trim($("#EditDescription").val());
		let strTagList = $.trim($("#EditTagList").val());
		strTagList = strTagList.substr(0 , 100);
		const nOpenId = $('#ContentOpenId').val();
		const nPublishId = parseInt($('#EditPublish').val(), 10);
		const strPassword = $('#EditPassword').val();
		const nCheerNg = ($('#OptionCheerNg').prop('checked'))?0:1;
		const nRecent = ($('#OptionRecent').prop('checked'))?1:0;
		let nTweet = ($('#OptionTweet').prop('checked'))?1:0;
		const nTweetImage = ($('#OptionImage').prop('checked'))?1:0;
		const nDeleteTweet = ($('#OptionDeleteTweet').prop('checked'))?1:0;
		let nTwListId = null;
		const nLimitedTime = getLimitedTimeFlg('EditPublish', 'OptionLimitedTimePublish');
		let strPublishStart = null;
		let strPublishEnd = null;
		if(nPublishId === 10){
			if($("#TwitterListNotFound").is(':visible')){
				bEntered = false;
				twitterListNotFoundMsg();
				return;
			}
			nTwListId = $('#EditTwitterList').val();
		}
		if(nLimitedTime === 1){
			strPublishStart = getPublishDateTime($('#EditTimeLimitedStart').val());
			strPublishEnd = getPublishDateTime($('#EditTimeLimitedEnd').val());
			strPublishStartPresent = $('#EditTimeLimitedStartPresent').val();
			strPublishEndPresent = $('#EditTimeLimitedEndPresent').val();
			if(!checkPublishDatetime(strPublishStart, strPublishEnd, true, strPublishStartPresent, strPublishEndPresent)){
				bEntered = false;
				return;
			}
		}
		if(!($('#TagInputItemData').length)) genre=1;

		setTweetSetting($('#OptionTweet').prop('checked'));
		setTweetImageSetting($('#OptionImage').prop('checked'));
		setTwitterCardThumbnailSetting($('#OptionTwitterCardThumbnail').prop('checked'));
		setLastCategorySetting(nCategory);
		if(nPublishId === 99) {
			nTweet = 0;
		}

		let nTweetNow = nTweet;
		if(nLimitedTime === 1){
			if(nOpenId !== 2 && (strPublishStartPresent==null||strPublishEndPresent==null)){
				nTweetNow = 0;
			} else if(nTweet === 1 && nOpenId !== 2 && comparePublishDate(strPublishStartPresent,strPublishStart) && comparePublishDate(strPublishEndPresent, strPublishEnd)){
				nTweetNow = 1;
			} else {
				nTweetNow = 0;
			}
		}

		startMsg();

		const data = {
			"UID":user_id,
			"IID":content_id,
			"GD" :genre,
			"CAT":nCategory,
			"DES":strDescription,
			"TAG":strTagList,
			"PID":nPublishId,
			"PPW":strPassword,
			"PLD":nTwListId,
			"LTP":nLimitedTime,
			"REC":nRecent,
			"PST":strPublishStart,
			"PED":strPublishEnd,
			"TWT":getTweetSetting(),
			"TWI":getTweetImageSetting(),
			"TWCT":getTwitterCardThumbnailSetting(),
			"DELTW":nDeleteTweet,
			"ED":1,
			"CNG":nCheerNg,
		};
		let fUpdateFile = UpdateFileRefTwitterFAjax(data);

		let aryFunc = [];
		let fTweet = null;

		fUpdateFile.done(
			function(data){
				let f = null;
				$('.imgView').each(function(){
					f = UpdatePasteAppendFAjax($(this),user_id,data.content_id);
					if (f != null){
						aryFunc.push(f);
					}
				});

				if(nTweetNow === 1) {
					fTweet = UploadFileTweetFAjax(user_id, data.content_id, nTweetImage, nDeleteTweet);
				} else {
					fTweet = function() {
						let dfd = $.Deferred();
						dfd.resolve(1);
						return dfd.promise();
					};
				}

				$.when.apply($, aryFunc)
				.then(function(){
					var json_array = [];
					$.each($('#PasteZone').sortable('toArray'), function(i, item) {
						json_array.push(parseInt(item))
					});
					for (let i = 0; i < arguments.length; i++) {
						let aid;
						if(json_array.length === 1){
							aid = arguments[0].append_id;
						}else{
							aid = arguments[i][0].append_id;
						}
						if(aid >= 0){
							json_array[i] = aid;
						}
						if(json_array.length === 1){
							break;
						}
					}
					return UpdatePasteOrderAjax(user_id, data.content_id, json_array);
				},function(err){errorMsg(-10);})
				.then(fTweet, function(err){errorMsg(-11)})
				.then(
					function(data){
						tweetSucceeded(data);
					},
					function(err){errorMsg(-12)}
				);
			}
		);
		return false;
	}
}
var UpdatePaste = createUpdatePaste();


// テキストの更新
function createUpdateText(){
	let bEntered = false;
	return function UpdateText(user_id, content_id) {
		if(bEntered) return;
		bEntered = true;

		let genre = $('#TagInputItemData').val();
		const nCategory = parseInt($('#EditCategory').val(), 10);
		const strDescription = $.trim($("#EditDescription").val());
		const strTextBody = $("#EditTextBody").val();
		let strTagList = $.trim($("#EditTagList").val());
		strTagList = strTagList.substr(0 , 100);
		const nOpenId = $('#ContentOpenId').val();
		const nPublishId = parseInt($('#EditPublish').val(), 10);
		const strPassword = $('#EditPassword').val();
		const nCheerNg = ($('#OptionCheerNg').prop('checked'))?0:1;
		const nRecent = ($('#OptionRecent').prop('checked'))?1:0;
		let nTweet = ($('#OptionTweet').prop('checked'))?1:0;
		const title = $("#EditTextTitle").val();
		const direction = $('input:radio[name="EditTextDirection"]:checked').val();

		const nTweetImage = 0;
		const nDeleteTweet = ($('#OptionDeleteTweet').prop('checked'))?1:0;
		let nTwListId = null;
		const nLimitedTime = getLimitedTimeFlg('EditPublish', 'OptionLimitedTimePublish');
		let strPublishStart = null;
		let strPublishEnd = null;
		if(nPublishId === 10){
			if($("#TwitterListNotFound").is(':visible')){
				twitterListNotFoundMsg();
				return;
			}
			nTwListId = $('#EditTwitterList').val();
		}
		if(nLimitedTime === 1){
			strPublishStart = getPublishDateTime($('#EditTimeLimitedStart').val());
			strPublishEnd = getPublishDateTime($('#EditTimeLimitedEnd').val());
			strPublishStartPresent = $('#EditTimeLimitedStartPresent').val();
			strPublishEndPresent = $('#EditTimeLimitedEndPresent').val();
			if(!checkPublishDatetime(strPublishStart, strPublishEnd, true, strPublishStartPresent, strPublishEndPresent)){
				bEntered = false;
				return;
			}
		}
		if(!($('#TagInputItemData').length)) genre=1;

		setTweetSetting($('#OptionTweet').prop('checked'));
		setTweetImageSetting($('#OptionImage').prop('checked'));
		setLastCategorySetting(nCategory);
		if(nPublishId === 99) {
			nTweet = 0;
		}

		let nTweetNow = nTweet;
		if(nLimitedTime === 1){
			if(nOpenId !== 2 && (strPublishStartPresent==null||strPublishEndPresent==null)){
				nTweetNow = 0;
			} else if(nTweet === 1 && nOpenId !== 2 && comparePublishDate(strPublishStartPresent,strPublishStart) && comparePublishDate(strPublishEndPresent, strPublishEnd)){
				nTweetNow = 1;
			} else {
				nTweetNow = 0;
			}
		}

		startMsg();

		const data = {
			"UID":user_id,
			"IID":content_id,
			"GD" :genre,
			"CAT":nCategory,
			"DES":strDescription,
			"BDY":strTextBody,
			"TAG":strTagList,
			"PID":nPublishId,
			"PPW":strPassword,
			"PLD":nTwListId,
			"LTP":nLimitedTime,
			"REC":nRecent,
			"PST":strPublishStart,
			"PED":strPublishEnd,
			"TWT":getTweetSetting(),
			"TWI":getTweetImageSetting(),
			"DELTW":nDeleteTweet,
			"ED":3,
			"CNG":nCheerNg,
			"TIT":title,
			"DIR":direction,
		};
		let fUpdateFile = UploadTextRefTwitterFAjax(data);
		let aryFunc = [];
		let fTweet = null;

		fUpdateFile.done(
			function(data){
				if(nTweetNow === 1) {
					fTweet = UploadFileTweetFAjax(user_id, data.content_id, nTweetImage, nDeleteTweet);
				} else {
					fTweet = function() {
						let dfd = $.Deferred();
						dfd.resolve(1);
						return dfd.promise();
					};
				}

				$.when.apply($, aryFunc)
				.then(fTweet, function(err){errorMsg(-11)})
				.then(
					function(data){
						tweetSucceeded(data);
					},
					function(err){errorMsg(-12)}
				);
			}
		);
		return false;
	}
}
var UpdateText = createUpdateText();
