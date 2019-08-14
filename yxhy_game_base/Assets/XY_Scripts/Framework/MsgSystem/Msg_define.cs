
public class MSG_DEFINE
{
    public const string MSG_LOST_CONNECT_TO_SERVER = "MSG_LOST_CONNECT_TO_SERVER";  // 断线

    public const string MSG_SCENE_LOAD_START = "MSG_SCENE_LOAD_START";              // 新场景开始加载
    public const string MSG_SCENE_LOAD_PRE = "MSG_SCENE_LOAD_PRE";                  // 旧场景准备关闭（新场景准备加载）
    public const string MSG_SCENE_LOAD_COMPLETE = "MSG_SCENE_LOAD_COMPLETE";        // 场景加载完成, 参数1：str 场景名
    public const string MSG_SCENE_LOAD_LOADINGSCENE_COMPLETE = "MSG_SCENE_LOAD_LOADINGSCENE_COMPLETE";       // 场景加载进度条场景完成, 参数1：str 场景名
    public const string MSG_SCENE_INIT_COMPLETE = "MSG_SCENE_INIT_COMPLETE";        // 场景初始化完成
    public const string MSG_LOADING_TO_END = "MSG_LOADING_TO_END";                  //将进度条加载到100%
    public const string MSG_LOADING_PROCESS_CHANGE = "MSG_LOADING_PROCESS_CHANGE";  //将进度条进度改变

    // 网络相关事件
    public const string MSG_NETWORK_LOGOUT = "MSG_NETWORK_LOGOUT";                  //　注销协议返回成功

    // 加载完level，并且隐藏了loading界面
    public const string MSG_HIDE_LEVEL_LOADING_COMPLETE = "MSG_HIDE_LEVEL_LOADING_COMPLETE";

    //销毁版本更新UI
    public const string MSG_DESTROY_VERSION_UPDATE_UI = "MSG_DESTROY_VERSION_UPDATE_UI";

    //刷新网络状态UI
    public const string MSG_Refresh_NET_STATE_UI = "MSG_Refresh_NET_STATE_UI";
}