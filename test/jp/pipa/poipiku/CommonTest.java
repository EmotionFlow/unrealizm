package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class CommonTest {
	@Test
	public void testTrimBlankLines() {
		assertEquals(
				"1あああ\nいいいいい\nうううう",
				Common.TrimBlankLines("1あああ\nいいいいい\nうううう\n")
		);
		assertEquals(
				"　2あああ\nいいいいい\nうううう",
				Common.TrimBlankLines("\t  \n  　　\n　2あああ\nいいいいい\nうううう\n\t")
		);
		assertEquals(
				" 3あああ\n   いいいいい\nうううう",
				Common.TrimBlankLines("\n 3あああ\n   いいいいい\nうううう   \n  \n\n")
		);
		assertEquals(
				Common.TrimBlankLines("4"),
				"4"
		);
		assertEquals(
				Common.TrimBlankLines("5\n"),
				"5"
		);
		assertEquals(
				Common.TrimBlankLines("\n\t6"),
				"\t6"
		);
		assertEquals(
				Common.TrimBlankLines(""),
				""
		);
	}
}
