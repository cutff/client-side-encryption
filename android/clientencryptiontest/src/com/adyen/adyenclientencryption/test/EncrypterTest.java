package com.adyen.adyenclientencryption.test;

import java.util.Date;

import junit.framework.TestCase;


import android.util.Log;

import com.adyen.clientencryption.Card;
import com.adyen.clientencryption.Encrypter;
import com.adyen.clientencryption.EncrypterException;

public class EncrypterTest extends TestCase {
	String tag = this.getClass().getName();

	String pubKey = "10001|80C7821C961865FB4AD23F172E220F819A5CC7B9956BC3458E2788"
			 + "F9D725B07536E297B89243081916AAF29E26B7624453FC84CB10FC7DF386"
			 + "31B3FA0C2C01765D884B0DA90145FCE217335BCDCE4771E30E6E5630E797"
			 + "EE289D3A712F93C676994D2746CBCD0BEDD6D29618AF45FA6230C1D41FE1"
			 + "DB0193B8FA6613F1BD145EA339DAC449603096A40DC4BF8FACD84A5D2CA5"
			 + "ECFC59B90B928F31715A7034E7B674E221F1EB1D696CC8B734DF7DE2E309"
			 + "E6E8CF94156686558522629E8AF59620CBDE58327E9D84F29965E4CD0FAF"
			 + "A38C632B244287EA1F7F70DAA445D81C216D3286B09205F6650262CAB415"
			 + "5F024B3294A933F4DC514DE0B5686F6C2A6A2D";
	
	public void testEncrypt() {
		
		Card card = new Card.Builder(new Date())
		.number("5555444433331111")
		.cvc("737")
		.expiryMonth("06")
		.expiryYear("2016")
		.holderName("John Doe")
		.build();
		
		Encrypter enc;
		try {
			enc = new Encrypter(pubKey);
			Log.i(tag,enc.encrypt(card.toString()));
		} catch (EncrypterException e) {
			Log.w(tag,e.getMessage(), e.getCause());
		}
	}
}
