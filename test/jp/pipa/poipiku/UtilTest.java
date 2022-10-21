package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Util;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.junit.jupiter.api.Assertions.*;

public class UtilTest {
	@Test
	public void testFindUserIdFromUrl() {
		assertEquals(123, Util.findUserIdFromUrl("https://ai.poipiku.com/123"));
		assertEquals(123, Util.findUserIdFromUrl("https://ai.poipiku.com/123/"));
		assertEquals(123, Util.findUserIdFromUrl("https://ai.poipiku.com/123/456.html"));
		assertEquals(123, Util.findUserIdFromUrl("https://ai.poipiku.com/IllustViewPcV.jsp?ID=123&TD=678"));
		assertEquals(-1, Util.findUserIdFromUrl("https://ai.poipiku.com/"));
		assertEquals(-1, Util.findUserIdFromUrl("https://ai.poipiku.com/StartUnrealizmV.jsp/"));
		assertEquals(-1, Util.findUserIdFromUrl("https://ai.poipiku.com/IllustViewPcV.jsp?ID=-234"));
	}
}
