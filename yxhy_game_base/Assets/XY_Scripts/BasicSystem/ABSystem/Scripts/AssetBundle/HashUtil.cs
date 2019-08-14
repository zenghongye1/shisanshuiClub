using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Collections.Generic;

namespace XYHY.ABSystem
{
    public class HashUtil
    {
        static Dictionary<string, string> _nameToHashMap = new Dictionary<string, string>();
        public static string Get(Stream fs)
        {
            HashAlgorithm ha = HashAlgorithm.Create();
            byte[] bytes = ha.ComputeHash(fs);
            fs.Close();
            return ToHexString(bytes);
        }

        public static string Get(string s)
        {
            if (_nameToHashMap.ContainsKey(s))
                return _nameToHashMap[s];

            var hash = Get(Encoding.UTF8.GetBytes(s));
            _nameToHashMap[s] = hash;
            return hash;
        }

        public static string Get(byte[] data)
        {
            HashAlgorithm ha = HashAlgorithm.Create();
            byte[] bytes = ha.ComputeHash(data);
            return ToHexString(bytes);
        }

        public static string ToHexString(byte[] bytes)
        {
            string hexString = string.Empty;
            if (bytes != null)
            {
                StringBuilder strB = new StringBuilder();

                for (int i = 0; i < bytes.Length; i++)
                {
                    strB.Append(bytes[i].ToString("X2"));
                }
                hexString = strB.ToString().ToLower();
            }
            return hexString;
        }
    }
}
