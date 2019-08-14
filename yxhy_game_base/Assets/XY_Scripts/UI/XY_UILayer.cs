/********************************************************************
	file base:	XY_UILayer
	file ext:	cs
	author:		xx	
	purpose:	定义一些layer的枚举，所有的界面都会落到某layer中，从而可以合理
                地对layer的深度层级进行合理安排
*********************************************************************/
using UnityEngine;
using System.Collections;


[AddComponentMenu("XYHYGame/UI/UILayer")]
public class XY_UILayer : MonoBehaviour {

    public enum Layer
    {
        //该枚举跟Unity的Prefab紧密关联，只能顺序添加，不能插入;
        //有层次添加需求，可找咨询
        MainBarLayer,       //主界面层
        SingleLayer,        //功能面板层（PanelLayer）
        MsgBoxLayer,        //消息框层
        GuideLayer,         //loading与引导层
		DebugToolLayer,         // debug tool独占的层
        ChatBroadcastLayer,     // 聊天系统走马灯独占的层
        SubPanelLayer,          //功能面板的子面板层，用于复杂面板
        FuncGuideLayer,         //情景引导层
    }


    enum RealLayer
    { 
        MainBarLayer,           //layer2
        SingleLayer,            //layer3
        SubPanelLayer,          //layer4
        FuncGuideLayer,         //layer5
        MsgBoxLayer,            //layer6
        ChatBroadcastLayer,     //layer7
        GuideLayer,             //layer8
        DebugToolLayer,         //layer9 (注意：调试工具层，永远都在最顶层，  )
    }

    public int mLayerbase = 0;

    //[HideInInspector]
    [SerializeField]
    protected Layer uiLayer = Layer.MainBarLayer;

    public Layer layer
    {
        get
        {
            return uiLayer;
        }
        set
        {
            if (uiLayer != value)
            {
                uiLayer = value;
            }
        }
    }

    public int GetLayerbase()
    {
        switch (uiLayer)
        {
            case Layer.MainBarLayer:
                mLayerbase = (int)RealLayer.MainBarLayer;
                break;
            case Layer.SingleLayer:
                mLayerbase = (int)RealLayer.SingleLayer;
                break;
            case Layer.SubPanelLayer:
                mLayerbase = (int)RealLayer.SubPanelLayer;
                break;
            case Layer.MsgBoxLayer:
                mLayerbase = (int)RealLayer.MsgBoxLayer;
                break;
            case Layer.GuideLayer:
                mLayerbase = (int)RealLayer.GuideLayer;
                break;
            case Layer.DebugToolLayer:
                mLayerbase = (int)RealLayer.DebugToolLayer;
                break;
            case Layer.ChatBroadcastLayer:
                mLayerbase = (int)RealLayer.ChatBroadcastLayer;
                break;
            case Layer.FuncGuideLayer:
                mLayerbase = (int)RealLayer.FuncGuideLayer;
                break;
            default:
                mLayerbase = 0;
                break;
        }
        return mLayerbase;
    }

	// Use this for initialization
	void Start () 
    {
                             
	}
}
