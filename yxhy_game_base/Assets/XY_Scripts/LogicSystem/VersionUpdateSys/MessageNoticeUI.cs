using UnityEngine;
using System;
using System.Collections;

public class MessageNoticeUI : MonoBehaviour
{
    Transform _transform;
    GameObject _gameObject;
    GameObject _closeBtnGo;
    GameObject _yesBtnGo;
    GameObject _noBtnGo;
    
    UILabel _contentLabel;
    UILabel _tipsLabel;
    UILabel _yesBtnLabel;
    UILabel _noBtnLabel;

    UIGrid _grid;


    Action _yesCallback;
    Action _noCallback;

    private void Awake()
    {
        _transform = transform;
        _gameObject = gameObject;
        _closeBtnGo = GetGameObject("btn_close");
        UIEventListener.Get(_closeBtnGo).onClick = OnCloseBtnClick;
        _yesBtnGo = GetGameObject("btn_grid/btn_01");
        UIEventListener.Get(_yesBtnGo).onClick = OnYesBtnClick;
        _noBtnGo = GetGameObject("btn_grid/btn_02");
        UIEventListener.Get(_noBtnGo).onClick = OnNoBtnClick;

        _contentLabel = GetComponent<UILabel>("lab_content");
        _tipsLabel = GetComponent<UILabel>("tip");
        _tipsLabel.gameObject.SetActive(false);
        _yesBtnLabel = GetComponent<UILabel>("btn_grid/btn_01/Label");
        _noBtnLabel = GetComponent<UILabel>("btn_grid/btn_02/Label");
        _grid = GetComponent<UIGrid>("btn_grid");
    }

    void OnCloseBtnClick(GameObject go)
    {
        Close();
    }

    void OnYesBtnClick(GameObject go)
    {
        if(_yesCallback != null)
        {
            _yesCallback();
        }
        Close();
    }

    void OnNoBtnClick(GameObject go)
    {
        if (_noCallback != null)
        {
            _noCallback();
        }
        Close();
    }

    public void ShowTip(string label)
    {
        _tipsLabel.text = label;
        _tipsLabel.gameObject.SetActive(true);
    }

    public void ShowYesNoBox(string content, string yesLabel = "确 定", string noLabel ="取消", Action yesCallback = null, Action noCallback = null)
    {
        _contentLabel.text = content;
        _yesBtnLabel.text = yesLabel;
        _noBtnLabel.text = noLabel;
        _yesCallback = yesCallback;
        _noCallback = noCallback;
        gameObject.SetActive(true);
    }

    void Close()
    {
        _gameObject.SetActive(false);
        _yesCallback = null;
        _noCallback = null;
    }

    GameObject GetGameObject(string path)
    {
        var tr = _transform.Find(path);
        if (tr == null)
            return null;
        return tr.gameObject;
    }

    T GetComponent<T>(string path)
    {
        var go = GetGameObject(path);
        if (go == null)
            return default(T);
        return go.GetComponent<T>();
    }

    public static MessageNoticeUI CreateMessageNoticeUI()
    {
        UnityEngine.Object verUpdateObj = Resources.Load("UI/message_notice_ui");
        GameObject verUpdateGo = GameObject.Instantiate(verUpdateObj) as GameObject;
        verUpdateGo.transform.SetParent(GameObject.FindGameObjectWithTag("NGUI").transform, false);
        return NGUITools.AddMissingComponent<MessageNoticeUI>(verUpdateGo);
    }
}
