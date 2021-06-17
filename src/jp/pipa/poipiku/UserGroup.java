package jp.pipa.poipiku;

import java.util.ArrayList;
import java.util.List;

public final class UserGroup {
	public int id;
	public List<Integer> userIds = new ArrayList<>();

	public UserGroup(int userId) {

	}

	public boolean select(int userId) {
		return false;
	}

	public boolean add(int addId){
		return false;
	}

	public boolean remove(int userId){
		return false;
	}
}
