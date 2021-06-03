package jp.pipa.poipiku;

public class RecommendedUser {
	public int userId = -1;
	public String nickname = "";
	public String profile = "";
	public Integer requestCreatorStatus = null;

	public String getNickname() {
		return nickname;
	}

	public int getUserId() {
		return userId;
	}

	public String getProfile() {
		if (profile.isEmpty()) return "";
		String[] lines = profile.split("\n");
		String line = lines[0];
		if (lines.length > 1) {
			line += " " + lines[1];
		}
		return line;
	}

	public int getRequestCreatorStatus() {
		return requestCreatorStatus;
	}
}
