//並べ替え情報の送信
function UpdateFileOrder(user_id, content_id) {
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
		"success": function(data) {
			console.log("UploadFileOrderF:" + data.result);
		}
	});
}

//並べ替え情報の送信
function UpdatePasteOrder(user_id, content_id) {
	var json_array = [];
	$.each($('#PasteZone').sortable('toArray'), function(i, item) {
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
		"success": function(data) {
			console.log("UploadFileOrderF:" + data.result);
		}
	});
}

//ファイル選択エリアの初期化
function initUpdateFile(userid, contentid) {
	$('#OptionTweet').prop('checked', getTweetSetting());
	$('#OptionImage').prop('checked', getTweetImageSetting());
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
						IID: this.illust_id,
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
						$.ajax({
							"type": "post",
							"data": {
								UID: this.user_id,
								IID: this.illust_id,
								IMG: this.tweet_image
							},
							"url": "/f/UploadFileTweetF.jsp",
							"dataType": "json",
							"success": function(data) {
								console.log("UploadFileTweetF");
								// complete
								completeMsg();
								setTimeout(function(){
									location.href="/MyHomePcV.jsp";
								}, 1000);
							}
						});
					} else {
						// complete
						completeMsg();
						setTimeout(function(){
							location.href="/MyHomePcV.jsp";
						}, 1000);
					}

					//並べ替え情報の送信
					UpdateFileOrder(this.user_id, this.illust_id);
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

//画像ファイルの更新アップロード
function UpdateFile(user_id, content_id) {
	if(!multiFileUploader) return;
	var nCategory = $('#EditCategory').val();
	var strDescription = $.trim($("#EditDescription").val());
	strDescription = strDescription.substr(0 , 200);
	var strTagList = $.trim($("#EditTagList").val());
	strTagList = strTagList.substr(0 , 100);
	var nPublishId = $('#EditPublish').val();
	var strPassword = $('#EditPassword').val();
	var nRecent = ($('#OptionRecent').prop('checked'))?1:0;
	var nTweet = ($('#OptionTweet').prop('checked'))?1:0;
	var nTweetImage = ($('#OptionImage').prop('checked'))?1:0;
	setTweetSetting($('#OptionTweet').prop('checked'));
	setTweetImageSetting($('#OptionImage').prop('checked'));
	setLastCategorySetting(nCategory);
	if(nPublishId == 99) {
		nRecent = 2;
		nTweet = 0;
	}

	startMsg();

	$.ajaxSingle({
		"type": "post",
		"data": {
			"UID":user_id,
			"IID":content_id,
			"CAT":nCategory,
			"DES":strDescription,
			"TAG":strTagList,
			"PID":nPublishId,
			"PPW":strPassword,
			"PLD":"",
			"REC": nRecent,
			"ED":0
		},
		"url": "/f/UpdateFileRefTwitterF.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UpdateFileRefTwitterF:" + data.content_id);
			if (data && data.content_id > 0) {
				if (multiFileUploader.getSubmittedNum()>0) {
					multiFileUploader.user_id = user_id;
					multiFileUploader.illust_id = content_id;
					multiFileUploader.recent = nRecent;
					multiFileUploader.first_file = true;
					multiFileUploader.tweet = nTweet;
					multiFileUploader.tweet_image = nTweetImage;
					multiFileUploader.newfile_num = multiFileUploader.getSubmittedNum();
					multiFileUploader.uploadStoredFiles();
				} else {
					UpdateFileOrder(user_id, content_id);
					location.href="/MyHomePcV.jsp";
				}
			} else {
				errorMsg();
			}
		}
	});
}

//画像ペーストエリアの初期化
function initUpdatePaste(user_id, content_id) {
	console.log("initUpdatePaste");

	$('#OptionTweet').prop('checked', getTweetSetting());
	$('#OptionImage').prop('checked', getTweetImageSetting());
	var cCategory = getLastCategorySetting();
	$('#EditCategory option').each(function(){
		console.log($(this).val());
		if($(this).val()==cCategory) {
			$('#EditCategory').val(cCategory);
		}
	});
	updateTweetButton();

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

//ペースト画像のアップロード
function UpdatePaste(user_id, content_id) {
	// check image
	var nImageNum = 0;
	$('.imgView').each(function(){
		var strSrc = $.trim($(this).attr('src'));
		if(strSrc.length>0) nImageNum++;
	});
	console.log(nImageNum);
	if(nImageNum<=0) return;

	var nCategory = $('#EditCategory').val();
	var strDescription = $.trim($("#EditDescription").val());
	strDescription = strDescription.substr(0 , 200);
	var strTagList = $.trim($("#EditTagList").val());
	strTagList = strTagList.substr(0 , 100);
	var nPublishId = $('#EditPublish').val();
	var strPassword = $('#EditPassword').val();
	var nRecent = ($('#OptionRecent').prop('checked'))?1:0;
	var nTweet = ($('#OptionTweet').prop('checked'))?1:0;
	var nTweetImage = ($('#OptionImage').prop('checked'))?1:0;
	setTweetSetting($('#OptionTweet').prop('checked'));
	setTweetImageSetting($('#OptionImage').prop('checked'));
	setLastCategorySetting(nCategory);
	if(nPublishId == 99) {
		nRecent = 2;
		nTweet = 0;
	}
	startMsg();

	$.ajaxSingle({
		"type": "post",
		"data": {
			"UID":user_id,
			"IID":content_id,
			"CAT":nCategory,
			"DES":strDescription,
			"TAG":strTagList,
			"PID":nPublishId,
			"PPW":strPassword,
			"PLD":"",
			"REC": nRecent,
			"ED":1
		},
		"url": "/f/UpdateFileRefTwitterF.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UpdateFileRefTwitterF", data.content_id);
			var first_file = true;
			$('.imgView').each(function(){
				$(this).parent().addClass('Done');
				var strEncodeImg = $(this).attr('src').replace('data:image/png;base64,', '');
				if(strEncodeImg.length<=0) return true;

				$.ajax({
					"type": "post",
					"data": {
						"UID":user_id,
						"IID":data.content_id,
						"DATA":strEncodeImg,
					},
					"url": "/f/UpdatePasteAppendF.jsp",
					"dataType": "json",
					"async": false,
					"success": function(data) {
						console.log("UploadPasteAppendF");
					}
				});
			});
			if(nTweet==1) {
				$.ajax({
					"type": "post",
					"data": {
						UID: user_id,
						IID: data.content_id,
						IMG: nTweetImage,
					},
					"url": "/f/UploadFileTweetF.jsp",
					"dataType": "json",
					"success": function(data) {
						console.log("UpdateFileTweetF");
						// complete
						completeMsg();
						setTimeout(function(){
							location.href="/MyHomePcV.jsp";
						}, 1000);
					}
				});
			} else {
				setTimeout(function(){
					location.href="/MyHomePcV.jsp";
				}, 1000);
			}
		}
	});

	//並べ替え情報の送信
	UpdatePasteOrder(user_id, content_id);

	return false;
}

