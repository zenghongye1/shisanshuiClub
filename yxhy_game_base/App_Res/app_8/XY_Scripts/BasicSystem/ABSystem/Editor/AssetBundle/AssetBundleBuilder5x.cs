#if UNITY_5
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.IO;

namespace XYHY.ABSystem
{
    public class AssetBundleBuilder5x : ABBuilder
    {
        public AssetBundleBuilder5x(AssetBundlePathResolver resolver)
            : base(resolver)
        {

        }

        public override void Export()
        {
            base.Export();
            
            List<AssetBundleBuild> list = new List<AssetBundleBuild>();
            //标记所有 asset bundle name
            var all = AssetBundleUtils.GetAll();
            for (int i = 0; i < all.Count; i++)
            {
                AssetTarget target = all[i];
                if (target.needSelfExport)
                {
                    AssetBundleBuild build = new AssetBundleBuild();
                    build.assetNames = new string[] { target.assetPath };

                    //获取第二个分支目录名称
                    /*if(target.assetPath.EndsWith(".shader"))
                    {
                        build.assetBundleName = "game_comm/shader.ab";
                    }
                    else*/
                    {
#if UNITY_IOS || UNITY_IPHONE
                        string secondDirName = target.assetPath.Split('/')[2];
#elif UNITY_ANDROID
                        string secondDirName = target.assetPath.Split('\\')[2];
#endif
                        build.assetBundleName = secondDirName + "/" + target.bundleName;
                    }

                    list.Add(build);
                }
            }
            BuildPipeline.BuildAssetBundles(pathResolver.BundleSavePath, list.ToArray(), BuildAssetBundleOptions.ChunkBasedCompression, EditorUserBuildSettings.activeBuildTarget);
#if UNITY_5_1 || UNITY_5_2
            AssetBundle ab = AssetBundle.CreateFromFile(pathResolver.BundleSavePath + "/" + pathResolver.BundleSaveDirName);           
#else
            AssetBundle ab = AssetBundle.LoadFromFile(pathResolver.BundleSavePath + "/" + pathResolver.BundleSaveDirName);
#endif
            AssetBundleManifest manifest = ab.LoadAsset("AssetBundleManifest") as AssetBundleManifest;

            //hash
            for (int i = 0; i < all.Count; i++)
            {
                AssetTarget target = all[i];
#if UNITY_IOS || UNITY_IPHONE
                string secondDirName = target.assetPath.Split('/')[2];
#elif UNITY_ANDROID
                string secondDirName = target.assetPath.Split('\\')[2];
#endif
                if (target.needSelfExport)
                {
                    Hash128 hash = manifest.GetAssetBundleHash(secondDirName + "/" + target.bundleName);
                    target.bundleCrc = hash.ToString();
                }
            }

            var confAndLua = AssetBundleUtils.GetAllConfAndLua();
            for(int i=0; i<confAndLua.Count; i++)
            {
                AssetTarget target = confAndLua[i];
                target.bundleCrc = FileUtils.getFileMd5(target.file.FullName);
            }

            this.SaveDepAll(all, confAndLua);
            ab.Unload(true);
            this.RemoveUnused(all);

            AssetDatabase.RemoveUnusedAssetBundleNames();

            this._SaveVersion();

            //压缩patch包
            AssetBundleUtils.Convert2Patch();
            AssetDatabase.Refresh();            
        }
    }
}
#endif