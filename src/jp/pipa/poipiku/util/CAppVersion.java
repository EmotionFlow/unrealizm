package jp.pipa.poipiku.util;

import jp.pipa.poipiku.Common;

import javax.servlet.http.Cookie;

public class CAppVersion {
    enum OS {
        UNKNOWN, ANDROID, IOS
    }

    private final String COOKIE_NAME = "APPVER";
    public Integer m_nNum = null;
    public Integer m_nVerPart = null;

    public CAppVersion() {
    }

    public CAppVersion(int nVersion) {
        m_nNum = nVersion;
    }

    public CAppVersion(Cookie cCookies[]) {
        if (cCookies != null) {
            for (Cookie c : cCookies) {
                if (c.getName().equals(COOKIE_NAME)) {
                    m_nNum = Common.ToInt(c.getValue());
                    m_nVerPart = m_nNum % 100;
                }
            }
        }
    }

    public boolean isValid(){
        return m_nNum != null;
    }

    public OS getOS() {
        if (100 <= m_nNum && m_nNum <= 199) {
            return OS.IOS;
        }
        if (200 <= m_nNum && m_nNum <= 299) {
            return OS.ANDROID;
        }
        return OS.UNKNOWN;
    }

    public boolean isAndroid() {
        return getOS() == OS.ANDROID;
    }

    public boolean isIOS() {
        return getOS() == OS.IOS;
    }

}
