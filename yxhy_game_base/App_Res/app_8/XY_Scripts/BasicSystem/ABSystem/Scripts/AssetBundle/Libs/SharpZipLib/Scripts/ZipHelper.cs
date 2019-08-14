using System;
using System.Collections.Generic;
using System.IO;
using ICSharpCode.SharpZipLib.Zip;
using ICSharpCode.SharpZipLib.Checksums;

/// <summary>  
/// 文件(夹)压缩、解压缩  
/// </summary>  
public class ZipHelper
{
    #region 压缩文件  
    /// <summary>    
    /// 压缩文件    
    /// </summary>    
    /// <param name="fileNames">要打包的文件列表</param>    
    /// <param name="GzipFileName">目标文件名</param>    
    /// <param name="CompressionLevel">压缩品质级别（0~9）</param>    
    /// <param name="deleteFile">是否删除原文件</param>  
    public static void CompressFile(List<FileInfo> fileNames, string GzipFileName, int CompressionLevel, bool deleteFile)
    {
        ZipOutputStream s = new ZipOutputStream(File.Create(GzipFileName));
        try
        {
            s.SetLevel(CompressionLevel);   //0 - store only to 9 - means best compression    
            foreach (FileInfo file in fileNames)
            {
                FileStream fs = null;
                try
                {
                    fs = file.Open(FileMode.Open, FileAccess.ReadWrite);
                }
                catch
                { continue; }
                //  方法二，将文件分批读入缓冲区    
                byte[] data = new byte[2048];
                int size = 2048;
                ZipEntry entry = new ZipEntry(Path.GetFileName(file.Name));
                entry.DateTime = (file.CreationTime > file.LastWriteTime ? file.LastWriteTime : file.CreationTime);
                s.PutNextEntry(entry);
                while (true)
                {
                    size = fs.Read(data, 0, size);
                    if (size <= 0) break;
                    s.Write(data, 0, size);
                }
                fs.Close();
                if (deleteFile)
                {
                    file.Delete();
                }
            }
        }
        finally
        {
            s.Finish();
            s.Close();
        }
    }
    /// <summary>    
    /// 压缩文件夹    
    /// </summary>    
    /// <param name="dirPath">要打包的文件夹</param>  
    /// <param name="fileInfos">要压缩的文件</param>   
    /// <param name="GzipFileName">目标文件名</param>    
    /// <param name="CompressionLevel">压缩品质级别（0~9）</param>    
    /// <param name="deleteDir">是否删除原文件夹</param>  
    public static void CompressDirectory(string dirPath, FileInfo[] fileInfos, string GzipFileName, int CompressionLevel, bool deleteDir)
    {
        dirPath = Directory.GetParent(dirPath).FullName.Replace("\\", "/");

        using (ZipOutputStream zipoutputstream = new ZipOutputStream(File.Create(GzipFileName)))
        {
            zipoutputstream.SetLevel(CompressionLevel);
            Crc32 crc = new Crc32();
            Dictionary<string, DateTime> fileList = null;
            if (fileInfos == null)
            {
                fileList = GetAllFies(dirPath);
            }
            else
            {
                fileList = new Dictionary<string, DateTime>();
                foreach (FileInfo item in fileInfos)
                {
                    fileList.Add(item.FullName.Replace("\\", "/"), item.LastWriteTime);
                }
            }

            long index = 0;
            foreach (KeyValuePair<string, DateTime> item in fileList)
            {
                FileStream fs = File.OpenRead(item.Key.ToString());
                byte[] buffer = new byte[fs.Length];
                fs.Read(buffer, 0, buffer.Length);

                ZipEntry entry = new ZipEntry(item.Key.Substring(dirPath.Length));
                entry.DateTime = item.Value;
                entry.Size = fs.Length;
                entry.ZipFileIndex = fileList.Count - index++;
                fs.Close();
                crc.Reset();
                crc.Update(buffer);
                entry.Crc = crc.Value;
                zipoutputstream.PutNextEntry(entry);
                zipoutputstream.Write(buffer, 0, buffer.Length);
            }
        }
        if (deleteDir)
        {
            Directory.Delete(dirPath, true);
        }
    }
    /// <summary>    
    /// 获取所有文件    
    /// </summary>    
    /// <returns></returns>    
    private static Dictionary<string, DateTime> GetAllFies(string dir)
    {
        Dictionary<string, DateTime> FilesList = new Dictionary<string, DateTime>();
        DirectoryInfo fileDire = new DirectoryInfo(dir);
        if (!fileDire.Exists)
        {
            throw new System.IO.FileNotFoundException("目录:" + fileDire.FullName + "没有找到!");
        }
        GetAllDirFiles(fileDire, FilesList);
        GetAllDirsFiles(fileDire.GetDirectories(), FilesList);
        return FilesList;
    }
    /// <summary>    
    /// 获取一个文件夹下的所有文件夹里的文件    
    /// </summary>    
    /// <param name="dirs"></param>    
    /// <param name="filesList"></param>    
    private static void GetAllDirsFiles(DirectoryInfo[] dirs, Dictionary<string, DateTime> filesList)
    {
        foreach (DirectoryInfo dir in dirs)
        {
            foreach (FileInfo file in dir.GetFiles("*.*"))
            {
                filesList.Add(file.FullName.Replace("\\", "/"), file.LastWriteTime);
            }
            GetAllDirsFiles(dir.GetDirectories(), filesList);
        }
    }
    /// <summary>    
    /// 获取一个文件夹下的文件    
    /// </summary>    
    /// <param name="dir">目录名称</param>    
    /// <param name="filesList">文件列表HastTable</param>    
    private static void GetAllDirFiles(DirectoryInfo dir, Dictionary<string, DateTime> filesList)
    {
        foreach (FileInfo file in dir.GetFiles("*.*"))
        {
            filesList.Add(file.FullName.Replace("\\", "/"), file.LastWriteTime);
        }
    }
    #endregion
    #region 解压缩文件  
    /// <summary>    
    /// 解压缩文件    
    /// </summary>    
    /// <param name="GzipFile">压缩包文件名</param>    
    /// <param name="targetPath">解压缩目标路径</param>           
    public static void Decompress(string GzipFile, string targetPath, ref ZipResult zipResult)
    {
        zipResult.Errors = false;
        try
        {
            UnityEngine.Debug.Log("开始解压");

            string directoryName = targetPath;
            if (!Directory.Exists(directoryName)) Directory.CreateDirectory(directoryName);//生成解压目录    
            string CurrentDirectory = directoryName;
            byte[] data = new byte[2048];
            int size = 2048;
            ZipEntry theEntry = null;
            
            ////long zipFileIndex = 0;
            using (ZipInputStream s = new ZipInputStream(File.OpenRead(GzipFile)))
            {
                while ((theEntry = s.GetNextEntry()) != null)
                {
                    ////if (zipResult.FileCount < theEntry.ZipFileIndex)
                    ////{
                    ////    zipResult.FileCount = theEntry.ZipFileIndex;
                    ////}
                    string dir = (CurrentDirectory + theEntry.Name).Replace("\\", "/");
                    string[] temp = dir.Split('/');
                    dir = dir.Replace(temp[temp.Length - 1], "");
                    DirectoryInfo di = new DirectoryInfo(dir);
                    if (!di.Exists)
                    {
                        di.Create();
                    }

                    if (theEntry.Name != String.Empty)
                    {
                        //  检查多级目录是否存在  
                        if (theEntry.Name.Contains("//"))
                        {
                            string parentDirPath = theEntry.Name.Remove(theEntry.Name.LastIndexOf("//") + 1);
                            if (!Directory.Exists(parentDirPath))
                            {
                                Directory.CreateDirectory(CurrentDirectory + parentDirPath);
                            }
                        }

                        //解压文件到指定的目录    
                        using (FileStream streamWriter = File.Create(CurrentDirectory + theEntry.Name))
                        {
                            while (true)
                            {
                                size = s.Read(data, 0, data.Length);
                                if (size <= 0) break;
                                streamWriter.Write(data, 0, size);
                            }
                            streamWriter.Close();
                        }

                        ////zipFileIndex++;
                        ////zipResult.UnZipPercent = 1f * zipFileIndex / zipResult.FileCount;
                        //UnityEngine.Debug.Log("--UnZipPercent-->" + zipResult.UnZipPercent);
                    }
                }
                s.Close();

                UnityEngine.Debug.Log("解压成功");
            }
        }
        catch(Exception ex)
        {
            zipResult.Errors = true;
            UnityEngine.Debug.LogError("解压失败：" + ex.ToString());
        }
    }
    #endregion
}

public class ZipResult
{
    /// <summary>
    /// 要压缩/解压的文件数
    /// </summary>
    public long FileCount = 0;

    /// <summary>
    /// 压缩百分比
    /// </summary>
    public int CompressionPercent = 0;
    /// <summary>
    /// 解压百分比
    /// </summary>
    public float UnZipPercent = 0;

    public bool Errors = false;
}