var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,b,c){a instanceof String&&(a=String(a));for(var e=a.length,d=0;d<e;d++){var n=a[d];if(b.call(c,n,d,a))return{i:d,v:n}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.SIMPLE_FROUND_POLYFILL=!1;
$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,b,c){a!=Array.prototype&&a!=Object.prototype&&(a[b]=c.value)};$jscomp.getGlobal=function(a){return"undefined"!=typeof window&&window===a?a:"undefined"!=typeof global&&null!=global?global:a};$jscomp.global=$jscomp.getGlobal(this);
$jscomp.polyfill=function(a,b,c,e){if(b){c=$jscomp.global;a=a.split(".");for(e=0;e<a.length-1;e++){var d=a[e];d in c||(c[d]={});c=c[d]}a=a[a.length-1];e=c[a];b=b(e);b!=e&&null!=b&&$jscomp.defineProperty(c,a,{configurable:!0,writable:!0,value:b})}};$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(a,c){return $jscomp.findInternal(this,a,c).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(a){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return d.mountNonInputable(a)._container};a.fn.pastableNonInputable=function(){var b;var c=0;for(b=this.length;c<b;c++){var g=this[c];g._pastable||a(g).is("textarea, input:text, [contenteditable]")||(d.mountNonInputable(g),g._pastable=!0)}return this};a.fn.pastableTextarea=function(){var b;var c=0;for(b=
this.length;c<b;c++){var g=this[c];g._pastable||a(g).is(":not(textarea, input:text)")||(d.mountTextarea(g),g._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var b;var c=0;for(b=this.length;c<b;c++){var g=this[c];g._pastable||a(g).is(":not([contenteditable])")||(d.mountContenteditable(g),g._pastable=!0)}return this};var b=function(a,b){var c,f,h;null==b&&(b=512);if(!(c=a.match(/^data:([^;]+);base64,(.+)$/)))return null;a=c[1];var l=atob(c[2]);c=[];for(h=0;h<l.length;){var k=l.slice(h,
h+b);var e=Array(k.length);for(f=0;f<k.length;)e[f]=k.charCodeAt(f),f++;e=new Uint8Array(e);c.push(e);h+=b}return new Blob(c,{type:a})};var c=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var e=function(b,c){var f=b.nodeName.toLowerCase();if("area"===f){c=b.parentNode;f=c.name;if(!b.href||!f||"map"!==c.nodeName.toLowerCase())return!1;b=a("img[usemap='#"+
f+"']");return 0<b.length&&b.is(":visible")}/^(input|select|textarea|button|object)$/.test(f)?(f=!b.disabled)&&(c=a(b).closest("fieldset")[0])&&(f=!c.disabled):f="a"===f?b.href||c:c;return(f=f||a(b).is("[contenteditable]"))&&a(b).is(":visible")};var d=function(){function d(b,c){this._container=b;this._target=c;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(a){return function(b){var c,f,d;a.originalEvent=null!==b.originalEvent?
b.originalEvent:null;a._paste_event_fired=!0;if(null!=(null!=(c=b.originalEvent)?c.clipboardData:void 0)){var e=b.originalEvent.clipboardData;if(e.items){var h=null;a.originalEvent.pastedTypes=[];var g=e.items;var m=0;for(f=g.length;m<f;m++)c=g[m],c.type.match(/^text\/(plain|rtf|html)/)&&a.originalEvent.pastedTypes.push(c.type);var n=e.items;m=f=0;for(g=n.length;f<g;m=++f){c=n[m];if(c.type.match(/^image\//)){e=new FileReader;e.onload=function(b){return a._handleImage(b.target.result,a.originalEvent,
h)};try{e.readAsDataURL(c.getAsFile())}catch(w){}b.preventDefault();break}if("text/plain"===c.type){if(0===m&&1<e.items.length&&e.items[1].type.match(/^image\//)){var u=!0;var v=e.items[1].type}c.getAsString(function(b){return u?(h=b,a._target.trigger("pasteText",{text:b,isFilename:!0,fileType:v,originalEvent:a.originalEvent})):a._target.trigger("pasteText",{text:b,originalEvent:a.originalEvent})})}"text/rtf"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextRich",{text:b,originalEvent:a.originalEvent})});
"text/html"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextHtml",{text:b,originalEvent:a.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(e.types,"text/plain")){var t=e.getData("Text");setTimeout(function(){return a._target.trigger("pasteText",{text:t,originalEvent:a.originalEvent})},1)}a._checkImagesInContainer(function(b){return a._handleImage(b,a.originalEvent)})}}if(e=window.clipboardData)if(null!=(d=t=e.getData("Text"))&&d.length)setTimeout(function(){a._target.trigger("pasteText",
{text:t,originalEvent:a.originalEvent});return a._target.trigger("_pasteCheckContainerDone")},1);else{e=e.files;d=0;for(c=e.length;d<c;d++)b=e[d],a._handleImage(URL.createObjectURL(b),a.originalEvent);a._checkImagesInContainer(function(a){})}return null}}(this))}d.prototype._target=null;d.prototype._container=null;d.mountNonInputable=function(b){var f=new d(c().appendTo(b),b);a(b).on("click",function(a){return function(a){if(!e(a.target,!1)&&!window.getSelection().toString())return f._container.focus()}}(this));
f._container.on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return f._container.on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};d.mountTextarea=function(b){var e,f;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(e=Object.getOwnPropertyDescriptor)&&null!=(f=e.call(Object,DataTransfer.prototype,"items"))&&f.get)return this.mountContenteditable(b);var h=new d(c().insertBefore(b),
b);var l=!1;a(b).on("keyup",function(a){var b;if(17===(b=a.keyCode)||224===b)l=!1;return null});a(b).on("keydown",function(c){var e;if(17===(e=c.keyCode)||224===e)l=!0;null!=c.ctrlKey&&null!=c.metaKey&&(l=c.ctrlKey||c.metaKey);l&&86===c.keyCode&&(h._textarea_focus_stolen=!0,h._container.focus(),h._paste_event_fired=!1,setTimeout(function(c){return function(){if(!h._paste_event_fired)return a(b).focus(),h._textarea_focus_stolen=!1}}(this),1));return null});a(b).on("paste",function(a){return function(){}}(this));
a(b).on("focus",function(c){return function(){if(!h._textarea_focus_stolen)return a(b).addClass("pastable-focus")}}(this));a(b).on("blur",function(c){return function(){if(!h._textarea_focus_stolen)return a(b).removeClass("pastable-focus")}}(this));a(h._target).on("_pasteCheckContainerDone",function(c){return function(){a(b).focus();return h._textarea_focus_stolen=!1}}(this));return a(h._target).on("pasteText",function(c){return function(c,e){var d=a(b).prop("selectionStart");var f=a(b).prop("selectionEnd");
c=a(b).val();a(b).val(""+c.slice(0,d)+e.text+c.slice(f));a(b)[0].setSelectionRange(d+e.text.length,d+e.text.length);return a(b).trigger("change")}}(this))};d.mountContenteditable=function(b){new d(b,b);a(b).on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return a(b).on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};d.prototype._handleImage=function(a,c,e){if(a.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var d=new Image;d.crossOrigin="anonymous";d.onload=function(a){return function(){var f=document.createElement("canvas");f.width=d.width;f.height=d.height;f.getContext("2d").drawImage(d,0,0,f.width,f.height);var g=null;try{g=f.toDataURL("image/png");var h=b(g)}catch(r){}g&&a._target.trigger("pasteImage",{blob:h,dataURL:g,width:d.width,height:d.height,originalEvent:c,
name:e});return a._target.trigger("pasteImageEnd")}}(this);d.onerror=function(b){return function(){b._target.trigger("pasteImageError",{message:"Failed to get image from: "+a,url:a});return b._target.trigger("pasteImageEnd")}}(this);return d.src=a};d.prototype._checkImagesInContainer=function(b){var c;var e=Math.floor(1E3*Math.random());var d=this._container.find("img");var f=0;for(c=d.length;f<c;f++){var k=d[f];k["_paste_marked_"+e]=!0}return setTimeout(function(c){return function(){var d;var f=
c._container.find("img");var g=0;for(d=f.length;g<d;g++)k=f[g],k["_paste_marked_"+e]||(b(k.src),a(k).remove());return c._target.trigger("_pasteCheckContainerDone")}}(this),1)};return d}()}).call(this);function DispDescCharNum(){var a=200-$("#EditDescription").val().length;$("#DescriptionCharNum").html(a)}function DispTagListCharNum(){var a=100-$("#EditTagList").val().length;$("#EditTagListCharNum").html(a)}
function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}function setLastCategorySetting(a){setLocalStrage("last_category",a)}
function getLastCategorySetting(){return getLocalStrage("last_category")}function comparePublishDate(a,b){return null==a&&null==b?!1:null==a&&null==b?!0:a.substr(0,16)===b.substr(0,16)}
function checkPublishDatetime(a,b,c,e,d){e=void 0===e?null:e;d=void 0===d?null:d;if(c&&(null==e||null==d)||c&&comparePublishDate(e,a)&&comparePublishDate(d,b))return!0;if(""==a||""==b)return dateTimeEmptyMsg(),!1;if(!c||c&&(!comparePublishDate(e,a)||!comparePublishDate(d,b)))if(Date.parse(a)<Date.now()||Date.parse(b)<Date.now())return dateTimePastMsg(),!1;return Date.parse(a)>Date.parse(b)?(dateTimeReverseMsg(),!1):!0}
function updateTweetButton(){$("#OptionTweet").prop("checked")?($("#ImageSwitch .OptionLabel").removeClass("disabled"),$("#ImageSwitch .onoffswitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1),$("#DeleteTweetSwitch .OptionLabel").removeClass("disabled"),$("#DeleteTweetSwitch .onoffswitch").removeClass("disabled"),$("#OptionDeleteTweet:checkbox").prop("disabled",!1)):($("#ImageSwitch .OptionLabel").addClass("disabled"),$("#ImageSwitch .onoffswitch").addClass("disabled"),
$("#OptionImage:checkbox").prop("disabled",!0),$("#DeleteTweetSwitch .OptionLabel").addClass("disabled"),$("#DeleteTweetSwitch .onoffswitch").addClass("disabled"),$("#OptionDeleteTweet:checkbox").prop("disabled",!0))}function initStartDatetime(a){$("#EditTimeLimitedStart").flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,defaultDate:a})}
function initEndDatetime(a){$("#EditTimeLimitedEnd").flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,defaultDate:a})}
function updateOptionLimitedTimePublish(){var a=$("#ItemTimeLimitedVal");$("#OptionLimitedTimePublish").prop("checked")?a.slideDown(300,function(){$.each(["#EditTimeLimitedStart","#EditTimeLimitedEnd"],function(a,c){0>$(c)[0].classList.value.indexOf("flatpickr-input")&&(a=new Date,a.setMinutes(30*Math.floor((a.getMinutes()+45)/30)),$(c).flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,minDate:a}))})}):a.slideUp(300)}
function updateAreaLimitedTimePublish(a){var b=$("#ItemTimeLimitedFlg"),c=$("#ItemTimeLimitedVal");99!=a?b.slideDown(300,function(){updateOptionLimitedTimePublish()}):$("#OptionLimitedTimePublish").prop("checked")?c.slideUp(300,function(){b.slideUp(300)}):b.slideUp(300)}
function updatePublish(){var a=parseInt($("#EditPublish").val(),10);updateAreaLimitedTimePublish(a);var b=[$("#ItemTwitterList"),$("#ItemPassword")];if(4==a||10==a||11==a){var c=null,e=null;switch(a){case 4:e=$("#ItemPassword");break;case 10:e=$("#ItemTwitterList")}for(a=0;a<b.length;a++){var d=b[a];if(d.is(":visible")){c=d;break}}null==c?e.slideDown(300):c.slideUp(300,function(){e.delay(150).slideDown(300)})}else for(a=0;a<b.length;a++)d=b[a],d.is(":visible")&&d.slideUp(300)}
function initUploadFile(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateTweetButton();multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg",
"jpg","gif","png"],itemLimit:200,sizeLimit:2E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,c){this.first_file?(this.first_file=!1,this.setEndpoint("/f/UploadFileFirstF.jsp",a),console.log("UploadFileFirstF")):(this.setEndpoint("/f/UploadFileAppendF.jsp",a),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,PID:this.publish_id,REC:this.recent},a)},onAllComplete:function(a,c){console.log("onAllComplete",a,c,this.tweet);1==this.tweet?
$.ajax({type:"post",data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyIllustListV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyIllustListV.jsp"},1E3))},onValidate:function(a){var b=this.getSubmittedSize(),e=this.getSubmittedNum();this.showTotalSize(b,e);b+=a.size;if(b>this.total_size)return!1;this.showTotalSize(b,
e+1)},onStatusChange:function(a,c,e){this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),c=0;$.each(a,function(){c+=this.size});return c};multiFileUploader.showTotalSize=function(a,c){var b="(jpeg|png|gif, 200files, total 50MByte)";0<a&&(b="("+c+"/200,  "+Math.ceil((multiFileUploader.total_size-
a)/1024)+" KByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(b)};multiFileUploader.total_size=52428800}function getPublishDateTime(a){return""==a?"":(new Date(a)).toISOString()}function getLimitedTimeFlg(a,b){return 99==$("#"+a).val()?0:$("#"+b).prop("checked")?1:0}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var b=$("#EditCategory").val(),c=$.trim($("#EditDescription").val());c=c.substr(0,200);var e=$.trim($("#EditTagList").val());e=e.substr(0,100);var d=$("#EditPublish").val(),n=$("#EditPassword").val(),f=$("#OptionRecent").prop("checked")?1:0,g=$("#OptionTweet").prop("checked")?1:0,m=$("#OptionImage").prop("checked")?1:0,h=null,l=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),k=null,p=null;10==d&&(h=
$("#EditTwitterList").val());if(1==l&&(k=getPublishDateTime($("#EditTimeLimitedStart").val()),p=getPublishDateTime($("#EditTimeLimitedEnd").val()),!checkPublishDatetime(k,p,!1)))return;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(b);99==d&&(g=0);startMsg();var q=g;1==l&&(q=0);$.ajaxSingle({type:"post",data:{UID:a,CAT:b,DES:c,TAG:e,PID:d,PPW:n,PLD:h,LTP:l,PST:k,PED:p,TWT:getTweetSetting(),TWI:getTweetImageSetting()},
url:"/f/UploadFileRefTwitterF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF");b&&b.content_id&&(0<b.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=b.content_id,multiFileUploader.recent=f,multiFileUploader.tweet=q,multiFileUploader.tweet_image=m,multiFileUploader.publish_id=d,multiFileUploader.uploadStoredFiles()):errorMsg())}})}}var g_strPasteMsg="";
function initUploadPaste(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateTweetButton();g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,c){10>$(".InputFile").length&&(a=createPasteElm(c.dataURL),
$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(a,c){c.url&&alert("error data : "+c.url)}).on("pasteText",function(a,c){$("#TimeLineAddImage").html(g_strPasteMsg)})}
function createPasteElm(a){var b=$("<div />").addClass("InputFile"),c=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);b.append(c).append(a);return b}
function createPasteListItem(a,b){b=$("<li />").addClass("InputFile").attr("id",b);var c=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);b.append(c).append(a);return b}
function createPasteListItem(a,b){b=$("<li />").addClass("InputFile").attr("id",b);var c=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);b.append(c).append(a);return b}
function initPasteElm(a){a.on("pasteImage",function(a,c){$(".OrgMessage",this).hide();$(".imgView",this).attr("src",c.dataURL).show()}).on("pasteImageError",function(a,c){c.url&&alert("error data : "+c.url)}).on("pasteText",function(a,c){})}function updatePasteNum(){strTotal="("+$(".InputFile").length+"/10)";$("#TotalSize").html(strTotal)}
function UploadPaste(a){var b=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&b++});console.log(b);if(!(0>=b)){var c=$("#EditCategory").val(),e=$.trim($("#EditDescription").val());e=e.substr(0,200);var d=$.trim($("#EditTagList").val());d=d.substr(0,100);var n=$("#EditPublish").val(),f=$("#EditPassword").val(),g=$("#OptionRecent").prop("checked")?1:0,m=$("#OptionTweet").prop("checked")?1:0,h=$("#OptionImage").prop("checked")?1:0,l=null,k=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),
p=null,q=null;10==n&&(l=$("#EditTwitterList").val());if(1==k&&(p=getPublishDateTime($("#EditTimeLimitedStart").val()),q=getPublishDateTime($("#EditTimeLimitedEnd").val()),!checkPublishDatetime(p,q,!1)))return;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(c);99==n&&(m=0);startMsg();var r=m;1==k&&(r=0);$.ajaxSingle({type:"post",data:{UID:a,CAT:c,DES:e,TAG:d,PID:n,PPW:f,PLD:l,LTP:k,PST:p,PED:q,TWT:getTweetSetting(),TWI:getTweetImageSetting(),
ED:1},url:"/f/UploadFileRefTwitterF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF",b.content_id);var c=!0;$(".imgView").each(function(){$(this).parent().addClass("Done");var d=$(this).attr("src").replace("data:image/png;base64,","");if(0>=d.length)return!0;c?(c=!1,$.ajax({type:"post",data:{UID:a,IID:b.content_id,REC:g,DATA:d},url:"/f/UploadPasteFirstF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteFirstF")}})):$.ajax({type:"post",data:{UID:a,
IID:b.content_id,DATA:d},url:"/f/UploadPasteAppendF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteAppendF")}})});1==r?$.ajax({type:"post",data:{UID:a,IID:b.content_id,IMG:h},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyIllustListV.jsp"},1E3)}}):setTimeout(function(){location.href="/MyIllustListV.jsp"},1E3)}});return!1}};
