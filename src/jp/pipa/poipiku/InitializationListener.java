package jp.pipa.poipiku;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import jp.pipa.poipiku.cache.CacheUsers0000;
import org.apache.velocity.app.Velocity;


public class InitializationListener implements ServletContextListener {
	//AccessUnique accessUnique = new AccessUnique();

	public InitializationListener() {}

	@Override
	public void contextInitialized(ServletContextEvent event) {
		//ServletContext context=event.getServletContext();
		//context.setAttribute("access_unique", accessUnique);

		Emoji emoji = Emoji.getInstance();
		emoji.init();

		CacheUsers0000 cacheUsers0000 = CacheUsers0000.getInstance();
		cacheUsers0000.init();
		Velocity.setProperty(Velocity.FILE_RESOURCE_LOADER_PATH, event.getServletContext().getRealPath("WEB-INF/email_templates"));
		Velocity.setProperty(Velocity.FILE_RESOURCE_LOADER_CACHE, true);
		Velocity.init();

		//AccessUnique accessUnique = AccessUnique.getInstance();
		//accessUnique.init();
}

	public void contextDestroyed(ServletContextEvent event) {
	}
}
