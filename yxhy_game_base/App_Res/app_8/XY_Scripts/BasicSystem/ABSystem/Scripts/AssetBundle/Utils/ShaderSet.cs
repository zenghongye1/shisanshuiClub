using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ShaderSet : MonoBehaviour
{
    [Header("公共Shader")]
    public List<Shader> CommonShaderList = null;

    [Header("UI Shaders")]
    public List<Shader> UIShaderList = null;

    [Header("Effect Shaders")]
    public List<Shader> EffectShaderList = null;
}
