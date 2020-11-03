package jp.pipa.poipiku;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;


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

		//AccessUnique accessUnique = AccessUnique.getInstance();
		//accessUnique.init();
}

	public void contextDestroyed(ServletContextEvent event) {
	}
}
