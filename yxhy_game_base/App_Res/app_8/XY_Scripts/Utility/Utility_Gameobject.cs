using UnityEngine;
using LuaInterface;

public class Utility_GameObject
{
    /// <summary>
    /// 只能是当前transform下面的子节点 孙子节点要扩展 为了避免GC扩展自己另外写函数
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="go"></param>
    /// <returns></returns>
    static public T GetComponentInChild<T>(GameObject go) where T : Behaviour
    {
        T target = go.GetComponent<T>();
        if (target != null)
            return target;

        for (int i = 0; i < go.transform.childCount; i++)
        {
            target = go.transform.GetChild(i).GetComponent<T>();
            if (target != null)
                return target;
        }

        return null;
    }

    //避免几十kb的GC 特别函数 end

    static public T AddMonoBehaviour<T>(GameObject go) where T : Component
    {
        if (go != null)
        {
            var comp = go.GetComponent<T>();
            if (comp == null)
            {
                comp = go.AddComponent<T>();
            }
            return comp;
        }
        else
        {
            return null;
        }
    }

    static public void RemoveBehaviour<T>(GameObject go) where T : Component
    {
        if (go != null)
        {
            var comp = go.GetComponentInChildren<T>();
            if (comp != null)
            {
                GameObject.Destroy(comp);
            }
        }
    }

    static public void SetObjectPosion(GameObject goRet, Vector3 Pos, Vector3 Towards, Vector3 Scale)
    {
        goRet.transform.position = Pos;
        goRet.transform.forward = Towards;
        if (Scale != Vector3.zero) goRet.transform.localScale = Scale;
    }


    static public void RecursiveSetLayerVal(Transform node, int depth, int layer)
    {
        depth--;
        if (depth < 0 || node == null)
        {
            return;
        }
        for (int i = 0; i < node.childCount; ++i)
        {
            Transform child = node.GetChild(i);
            if (child != null)
            {
                child.gameObject.layer = layer;
                RecursiveSetLayerVal(child, depth, layer);
            }
        }
    }

}