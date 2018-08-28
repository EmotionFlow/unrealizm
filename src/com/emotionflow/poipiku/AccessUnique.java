package com.emotionflow.poipiku;

import java.util.concurrent.ConcurrentHashMap;

import com.emotionflow.poipiku.util.Log;

public class AccessUnique {
	private ConcurrentHashMap<String, Long> m_mapAccess = new ConcurrentHashMap<String, Long>();

	public boolean isUnique(int nIllustId, int nIpAddress) {
		String key = String.format("%d_%d", nIllustId, nIpAddress);
		try {
			Long value = m_mapAccess.get(key);
			Long timeNow = java.lang.System.currentTimeMillis();

			if((value != null) && (value >= timeNow-24*60*60*1000) && (nIpAddress != -880123161) && (nIpAddress != -613038627)) {
				return false;
			}

			m_mapAccess.put(key, timeNow);
		} catch (Exception e) {
			Log.d(e.getMessage());
		}
		return true;
	}

}
