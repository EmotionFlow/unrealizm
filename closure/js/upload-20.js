var multiFileUploader = null;

$.ajaxSetup({
	cache : false,
});

(function() {
	var $, Paste, createHiddenEditable, dataURLtoBlob, isFocusable;

	$ = window.jQuery;

	$.paste = function(pasteContainer) {
		var pm;
		if (typeof console !== "undefined" && console !== null) {
		console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");
		}
		pm = Paste.mountNonInputable(pasteContainer);
		return pm._container;
	};

	$.fn.pastableNonInputable = function() {
		var el, j, len, ref;
		ref = this;
		for (j = 0, len = ref.length; j < len; j++) {
		el = ref[j];
		if (el._pastable || $(el).is('textarea, input:text, [contenteditable]')) {
			continue;
		}
		Paste.mountNonInputable(el);
		el._pastable = true;
		}
		return this;
	};

	$.fn.pastableTextarea = function() {
		var el, j, len, ref;
		ref = this;
		for (j = 0, len = ref.length; j < len; j++) {
		el = ref[j];
		if (el._pastable || $(el).is(':not(textarea, input:text)')) {
			continue;
		}
		Paste.mountTextarea(el);
		el._pastable = true;
		}
		return this;
	};

	$.fn.pastableContenteditable = function() {
		var el, j, len, ref;
		ref = this;
		for (j = 0, len = ref.length; j < len; j++) {
		el = ref[j];
		if (el._pastable || $(el).is(':not([contenteditable])')) {
			continue;
		}
		Paste.mountContenteditable(el);
		el._pastable = true;
		}
		return this;
	};

	dataURLtoBlob = function(dataURL, sliceSize) {
		var b64Data, byteArray, byteArrays, byteCharacters, byteNumbers, contentType, i, m, offset, ref, slice;
		if (sliceSize == null) {
		sliceSize = 512;
		}
		if (!(m = dataURL.match(/^data\:([^\;]+)\;base64\,(.+)$/))) {
		return null;
		}
		ref = m, m = ref[0], contentType = ref[1], b64Data = ref[2];
		byteCharacters = atob(b64Data);
		byteArrays = [];
		offset = 0;
		while (offset < byteCharacters.length) {
		slice = byteCharacters.slice(offset, offset + sliceSize);
		byteNumbers = new Array(slice.length);
		i = 0;
		while (i < slice.length) {
			byteNumbers[i] = slice.charCodeAt(i);
			i++;
		}
		byteArray = new Uint8Array(byteNumbers);
		byteArrays.push(byteArray);
		offset += sliceSize;
		}
		return new Blob(byteArrays, {
		type: contentType
		});
	};

	createHiddenEditable = function() {
		return $(document.createElement('div')).attr('contenteditable', true).attr('aria-hidden', true).attr('tabindex', -1).css({
		width: 1,
		height: 1,
		position: 'fixed',
		left: -100,
		overflow: 'hidden',
		opacity: 1e-17
		});
	};

	isFocusable = function(element, hasTabindex) {
		var fieldset, focusableIfVisible, img, map, mapName, nodeName;
		map = void 0;
		mapName = void 0;
		img = void 0;
		focusableIfVisible = void 0;
		fieldset = void 0;
		nodeName = element.nodeName.toLowerCase();
		if ('area' === nodeName) {
		map = element.parentNode;
		mapName = map.name;
		if (!element.href || !mapName || map.nodeName.toLowerCase() !== 'map') {
			return false;
		}
		img = $('img[usemap=\'#' + mapName + '\']');
		return img.length > 0 && img.is(':visible');
		}
		if (/^(input|select|textarea|button|object)$/.test(nodeName)) {
		focusableIfVisible = !element.disabled;
		if (focusableIfVisible) {
			fieldset = $(element).closest('fieldset')[0];
			if (fieldset) {
			focusableIfVisible = !fieldset.disabled;
			}
		}
		} else if ('a' === nodeName) {
		focusableIfVisible = element.href || hasTabindex;
		} else {
		focusableIfVisible = hasTabindex;
		}
		focusableIfVisible = focusableIfVisible || $(element).is('[contenteditable]');
		return focusableIfVisible && $(element).is(':visible');
	};

	Paste = (function() {
		Paste.prototype._target = null;

		Paste.prototype._container = null;

		Paste.mountNonInputable = function(nonInputable) {
		var paste;
		paste = new Paste(createHiddenEditable().appendTo(nonInputable), nonInputable);
		$(nonInputable).on('click', (function(_this) {
			return function(ev) {
			if (!(isFocusable(ev.target, false) || window.getSelection().toString())) {
				return paste._container.focus();
			}
			};
		})(this));
		paste._container.on('focus', (function(_this) {
			return function() {
			return $(nonInputable).addClass('pastable-focus');
			};
		})(this));
		return paste._container.on('blur', (function(_this) {
			return function() {
			return $(nonInputable).removeClass('pastable-focus');
			};
		})(this));
		};

		Paste.mountTextarea = function(textarea) {
		var ctlDown, paste, ref, ref1;
		if ((typeof DataTransfer !== "undefined" && DataTransfer !== null ? DataTransfer.prototype : void 0) && ((ref = Object.getOwnPropertyDescriptor) != null ? (ref1 = ref.call(Object, DataTransfer.prototype, 'items')) != null ? ref1.get : void 0 : void 0)) {
			return this.mountContenteditable(textarea);
		}
		paste = new Paste(createHiddenEditable().insertBefore(textarea), textarea);
		ctlDown = false;
		$(textarea).on('keyup', function(ev) {
			var ref2;
			if ((ref2 = ev.keyCode) === 17 || ref2 === 224) {
			ctlDown = false;
			}
			return null;
		});
		$(textarea).on('keydown', function(ev) {
			var ref2;
			if ((ref2 = ev.keyCode) === 17 || ref2 === 224) {
			ctlDown = true;
			}
			if ((ev.ctrlKey != null) && (ev.metaKey != null)) {
			ctlDown = ev.ctrlKey || ev.metaKey;
			}
			if (ctlDown && ev.keyCode === 86) {
			paste._textarea_focus_stolen = true;
			paste._container.focus();
			paste._paste_event_fired = false;
			setTimeout((function(_this) {
				return function() {
				if (!paste._paste_event_fired) {
					$(textarea).focus();
					return paste._textarea_focus_stolen = false;
				}
				};
			})(this), 1);
			}
			return null;
		});
		$(textarea).on('paste', (function(_this) {
			return function() {};
		})(this));
		$(textarea).on('focus', (function(_this) {
			return function() {
			if (!paste._textarea_focus_stolen) {
				return $(textarea).addClass('pastable-focus');
			}
			};
		})(this));
		$(textarea).on('blur', (function(_this) {
			return function() {
			if (!paste._textarea_focus_stolen) {
				return $(textarea).removeClass('pastable-focus');
			}
			};
		})(this));
		$(paste._target).on('_pasteCheckContainerDone', (function(_this) {
			return function() {
			$(textarea).focus();
			return paste._textarea_focus_stolen = false;
			};
		})(this));
		return $(paste._target).on('pasteText', (function(_this) {
			return function(ev, data) {
			var content, curEnd, curStart;
			curStart = $(textarea).prop('selectionStart');
			curEnd = $(textarea).prop('selectionEnd');
			content = $(textarea).val();
			$(textarea).val("" + content.slice(0, curStart) + data.text + content.slice(curEnd));
			$(textarea)[0].setSelectionRange(curStart + data.text.length, curStart + data.text.length);
			return $(textarea).trigger('change');
			};
		})(this));
		};

		Paste.mountContenteditable = function(contenteditable) {
		var paste;
		paste = new Paste(contenteditable, contenteditable);
		$(contenteditable).on('focus', (function(_this) {
			return function() {
			return $(contenteditable).addClass('pastable-focus');
			};
		})(this));
		return $(contenteditable).on('blur', (function(_this) {
			return function() {
			return $(contenteditable).removeClass('pastable-focus');
			};
		})(this));
		};

		function Paste(_container, _target) {
		this._container = _container;
		this._target = _target;
		this._container = $(this._container);
		this._target = $(this._target).addClass('pastable');
		this._container.on('paste', (function(_this) {
			return function(ev) {
			var _i, clipboardData, file, fileType, item, j, k, l, len, len1, len2, pastedFilename, reader, ref, ref1, ref2, ref3, ref4, stringIsFilename, text;
			_this.originalEvent = (ev.originalEvent !== null ? ev.originalEvent : null);
			_this._paste_event_fired = true;
			if (((ref = ev.originalEvent) != null ? ref.clipboardData : void 0) != null) {
				clipboardData = ev.originalEvent.clipboardData;
				if (clipboardData.items) {
				pastedFilename = null;
				_this.originalEvent.pastedTypes = [];
				ref1 = clipboardData.items;
				for (j = 0, len = ref1.length; j < len; j++) {
					item = ref1[j];
					if (item.type.match(/^text\/(plain|rtf|html)/)) {
					_this.originalEvent.pastedTypes.push(item.type);
					}
				}
				ref2 = clipboardData.items;
				for (_i = k = 0, len1 = ref2.length; k < len1; _i = ++k) {
					item = ref2[_i];
					if (item.type.match(/^image\//)) {
					reader = new FileReader();
					reader.onload = function(event) {
						return _this._handleImage(event.target.result, _this.originalEvent, pastedFilename);
					};
					try {
						reader.readAsDataURL(item.getAsFile());
					} catch (error) {}
					ev.preventDefault();
					break;
					}
					if (item.type === 'text/plain') {
					if (_i === 0 && clipboardData.items.length > 1 && clipboardData.items[1].type.match(/^image\//)) {
						stringIsFilename = true;
						fileType = clipboardData.items[1].type;
					}
					item.getAsString(function(string) {
						if (stringIsFilename) {
						pastedFilename = string;
						return _this._target.trigger('pasteText', {
							text: string,
							isFilename: true,
							fileType: fileType,
							originalEvent: _this.originalEvent
						});
						} else {
						return _this._target.trigger('pasteText', {
							text: string,
							originalEvent: _this.originalEvent
						});
						}
					});
					}
					if (item.type === 'text/rtf') {
					item.getAsString(function(string) {
						return _this._target.trigger('pasteTextRich', {
						text: string,
						originalEvent: _this.originalEvent
						});
					});
					}
					if (item.type === 'text/html') {
					item.getAsString(function(string) {
						return _this._target.trigger('pasteTextHtml', {
						text: string,
						originalEvent: _this.originalEvent
						});
					});
					}
				}
				} else {
				if (-1 !== Array.prototype.indexOf.call(clipboardData.types, 'text/plain')) {
					text = clipboardData.getData('Text');
					setTimeout(function() {
					return _this._target.trigger('pasteText', {
						text: text,
						originalEvent: _this.originalEvent
					});
					}, 1);
				}
				_this._checkImagesInContainer(function(src) {
					return _this._handleImage(src, _this.originalEvent);
				});
				}
			}
			if (clipboardData = window.clipboardData) {
				if ((ref3 = (text = clipboardData.getData('Text'))) != null ? ref3.length : void 0) {
				setTimeout(function() {
					_this._target.trigger('pasteText', {
					text: text,
					originalEvent: _this.originalEvent
					});
					return _this._target.trigger('_pasteCheckContainerDone');
				}, 1);
				} else {
				ref4 = clipboardData.files;
				for (l = 0, len2 = ref4.length; l < len2; l++) {
					file = ref4[l];
					_this._handleImage(URL.createObjectURL(file), _this.originalEvent);
				}
				_this._checkImagesInContainer(function(src) {});
				}
			}
			return null;
			};
		})(this));
		}

		Paste.prototype._handleImage = function(src, e, name) {
		var loader;
		if (src.match(/^webkit\-fake\-url\:\/\//)) {
			return this._target.trigger('pasteImageError', {
			message: "You are trying to paste an image in Safari, however we are unable to retieve its data."
			});
		}
		this._target.trigger('pasteImageStart');
		loader = new Image();
		loader.crossOrigin = "anonymous";
		loader.onload = (function(_this) {
			return function() {
			var blob, canvas, ctx, dataURL;
			canvas = document.createElement('canvas');
			canvas.width = loader.width;
			canvas.height = loader.height;
			ctx = canvas.getContext('2d');
			ctx.drawImage(loader, 0, 0, canvas.width, canvas.height);
			dataURL = null;
			try {
				dataURL = canvas.toDataURL('image/png');
				blob = dataURLtoBlob(dataURL);
			} catch (error) {}
			if (dataURL) {
				_this._target.trigger('pasteImage', {
				blob: blob,
				dataURL: dataURL,
				width: loader.width,
				height: loader.height,
				originalEvent: e,
				name: name
				});
			}
			return _this._target.trigger('pasteImageEnd');
			};
		})(this);
		loader.onerror = (function(_this) {
			return function() {
			_this._target.trigger('pasteImageError', {
				message: "Failed to get image from: " + src,
				url: src
			});
			return _this._target.trigger('pasteImageEnd');
			};
		})(this);
		return loader.src = src;
		};

		Paste.prototype._checkImagesInContainer = function(cb) {
		var img, j, len, ref, timespan;
		timespan = Math.floor(1000 * Math.random());
		ref = this._container.find('img');
		for (j = 0, len = ref.length; j < len; j++) {
			img = ref[j];
			img["_paste_marked_" + timespan] = true;
		}
		return setTimeout((function(_this) {
			return function() {
			var k, len1, ref1;
			ref1 = _this._container.find('img');
			for (k = 0, len1 = ref1.length; k < len1; k++) {
				img = ref1[k];
				if (!img["_paste_marked_" + timespan]) {
				cb(img.src);
				$(img).remove();
				}
			}
			return _this._target.trigger('_pasteCheckContainerDone');
			};
		})(this), 1);
		};

		return Paste;

	})();
}).call(this);

function DispDescCharNum() {
	var nCharNum = 200 - $("#EditDescription").val().length;
	$("#DescriptionCharNum").html(nCharNum);
}

function DispTagListCharNum() {
	var nCharNum = 100 - $("#EditTagList").val().length;
	$("#EditTagListCharNum").html(nCharNum);
}

function OnChangeTab(nIndex) {
	setCookie("MOD", nIndex);
	if(nIndex==0) {
		window.location.href="/UploadFilePcV.jsp";
	}else{
		window.location.href="/UploadPastePcV.jsp";
	}
}

function setTweetSetting(val) {
	setLocalStrage('upload_tweet', val);
}

function getTweetSetting() {
	var upload_tweet = getLocalStrage('upload_tweet');
	if(upload_tweet) return true;
	return false;
}

function setTweetImageSetting(val) {
	setLocalStrage('upload_tweet_image', val);
}

function getTweetImageSetting() {
	var upload_tweet = getLocalStrage('upload_tweet_image');
	if(upload_tweet) return true;
	return false;
}

function setLastCategorySetting(val) {
	setLocalStrage('last_category', val);
}

function getLastCategorySetting() {
	return getLocalStrage('last_category');
}
function comparePublishDate(a, b){
	if(a==null && b==null){
		return false;
	} else if(a==null && b==null){
		return true;
	} else {
		return a.substr(0, 16) === b.substr(0, 16);
	}
}
function checkPublishDatetime(strPublishStart, strPublishEnd, isUpdate, strPublishStartPresent=null, strPublishEndPresent=null){
	if(isUpdate && comparePublishDate(strPublishStartPresent,strPublishStart) && comparePublishDate(strPublishEndPresent, strPublishEnd)){
		return true;
	}
	if(strPublishStart=='' || strPublishEnd==''){
		dateTimeEmptyMsg();
		return false;
	}
	if(!isUpdate || isUpdate && (!comparePublishDate(strPublishStartPresent,strPublishStart) || !comparePublishDate(strPublishEndPresent, strPublishEnd))){
		if(Date.parse(strPublishStart) < Date.now() || Date.parse(strPublishEnd) < Date.now()) {
			dateTimePastMsg();
			return false;
		}
	}
	if(Date.parse(strPublishStart) > Date.parse(strPublishEnd)){
		dateTimeReverseMsg();
		return false;
	}
	return true;
}
function updateTweetButton() {
	var bTweet = $('#OptionTweet').prop('checked');
	if(!bTweet) {
		$('#ImageSwitch .OptionLabel').addClass('disabled');
		$('#ImageSwitch .onoffswitch').addClass('disabled');
		$('#OptionImage:checkbox').prop('disabled',true);

		$('#DeleteTweetSwitch .OptionLabel').addClass('disabled');
		$('#DeleteTweetSwitch .onoffswitch').addClass('disabled');
		$('#OptionDeleteTweet:checkbox').prop('disabled',true);
	} else {
		$('#ImageSwitch .OptionLabel').removeClass('disabled');
		$('#ImageSwitch .onoffswitch').removeClass('disabled');
		$('#OptionImage:checkbox').prop('disabled',false);
		$('#DeleteTweetSwitch .OptionLabel').removeClass('disabled');
		$('#DeleteTweetSwitch .onoffswitch').removeClass('disabled');
		$('#OptionDeleteTweet:checkbox').prop('disabled',false);
	}
}

function initStartDatetime(datetime){
	$("#EditTimeLimitedStart").flatpickr({
		enableTime: true,
		dateFormat: "Z",
		altInput: true,
		altFormat: "Y/m/d H:i",
		time_24hr: true,
		minuteIncrement: 30,
		defaultDate: datetime,
	});
}

function initEndDatetime(datetime){
	$("#EditTimeLimitedEnd").flatpickr({
		enableTime: true,
		dateFormat: "Z",
		altInput: true,
		altFormat: "Y/m/d H:i",
		time_24hr: true,
		minuteIncrement: 30,
		defaultDate: datetime,
	});
}

function updateOptionLimitedTimePublish(){
	var elVal = $('#ItemTimeLimitedVal');
	var nSlideSpeed = 300;
	if($('#OptionLimitedTimePublish').prop('checked')){
		elVal.slideDown(nSlideSpeed, function(){
			$.each(["#EditTimeLimitedStart", "#EditTimeLimitedEnd"], function(index, value){
				if($(value)[0].classList.value.indexOf("flatpickr-input")<0){
					var dateNow = new Date();
					dateNow.setMinutes(Math.floor((dateNow.getMinutes()+45)/30)*30);
					$(value).flatpickr({
						enableTime: true,
						dateFormat: "Z",
						altInput: true,
						altFormat: "Y/m/d H:i",
						time_24hr: true,
						minuteIncrement: 30,
						minDate: dateNow,
					});
				}
			});
		});
	} else {
		elVal.slideUp(nSlideSpeed);
	}
}

function updateAreaLimitedTimePublish(publishId) {
	var nSlideSpeed = 300;
	var elFlg = $('#ItemTimeLimitedFlg');
	var elVal = $('#ItemTimeLimitedVal');
	if(publishId!=99){
		elFlg.slideDown(nSlideSpeed, function(){
			updateOptionLimitedTimePublish();
		});
	} else {
		if($('#OptionLimitedTimePublish').prop('checked')){
			elVal.slideUp(nSlideSpeed, function(){
				elFlg.slideUp(nSlideSpeed);
			});
		} else {
			elFlg.slideUp(nSlideSpeed);
		}
	}
}

function updatePublish() {
	var val = parseInt($('#EditPublish').val(), 10);
	updateAreaLimitedTimePublish(val);

    var nSlideSpeed = 300;
	var nChangeDelay = 150;
	var elements = [$('#ItemTwitterList'), $('#ItemPassword')];

    if (val==4 || val==10 || val==11){
		var elToHide = null;
		var elToVisible = null;
		switch (val) {
			case 4:
				elToVisible = $('#ItemPassword');
				break;
			case 10:
				elToVisible = $('#ItemTwitterList');
				break;
			default:
				;
		}

		for (var i=0; i<elements.length; i++){
			var el = elements[i];
			if(el.is(':visible')){
				elToHide = el;
				break;
			}
		}

		if (elToHide==null){
			elToVisible.slideDown(nSlideSpeed);
		} else {
			elToHide.slideUp(nSlideSpeed,
				function(){
					elToVisible.delay(nChangeDelay).slideDown(nSlideSpeed);
				});
		}
    } else {
		for (var i=0; i<elements.length; i++){
			var el = elements[i];
			if(el.is(':visible')){
				el.slideUp(nSlideSpeed);
			}
		}
	}
}

function initUploadFile() {
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
	multiFileUploader = new qq.FineUploader({
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
				if(this.first_file) {
					this.first_file = false;
					this.setEndpoint('/f/UploadFileFirstF.jsp', id);
					console.log("UploadFileFirstF");
				} else {
					this.setEndpoint('/f/UploadFileAppendF.jsp', id);
					console.log("UploadFileAppendF");
				}
				this.setParams({
					UID: this.user_id,
					IID: this.illust_id,
					PID: this.publish_id,
					REC: this.recent
				}, id);
			},
			onAllComplete: function(succeeded, failed) {
				console.log("onAllComplete", succeeded, failed, this.tweet);
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
								location.href="/MyIllustListV.jsp";
							}, 1000);
						}
					});
				} else {
					// complete
					completeMsg();
					setTimeout(function(){
						location.href="/MyIllustListV.jsp";
					}, 1000);
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
				this.showTotalSize(this.getSubmittedSize(), this.getSubmittedNum());
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
	multiFileUploader.total_size = 50*1024*1024;
}

function getPublishDateTime(local_datetime_str){
	if(local_datetime_str == '') return '';
	var date = new Date(local_datetime_str);
	return date.toISOString();
}

function getLimitedTimeFlg(strPublishElementId, strLimitedTimeElementId){
	if($('#'+strPublishElementId).val() == 99){
		return 0;
	} else {
		return ($('#'+strLimitedTimeElementId).prop('checked'))?1:0;
	}
}

function UploadFile(user_id) {
	if(!multiFileUploader) return;
	if(multiFileUploader.getSubmittedNum()<=0) return;
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
	var nTwListId = null;
	var nLimitedTime = getLimitedTimeFlg('EditPublish', 'OptionLimitedTimePublish');
	var strPublishStart = null;
	var strPublishEnd = null;
	if(nPublishId==10){
        nTwListId = $('#EditTwitterList').val();
	}
	if(nLimitedTime==1){
		strPublishStart = getPublishDateTime($('#EditTimeLimitedStart').val());
		strPublishEnd = getPublishDateTime($('#EditTimeLimitedEnd').val());
		if(!checkPublishDatetime(strPublishStart, strPublishEnd, false)){
			return;
		}
	}

	setTweetSetting($('#OptionTweet').prop('checked'));
	setTweetImageSetting($('#OptionImage').prop('checked'));
	setLastCategorySetting(nCategory);
	if(nPublishId == 99) {
		nTweet = 0;
	}
	startMsg();

	var nTweetNow = nTweet;
	if(nLimitedTime==1) nTweetNow = 0;

	$.ajaxSingle({
		"type": "post",
		"data": {
			"UID":user_id,
			"CAT":nCategory,
			"DES":strDescription,
			"TAG":strTagList,
			"PID":nPublishId,
			"PPW":strPassword,
			"PLD":nTwListId,
			"LTP":nLimitedTime,
			"PST":strPublishStart,
			"PED":strPublishEnd,
			"TWT":getTweetSetting(),
			"TWI":getTweetImageSetting(),
		},
		"url": "/f/UploadFileRefTwitterF.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UploadFileReferenceF");
			if(data && data.content_id) {
				if(data.content_id>0) {
					multiFileUploader.first_file = true;
					multiFileUploader.user_id = user_id;
					multiFileUploader.illust_id = data.content_id;
					multiFileUploader.recent = nRecent;
					multiFileUploader.tweet = nTweetNow;
					multiFileUploader.tweet_image = nTweetImage;
					multiFileUploader.publish_id = nPublishId;
					multiFileUploader.uploadStoredFiles();
				} else {
					errorMsg();
				}
			}
		}
	});
}


var g_strPasteMsg = '';
function initUploadPaste() {
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
//	var $elmPaste = createPasteElm();
//	$('#PasteZone').append($elmPaste);
}

function createPasteElm(src) {
	var $InputFile = $('<div />').addClass('InputFile');
	var $DeletePaste = $('<div />').addClass('DeletePaste').html('<i class="fas fa-times"></i>').on('click', function(){
		$(this).parent().remove();
		updatePasteNum();
	});
	var $imgView = $('<img />').addClass('imgView').attr('src', src);
	$InputFile.append($DeletePaste).append($imgView);
	return $InputFile
}

function createPasteListItem(src, append_id) {
	var $InputFile = $('<li />').addClass('InputFile').attr('id', append_id);
	var $DeletePaste = $('<div />').addClass('DeletePaste').html('<i class="fas fa-times"></i>').on('click', function(){
		$(this).parent().remove();
		updatePasteNum();
	});
	var $imgView = $('<img />').addClass('imgView').attr('src', src);
	$InputFile.append($DeletePaste).append($imgView);
	return $InputFile
}

function createPasteListItem(src, append_id) {
	var $InputFile = $('<li />').addClass('InputFile').attr('id', append_id);
	var $DeletePaste = $('<div />').addClass('DeletePaste').html('<i class="fas fa-times"></i>').on('click', function(){
		$(this).parent().remove();
		updatePasteNum();
	});
	var $imgView = $('<img />').addClass('imgView').attr('src', src);
	$InputFile.append($DeletePaste).append($imgView);
	return $InputFile
}

function initPasteElm($elmPaste) {
	$elmPaste.on('pasteImage', function(ev, data){
		$('.OrgMessage', this).hide();
		$('.imgView', this).attr('src', data.dataURL).show();
	}).on('pasteImageError', function(ev, data){
		if(data.url){
			alert('error data : ' + data.url)
		}
	}).on('pasteText', function(ev, data){
		;
	});
}

function updatePasteNum() {
	strTotal="("+ $('.InputFile').length + "/10)";
	$('#TotalSize').html(strTotal);
}

function UploadPaste(user_id) {
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
	var nTwListId = null;
	var nLimitedTime = getLimitedTimeFlg('EditPublish','OptionLimitedTimePublish');
	var strPublishStart = null;
	var strPublishEnd = null;
	if(nPublishId==10){
        nTwListId = $('#EditTwitterList').val();
	}
	if(nLimitedTime==1){
		strPublishStart = getPublishDateTime($('#EditTimeLimitedStart').val());
		strPublishEnd = getPublishDateTime($('#EditTimeLimitedEnd').val());
		if(!checkPublishDatetime(strPublishStart, strPublishEnd, false)){
			return;
		}
	}

	setTweetSetting($('#OptionTweet').prop('checked'));
	setTweetImageSetting($('#OptionImage').prop('checked'));
	setLastCategorySetting(nCategory);
	if(nPublishId == 99) {
		nTweet = 0;
	}
	startMsg();

	var nTweetNow = nTweet;
	if(nLimitedTime==1) nTweetNow = 0;

	$.ajaxSingle({
		"type": "post",
		"data": {
			"UID":user_id,
			"CAT":nCategory,
			"DES":strDescription,
			"TAG":strTagList,
			"PID":nPublishId,
			"PPW":strPassword,
			"PLD":nTwListId,
			"LTP":nLimitedTime,
			"PST":strPublishStart,
			"PED":strPublishEnd,
			"TWT":getTweetSetting(),
			"TWI":getTweetImageSetting(),
			"ED":1,
		},
		"url": "/f/UploadFileRefTwitterF.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UploadFileReferenceF", data.content_id);
			var first_file = true;
			$('.imgView').each(function(){
				$(this).parent().addClass('Done');
				var strEncodeImg = $(this).attr('src').replace('data:image/png;base64,', '');
				if(strEncodeImg.length<=0) return true;

				if(first_file) {
					first_file = false;
					$.ajax({
						"type": "post",
						"data": {
							"UID":user_id,
							"IID":data.content_id,
							"REC":nRecent,
							"DATA":strEncodeImg,
						},
						"url": "/f/UploadPasteFirstF.jsp",
						"dataType": "json",
						"async": false,
						"success": function(data) {
							console.log("UploadPasteFirstF");
						}
					});
				} else {
					$.ajax({
						"type": "post",
						"data": {
							"UID":user_id,
							"IID":data.content_id,
							"DATA":strEncodeImg,
						},
						"url": "/f/UploadPasteAppendF.jsp",
						"dataType": "json",
						"async": false,
						"success": function(data) {
							console.log("UploadPasteAppendF");
						}
					});
				}
			});
			if(nTweetNow==1) {
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
						console.log("UploadFileTweetF");
						// complete
						completeMsg();
						setTimeout(function(){
							location.href="/MyIllustListV.jsp";
						}, 1000);
					}
				});
			} else {
				setTimeout(function(){
					location.href="/MyIllustListV.jsp";
				}, 1000);
			}
		}
	});
	return false;
}
