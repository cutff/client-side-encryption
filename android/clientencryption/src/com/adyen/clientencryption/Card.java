package com.adyen.clientencryption;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.json.JSONException;
import org.json.JSONObject;

public class Card {

	private String number;
	private String holderName;
	private String cvc;
	private String expiryMonth;
	private String expiryYear;
	private Date   generationtime;


	public static class Builder {
		//required
		private final Date generationtime;

		//optional
		private String number;
		private String holderName;
		private String cvc;
		private String expiryMonth;
		private String expiryYear;


		public Builder(Date generationtime) {
			this.generationtime = generationtime;
		}

		public Builder number(String value) {
			number = value;
			return this;
		}
		public Builder holderName(String value) {
			holderName = value;
			return this;
		}
		public Builder cvc(String value) {
			cvc = value;
			return this;
		}
		public Builder expiryMonth(String value) {
			expiryMonth = value;
			return this;
		}
		public Builder expiryYear(String value) {
			expiryYear = value;
			return this;
		}

		public Card build() {
			return new Card(this);
		}
	}

	private Card (Builder builder) {
		generationtime 	= builder.generationtime;
		number 			= builder.number;
		holderName 		= builder.holderName;
		cvc 			= builder.cvc;
		expiryMonth		= builder.expiryMonth;
		expiryYear 		= builder.expiryYear;	
	}

	@Override
	public String toString() {
		
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
	
		JSONObject obj = new JSONObject();
		try {
			obj.put("generationtime", 	df.format(generationtime));
			obj.put("number", 			number);
			obj.put("holderName", 		holderName);
			obj.put("cvc", 				cvc);
			obj.put("expiryMonth", 		expiryMonth);
			obj.put("expiryYear", 		expiryYear);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return obj.toString();
	}
}
