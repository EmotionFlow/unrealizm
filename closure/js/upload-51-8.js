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
			if (clipboardData === window.clipboardData) {
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

let privateNote = (()=>{
	let text = '';
	let placeholder = '';
	let footer = '';
	let $summaryElement = null;
	let summaryLength = 10;
	function _getSummary() {
		const trimText = text.replace("\n"," ").trim();
		return trimText.length < summaryLength ? trimText : trimText.substr(0, summaryLength) + '...';
	}
	function _updateSummaryElement() {
		if ($summaryElement) $summaryElement.text(_getSummary());
	}

	return {
		showEditDlg: () => {
			Swal.fire({
				input: 'textarea',
				inputPlaceholder: placeholder,
				inputAttributes: {maxlength: 100},
				inputValue: text,
				footer: '<span style="font-size: 12px">'+footer+'</span>',
				showCancelButton: true
			}).then((result) => {
				if (result.dismiss) return;
				text = result.value;
				_updateSummaryElement();
			})
		},
		setPlaceholder: (txt) => {placeholder = txt;},
		setFooter: (_footer) => {footer = _footer;},
		setText: (_text) => {text = _text; _updateSummaryElement();},
		setSummaryElement: (_$element) => {$summaryElement = _$element},
		getText: () => {return text;},
	}
})();

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
	if(strPublishStart==='' || strPublishEnd===''){
		dateTimeEmptyMsg();
		return false;
	}

	if(Date.parse(strPublishStart) > Date.parse(strPublishEnd)){
		dateTimeReverseMsg();
		return false;
	}

	if(isUpdate && strPublishStartPresent!=null && strPublishEndPresent!=null){
		var startEquals = comparePublishDate(strPublishStartPresent,strPublishStart);
		var endEquals = comparePublishDate(strPublishEndPresent, strPublishEnd);
		if(startEquals && endEquals){
			return true;
		}else if(!startEquals){
			if(Date.parse(strPublishStart) < Date.now()){
				dateTimePastMsg();
				return false;
			}
		}else if(!endEquals){
			if(Date.parse(strPublishEnd) < Date.now()) {
				dateTimePastMsg();
				return false;
			}
		}
	} else if(Date.parse(strPublishStart) < Date.now() || Date.parse(strPublishEnd) < Date.now()) {
		dateTimePastMsg();
		return false;
	}
	return true;
}


function initStartDatetime(datetime){
	$("#TIME_LIMITED_START").flatpickr({
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
	$("#TIME_LIMITED_END").flatpickr({
		enableTime: true,
		dateFormat: "Z",
		altInput: true,
		altFormat: "Y/m/d H:i",
		time_24hr: true,
		minuteIncrement: 30,
		defaultDate: datetime,
	});
}

function updateOptionPublish(){
	const $ItemTimeLimited = $("#ItemTimeLimited");
	const slideSpeed = 300;
	if($('#OPTION_PUBLISH').prop('checked')){
		$ItemTimeLimited.slideDown(slideSpeed);
	} else {
		updateCheckbox($("#OPTION_NOT_TIME_LIMITED"), true);
		$ItemTimeLimited.slideUp(0);
	}
	updateOptionLimitedTimePublish();
}

function updateOptionLimitedTimePublish(){
	const $ItemTimeLimitedVal = $('#ItemTimeLimitedVal');
	const slideSpeed = 300;
	if(!$('#OPTION_NOT_TIME_LIMITED').prop('checked')){
		$ItemTimeLimitedVal.slideDown(slideSpeed, ()=>{
			$.each(["#TIME_LIMITED_START", "#TIME_LIMITED_END"], (index, value) => {
				if($(value)[0].classList.value.indexOf("flatpickr-input")<0){
					let dateNow = new Date();
					dateNow.setSeconds(0);
					let minDate = new Date();
					minDate.setMinutes(Math.floor((minDate.getMinutes()-30)/30)*30);
					$(value).flatpickr({
						enableTime: true,
						dateFormat: "Z",
						altInput: true,
						altFormat: "Y/m/d H:i",
						time_24hr: true,
						minuteIncrement: 30,
						minDate: minDate,
						defaultDate: dateNow,
					});
				}
			});
		});
	} else {
		$ItemTimeLimitedVal.slideUp(0);
	}
}

function updateOptionPublishNsfw(){
	const $ItemNsfwVal = $("#ItemNsfwVal");
	const slideSpeed = 300;
	if(!$('#OPTION_NOT_PUBLISH_NSFW').prop('checked')){
		$ItemNsfwVal.slideDown(slideSpeed);
	} else {
		$ItemNsfwVal.slideUp(0);
	}
	updateShowAllFirst();
}

function updateOptionShowLimit(){
	const $ItemShowLimitVal = $("#ItemShowLimitVal");
	const slideSpeed = 500;
	if(!$('#OPTION_NO_CONDITIONAL_SHOW').prop('checked')){
		$ItemShowLimitVal.slideDown(slideSpeed);
	} else {
		$ItemShowLimitVal.slideUp(0);
	}
	updateShowAllFirst();
}

function updateOptionPassword(){
	const $ItemPassword = $("#ItemPassword");
	const slideSpeed = 500;
	if(!$('#OPTION_NO_PASSWORD').prop('checked')){
		$ItemPassword.slideDown(slideSpeed);
	} else {
		$ItemPassword.slideUp(0);
	}
	updateShowAllFirst();
}

function updateOptionTweet(){
	const $OptionItemTweetImage = $("#OptionItemTweetImage");
	if (!$OptionItemTweetImage) return;
	const slideSpeed = 500;
	if($('#OPTION_TWEET').prop('checked')){
		$OptionItemTweetImage.slideDown(slideSpeed);
	} else {
		$OptionItemTweetImage.slideUp(0);
	}
}

function updateShowAllFirst() {
	if (
		!$("#OPTION_NOT_PUBLISH_NSFW").prop("checked") ||
		!$("#OPTION_NO_CONDITIONAL_SHOW").prop("checked") ||
		!$("#OPTION_NO_PASSWORD").prop("checked")
	) {
		$("#OptionItemShowAllFirst").show();
	} else {
		$("#OptionItemShowAllFirst").hide();
	}
}


function updateMyTwitterList() {
	var isExecuted = false;
	var apiResp = null;
	function dispMyTwitterList(){
		const $selectElement = $("#TWITTER_LIST_ID");
		if(isExecuted) return;
		if($selectElement.children().length>0){
			isExecuted = true;
			return;
		}
		isExecuted = true;
		$("#TwitterListLoading").hide();
		if(apiResp.result!==0 || (apiResp.result===0 && apiResp.twitter_open_list.length === 0)){
			$("#TwitterListNotFound").show();
			$selectElement.hide();
			if(apiResp.result===-102){
				twitterListRateLimiteExceededMsg();
			}else if(apiResp.result===-103){
				twitterListInvalidTokenMsg();
			}else if(apiResp.result<0){
				twitterListOtherErrMsg();
			}
		} else {
			$("#TwitterListNotFound").hide();
			$selectElement.show();
			apiResp.twitter_open_list.forEach(function(l, idx, ar){
				$selectElement.append('<option value="' + l.id +  '">' + l.name + '</option>');
			});
		}
	}

	return function _updateMyTwitterList(nUserId){
		if(apiResp != null){
			dispMyTwitterList();
		} else {
			$("#TwitterListLoading").show();
			$.ajax({
				"type": "post",
				"data": {"ID": nUserId},
				"url": "/f/TwitterMyListF.jsp",
				"dataType": "json",
				"success": function(data) {
					apiResp = data;
					dispMyTwitterList();
				}
			});
		}
	};
}

var updateMyTwitterListF = updateMyTwitterList();

function tweetSucceeded(resultCode){
	const toContext = "/MyIllustListPcV.jsp";
	const nTimeOut = 5000;
	if (resultCode != null) {
		if (resultCode >= 0) { // 異常無し
			completeMsg();
			setTimeout(function () {
				location.href = toContext;
			}, 1000);
		} else {
			if (resultCode === -103 || resultCode === -203) {
				twitterTweetInvalidTokenMsg();
				setTimeout(function () {
					location.href = toContext;
				}, nTimeOut);
			} else if (resultCode === -102) {
				twitterTweetRateLimitMsg();
				setTimeout(function () {
					location.href = toContext;
				}, nTimeOut);
			} else if (resultCode === -104) {
				twitterTweetTooMuchMsg();
				setTimeout(function () {
					location.href = toContext;
				}, nTimeOut);
			} else {
				twitterTweetOtherErrMsg(resultCode);
				setTimeout(function () {
					location.href = toContext;
				}, nTimeOut);
			}
		}
	} else {
		twitterTweetOtherErrMsg(resultCode);
		setTimeout(function () {
			location.href = toContext;
		}, nTimeOut);
	}
}

// update-*.jspでも使っています
const FINE_UPLOADER_ERROR = {
	typeError: 'TypeError',
	tooManyItemsError: 'TooManyItemsError',
	sizeError: 'SizeError',
	totalSizeError: 'TotalSizeError',
}
function initUploadFile(fileNumMax, fileSizeMax) {
	multiFileUploader = new qq.FineUploader({
		element: document.getElementById("file-drop-area"),
		autoUpload: false,
		button: document.getElementById('TimeLineAddImage'),
		maxConnections: 1,
		validation: {
			allowedExtensions: ['jpeg', 'jpg', 'gif', 'png'],
			itemLimit: fileNumMax,
			sizeLimit: fileSizeMax*1024*1024,
			stopOnFirstInvalidFile: false
		},
		retry: {
			enableAuto: false
		},
		messages: FINE_UPLOADER_ERROR,
		showMessage: function() {
			// FineUploader側で実装されているDlg表示をしないようにする。
			// エラーダイアログ表示は、onValidate(), onErrror()で実装する。
		},
		callbacks: {
			onUpload: function(id, name) {
				if(this.first_file) {
					this.first_file = false;
					this.setEndpoint('/f/UploadFileFirstV2F.jsp', id);
					console.log("UploadFileFirstV2F");
				} else {
					this.setEndpoint('/f/UploadFileAppendV2F.jsp', id);
					console.log("UploadFileAppendV2F");
				}
				this.setParams({
					UID: this.user_id,
					IID: this.illust_id,
					OID: this.open_id,
					REC: this.recent
				}, id);
			},
			onAllComplete: function(succeeded, failed) {
				console.log("onAllComplete", succeeded, failed, this.tweet);
				if(this.tweet) {
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
							tweetSucceeded(data.result);
						}
					});
				} else {
					// complete
					completeMsg();
					setTimeout(onCompleteUpload, 1000);
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
				this.showTotalSize(this.getSubmittedSize(), this.getSubmittedNum());
			},
			onError: function(id, name, errorReason, xhrOrXdr) {
				showFineUploaderErrorDialog(errorReason);
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
		var strTotal = "(jpeg|png|gif, "+fileNumMax+"files, total "+fileSizeMax+"MByte)";
		if(total>0) {
			strTotal="("+ submit_num+"/"+fileNumMax + "files " + Math.ceil(total/1024.0/1024.0) + "/" + fileSizeMax + "MByte)";
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

function _getBasePostData(userId, requestId, editorId) {
	const $TagInputItemData = $('#TagInputItemData');
	let genre = $TagInputItemData.val();
	if(!($TagInputItemData.length)) genre = 1;

	const categoryId = parseInt($('#EditCategory').val(), 10);
	let strTagList = $.trim($("#EditTagList").val());
	strTagList = strTagList.substr(0 , 100);

	let uploadParams = getUploadParams();

	uploadParams["TWITTER_LIST_ID"] = {"value": ""};
	if (uploadParams.SHOW_LIMIT_VAL.value === 10){
		if($("#TwitterListNotFound").is(':visible')){
			twitterListNotFoundMsg();
			return null;
		}
		uploadParams.TWITTER_LIST_ID.value = $('#TWITTER_LIST_ID').val();
	} else if(uploadParams.SHOW_LIMIT_VAL.value === 12) {
		if (!uploadParams.OPTION_TWEET.value) {
			needTweetForRTLimitMsg();
			return null;
		}
	}
	if(!uploadParams.OPTION_NOT_TIME_LIMITED.value){
		if(!checkPublishDatetime(uploadParams.TIME_LIMITED_START.value, uploadParams.TIME_LIMITED_END.value, false)){
			return null;
		}
	}

	if ((!uploadParams.OPTION_NO_CONDITIONAL_SHOW.value ||
			!uploadParams.OPTION_NOT_PUBLISH_NSFW.value ||
			!uploadParams.OPTION_NO_PASSWORD.value) &&
		uploadParams.OPTION_SHOW_FIRST.value) {

		let isErr = false;
		if (editorId === 0) {  // EDITOR_UPLOAD
			isErr = getPreviewAreaImageNum() < 2;
		} else if(editorId === 1) {  // EDITOR_PASTE
			isErr = getPasteAreaImageNum() < 2;
		}
		if (isErr) {
			showAllFirstErrMsg();
			return null;
		}
	}

	if(!uploadParams.OPTION_PUBLISH.value) {
		uploadParams.OPTION_TWEET.value = false;
	}

	let postData = {
		"ED":	editorId,
		"UID":	userId,
		"GD":	genre,
		"CAT":	categoryId,
		"TAG":	strTagList,
		"RID":	requestId ? requestId : -1,
		"NOTE":	privateNote.getText(),
		...Object.fromEntries(Object.entries( uploadParams ).map( ( [ k, v ] ) => [ k, v.value ] )),
	};

	const descList = transList.Description;
	descList[selected['Description']] = $("#EditDescription").val();
	for (let key in descList) {
		if (key === 'default') {
			postData["DES"] = descList[key];
		} else {
			postData["DES" + key] = descList[key];
		}
	}

	postData["AI_PRMPT"] = $("#EditPrompt").val().trim().replace("\n", "");
	if (!postData["AI_PRMPT"] || postData["AI_PRMPT"].length === 0) {
		showPromptErrMsg();
		return null;
	}

	postData["AI_NG_PRMPT"] = $("#EditNegativePrompt").val().trim().replace("\n", "");
	postData["AI_PARAMS"] = $("#EditOtherParams").val().trim();


	// for novel
	if (editorId === 3) {
		postData["TIT"] = $("#EditTextTitle").val();
		postData["BDY"] = $("#EditTextBody").val();
	}

	return postData;
}

function isTweetNow(optionTweet, optionNotTimeLimited) {
	let v = optionTweet;
	if(!optionNotTimeLimited) v = false;
	return v;
}

function UploadFile(userId, requestId) {
	if(!multiFileUploader) return;
	if(multiFileUploader.getSubmittedNum()<=0) return;

	const editorId = 0;

	let postData = _getBasePostData(userId, requestId, editorId);
	if (!postData) return;

	setLastCategorySetting(postData.CAT);
	saveUploadParamsToLocalStorage();
	startMsg();

	$.ajaxSingle({
		"type": "post",
		"data": postData,
		"url": "/f/UploadFileRefTwitterV2F.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UploadFileRefTwitterV2F");
			if(data && data.content_id) {
				if(data.content_id>0) {
					multiFileUploader.first_file = true;
					multiFileUploader.user_id = userId;
					multiFileUploader.illust_id = data.content_id;
					multiFileUploader.open_id = data.open_id;
					multiFileUploader.recent = postData.OPTION_RECENT?0:1;
					multiFileUploader.tweet = isTweetNow(postData.OPTION_TWEET, postData.OPTION_NOT_TIME_LIMITED);
					multiFileUploader.tweet_image = postData.OPTION_TWEET_IMAGE?1:0;
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
	const $TimeLineAddImage = $('#TimeLineAddImage');
	g_strPasteMsg = $TimeLineAddImage.html();
	$TimeLineAddImage.pastableContenteditable();
	$TimeLineAddImage.on('pasteImage', function(ev, data){
		if($('.InputFile').length<10) {
			var $elmPaste = createPasteElm(data.dataURL);
			$('#PasteZone').append($elmPaste);
			$TimeLineAddImage.html(g_strPasteMsg);
		}
		updatePasteNum();
	}).on('pasteImageError', function(ev, data){
		if(data.url){
			alert('error data : ' + data.url)
		}
	}).on('pasteText', function(ev, data){
		$TimeLineAddImage.html(g_strPasteMsg);
	});
}

function createPasteElm(src) {
	let $InputFile = $('<div />').addClass('InputFile');
	let $DeletePaste = $('<div />').addClass('DeletePaste').html('<i class="fas fa-times"></i>').on('click', function(){
		$(this).parent().remove();
		updatePasteNum();
	});
	const $imgView = $('<img />').addClass('imgView').attr('src', src);
	$InputFile.append($DeletePaste).append($imgView);
	return $InputFile
}

function createPasteListItem(src, append_id) {
	let $InputFile = $('<li />').addClass('InputFile').attr('id', append_id);
	let $DeletePaste = $('<div />').addClass('DeletePaste').html('<i class="fas fa-times"></i>').on('click', function(){
		$(this).parent().remove();
		updatePasteNum();
	});
	const $imgView = $('<img />').addClass('imgView').attr('src', src);
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
	}).on('pasteText', function(ev, data){});
}

function updatePasteNum() {
	strTotal="("+ $('.InputFile').length + "/10)";
	$('#TotalSize').html(strTotal);
}

function UploadPaste(userId) {
	const editorId = 1;

	// check image
	let nImageNum = 0;
	$('.imgView').each(function () {
		const strSrc = $.trim($(this).attr('src'));
		if (strSrc.length > 0) nImageNum++;
	});
	if (nImageNum <= 0) return;

	let postData = _getBasePostData(userId, null, editorId);
	if (!postData) return;

	setLastCategorySetting(postData.CAT);
	saveUploadParamsToLocalStorage();
	startMsg();

	$.ajaxSingle({
		"type": "post",
		"data": postData,
		"url": "/f/UploadFileRefTwitterV2F.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UploadFileReferenceV2F", data.content_id);
			let first_file = true;
			$('.imgView').each(function(){
				$(this).parent().addClass('Done');
				const strEncodeImg = $(this).attr('src').replace('data:image/png;base64,', '');
				if(strEncodeImg.length<=0) return true;

				if(first_file) {
					first_file = false;
					$.ajax({
						"type": "post",
						"data": {
							"UID": userId,
							"IID": data.content_id,
							"REC": postData.OPTION_RECENT?0:1,
							"DATA": strEncodeImg,
						},
						"url": "/f/UploadPasteFirstV2F.jsp",
						"dataType": "json",
						"async": false,
						"success": function() {
							console.log("UploadPasteFirstV2F");
						}
					});
				} else {
					$.ajax({
						"type": "post",
						"data": {
							"UID":userId,
							"IID":data.content_id,
							"DATA":strEncodeImg,
						},
						"url": "/f/UploadPasteAppendV2F.jsp",
						"dataType": "json",
						"async": false,
						"success": function() {
							console.log("UploadPasteAppendV2F");
						}
					});
				}
			});
			if(isTweetNow(postData.OPTION_TWEET, postData.OPTION_NOT_TIME_LIMITED)) {
				$.ajax({
					"type": "post",
					"data": {
						UID: userId,
						IID: data.content_id,
						IMG: postData.OPTION_TWEET_IMAGE ? 1 : 0,
					},
					"url": "/f/UploadFileTweetF.jsp",
					"dataType": "json",
					"success": function(data) {
						tweetSucceeded(data.result);
					}
				});
			} else {
				setTimeout(function(){
					location.href="/MyIllustListPcV.jsp";
				}, 1000);
			}
		}
	});
	return false;
}

function UploadText(userId, requestId) {
	const editorId = 3;

	let postData = _getBasePostData(userId, requestId, editorId);
	if (!postData) return;

	setLastCategorySetting(postData.CAT);
	saveUploadParamsToLocalStorage();
	startMsg();

	$.ajaxSingle({
		"type": "post",
		"data": postData,
		"url": "/f/UploadTextRefTwitterV2F.jsp",
		"dataType": "json",
		"success": function(data) {
			console.log("UploadTextRefTwitterF");
			if(data && data.content_id) {
				if(data.content_id>0) {
					if(isTweetNow(postData.OPTION_TWEET, postData.OPTION_NOT_TIME_LIMITED)) {
						$.ajax({
							"type": "post",
							"data": {
								UID: userId,
								IID: data.content_id,
								IMG: postData.OPTION_TWEET_IMAGE ? 1 : 0,
							},
							"url": "/f/UploadFileTweetF.jsp",
							"dataType": "json",
							"success": function(data) {
								tweetSucceeded(data.result);
							}
						});
					} else {
						setTimeout(function(){
							location.href="/MyIllustListPcV.jsp";
						}, 1000);
					}
				}
			}
		}
	});
}

function initOption() {
	const cCategory = getLastCategorySetting();
	$('#EditCategory option').each(function(){
		if($(this).val()===cCategory) {
			$('#EditCategory').val(cCategory);
		}
	});
}

function onClickOptionItem() {
	$(".OptionItem").on('click', (ev) => {
		let $targets;
		if (ev.target.classList.contains("OptionItem")) {
			$targets = $(ev.target).find("div > input");
		} else {
			$targets = $(ev.target).closest(".OptionItem").find("div > input");
		}
		if ($targets.length === 1) {
			let $OptionItem;
			if (ev.target.classList.contains("OptionItem")) {
				$OptionItem = $(ev.target);
			} else {
				$OptionItem = $(ev.target).closest(".OptionItem");
			}

			const bgColor = '#f9f9ff';
			if ($OptionItem.css('background') !== bgColor) {
				$OptionItem.css('background', bgColor);
				setTimeout(()=>{$OptionItem.css('background', 'none');}, 220);
			}

			if ($(ev.target).closest(".onoffswitch").length === 0) {
				$targets[0].click();
			}
		}
	});
}

function getPreviewAreaImageNum() {
	return $('.qq-upload-list-selector.qq-upload-list').children('li').length;
}

function getPasteAreaImageNum() {
	return $('.PasteZone').children('.InputFile').length;
}

function switchTransTxt(name, langId) {
	const $Edit = $("#Edit"+name)
	transList[name][selected[name]] = $Edit.val();
	let txt = transList[name][langId];
	$Edit.val(txt ?  txt : "");
	selected[name] = langId;
}

function updateCheckbox($checkbox, checked) {
	if ($checkbox) {
		if (checked) {
			$checkbox.attr('checked', true).prop('checked', true).change();
		} else {
			$checkbox.removeAttr('checked').prop('checked', false).change();
		}
	}
}

function selectRadioButton(name, value) {
	$("input[name=" + name + "][value=" + value + "]").prop('checked', true);
}

const UPLOAD_PARAMS_DEFAULT = {
	"OPTION_PUBLISH":				{"type": "checkbox", "value": true},
	"OPTION_NOT_TIME_LIMITED": 		{"type": "checkbox", "value": true},
	"TIME_LIMITED_START": 			{"type": "datetime", "value": ""},
	"TIME_LIMITED_END": 			{"type": "datetime", "value": ""},
	"OPTION_NOT_PUBLISH_NSFW": 		{"type": "checkbox", "value": true},
	"NSFW_VAL": 					{"type": "radio",    "value": 2},
	"OPTION_NO_CONDITIONAL_SHOW": 	{"type": "checkbox", "value": true},
	"SHOW_LIMIT_VAL": 				{"type": "radio",    "value": 6},
	"OPTION_NO_PASSWORD": 			{"type": "checkbox", "value": true},
	"PASSWORD_VAL": 				{"type": "textbox",  "value": ""},
	"OPTION_SHOW_FIRST": 			{"type": "checkbox", "value": false},
	"OPTION_TWEET": 				{"type": "checkbox", "value": false},
	"OPTION_TWEET_IMAGE": 			{"type": "checkbox", "value": true},
	"OPTION_TWITTER_CARD_THUMBNAIL":{"type": "checkbox", "value": true},
	"OPTION_CHEER_NG": 				{"type": "checkbox", "value": true},
	"OPTION_RECENT": 				{"type": "checkbox", "value": true},
	"NOVEL_DIRECTION_VAL": 			{"type": "radio",    "value": 0},
}

// for local storage
const UPLOAD_PARAMS_KEY = 'UPLOAD_PARAMS';

function getUploadParams() {
	let uploadParams = UPLOAD_PARAMS_DEFAULT;

	for (let [key, val] of Object.entries(UPLOAD_PARAMS_DEFAULT)) {
		const type = val.type;
		const $el = $("#" + key)
		let v;
		if (type === 'checkbox') {
			v = $el.prop('checked');
		} else if (type === 'textbox') {
			v = $el.val();
		} else if (type === 'radio') {
			let radioValue = $("input[name='" + key + "']:checked").val();
			if (radioValue) {
				v = radioValue;
			} else {
				v = val.value;
			}
			let intVal;
			try { intVal = parseInt(v); } catch (e){}
			if (intVal) v = intVal;

		} else if (type === 'datetime') {
			v = getPublishDateTime($el.val());
		}

		uploadParams[key].value = v;
	}

	return uploadParams;
}

function saveUploadParamsToLocalStorage() {
	let uploadParams = getUploadParams();
	const json = JSON.stringify(uploadParams);
	localStorage.setItem(UPLOAD_PARAMS_KEY, json);
}

function loadUploadParamsFromLocalStorage() {
	const json = localStorage.getItem(UPLOAD_PARAMS_KEY);
	if (json) {
		let result;
		try {
			result = JSON.parse(json);
		} catch (e) {
			console.log(e);
			result = null;
		}
		return result;
	} else {
		return null;
	}
}

function setUploadParams(params) {
	for (let [key, val] of Object.entries(params)) {
		const type = val.type;
		if (type === 'checkbox') {
			updateCheckbox($("#" + key), val.value);
		} else if (type === 'textbox') {
			$("#" + key).val(val.value);
		} else if (type === 'radio') {
			selectRadioButton(key, val.value);
		}
	}
	updateOptionPublish();
	updateOptionPublishNsfw();
	updateOptionShowLimit();
	updateOptionPassword();
	updateOptionTweet();
}

function initUploadParams(tweetEnabled) {
	let uploadParams = UPLOAD_PARAMS_DEFAULT;
	const storageParams = loadUploadParamsFromLocalStorage();
	try {
		if (storageParams && storageParams !== 'undefined' && storageParams !== 'null') {
			for (let [key, _] of Object.entries(storageParams)) {
				if (uploadParams[key] && storageParams[key]) {
					uploadParams[key].value = storageParams[key].value;
				}
			}
		}
	} catch (e) {
		console.log(e);
	}

	if (!tweetEnabled) {
		uploadParams.OPTION_TWEET.value = false;
		uploadParams.OPTION_TWEET_IMAGE.value = false;
		if (uploadParams.SHOW_LIMIT_VAL.value === 7
			|| uploadParams.SHOW_LIMIT_VAL.value === 10
			|| uploadParams.SHOW_LIMIT_VAL.value === 9
			|| uploadParams.SHOW_LIMIT_VAL.value === 12
		) {
			uploadParams.SHOW_LIMIT_VAL.value = 5;
		}
	}

	setUploadParams(uploadParams);
}

function showSetTagDlg() {
	function getSetTagDlgHtml() {
		const tagMaxLength = $('#EditTagList').data('tag-max-length');
		const dlgHtml = `
<div id="TagDlgWrapper" class="TagDlgWrapper">
	<form id="TagSearchWrapper" class="TagSearchWrapper" onsubmit="return addTag()">
		<div class="TagSearch">
			<div class="TagSearchInputWrapper">
				<input name="TagKWD" id="TagSearchBox" class="TagSearchBox" type="text" maxlength="${tagMaxLength}" placeholder="タグを入力 | ##でマイタグ" value="" autocomplete="off" enterkeyhint="done" oninput="onTagInput()">
				<div id="TagSearchClear" class="TagSearchClear">
					<i class="fas fa-times-circle" onclick="clearTagSearchInput()"></i>
				</div>
			</div>
		</div>
	</form>
	<div id="CurrentTagWrapper" class="DlgTagListWrapper">
		<div class="CurrentTagHeader">
			<span>設定中のタグ</span>
			<span id="CurrentTagNum"></span>
		</div>
		<ul id="CurrentTagList" class="DlgTagList"></ul>
	</div>
	<div id="TagSuggestionWrapper" class="DlgTagListWrapper">
		<div class="TagSuggestionHeader"></div>
		<ul id="TagSuggestionList" class="DlgTagList"></ul>
	</div>
</div>
		`;
		return dlgHtml;
	}

	Swal.fire({
		html: getSetTagDlgHtml(),
		showCancelButton: true,
		position: 'top',
		allowEnterKey: false,
		onOpen: () => {
			$('#TagSearchBox').focus();
			showCurrentTags(true);
		},
		preConfirm: () => getTagsInDlg(),
	}).then(result => {
		if(result.value) $('#EditTagList').val(result.value.join(' '));
	});
}

function getTagsInDlg() {
	return $('#CurrentTagList .CurrentTagName').get().map(el => {
		const tagName = $(el).text();
		return `${/^#/.test(tagName) ? '' : '#'}${tagName}`
	});
}

function toggleClearTagBtn() {
	const $TagSearchClear = $('#TagSearchClear');
	const $TagSearchBox = $('#TagSearchBox');
	if ($TagSearchBox.val()) {
		$TagSearchClear.css('visibility','visible');
		$TagSearchBox.css('padding-right', '28px');
	} else {
		$TagSearchClear.css('visibility','hidden');
		$TagSearchBox.css('padding-right', '1px');
	}
}

function clearTagSearchInput() {
	const $search = $('#TagSearchBox');
	$search.val('');
	toggleClearTagBtn();
	$search.focus();
	toggleClearSearchBtn();
	showCurrentTags();
}

function onTagInput() {
	const $input = $('#TagSearchBox');
	const inputStr = $input.val();
	if (/\s$/.test(inputStr)) $input.val(inputStr.replace(/\s/g, ''));
	toggleClearTagBtn();
	const prevTimeout = getLocalStrage('tag-suggestion-timeout');
	if (prevTimeout) clearTimeout(prevTimeout);
	setLocalStrage('tag-suggestion-timeout', setTimeout(() => {
		if (inputStr) {
			showTagSuggestion(inputStr);
		} else {
			showCurrentTags();
		}
	}, 800))
}

function generateCurrentTagRow(tagName) {
	const $li = $('<li></li>', { class: 'DlgTagItem CurrentTagItem' });
	const $tagRow = $('<div></div>',  { class: 'DlgTagRow CurrentTagRow' });
	const $tagName = $('<div></div>', {
		class: 'DlgTagName CurrentTagName',
		text: `${/^#/.test(tagName) ? '' : '#'}${tagName}`,
	});
	const $delBtn = $('<div></div>', { class: 'CurrentTagDelBtn', onclick: 'deleteTag()' });
	const $delIcon = $('<i></i>', { class: 'fas fa-times' });
	return $li.append($tagRow.append($tagName, $delBtn.append($delIcon)));
}

function showCurrentTags(refresh=false) {
	const tagMaxNum = $('#EditTagList').data('tag-max-num');
	$('#CurrentTagWrapper').show();
	$('#TagSuggestionWrapper').hide();
	const $tagList = $('#CurrentTagWrapper').find('ul#CurrentTagList');
	if (refresh) {
		$tagList.empty();
		const tags = $('#EditTagList').val().trim().split(/\s+/).filter(str => str);
		if (tags.length) {
			tags.filter((_, i) => i < tagMaxNum).forEach(tag => {
				$tagList.append(generateCurrentTagRow(tag));
			});
		}
	}
	const tagRowsCnt = $tagList.find('li.DlgTagItem.CurrentTagItem').length;
	$('#CurrentTagNum').text(`(${tagRowsCnt}/${tagMaxNum})`)
	if (tagRowsCnt) {
		$('li.CurrentTagBlankRow').remove();
	} else if (!$('li.CurrentTagBlankRow').length) {
		const $li = $('<li></li>', { class: 'CurrentTagBlankRow' });
		const $row = $('<div></div>', { class: 'DlgTagRow' });
		const $item = $('<div></div>', { class: 'DlgTagNameBlank', text: 'タグはありません' });
		$tagList.append($li.append($row.append($item)));
	}
}

function showTagSuggestion(inputStr) {
	// $('#CurrentTagWrapper').hide();
	// $('#TagSuggestionWrapper').show();
	// const $tagList = $('#TagSuggestionWrapper').find('ul#TagSuggestionList');
	// $tagList.empty();
	// $tagList.addClass('Loading');
	// TODO: get & show
}

function addTag() {
	const tagMaxNum = $('#EditTagList').data('tag-max-num');
	const $input = $(event.currentTarget).find('#TagSearchBox');
	const newTag = $input.val();
	const $tagList = $('#CurrentTagWrapper').find('ul#CurrentTagList');
	$input.val('');
	toggleClearTagBtn();
	if (newTag && $tagList.find('li.DlgTagItem.CurrentTagItem').length < tagMaxNum) {
		const $newTagRow = generateCurrentTagRow(newTag);
		const newTagText = $newTagRow.find('.DlgTagName').text()
		if(!getTagsInDlg().includes(newTagText)) $tagList.append(generateCurrentTagRow(newTag));
	}
	showCurrentTags();
	return false;
}

function deleteTag() {
	const $tag = $(event.currentTarget).closest('li');
	$tag.remove();
	showCurrentTags();
}
