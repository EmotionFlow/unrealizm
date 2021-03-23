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
