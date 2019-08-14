/********************************************************************
	created:	2017/05/27  10:11
	file base:	ProtobufDataConfigMgr
	file ext:	cs
	author:		shine	
	purpose:	用来得到配置文件反序列化后的protobuf对象。
                不保存配置数据，只提供配置数据解释方法，
                每个业务模块负责存储自己的配置数据,示例用法如下：
                
                // 配置文件名
                string configFileName = "dataconfig_activity_center_conf";
                
                // 相应的protobuf对象
                ACTIVITY_CENTER_CONF_ARRAY configArray;
                configArray = ProtobufDataConfigMgr.ReadOneDataConfig<ACTIVITY_CENTER_CONF_ARRAY>(configFileName);
                
                // 挨个读取每行的数据，这里只打印其中的一列值
                for (int i = 0; i < configArray.items.Count; ++i)
                {
                    Debug.Log("i: " + i + ", description: " + configArray.items[i].description);
                }
*********************************************************************/

using dataconfig;
using ProtoBuf;
using System.IO;
using UnityEngine;
using System;
using System.Collections.Generic;
using System.Collections;
using LuaInterface;
using XYHY;

namespace ProtobufDataConfig
{
    public class ProtobufDataConfigMgr
    {
        private static Dictionary<string, Byte[]> ms_dataStreamDict = new Dictionary<string, Byte[]>();

        public static void Clear()
        {
            ms_dataStreamDict.Clear();
        }

        static Dictionary<string, int> s_dr = new Dictionary<string, int>();
        static Dictionary<string, int> s_drlua = new Dictionary<string, int>();
        static Dictionary<string, int> s_drAll = new Dictionary<string, int>();

        /// <summary>
        /// 各个系统通过传入配置文件名得到Protobuf类型的对象
        /// </summary>
        /// <typeparam name="T">protobuf类型</typeparam>
        /// <param name="FileName">配置文件名</param>
        /// <returns>Protobuf类型的对象</returns>
        public static T ReadOneDataConfig<T>(string FileName,bool bRemain = false)
        {
            byte[] bytesData = null;
            if (!ms_dataStreamDict.ContainsKey(FileName))
            {
                bytesData = GetDataStream(FileName);
                if (bRemain)
                    ms_dataStreamDict.Add(FileName, bytesData);
            }
            else 
            {
                bytesData = ms_dataStreamDict[FileName];
            }
            
            if (!s_dr.ContainsKey(FileName))
            {
                s_dr[FileName] = 0;
            }

            s_dr[FileName] += 1;

            if (!s_drAll.ContainsKey(FileName))
            {
                s_drAll[FileName] = 0;
            }

            s_drAll[FileName] += 1;

            if (s_dr[FileName] > 1)
            {
                int tmp = 0;
                tmp++;
            }

            Stream stream = new MemoryStream(bytesData);

            T t = default(T);
            try
            {
                t = ReadOneDataConfig<T>(stream);
            }
            catch (System.Exception ex)
            {
                Debugger.LogError("反序列化失败, 请检查数据和解析类的一致性：" + FileName + ex.ToString());
            }

            stream.Close();

            return t;
        }

        public static void PreReadByteForLua(string FileName) 
        {
            if (!ms_dataStreamDict.ContainsKey(FileName))
            {
                ms_dataStreamDict.Add(FileName, GetDataStream(FileName));
            }
        }

        /// <summary>
        /// 从lua层读取一个配置文件
        /// </summary>
        /// <param name="fileName"></param>
        public static LuaByteBuffer ReadOneDataConfigForLua(string FileName)
        {
            byte[] bytesData = null;
            if (ms_dataStreamDict.ContainsKey(FileName))
            {
                bytesData = ms_dataStreamDict[FileName];
                // ms_dataStreamDict.Add(FileName, bytesData);
            }
            else
            {
                bytesData = GetDataStream(FileName);
            }

            if (!s_drlua.ContainsKey(FileName))
            {
                s_drlua[FileName] = 0;
            }

            s_drlua[FileName] += 1;

            if (!s_drAll.ContainsKey(FileName))
            {
                s_drAll[FileName] = 0;
            }

            s_drAll[FileName] += 1;
//            Stream stream = new MemoryStream(ms_dataStreamDict[FileName]);
            //Stream stream = new MemoryStream(bytesData);
            
            //MemoryStream memoryStream = stream as MemoryStream;
            //return new LuaByteBuffer(memoryStream.ToArray());
            return new LuaByteBuffer(bytesData);        
        }

        /// <summary>
        /// 根据数据流得到protobuf对象
        /// </summary>
        private static T ReadOneDataConfig<T>(Stream stream)
        {
            if (null != stream)
            {
                T t = Serializer.Deserialize<T>(stream);           
                return t;
            }

            return default(T);
        }

        /// <summary>
        /// 从Resources中读取数据
        /// </summary>
        private static byte[] ReadFromResources(string fileName)
        {
            IResourceMgr resourceMgr = Framework.GameKernel.GetResourceMgr();
            byte[] streamBytes = resourceMgr.LoadConfigFile("ProtobufDataConfig/" + fileName, "bytes");
            
            //byte[] streamBytes = null;
            //string filePath = "ProtobufDataConfig/" + fileName;
            //string fileUrl = string.Format("{0}{1}.bytes", BundleConfig.Instance.BundlesPathForPersist, filePath);
            //if (!File.Exists(fileUrl))
            //{
            //    TextAsset asset = Resources.Load<TextAsset>(filePath);
            //    if (asset != null)
            //    {
            //        streamBytes = asset.bytes;
            //    }
            //}
            //else
            //{
            //    using (FileStream fs = new FileStream(fileUrl, FileMode.Open))
            //    {
            //        BinaryReader br = new BinaryReader(fs);
            //        streamBytes = br.ReadBytes((int)fs.Length);
            //    }
            //}
            
            return streamBytes;
        }
        
        /// <summary>
        /// 根据文件名得到数据流
        /// </summary>
        private static Byte[] GetDataStream(string fileName)
        {
            //string filePath = "/ProtobufDataConfig/" + fileName;
            //string bytesFileName = filePath + ".bytes";
            //string path;
            byte[] streamBytes = null;

            streamBytes = ReadFromResources(fileName);

            //if (Const.DebugMode)
            //{
            //    streamBytes = ReadFromResources(fileName);
            //}
            //else
            //{
            //    bool existFlag = File.Exists(Util.DataPath + bytesFileName);
            //    if (existFlag)
            //    {
            //        path = Util.DataPath + bytesFileName;
            //        streamBytes = File.ReadAllBytes(path);
            //    }
            //    else
            //    {
            //        streamBytes = ReadFromResources(fileName);
            //    }
            //}

            return streamBytes;
        }
    }
}
