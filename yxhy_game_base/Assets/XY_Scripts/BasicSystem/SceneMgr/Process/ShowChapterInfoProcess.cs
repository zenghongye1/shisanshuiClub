using System;
using UnityEngine;
using System.Collections;
using Framework;
using LuaInterface;
using SceneSystem;

public class ShowChapterInfoProcess : SceneProcessBase
{
    private float _duration;
    private Coroutine _coroutine;

    public override void Start()
    {
        LuaFunction func = LuaClient.GetMainState()
            .GetFunction("show_chapter_info_mgr.OnLevelLoading");

        func.BeginPCall();
        func.Push(SceneMgr.Instance.SceneId);
        func.PCall();
        _duration = (float)func.CheckNumber();
        func.EndPCall();
        func.Dispose();

        if (_duration > 0)
        {
            _coroutine = GameKernel.Instance.StartCoroutine(WaitFinish());
        }
        else
        {
            Complete();
        }

    }

    private IEnumerator WaitFinish()
    {
        yield return new WaitForSeconds(_duration);
        Complete();
    }

    public override void Stop()
    {
        if (_coroutine != null)
        {
            GameKernel.Instance.StopCoroutine(_coroutine);
            _coroutine = null;
        }
    }
}
