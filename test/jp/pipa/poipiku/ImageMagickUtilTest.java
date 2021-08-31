package jp.pipa.poipiku;

import jp.pipa.poipiku.util.ImageMagickUtil;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class ImageMagickUtilTest {
	@Test
	public void testMontage() {
		List<String> srcList = new ArrayList<>();
		Collections.addAll(srcList,
				"img/1.png",
				"img/2.png",
				"img/3.png",
				"img/4.png",
				"img/5.png",
				"img/6.png",
				"img/7.png",
				"img/8.png",
				"img/9.jpg"
		);
		int exitCode = ImageMagickUtil.createMontage(srcList, "/tmp/montage_result.png");
		assertEquals(0, exitCode);
	}
}