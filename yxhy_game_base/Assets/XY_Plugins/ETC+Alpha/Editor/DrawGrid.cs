using UnityEngine;
using System.Collections;

public class DrawGrid {

    static DrawGrid _inst = null;

	public static void Done() 
    {
		if (_inst != null) 
        {
			_inst.DestroyTexture();
			_inst = null;
		}
	}

	const int TextureSize = 16;

	public static void Draw(Rect rect) 
    {
		Draw(rect, Vector2.zero);
	}

	public static void Draw(Rect rect, Vector2 offset) {
		if (_inst == null) {
            _inst = new DrawGrid();
			_inst.InitTexture();
		}
		GUI.DrawTextureWithTexCoords(rect, _inst._gridTexture, new Rect(-offset.x / TextureSize, (offset.y - rect.height) / TextureSize, rect.width / TextureSize, rect.height / TextureSize), false);
	} 

	private Texture2D _gridTexture = null;

	void InitTexture() 
    {
		if (_gridTexture == null) 
        {
			_gridTexture = new Texture2D(TextureSize, TextureSize);
			Color c0 = new Color32( 37,  37,  37, 255);
            Color c1 = new Color32(31, 31, 31, 255); 

			for (int y = 0; y < _gridTexture.height; ++y)
			{
				for (int x = 0; x < _gridTexture.width; ++x)
				{
					bool xx = (x < _gridTexture.width / 2);
					bool yy = (y < _gridTexture.height / 2);
					_gridTexture.SetPixel(x, y, (xx == yy)?c0:c1);
				}
			}
			_gridTexture.Apply();
			_gridTexture.filterMode = FilterMode.Point;
			_gridTexture.hideFlags = HideFlags.HideAndDontSave;
		}
	}

	void DestroyTexture() 
    {
		if (_gridTexture != null) 
        {
			Object.DestroyImmediate(_gridTexture);
			_gridTexture = null;
		}
	}
}
