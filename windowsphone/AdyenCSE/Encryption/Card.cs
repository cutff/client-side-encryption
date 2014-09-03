using Newtonsoft.Json;

namespace AdyenCSE.Encryption
{
    public class Card
    {
        public string CardNumber { get; set; }
        public string HolderName { get; set; }
        public string ExpirationMonth { get; set; }
        public string ExpirationYear { get; set; }
        public string CVC { get; set; }
        private string GenerationTime { get; set; }

        public override string ToString()
        {
            return JsonConvert.SerializeObject(new
            {
                generationtime = System.DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
                number = this.CardNumber,
                holderName = this.HolderName,
                cvc = this.CVC,
                expiryMonth = this.ExpirationMonth,
                expiryYear = this.ExpirationYear
            });
        }
    }
}
