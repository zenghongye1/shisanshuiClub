using UnityEngine;
using System.Collections;
using System;

namespace SceneSystem
{
    public class ShowLoadingUIProcess : SceneProcessBase
    {
        public string mTips = "";
        public override void Start()
        {
            UIComponentBase comBase = UISys.Instance.CreateUIByName(typeof(Loading).ToString());
            if (comBase != null)
            {
                Loading loading = comBase as Loading;
                if (loading != null)
                {
                    loading.SetLoadingDesc(mTips);
                }
            }
            //Messenger.BroadcastAsync<string>(MSG_DEFINE.MSG_SCENE_LOAD_LOADINGSCENE_COMPLETE, SceneMgr.Instance.CurrentScene);
            Complete();
        }

        public override void Stop()
        {

        }
    }
}
