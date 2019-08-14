using UnityEngine;
using System;
using System.Collections.Generic;
using XYHY;
using LuaInterface;
using BindType = ToLuaMenu.BindType;
using Framework;
using BestHTTP.WebSocket;
using gcloud_voice;

public static class CustomSettings
{
    public static string saveDir = Application.dataPath + "/XY_Scripts/Generate/";
    public static string luaDir = Application.dataPath + "/XY_Lua/";
    public static string toluaBaseType = Application.dataPath + "/ToLua/BaseType/";
    public static string toluaLuaDir = Application.dataPath + "/ToLua/Lua";

    //可以作为静态类导出的类型(注意customTypeList 还要添加这个类型才能导出)
    public static List<Type> staticClassTypes = new List<Type>
    {
        //unity 有些类作为sealed class, 其实完全等价于静态类
        typeof(UnityEngine.Application),
        typeof(UnityEngine.Time),
        typeof(UnityEngine.Screen),
        typeof(UnityEngine.SleepTimeout),
        typeof(UnityEngine.Input),
        typeof(UnityEngine.Resources),
        typeof(UnityEngine.Physics),
        //typeof(UnityEngine.RenderSettings),
        //typeof(UnityEngine.QualitySettings),
    };

    //附加导出委托类型(在导出委托时, customTypeList 中牵扯的委托类型都会导出， 无需写在这里)
    public static DelegateType[] customDelegateList =
    {
        _DT(typeof(Action)),
        //_DT(typeof(Action<GameObject>)),
        _DT(typeof(UnityEngine.Events.UnityAction)),
        //_DT(typeof(Best.AssetBundleInfo.LoadAssetCompleteHandler)),
    };

    //在这里添加你要导出注册到lua的类型列表
    public static BindType[] customTypeList =
    {
        //语音接口
        _GT(typeof(GVoiceInterface)),
        _GT(typeof(GCloudVoiceMode)),
        _GT(typeof(GCloudVoiceEngine)),
        _GT(typeof(IGCloudVoice)),      
        _GT(typeof(Debugger)).SetNameSpace(null),
        _GT(typeof(UnGfx)),

        _GT(typeof(Component)),
        _GT(typeof(Behaviour)),
        _GT(typeof(MonoBehaviour)),
        _GT(typeof(GameObject)),
        _GT(typeof(Transform)),
        _GT(typeof(Animation)),
        _GT(typeof(AnimationClip)),
        _GT(typeof(AnimationState)),
        //_GT(typeof(Space)),
        _GT(typeof(Screen)),
        _GT(typeof(Time)),
        _GT(typeof(SleepTimeout)),
        _GT(typeof(Renderer)),
        _GT(typeof(SkinnedMeshRenderer)),
        //_GT(typeof(Light)),
        //_GT(typeof(LightType)),
        _GT(typeof(Physics)),
        _GT(typeof(ParticleSystem)),
        //_GT(typeof(WWW)),
        _GT(typeof(PlayerPrefs)),
        _GT(typeof(Animator)),
        _GT(typeof(AnimatorStateInfo)),
      
        
        _GT(typeof(Camera)),
        _GT(typeof(Texture2D)),
        _GT(typeof(RenderTexture)),
        _GT(typeof(SpriteRenderer)),
        _GT(typeof(Sprite)),
        _GT(typeof(Rect)),
        _GT(typeof(Application)),
        _GT(typeof(RuntimePlatform)),
        //_GT(typeof(RenderSettings)),
        _GT(typeof(AudioClip)),
        _GT(typeof(AudioSource)),
        //_GT(typeof(CapsuleCollider)),
        _GT(typeof(MeshRenderer)),
        _GT(typeof(Material)),
        _GT(typeof(Collider)),
        _GT(typeof(BoxCollider)),
        _GT(typeof(Texture)),
        _GT(typeof(UIDrawCall)),
        _GT(typeof(MeshFilter)),
        _GT(typeof(Mesh)),
        _GT(typeof(Input)),
        //_GT(typeof(MeshCollider)),
        _GT(typeof(UICamera)),
        _GT(typeof(NGUITools)),
        _GT(typeof(UIRect)),
        _GT(typeof(UIRect.AnchorPoint)),
        _GT(typeof(UIWidget)),
        _GT(typeof(UILabel)),
        _GT(typeof(UILabel.Overflow)),
        _GT(typeof(UILabel.Effect)),
        _GT(typeof(UIToggle)),
        _GT(typeof(UIBasicSprite)),
        _GT(typeof(UITexture)),
        _GT(typeof(UISprite)),
        //_GT(typeof(UIProgressBar)),
        _GT(typeof(UISlider)),
        _GT(typeof(UIGrid)),
        _GT(typeof(UIInput)),
        _GT(typeof(UIInput.Validation)),
        _GT(typeof(UIScrollView)),
        _GT(typeof(UITweener)),
        _GT(typeof(UITweener.Style)),
        _GT(typeof(TweenColor)),
        _GT(typeof(TweenWidth)),
        _GT(typeof(TweenRotation)),
        _GT(typeof(TweenPosition)),
        _GT(typeof(TweenScale)),
        _GT(typeof(UITweener.Method)),
        _GT(typeof(UICenterOnChild)),
        _GT(typeof(UIAtlas)),
        _GT(typeof(TweenAlpha)),
        _GT(typeof(UIWrapContent)),
        _GT(typeof(UIEventListener)),
        _GT(typeof(UIPanel)),
        //_GT(typeof(UIAnchor)),
        //_GT(typeof(UIAnchor.Side)),
        //_GT(typeof(UIPopupList)),
        _GT(typeof(Font)),
        _GT(typeof(UIFont)),
        _GT(typeof(UITable)),
        _GT(typeof(UIButtonColor)),
        _GT(typeof(UIButton)),
        _GT(typeof(EventDelegate)),
        _GT(typeof(List<EventDelegate>)),
        _GT(typeof(UICamera.MouseOrTouch)),
        _GT(typeof(UIRoot)),
        _GT(typeof(UIScrollBar)),
        _GT(typeof(UIDragScrollView)),
        _GT(typeof(TweenHeight)),
        _GT(typeof(SpringPanel)),

        _GT(typeof(DG.Tweening.AutoPlay)),
        _GT(typeof(DG.Tweening.AxisConstraint)),
        _GT(typeof(DG.Tweening.Ease)),
        _GT(typeof(DG.Tweening.LogBehaviour)),
        _GT(typeof(DG.Tweening.LoopType)),
        _GT(typeof(DG.Tweening.PathMode)),
        _GT(typeof(DG.Tweening.PathType)),
        _GT(typeof(DG.Tweening.RotateMode)),
        _GT(typeof(DG.Tweening.ScrambleMode)),
        _GT(typeof(DG.Tweening.TweenType)),
        _GT(typeof(DG.Tweening.UpdateType)),

        _GT(typeof(DG.Tweening.DOTween)),
        _GT(typeof(DG.Tweening.DOVirtual)),
        _GT(typeof(DG.Tweening.EaseFactory)),
        _GT(typeof(DG.Tweening.Tweener)),
        _GT(typeof(DG.Tweening.Tween)),
        _GT(typeof(DG.Tweening.Sequence)),
        _GT(typeof(DG.Tweening.TweenParams)),

        _GT(typeof(DG.Tweening.DOTweenAnimation)),
        _GT(typeof(DG.Tweening.DOTweenPath)),
        _GT(typeof(DG.Tweening.DOTweenVisualManager)),
        _GT(typeof(DG.Tweening.Core.ABSSequentiable)),
        _GT(typeof(DG.Tweening.Core.TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions>)).SetWrapName("TweenerCoreV3V3VO").SetLibName("TweenerCoreV3V3VO"),
        _GT(typeof(DG.Tweening.Core.TweenerCore<Quaternion, Vector3, DG.Tweening.Plugins.Options.QuaternionOptions>)).SetWrapName("TweenerCoreQ4V3QO").SetLibName("TweenerCoreQ4V3QO"), //一定要加Quaternion的泛型，要不然旋转后面除了没有回调也用不了其他DoTween的方法  

        _GT(typeof(Framework.GameKernel)).SetBaseType(typeof(MonoBehaviour)),   //SetBaseType 去警告

        _GT(typeof(Util)),
        _GT(typeof(Utility_GameObject)),        
             
        _GT(typeof(LogicBaseLua)),
        _GT(typeof(XyhyGlobal)),
        _GT(typeof(Resolution)),

        _GT(typeof(FileReader)),
        _GT(typeof(ProjectConfigInfo)),

        _GT(typeof(UISys)),
        _GT(typeof(XYHY.LuaDestroyBundle)),
        
        _GT(typeof(AssetBundleParams)),
        _GT(typeof(XYHY.ResourceMgr)),
        _GT(typeof(SceneMgr)),
        //_GT(typeof(TimeCostLog)),      
        //_GT(typeof(TimeCostType)),
        _GT(typeof(ProtobufDataConfig.ProtobufDataConfigMgr)),

        _GT(typeof(NetWorkManage)),
        _GT(typeof(DownloadCachesMgr)),
        //_GT(typeof(TimeSpanManager)),
        _GT(typeof(YX_APIManage)),
        _GT(typeof(Spine.Unity.SkeletonAnimation)),
        _GT(typeof(Spine.AnimationState)),
        _GT(typeof(Spine.TrackEntry)),
        _GT(typeof(Spine.Skeleton)),

        _GT(typeof(UIscroll)),
        _GT(typeof(SingleWeb)),
        _GT(typeof(SingleFullWeb)),
        _GT(typeof(TextAsset)),
        _GT(typeof(LuaHelper)),
        _GT(typeof(TrieFilter)),
        _GT(typeof(BestHTTP.WebSocket.WebSocket)),
        _GT(typeof(System.Uri)),
        _GT(typeof(UniWebViewMessage)),
        //_GT(typeof(ScrollViewMoveFixed)), //滑动固定距离现不用
        _GT(typeof(WebPage)),
        _GT(typeof(FingerHoverEvent)),//手势识别事件
        _GT(typeof(SwipeGesture)),
        _GT(typeof(FingerUpEvent)),
        _GT(typeof(FingerDownEvent)),
        _GT(typeof(TapGesture)),

        _GT(typeof(Lua2csMessenger)),
        _GT(typeof(VersionInfo)),
        _GT(typeof(FileUtils)),
        _GT(typeof(UI_Base)),
        _GT(typeof(EffectComp)),

        _GT(typeof(DragGesture)),
        _GT(typeof(NS_VersionUpdate.AssetUpdateManager)).SetBaseType(typeof(MonoBehaviour)),
        _GT(typeof(TrackedReference)),
        _GT(typeof(UILabel.MyFormat)),
        //_GT(typeof(WrapMode)),
        //_GT(typeof(PlayMode)),
        //_GT(typeof(XYHY.ABSystem.AssetBundleManager)),
    };

    public static List<Type> dynamicList = new List<Type>()
    {
        /*
        typeof(MeshRenderer),
   //     typeof(ParticleEmitter),
    //    typeof(ParticleRenderer),
    //    typeof(ParticleAnimator),

        typeof(BoxCollider),
        typeof(MeshCollider),
        typeof(SphereCollider),
        typeof(CharacterController),
        typeof(CapsuleCollider),
       
        typeof(Animation),
        typeof(AnimationClip),
        typeof(AnimationState),
        typeof(AnimationBlendMode),
       
        //      typeof(BlendWeights),
        //       typeof(RenderTexture),
          */
    };

    //重载函数，相同参数个数，相同位置out参数匹配出问题时, 需要强制匹配解决
    //使用方法参见例子14
    public static List<Type> outList = new List<Type>()
    {

    };

    static BindType _GT(Type t)
    {
        return new BindType(t);
    }

    static DelegateType _DT(Type t)
    {
        return new DelegateType(t);
    }
}
