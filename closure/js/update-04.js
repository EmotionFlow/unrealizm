//並べ替え情報の送信
function UpdateFileOrder(user_id, content_id, location_href) {
	var json_array = [];
	$.each($('.qq-upload-list-selector.qq-upload-list').sortable('toArray'), function(i, item) {
		json_array.push(parseInt(item))
	});

	$.ajax({
		"type": "post",
		"data": {
			UID: user_id,
			IID: content_id,
			AID: JSON.stringify(json_array)
		},
		"url": "/f/UpdateFileOrderF.jsp",
		"dataType": "json",
		"success": function (data) {
			console.log("UploadFileOrderF:" + data.result);
			if (location_href && location_href.length > 0) {
				completeMsg();
				setTimeout(function(){location.href=location_href;}, 1000);
			}
		},"error": function(err){
			console.log(err);
		}
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
function initUpdateFile(userid, contentid) {
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
		validation: {
			allowedExtensions: ['jpeg', 'jpg', 'gif', 'png'],
			itemLimit: 200,
			sizeLimit: 20000000,
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
				append_id = response.append_id
				$('.qq-file-id-' + id).attr('id', append_id);
			},
			onAllComplete: function(succeeded, failed) {
				console.log("onAllComplete", succeeded, failed, this.tweet);
				if (this.newfile_num && this.newfile_num > 0) {
					if(this.tweet==1) {
						Tweet(this.user_id, this.content_id, this.tweet_image, this.delete_tweet);
					} else {
						// complete
						completeMsg();
						setTimeout(function(){
							location.href="/MyIllustListV.jsp";
						}, 1000);
					}

					//並べ替え情報の送信
					UpdateFileOrder(this.user_id, this.content_id, "/MyIllustListV.jsp");
				} else {
					$("li.qq-upload-success").removeClass("qq-upload-success");
					$("button.qq-upload-cancel").removeClass("qq-hide");
				}
			},
			onValidate: function(data) {
				var total = this.getSubmittedSize();
				var submit_num = this.getSubmittedNum();
				this.showTotalSize(total, submit_num);
				total += data.size;
				if (total>this.total_size) return false;
				this.showTotalSize(total, submit_num+1);
			},
			onStatusChange: function(id, oldStatus, newStatus) {
				if (this.newfile_num && this.newfile_num > 0) {
					this.showTotalSize(this.getSubmittedSize(), this.getSubmittedNum());
				}
			}
		}
	});
	multiFileUploader.getSubmittedNum = function() {
		var uploads = this.getUploads({
			status: qq.status.SUBMITTED
		});
		return uploads.length;
	};
	multiFileUploader.getSubmittedSize = function() {
		var uploads = this.getUploads({
			status: qq.status.SUBMITTED
		});
		var total = 0;
		$.each(uploads,function(){
			total+=this.size;
		});
		return total;
	};
	multiFileUploader.showTotalSize = function(total, submit_num) {
		var strTotal = "(jpeg|png|gif, 200files, total 50MByte)";
		if(total>0) {
			strTotal="("+ submit_num + "/200,  " + Math.ceil((multiFileUploader.total_size-total)/1024) + " KByte)";
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
			tweetSucceeded(data);
		}
	});
}

//画像ファイルの更新アップロード
function UpdateFile(user_id, content_id) {
	if(!multiFileUploader) return;
	if($('.qq-upload-list-selector.qq-upload-list').children('li').length<=0) return;
	var nCategory = $('#EditCategory').val();
	var strDescription = $.trim($("#EditDescription").val());
	strDescription = strDescription.substr(0 , 200);
	var strTagList = $.trim($("#EditTagList").val());
	strTagList = strTagList.substr(0 , 100);
	var nOpenId = $('#ContentOpenId').val();
	var nPublishId = $('#EditPublish').val();
	var strPassword = $('#EditPassword').val();
	var nCheerNg = ($('#OptionCheerNg').prop('checked'))?0:1;
	var nRecent = ($('#OptionRecent').prop('checked'))?1:0;
	var nTweet = ($('#OptionTweet').prop('checked'))?1:0;
	var nTweetImage = ($('#OptionImage').prop('checked'))?1:0;
	var nDeleteTweet = ($('#OptionDeleteTweet').prop('checked'))?1:0;
	var nTwListId = null;
	var nLimitedTime = getLimitedTimeFlg('EditPublish', 'OptionLimitedTimePublish');
	var strPublishStart = null;
	var strPublishEnd = null;
	if(nPublishId==10){
		if($("#TwitterListNotFound").is(':visible')){
			twitterListNotFoundMsg();
			return;
		}
				nTwListId = $('#EditTwitterList').val();
	}
	if(nLimitedTime==1){
		strPublishStart = getPublishDateTime($('#EditTimeLimitedStart').val());
		strPublishEnd = getPublishDateTime($('#EditTimeLimitedEnd').val());
		strPublishStartPresent = $('#EditTimeLimitedStartPresent').val();
		strPublishEndPresent = $('#EditTimeLimitedEndPresent').val();
		if(!checkPublishDatetime(strPublishStart, strPublishEnd, true, strPublishStartPresent, strPublishEndPresent)){
			return;
		}
	}

	setTweetSetting($('#OptionTweet').prop('checked'));
	setTweetImageSetting($('#OptionImage').prop('checked'));
	setLastCategorySetting(nCategory);
	if(nPublishId == 99) {
		nTweet = 0;
	}

	var nTweetNow = nTweet;
	if(nLimitedTime==1){
		if(nOpenId!=2 && (strPublishStartPresent==null||strPublishEndPresent==null)){
			nTweetNow = 0;
		} else if(nTweet==1 && nOpenId!=2 && comparePublishDate(strPublishStartPresent,strPublishStart) && comparePublishDate(strPublishEndPresent, strPublishEnd)){
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
			"DELTW":nDeleteTweet,
			"ED":0,
			"CNG":nCheerNg,
		},
		"url": "/f/UpdateFileRefTwitterF.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UpdateFileRefTwitterF:" + data.content_id);
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
					if(nTweetNow==1){
						UpdateFileOrder(user_id, data.content_id, null);
						Tweet(user_id, data.content_id, nTweetImage, nDeleteTweet);
					}else{
						UpdateFileOrder(user_id, data.content_id, "/MyIllustListV.jsp");
					}
				}
			} else {
				errorMsg(data.result);
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

function UpdateFileRefTwitterFAjax(
	user_id, content_id, nCategory, strDescription, strTagList,
	nPublishId, strPassword, nTwListId, nCheerNg, nRecent,
	nLimitedTime, strPublishStart, strPublishEnd,
	nTweetText, nTweetImage, nDeleteTweet){
	return $.ajax({
		"type": "post",
		"data": {
			"UID":user_id,
			"IID":content_id,
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
			"TWT":nTweetText,
			"TWI":nTweetImage,
			"DELTW":nDeleteTweet,
			"ED":1,
			"CNG":nCheerNg,
		},
		"url": "/f/UpdateFileRefTwitterF.jsp",
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
		"url": "/f/UploadFileTweetF.jsp",
		"dataType": "json",
	});
}

//ペースト画像のアップロード
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

		var nCategory = $('#EditCategory').val();
		var strDescription = $.trim($("#EditDescription").val());
		strDescription = strDescription.substr(0 , 200);
		var strTagList = $.trim($("#EditTagList").val());
		strTagList = strTagList.substr(0 , 100);
		var nOpenId = $('#ContentOpenId').val();
		var nPublishId = $('#EditPublish').val();
		var strPassword = $('#EditPassword').val();
		var nCheerNg = ($('#OptionCheerNg').prop('checked'))?0:1;
		var nRecent = ($('#OptionRecent').prop('checked'))?1:0;
		var nTweet = ($('#OptionTweet').prop('checked'))?1:0;
		var nTweetImage = ($('#OptionImage').prop('checked'))?1:0;
		var nDeleteTweet = ($('#OptionDeleteTweet').prop('checked'))?1:0;
		var nTwListId = null;
		var nLimitedTime = getLimitedTimeFlg('EditPublish', 'OptionLimitedTimePublish');
		var strPublishStart = null;
		var strPublishEnd = null;
		if(nPublishId==10){
			if($("#TwitterListNotFound").is(':visible')){
				bEntered = false;
				twitterListNotFoundMsg();
				return;
			}
			nTwListId = $('#EditTwitterList').val();
		}
		if(nLimitedTime==1){
			strPublishStart = getPublishDateTime($('#EditTimeLimitedStart').val());
			strPublishEnd = getPublishDateTime($('#EditTimeLimitedEnd').val());
			strPublishStartPresent = $('#EditTimeLimitedStartPresent').val();
			strPublishEndPresent = $('#EditTimeLimitedEndPresent').val();
			if(!checkPublishDatetime(strPublishStart, strPublishEnd, true, strPublishStartPresent, strPublishEndPresent)){
				bEntered = false;
				return;
			}
		}

		setTweetSetting($('#OptionTweet').prop('checked'));
		setTweetImageSetting($('#OptionImage').prop('checked'));
		setLastCategorySetting(nCategory);
		if(nPublishId == 99) {
			nTweet = 0;
		}

		var nTweetNow = nTweet;
		if(nLimitedTime==1){
			if(nOpenId!=2 && (strPublishStartPresent==null||strPublishEndPresent==null)){
				nTweetNow = 0;
			} else if(nTweet==1 && nOpenId!=2 && comparePublishDate(strPublishStartPresent,strPublishStart) && comparePublishDate(strPublishEndPresent, strPublishEnd)){
				nTweetNow = 1;
			} else {
				nTweetNow = 0;
			}
		}

		startMsg();

		var fUpdateFile = UpdateFileRefTwitterFAjax(
			user_id, content_id, nCategory, strDescription, strTagList,
			nPublishId, strPassword, nTwListId, nCheerNg, nRecent,
			nLimitedTime, strPublishStart, strPublishEnd,
			getTweetSetting(), getTweetImageSetting(), nDeleteTweet);

		var aryFunc = [];
		var fTweet = null;

		fUpdateFile.done(
			function(data){
				var f = null;
				$('.imgView').each(function(){
					f = UpdatePasteAppendFAjax($(this),user_id,data.content_id);
					if (f != null){
						aryFunc.push(f);
					}
				});

				if(nTweetNow==1) {
					fTweet = UploadFileTweetFAjax(user_id, data.content_id, nTweetImage, nDeleteTweet);
				} else {
					fTweet = function() {
						var dfd = $.Deferred();
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
					for (var i = 0; i < arguments.length; i++) {
						var aid;
						if(json_array.length==1){
							aid = arguments[0].append_id;
						}else{
							aid = arguments[i][0].append_id;
						}
						if(aid >= 0){
							json_array[i] = aid;
						}
						if(json_array.length==1){
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
