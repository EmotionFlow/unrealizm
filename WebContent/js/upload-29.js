var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,b,c){a instanceof String&&(a=String(a));for(var f=a.length,e=0;e<f;e++){var g=a[e];if(b.call(c,g,e,a))return{i:e,v:g}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.SIMPLE_FROUND_POLYFILL=!1;$jscomp.ISOLATE_POLYFILLS=!1;$jscomp.FORCE_POLYFILL_PROMISE=!1;$jscomp.FORCE_POLYFILL_PROMISE_WHEN_NO_UNHANDLED_REJECTION=!1;
$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,b,c){if(a==Array.prototype||a==Object.prototype)return a;a[b]=c.value;return a};$jscomp.getGlobal=function(a){a=["object"==typeof globalThis&&globalThis,a,"object"==typeof window&&window,"object"==typeof self&&self,"object"==typeof global&&global];for(var b=0;b<a.length;++b){var c=a[b];if(c&&c.Math==Math)return c}throw Error("Cannot find global object");};$jscomp.global=$jscomp.getGlobal(this);
$jscomp.IS_SYMBOL_NATIVE="function"===typeof Symbol&&"symbol"===typeof Symbol("x");$jscomp.TRUST_ES6_POLYFILLS=!$jscomp.ISOLATE_POLYFILLS||$jscomp.IS_SYMBOL_NATIVE;$jscomp.polyfills={};$jscomp.propertyToPolyfillSymbol={};$jscomp.POLYFILL_PREFIX="$jscp$";var $jscomp$lookupPolyfilledValue=function(a,b){var c=$jscomp.propertyToPolyfillSymbol[b];if(null==c)return a[b];c=a[c];return void 0!==c?c:a[b]};
$jscomp.polyfill=function(a,b,c,f){b&&($jscomp.ISOLATE_POLYFILLS?$jscomp.polyfillIsolated(a,b,c,f):$jscomp.polyfillUnisolated(a,b,c,f))};$jscomp.polyfillUnisolated=function(a,b,c,f){c=$jscomp.global;a=a.split(".");for(f=0;f<a.length-1;f++){var e=a[f];if(!(e in c))return;c=c[e]}a=a[a.length-1];f=c[a];b=b(f);b!=f&&null!=b&&$jscomp.defineProperty(c,a,{configurable:!0,writable:!0,value:b})};
$jscomp.polyfillIsolated=function(a,b,c,f){var e=a.split(".");a=1===e.length;f=e[0];f=!a&&f in $jscomp.polyfills?$jscomp.polyfills:$jscomp.global;for(var g=0;g<e.length-1;g++){var d=e[g];if(!(d in f))return;f=f[d]}e=e[e.length-1];c=$jscomp.IS_SYMBOL_NATIVE&&"es6"===c?f[e]:null;b=b(c);null!=b&&(a?$jscomp.defineProperty($jscomp.polyfills,e,{configurable:!0,writable:!0,value:b}):b!==c&&($jscomp.propertyToPolyfillSymbol[e]=$jscomp.IS_SYMBOL_NATIVE?$jscomp.global.Symbol(e):$jscomp.POLYFILL_PREFIX+e,e=
$jscomp.propertyToPolyfillSymbol[e],$jscomp.defineProperty(f,e,{configurable:!0,writable:!0,value:b})))};$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(b,c){return $jscomp.findInternal(this,b,c).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(g){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return e.mountNonInputable(g)._container};a.fn.pastableNonInputable=function(){var g;var d=0;for(g=this.length;d<g;d++){var h=this[d];h._pastable||a(h).is("textarea, input:text, [contenteditable]")||(e.mountNonInputable(h),h._pastable=!0)}return this};a.fn.pastableTextarea=function(){var g;var d=0;for(g=
this.length;d<g;d++){var h=this[d];h._pastable||a(h).is(":not(textarea, input:text)")||(e.mountTextarea(h),h._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var g;var d=0;for(g=this.length;d<g;d++){var h=this[d];h._pastable||a(h).is(":not([contenteditable])")||(e.mountContenteditable(h),h._pastable=!0)}return this};var b=function(g,d){var h,k,l;null==d&&(d=512);if(!(h=g.match(/^data:([^;]+);base64,(.+)$/)))return null;g=h[1];var n=atob(h[2]);h=[];for(l=0;l<n.length;){var m=n.slice(l,
l+d);var p=Array(m.length);for(k=0;k<m.length;)p[k]=m.charCodeAt(k),k++;p=new Uint8Array(p);h.push(p);l+=d}return new Blob(h,{type:g})};var c=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var f=function(g,d){var h=g.nodeName.toLowerCase();if("area"===h){d=g.parentNode;h=d.name;if(!g.href||!h||"map"!==d.nodeName.toLowerCase())return!1;g=a("img[usemap='#"+
h+"']");return 0<g.length&&g.is(":visible")}/^(input|select|textarea|button|object)$/.test(h)?(h=!g.disabled)&&(d=a(g).closest("fieldset")[0])&&(h=!d.disabled):h="a"===h?g.href||d:d;return(h=h||a(g).is("[contenteditable]"))&&a(g).is(":visible")};var e=function(){function g(d,h){this._container=d;this._target=h;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(k){return function(l){var n,m,p;k.originalEvent=null!==l.originalEvent?
l.originalEvent:null;k._paste_event_fired=!0;if(null!=(null!=(n=l.originalEvent)?n.clipboardData:void 0)){var q=l.originalEvent.clipboardData;if(q.items){var t=null;k.originalEvent.pastedTypes=[];var r=q.items;var u=0;for(m=r.length;u<m;u++)n=r[u],n.type.match(/^text\/(plain|rtf|html)/)&&k.originalEvent.pastedTypes.push(n.type);var x=q.items;u=m=0;for(r=x.length;m<r;u=++m){n=x[u];if(n.type.match(/^image\//)){q=new FileReader;q.onload=function(v){return k._handleImage(v.target.result,k.originalEvent,
t)};try{q.readAsDataURL(n.getAsFile())}catch(v){}l.preventDefault();break}if("text/plain"===n.type){if(0===u&&1<q.items.length&&q.items[1].type.match(/^image\//)){var w=!0;var y=q.items[1].type}n.getAsString(function(v){return w?(t=v,k._target.trigger("pasteText",{text:v,isFilename:!0,fileType:y,originalEvent:k.originalEvent})):k._target.trigger("pasteText",{text:v,originalEvent:k.originalEvent})})}"text/rtf"===n.type&&n.getAsString(function(v){return k._target.trigger("pasteTextRich",{text:v,originalEvent:k.originalEvent})});
"text/html"===n.type&&n.getAsString(function(v){return k._target.trigger("pasteTextHtml",{text:v,originalEvent:k.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(q.types,"text/plain")){var z=q.getData("Text");setTimeout(function(){return k._target.trigger("pasteText",{text:z,originalEvent:k.originalEvent})},1)}k._checkImagesInContainer(function(v){return k._handleImage(v,k.originalEvent)})}}if(q=window.clipboardData)if(null!=(p=z=q.getData("Text"))&&p.length)setTimeout(function(){k._target.trigger("pasteText",
{text:z,originalEvent:k.originalEvent});return k._target.trigger("_pasteCheckContainerDone")},1);else{q=q.files;p=0;for(n=q.length;p<n;p++)l=q[p],k._handleImage(URL.createObjectURL(l),k.originalEvent);k._checkImagesInContainer(function(v){})}return null}}(this))}g.prototype._target=null;g.prototype._container=null;g.mountNonInputable=function(d){var h=new g(c().appendTo(d),d);a(d).on("click",function(k){return function(l){if(!f(l.target,!1)&&!window.getSelection().toString())return h._container.focus()}}(this));
h._container.on("focus",function(k){return function(){return a(d).addClass("pastable-focus")}}(this));return h._container.on("blur",function(k){return function(){return a(d).removeClass("pastable-focus")}}(this))};g.mountTextarea=function(d){var h,k;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(h=Object.getOwnPropertyDescriptor)&&null!=(k=h.call(Object,DataTransfer.prototype,"items"))&&k.get)return this.mountContenteditable(d);var l=new g(c().insertBefore(d),
d);var n=!1;a(d).on("keyup",function(m){var p;if(17===(p=m.keyCode)||224===p)n=!1;return null});a(d).on("keydown",function(m){var p;if(17===(p=m.keyCode)||224===p)n=!0;null!=m.ctrlKey&&null!=m.metaKey&&(n=m.ctrlKey||m.metaKey);n&&86===m.keyCode&&(l._textarea_focus_stolen=!0,l._container.focus(),l._paste_event_fired=!1,setTimeout(function(q){return function(){if(!l._paste_event_fired)return a(d).focus(),l._textarea_focus_stolen=!1}}(this),1));return null});a(d).on("paste",function(m){return function(){}}(this));
a(d).on("focus",function(m){return function(){if(!l._textarea_focus_stolen)return a(d).addClass("pastable-focus")}}(this));a(d).on("blur",function(m){return function(){if(!l._textarea_focus_stolen)return a(d).removeClass("pastable-focus")}}(this));a(l._target).on("_pasteCheckContainerDone",function(m){return function(){a(d).focus();return l._textarea_focus_stolen=!1}}(this));return a(l._target).on("pasteText",function(m){return function(p,q){var t=a(d).prop("selectionStart");var r=a(d).prop("selectionEnd");
p=a(d).val();a(d).val(""+p.slice(0,t)+q.text+p.slice(r));a(d)[0].setSelectionRange(t+q.text.length,t+q.text.length);return a(d).trigger("change")}}(this))};g.mountContenteditable=function(d){new g(d,d);a(d).on("focus",function(h){return function(){return a(d).addClass("pastable-focus")}}(this));return a(d).on("blur",function(h){return function(){return a(d).removeClass("pastable-focus")}}(this))};g.prototype._handleImage=function(d,h,k){if(d.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var l=new Image;l.crossOrigin="anonymous";l.onload=function(n){return function(){var m=document.createElement("canvas");m.width=l.width;m.height=l.height;m.getContext("2d").drawImage(l,0,0,m.width,m.height);var p=null;try{p=m.toDataURL("image/png");var q=b(p)}catch(t){}p&&n._target.trigger("pasteImage",{blob:q,dataURL:p,width:l.width,height:l.height,originalEvent:h,
name:k});return n._target.trigger("pasteImageEnd")}}(this);l.onerror=function(n){return function(){n._target.trigger("pasteImageError",{message:"Failed to get image from: "+d,url:d});return n._target.trigger("pasteImageEnd")}}(this);return l.src=d};g.prototype._checkImagesInContainer=function(d){var h;var k=Math.floor(1E3*Math.random());var l=this._container.find("img");var n=0;for(h=l.length;n<h;n++){var m=l[n];m["_paste_marked_"+k]=!0}return setTimeout(function(p){return function(){var q;var t=
p._container.find("img");var r=0;for(q=t.length;r<q;r++)m=t[r],m["_paste_marked_"+k]||(d(m.src),a(m).remove());return p._target.trigger("_pasteCheckContainerDone")}}(this),1)};return g}()}).call(this);function DispTagListCharNum(){var a=100-$("#EditTagList").val().length;$("#EditTagListCharNum").html(a)}function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}
function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}function setLastCategorySetting(a){setLocalStrage("last_category",a)}function getLastCategorySetting(){return getLocalStrage("last_category")}function comparePublishDate(a,b){return null==a&&null==b?!1:null==a&&null==b?!0:a.substr(0,16)===b.substr(0,16)}
function checkPublishDatetime(a,b,c,f,e){f=void 0===f?null:f;e=void 0===e?null:e;if(""==a||""==b)return dateTimeEmptyMsg(),!1;if(Date.parse(a)>Date.parse(b))return dateTimeReverseMsg(),!1;if(c&&null!=f&&null!=e){if(c=comparePublishDate(f,a),e=comparePublishDate(e,b),!c||!e)if(!c){if(Date.parse(a)<Date.now())return dateTimePastMsg(),!1}else if(!e&&Date.parse(b)<Date.now())return dateTimePastMsg(),!1}else if(Date.parse(a)<Date.now()||Date.parse(b)<Date.now())return dateTimePastMsg(),!1;return!0}
function updateTweetButton(){var a=$("#OptionTweet").prop("checked");$("#ImageSwitc").length&&(a?($("#ImageSwitch .OptionLabel").removeClass("disabled"),$("#ImageSwitch .onoffswitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1),$("#DeleteTweetSwitch .OptionLabel").removeClass("disabled"),$("#DeleteTweetSwitch .onoffswitch").removeClass("disabled"),$("#OptionDeleteTweet:checkbox").prop("disabled",!1)):($("#ImageSwitch .OptionLabel").addClass("disabled"),$("#ImageSwitch .onoffswitch").addClass("disabled"),
$("#OptionImage:checkbox").prop("disabled",!0),$("#DeleteTweetSwitch .OptionLabel").addClass("disabled"),$("#DeleteTweetSwitch .onoffswitch").addClass("disabled"),$("#OptionDeleteTweet:checkbox").prop("disabled",!0)))}function initStartDatetime(a){$("#EditTimeLimitedStart").flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,defaultDate:a})}
function initEndDatetime(a){$("#EditTimeLimitedEnd").flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,defaultDate:a})}
function updateOptionLimitedTimePublish(){var a=$("#ItemTimeLimitedVal");$("#OptionLimitedTimePublish").prop("checked")?a.slideDown(300,function(){$.each(["#EditTimeLimitedStart","#EditTimeLimitedEnd"],function(b,c){if(0>$(c)[0].classList.value.indexOf("flatpickr-input")){b=new Date;b.setSeconds(0);var f=new Date;f.setMinutes(30*Math.floor((f.getMinutes()-30)/30));$(c).flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,minDate:f,defaultDate:b})}})}):
a.slideUp(300)}function updateAreaLimitedTimePublish(a){var b=$("#ItemTimeLimitedFlg"),c=$("#ItemTimeLimitedVal");99!=a?b.slideDown(300,function(){updateOptionLimitedTimePublish()}):$("#OptionLimitedTimePublish").prop("checked")?c.slideUp(300,function(){b.slideUp(300)}):b.slideUp(300)}
function udpateMyTwitterList(){function a(){b||(0<$("#EditTwitterList").children().length?b=!0:(b=!0,$("#TwitterListLoading").hide(),0!=c.result||0==c.result&&0==c.twitter_open_list.length?($("#TwitterListNotFound").show(),$("#EditTwitterList").hide(),-102==c.result?twtterListRateLimiteExceededMsg():-103==c.result?twtterListInvalidTokenMsg():0>c.result&&twtterListOtherErrMsg()):($("#TwitterListNotFound").hide(),$("#EditTwitterList").show(),c.twitter_open_list.forEach(function(f,e,g){$("#EditTwitterList").append('<option value="'+
f.id+'">'+f.name+"</option>")}))))}var b=!1,c=null;return function(f){null!=c?a():$.ajax({type:"post",data:{ID:f},url:"/f/TwitterMyListF.jsp",dataType:"json",success:function(e){c=e;a()}})}}var updateMyTwitterListF=udpateMyTwitterList();
function updatePublish(a){var b=parseInt($("#EditPublish").val(),10);updateAreaLimitedTimePublish(b);var c=[$("#ItemTwitterList"),$("#ItemPassword")];if(4==b||10==b||11==b){var f=null,e=null;switch(b){case 4:e=$("#ItemPassword");break;case 10:e=$("#ItemTwitterList")}for(var g=0;g<c.length;g++){var d=c[g];if(d.is(":visible")){f=d;break}}null==f?e.slideDown(300):f.slideUp(300,function(){e.delay(150).slideDown(300)});10==b&&updateMyTwitterListF(a)}else for(g=0;g<c.length;g++)d=c[g],d.is(":visible")&&
d.slideUp(300)}function tweetSucceeded(a){if(null!=a)if(0<=a)completeMsg(),setTimeout(function(){location.href="/MyIllustListPcV.jsp"},1E3);else{var b=5E3;-103==a||-203==a?twtterTweetInvalidTokenMsg():-102==a?twtterTweetRateLimitMsg():-104==a?twtterTweetTooMuchMsg():twtterTweetOtherErrMsg(a);setTimeout(function(){location.href="/MyIllustListPcV.jsp"},b)}else twtterTweetOtherErrMsg(a),setTimeout(function(){location.href="/MyIllustListPcV.jsp"},b)}
function initUploadFile(a,b){multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg","jpg","gif","png"],itemLimit:a,sizeLimit:1048576*b,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(c,f){this.first_file?(this.first_file=!1,this.setEndpoint("/api/UploadFileFirstF.jsp",c),console.log("UploadFileFirstF")):(this.setEndpoint("/api/UploadFileAppendF.jsp",
c),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,PID:this.publish_id,REC:this.recent},c)},onAllComplete:function(c,f){console.log("onAllComplete",c,f,this.tweet);1==this.tweet?$.ajax({type:"post",data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},url:"/api/UploadFileTweetF.jsp",dataType:"json",success:function(e){tweetSucceeded(e.result)}}):(completeMsg(),setTimeout(function(){location.href="/MyIllustListPcV.jsp"},1E3))},onValidate:function(c){var f=
this.getSubmittedSize(),e=this.getSubmittedNum();this.showTotalSize(f,e);f+=c.size;if(f>this.total_size)return!1;this.showTotalSize(f,e+1)},onStatusChange:function(c,f,e){this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};multiFileUploader.getSubmittedSize=function(){var c=this.getUploads({status:qq.status.SUBMITTED}),f=0;$.each(c,function(){f+=this.size});return f};multiFileUploader.showTotalSize=
function(c,f){var e="(jpeg|png|gif, "+a+"files, total "+b+"MByte)";0<c&&(e="("+f+"/"+a+"files "+Math.ceil(c/1024/1024)+"/"+b+"MByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(e)};multiFileUploader.total_size=52428800}function getPublishDateTime(a){return""==a?"":(new Date(a)).toISOString()}function getLimitedTimeFlg(a,b){return 99==$("#"+a).val()?0:$("#"+b).prop("checked")?1:0}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var b=$("#EditCategory").val(),c=$.trim($("#EditDescription").val()),f=$.trim($("#EditTagList").val());f=f.substr(0,100);var e=$("#EditPublish").val(),g=$("#EditPassword").val(),d=$("#OptionCheerNg").prop("checked")?0:1,h=$("#OptionRecent").prop("checked")?1:0,k=$("#OptionTweet").prop("checked")?1:0,l=$("#OptionImage").prop("checked")?1:0,n=null,m=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),p=null,
q=null;if(10==e){if($("#TwitterListNotFound").is(":visible")){twitterListNotFoundMsg();return}n=$("#EditTwitterList").val()}if(1==m&&(p=getPublishDateTime($("#EditTimeLimitedStart").val()),q=getPublishDateTime($("#EditTimeLimitedEnd").val()),!checkPublishDatetime(p,q,!1)))return;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(b);99==e&&(k=0);startMsg();var t=k;1==m&&(t=0);$.ajaxSingle({type:"post",data:{UID:a,CAT:b,
DES:c,TAG:f,PID:e,PPW:g,PLD:n,LTP:m,PST:p,PED:q,TWT:getTweetSetting(),TWI:getTweetImageSetting(),ED:0,CNG:d},url:"/api/UploadFileRefTwitterF.jsp",dataType:"json",success:function(r){console.log("UploadFileRefTwitterF");r&&r.content_id&&(0<r.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=r.content_id,multiFileUploader.recent=h,multiFileUploader.tweet=t,multiFileUploader.tweet_image=l,multiFileUploader.publish_id=e,multiFileUploader.uploadStoredFiles()):
errorMsg())}})}}var g_strPasteMsg="";
function initUploadPaste(){g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,b){10>$(".InputFile").length&&(a=createPasteElm(b.dataURL),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){$("#TimeLineAddImage").html(g_strPasteMsg)})}
function createPasteElm(a){var b=$("<div />").addClass("InputFile"),c=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);b.append(c).append(a);return b}
function createPasteListItem(a,b){b=$("<li />").addClass("InputFile").attr("id",b);var c=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);b.append(c).append(a);return b}
function createPasteListItem(a,b){b=$("<li />").addClass("InputFile").attr("id",b);var c=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);b.append(c).append(a);return b}
function initPasteElm(a){a.on("pasteImage",function(b,c){$(".OrgMessage",this).hide();$(".imgView",this).attr("src",c.dataURL).show()}).on("pasteImageError",function(b,c){c.url&&alert("error data : "+c.url)}).on("pasteText",function(b,c){})}function updatePasteNum(){strTotal="("+$(".InputFile").length+"/10)";$("#TotalSize").html(strTotal)}
function UploadPaste(a){var b=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&b++});console.log(b);if(!(0>=b)){var c=$("#EditCategory").val(),f=$.trim($("#EditDescription").val()),e=$.trim($("#EditTagList").val());e=e.substr(0,100);var g=$("#EditPublish").val(),d=$("#EditPassword").val(),h=$("#OptionCheerNg").prop("checked")?0:1,k=$("#OptionRecent").prop("checked")?1:0,l=$("#OptionTweet").prop("checked")?1:0,n=$("#OptionImage").prop("checked")?1:0,m=null,p=getLimitedTimeFlg("EditPublish",
"OptionLimitedTimePublish"),q=null,t=null;if(10==g){if($("#TwitterListNotFound").is(":visible")){twitterListNotFoundMsg();return}m=$("#EditTwitterList").val()}if(1==p&&(q=getPublishDateTime($("#EditTimeLimitedStart").val()),t=getPublishDateTime($("#EditTimeLimitedEnd").val()),!checkPublishDatetime(q,t,!1)))return;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(c);99==g&&(l=0);startMsg();var r=l;1==p&&(r=0);$.ajaxSingle({type:"post",
data:{UID:a,CAT:c,DES:f,TAG:e,PID:g,PPW:d,PLD:m,LTP:p,PST:q,PED:t,TWT:getTweetSetting(),TWI:getTweetImageSetting(),ED:1,CNG:h},url:"/api/UploadFileRefTwitterF.jsp",dataType:"json",success:function(u){console.log("UploadFileReferenceF",u.content_id);var x=!0;$(".imgView").each(function(){$(this).parent().addClass("Done");var w=$(this).attr("src").replace("data:image/png;base64,","");if(0>=w.length)return!0;x?(x=!1,$.ajax({type:"post",data:{UID:a,IID:u.content_id,REC:k,DATA:w},url:"/f/UploadPasteFirstF.jsp",
dataType:"json",async:!1,success:function(y){console.log("UploadPasteFirstF")}})):$.ajax({type:"post",data:{UID:a,IID:u.content_id,DATA:w},url:"/f/UploadPasteAppendF.jsp",dataType:"json",async:!1,success:function(y){console.log("UploadPasteAppendF")}})});1==r?$.ajax({type:"post",data:{UID:a,IID:u.content_id,IMG:n},url:"/api/UploadFileTweetF.jsp",dataType:"json",success:function(w){tweetSucceeded(w.result)}}):setTimeout(function(){location.href="/MyIllustListPcV.jsp"},1E3)}});return!1}}
function UploadText(a){var b=$("#EditCategory").val(),c=$.trim($("#EditDescription").val()),f=$.trim($("#EditTextBody").val()),e=$.trim($("#EditTagList").val());e=e.substr(0,100);var g=$("#EditPublish").val(),d=$("#EditPassword").val(),h=$("#OptionCheerNg").prop("checked")?0:1,k=$("#OptionRecent").prop("checked")?1:0,l=$("#OptionTweet").prop("checked")?1:0,n=null,m=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),p=null,q=null;if(10==g){if($("#TwitterListNotFound").is(":visible")){twitterListNotFoundMsg();
return}n=$("#EditTwitterList").val()}if(1==m&&(p=getPublishDateTime($("#EditTimeLimitedStart").val()),q=getPublishDateTime($("#EditTimeLimitedEnd").val()),!checkPublishDatetime(p,q,!1)))return;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(b);99==g&&(l=0);startMsg();var t=l;1==m&&(t=0);$.ajaxSingle({type:"post",data:{UID:a,CAT:b,DES:c,BDY:f,TAG:e,PID:g,PPW:d,PLD:n,LTP:m,PST:p,PED:q,TWT:getTweetSetting(),TWI:getTweetImageSetting(),
ED:3,CNG:h,REC:k},url:"/f/UploadTextRefTwitterF.jsp",dataType:"json",success:function(r){console.log("UploadTextRefTwitterF");r&&r.content_id&&0<r.content_id&&(1==t?$.ajax({type:"post",data:{UID:a,IID:r.content_id,IMG:0},url:"/api/UploadFileTweetF.jsp",dataType:"json",success:function(u){tweetSucceeded(u.result)}}):setTimeout(function(){location.href="/MyIllustListPcV.jsp"},1E3))}})}
function initOption(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){$(this).val()==a&&$("#EditCategory").val(a)});updateTweetButton()};
