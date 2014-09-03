Windows Phone Client-Side-Encryption
==============
This code sample shows how you can integrate Adyen Client-Side-Encryption on the Windows Phone platform.

## Compatibility
The AdyenCSE project is a Windows Phone Silverlight application that targets Windows Phone 8.0. Due to backwards compatibility, Windows Phone 8.1 is also supported.

## Used libraries

- https://www.nuget.org/packages/Newtonsoft.Json/
- https://www.nuget.org/packages/Portable.BouncyCastle/
- https://www.nuget.org/packages/Microsoft.Net.Http/ (only for the HTTP Post request)

Include these libraries in your Windows Phone project, e.g. using the NuGet Package Manager in Visual Studio.

## Example usage (C#)
```
// Fill in your public key from the Adyen CA backend
string publicKey = "10001|80C7821C961865FB4AD23F172E220F819A5CC7B9956BC3458E2788"
                 + ...
                 + "5F024B3294A933F4DC514DE0B5686F6C2A6A2D";
Encrypter cse = new Encrypter(publicKey);

Card card = new Card();
card.CardNumber = "4111111111111111";
card.HolderName = "John Doe";
card.ExpirationMonth = "06";
card.ExpirationYear = "2016";
card.CVC = "737";

string encryptedCard = cse.Encrypt(card.ToString());

// Include the encrypted card in the additionalData.card.encrypted.json field of the PaymentRequest
```