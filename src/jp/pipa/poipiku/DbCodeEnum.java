package jp.pipa.poipiku;

import java.util.Arrays;

public interface DbCodeEnum<E extends Enum<E>> {
	int getCode();

	@SuppressWarnings("unchecked")
	default E toEnum() {
		return (E) this;
	}

	default boolean equalsByCode(int code) {
		return getCode() == code;
	}

	static <E extends Enum<E>> E getEnum(Class<? extends DbCodeEnum<E>> clazz, int code) {
		return Arrays.stream(clazz.getEnumConstants())
				.filter(e -> e.equalsByCode(code))
				.map(DbCodeEnum::toEnum)
				.findFirst()
				.orElse(null);
	}
}
