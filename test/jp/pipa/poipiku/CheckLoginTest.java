package jp.pipa.poipiku;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class CheckLoginTest {
	@Test
	public void testIsStaff() {
		CheckLogin c = new CheckLogin();
		assertFalse(c.isStaff());
		c.m_nUserId = 1;
		assertTrue(c.isStaff());
	}
}
