/********************************************************************
	created:	2015/06/18  11:58
	file base:	IResourceMgr
	file ext:	cs
	author:		shine	
	purpose:	用来对所有资源进行统一管理，主要是加载，缓存和释放的策略,目前存在3种不同运行时的资源情况：
                (1) 编辑器中运行
                (2) 真机运行，不打包（可以先不考虑）
                (3) 真机运行，打包
                目前包括AssetBundle和SceneBundle
*********************************************************************/

using System.Collections.Generic;
using UnityEngine;

namespace XYHY
{
    public delegate void SceneLoadedCallback(string sceneName);

    public interface IResourceMgr
    {
        /// <summary>
        /// 同步方式载入Atlas
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        UIAtlas LoadAtlasSync(string path);
        
        Texture2D LoadTextureSync(string path);

        Texture2D LoadImmortalTextureSync(string path);

        //同步加载普通资源
        Object LoadNormalObjSync(AssetBundleParams abParams);

        //同步加载临时常驻内存资源（一经加载，当前场景不会释放，但在切换场景时会被释放掉）
        Object LoadSceneResidentMemoryObjSync(AssetBundleParams abParams);

        //同步加载常驻内存资源
        Object LoadResidentMemoryObjSync(AssetBundleParams abParams);

        //异步加载普通资源，如果资源已经存在就返回true，否则需要异步处理
        bool LoadNormalObjAsync(AssetBundleParams abParams);

        //异步加载常驻内存资源
        Object LoadResidentMemoryObjAsync(AssetBundleParams abParams);


        void UnloadLastSceneAsset(string sceneName, UILabel labelCtrl = null);

        bool UnloadImmortalResource(string path, System.Type type);

        //清理加载资源时使用的资源文件，标注Immortal的资源暂不销毁
        void UnloadAllNormalResources();

        /// <summary>
        /// 加载配置文件
        /// </summary>
        /// <param name="resPath">Resources目录相对路径</param>
        /// <param name="fileSuffix">文件后缀名</param>
        /// <returns>文件的bytes</returns>
        byte[] LoadConfigFile(string resPath, string fileSuffix);
    }
}