<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByTagGridC cResults = new SearchIllustByTagGridC();
cResults.getParam(request);
cResults.m_strKeyword = "私の漫画を動画にしたい";
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(checkLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>私の漫画を動画にしたい | <%=_TEX.T("THeader.Title")%></title>
		<script>
			var g_nPage = 1;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage, "KWD" : decodeURIComponent("<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"), "MD" : <%=CCnv.MODE_PC%>},
					"dataType": "json",
					"url": "/f/SearchIllustByTagGridF.jsp",
					"success": function(data) {
						if(data.end_id>0) {
							g_nPage++;
							$("#IllustThumbList").append(data.html);
							$(".Waiting").remove();
							if(vg)vg.vgrefresh();
							g_bAdding = false;
							console.log(location.pathname+'/'+g_nPage+'.html');
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function UpdateFollow(nUserId, nFollowUserId) {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": nUserId, "IID": nFollowUserId },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow_'+nFollowUserId).addClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Following")%>");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow_'+nFollowUserId).removeClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Follow")%>");
						} else {
							DispMsg('フォローできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 600) {
						addContents();
					}
				});
			});
		</script>
		<style>
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
		</style>

		<script type="text/javascript" src="/js/jquery.easing.1.3.js"></script>
		<script type="text/javascript" src="/js/jquery.vgrid.min.js"></script>
		<script>
		//setup
		$(function() {
			vg = $("#IllustThumbList").vgrid({
				easing: "easeOutQuint",
				useLoadImageEvent: true,
				useFontSizeListener: true,
				time: 1,
				delay: 1,
				wait: 1,
				fadeIn: {
					time: 1,
					delay: 1
				},
				onStart: function(){
					$("#message1")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				},
				onFinish: function(){
					$("#message2")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				}
			});

			//$(window).load(function(e){
				$("#IllustThumbList").css('opacity', 1);
				//vg.vgrefresh();
			//});
		});
		</script>

<!-- #私の漫画を動画にしたい -->
<style>
.ppmc_content {
	background:#fff;
}
.ppmc_head img {
	width:600px;
}
.ppmc_sub img {
	width:600px;
}
.ppmc_sub_text {
	font-size:14px;
	padding:10px 25px 10px 25px;
}
.ppmc_sub {display: block; position: relative;}
.syou {
	text-align:center;
	border:1px solid red;
	font-size:24px;
	margin:10px 50px 10px 50px;
	padding:10px 25px 10px 25px;
}
.LinkButton {display: block; position: absolute; width: 100%;}
.LinkButton.Link2 {height: 321px; top:66px;}
</style>
<!-- /#私の漫画を動画にしたい -->

	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

<!-- #私の漫画を動画にしたい -->
<article class="Wrapper">
	<div class="ppmc_content">
		<div class="ppmc_head">
			<img src="./ppmc_pc_img/head_20200512.png">
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_syou_result.png">
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/syou1.png">
			<div class="syou">
				suka さん
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/syou2.png">
			<div class="syou">
				きたきたに さん
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/syou3.png">
			<div class="syou">
				そーや さん
				/ ばるたぁ さん
				/ ダrエダ？！？！ さん
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/syou4.png">
			<div class="syou">
				npitt さん
				/ あおい さん
				/ あおはる さん
				/ あざらし さん
				/ キスギ さん
				/ くきわかめ さん
				/ こじろー さん
				/ ようか さん
				/ わっちょ さん
				/ 矢代迅 さん
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_about.png">
			<div class="ppmc_sub_text">
				Youtubeで配信されるマンガ動画の漫画制作コンテストです。<br><br>
				お題となるシナリオを元に、詳細ラフを仕上げてポイピクで「 #私の漫画を動画にしたい 」で投稿していただきます。<br>
				投稿された漫画は後日、審査員による審査を行い、発表いたします。<br><br>
				ポイピクではクリエイターの方々のキャリアラダーとなれる様、様々な機能やイベントを予定しております。<br>
				今回のコンテストでは受賞者だけでなく、優秀な作品をご応募いただいた方にはYoutubeの漫画動画チャンネルを運営する株式会社プリズムリンクからマンガ動画の原稿制作を依頼させていただく可能性がございます。<br><br>
				皆様のご応募を心よりお待ちしております。<br>
			</div>
		</div>

		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_syou.png">
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/img_syou_20200512.png">
			<a class="LinkButton Link2" href="https://www.wacom.com/ja-jp/products/pen-displays/wacom-one" target="_blank"></a>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_term.png">
			<div class="ppmc_sub_text">
				応募期間：2020年4月22日〜2020年5月27日（23：59）<br>
				結果発表：2020年6月2日<br>
				※制作期間をもう少し欲しいとのご要望にお応えし応募期間を延長させていただきました<br>
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_req.png">
			<div class="ppmc_sub_text">
			・日本国内在住で国籍は不問。<br>
			・日本国内に銀行口座をお持ちの方。<br>
			・アマチュアで継続的にお仕事を受けられる方。<br>
			　※お仕事の内容は、月に1本、指示されたシナリオに従って25コマ程度の漫画制作（着彩まで含む）を想定<br>
			・応募時に満18歳以上の方。<br>
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_judge.png">
			<div class="ppmc_sub_text">
			#私の漫画を動画にしたい<br>
			Youtubeマンガ動画の漫画コンテスト<br>
			運営事務局
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_exam.png">
			<div class="ppmc_sub_text">
			・テーマに沿ってイラストが描かれていること<br>
			・シナリオを面白く伝えることができること<br>
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/sub_method.png">
			<div class="ppmc_sub">
				<img src="./ppmc_pc_img/btn_end.png">
			</div>
			<div class="ppmc_sub_text">
				①お題をDL<br>
				　本コンテストページからお題となるシナリオをダウンロード。<br>
				②３コマの漫画制作<br>
				　ダウンロードしたシナリオから３コマを選び、３つのラフ詳細を制作ください。<br>
				　ラフ詳細とは、線画着彩の１つ手前で、細かく書き込まれたラフ絵となります。<br>
				③３コマを合わせてタグを付けて投稿して応募完了<br>
				　ポイピクで「 #私の漫画を動画にしたい 」タグを付け、３コマを合わせて投稿してください。<br>
				　シナリオを読み、物語の見せ場などから３コマ自由に選んで頂き、投稿いただきます。<br>
				　画像サイズは、1920×1080[px]、解像度は72となります。<br>
			</div>
			<img src="./ppmc_pc_img/img_sample.png" width="200px">
			<div class="ppmc_sub_text">
				ご応募いただくことで、ポイピクの利用規約とプライバシーポリシー、下記注意事項にご同意いただいたこととなります。<br>
				<br>
				【注意事項】<br>
				・本コンテストにてダウンロードできるコンテンツ（以下「本コンテンツ」という）について，次の行為は許されません。<br>
				　本コンテンツそのまま、または改変しての譲渡・公表・配布・出版・私的利用以外の目的での複製又は改変等。<br>
				・応募者は、第三者から権利侵害・損害賠償請求等の主張があった場合、応募者が自らの責任で対処することとし、主催者側として一切責任を負わないものとします。作品の投稿に関連して投稿者に損害が生じることがあっても主催者側は一切責任を負わないものとします。<br>
				・応募者は、受賞の有無にかかわらず本コンテストへの投稿作品、作品コメントおよびニックネームの全部または一部が、ポイピク公式のTwitterなどのポイピク公式SNSアカウントに転載、またはイベント等に展示される場合があることを、あらかじめ承諾するものとします。転載内容は一部翻案・改変する場合があります。<br>
				・本コンテスト応募に伴う個人情報は、株式会社プリズムリンク社に副賞のお振込み及びお仕事のご依頼に関する連絡のためにのみ提供いたします。<br>
				・本コンテストにご応募いただいたラフ詳細がそのまま動画として配信されるのではなく、お仕事のご依頼にご同意いただいた方に動画用の漫画を仕上げて頂き、配信されることとなります。<br>
			</div>
		</div>
		<div class="ppmc_sub">
			<img src="./ppmc_pc_img/info.png">
		</div>
	</div>
</article>
<!-- /#私の漫画を動画にしたい -->

		<article class="Wrapper GridList">
			<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px; float: none;">
				<h2 class="Keyword">#<%=Util.toStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!checkLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%if(nCnt==1) {%>
					<%@ include file="/inner/TAdPc336x280_right_top.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>