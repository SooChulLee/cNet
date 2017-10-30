package com.cnet.crec.util;

import java.util.Iterator;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

public class TestJson {
	@SuppressWarnings("unchecked")
	public static void main(String[] args) throws Exception {
		JSONObject obj = new JSONObject();
		obj.put("학교", "서울대");
		obj.put("학년", "1");
		JSONArray arr = new JSONArray();
		JSONObject obj1 = new JSONObject();
		obj1.put("이름", "홍길동");
		obj1.put("나이", "18");
		JSONObject obj2 = new JSONObject();
		obj2.put("이름", "춘향이");
		obj2.put("나이", "18");
		arr.add(obj1);
		arr.add(obj2);
		obj.put("학생", arr);
		System.out.println(obj.toString());
		System.out.println(arr.toString());

		String str = "[{\"date\":\"2011년 02월 15일 (화)\",\"locatename\":\"강남\"},{\"date\":\"2011년 02월 16일 (수)\",\"locatename\":\"신도림\"},{\"date\":\"2011년 02월 17일 (목)\",\"locatename\":\"목동\"},";
		str = str + "{\"date\":\"2011년 02월 18일 (금)\",\"locatename\":\"홍대\"},{\"date\":\"2011년 02월 19일 (토)\",\"locatename\":\"영등포구청\"},{\"date\":\"2011년 02월 21일 (월)\",\"locatename\":\"목동\"}]";

		String date = "";
		String locatename = "";
		// JSONObject jsonobj = (JSONObject)JSONValue.parse(string);
		// if(jsonobj instanceof JSONArray){

		//Object jsonobj = JSONValue.parseWithException(str);
		Object jsonobj = JSONValue.parse(str);
		JSONArray jsonArray = (JSONArray) jsonobj;
		JSONObject jsonObject = null;
		for (int i = 0; i < jsonArray.size(); i++) {
			System.out.println(i+" ================================");
			jsonObject = (JSONObject) jsonArray.get(i);
			Iterator<String> iter = jsonObject.keySet().iterator();
			while (iter.hasNext()) {
				String key = iter.next();
				System.out.println("key : " + key);
				System.out.println("value : " + (String) jsonObject.get(key));
			}
		}

	}
}
