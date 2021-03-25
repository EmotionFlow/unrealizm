package jp.pipa.poipiku;
import java.io.StringWriter;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.apache.velocity.exception.ResourceNotFoundException;
import org.apache.velocity.exception.ParseErrorException;
import org.apache.velocity.exception.MethodInvocationException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class EmailTemplateTest {
	@Test
	public void testDear() {
		final String toName = "山田太郎";
		try{
			//Velocityの初期化
			Velocity.init("velocity.properties");
			//Velocityコンテキストに値を設定
			VelocityContext context = new VelocityContext();
			context.put("to_name", toName);
			StringWriter sw = new StringWriter();
			//テンプレートの作成
			Template template = Velocity.getTemplate("ja/header.vm", "UTF-8");
			//テンプレートとマージ
			template.merge(context,sw);
			//マージしたデータはWriterオブジェクトであるswが持っているのでそれを文字列として出力
			System.out.println(sw.toString());
			assertTrue(sw.toString().indexOf(toName) >= 0);
			sw.flush();
		} catch (ResourceNotFoundException e) {
			fail(e);
		} catch (ParseErrorException e) {
			fail(e);
		} catch (MethodInvocationException e) {
			fail(e);
		} catch (Exception e) {
			fail(e);
		}
	}
}
