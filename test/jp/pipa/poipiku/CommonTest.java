package jp.pipa.poipiku;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class CommonTest {
	@Test
	public void testTrimBlankLines() {
		assertEquals(
				"1あああ\nいいいいい\nうううう\n",
				Common.TrimHeadBlankLines("1あああ\nいいいいい\nうううう\n")
		);
		assertEquals(
				"　2あああ\nいいいいい\nうううう\n\t",
				Common.TrimHeadBlankLines("\t  \n  　　\n　2あああ\nいいいいい\nうううう\n\t")
		);
		assertEquals(
				" 3あああ\n   いいいいい\nうううう   \n  \n\n",
				Common.TrimHeadBlankLines("\n 3あああ\n   いいいいい\nうううう   \n  \n\n")
		);
		assertEquals(
				Common.TrimHeadBlankLines("4"),
				"4"
		);
		assertEquals(
				Common.TrimHeadBlankLines("5\n"),
				"5\n"
		);
		assertEquals(
				Common.TrimHeadBlankLines("\n\t6"),
				"\t6"
		);
		assertEquals(
				Common.TrimHeadBlankLines(""),
				""
		);
	}
}
