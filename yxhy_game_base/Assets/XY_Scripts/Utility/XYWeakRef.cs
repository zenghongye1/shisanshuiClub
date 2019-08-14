using UnityEngine;
using System.Collections;

/// <summary>
/// 封装弱引用的使用,适用于Unity Object
/// </summary>
/// <typeparam name="T"></typeparam>
public class XYWeakRef<T> where T : UnityEngine.Object
{
    public XYWeakRef(T target)
    {
        internalRef = new System.WeakReference(target);
    }

    public T Target
    {
        set
        {
            internalRef.Target = value;
        }

        get
        {
            if ( internalRef.Target != null )
            {
                T ret = internalRef.Target as T;
                return ret;
            }

            return null;
        }
    }

    public bool IsValid
    {
        get
        {
            return Target != null;
        }
    }

    public bool IsAliveInMono
    {
        get
        {
            return internalRef.IsAlive;
        }
    }

    System.WeakReference internalRef;
}
