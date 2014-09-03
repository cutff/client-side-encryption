using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Engines;
using Org.BouncyCastle.Crypto.Modes;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.Security;

namespace AdyenCSE.Encryption
{
    public class Encrypter
    {
        public const string Prefix = "adyenc#";
        public const string Version= "0_1_0";
        public const string Separator = "$";

        private string publicKey;

        private CcmBlockCipher aesCipher;
        private IBufferedCipher rsaCipher;

        public Encrypter(string publicKey)
        {
            this.publicKey = publicKey;
            InitializeRSA();
        }

        private void InitializeRSA()
        {
            string[] keyComponents = publicKey.Split('|');
            var modulus = new Org.BouncyCastle.Math.BigInteger(keyComponents[1].ToLower(), 16);
            var exponent = new Org.BouncyCastle.Math.BigInteger(keyComponents[0].ToLower(), 16);
            RsaKeyParameters keyParams = new RsaKeyParameters(false, modulus, exponent);

            rsaCipher = CipherUtilities.GetCipher("RSA/None/PKCS1Padding");
            rsaCipher.Init(true, keyParams);
        }

        public string Encrypt(string data)
        {
            SecureRandom random = new SecureRandom();

            // Generate 256-bits AES key
            byte[] aesKey = new byte[32];
            random.NextBytes(aesKey);

            // Generate Initialization Vector
            byte[] IV = new byte[12];
            random.NextBytes(IV);

            // Apply RSA/None/PKCS1Padding encryption to the AES key
            byte[] encyptedAESKey = rsaCipher.DoFinal(aesKey);

            // Apply AES/CCM/NoPadding encryption to the data
            byte[] cipherText = System.Text.Encoding.UTF8.GetBytes(data);

            var ccmParameters = new CcmParameters(new KeyParameter(aesKey), 64, IV, new byte[] { });
            aesCipher = new CcmBlockCipher(new AesFastEngine());
            aesCipher.Init(true, ccmParameters);

            var encrypted = new byte[aesCipher.GetOutputSize(cipherText.Length)];
            var res = aesCipher.ProcessBytes(cipherText, 0, cipherText.Length, encrypted, 0);
            aesCipher.DoFinal(encrypted, res);

            // Merge 'IV' and 'encrypted' to 'result'
            byte[] result = new byte[IV.Length + encrypted.Length];
            System.Buffer.BlockCopy(IV, 0, result, 0, IV.Length);
            System.Buffer.BlockCopy(encrypted, 0, result, IV.Length, encrypted.Length);

            // Return encrypted data
            return Prefix + Version + Separator + System.Convert.ToBase64String(encyptedAESKey) + Separator + System.Convert.ToBase64String(result);
        }
    }
}
