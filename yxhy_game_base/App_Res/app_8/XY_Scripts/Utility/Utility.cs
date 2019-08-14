using System;
using System.IO;
using System.Xml;
using System.Text;
using System.Net;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using System.Security.Cryptography;
using UnityEngine;
using cs;
using LuaInterface;

public static class UtilTool
{   
	public static int ConvertStructToBytes(object objStruct, byte[] buffer, int startIndex)
	{
		int size = Marshal.SizeOf(objStruct);
		IntPtr ipStruct = Marshal.AllocHGlobal(size);
		Marshal.StructureToPtr(objStruct, ipStruct, false);
		Marshal.Copy(ipStruct, buffer, startIndex, size);
		Marshal.FreeHGlobal(ipStruct);

		return size;
	}

	public static T ConvertBytesToStruct<T>(byte[] datas)
	{
        return ConvertBytesToStruct<T>(datas, 0);
	}

    public static T ConvertBytesToStruct<T>(byte[] datas, int offset)
    {
        int size = Marshal.SizeOf(typeof(T));

        if (datas.Length < size)
        {
            return default(T);
        }

        System.IntPtr ipSturct = Marshal.AllocHGlobal(size);
        Marshal.Copy(datas, offset, ipSturct, size);
        T objStruct = (T)Marshal.PtrToStructure(ipSturct, typeof(T));
        Marshal.FreeHGlobal(ipSturct);
        return objStruct;
    }

    public static List<int> Str2IntList(string str)
	{
        if (str == null || str == string.Empty)
        {
            return null;
        }

		string[] ss = str.Split(new char[]{','}, System.StringSplitOptions.RemoveEmptyEntries);
        List<int> ret = new List<int>(ss.Length);

        try
        {
            for (int i = 0; i < ss.Length; i++)
            {
                int n = int.Parse(ss[i]);
                ret.Add(n);
            }
        }
        catch (System.FormatException)
        {
            Debugger.LogError("String {0} parse to int list error", str);
        }

		return ret;
	}

    public static string IntList2str(List<int> list)
    {
        if (list.Count <= 0)
        {
            return string.Empty;
        }

        StringBuilder buffer = StringBuilderCache.Acquire();        

        for (int i = 0; i < list.Count - 1; i++)
        {
            buffer.Append(list[i]);
            buffer.Append(",");
        }

        buffer.Append(list[list.Count - 1]);
        return StringBuilderCache.GetStringAndRelease(buffer);
    }
	

    public static T DeSerializer<T>(string path, Encoding code)
    {
        using (TextReader reader = new StreamReader(path, code))
        {
            XmlSerializer serializer = new XmlSerializer(typeof(T));
            StringReader stringReader = new StringReader(reader.ReadToEnd());
            XmlTextReader xmlReader = new XmlTextReader(stringReader);
            T data = (T)serializer.Deserialize(xmlReader);
            xmlReader.Close();
            stringReader.Close();
            reader.Close();

            return data;
        }
    }

    public static T DeSerializer<T>(string path)
    {
        string str = UnGfx.LoadTextAsset(path);        
        XmlSerializer serializer = new XmlSerializer(typeof(T));
        StringReader stringReader = new StringReader(str);
        XmlTextReader xmlReader = new XmlTextReader(stringReader);
        T data = (T)serializer.Deserialize(xmlReader);
        xmlReader.Close();
        stringReader.Close();
        return data;
    }


    public static void Serializer<T>(T data, string path, Encoding code)
    {
        using (StringWriter sw = new StringWriter())
        {
            XmlSerializer serializer = new XmlSerializer(typeof(T));
            serializer.Serialize(sw, data);

            TextWriter textWriter = new StreamWriter(path, false, code);
            textWriter.Write(sw.ToString());
            textWriter.Flush();
            textWriter.Close();
        }
    }

    public static void Serializer<T>(T data, string path)
    {
        Serializer<T>(data, path, Encoding.UTF8);
    }
	
	public static long TimeStamp()
	{
		System.DateTime timeStamp = new System.DateTime(1970,1,1);
		long t = (System.DateTime.UtcNow.Ticks - timeStamp.Ticks) / 10000000;
		return t;
	}

    public static string BytesToHexString(byte[] src)
    {                
        StringBuilder buffer = StringBuilderCache.Acquire();        

        if (src == null || src.Length <= 0)
        {
            return null;
        }

        for (int i = 0; i < src.Length; i++)
        {
            int v = src[i] & 0xFF;
            buffer.Append(v.ToString("X2"));
        }

        return StringBuilderCache.GetStringAndRelease(buffer);
    }

    public static byte[] StringToBytes(string hexString)
    {
        hexString = hexString.Replace(" ", "");

        if ((hexString.Length % 2) != 0)
        {
            hexString += " ";
        }

        byte[] bs = new byte[hexString.Length / 2];

        for (int i = 0; i < bs.Length; i++)
        {
            bs[i] = System.Convert.ToByte(hexString.Substring(i * 2, 2), 16);
        }

        return bs;
    }

    public static bool IsConnection()
    {
#if DEVELOPER
        //内网
        FtpWebRequest ftp = (FtpWebRequest)FtpWebRequest.Create("http://www.baidu.com");
        ftp.Method = WebRequestMethods.Ftp.PrintWorkingDirectory;
        WebResponse ftpStream = null;

        try
        {
            ftpStream = ftp.GetResponse();
        }
        catch (Exception e)
        {
            Debugger.Log("check connect: " + e.ToString());
            ftpStream = null;
        }

        return ftpStream != null;
#else
        //外网
        WebRequest request = HttpWebRequest.Create("http://www.baidu.com");
        request.Method = "HEAD";
        WebResponse resp = null;

        try
        {
            resp = request.GetResponse();
        }
        catch
        {
            resp = null;
        }
        
        return resp != null;
#endif
    }

    public static string SplitFileName(string path)
    {
        int pos = path.LastIndexOf("/");

        if (pos <= 0)
        {
            pos = path.LastIndexOf("\\");
        }

        if (pos > 0 && pos + 1 < path.Length)
        {
            path = path.Substring(pos + 1);
        }

        return path;
    }

    public static string RemoveCloneString(string name)
    {
        int pos = name.IndexOf("(Clone)");

        if (pos > 0)
        {
            name = name.Substring(0, pos);
        }

        return name;
    }

    static MD5 md5Hash = MD5.Create();

    static string GetMd5Hash(string name)
    {                
        MD5 md5Hash = MD5.Create();
        Stream stream = File.Open(name, FileMode.Open, FileAccess.Read, FileShare.Read);
        byte[] data = md5Hash.ComputeHash(stream);        
        StringBuilder buffer = StringBuilderCache.Acquire();        
     
        for (int i = 0; i < data.Length; i++)
        {
            buffer.Append(data[i].ToString("x2"));
        }

        stream.Close();
        return StringBuilderCache.GetStringAndRelease(buffer);
    }    

    public static string CalcMD5Hash(string input)
    {
        byte[] data = Encoding.UTF8.GetBytes(input);
        byte[] hash = md5Hash.ComputeHash(data);

        return BitConverter.ToString(hash).Replace("-", "");
    }

    public static byte[] CalcMD5HashAsBytes(string input)
    {
        byte[] data = Encoding.UTF8.GetBytes(input);
        byte[] hash = md5Hash.ComputeHash(data);

        return hash;
    }

    //string ReadBinaryFile(string name)
    //{
    //    using (FileStream fs = new FileStream(name, FileMode.Open, FileAccess.Read))
    //    {
    //        BinaryReader br = new BinaryReader(fs);
            
    //    }
    //}

    public static string SubString(string str, char c)
    {        
        int pos = str.IndexOf(c);
        return pos > 0 ? str.Substring(0, pos) : str;
    }

    public static void Vector3ToTriple( Vector3 pos,Triple triPos)
    {
        if (triPos == null)
            return;
        triPos.x = (int)(pos.x * 100);
        triPos.y = (int)(pos.y * 100);
        triPos.z = (int)(pos.z * 100);
    }

    public static Vector3 LstInt2Vector3(List<int> pos)
    {
        if (pos.Count == 3)
        {
            return new Vector3(pos[0] * 0.01f,pos[1] * 0.01f,pos[2] * 0.01f);
        }
        return Vector3.zero;
    }

    public static Vector3 TripleToVector3(Triple triPos) 
    {
        if (triPos == null)
            return Vector3.zero;
        return new Vector3(triPos.x * 0.01f, triPos.y * 0.01f, triPos.z * 0.01f);
    }

    //拉位与，bit ：第几位
    public static bool IsBitMask(ulong val,int bit)
    {
        ulong tmp = (ulong)(1 << bit);
        return (val & tmp) > 0;
    }

    //计算两个点的平面距离(服务器不计算y值，所以最好保持一样)
    public static float Dist(Vector3 src,Vector3 dst)
    {
        src.y = 0.0f;
        dst.y = 0.0f;
        return Vector3.Distance(src, dst);
    }

    public static float GetSqrDistNoYAxis(Vector3 src, Vector3 dst) 
    {
        return (src.x - dst.x) * (src.x - dst.x) +  (src.z - dst.z) * (src.z - dst.z); 
    }

    //NavMesh 位置采样距离
    public static float SampleDistance = float.MaxValue;

    public static Vector3 VECTOR3_NAN = new Vector3(float.NaN, float.NaN, float.NaN);
    public static bool CheckVector3NAN(Vector3 v3)
    {
        return v3.Equals(VECTOR3_NAN);
    }
}