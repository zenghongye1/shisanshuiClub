using UnityEngine;
using System.Collections;

namespace SceneSystem
{
    public abstract class SceneProcessBase
    {
        abstract public void Start();
        abstract public void Stop();

        virtual public void Update(float detalTime) { }

        virtual public void Complete()
        {
            Stop();
            SceneMgr.Instance.NextProcess();
        }
    }
}
