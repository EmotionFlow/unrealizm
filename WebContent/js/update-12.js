function UpdateFileOrder(b,d,f){var e=[];$.each($(".qq-upload-list-selector.qq-upload-list").sortable("toArray"),function(a,c){e.push(parseInt(c))});$.ajax({type:"post",data:{UID:b,IID:d,AID:JSON.stringify(e)},url:"/f/UpdateFileOrderF.jsp",dataType:"json",success:function(a){console.log("UploadFileOrderF:"+a.result);f&&0<f.length&&(completeMsg(),setTimeout(function(){location.href=f},1E3))},error:function(a){console.log(a)}})}
function UpdatePasteOrderAjax(b,d,f){return $.ajax({type:"post",data:{UID:b,IID:d,AID:JSON.stringify(f)},url:"/f/UpdateFileOrderF.jsp",dataType:"json"})}
function initUpdateFile(b,d,f,e){updateTweetButton();multiFileUploader=new qq.FineUploader({session:{endpoint:"/f/GetIllustFileListF.jsp?TD="+e+"&ID="+f,refreshOnRequest:!0},element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg","jpg","gif","png"],itemLimit:b,sizeLimit:1048576*d,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,c){this.newfile_num&&0<this.newfile_num&&
(this.setEndpoint("/f/UpdateFileAppendF.jsp",a),this.setParams({UID:this.user_id,IID:this.content_id},a))},onComplete:function(a,c,g,l){append_id=g.append_id;$(".qq-file-id-"+a).attr("id",append_id)},onAllComplete:function(a,c){console.log("onAllComplete",a,c,this.tweet);this.newfile_num&&0<this.newfile_num?(1==this.tweet?Tweet(this.user_id,this.content_id,this.tweet_image,this.delete_tweet):(completeMsg(),setTimeout(function(){location.href="/MyIllustListPcV.jsp"},1E3)),UpdateFileOrder(this.user_id,
this.content_id,"/MyIllustListPcV.jsp")):($("li.qq-upload-success").removeClass("qq-upload-success"),$("button.qq-upload-cancel").removeClass("qq-hide"))},onValidate:function(a){var c=this.getSubmittedSize(),g=this.getSubmittedNum();this.showTotalSize(c,g);c+=a.size;if(c>this.total_size)return!1;this.showTotalSize(c,g+1)},onStatusChange:function(a,c,g){this.newfile_num&&0<this.newfile_num&&this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};
multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),c=0;$.each(a,function(){c+=this.size});return c};multiFileUploader.showTotalSize=function(a,c){var g="(jpeg|png|gif, "+b+"files, total "+d+"MByte)";0<a&&(g="("+c+"/"+b+"files "+Math.ceil(a/1024/1024)+"/"+d+"MByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(g)};multiFileUploader.sessionRequestComplete=function(a,c,g,l){alert(c)};multiFileUploader.total_size=52428800}
function Tweet(b,d,f,e){$.ajax({type:"post",data:{UID:b,IID:d,IMG:f,DELTW:e},url:"/api/UploadFileTweetF.jsp",dataType:"json",success:function(a){tweetSucceeded(a.result)}})}
function UpdateFile(b,d){if(multiFileUploader&&!(0>=$(".qq-upload-list-selector.qq-upload-list").children("li").length)){var f=$("#TagInputItemData").val(),e=parseInt($("#EditCategory").val(),10),a=$.trim($("#EditDescription").val()),c=$.trim($("#EditTagList").val());c=c.substr(0,100);var g=parseInt($("#ContentOpenId").val(),10),l=parseInt($("#EditPublish").val(),10),u=$("#EditPassword").val(),q=$("#OptionCheerNg").prop("checked")?0:1,y=$("#OptionRecent").prop("checked")?1:0,v=$("#OptionTweet").prop("checked")?
1:0,w=$("#OptionImage").prop("checked")?1:0,m=$("#OptionDeleteTweet").prop("checked")?1:0,x=null,t=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),n=null,r=null;if(10===l){if($("#TwitterListNotFound").is(":visible")){twitterListNotFoundMsg();return}x=$("#EditTwitterList").val()}if(1===t&&(n=getPublishDateTime($("#EditTimeLimitedStart").val()),r=getPublishDateTime($("#EditTimeLimitedEnd").val()),strPublishStartPresent=$("#EditTimeLimitedStartPresent").val(),strPublishEndPresent=$("#EditTimeLimitedEndPresent").val(),
!checkPublishDatetime(n,r,!0,strPublishStartPresent,strPublishEndPresent))){bEntered=!1;return}$("#TagInputItemData").length||(f=1);setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(e);99===l&&(v=0);startMsg();var p=v;1===t&&(p=2===g||null!=strPublishStartPresent&&null!=strPublishEndPresent?1===v&&2!==g&&comparePublishDate(strPublishStartPresent,n)&&comparePublishDate(strPublishEndPresent,r)?1:0:0);startMsg();$.ajaxSingle({type:"post",
data:{IID:d,UID:b,GD:f,CAT:e,DES:a,TAG:c,PID:l,PPW:u,PLD:x,LTP:t,REC:y,PST:n,PED:r,TWT:getTweetSetting(),TWI:getTweetImageSetting(),DELTW:m,ED:0,CNG:q},url:"/f/UpdateFileRefTwitterF.jsp",dataType:"json",success:function(k){k&&0<k.content_id?0<multiFileUploader.getSubmittedNum()?(multiFileUploader.user_id=b,multiFileUploader.content_id=k.content_id,multiFileUploader.tweet=p,multiFileUploader.tweet_image=w,multiFileUploader.delete_tweet=m,multiFileUploader.newfile_num=multiFileUploader.getSubmittedNum(),
multiFileUploader.uploadStoredFiles()):1===p?(UpdateFileOrder(b,k.content_id,null),Tweet(b,k.content_id,w,m)):UpdateFileOrder(b,k.content_id,"/MyIllustListPcV.jsp"):errorMsg()}})}}
function initUpdatePaste(b,d){updateTweetButton();var f=getLastCategorySetting();$("#EditCategory option").each(function(){$(this).val()==f&&$("#EditCategory").val(f)});g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(e,a){10>$(".InputFile").length&&(e=createPasteElm(a.dataURL),$("#PasteZone").append(e),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(e,a){a.url&&
alert("error data : "+a.url)}).on("pasteText",function(e,a){$("#TimeLineAddImage").html(g_strPasteMsg)});$.ajax({type:"post",data:{ID:b,TD:d},url:"/f/GetIllustFileListF.jsp",dataType:"json",success:function(e){$.each(e,function(a,c){10>$(".InputFile").length&&(a=createPasteListItem(c.thumbnailUrl,c.append_id),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()})}})}
function UpdatePasteAppendFAjax(b,d,f){b.parent().addClass("Done");b=b.attr("src").replace("data:image/png;base64,","");return 0>=b.length?null:$.ajax({type:"post",data:{UID:d,IID:f,DATA:b},url:"/f/UpdatePasteAppendF.jsp",dataType:"json",async:!1})}
function UpdateFileRefTwitterFAjax(b,d,f,e,a,c,g,l,u,q,y,v,w,m,x,t,n){return $.ajax({type:"post",data:{UID:b,IID:d,GD:f,CAT:e,DES:a,TAG:c,PID:g,PPW:l,PLD:u,LTP:v,REC:y,PST:w,PED:m,TWT:x,TWI:t,DELTW:n,ED:1,CNG:q},url:"/f/UpdateFileRefTwitterF.jsp",dataType:"json"})}
function UploadTextRefTwitterFAjax(b,d,f,e,a,c,g,l,u,q,y,v,w,m,x,t,n,r,p,k){return $.ajax({type:"post",data:{UID:b,IID:d,GD:f,CAT:e,DES:a,BDY:c,TAG:g,PID:l,PPW:u,PLD:q,LTP:w,REC:v,PST:m,PED:x,TWT:t,TWI:n,DELTW:r,ED:1,CNG:y,TIT:p,DIR:k},url:"/f/UpdateTextRefTwitterF.jsp",dataType:"json"})}function UploadFileTweetFAjax(b,d,f,e){return $.ajax({type:"post",data:{UID:b,IID:d,IMG:f,DELTW:e},url:"/api/UploadFileTweetF.jsp",dataType:"json"})}
function createUpdatePaste(){var b=!1;return function(d,f){if(!b){b=!0;var e=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&e++});if(0>=e)b=!1;else{var a=$("#TagInputItemData").val(),c=parseInt($("#EditCategory").val(),10),g=$.trim($("#EditDescription").val()),l=$.trim($("#EditTagList").val());l=l.substr(0,100);var u=$("#ContentOpenId").val(),q=parseInt($("#EditPublish").val(),10),y=$("#EditPassword").val(),v=$("#OptionCheerNg").prop("checked")?0:1,w=$("#OptionRecent").prop("checked")?
1:0,m=$("#OptionTweet").prop("checked")?1:0,x=$("#OptionImage").prop("checked")?1:0,t=$("#OptionDeleteTweet").prop("checked")?1:0,n=null,r=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),p=null,k=null;if(10===q){if($("#TwitterListNotFound").is(":visible")){b=!1;twitterListNotFoundMsg();return}n=$("#EditTwitterList").val()}if(1===r&&(p=getPublishDateTime($("#EditTimeLimitedStart").val()),k=getPublishDateTime($("#EditTimeLimitedEnd").val()),strPublishStartPresent=$("#EditTimeLimitedStartPresent").val(),
strPublishEndPresent=$("#EditTimeLimitedEndPresent").val(),!checkPublishDatetime(p,k,!0,strPublishStartPresent,strPublishEndPresent))){b=!1;return}$("#TagInputItemData").length||(a=1);setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(c);99===q&&(m=0);var z=m;1===r&&(z=2===u||null!=strPublishStartPresent&&null!=strPublishEndPresent?1===m&&2!==u&&comparePublishDate(strPublishStartPresent,p)&&comparePublishDate(strPublishEndPresent,
k)?1:0:0);startMsg();var B=[],D=null;UpdateFileRefTwitterFAjax(d,f,a,c,g,l,q,y,n,v,w,r,p,k,getTweetSetting(),getTweetImageSetting(),t).done(function(A){var C=null;$(".imgView").each(function(){C=UpdatePasteAppendFAjax($(this),d,A.content_id);null!=C&&B.push(C)});D=1===z?UploadFileTweetFAjax(d,A.content_id,x,t):function(){var h=$.Deferred();h.resolve(1);return h.promise()};$.when.apply($,B).then(function(){var h=[];$.each($("#PasteZone").sortable("toArray"),function(H,G){h.push(parseInt(G))});for(var E=
0;E<arguments.length;E++){var F=void 0;F=1===h.length?arguments[0].append_id:arguments[E][0].append_id;0<=F&&(h[E]=F);if(1===h.length)break}return UpdatePasteOrderAjax(d,A.content_id,h)},function(h){errorMsg(-10)}).then(D,function(h){errorMsg(-11)}).then(function(h){tweetSucceeded(h)},function(h){errorMsg(-12)})});return!1}}}}var UpdatePaste=createUpdatePaste();
function createUpdateText(){var b=!1;return function(d,f){if(!b){b=!0;var e=$("#TagInputItemData").val(),a=parseInt($("#EditCategory").val(),10),c=$.trim($("#EditDescription").val()),g=$("#EditTextBody").val(),l=$.trim($("#EditTagList").val());l=l.substr(0,100);var u=$("#ContentOpenId").val(),q=parseInt($("#EditPublish").val(),10),y=$("#EditPassword").val(),v=$("#OptionCheerNg").prop("checked")?0:1,w=$("#OptionRecent").prop("checked")?1:0,m=$("#OptionTweet").prop("checked")?1:0,x=$("#EditTextTitle").val(),
t=$('input:radio[name="EditTextDirection"]:checked').val(),n=$("#OptionDeleteTweet").prop("checked")?1:0,r=null,p=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),k=null,z=null;if(10===q){if($("#TwitterListNotFound").is(":visible")){twitterListNotFoundMsg();return}r=$("#EditTwitterList").val()}if(1===p&&(k=getPublishDateTime($("#EditTimeLimitedStart").val()),z=getPublishDateTime($("#EditTimeLimitedEnd").val()),strPublishStartPresent=$("#EditTimeLimitedStartPresent").val(),strPublishEndPresent=
$("#EditTimeLimitedEndPresent").val(),!checkPublishDatetime(k,z,!0,strPublishStartPresent,strPublishEndPresent))){b=!1;return}$("#TagInputItemData").length||(e=1);setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(a);99===q&&(m=0);var B=m;1===p&&(B=2===u||null!=strPublishStartPresent&&null!=strPublishEndPresent?1===m&&2!==u&&comparePublishDate(strPublishStartPresent,k)&&comparePublishDate(strPublishEndPresent,z)?1:0:0);
startMsg();var D=[],A=null;UploadTextRefTwitterFAjax(d,f,e,a,c,g,l,q,y,r,v,w,p,k,z,getTweetSetting(),getTweetImageSetting(),n,x,t).done(function(C){A=1===B?UploadFileTweetFAjax(d,C.content_id,0,n):function(){var h=$.Deferred();h.resolve(1);return h.promise()};$.when.apply($,D).then(A,function(h){errorMsg(-11)}).then(function(h){tweetSucceeded(h)},function(h){errorMsg(-12)})});return!1}}}var UpdateText=createUpdateText();
