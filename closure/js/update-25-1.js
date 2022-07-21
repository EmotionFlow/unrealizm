const uploadListId = '.qq-upload-list-selector.qq-upload-list';
const pasteListId = '#PasteZone';
//並べ替え情報の送信
function UpdateFileOrderAjax(user_id, content_id) {
	let json_array = [];
	$.each($(uploadListId).sortable('toArray'), function(i, item) {
		json_array.push(parseInt(item))
	});

	return $.ajax({
		"type": "post",
		"data": {
			UID: user_id,
			IID: content_id,
			AID: JSON.stringify(json_array),
			FirstNewID: $(uploadListId).attr('data-first-new-id') || 0,
		},
		"url": "/f/UpdateFileOrderF.jsp",
		"dataType": "json",
	});
}

function UpdatePasteOrderAjax(user_id, content_id, append_ids, firstNewID){
	return $.ajax({
		"type": "post",
		"data": {
			UID: user_id,
			IID: content_id,
			AID: JSON.stringify(append_ids),
			FirstNewID: firstNewID || 0,
		},
		"url": "/f/UpdateFileOrderF.jsp",
		"dataType": "json",
	});
}

//ファイル選択エリアの初期化
function initUpdateFile(fileNumMax, fileSizeMax, userId, contentId) {
	multiFileUploader = new qq.FineUploader({
		session: {
			endpoint: '/f/GetIllustFileListF.jsp?TD=' + contentId + '&ID=' + userId,
			refreshOnRequest: true
		},
		element: document.getElementById("file-drop-area"),
		autoUpload: false,
		button: document.getElementById('TimeLineAddImage'),
		maxConnections: 1,
		messages: FINE_UPLOADER_ERROR,
		showMessage: function() {
			// FineUploader側で実装されているDlg表示をしないようにする。
			// エラーダイアログ表示は、onValidate(), onError()で実装する。
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
					this.setEndpoint('/f/UpdateFileAppendV2F.jsp', id);
					this.setParams({
						UID: this.user_id,
						IID: this.content_id,
					}, id);
				}
			},
			onComplete: function(id, name, response, xhr) {
				//画像追加アップによって払い出されたappend_idをDOMに設定
				$('.qq-file-id-' + id).attr('id', response.append_id);
				if (!$(uploadListId).attr('data-first-new-id')) $(uploadListId).attr('data-first-new-id', response.append_id);
			},
			onAllComplete: function(succeeded, failed) {
				console.log("onAllComplete", succeeded, failed, this.tweet);
				if (this.newfile_num && this.newfile_num > 0) {
					//並べ替え情報の送信
					const deferred = UpdateFileOrderAjax(this.user_id, this.content_id);
					deferred.done( () => {
						if(this.tweet) {
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
				let total = this.getTotalSize();
				const total_num = this.getTotalNum();
				this.showTotalSize(total, total_num);
				total += data.size;
				if (total > this._options.validation.sizeLimit) {
					showFineUploaderErrorDialog(FINE_UPLOADER_ERROR.totalSizeError);
					return false;
				}
				this.showTotalSize(total, total_num+1);
			},
			onStatusChange: function(id, oldStatus, newStatus) {
				if (this.newfile_num && this.newfile_num > 0 || newStatus == 'canceled') {
					this.showTotalSize();
				}
			},
			onError: function(id, name, errorReason, xhrOrXdr) {
				showFineUploaderErrorDialog(errorReason);
			},
			onSessionRequestComplete: function(response, success, xhrOrXdr) {
				this.showTotalSize();
			}
		}
	});
	multiFileUploader.getSubmittedNum = function() {
		const uploads = this.getUploads({
			status: qq.status.SUBMITTED
		});
		return uploads.length;
	};
	multiFileUploader.getTotalNum = function() {
		const uploads = this.getUploads({
			status: qq.status.UPLOAD_SUCCESSFUL
		});
		return this.getSubmittedNum() + uploads.length;
	};
	multiFileUploader.getTotalSize = function() {
		const uploads = this.getUploads({
			status: [qq.status.SUBMITTED, qq.status.UPLOAD_SUCCESSFUL]
		});
		let total = 0;
		$.each(uploads,function(){
			total+=this.size;
		});
		return total;
	};
	multiFileUploader.showTotalSize = function(total, submit_num) {
		total = total || this.getTotalSize();
		submit_num = submit_num || this.getTotalNum();
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
		"url": "/f/UploadFileTweetF.jsp",
		"dataType": "json",
		"success": function (data) {
			tweetSucceeded(data.result);
		}
	});
}

function _getUpdatePostData(userId, contentId, editorId) {
	let postData = _getBasePostData(userId, null, editorId);
	if (!postData) return null;

	postData["DELTW"] = ($('#OPTION_DELETE_TWEET').prop('checked')) ? 1 : 0;
	postData["IID"] = contentId;

	return postData;
}

function _preCheckForUpdate(postData) {
	let nTweetNow = postData.OPTION_TWEET ? 1 : 0;
	const nOpenId = $('#ContentOpenId').val();
	if (!postData.OPTION_NOT_TIME_LIMITED){
		let strPublishStartPresent = "";
		let strPublishEndPresent = "";
		strPublishStartPresent = $('#EditTimeLimitedStartPresent').val();
		strPublishEndPresent = $('#EditTimeLimitedEndPresent').val();
		if(!checkPublishDatetime(postData.TIME_LIMITED_START, postData.TIME_LIMITED_END, true, strPublishStartPresent, strPublishEndPresent)){
			return null;
		}
		if(nOpenId !== 2 && (strPublishStartPresent==null||strPublishEndPresent==null)){
			nTweetNow = 0;
		} else if(postData.OPTION_TWEET && nOpenId !== 2 && comparePublishDate(strPublishStartPresent,postData.TIME_LIMITED_START) && comparePublishDate(strPublishEndPresent, postData.TIME_LIMITED_END)){
			nTweetNow = 1;
		} else {
			nTweetNow = 0;
		}
	}
	return nTweetNow;
}

//画像ファイルの更新アップロード
function UpdateFile(userId, contentId) {
	if(!multiFileUploader) return;
	if($(uploadListId).children('li').length<=0) return;

	const editorId = 0;
	let postData = _getUpdatePostData(userId, contentId, editorId);

	let nTweetNow = _preCheckForUpdate(postData);
	if (nTweetNow == null) return;

	setLastCategorySetting(postData.CAT);
	startMsg();

	$.ajaxSingle({
		"type": "post",
		"data": postData,
		"url": "/f/UpdateFileRefTwitterV2F.jsp",
		"dataType": "json",
		"success": function(data) {
			if (data && data.content_id > 0) {
				if (multiFileUploader.getSubmittedNum()>0) {
					multiFileUploader.user_id = userId;
					multiFileUploader.content_id = data.content_id;
					multiFileUploader.tweet = nTweetNow;
					multiFileUploader.tweet_image = postData.OPTION_TWEET_IMAGE;
					multiFileUploader.delete_tweet = postData.DELTW;
					multiFileUploader.newfile_num = multiFileUploader.getSubmittedNum();
					multiFileUploader.uploadStoredFiles();
				} else {
					const deferred = UpdateFileOrderAjax(userId, data.content_id);
					deferred.done(()=>{
						if(nTweetNow === 1){
							Tweet(userId, data.content_id, postData.OPTION_TWEET_IMAGE, postData.DELTW);
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
	// var cCategory = getLastCategorySetting();
	// $('#EditCategory option').each(function(){
	// 	if($(this).val()==cCategory) {
	// 		$('#EditCategory').val(cCategory);
	// 	}
	// });

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
		"url": "/f/UpdatePasteAppendV2F.jsp",
		"dataType": "json",
		"async": false,
	});
}

function UpdateFileRefTwitterFAjax(data){
	return $.ajax({
		"type": "post",
		"data": data,
		"url": "/f/UpdateFileRefTwitterV2F.jsp",
		"dataType": "json",
	});
}


function UpdateTextRefTwitterFAjax(data){
	return $.ajax({
		"type": "post",
		"data": data,
		"url": "/f/UpdateTextRefTwitterV2F.jsp",
		"dataType": "json",
	});
}

function UploadFileTweetFAjax(user_id, content_id, isTweetWithImage, nDeleteTweet){
	return $.ajax({
		"type": "post",
		"data": {
			UID: user_id,
			IID: content_id,
			IMG: isTweetWithImage ? 1 : 0,
			DELTW: nDeleteTweet,
		},
		"url": "/f/UploadFileTweetF.jsp",
		"dataType": "json",
	});
}

//ペースト画像の更新
function createUpdatePasteFunction(){
	var nowProcessing = false;
	return function UpdatePaste(userId, contentId) {
		if(nowProcessing) return;
		nowProcessing = true;

		// check image
		let nImageNum = 0;
		$('.imgView').each(function(){
			const strSrc = $.trim($(this).attr('src'));
			if(strSrc.length>0) nImageNum++;
		});
		if(nImageNum<=0){
			nowProcessing = false;
			return;
		}

		const editorId = 1;
		let postData = _getUpdatePostData(userId, contentId, editorId);

		let nTweetNow = _preCheckForUpdate(postData);
		if (nTweetNow == null) {
			nowProcessing = false;
			return;
		}

		setLastCategorySetting(postData.CAT);
		startMsg();

		let fUpdateFile = UpdateFileRefTwitterFAjax(postData);
		let aryFunc = [];
		let fTweet = null;

		fUpdateFile.done(
			function(data){
				let f = null;
				$('.imgView').each(function(){
					f = UpdatePasteAppendFAjax($(this),userId,data.content_id);
					if (f != null){
						aryFunc.push(f);
					}
				});

				if(nTweetNow === 1) {
					fTweet = UploadFileTweetFAjax(userId, data.content_id, postData.OPTION_TWEET_IMAGE, postData.DELTW);
				} else {
					fTweet = function() {
						let dfd = $.Deferred();
						dfd.resolve(1);
						return dfd.promise();
					};
				}

				$.when.apply($, aryFunc)
				.then(function(){
					let json_array = [];
					let firstNewID = null;
					$.each($('#PasteZone').sortable('toArray'), function(i, item) {
						json_array.push(parseInt(item));
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
							if (!firstNewID || firstNewID > aid) firstNewID = aid;
						}
						if(json_array.length === 1){
							break;
						}
					}
					return UpdatePasteOrderAjax(userId, data.content_id, json_array, firstNewID);
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
var UpdatePaste = createUpdatePasteFunction();


// テキストの更新
function createUpdateTextFunction(){
	let nowProcessing = false;
	return function UpdateText(userId, contentId) {
		if(nowProcessing) return;
		nowProcessing = true;

		const editorId = 3;

		let postData = _getUpdatePostData(userId, contentId, editorId);
		if (postData == null) {
			nowProcessing = false;
			return;
		}

		let nTweetNow = _preCheckForUpdate(postData);
		if (nTweetNow == null) {
			nowProcessing = false;
			return;
		}

		startMsg();

		let fUpdateFile = UpdateTextRefTwitterFAjax(postData);
		let aryFunc = [];
		let fTweet = null;

		fUpdateFile.done(
			function(data){
				if(nTweetNow === 1) {
					fTweet = UploadFileTweetFAjax(userId, data.content_id, postData.OPTION_TWEET_IMAGE, postData.DELTW);
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
var UpdateText = createUpdateTextFunction();
