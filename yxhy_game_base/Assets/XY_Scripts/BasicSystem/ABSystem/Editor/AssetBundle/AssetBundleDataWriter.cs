using System.Collections.Generic;
using System.IO;

namespace XYHY.ABSystem
{
    public class AssetBundleDataWriter
    {
        public void Save(string path, AssetTarget[] targets)
        {
            //先删除旧的依赖文件
            if(File.Exists(path))
            {
                File.Delete(path);
            }
            FileStream fs = new FileStream(path, FileMode.CreateNew);
            Save(fs, targets);
        }

        public virtual void Save(Stream stream, AssetTarget[] targets)
        {
            StreamWriter sw = new StreamWriter(stream);
            //写入文件头判断文件类型用，ABDT 意思即 Asset-Bundle-Data-Text
            sw.WriteLine("ABDT");

            for (int i = 0; i < targets.Length; i++)
            {
                AssetTarget target = targets[i];
                HashSet<AssetTarget> deps = new HashSet<AssetTarget>();
                target.GetDependencies(deps);

                //debug name
                //lua 和 protobuf  大小写不变
                if (!target.assetPath.Contains("Lua") && !target.assetPath.Contains("ProtobufDataConfig")) 
                    sw.WriteLine(target.assetPath.ToLower());
                else
                    sw.WriteLine(target.assetPath);
                //bundle name
                sw.WriteLine(target.bundleName);
                //File Name
                sw.WriteLine(target.bundleShortName);
                //belong Name
                sw.WriteLine(target.belongName);
                //hash
                sw.WriteLine(target.bundleCrc);
                //type
                sw.WriteLine((int)target.compositeType);
                //写入依赖信息
                sw.WriteLine(deps.Count);

                foreach (AssetTarget item in deps)
                {
                    sw.WriteLine(item.bundleName);
                }

                sw.WriteLine(target.file.Length);
                sw.WriteLine("<-------------------------------------------->");
            }
            sw.Close();
        }
    }
}