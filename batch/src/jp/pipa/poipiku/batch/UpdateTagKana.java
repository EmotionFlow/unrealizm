package jp.pipa.poipiku.batch;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.List;

import com.atilika.kuromoji.ipadic.neologd.Token;
import com.atilika.kuromoji.ipadic.neologd.Tokenizer;
import jp.pipa.poipiku.util.Util;

public class UpdateTagKana extends Batch {
	public static void main(String[] args) {
		int nCountNum = 0;
		int nCountEndNum = 0;

		String sql;

		sql = "SELECT COUNT(*) FROM tags_0000 WHERE tag_kana_txt IS NULL";

		try (
				Connection connection = dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql)) {
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				nCountNum = resultSet.getInt(1);
			}
			System.out.println("m_nCountNum:" + nCountNum);
		} catch (Exception e) {
			System.out.println(sql);
			e.printStackTrace();
		}

		CTag cTag = null;
		for (int i = 0; i < 10000; i++) {
			//CContent
			cTag = null;
			sql = "SELECT COUNT(*), tag_txt FROM tags_0000 WHERE tag_kana_txt IS NULL GROUP BY tag_txt ORDER BY COUNT(*) DESC LIMIT 1";
			try (
					Connection connection = dataSource.getConnection();
					PreparedStatement statement = connection.prepareStatement(sql)) {
				ResultSet resultSet = statement.executeQuery();
				if (resultSet.next()) {
					cTag = new CTag();
					cTag.m_nTagId = resultSet.getInt(1);
					cTag.m_strTagTxt = Util.toString(resultSet.getString("tag_txt"));
				}
			} catch (Exception e) {
				System.out.println(sql);
				e.printStackTrace();
				continue;
			}

			if (cTag == null) break;
			if (cTag.m_nTagId <= 0) break;

			// Update Kana
			sql = "UPDATE tags_0000 SET tag_kana_txt=? WHERE tag_txt=? AND tag_kana_txt IS NULL;";
			try (
					Connection connection = dataSource.getConnection();
					PreparedStatement statement = connection.prepareStatement(sql)) {

				String strKana = getKana(cTag.m_strTagTxt);
				statement.setString(1, strKana);
				statement.setString(2, cTag.m_strTagTxt);
				statement.executeUpdate();
				System.out.println("i:" + (i + 1));
				System.out.println("cTag.m_strTagTxt:" + cTag.m_strTagTxt + ":" + strKana + " : " + cTag.m_nTagId);
			} catch (Exception e) {
				e.printStackTrace();
			}

			try {
				Thread.sleep(100);
			} catch (InterruptedException ex) {
				ex.printStackTrace();
			}
		}

		// Get count
		sql = "SELECT COUNT(*) FROM tags_0000 WHERE tag_kana_txt IS NULL";
		try (
				Connection connection = dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql)) {

			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				nCountEndNum = resultSet.getInt(1);
			}
			System.out.println("nCountEndNum:" + nCountEndNum);
		} catch (Exception e) {
			System.out.println(sql);
			e.printStackTrace();
		}
		System.out.println("end");
	}

	public static String getKana(String strTxt) {
		if (strTxt.trim().isEmpty()) return "";
		StringBuilder sbRet = new StringBuilder();
		try {
			Tokenizer tokenizer = new Tokenizer();
			List<Token> tokens = tokenizer.tokenize(strTxt.trim());
			for (Token token : tokens) {
				sbRet.append(token.getReading());
			}
		} catch (Exception ignored) {
			;
		}
		boolean bConvert = false;
		for (int i = 0; i < sbRet.length(); i++) {
			if (sbRet.charAt(i) != '*') {
				bConvert = true;
				break;
			}
		}
		return (bConvert) ? sbRet.toString() : "";
	}


	static class CTag {
		public int m_nTagId = -1;
		public String m_strTagTxt = "";
	}

}
