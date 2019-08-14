using UnityEngine;
using System.Collections;

public class ScrollViewMoveFixed : MonoBehaviour {

    bool isButtonDown = false;
    float translateX;
    float mouseDownPostionX;
    int i = 0;
    int numActive = 0;

    enum NowShow
    {
        pic1,
        pic2,
        pic3
    }
    NowShow show = NowShow.pic1;
    void Start()
    {
        Transform trans = transform.GetChild(0); 
        for (int i = 0; i < trans.transform.childCount; i++)
        {
            if (trans.GetChild(i).gameObject.activeSelf)
            {
                numActive++;
            }
        }
        Debug.Log(numActive);
        translateX = transform.FindChild("userGrid").GetComponent<UIGrid>().cellWidth;
    }

    void Update()
    {
        if ((!isButtonDown) && Input.GetMouseButtonDown(0))
        {
            isButtonDown = true;
            mouseDownPostionX = transform.localPosition.x;
        }
        if (Input.GetMouseButtonUp(0))
        {
            float distanceAbs = Mathf.Abs(mouseDownPostionX - transform.localPosition.x);
            if ( distanceAbs > 150)
            {
                if (mouseDownPostionX < transform.localPosition.x) //向右滑动
                {
                    if (distanceAbs < translateX + 150)
                        ShowLeft();
                    else if (distanceAbs > translateX + 150 )
                    {
                        ShowLeft();
                        ShowLeft();
                    }
                        
                }
                else if (mouseDownPostionX > transform.localPosition.x) //向左滑动
                {
                    if (distanceAbs < translateX + 150)
                        ShowRight();
                    else if (distanceAbs > translateX + 150)
                    {
                        ShowRight();
                        ShowRight();
                    }
                }
            }
            isButtonDown = false;
        }
        if (!isButtonDown)
        {
            UpdatePic();
        }
    }
    /// <summary>
    /// 移动位置到中间
    /// </summary>
    void UpdatePic()
    {
        i = (int)show;
        float x = Mathf.Lerp(transform.localPosition.x, -translateX * (i - 1), Time.deltaTime * 15);
        transform.localPosition = new Vector3(x, transform.localPosition.y, transform.localPosition.z);
        GetComponent<UIPanel>().clipOffset = new Vector2(-x, GetComponent<UIPanel>().clipOffset.y);
    }
    /// <summary>
    /// 向左移动
    /// </summary>
    void ShowLeft()
    {
        if (show != NowShow.pic1)
        {
            show--;
        }
    }
    /// <summary>
    /// 向右移动
    /// </summary>
    void ShowRight()
    {
        if (numActive == 5)
        {
            if (show != NowShow.pic3)
            {
                show++;
            }
        }
        else
        {
            if (show != NowShow.pic2)
            {
                show++;
            }
        }
    }
}
