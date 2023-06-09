package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Util;
import org.junit.jupiter.api.Test;


import static org.junit.jupiter.api.Assertions.*;

public class UtilTest {
	@Test
	public void testFindUserIdFromUrl() {
		assertEquals(123, Util.findUserIdFromUrl("https://unrealizm.com/123"));
		assertEquals(123, Util.findUserIdFromUrl("https://unrealizm.com/123/"));
		assertEquals(123, Util.findUserIdFromUrl("https://unrealizm.com/123/456.html"));
		assertEquals(123, Util.findUserIdFromUrl("https://unrealizm.com/IllustViewPcV.jsp?ID=123&TD=678"));
		assertEquals(-1, Util.findUserIdFromUrl("https://unrealizm.com/"));
		assertEquals(-1, Util.findUserIdFromUrl("https://unrealizm.com/StartUnrealizmV.jsp/"));
		assertEquals(-1, Util.findUserIdFromUrl("https://unrealizm.com/IllustViewPcV.jsp?ID=-234"));
	}
}
