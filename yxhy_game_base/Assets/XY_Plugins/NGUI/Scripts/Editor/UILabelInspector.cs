//----------------------------------------------
//            NGUI: Next-Gen UI kit
// Copyright © 2011-2015 Tasharen Entertainment
//----------------------------------------------

#if !UNITY_FLASH
#define DYNAMIC_FONT
#endif

using UnityEngine;
using UnityEditor;

/// <summary>
/// Inspector class used to edit UILabels.
/// </summary>

[CanEditMultipleObjects]
[CustomEditor(typeof(UILabel), true)]
public class UILabelInspector : UIWidgetInspector
{
	public enum FontType
	{
		NGUI,
		Unity,
	}

	UILabel mLabel;
	FontType mFontType;

	//fuckby cjl
	UILabel.stMyFormatData noneFromatData;//none时的数据
	UILabel.stMyFormatData tempData;
	UILabel.MyFormat mCurrFromat = UILabel.MyFormat.None;

    GenericMenu menu;


    void UpdateMyFormat()
	{
		if (mLabel == null) return;
		mLabel.myFormat = mCurrFromat;
		if (mCurrFromat == UILabel.MyFormat.None)
		{
			//tempData = noneFromatData;
			return;//None不做任何处理
		}
		else
		{
			tempData.reinit();
			UILabel.getMyFormatData(mCurrFromat, ref tempData);
		}

		//根据tempData保存serializedObject
		serializedObject.Update();
		//Gradient
		var sp = serializedObject.FindProperty("mApplyGradient");
		sp.boolValue = tempData.m_isGradient;
		if (tempData.m_isGradient)
		{
			sp = serializedObject.FindProperty("mGradientTop");
			sp.colorValue = tempData.m_gradientUp;

			sp = serializedObject.FindProperty("mGradientBottom");
			sp.colorValue = tempData.m_gradientDown;
		}

        sp = serializedObject.FindProperty("mMyFormat");
        sp.intValue = (int)mCurrFromat;
		//effect
		sp = serializedObject.FindProperty("mEffectStyle");
		sp.intValue = (int)tempData.m_effect;
		if(tempData.m_effect!= UILabel.Effect.None)
		{
			sp = serializedObject.FindProperty("mEffectColor");
			sp.colorValue = tempData.m_effectColor;

			sp = serializedObject.FindProperty("mEffectDistance");
			sp.vector2Value = tempData.m_effectDistance;
		}
		//orgColor
		sp = serializedObject.FindProperty("mColor");
		sp.colorValue = tempData.m_orgColor;

		//fontSize
		sp = serializedObject.FindProperty("mFontSize");
		if (tempData.m_fontSize > 0)
		{
			sp.intValue = tempData.m_fontSize;
		}

		serializedObject.ApplyModifiedProperties();
	}
	//end cjl

    void OnMenuItemClick(object data)
    {
        if(mCurrFromat != (UILabel.MyFormat)data)
        {
            mCurrFromat = (UILabel.MyFormat)data;
            UpdateMyFormat();
        }
    }

    protected void InitMenu()
    {
        menu = new GenericMenu();
        menu.AddItem(new GUIContent("None"), false, OnMenuItemClick, UILabel.MyFormat.None);
        for(int i = (int)UILabel.MyFormat.A; i <= (int)UILabel.MyFormat.Z; i++)
        {
            UILabel.MyFormat format = (UILabel.MyFormat)i;
            menu.AddItem(new GUIContent("A-Z/" + format.ToString()), false, OnMenuItemClick, i);
        }

        for (int i = (int)UILabel.MyFormat.A1; i <= (int)UILabel.MyFormat.A14; i++)
        {
            UILabel.MyFormat format = (UILabel.MyFormat)i;
            menu.AddItem(new GUIContent("A1-A14/" + format.ToString()), false, OnMenuItemClick, i);
        }

        int count = 0;
        for (int i = (int)UILabel.MyFormat.F1; i < (int)UILabel.MyFormat.MAX; i++)
        {
            UILabel.MyFormat format = (UILabel.MyFormat)i;
            int decade = count / 10;

            string menuContent = string.Format("{0}-{1}/", decade * 10 + 1, ((decade + 1) * 10));

            menu.AddItem(new GUIContent(menuContent + format.ToString()), false, OnMenuItemClick, i);

            count++;
        }
    }

	protected override void OnEnable ()
	{
		base.OnEnable();
		SerializedProperty bit = serializedObject.FindProperty("mFont");
		mFontType = (bit != null && bit.objectReferenceValue != null) ? FontType.NGUI : FontType.Unity;

        InitMenu();
        //fuckby cjl
        UILabel _Label = mWidget as UILabel;
		if(_Label!=null)
		{
			mCurrFromat = _Label.myFormat;
			if (UILabel.MyFormat.None == mCurrFromat)
			{
				_Label.cloneMyFormatData(ref noneFromatData);
			}
		}
		//end cjl
	}

	void OnNGUIFont (Object obj)
	{
		serializedObject.Update();
		SerializedProperty sp = serializedObject.FindProperty("mFont");
		sp.objectReferenceValue = obj;
		serializedObject.ApplyModifiedProperties();
		NGUISettings.ambigiousFont = obj;
	}

	void OnUnityFont (Object obj)
	{
		serializedObject.Update();
		SerializedProperty sp = serializedObject.FindProperty("mTrueTypeFont");
		sp.objectReferenceValue = obj;
		serializedObject.ApplyModifiedProperties();
		NGUISettings.ambigiousFont = obj;
	}

	/// <summary>
	/// Draw the label's properties.
	/// </summary>

	protected override bool ShouldDrawProperties ()
	{
		mLabel = mWidget as UILabel;

		//fuckby cjl
		GUILayout.BeginHorizontal();
		SerializedProperty omf = NGUIEditorTools.DrawProperty("MyFormat", serializedObject, "mMyFormat");
		if (mCurrFromat != (UILabel.MyFormat)omf.intValue)
		{
			mCurrFromat = (UILabel.MyFormat)omf.intValue;
			//刷新字体
			UpdateMyFormat();
		}

        if(GUILayout.Button("select", GUILayout.Width(80)))
        {
            //GenericMenu menu = new GenericMenu();
            //menu.AddItem(new GUIContent("A-Z/Z"), false, null, "");
            //menu.AddItem(new GUIContent("A-Z/A"), false, null, "");
            //menu.AddItem(new GUIContent("1-10/F1"), false, null, "");
            menu.ShowAsContext();
        }

		GUILayout.EndHorizontal();
		//end cjl

		GUILayout.BeginHorizontal();

#if DYNAMIC_FONT
		mFontType = (FontType)EditorGUILayout.EnumPopup(mFontType, "DropDown", GUILayout.Width(74f));
		if (NGUIEditorTools.DrawPrefixButton("Font", GUILayout.Width(64f)))
#else
		mFontType = FontType.NGUI;
		if (NGUIEditorTools.DrawPrefixButton("Font", GUILayout.Width(74f)))
#endif
		{
			if (mFontType == FontType.NGUI)
			{
				ComponentSelector.Show<UIFont>(OnNGUIFont);
			}
			else
			{
				ComponentSelector.Show<Font>(OnUnityFont, new string[] { ".ttf", ".otf" });
			}
		}

		bool isValid = false;
		SerializedProperty fnt = null;
		SerializedProperty ttf = null;

		if (mFontType == FontType.NGUI)
		{
			fnt = NGUIEditorTools.DrawProperty("", serializedObject, "mFont", GUILayout.MinWidth(40f));

			if (fnt.objectReferenceValue != null)
			{
				NGUISettings.ambigiousFont = fnt.objectReferenceValue;
				isValid = true;
			}
		}
		else
		{
			ttf = NGUIEditorTools.DrawProperty("", serializedObject, "mTrueTypeFont", GUILayout.MinWidth(40f));

			if (ttf.objectReferenceValue != null)
			{
				NGUISettings.ambigiousFont = ttf.objectReferenceValue;
				isValid = true;
			}
		}

		GUILayout.EndHorizontal();

		if (mFontType == FontType.Unity)
		{
			EditorGUILayout.HelpBox("Dynamic fonts suffer from issues in Unity itself where your characters may disappear, get garbled, or just not show at times. Use this feature at your own risk.\n\n" +
				"When you do run into such issues, please submit a Bug Report to Unity via Help -> Report a Bug (as this is will be a Unity bug, not an NGUI one).", MessageType.Warning);
		}

		EditorGUI.BeginDisabledGroup(!isValid);
		{
			UIFont uiFont = (fnt != null) ? fnt.objectReferenceValue as UIFont : null;
			Font dynFont = (ttf != null) ? ttf.objectReferenceValue as Font : null;

			if (uiFont != null && uiFont.isDynamic)
			{
				dynFont = uiFont.dynamicFont;
				uiFont = null;
			}

			if (dynFont != null)
			{
				GUILayout.BeginHorizontal();
				{
					EditorGUI.BeginDisabledGroup((ttf != null) ? ttf.hasMultipleDifferentValues : fnt.hasMultipleDifferentValues);
					
					SerializedProperty prop = NGUIEditorTools.DrawProperty("Font Size", serializedObject, "mFontSize", GUILayout.Width(142f));
					NGUISettings.fontSize = prop.intValue;
					
					prop = NGUIEditorTools.DrawProperty("", serializedObject, "mFontStyle", GUILayout.MinWidth(40f));
					NGUISettings.fontStyle = (FontStyle)prop.intValue;
					
					NGUIEditorTools.DrawPadding();
					EditorGUI.EndDisabledGroup();
				}
				GUILayout.EndHorizontal();

				NGUIEditorTools.DrawProperty("Material", serializedObject, "mMaterial");
			}
			else if (uiFont != null)
			{
				GUILayout.BeginHorizontal();
				SerializedProperty prop = NGUIEditorTools.DrawProperty("Font Size", serializedObject, "mFontSize", GUILayout.Width(142f));

				EditorGUI.BeginDisabledGroup(true);
				if (!serializedObject.isEditingMultipleObjects)
					GUILayout.Label(" Default: " + mLabel.defaultFontSize);
				EditorGUI.EndDisabledGroup();

				NGUISettings.fontSize = prop.intValue;
				GUILayout.EndHorizontal();
			}

			bool ww = GUI.skin.textField.wordWrap;
			GUI.skin.textField.wordWrap = true;
			SerializedProperty sp = serializedObject.FindProperty("mText");

			if (sp.hasMultipleDifferentValues)
			{
				NGUIEditorTools.DrawProperty("", sp, GUILayout.Height(128f));
			}
			else
			{
				GUIStyle style = new GUIStyle(EditorStyles.textField);
				style.wordWrap = true;

				float height = style.CalcHeight(new GUIContent(sp.stringValue), Screen.width - 100f);
				bool offset = true;

				if (height > 90f)
				{
					offset = false;
					height = style.CalcHeight(new GUIContent(sp.stringValue), Screen.width - 20f);
				}
				else
				{
					GUILayout.BeginHorizontal();
					GUILayout.BeginVertical(GUILayout.Width(76f));
					GUILayout.Space(3f);
					GUILayout.Label("Text");
					GUILayout.EndVertical();
					GUILayout.BeginVertical();
				}
				Rect rect = EditorGUILayout.GetControlRect(GUILayout.Height(height));

				GUI.changed = false;
				string text = EditorGUI.TextArea(rect, sp.stringValue, style);
				if (GUI.changed) sp.stringValue = text;

				if (offset)
				{
					GUILayout.EndVertical();
					GUILayout.EndHorizontal();
				}
			}

			GUI.skin.textField.wordWrap = ww;

			SerializedProperty ov = NGUIEditorTools.DrawPaddedProperty("Overflow", serializedObject, "mOverflow");
			NGUISettings.overflowStyle = (UILabel.Overflow)ov.intValue;

			NGUIEditorTools.DrawPaddedProperty("Alignment", serializedObject, "mAlignment");

			if (dynFont != null)
				NGUIEditorTools.DrawPaddedProperty("Keep crisp", serializedObject, "keepCrispWhenShrunk");

			EditorGUI.BeginDisabledGroup(mLabel.bitmapFont != null && mLabel.bitmapFont.packedFontShader);
			GUILayout.BeginHorizontal();
			SerializedProperty gr = NGUIEditorTools.DrawProperty("Gradient", serializedObject, "mApplyGradient",
			GUILayout.Width(95f));

			EditorGUI.BeginDisabledGroup(!gr.hasMultipleDifferentValues && !gr.boolValue);
			{
				NGUIEditorTools.SetLabelWidth(30f);
				NGUIEditorTools.DrawProperty("Top", serializedObject, "mGradientTop", GUILayout.MinWidth(40f));
				GUILayout.EndHorizontal();
				GUILayout.BeginHorizontal();
				NGUIEditorTools.SetLabelWidth(50f);
				GUILayout.Space(79f);

				NGUIEditorTools.DrawProperty("Bottom", serializedObject, "mGradientBottom", GUILayout.MinWidth(40f));
				NGUIEditorTools.SetLabelWidth(80f);
			}
			EditorGUI.EndDisabledGroup();
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Label("Effect", GUILayout.Width(76f));
			sp = NGUIEditorTools.DrawProperty("", serializedObject, "mEffectStyle", GUILayout.MinWidth(16f));

			EditorGUI.BeginDisabledGroup(!sp.hasMultipleDifferentValues && !sp.boolValue);
			{
				NGUIEditorTools.DrawProperty("", serializedObject, "mEffectColor", GUILayout.MinWidth(10f));
				GUILayout.EndHorizontal();

				GUILayout.BeginHorizontal();
				{
					GUILayout.Label(" ", GUILayout.Width(56f));
					NGUIEditorTools.SetLabelWidth(20f);
					NGUIEditorTools.DrawProperty("X", serializedObject, "mEffectDistance.x", GUILayout.MinWidth(40f));
					NGUIEditorTools.DrawProperty("Y", serializedObject, "mEffectDistance.y", GUILayout.MinWidth(40f));
					NGUIEditorTools.DrawPadding();
					NGUIEditorTools.SetLabelWidth(80f);
				}
			}
			EditorGUI.EndDisabledGroup();
			GUILayout.EndHorizontal();
			EditorGUI.EndDisabledGroup();

			sp = NGUIEditorTools.DrawProperty("Float spacing", serializedObject, "mUseFloatSpacing", GUILayout.Width(100f));

			if (!sp.boolValue)
			{
				GUILayout.BeginHorizontal();
				GUILayout.Label("Spacing", GUILayout.Width(56f));
				NGUIEditorTools.SetLabelWidth(20f);
				NGUIEditorTools.DrawProperty("X", serializedObject, "mSpacingX", GUILayout.MinWidth(40f));
				NGUIEditorTools.DrawProperty("Y", serializedObject, "mSpacingY", GUILayout.MinWidth(40f));
				NGUIEditorTools.DrawPadding();
				NGUIEditorTools.SetLabelWidth(80f);
				GUILayout.EndHorizontal();
			}
			else
			{
				GUILayout.BeginHorizontal();
				GUILayout.Label("Spacing", GUILayout.Width(56f));
				NGUIEditorTools.SetLabelWidth(20f);
				NGUIEditorTools.DrawProperty("X", serializedObject, "mFloatSpacingX", GUILayout.MinWidth(40f));
				NGUIEditorTools.DrawProperty("Y", serializedObject, "mFloatSpacingY", GUILayout.MinWidth(40f));
				NGUIEditorTools.DrawPadding();
				NGUIEditorTools.SetLabelWidth(80f);
				GUILayout.EndHorizontal();
			}
			
			NGUIEditorTools.DrawProperty("Max Lines", serializedObject, "mMaxLineCount", GUILayout.Width(110f));

			GUILayout.BeginHorizontal();
			sp = NGUIEditorTools.DrawProperty("BBCode", serializedObject, "mEncoding", GUILayout.Width(100f));
			EditorGUI.BeginDisabledGroup(!sp.boolValue || mLabel.bitmapFont == null || !mLabel.bitmapFont.hasSymbols);
			NGUIEditorTools.SetLabelWidth(60f);
			NGUIEditorTools.DrawPaddedProperty("Symbols", serializedObject, "mSymbols");
			NGUIEditorTools.SetLabelWidth(80f);
			EditorGUI.EndDisabledGroup();
			GUILayout.EndHorizontal();
		}
		EditorGUI.EndDisabledGroup();
		return isValid;
	}
}
