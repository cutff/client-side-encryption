using AdyenCSE.Encryption;
using Microsoft.Phone.Controls;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net;
using System.Net.Http;
using System.Windows;

namespace AdyenCSE
{
    public partial class MainPage : PhoneApplicationPage
    {
        public MainPage()
        {
            InitializeComponent();
        }

        private async void SubmitButton_Click(object sender, RoutedEventArgs e)
        {
            // Initialize Client-Side-Encryption (with the public key from Adyen CA)
            string publicKey = "YourPublicKey";
            Encrypter cse = new Encrypter(publicKey);

            // Create card object
            Card card = new Card();
            card.CardNumber = CardNumber.Text;
            card.HolderName = HolderName.Text;
            card.ExpirationMonth = ExpirationMonth.Text;
            card.ExpirationYear = ExpirationYear.Text;
            card.CVC = CVC.Text;

            // Apply Client-Side-Encryption to the card data
            string encryptedCard = cse.Encrypt(card.ToString());
            Debug.WriteLine(encryptedCard);

            // Send payment request with encrypted card data (using HTTP Post)
            var httpClientHandler = new HttpClientHandler();
            httpClientHandler.Credentials = new NetworkCredential("YourWSUser", "YourWSPassword");
            var httpClient = new HttpClient(httpClientHandler);

            var values = new List<KeyValuePair<string, string>>
            {
                new KeyValuePair<string, string>("action", "Payment.authorise"),
                new KeyValuePair<string, string>("paymentRequest.merchantAccount", "YourMerchantAccount"),
                new KeyValuePair<string, string>("paymentRequest.reference", "TEST-PAYMENT-WindowsPhone-" + DateTime.Now.ToString("yyyy-MM-dd-HH:mm:ss")),
                new KeyValuePair<string, string>("paymentRequest.amount.currency", "EUR"),
                new KeyValuePair<string, string>("paymentRequest.amount.value", "1000"),
                new KeyValuePair<string, string>("paymentRequest.additionalData.card.encrypted.json", encryptedCard),
            };

            HttpResponseMessage response = await httpClient.PostAsync("https://pal-test.adyen.com/pal/adapter/httppost", new FormUrlEncodedContent(values));
            response.EnsureSuccessStatusCode();
            var responseString = await response.Content.ReadAsStringAsync();

            // Show payment result
            MessageBox.Show(responseString, "Payment result", MessageBoxButton.OK);
        }
    }
}