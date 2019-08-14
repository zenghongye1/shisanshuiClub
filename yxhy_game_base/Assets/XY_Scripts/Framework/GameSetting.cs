/********************************************************************
	created:	2017/05/15  11:03
	file base:	GameSetting
	file ext:	cs
	author:		shine
	
	purpose:	游戏设置，如屏幕睡眠，屏幕分辨率，帧率等
*********************************************************************/

using UnityEngine;
using System.Collections;

namespace Framework
{
    public class GameSetting
    {
        public void InitSetting()
        {
            Screen.sleepTimeout = SleepTimeout.NeverSleep;

            RuntimePlatform platform =  Application.platform;
            //if (platform != RuntimePlatform.IPhonePlayer)
            //{
            //    if (platform != RuntimePlatform.WindowsPlayer)
            //    {
            //        UnGfx.SetResolution(640, false);
            //    }
            //}
            //else
            //{
            //    handleIOSDeviceScreen();
            //}

            //-- android直接先限制到40吧 ,苹果60，暂为测试使用
            if (platform == UnityEngine.RuntimePlatform.Android || platform == RuntimePlatform.IPhonePlayer)
                Application.targetFrameRate = 60;
            else
                UnityEngine.Application.targetFrameRate = 60;
        }
        
        void handleIOSDeviceScreen()
        {
            double dstHeight = Screen.height;

            if (dstHeight > 1024)
            {
                dstHeight = dstHeight * 0.75;

                if (dstHeight > 1024)
                    dstHeight = 1024;
            }

         //   UnGfx.SetResolution((int)dstHeight, false);
            UnGfx.SetResolution((int)dstHeight, true);
        }
    }
}