package jp.pipa.poipiku;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import jp.pipa.poipiku.AccessUnique;

public class InitializationListener implements ServletContextListener {
	AccessUnique accessUnique = new AccessUnique();

	public InitializationListener() {}

	public void contextInitialized(ServletContextEvent event) {
		ServletContext context=event.getServletContext();
		context.setAttribute("access_unique", accessUnique);
	}

	public void contextDestroyed(ServletContextEvent event) {
	}
}
