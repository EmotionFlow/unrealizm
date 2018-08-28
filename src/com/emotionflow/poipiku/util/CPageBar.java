package com.emotionflow.poipiku.util;

public class CPageBar {
	static final int PAGE_BAR_NUM = 2;

	public static String CreatePageBar(String strPageName, String strOption, int nPageNum, int nContentsNum, int SELECT_MAX) {
		return CreatePageBar(strPageName, strOption, nPageNum, nContentsNum, SELECT_MAX, PAGE_BAR_NUM);
	}

	public static String CreatePageBar(String strPageName, String strOption, int nPageNum, int nContentsNum, int SELECT_MAX, int nPageBarNum) {
		int nPageTop = 0;
		int nPagePre = Math.max(nPageNum - 1, nPageTop);
		int nPageLast = Math.max((int) Math.ceil((double) nContentsNum / (double) SELECT_MAX) - 1, 0);
		int nPageNext = Math.min(nPageNum + 1, nPageLast);

		String strPagePre = String.format("<span class=\"PageBarItemFrame\"><a class=\"BtnBase PageBarItem\" href=\"%s?PG=%d%s\">&lt;</a></span>",
				strPageName, nPagePre, strOption);
		String strPageNext = String.format("<span class=\"PageBarItemFrame\"><a class=\"BtnBase PageBarItem\" href=\"%s?PG=%d%s\">&gt;</a></span>",
				strPageName, nPageNext, strOption);

		final int nPageNumLeftTmp1 = Math.min(nPageNum, nPageBarNum);
		final int nPageNumRightTmp1 = Math.min(nPageLast - nPageNum, nPageBarNum);

		final int nPageNumLeftTmp2 = nPageNumLeftTmp1 + nPageBarNum - nPageNumRightTmp1;
		final int nPageNumRightTmp2 = nPageNumRightTmp1 + nPageBarNum - nPageNumLeftTmp1;

		final int nPageNumLeft = Math.max(nPageNum - nPageNumLeftTmp2, 0);
		final int nPageNumRight = Math.min(nPageNum + nPageNumRightTmp2, nPageLast);

		StringBuilder strPageMenu = new StringBuilder();

		strPageMenu.append(strPagePre);
		for (int nPageCnt = nPageNumLeft; nPageCnt <= nPageNumRight; nPageCnt++) {
			strPageMenu.append(String.format("<span class=\"PageBarItemFrame\"><a class=\"BtnBase PageBarItem %s\" href=\"%s?PG=%d%s\">%d</a></span>",
					(nPageCnt == nPageNum) ? "Selected" : "", strPageName, nPageCnt, strOption, nPageCnt + 1));
		}
		strPageMenu.append(strPageNext);

		return strPageMenu.toString();
	}

	public static String CreatePageBarHtml(String strPageName, int nPageNum, int nContentsNum, int SELECT_MAX) {
		return CreatePageBarHtml(strPageName, nPageNum, nContentsNum, SELECT_MAX, PAGE_BAR_NUM);
	}

	public static String CreatePageBarHtml(String strPageName, int nPageNum, int nContentsNum, int SELECT_MAX, int nPageBarNum) {
		int nPageTop = 0;
		int nPagePre = Math.max(nPageNum - 1, nPageTop);
		int nPageLast = Math.max((int) Math.ceil((double) nContentsNum / (double) SELECT_MAX) - 1, 0);
		int nPageNext = Math.min(nPageNum + 1, nPageLast);

		String strPagePre = String.format("<span class=\"PageBarItemFrame\"><a class=\"BtnBase PageBarItem\" href=\"%s_%d.html\">&lt;</a></span>",
				strPageName, nPagePre);
		String strPageNext = String.format("<span class=\"PageBarItemFrame\"><a class=\"BtnBase PageBarItem\" href=\"%s_%d.html\">&gt;</a></span>",
				strPageName, nPageNext);

		final int nPageNumLeftTmp1 = Math.min(nPageNum, nPageBarNum);
		final int nPageNumRightTmp1 = Math.min(nPageLast - nPageNum, nPageBarNum);

		final int nPageNumLeftTmp2 = nPageNumLeftTmp1 + nPageBarNum - nPageNumRightTmp1;
		final int nPageNumRightTmp2 = nPageNumRightTmp1 + nPageBarNum - nPageNumLeftTmp1;

		final int nPageNumLeft = Math.max(nPageNum - nPageNumLeftTmp2, 0);
		final int nPageNumRight = Math.min(nPageNum + nPageNumRightTmp2, nPageLast);

		StringBuilder strPageMenu = new StringBuilder();

		strPageMenu.append(strPagePre);
		for (int nPageCnt = nPageNumLeft; nPageCnt <= nPageNumRight; nPageCnt++) {
			strPageMenu.append(String.format("<span class=\"PageBarItemFrame\"><a class=\"BtnBase PageBarItem %s\" href=\"%s_%d.html\">%d</a></span>",
					(nPageCnt == nPageNum) ? "Selected" : "", strPageName, nPageCnt, nPageCnt + 1));
		}
		strPageMenu.append(strPageNext);

		return strPageMenu.toString();
	}
}
