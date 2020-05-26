package jp.pipa.poipiku;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

public class COrder {
    public static final Map<String, Integer> Status;
    static {
        Map<String, Integer> map = new LinkedHashMap<>();
        map.put("Init", 0);
        map.put("Paid", 20);
        map.put("PaymentError", -10);
        Status = Collections.unmodifiableMap(map);
    }
}
