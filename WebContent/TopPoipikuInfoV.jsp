<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>

		<script type="text/javascript" src="/js/jquery.simplyscroll.min.js"></script>
		<style>
			body {padding: 0 !important;}

			.Wrapper {width: 100%; color: #fff; background: #5bd; height: auto;}
			.Wrapper.ThumbList {width: 630px; margin: 0;}
			.AnalogicoDesc {display: block;width: 100%; padding: 30px 0 0 0; box-sizing: border-box; text-align: center; font-size: 16px; line-height: 28px; color: #fff; font-weight: normal;}
			.AnalogicoLogin {margin: 0 0 10px 0;}
			.AnalogicoTerm {display: block;width: 100%; padding: 0; box-sizing: border-box; text-align: center; font-size: 13px; line-height: 28px; color: #fff; font-weight: normal; text-decoration: underline;}
			.AnalogicoStart {text-align: center; margin: 30px 0 0 0; padding: 0 0 30px 0;}
			.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
			.AnalogicoInfo {display: none;}
			.FooterAd {display: none;}

			.PoipikuInfo {display: flex; flex-flow: row wrap; width: 100%; margin: 0 auto; justify-content: space-around; background-color: #fafafa; color: #5bd;padding: 5px; box-sizing: border-box;}
			.PoipikuInfoTitle {display: block; padding: 30px 0; text-align: center; font-size: 30px; font-weight: bold; flex: 1 1 100%;}
			.PoipikuInfo .PoipikuDesc {display: block; flex: 0 0 300px; padding: 10px; box-sizing: border-box; background-color: #5bd; color: #fff; margin: 5px 0;}
			.PoipikuInfo .PoipikuDesc .PoipikuDescImg {display: block; width: 100%;}
			.PoipikuInfo .PoipikuDesc .DescTitle {font-size: 17px; margin: 0 0 15px 0; font-weight: bold;}
			.PoipikuInfo .PoipikuDesc .DescTitle .DescSubTitle {font-size: 15px; font-weight: normal;}


			.poipikuDesc.TextOnly {height: auto;}
			.poipikuDesc .DescTitle {font-size: 18px; font-weight: bold;}

			.TopBanner {display: block; width: 350px; margin: 0 auto 20px auto;}

			<%if(Util.isSmartPhone(request)) {%>
			<%} else {%>
			.TopBanner {display: block; width: 600px; margin: 0 auto 30px auto;}
			<%}%>
		</style>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>
	</head>

	<body>
		<div class="Wrapper ThumbList">
			<div class="PoipikuInfo">
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS01.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS02.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS03.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS03-2.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS04.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS04-2.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS05.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS06.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS07.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS08.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS09.png" />
				</div>
				<div class="PoipikuDesc">
					<img class="PoipikuDescImg" src="/img/PoipikuInfo_2018_10_25/SS10.png" />
				</div>

				<div class="PoipikuDesc" style="flex: 0 0 610px;">
					<div class="DescTitle">
						転載対策もOK！
						<div class="DescSubTitle">
							転載禁止表示と右クリック禁止対策
						</div>
					</div>
					<div class="DescTitle">
						動くイラストもOK！
						<div class="DescSubTitle">
							アニメーションGIFにもフル対応
						</div>
					</div>
					<div class="DescTitle">
						ポイピクの活動を定期ツイート！
						<div class="DescSubTitle">
							週1回もしくは毎日の指定時間に定期ツイート ＆ 古い定期ツイート自動削除でTwitterの画像一覧が埋まらない
						</div>
					</div>
					<div class="DescTitle">
						イラストSNS11年の運営実績
						<div class="DescSubTitle">
							2007年から手書きブログを開始し、イラストSNS運営実績は11年。
							皆様の大切なイラストと共にサービスを売却するようなことはありません。
							安心してご利用ください。
							健全な運営のために必要な広告掲載にご理解いただけますと幸いです
						</div>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>