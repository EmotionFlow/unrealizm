package jp.pipa.poipiku;

import java.util.concurrent.ConcurrentHashMap;

public class AccessUnique {
	private ConcurrentHashMap<String, Long> m_mapAccess = new ConcurrentHashMap<String, Long>();

	private AccessUnique() {}
	public static AccessUnique getInstance() {
		return InstanceHolder.INSTANCE;
	}

	public void init(){
	}

	public static class InstanceHolder {
		private static final AccessUnique INSTANCE = new AccessUnique();
	}

	public boolean isUnique(int id, int idAddress) {
		String key = String.format("%d_%d", id, idAddress);
		try {
			Long value = m_mapAccess.get(key);
			Long timeNow = java.lang.System.currentTimeMillis();

			if((value != null) && (value >= timeNow-24*60*60*1000) && (idAddress != -880123161) && (idAddress != -613038627)) {
				return false;
			}
			m_mapAccess.putIfAbsent(key, timeNow);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return true;
	}

}
