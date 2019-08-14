using UnityEngine;
using System.Collections;
using System.Security.Cryptography;

public class UrlUtil
{

	/// <summary>
	/// 资源路径通过MD5方式变为文件名.
	/// </summary>
	/// <returns>The file name.</returns>
	/// <param name="assetpath">Assetpath.</param>
    static public string parseAssetPathToBundleName(string assetpath)
    {

        string filename = "";
        if (assetpath.Contains("Resources"))
        {
            string[] filenames = assetpath.Split('.');
            filename = filenames[0];
        }
        else
        {
            filename = assetpath;
        }

        MD5 md5 = MD5.Create();

        byte[] input = System.Text.Encoding.Default.GetBytes(filename);

        byte[] bMd5 = md5.ComputeHash(input);

        md5.Clear();

        string str = "";

        for (int i = 0; i < bMd5.Length; i++)
        {
            str += bMd5[i].ToString("x").PadLeft(2, '0');
        }

        //Debug.Log (filenames [0] + ":" + str);

        return str;
    }

    static public string parseSceneNameToBundleName(string sceneName)
    {
        MD5 md5 = MD5.Create();

        byte[] input = System.Text.Encoding.Default.GetBytes(sceneName);

        byte[] bMd5 = md5.ComputeHash(input);

        md5.Clear();

        string str = "";

        for (int i = 0; i < bMd5.Length; i++)
        {
            str += bMd5[i].ToString("x").PadLeft(2, '0');
        }

        return str;
    }
}
