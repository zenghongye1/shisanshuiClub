//----------------------------------------------
//            NGUI: Next-Gen UI kit
// Copyright © 2011-2015 Tasharen Entertainment
//----------------------------------------------

#if !UNITY_3_5
#define DYNAMIC_FONT
#endif

//###label format define###
//#define LABEL_TYPE_TTH
//#define LABEL_FORCE_FORMAT //是否强制设置样式(prefab中设置无效)

using UnityEngine;
using System.Collections.Generic;
using System;
using Alignment = NGUIText.Alignment;
using System.ComponentModel;

[ExecuteInEditMode]
[AddComponentMenu("NGUI/UI/NGUI Label")]
public class UILabel : UIWidget
{
    public enum Effect
    {
        None,
        Shadow,
        Outline,
        Outline8,
    }

    public enum Overflow
    {
        ShrinkContent,
        ClampContent,
        ResizeFreely,
        ResizeHeight,
    }

    public enum Crispness
    {
        Never,
        OnDesktop,
        Always,
    }


    /*fuckby cjl
     * 字体样式枚举
     */
    public enum MyFormat
    {
        None,
        //		切换按钮点亮1,
        A,
        B,
        C,
        D,
        E,
        F,
        G,
        H,
        I,
        J,
        K,
        L,
        M,
        N,
        O,
        P,
        Q,
        R,
        S,
        T,
        X,
        Y,
        Z,
        A1,
        A2,
        A3,
        A4,
        A5,
        A6,
        A7,
        A8,
        A9,
        A10,
        A11,
        A12,
        A13,
        A14,
        A15,
        A16,
        [Description("提示弹框文本")]
        F1,
        [Description("提示弹框文本")]
        F2,
        [Description("标题文字")]
        F3,
        [Description("通用文字")]
        F4,
        [Description("通用文字")]
        F5,
        [Description("二级弹框文本")]
        F6,
        [Description("分类标签文字")]
        F7,
        [Description("列表文字")]
        F8,
        [Description("提示文字")]
        F9,
        [Description("公告规则文字")]
        F10,
        [Description("玩家名字")]
        F11,
        [Description("玩家名字")]
        F12,
        [Description("提示文字")]
        F13,
        [Description("跑马灯文字")]
        F14,
        [Description("设置界面")]
        F15,
        [Description("二级弹框标题")]
        F16,
        [Description("二级弹框通用")]
        F17,
        [Description("二级弹框通用")]
        F18,
        [Description("二级弹框通用")]
        F19,
        [Description("提示文字")]
        F20,
        [Description("特殊文字")]
        F21,
        [Description("特殊文字")]
        F22,
        [Description("特殊文字")]
        F23,
        [Description("特殊文字")]
        F24,
        [Description("商城数字金额")]
        F25,
        [Description("牌局提示文字")]
        F26,
        [Description("牌局聊天文字")]
        F27,
        [Description("牌局语音文字")]
        F28,
        [Description("牌局聊天文字")]
        F29,
        [Description("特殊文字")]
        F30,
        [Description("特殊文字")]
        F31,
        [Description("同33")]
        F32,
        [Description("牌局角色名称")]
        F33,
        [Description("一级按钮文字")]
        F34,
        [Description("竖向按钮文字")]
        F35,
        [Description("竖向按钮文字")]
        F36,
        [Description("特殊按钮文字")]
        F37,
        [Description("横向按钮文字")]
        F38,
        [Description("横向按钮文字")]
        F39,
        [Description("个人信息")]
        F40,
        [Description("个人信息")]
        F41,
        [Description("通用文字")]
        F42,
        [Description("通用文字")]
        F43,
        [Description("角标文字")]
        F44,
        [Description("角标文字")]
        F45,
        [Description("特殊文字")]
        F46,
        [Description("提示弹框文本")]
        F47,
        [Description("提示弹框文本")]
        F48,
        [Description("特殊文字")]
        F49,
        [Description("特殊文字")]
        F50,
        [Description("特殊文字")]
        F52,
        [Description("横向二级按钮")]
        F51,
        [Description("横向二级按钮")]
        F53,
        [Description("特殊文字")]
        F54,
        [Description("特殊文字")]
        F55,
        F56,
        F57,
        F58,
        F59,
        F60,
        F61,
        F62,
        F63,
        F64,
        F65,
        F66,
        F67,
        F68,
        F69,
        F70,
        F71,
        F72,
        F73,
        F74,
        F75,
        F76,
        F77,
        F78,
        F79,
        F80,
        MAX,  // 用于计算总长度
    }
    public struct stMyFormatData
    {
        public bool m_isGradient;//是否渐变
        public Color m_gradientUp;
        public Color m_gradientDown;

        public Effect m_effect;//效果
        public Color m_effectColor;
        public Vector2 m_effectDistance;

        public Color m_orgColor;//字体本身颜色

        public FontStyle fs;

        public int m_fontSize;//字体大小

        public void reinit()
        {
            m_isGradient = false;//是否渐变
            m_gradientUp = Color.white;
            m_gradientDown = Color.white;

            m_effect = Effect.None;//效果
            m_effectColor = Color.white;
            m_effectDistance = new Vector2(0, 1f);

            m_orgColor = Color.white;//字体本身颜色

            fs = FontStyle.Normal;

            m_fontSize = 0;
        }
    }

    public MyFormat myFormat
    {
        get
        {
            return mMyFormat;
        }
        set
        {
            if (mMyFormat != value)
            {
                mMyFormat = value;
            }
        }
    }

    public void SetLabelFormat(MyFormat format)
    {
        if (format == mMyFormat)
            return;
        myFormat = format;
        resetMyFormatData(false);
    }

    public void resetMyFormatData(bool bForce = true)
    {
        if (bForce || myFormat != MyFormat.None)
        {
            stMyFormatData data = new stMyFormatData();
            data.reinit();
            getMyFormatData(myFormat, ref data);
            setMyFormatData(ref data);
        }
    }

    //颜色表
    public enum MyColorType
    {
        None,
        A,
        B,
        C,
        D,
        E,
        F,
        G,
        H,
        I,
        J,
        K,
        L,
        M,
        N,
        O,
        P,
        Q,
        R,
        S,
        T,
        X,
        Y,
        Z,
        A1,
        A2,
        A3,
        A4,
        A5,
        A6,
        A7,
        A8,
        A9,
        A10,
        A11,
        A12,
        A13,
        A14,
        A15,
        A16,
    }
    public static void getMyColor(MyColorType type, ref stMyFormatData data, bool hasEffect = false)
    {
        switch (type)
        {
#if LABEL_TYPE_TTH

            case MyColorType.A:
                {
                    data.m_orgColor = new Color32(138, 117, 106, 255);
                } break;
            case MyColorType.B:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(159, 92, 20, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.C:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(62, 69, 150, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.D:
                {
                    data.m_orgColor = new Color32(228, 78, 4, 255);
                } break;
            case MyColorType.E:
                {
                    data.m_orgColor = new Color32(84, 54, 128, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(229, 196, 254, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            case MyColorType.F:
                {
                    data.m_orgColor = new Color32(137, 54, 9, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(254, 255, 137, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            case MyColorType.G:
                {
                    data.m_orgColor = new Color32(45, 40, 98, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(208, 231, 254, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            case MyColorType.H:
                {
                    data.m_orgColor = new Color32(255, 246, 169, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(76, 35, 13, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            case MyColorType.I:
                {
                    data.m_orgColor = new Color32(163, 88, 27, 255);
                } break;
            case MyColorType.J:
                {
                    data.m_orgColor = new Color32(230, 203, 255, 255);
                } break;
            case MyColorType.K:
                {
                    data.m_orgColor = new Color32(25, 49, 129, 255);
                } break;
            case MyColorType.L:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(31, 31, 31, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            case MyColorType.M:
                {
                    data.m_orgColor = new Color32(183, 195, 230, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(42, 26, 51, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            case MyColorType.N:
                {
                    data.m_orgColor = new Color32(249, 251, 220, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(43, 85, 6, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            case MyColorType.O:
                {
                    data.m_orgColor = new Color32(249, 251, 220, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(131, 82, 80, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.P:
                {
                    data.m_orgColor = new Color32(249, 251, 220, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(187, 113, 23, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.Q:
                {
                    data.m_orgColor = new Color32(120, 119, 119, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(16, 16, 16, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.R:
                {
                    data.m_orgColor = new Color32(208, 208, 208, 255);
                } break;
            case MyColorType.S:
                {
                    data.m_orgColor = new Color32(21, 70, 71, 255);
                } break;
            case MyColorType.T:
                {
                    //				data.m_orgColor = new Color32(255, 255, 255, 255);
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 255, 255, 255);
                    data.m_gradientDown = new Color32(152, 127, 232, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(16, 16, 16, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.X:
                {
                    //				data.m_orgColor = new Color32(249, 251, 220, 255);
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 255, 255, 255);
                    data.m_gradientDown = new Color32(255, 238, 96, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(121, 35, 7, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.Y:
                {
                    //				data.m_orgColor = new Color32(255, 255, 255, 255);
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 255, 255, 255);
                    data.m_gradientDown = new Color32(255, 175, 248, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(111, 12, 129, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.Z:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(146, 46, 14, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            case MyColorType.A1:
            #region
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(178, 30, 12, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            #endregion
            case MyColorType.A2:
            #region
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(2, 49, 120, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                } break;
            #endregion
            case MyColorType.A3:
            #region
                {
                    data.m_orgColor = new Color32(74, 74, 74, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(216, 213, 213, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                } break;
            #endregion
            case MyColorType.A4:
            #region
                {
                    data.m_orgColor = new Color32(139, 74, 27, 255);
                } break;
            #endregion
			case MyColorType.A5:
				{
					data.m_orgColor = new Color32(7, 146, 11, 255);
				} break;
			case MyColorType.A6:
				{
					data.m_orgColor = new Color32(172, 20, 33, 255);
				} break;

#else // default yx

            case MyColorType.A:
                {
                    data.m_orgColor = new Color32(138, 117, 106, 255);
                }
                break;
            case MyColorType.B:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(159, 92, 20, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.C:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(62, 69, 150, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.D:
                {
                    data.m_orgColor = new Color32(228, 78, 4, 255);
                }
                break;
            case MyColorType.E:
                {
                    data.m_orgColor = new Color32(84, 54, 128, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(229, 196, 254, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.F:
                {
                    data.m_orgColor = new Color32(137, 54, 9, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(254, 255, 137, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.G:
                {
                    data.m_orgColor = new Color32(45, 40, 98, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(208, 231, 254, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.H:
                {
                    data.m_orgColor = new Color32(255, 246, 169, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(76, 35, 13, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.I:
                {
                    data.m_orgColor = new Color32(163, 88, 27, 255);
                }
                break;
            case MyColorType.J:
                {
                    data.m_orgColor = new Color32(230, 203, 255, 255);
                }
                break;
            case MyColorType.K:
                {
                    data.m_orgColor = new Color32(25, 49, 129, 255);
                }
                break;
            case MyColorType.L:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(31, 31, 31, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.M:
                {
                    data.m_orgColor = new Color32(183, 195, 230, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(42, 26, 51, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.N:
                {
                    data.m_orgColor = new Color32(249, 251, 220, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(43, 85, 6, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.O:
                {
                    data.m_orgColor = new Color32(249, 251, 220, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(131, 82, 80, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.P:
                {
                    data.m_orgColor = new Color32(249, 251, 220, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(187, 113, 23, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.Q:
                {
                    data.m_orgColor = new Color32(120, 119, 119, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(16, 16, 16, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.R:
                {
                    data.m_orgColor = new Color32(208, 208, 208, 255);
                }
                break;
            case MyColorType.S:
                {
                    data.m_orgColor = new Color32(21, 70, 71, 255);
                }
                break;
            case MyColorType.T:
                {
                    //				data.m_orgColor = new Color32(255, 255, 255, 255);
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 255, 255, 255);
                    data.m_gradientDown = new Color32(152, 127, 232, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(16, 16, 16, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.X:
                {
                    //				data.m_orgColor = new Color32(249, 251, 220, 255);
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 255, 255, 255);
                    data.m_gradientDown = new Color32(255, 238, 96, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(121, 35, 7, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.Y:
                {
                    //				data.m_orgColor = new Color32(255, 255, 255, 255);
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 255, 255, 255);
                    data.m_gradientDown = new Color32(255, 175, 248, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(111, 12, 129, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.Z:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(146, 46, 14, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.A1:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(178, 30, 12, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.A2:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Outline8;
                        data.m_effectColor = new Color32(2, 49, 120, 255);
                        data.m_effectDistance.x = 2;
                        data.m_effectDistance.y = 2;
                    }
                }
                break;
            case MyColorType.A3:
                {
                    data.m_orgColor = new Color32(74, 74, 74, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(216, 213, 213, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A4:
                {
                    data.m_orgColor = new Color32(139, 74, 27, 255);
                }
                break;
            case MyColorType.A5:
                {
                    data.m_orgColor = new Color32(7, 146, 11, 255);
                }
                break;
            case MyColorType.A6:
                {
                    data.m_orgColor = new Color32(172, 20, 33, 255);
                }
                break;
            case MyColorType.A7:
                {
                    data.m_orgColor = new Color32(210, 217, 255, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(59, 62, 130, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A8:
                {
                    data.m_orgColor = new Color32(240, 222, 180, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(112, 84, 39, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A9:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(121, 11, 107, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A10:
                {
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(201, 195, 255, 255);
                    data.m_gradientDown = new Color32(163, 160, 255, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(46, 32, 78, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A11:
                {
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 255, 255, 255);
                    data.m_gradientDown = new Color32(176, 205, 244, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(46, 32, 78, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A12:
                {
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(255, 245,136, 255);
                    data.m_gradientDown = new Color32(255, 198, 1, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(0 , 0, 0, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A13:
                {
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(186, 243, 242, 255);
                    data.m_gradientDown = new Color32(79, 192, 183, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(0, 0, 0, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A14:
                {
                    data.m_isGradient = true;
                    data.m_gradientUp = new Color32(232, 250, 83, 255);
                    data.m_gradientDown = new Color32(241, 132, 45, 255);

                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(0, 0, 0, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A15:
                {
                    data.m_orgColor = new Color32(168, 146, 252, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(78, 59, 161, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
            case MyColorType.A16:
                {
                    data.m_orgColor = new Color32(255, 255, 255, 255);
                    if (hasEffect)
                    {
                        data.m_effect = Effect.Shadow;
                        data.m_effectColor = new Color32(77, 45, 146, 255);
                        data.m_effectDistance.x = 0;
                        data.m_effectDistance.y = 1;
                    }
                }
                break;
#endif

            default: break;
        }
    }

    public static void getMyFormatData(MyFormat fromat, ref stMyFormatData data)
    {
        if(fromat != MyFormat.None && fromat < MyFormat.F1)
        {
            getMyColor((MyColorType)fromat, ref data, true);
            return;
        }

        switch (fromat)
        {
            //		case MyFormat.切换按钮点亮1:
            //			{
            //				data.m_isGradient = true;
            //				data.m_gradientUp = new Color32(255, 255, 255, 255);
            //				data.m_gradientDown = new Color32(255, 229, 128, 255);
            //				data.m_effect = Effect.Shadow;
            //				data.m_effectColor = new Color32(48, 4, 4, 255);
            //				data.m_effectDistance.x = 1;
            //				data.m_effectDistance.y = 1;
            //			}break;

            //case MyFormat.A:
            //case MyFormat.B:
            //case MyFormat.C:
            //case MyFormat.D:
            //case MyFormat.E:
            //case MyFormat.F:
            //case MyFormat.G:
            //case MyFormat.H:
            //case MyFormat.I:
            //case MyFormat.J:
            //case MyFormat.K:
            //case MyFormat.L:
            //case MyFormat.M:
            //case MyFormat.N:
            //case MyFormat.O:
            //case MyFormat.P:
            //    {
            //        getMyColor((MyColorType)fromat, ref data, true);
            //    }
            //    break;
            //case MyFormat.B:
            //    {
            //        getMyColor(MyColorType.B, ref data, true);
            //    }
            //    break;
            //case MyFormat.C:
            //    {
            //        getMyColor(MyColorType.C, ref data, true);
            //    }
            //    break;
            //case MyFormat.D:
            //    {
            //        getMyColor(MyColorType.D, ref data);
            //    }
            //    break;
            //case MyFormat.E:
            //    {
            //        getMyColor(MyColorType.E, ref data, true);
            //    }
            //    break;
            //case MyFormat.F:
            //    {
            //        getMyColor(MyColorType.F, ref data, true);
            //    }
            //    break;
            //case MyFormat.G:
            //    {
            //        getMyColor(MyColorType.G, ref data, true);
            //    }
            //    break;
            //case MyFormat.H:
            //    {
            //        getMyColor(MyColorType.H, ref data, true);
            //    }
            //    break;
            //case MyFormat.I:
            //    {
            //        getMyColor(MyColorType.I, ref data);
            //    }
            //    break;
            //case MyFormat.J:
            //    {
            //        getMyColor(MyColorType.J, ref data);
            //    }
            //    break;
            //case MyFormat.K:
            //    {
            //        getMyColor(MyColorType.K, ref data);
            //    }
            //    break;
            //case MyFormat.L:
            //    {
            //        getMyColor(MyColorType.L, ref data, true);
            //    }
            //    break;
            //case MyFormat.M:
            //    {
            //        getMyColor(MyColorType.M, ref data, true);
            //    }
            //    break;
            //case MyFormat.N:
            //    {
            //        getMyColor(MyColorType.N, ref data, true);
            //    }
            //    break;
            //case MyFormat.O:
            //    {
            //        getMyColor(MyColorType.O, ref data, true);
            //    }
            //    break;
            //case MyFormat.P:
            //    {
            //        getMyColor(MyColorType.P, ref data, true);
            //    }
            //    break;
            //case MyFormat.Q:
            //    {
            //        getMyColor(MyColorType.Q, ref data, true);
            //    }
            //    break;
            //case MyFormat.X:
            //    {
            //        getMyColor(MyColorType.X, ref data, true);
            //    }
            //    break;
            //case MyFormat.Y:
            //    {
            //        getMyColor(MyColorType.Y, ref data, true);
            //    }
            //    break;
            //case MyFormat.Z:
            //    {
            //        getMyColor(MyColorType.Z, ref data, true);
            //    }
            //    break;
            //case MyFormat.A1:
            //    {
            //        getMyColor(MyColorType.A1, ref data, true);
            //    }
            //    break;
            //case MyFormat.A2:
            //    {
            //        getMyColor(MyColorType.A2, ref data, true);
            //    }
            //    break;
            //case MyFormat.A3:
            //    {
            //        getMyColor(MyColorType.A3, ref data, true);
            //    }
            //    break;
            //case MyFormat.A4:
            //    {
            //        getMyColor(MyColorType.A4, ref data, true);
            //    }
            //    break;
            //case MyFormat.N:
            //    {
            //        getMyColor(MyColorType.N, ref data, true);
            //    }
            //    break;
            //case MyFormat.N:
            //    {
            //        getMyColor(MyColorType.N, ref data, true);
            //    }
            //    break;
            //case MyFormat.N:
            //    {
            //        getMyColor(MyColorType.N, ref data, true);
            //    }
            //    break;
            case MyFormat.F1:
                {
                    data.m_fontSize = 36;
                    getMyColor(MyColorType.F, ref data);
                }
                break;

            case MyFormat.F2:
                {
                    data.m_fontSize = 36;
                    getMyColor(MyColorType.I, ref data);
                }
                break;

            case MyFormat.F3:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.F, ref data);
                }
                break;

            case MyFormat.F4:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.I, ref data);
                }
                break;

            case MyFormat.F5:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A, ref data);
                }
                break;

            case MyFormat.F6:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.D, ref data);
                }
                break;

            case MyFormat.F7:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.H, ref data, true);
                }
                break;

            case MyFormat.F8:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.G, ref data);
                }
                break;

            case MyFormat.F9:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.L, ref data, true);
                }
                break;

            case MyFormat.F10:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.F, ref data);
                }
                break;

            case MyFormat.F11:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.I, ref data);
                }
                break;

            case MyFormat.F12:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.G, ref data);
                }
                break;

            case MyFormat.F13:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.A, ref data);
                }
                break;

            case MyFormat.F14:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.H, ref data, true);
                }
                break;

            case MyFormat.F15:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.M, ref data);
                }
                break;

            case MyFormat.F16:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.F, ref data);
                }
                break;

            case MyFormat.F17:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.I, ref data);
                }
                break;

            case MyFormat.F18:
                {
                    data.m_fontSize = 20;
                    getMyColor(MyColorType.I, ref data);
                }
                break;

            case MyFormat.F19:
                {
                    data.m_fontSize = 20;
                    getMyColor(MyColorType.G, ref data);
                }
                break;

            case MyFormat.F20:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.L, ref data, true);
                }
                break;

            case MyFormat.F21:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.A5, ref data);
                }
                break;

            case MyFormat.F22:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.A6, ref data);
                }
                break;

            case MyFormat.F23:
                {
                    data.m_fontSize = 60;
                    getMyColor(MyColorType.G, ref data);
                }
                break;

            case MyFormat.F24:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.M, ref data);
                }
                break;

            case MyFormat.F25:
                {
                    data.m_fontSize = 40;
                    getMyColor(MyColorType.N, ref data, true);
                }
                break;

            case MyFormat.F26:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.Q, ref data, true);
                }
                break;

            case MyFormat.F27:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.L, ref data, true);
                }
                break;

            case MyFormat.F28:
                {
                    data.m_fontSize = 18;
                    getMyColor(MyColorType.T, ref data, true);
                }
                break;

            case MyFormat.F29:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.S, ref data);
                }
                break;

            case MyFormat.F30:
                {
                    data.m_fontSize = 26;
                    getMyColor(MyColorType.J, ref data);
                }
                break;

            case MyFormat.F31:
                {
                    data.m_fontSize = 26;
                    getMyColor(MyColorType.M, ref data);
                }
                break;
            case MyFormat.F32:
            case MyFormat.F33:
                {
                    data.m_fontSize = 18;
                    getMyColor(MyColorType.R, ref data);
                }
                break;

            case MyFormat.F40:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.O, ref data, true);
                }
                break;

            case MyFormat.F41:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.P, ref data, true);
                }
                break;

            case MyFormat.F34:
                {
                    data.m_fontSize = 36;
                    getMyColor(MyColorType.F, ref data, true);
                }
                break;

            case MyFormat.F35:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.B, ref data, true);
                }
                break;

            case MyFormat.F36:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.C, ref data, true);
                }
                break;

            case MyFormat.F37:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.E, ref data, true);
                }
                break;

            case MyFormat.F38:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.G, ref data, true);
                }
                break;

            case MyFormat.F39:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.M, ref data, true);
                }
                break;

            case MyFormat.F42:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.L, ref data);
                }
                break;

            case MyFormat.F43:
                {
                    data.m_fontSize = 26;
                    getMyColor(MyColorType.F, ref data);
                }
                break;

            case MyFormat.F44:
                {
                    data.m_fontSize = 25;
                    getMyColor(MyColorType.X, ref data, true);
                }
                break;

            case MyFormat.F45:
                {
                    data.m_fontSize = 26;
                    getMyColor(MyColorType.Y, ref data, true);
                }
                break;

            case MyFormat.F46:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.L, ref data);
                }
                break;

            case MyFormat.F47:
                {
                    data.m_fontSize = 15;
                    getMyColor(MyColorType.Z, ref data, true);
                }
                break;

            case MyFormat.F48:
                {
                    data.m_fontSize = 15;
                    getMyColor(MyColorType.C, ref data, true);
                }
                break;

            case MyFormat.F49:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.A1, ref data, true);
                }
                break;

            case MyFormat.F50:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.A2, ref data, true);
                }
                break;

            case MyFormat.F51:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A3, ref data, true);
                }
                break;

            case MyFormat.F52:
                {
                    data.m_fontSize = 40;
                    getMyColor(MyColorType.A4, ref data, true);
                }
                break;

            case MyFormat.F53:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.F, ref data, true);
                }
                break;
            case MyFormat.F54:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A, ref data);
                }
                break;
            case MyFormat.F55:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.A7, ref data);
                }
                break;
            case MyFormat.F56:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A7, ref data, true);
                }
                break;
            case MyFormat.F57:
                {
                    data.m_fontSize = 16;
                    getMyColor(MyColorType.A7, ref data, true);
                }
                break;
            case MyFormat.F58:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A8, ref data, true);
                }
                break;
            case MyFormat.F59:
                {
                    data.m_fontSize = 16;
                    getMyColor(MyColorType.A8, ref data, true);
                }
                break;
            case MyFormat.F60:
                {
                    data.m_fontSize = 20;
                    getMyColor(MyColorType.A9, ref data, true);
                }
                break;
            case MyFormat.F61:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A10, ref data, true);
                }
                break;
            case MyFormat.F62:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A11, ref data, true);
                }
                break;
            case MyFormat.F63:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.L, ref data);
                }
                break;
            case MyFormat.F64:
                {
                    data.m_fontSize = 22;
                    getMyColor(MyColorType.A11, ref data, true);
                }
                break;
            case MyFormat.F65:
                {
                    data.m_fontSize = 26;
                    getMyColor(MyColorType.I, ref data);
                }
                break;
            case MyFormat.F66:
                {
                    data.m_fontSize = 26;
                    getMyColor(MyColorType.G, ref data);
                }
                break;
            case MyFormat.F67:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.M, ref data);
                }
                break;
            case MyFormat.F68:
                {
                    data.m_fontSize = 60;
                    getMyColor(MyColorType.L, ref data);
                }
                break;
            case MyFormat.F69:
                {
                    data.m_fontSize = 36;
                    getMyColor(MyColorType.K, ref data);
                }
                break;
            case MyFormat.F70:
                {
                    data.m_fontSize = 36;
                    getMyColor(MyColorType.A7, ref data);
                }
                break;
            case MyFormat.F71:
                {
                    data.m_fontSize = 40;
                    getMyColor(MyColorType.L, ref data, true);
                }
                break;
            case MyFormat.F72:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A12, ref data, true);
                }
                break;
            case MyFormat.F73:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A13, ref data, true);
                }
                break;
            case MyFormat.F74:
                {
                    data.m_fontSize = 36;
                    getMyColor(MyColorType.A14, ref data, true);
                }
                break;
            case MyFormat.F75:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.E, ref data, true);
                }
                break;
            case MyFormat.F76:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.L, ref data, true);
                }
                break;
            case MyFormat.F77:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.A5, ref data, true);
                }
                break;
            case MyFormat.F78:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A15, ref data, true);
                }
                break;
            case MyFormat.F79:
                {
                    data.m_fontSize = 30;
                    getMyColor(MyColorType.A16, ref data, true);
                }
                break;
            case MyFormat.F80:
                {
                    data.m_fontSize = 24;
                    getMyColor(MyColorType.Y, ref data, true);
                }
                break;
            default: break;
        }
    }

    public void cloneMyFormatData(ref stMyFormatData data)
    {
        data.m_isGradient = applyGradient;
        data.m_gradientUp = gradientTop;
        data.m_gradientDown = gradientBottom;

        data.m_effect = effectStyle;
        data.m_effectColor = effectColor;
        data.m_effectDistance = effectDistance;

        data.m_orgColor = color;

        data.fs = fontStyle;

        data.m_fontSize = fontSize;
    }

    public void setMyFormatData(ref stMyFormatData data)
    {

        applyGradient = data.m_isGradient;
        gradientTop = data.m_gradientUp;
        gradientBottom = data.m_gradientDown;

        effectStyle = data.m_effect;
        effectColor = data.m_effectColor;
        effectDistance = data.m_effectDistance;

        color = data.m_orgColor;

        fontStyle = data.fs;

        if (data.m_fontSize > 0)
        {
            fontSize = data.m_fontSize;
        }
    }
    //end cjl

    /// <summary>
    /// Whether the label will keep its content crisp even when shrunk.
    /// You may want to turn this off on mobile devices.
    /// </summary>

    public Crispness keepCrispWhenShrunk = Crispness.OnDesktop;

    [HideInInspector]
    [SerializeField]
    Font mTrueTypeFont;
    [HideInInspector]
    [SerializeField]
    UIFont mFont;
#if !UNITY_3_5
    [MultilineAttribute(6)]
#endif
    [HideInInspector]
    [SerializeField]
    string mText = "";
    [HideInInspector]
    [SerializeField]
    int mFontSize = 16;
    [HideInInspector]
    [SerializeField]
    FontStyle mFontStyle = FontStyle.Normal;
    [HideInInspector]
    [SerializeField]
    Alignment mAlignment = Alignment.Automatic;
    [HideInInspector]
    [SerializeField]
    bool mEncoding = true;
    [HideInInspector]
    [SerializeField]
    int mMaxLineCount = 0; // 0 denotes unlimited
    [HideInInspector]
    [SerializeField]
    Effect mEffectStyle = Effect.None;
    [HideInInspector]
    [SerializeField]
    Color mEffectColor = Color.black;
    [HideInInspector]
    [SerializeField]
    NGUIText.SymbolStyle mSymbols = NGUIText.SymbolStyle.Normal;
    [HideInInspector]
    [SerializeField]
    Vector2 mEffectDistance = Vector2.one;
    [HideInInspector]
    [SerializeField]
    Overflow mOverflow = Overflow.ShrinkContent;
    [HideInInspector]
    [SerializeField]
    MyFormat mMyFormat = MyFormat.None;//fuckby cjl
    [HideInInspector]
    [SerializeField]
    Material mMaterial;
    [HideInInspector]
    [SerializeField]
    bool mApplyGradient = false;
    [HideInInspector]
    [SerializeField]
    Color mGradientTop = Color.white;
    [HideInInspector]
    [SerializeField]
    Color mGradientBottom = new Color(0.7f, 0.7f, 0.7f);
    [HideInInspector]
    [SerializeField]
    int mSpacingX = 0;
    [HideInInspector]
    [SerializeField]
    int mSpacingY = 0;
    [HideInInspector]
    [SerializeField]
    bool mUseFloatSpacing = false;
    [HideInInspector]
    [SerializeField]
    float mFloatSpacingX = 0;
    [HideInInspector]
    [SerializeField]
    float mFloatSpacingY = 0;

    // Obsolete values
    [HideInInspector]
    [SerializeField]
    bool mShrinkToFit = false;
    [HideInInspector]
    [SerializeField]
    int mMaxLineWidth = 0;
    [HideInInspector]
    [SerializeField]
    int mMaxLineHeight = 0;
    [HideInInspector]
    [SerializeField]
    float mLineWidth = 0;
    [HideInInspector]
    [SerializeField]
    bool mMultiline = true;

#if DYNAMIC_FONT
    [System.NonSerialized]
    Font mActiveTTF = null;
    float mDensity = 1f;
#endif
    bool mShouldBeProcessed = true;
    string mProcessedText = null;
    bool mPremultiply = false;
    Vector2 mCalculatedSize = Vector2.zero;
    float mScale = 1f;
    int mPrintedSize = 0;
    int mLastWidth = 0;
    int mLastHeight = 0;

    /// <summary>
    /// Function used to determine if something has changed (and thus the geometry must be rebuilt)
    /// </summary>

    bool shouldBeProcessed
    {
        get
        {
            return mShouldBeProcessed;
        }
        set
        {
            if (value)
            {
                mChanged = true;
                mShouldBeProcessed = true;
            }
            else
            {
                mShouldBeProcessed = false;
            }
        }
    }

    /// <summary>
    /// Whether the rectangle is anchored horizontally.
    /// </summary>

    public override bool isAnchoredHorizontally { get { return base.isAnchoredHorizontally || mOverflow == Overflow.ResizeFreely; } }

    /// <summary>
    /// Whether the rectangle is anchored vertically.
    /// </summary>

    public override bool isAnchoredVertically
    {
        get
        {
            return base.isAnchoredVertically ||
                mOverflow == Overflow.ResizeFreely ||
                mOverflow == Overflow.ResizeHeight;
        }
    }

    /// <summary>
    /// Retrieve the material used by the font.
    /// </summary>

    public override Material material
    {
        get
        {
            if (mMaterial != null) return mMaterial;
            if (mFont != null) return mFont.material;
            if (mTrueTypeFont != null) return mTrueTypeFont.material;
            return null;
        }
        set
        {
            if (mMaterial != value)
            {
                RemoveFromPanel();
                mMaterial = value;
                MarkAsChanged();
            }
        }
    }

    [Obsolete("Use UILabel.bitmapFont instead")]
    public UIFont font { get { return bitmapFont; } set { bitmapFont = value; } }

    /// <summary>
    /// Set the font used by this label.
    /// </summary>

    public UIFont bitmapFont
    {
        get
        {
            return mFont;
        }
        set
        {
            if (mFont != value)
            {
                RemoveFromPanel();
                mFont = value;
                mTrueTypeFont = null;
                MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Set the font used by this label.
    /// </summary>

    public Font trueTypeFont
    {
        get
        {
            if (mTrueTypeFont != null) return mTrueTypeFont;
            return (mFont != null ? mFont.dynamicFont : null);
        }
        set
        {
            if (mTrueTypeFont != value)
            {
#if DYNAMIC_FONT
                SetActiveFont(null);
                RemoveFromPanel();
                mTrueTypeFont = value;
                shouldBeProcessed = true;
                mFont = null;
                SetActiveFont(value);
                ProcessAndRequest();
                if (mActiveTTF != null)
                    base.MarkAsChanged();
#else
				mTrueTypeFont = value;
				mFont = null;
#endif
            }
        }
    }

    /// <summary>
    /// Ambiguous helper function.
    /// </summary>

    public UnityEngine.Object ambigiousFont
    {
        get
        {
            return (mFont != null) ? (UnityEngine.Object)mFont : (UnityEngine.Object)mTrueTypeFont;
        }
        set
        {
            UIFont bf = value as UIFont;
            if (bf != null) bitmapFont = bf;
            else trueTypeFont = value as Font;
        }
    }

    /// <summary>
    /// Text that's being displayed by the label.
    /// </summary>

    public string text
    {
        get
        {
            return mText;
        }
        set
        {
            if (mText == value) return;

            if (string.IsNullOrEmpty(value))
            {
                if (!string.IsNullOrEmpty(mText))
                {
                    mText = "";
                    MarkAsChanged();
                    ProcessAndRequest();
                }
            }
            else if (mText != value)
            {
                mText = value;
                MarkAsChanged();
                ProcessAndRequest();
            }

            if (autoResizeBoxCollider) ResizeCollider();
        }
    }

    /// <summary>
    /// Default font size.
    /// </summary>

    public int defaultFontSize { get { return (trueTypeFont != null) ? mFontSize : (mFont != null ? mFont.defaultSize : 16); } }

    /// <summary>
    /// Active font size used by the label.
    /// </summary>

    public int fontSize
    {
        get
        {
            return mFontSize;
        }
        set
        {
            value = Mathf.Clamp(value, 0, 256);

            if (mFontSize != value)
            {
                mFontSize = value;
                shouldBeProcessed = true;
                ProcessAndRequest();
            }
        }
    }

    /// <summary>
    /// Dynamic font style used by the label.
    /// </summary>

    public FontStyle fontStyle
    {
        get
        {
            return mFontStyle;
        }
        set
        {
            if (mFontStyle != value)
            {
                mFontStyle = value;
                shouldBeProcessed = true;
                ProcessAndRequest();
            }
        }
    }

    /// <summary>
    /// Text alignment option.
    /// </summary>

    public Alignment alignment
    {
        get
        {
            return mAlignment;
        }
        set
        {
            if (mAlignment != value)
            {
                mAlignment = value;
                shouldBeProcessed = true;
                ProcessAndRequest();
            }
        }
    }

    /// <summary>
    /// Whether a gradient will be applied.
    /// </summary>

    public bool applyGradient
    {
        get
        {
            return mApplyGradient;
        }
        set
        {
            if (mApplyGradient != value)
            {
                mApplyGradient = value;
                MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Top gradient color.
    /// </summary>

    public Color gradientTop
    {
        get
        {
            return mGradientTop;
        }
        set
        {
            if (mGradientTop != value)
            {
                mGradientTop = value;
                if (mApplyGradient) MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Bottom gradient color.
    /// </summary>

    public Color gradientBottom
    {
        get
        {
            return mGradientBottom;
        }
        set
        {
            if (mGradientBottom != value)
            {
                mGradientBottom = value;
                if (mApplyGradient) MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Additional horizontal spacing between characters when printing text.
    /// </summary>

    public int spacingX
    {
        get
        {
            return mSpacingX;
        }
        set
        {
            if (mSpacingX != value)
            {
                mSpacingX = value;
                MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Additional vertical spacing between lines when printing text.
    /// </summary>

    public int spacingY
    {
        get
        {
            return mSpacingY;
        }
        set
        {
            if (mSpacingY != value)
            {
                mSpacingY = value;
                MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Whether this label will use float text spacing values, instead of integers.
    /// </summary>

    public bool useFloatSpacing
    {
        get
        {
            return mUseFloatSpacing;
        }
        set
        {
            if (mUseFloatSpacing != value)
            {
                mUseFloatSpacing = value;
                shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Additional horizontal spacing between characters when printing text.
    /// For this to have any effect useFloatSpacing must be true.
    /// </summary>

    public float floatSpacingX
    {
        get
        {
            return mFloatSpacingX;
        }
        set
        {
            if (!Mathf.Approximately(mFloatSpacingX, value))
            {
                mFloatSpacingX = value;
                MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Additional vertical spacing between lines when printing text.
    /// For this to have any effect useFloatSpacing must be true.
    /// </summary>

    public float floatSpacingY
    {
        get
        {
            return mFloatSpacingY;
        }
        set
        {
            if (!Mathf.Approximately(mFloatSpacingY, value))
            {
                mFloatSpacingY = value;
                MarkAsChanged();
            }
        }
    }

    /// <summary>
    /// Convenience property to get the used y spacing.
    /// </summary>

    public float effectiveSpacingY
    {
        get
        {
            return mUseFloatSpacing ? mFloatSpacingY : mSpacingY;
        }
    }

    /// <summary>
    /// Convenience property to get the used x spacing.
    /// </summary>

    public float effectiveSpacingX
    {
        get
        {
            return mUseFloatSpacing ? mFloatSpacingX : mSpacingX;
        }
    }

#if DYNAMIC_FONT
    /// <summary>
    /// Whether the label will use the printed size instead of font size when printing the label.
    /// It's a dynamic font feature that will ensure that the text is crisp when shrunk.
    /// </summary>

    bool keepCrisp
    {
        get
        {
            if (trueTypeFont != null && keepCrispWhenShrunk != Crispness.Never)
            {
#if UNITY_IPHONE || UNITY_ANDROID || UNITY_WP8 || UNITY_WP_8_1 || UNITY_BLACKBERRY
                return (keepCrispWhenShrunk == Crispness.Always);
#else
				return true;
#endif
            }
            return false;
        }
    }
#endif

    /// <summary>
    /// Whether this label will support color encoding in the format of [RRGGBB] and new line in the form of a "\\n" string.
    /// </summary>

    public bool supportEncoding
    {
        get
        {
            return mEncoding;
        }
        set
        {
            if (mEncoding != value)
            {
                mEncoding = value;
                shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Style used for symbols.
    /// </summary>

    public NGUIText.SymbolStyle symbolStyle
    {
        get
        {
            return mSymbols;
        }
        set
        {
            if (mSymbols != value)
            {
                mSymbols = value;
                shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Overflow method controls the label's behaviour when its content doesn't fit the bounds.
    /// </summary>

    public Overflow overflowMethod
    {
        get
        {
            return mOverflow;
        }
        set
        {
            if (mOverflow != value)
            {
                mOverflow = value;
                shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Maximum width of the label in pixels.
    /// </summary>

    [System.Obsolete("Use 'width' instead")]
    public int lineWidth
    {
        get { return width; }
        set { width = value; }
    }

    /// <summary>
    /// Maximum height of the label in pixels.
    /// </summary>

    [System.Obsolete("Use 'height' instead")]
    public int lineHeight
    {
        get { return height; }
        set { height = value; }
    }

    /// <summary>
    /// Whether the label supports multiple lines.
    /// </summary>

    public bool multiLine
    {
        get
        {
            return mMaxLineCount != 1;
        }
        set
        {
            if ((mMaxLineCount != 1) != value)
            {
                mMaxLineCount = (value ? 0 : 1);
                shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Process the label's text before returning its corners.
    /// </summary>

    public override Vector3[] localCorners
    {
        get
        {
            if (shouldBeProcessed) ProcessText();
            return base.localCorners;
        }
    }

    /// <summary>
    /// Process the label's text before returning its corners.
    /// </summary>

    public override Vector3[] worldCorners
    {
        get
        {
            if (shouldBeProcessed) ProcessText();
            return base.worldCorners;
        }
    }

    /// <summary>
    /// Process the label's text before returning its drawing dimensions.
    /// </summary>

    public override Vector4 drawingDimensions
    {
        get
        {
            if (shouldBeProcessed) ProcessText();
            return base.drawingDimensions;
        }
    }

    /// <summary>
    /// The max number of lines to be displayed for the label
    /// </summary>

    public int maxLineCount
    {
        get
        {
            return mMaxLineCount;
        }
        set
        {
            if (mMaxLineCount != value)
            {
                mMaxLineCount = Mathf.Max(value, 0);
                shouldBeProcessed = true;
                if (overflowMethod == Overflow.ShrinkContent) MakePixelPerfect();
            }
        }
    }

    /// <summary>
    /// What effect is used by the label.
    /// </summary>

    public Effect effectStyle
    {
        get
        {
            return mEffectStyle;
        }
        set
        {
            if (mEffectStyle != value)
            {
                mEffectStyle = value;
                shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Color used by the effect, if it's enabled.
    /// </summary>

    public Color effectColor
    {
        get
        {
            return mEffectColor;
        }
        set
        {
            if (mEffectColor != value)
            {
                mEffectColor = value;
                if (mEffectStyle != Effect.None) shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Effect distance in pixels.
    /// </summary>

    public Vector2 effectDistance
    {
        get
        {
            return mEffectDistance;
        }
        set
        {
            if (mEffectDistance != value)
            {
                mEffectDistance = value;
                shouldBeProcessed = true;
            }
        }
    }

    /// <summary>
    /// Whether the label will automatically shrink its size in order to fit the maximum line width.
    /// </summary>

    [System.Obsolete("Use 'overflowMethod == UILabel.Overflow.ShrinkContent' instead")]
    public bool shrinkToFit
    {
        get
        {
            return mOverflow == Overflow.ShrinkContent;
        }
        set
        {
            if (value)
            {
                overflowMethod = Overflow.ShrinkContent;
            }
        }
    }

    /// <summary>
    /// Returns the processed version of 'text', with new line characters, line wrapping, etc.
    /// </summary>

    public string processedText
    {
        get
        {
            if (mLastWidth != mWidth || mLastHeight != mHeight)
            {
                mLastWidth = mWidth;
                mLastHeight = mHeight;
                mShouldBeProcessed = true;
            }

            // Process the text if necessary
            if (shouldBeProcessed) ProcessText();
            return mProcessedText;
        }
    }

    /// <summary>
    /// Actual printed size of the text, in pixels.
    /// </summary>

    public Vector2 printedSize
    {
        get
        {
            if (shouldBeProcessed) ProcessText();
            return mCalculatedSize;
        }
    }

    /// <summary>
    /// Local size of the widget, in pixels.
    /// </summary>

    public override Vector2 localSize
    {
        get
        {
            if (shouldBeProcessed) ProcessText();
            return base.localSize;
        }
    }

    /// <summary>
    /// Whether the label has a valid font.
    /// </summary>

#if DYNAMIC_FONT
    bool isValid { get { return mFont != null || mTrueTypeFont != null; } }
#else
	bool isValid { get { return mFont != null; } }
#endif

#if DYNAMIC_FONT
    static BetterList<UILabel> mList = new BetterList<UILabel>();
    static Dictionary<Font, int> mFontUsage = new Dictionary<Font, int>();

    /// <summary>
    /// Register the font texture change listener.
    /// </summary>

    protected override void OnInit()
    {
        base.OnInit();
        mList.Add(this);
        SetActiveFont(trueTypeFont);

        //fuckby cjl
#if LABEL_FORCE_FORMAT
        resetMyFormatData(false);
#endif
        //end cjl
    }

    /// <summary>
    /// Remove the font texture change listener.
    /// </summary>

    protected override void OnDisable()
    {
        SetActiveFont(null);
        mList.Remove(this);
        base.OnDisable();
    }

    /// <summary>
    /// Set the active font, correctly setting and clearing callbacks.
    /// </summary>

    protected void SetActiveFont(Font fnt)
    {
        if (mActiveTTF != fnt)
        {
            if (mActiveTTF != null)
            {
                int usage;

                if (mFontUsage.TryGetValue(mActiveTTF, out usage))
                {
                    usage = Mathf.Max(0, --usage);

                    if (usage == 0)
                    {
#if UNITY_4_3 || UNITY_4_5 || UNITY_4_6
						mActiveTTF.textureRebuildCallback = null;
#endif
                        mFontUsage.Remove(mActiveTTF);
                    }
                    else mFontUsage[mActiveTTF] = usage;
                }
#if UNITY_4_3 || UNITY_4_5 || UNITY_4_6
				else mActiveTTF.textureRebuildCallback = null;
#endif
            }

            mActiveTTF = fnt;

            if (mActiveTTF != null)
            {
                int usage = 0;

                // Font hasn't been used yet? Register a change delegate callback
#if UNITY_4_3 || UNITY_4_5 || UNITY_4_6
				if (!mFontUsage.TryGetValue(mActiveTTF, out usage))
					mActiveTTF.textureRebuildCallback = OnFontTextureChanged;
#endif
#if UNITY_FLASH
				mFontUsage[mActiveTTF] = usage + 1;
#else
                mFontUsage[mActiveTTF] = ++usage;
#endif
            }
        }
    }

    /// <summary>
    /// Notification called when the Unity's font's texture gets rebuilt.
    /// Unity's font has a nice tendency to simply discard other characters when the texture's dimensions change.
    /// By requesting them inside the notification callback, we immediately force them back in.
    /// Originally I was subscribing each label to the font individually, but as it turned out
    /// mono's delegate system causes an insane amount of memory allocations when += or -= to a delegate.
    /// So... queue yet another work-around.
    /// </summary>

#if UNITY_4_3 || UNITY_4_5 || UNITY_4_6
	static void OnFontTextureChanged ()
	{
		for (int i = 0; i < mList.size; ++i)
		{
			UILabel lbl = mList[i];

			if (lbl != null)
			{
				Font fnt = lbl.trueTypeFont;

				if (fnt != null)
				{
					fnt.RequestCharactersInTexture(lbl.mText, lbl.mPrintedSize, lbl.mFontStyle);
				}
			}
		}

		for (int i = 0; i < mList.size; ++i)
		{
			UILabel lbl = mList[i];

			if (lbl != null)
			{
				Font fnt = lbl.trueTypeFont;

				if (fnt != null)
				{
					lbl.RemoveFromPanel();
					lbl.CreatePanel();
				}
			}
		}
	}
#else
    static void OnFontChanged(Font font)
    {
        for (int i = 0; i < mList.size; ++i)
        {
            UILabel lbl = mList[i];

            if (lbl != null)
            {
                Font fnt = lbl.trueTypeFont;

                if (fnt == font)
                {
                    fnt.RequestCharactersInTexture(lbl.mText, lbl.mPrintedSize, lbl.mFontStyle);
                }
            }
        }

        for (int i = 0; i < mList.size; ++i)
        {
            UILabel lbl = mList[i];

            if (lbl != null)
            {
                Font fnt = lbl.trueTypeFont;

                if (fnt == font)
                {
                    lbl.RemoveFromPanel();
                    lbl.CreatePanel();
                }
            }
        }
    }
#endif
#endif

    /// <summary>
    /// Get the sides of the rectangle relative to the specified transform.
    /// The order is left, top, right, bottom.
    /// </summary>

    public override Vector3[] GetSides(Transform relativeTo)
    {
        if (shouldBeProcessed) ProcessText();
        return base.GetSides(relativeTo);
    }

    /// <summary>
    /// Upgrading labels is a bit different.
    /// </summary>

    protected override void UpgradeFrom265()
    {
        ProcessText(true, true);

        if (mShrinkToFit)
        {
            overflowMethod = Overflow.ShrinkContent;
            mMaxLineCount = 0;
        }

        if (mMaxLineWidth != 0)
        {
            width = mMaxLineWidth;
            overflowMethod = mMaxLineCount > 0 ? Overflow.ResizeHeight : Overflow.ShrinkContent;
        }
        else overflowMethod = Overflow.ResizeFreely;

        if (mMaxLineHeight != 0)
            height = mMaxLineHeight;

        if (mFont != null)
        {
            int min = mFont.defaultSize;
            if (height < min) height = min;
            fontSize = min;
        }

        mMaxLineWidth = 0;
        mMaxLineHeight = 0;
        mShrinkToFit = false;

        NGUITools.UpdateWidgetCollider(gameObject, true);
    }

    /// <summary>
    /// If the label is anchored it should not auto-resize.
    /// </summary>

    protected override void OnAnchor()
    {
        if (mOverflow == Overflow.ResizeFreely)
        {
            if (isFullyAnchored)
                mOverflow = Overflow.ShrinkContent;
        }
        else if (mOverflow == Overflow.ResizeHeight)
        {
            if (topAnchor.target != null && bottomAnchor.target != null)
                mOverflow = Overflow.ShrinkContent;
        }
        base.OnAnchor();
    }

    /// <summary>
    /// Request the needed characters in the texture.
    /// </summary>

    void ProcessAndRequest()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying && !NGUITools.GetActive(this)) return;
        if (!mAllowProcessing) return;
#endif
        if (ambigiousFont != null) ProcessText();
    }

#if UNITY_EDITOR
    // Used to ensure that we don't process font more than once inside OnValidate function below
    bool mAllowProcessing = true;
    bool mUsingTTF = true;

    /// <summary>
    /// Validate the properties.
    /// </summary>

    protected override void OnValidate()
    {
        base.OnValidate();

        if (NGUITools.GetActive(this))
        {
            Font ttf = mTrueTypeFont;
            UIFont fnt = mFont;

            // If the true type font was not used before, but now it is, clear the font reference
            if (!mUsingTTF && ttf != null) fnt = null;
            else if (mUsingTTF && fnt != null) ttf = null;

            mFont = null;
            mTrueTypeFont = null;
            mAllowProcessing = false;

#if DYNAMIC_FONT
            SetActiveFont(null);
#endif
            if (fnt != null)
            {
                bitmapFont = fnt;
                mUsingTTF = false;
            }
            else if (ttf != null)
            {
                trueTypeFont = ttf;
                mUsingTTF = true;
            }

            shouldBeProcessed = true;
            mAllowProcessing = true;
            ProcessAndRequest();
            if (autoResizeBoxCollider) ResizeCollider();
        }
    }
#endif

#if !UNITY_4_3 && !UNITY_4_5 && !UNITY_4_6
    static bool mTexRebuildAdded = false;

    protected override void OnEnable()
    {
        base.OnEnable();
        if (!mTexRebuildAdded)
        {
            mTexRebuildAdded = true;
            Font.textureRebuilt += OnFontChanged;
        }
    }
#endif

    /// <summary>
    /// Determine start-up values.
    /// </summary>

    protected override void OnStart()
    {
        base.OnStart();

        // Legacy support
        if (mLineWidth > 0f)
        {
            mMaxLineWidth = Mathf.RoundToInt(mLineWidth);
            mLineWidth = 0f;
        }

        if (!mMultiline)
        {
            mMaxLineCount = 1;
            mMultiline = true;
        }

        // Whether this is a premultiplied alpha shader
        mPremultiply = (material != null && material.shader != null && material.shader.name.Contains("Premultiplied"));

#if DYNAMIC_FONT
        // Request the text within the font
        ProcessAndRequest();
#endif
    }

    /// <summary>
    /// UILabel needs additional processing when something changes.
    /// </summary>

    public override void MarkAsChanged()
    {
        shouldBeProcessed = true;
        base.MarkAsChanged();
    }

    /// <summary>
    /// Process the raw text, called when something changes.
    /// </summary>

    public void ProcessText() { ProcessText(false, true); }

    /// <summary>
    /// Process the raw text, called when something changes.
    /// </summary>

    void ProcessText(bool legacyMode, bool full)
    {
        if (!isValid) return;

        mChanged = true;
        shouldBeProcessed = false;

        float regionX = mDrawRegion.z - mDrawRegion.x;
        float regionY = mDrawRegion.w - mDrawRegion.y;

        NGUIText.rectWidth = legacyMode ? (mMaxLineWidth != 0 ? mMaxLineWidth : 1000000) : width;
        NGUIText.rectHeight = legacyMode ? (mMaxLineHeight != 0 ? mMaxLineHeight : 1000000) : height;
        NGUIText.regionWidth = (regionX != 1f) ? Mathf.RoundToInt(NGUIText.rectWidth * regionX) : NGUIText.rectWidth;
        NGUIText.regionHeight = (regionY != 1f) ? Mathf.RoundToInt(NGUIText.rectHeight * regionY) : NGUIText.rectHeight;

        mPrintedSize = Mathf.Abs(legacyMode ? Mathf.RoundToInt(cachedTransform.localScale.x) : defaultFontSize);
        mScale = 1f;

        if (NGUIText.regionWidth < 1 || NGUIText.regionHeight < 0)
        {
            mProcessedText = "";
            return;
        }

#if DYNAMIC_FONT
        bool isDynamic = (trueTypeFont != null);

        if (isDynamic && keepCrisp)
        {
            UIRoot rt = root;
            if (rt != null) mDensity = (rt != null) ? rt.pixelSizeAdjustment : 1f;
        }
        else mDensity = 1f;
#endif
        if (full) UpdateNGUIText();

        if (mOverflow == Overflow.ResizeFreely)
        {
            NGUIText.rectWidth = 1000000;
            NGUIText.regionWidth = 1000000;
        }

        if (mOverflow == Overflow.ResizeFreely || mOverflow == Overflow.ResizeHeight)
        {
            NGUIText.rectHeight = 1000000;
            NGUIText.regionHeight = 1000000;
        }

        if (mPrintedSize > 0)
        {
#if DYNAMIC_FONT
            bool adjustSize = keepCrisp;
#endif
            for (int ps = mPrintedSize; ps > 0; --ps)
            {
#if DYNAMIC_FONT
                // Adjust either the size, or the scale
                if (adjustSize)
                {
                    mPrintedSize = ps;
                    NGUIText.fontSize = mPrintedSize;
                }
                else
#endif
                {
                    mScale = (float)ps / mPrintedSize;
#if DYNAMIC_FONT
                    NGUIText.fontScale = isDynamic ? mScale : ((float)mFontSize / mFont.defaultSize) * mScale;
#else
					NGUIText.fontScale = ((float)mFontSize / mFont.defaultSize) * mScale;
#endif
                }

                NGUIText.Update(false);

                // Wrap the text
                bool fits = NGUIText.WrapText(mText, out mProcessedText, true);

                if (mOverflow == Overflow.ShrinkContent && !fits)
                {
                    if (--ps > 1) continue;
                    else break;
                }
                else if (mOverflow == Overflow.ResizeFreely)
                {
                    mCalculatedSize = NGUIText.CalculatePrintedSize(mProcessedText);

                    mWidth = Mathf.Max(minWidth, Mathf.RoundToInt(mCalculatedSize.x));
                    if (regionX != 1f) mWidth = Mathf.RoundToInt(mWidth / regionX);
                    mHeight = Mathf.Max(minHeight, Mathf.RoundToInt(mCalculatedSize.y));
                    if (regionY != 1f) mHeight = Mathf.RoundToInt(mHeight / regionY);

                    if ((mWidth & 1) == 1) ++mWidth;
                    if ((mHeight & 1) == 1) ++mHeight;
                }
                else if (mOverflow == Overflow.ResizeHeight)
                {
                    mCalculatedSize = NGUIText.CalculatePrintedSize(mProcessedText);
                    mHeight = Mathf.Max(minHeight, Mathf.RoundToInt(mCalculatedSize.y));
                    if (regionY != 1f) mHeight = Mathf.RoundToInt(mHeight / regionY);
                    if ((mHeight & 1) == 1) ++mHeight;
                }
                else
                {
                    mCalculatedSize = NGUIText.CalculatePrintedSize(mProcessedText);
                }

                // Upgrade to the new system
                if (legacyMode)
                {
                    width = Mathf.RoundToInt(mCalculatedSize.x);
                    height = Mathf.RoundToInt(mCalculatedSize.y);
                    cachedTransform.localScale = Vector3.one;
                }
                break;
            }
        }
        else
        {
            cachedTransform.localScale = Vector3.one;
            mProcessedText = "";
            mScale = 1f;
        }

        if (full)
        {
            NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
            NGUIText.dynamicFont = null;
#endif
        }
    }

    /// <summary>
    /// Text is pixel-perfect when its scale matches the size.
    /// </summary>

    public override void MakePixelPerfect()
    {
        if (ambigiousFont != null)
        {
            Vector3 pos = cachedTransform.localPosition;
            pos.x = Mathf.RoundToInt(pos.x);
            pos.y = Mathf.RoundToInt(pos.y);
            pos.z = Mathf.RoundToInt(pos.z);

            cachedTransform.localPosition = pos;
            cachedTransform.localScale = Vector3.one;

            if (mOverflow == Overflow.ResizeFreely)
            {
                AssumeNaturalSize();
            }
            else
            {
                int w = width;
                int h = height;

                Overflow over = mOverflow;
                if (over != Overflow.ResizeHeight) mWidth = 100000;
                mHeight = 100000;

                mOverflow = Overflow.ShrinkContent;
                ProcessText(false, true);
                mOverflow = over;

                int minX = Mathf.RoundToInt(mCalculatedSize.x);
                int minY = Mathf.RoundToInt(mCalculatedSize.y);

                minX = Mathf.Max(minX, base.minWidth);
                minY = Mathf.Max(minY, base.minHeight);

                if ((minX & 1) == 1) ++minX;
                if ((minY & 1) == 1) ++minY;

                mWidth = Mathf.Max(w, minX);
                mHeight = Mathf.Max(h, minY);

                MarkAsChanged();
            }
        }
        else base.MakePixelPerfect();
    }

    /// <summary>
    /// Make the label assume its natural size.
    /// </summary>

    public void AssumeNaturalSize()
    {
        if (ambigiousFont != null)
        {
            mWidth = 100000;
            mHeight = 100000;
            ProcessText(false, true);
            mWidth = Mathf.RoundToInt(mCalculatedSize.x);
            mHeight = Mathf.RoundToInt(mCalculatedSize.y);
            if ((mWidth & 1) == 1) ++mWidth;
            if ((mHeight & 1) == 1) ++mHeight;
            MarkAsChanged();
        }
    }

    [System.Obsolete("Use UILabel.GetCharacterAtPosition instead")]
    public int GetCharacterIndex(Vector3 worldPos) { return GetCharacterIndexAtPosition(worldPos, false); }

    [System.Obsolete("Use UILabel.GetCharacterAtPosition instead")]
    public int GetCharacterIndex(Vector2 localPos) { return GetCharacterIndexAtPosition(localPos, false); }

    static BetterList<Vector3> mTempVerts = new BetterList<Vector3>();
    static BetterList<int> mTempIndices = new BetterList<int>();

    /// <summary>
    /// Return the index of the character at the specified world position.
    /// </summary>

    public int GetCharacterIndexAtPosition(Vector3 worldPos, bool precise)
    {
        Vector2 localPos = cachedTransform.InverseTransformPoint(worldPos);
        return GetCharacterIndexAtPosition(localPos, precise);
    }

    /// <summary>
    /// Return the index of the character at the specified local position.
    /// </summary>

    public int GetCharacterIndexAtPosition(Vector2 localPos, bool precise)
    {
        if (isValid)
        {
            string text = processedText;
            if (string.IsNullOrEmpty(text)) return 0;

            UpdateNGUIText();

            if (precise) NGUIText.PrintExactCharacterPositions(text, mTempVerts, mTempIndices);
            else NGUIText.PrintApproximateCharacterPositions(text, mTempVerts, mTempIndices);

            if (mTempVerts.size > 0)
            {
                ApplyOffset(mTempVerts, 0);
                int retVal = precise ?
                    NGUIText.GetExactCharacterIndex(mTempVerts, mTempIndices, localPos) :
                    NGUIText.GetApproximateCharacterIndex(mTempVerts, mTempIndices, localPos);

                mTempVerts.Clear();
                mTempIndices.Clear();

                NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
                NGUIText.dynamicFont = null;
#endif
                return retVal;
            }

            NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
            NGUIText.dynamicFont = null;
#endif
        }
        return 0;
    }

    /// <summary>
    /// Retrieve the word directly below the specified world-space position.
    /// </summary>

    public string GetWordAtPosition(Vector3 worldPos)
    {
        int index = GetCharacterIndexAtPosition(worldPos, true);
        return GetWordAtCharacterIndex(index);
    }

    /// <summary>
    /// Retrieve the word directly below the specified relative-to-label position.
    /// </summary>

    public string GetWordAtPosition(Vector2 localPos)
    {
        int index = GetCharacterIndexAtPosition(localPos, true);
        return GetWordAtCharacterIndex(index);
    }

    /// <summary>
    /// Retrieve the word right under the specified character index.
    /// </summary>

    public string GetWordAtCharacterIndex(int characterIndex)
    {
        if (characterIndex != -1 && characterIndex < mText.Length)
        {
#if UNITY_FLASH
			int wordStart = LastIndexOfAny(mText, new char[] { ' ', '\n' }, characterIndex) + 1;
			int wordEnd = IndexOfAny(mText, new char[] { ' ', '\n', ',', '.' }, characterIndex);
#else
            int wordStart = mText.LastIndexOfAny(new char[] { ' ', '\n' }, characterIndex) + 1;
            int wordEnd = mText.IndexOfAny(new char[] { ' ', '\n', ',', '.' }, characterIndex);
#endif
            if (wordEnd == -1) wordEnd = mText.Length;

            if (wordStart != wordEnd)
            {
                int len = wordEnd - wordStart;

                if (len > 0)
                {
                    string word = mText.Substring(wordStart, len);
                    return NGUIText.StripSymbols(word);
                }
            }
        }
        return null;
    }

#if UNITY_FLASH
	/// <summary>
	/// Flash is fail IRL: http://www.tasharen.com/forum/index.php?topic=11390.0
	/// </summary>

	int LastIndexOfAny (string input, char[] any, int start)
	{
		if (start >= 0 && input.Length > 0 && any.Length > 0 && start < input.Length)
		{
			for (int w = start; w >= 0; w--)
			{
				for (int r = 0; r < any.Length; r++)
				{
					if (any[r] == input[w])
					{
						return w;
					}
				}
			}
		}
		return -1;
	}

	/// <summary>
	/// Flash is fail IRL: http://www.tasharen.com/forum/index.php?topic=11390.0
	/// </summary>

	int IndexOfAny (string input, char[] any, int start)
	{
		if (start >= 0 && input.Length > 0 && any.Length > 0 && start < input.Length)
		{
			for (int w = start; w < input.Length; w++)
			{
				for (int r = 0; r < any.Length; r++)
				{
					if (any[r] == input[w])
					{
						return w;
					}
				}
			}
		}
		return -1;
	}
#endif

    /// <summary>
    /// Retrieve the URL directly below the specified world-space position.
    /// </summary>

    public string GetUrlAtPosition(Vector3 worldPos) { return GetUrlAtCharacterIndex(GetCharacterIndexAtPosition(worldPos, true)); }

    /// <summary>
    /// Retrieve the URL directly below the specified relative-to-label position.
    /// </summary>

    public string GetUrlAtPosition(Vector2 localPos) { return GetUrlAtCharacterIndex(GetCharacterIndexAtPosition(localPos, true)); }

    /// <summary>
    /// Retrieve the URL right under the specified character index.
    /// </summary>

    public string GetUrlAtCharacterIndex(int characterIndex)
    {
        if (characterIndex != -1 && characterIndex < mText.Length - 6)
        {
            int linkStart;

            // LastIndexOf() fails if the string happens to begin with the expected text
            if (mText[characterIndex] == '[' &&
                mText[characterIndex + 1] == 'u' &&
                mText[characterIndex + 2] == 'r' &&
                mText[characterIndex + 3] == 'l' &&
                mText[characterIndex + 4] == '=')
            {
                linkStart = characterIndex;
            }
            else linkStart = mText.LastIndexOf("[url=", characterIndex);

            if (linkStart == -1) return null;

            linkStart += 5;
            int linkEnd = mText.IndexOf("]", linkStart);
            if (linkEnd == -1) return null;

            int urlEnd = mText.IndexOf("[/url]", linkEnd);
            if (urlEnd == -1 || characterIndex <= urlEnd)
                return mText.Substring(linkStart, linkEnd - linkStart);
        }
        return null;
    }

    /// <summary>
    /// Get the index of the character on the line directly above or below the current index.
    /// </summary>

    public int GetCharacterIndex(int currentIndex, KeyCode key)
    {
        if (isValid)
        {
            string text = processedText;
            if (string.IsNullOrEmpty(text)) return 0;

            int def = defaultFontSize;
            UpdateNGUIText();

            NGUIText.PrintApproximateCharacterPositions(text, mTempVerts, mTempIndices);

            if (mTempVerts.size > 0)
            {
                ApplyOffset(mTempVerts, 0);

                for (int i = 0; i < mTempIndices.size; ++i)
                {
                    if (mTempIndices[i] == currentIndex)
                    {
                        // Determine position on the line above or below this character
                        Vector2 localPos = mTempVerts[i];

                        if (key == KeyCode.UpArrow) localPos.y += def + effectiveSpacingY;
                        else if (key == KeyCode.DownArrow) localPos.y -= def + effectiveSpacingY;
                        else if (key == KeyCode.Home) localPos.x -= 1000f;
                        else if (key == KeyCode.End) localPos.x += 1000f;

                        // Find the closest character to this position
                        int retVal = NGUIText.GetApproximateCharacterIndex(mTempVerts, mTempIndices, localPos);
                        if (retVal == currentIndex) break;

                        mTempVerts.Clear();
                        mTempIndices.Clear();
                        return retVal;
                    }
                }
                mTempVerts.Clear();
                mTempIndices.Clear();
            }

            NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
            NGUIText.dynamicFont = null;
#endif
            // If the selection doesn't move, then we're at the top or bottom-most line
            if (key == KeyCode.UpArrow || key == KeyCode.Home) return 0;
            if (key == KeyCode.DownArrow || key == KeyCode.End) return text.Length;
        }
        return currentIndex;
    }

    /// <summary>
    /// Fill the specified geometry buffer with vertices that would highlight the current selection.
    /// </summary>

    public void PrintOverlay(int start, int end, UIGeometry caret, UIGeometry highlight, Color caretColor, Color highlightColor)
    {
        if (caret != null) caret.Clear();
        if (highlight != null) highlight.Clear();
        if (!isValid) return;

        string text = processedText;
        UpdateNGUIText();

        int startingCaretVerts = caret.verts.size;
        Vector2 center = new Vector2(0.5f, 0.5f);
        float alpha = finalAlpha;

        // If we have a highlight to work with, fill the buffer
        if (highlight != null && start != end)
        {
            int startingVertices = highlight.verts.size;
            NGUIText.PrintCaretAndSelection(text, start, end, caret.verts, highlight.verts);

            if (highlight.verts.size > startingVertices)
            {
                ApplyOffset(highlight.verts, startingVertices);

                Color32 c = new Color(highlightColor.r, highlightColor.g, highlightColor.b, highlightColor.a * alpha);

                for (int i = startingVertices; i < highlight.verts.size; ++i)
                {
                    highlight.uvs.Add(center);
                    highlight.cols.Add(c);
                }
            }
        }
        else NGUIText.PrintCaretAndSelection(text, start, end, caret.verts, null);

        // Fill the caret UVs and colors
        ApplyOffset(caret.verts, startingCaretVerts);
        Color32 cc = new Color(caretColor.r, caretColor.g, caretColor.b, caretColor.a * alpha);

        for (int i = startingCaretVerts; i < caret.verts.size; ++i)
        {
            caret.uvs.Add(center);
            caret.cols.Add(cc);
        }

        NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
        NGUIText.dynamicFont = null;
#endif
    }

    /// <summary>
    /// Draw the label.
    /// </summary>

    public override void OnFill(BetterList<Vector3> verts, BetterList<Vector2> uvs, BetterList<Color32> cols)
    {
        if (!isValid) return;

        int offset = verts.size;
        Color col = color;
        col.a = finalAlpha;

        if (mFont != null && mFont.premultipliedAlphaShader) col = NGUITools.ApplyPMA(col);

        if (QualitySettings.activeColorSpace == ColorSpace.Linear)
        {
            col.r = Mathf.GammaToLinearSpace(col.r);
            col.g = Mathf.GammaToLinearSpace(col.g);
            col.b = Mathf.GammaToLinearSpace(col.b);
        }

        string text = processedText;
        int start = verts.size;

        UpdateNGUIText();

        NGUIText.tint = col;
        NGUIText.Print(text, verts, uvs, cols);
        NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
        NGUIText.dynamicFont = null;
#endif
        // Center the content within the label vertically
        Vector2 pos = ApplyOffset(verts, start);

        // Effects don't work with packed fonts
        if (mFont != null && mFont.packedFontShader) return;

        // Apply an effect if one was requested
        if (effectStyle != Effect.None)
        {
            int end = verts.size;
            pos.x = mEffectDistance.x;
            pos.y = mEffectDistance.y;

            ApplyShadow(verts, uvs, cols, offset, end, pos.x, -pos.y);

            if ((effectStyle == Effect.Outline) || (effectStyle == Effect.Outline8))
            {
                offset = end;
                end = verts.size;

                ApplyShadow(verts, uvs, cols, offset, end, -pos.x, pos.y);

                offset = end;
                end = verts.size;

                ApplyShadow(verts, uvs, cols, offset, end, pos.x, pos.y);

                offset = end;
                end = verts.size;

                ApplyShadow(verts, uvs, cols, offset, end, -pos.x, -pos.y);

                if (effectStyle == Effect.Outline8)
                {
                    offset = end;
                    end = verts.size;

                    ApplyShadow(verts, uvs, cols, offset, end, -pos.x, 0);

                    offset = end;
                    end = verts.size;

                    ApplyShadow(verts, uvs, cols, offset, end, pos.x, 0);

                    offset = end;
                    end = verts.size;

                    ApplyShadow(verts, uvs, cols, offset, end, 0, pos.y);

                    offset = end;
                    end = verts.size;

                    ApplyShadow(verts, uvs, cols, offset, end, 0, -pos.y);
                }
            }
        }

        if (onPostFill != null)
            onPostFill(this, offset, verts, uvs, cols);
    }

    /// <summary>
    /// Align the vertices, making the label positioned correctly based on the pivot.
    /// Returns the offset that was applied.
    /// </summary>

    public Vector2 ApplyOffset(BetterList<Vector3> verts, int start)
    {
        Vector2 po = pivotOffset;

        float fx = Mathf.Lerp(0f, -mWidth, po.x);
        float fy = Mathf.Lerp(mHeight, 0f, po.y) + Mathf.Lerp((mCalculatedSize.y - mHeight), 0f, po.y);

        fx = Mathf.Round(fx);
        fy = Mathf.Round(fy);

#if UNITY_FLASH
		for (int i = start; i < verts.size; ++i)
		{
			Vector3 buff = verts.buffer[i];
			buff.x += fx;
			buff.y += fy;
			verts.buffer[i] = buff;
		}
#else
        for (int i = start; i < verts.size; ++i)
        {
            verts.buffer[i].x += fx;
            verts.buffer[i].y += fy;
        }
#endif
        return new Vector2(fx, fy);
    }

    /// <summary>
    /// Apply a shadow effect to the buffer.
    /// </summary>

    public void ApplyShadow(BetterList<Vector3> verts, BetterList<Vector2> uvs, BetterList<Color32> cols, int start, int end, float x, float y)
    {
        Color c = mEffectColor;
        c.a *= finalAlpha;
        Color32 col = (bitmapFont != null && bitmapFont.premultipliedAlphaShader) ? NGUITools.ApplyPMA(c) : c;

        for (int i = start; i < end; ++i)
        {
            verts.Add(verts.buffer[i]);
            uvs.Add(uvs.buffer[i]);
            cols.Add(cols.buffer[i]);

            Vector3 v = verts.buffer[i];
            v.x += x;
            v.y += y;
            verts.buffer[i] = v;

            Color32 uc = cols.buffer[i];

            if (uc.a == 255)
            {
                cols.buffer[i] = col;
            }
            else
            {
                Color fc = c;
                fc.a = (uc.a / 255f * c.a);
                cols.buffer[i] = (bitmapFont != null && bitmapFont.premultipliedAlphaShader) ? NGUITools.ApplyPMA(fc) : fc;
            }
        }
    }

    /// <summary>
    /// Calculate the character index offset necessary in order to print the end of the specified text.
    /// </summary>

    public int CalculateOffsetToFit(string text)
    {
        UpdateNGUIText();
        NGUIText.encoding = false;
        NGUIText.symbolStyle = NGUIText.SymbolStyle.None;
        int offset = NGUIText.CalculateOffsetToFit(text);
        NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
        NGUIText.dynamicFont = null;
#endif
        return offset;
    }

    /// <summary>
    /// Convenience function, in case you wanted to associate progress bar, slider or scroll bar's
    /// OnValueChanged function in inspector with a label.
    /// </summary>

    public void SetCurrentProgress()
    {
        if (UIProgressBar.current != null)
            text = UIProgressBar.current.value.ToString("F");
    }

    /// <summary>
    /// Convenience function, in case you wanted to associate progress bar, slider or scroll bar's
    /// OnValueChanged function in inspector with a label.
    /// </summary>

    public void SetCurrentPercent()
    {
        if (UIProgressBar.current != null)
            text = Mathf.RoundToInt(UIProgressBar.current.value * 100f) + "%";
    }

    /// <summary>
    /// Convenience function, in case you wanted to automatically set some label's text
    /// by selecting a value in the UIPopupList.
    /// </summary>

    public void SetCurrentSelection()
    {
        if (UIPopupList.current != null)
        {
            text = UIPopupList.current.isLocalized ?
                Localization.Get(UIPopupList.current.value) :
                UIPopupList.current.value;
        }
    }

    /// <summary>
    /// Convenience function -- wrap the current text given the label's settings and unlimited height.
    /// </summary>

    public bool Wrap(string text, out string final) { return Wrap(text, out final, 1000000); }

    /// <summary>
    /// Convenience function -- wrap the current text given the label's settings and the given height.
    /// </summary>

    public bool Wrap(string text, out string final, int height)
    {
        UpdateNGUIText();
        NGUIText.rectHeight = height;
        NGUIText.regionHeight = height;
        bool retVal = NGUIText.WrapText(text, out final);
        NGUIText.bitmapFont = null;
#if DYNAMIC_FONT
        NGUIText.dynamicFont = null;
#endif
        return retVal;
    }

    /// <summary>
    /// Update NGUIText.current with all the properties from this label.
    /// </summary>

    public void UpdateNGUIText()
    {
        Font ttf = trueTypeFont;
        bool isDynamic = (ttf != null);

        NGUIText.fontSize = mPrintedSize;
        NGUIText.fontStyle = mFontStyle;
        NGUIText.rectWidth = mWidth;
        NGUIText.rectHeight = mHeight;
        NGUIText.regionWidth = Mathf.RoundToInt(mWidth * (mDrawRegion.z - mDrawRegion.x));
        NGUIText.regionHeight = Mathf.RoundToInt(mHeight * (mDrawRegion.w - mDrawRegion.y));
        NGUIText.gradient = mApplyGradient && (mFont == null || !mFont.packedFontShader);
        NGUIText.gradientTop = mGradientTop;
        NGUIText.gradientBottom = mGradientBottom;
        NGUIText.encoding = mEncoding;
        NGUIText.premultiply = mPremultiply;
        NGUIText.symbolStyle = mSymbols;
        NGUIText.maxLines = mMaxLineCount;
        NGUIText.spacingX = effectiveSpacingX;
        NGUIText.spacingY = effectiveSpacingY;
        NGUIText.fontScale = isDynamic ? mScale : ((float)mFontSize / mFont.defaultSize) * mScale;

        if (mFont != null)
        {
            NGUIText.bitmapFont = mFont;

            for (;;)
            {
                UIFont fnt = NGUIText.bitmapFont.replacement;
                if (fnt == null) break;
                NGUIText.bitmapFont = fnt;
            }

#if DYNAMIC_FONT
            if (NGUIText.bitmapFont.isDynamic)
            {
                NGUIText.dynamicFont = NGUIText.bitmapFont.dynamicFont;
                NGUIText.bitmapFont = null;
            }
            else NGUIText.dynamicFont = null;
#endif
        }
#if DYNAMIC_FONT
        else
        {
            NGUIText.dynamicFont = ttf;
            NGUIText.bitmapFont = null;
        }

        if (isDynamic && keepCrisp)
        {
            UIRoot rt = root;
            if (rt != null) NGUIText.pixelDensity = (rt != null) ? rt.pixelSizeAdjustment : 1f;
        }
        else NGUIText.pixelDensity = 1f;

        if (mDensity != NGUIText.pixelDensity)
        {
            ProcessText(false, false);
            NGUIText.rectWidth = mWidth;
            NGUIText.rectHeight = mHeight;
            NGUIText.regionWidth = Mathf.RoundToInt(mWidth * (mDrawRegion.z - mDrawRegion.x));
            NGUIText.regionHeight = Mathf.RoundToInt(mHeight * (mDrawRegion.w - mDrawRegion.y));
        }
#endif

        if (alignment == Alignment.Automatic)
        {
            Pivot p = pivot;

            if (p == Pivot.Left || p == Pivot.TopLeft || p == Pivot.BottomLeft)
            {
                NGUIText.alignment = Alignment.Left;
            }
            else if (p == Pivot.Right || p == Pivot.TopRight || p == Pivot.BottomRight)
            {
                NGUIText.alignment = Alignment.Right;
            }
            else NGUIText.alignment = Alignment.Center;
        }
        else NGUIText.alignment = alignment;

        NGUIText.Update();
    }

    public void SetAlignment(int p_alignment)
    {
        this.alignment = (Alignment)p_alignment;
    }
}
