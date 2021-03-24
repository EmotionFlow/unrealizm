package jp.pipa.poipiku;

import java.util.Arrays;

public interface CodeEnum<E extends Enum<E>> {
	int getCode();

	@SuppressWarnings("unchecked")
	default E toEnum() {
		return (E) this;
	}

	default boolean equalsByCode(int code) {
		return getCode() == code;
	}

	static <E extends Enum<E>> E getEnum(Class<? extends CodeEnum<E>> clazz, int code) {
		return Arrays.stream(clazz.getEnumConstants())
				.filter(e -> e.equalsByCode(code))
				.map(CodeEnum::toEnum)
				.findFirst()
				.orElse(null);
	}
}

/* 適用例
public enum CheerPointStatus implements CodeEnum<CheerPointStatus> {
    BeforeDistribute(0),     // 分配前
    Distributing(1),        // 分配中
    Distributed(2),         // 分配済
    NotApplicable(-1);	    // 対象外

    static public CheerPointStatus byCode(int _code) {
        return CodeEnum.getEnum(CheerPointStatus.class, _code);
    }

    @Override
    public int getCode() {
        return code;
    }

    private final int code;
    private CheerPointStatus(int code) {
        this.code = code;
    }
}
 */