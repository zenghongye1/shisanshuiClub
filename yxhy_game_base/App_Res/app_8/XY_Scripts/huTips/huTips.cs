using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using UnityEngine;
using LitJson;

namespace TingInfo
{
    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct tagTINGINFO_NODE
    {

        /// unsigned char
        public byte bTing;

        /// int
        public int byTingFanNumber;

        /// unsigned char
        public byte szTingCard;

        /// unsigned char
        public byte szTingCardleft;
    }

    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct tagTING_NODE
    {

        /// TINGINFO_NODE[30]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 30, ArraySubType = System.Runtime.InteropServices.UnmanagedType.Struct)]
        public tagTINGINFO_NODE[] szTingInfo;

        /// unsigned char
        public byte szGiveCard;

        /// unsigned char
        public byte bCanTing;

        /// unsigned char
        public byte flag;

        /// unsigned char
        public byte bIsYouJin;
    }

    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct tagTING_COUNT
    {

        /// TING_NODE[17]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 17, ArraySubType = System.Runtime.InteropServices.UnmanagedType.Struct)]
        public tagTING_NODE[] m_TingNode;
    }



    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet = System.Runtime.InteropServices.CharSet.Ansi)]
    public struct tagENVIRONMENT
    {

        /// unsigned char
        public byte byChair;

        /// unsigned char
        public byte byTurn;

        /// unsigned char[68]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4*17)]
        public byte[] tHand;

        /// unsigned char[4]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] byHandCount;

        /// unsigned char[60]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 60)]
        public byte[] tSet;

        /// unsigned char[4]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] bySetCount;

        /// unsigned char[160]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 160)]
        public byte[] tGive;

        /// unsigned char[4]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] byGiveCount;

        /// unsigned char
        public byte tLast;

        /// unsigned char
        public byte byFlag;

        /// unsigned char
        public byte byRoundWind;

        /// unsigned char
        public byte byPlayerWind;

        /// unsigned char
        public byte byTilesLeft;

        /// unsigned char[4]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] byFlowerCount;

        /// unsigned char[4]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] byTing;

        /// unsigned char[4]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] byDoFirstGive;

        /// unsigned char[6]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 6)]
        public byte[] byRecv;

        /// unsigned char
        public byte gamestyle;

        /// unsigned char
        public byte qianggang;

        /// unsigned char
        public byte menqing;

        /// unsigned char
        public byte bkd;

        /// unsigned char
        public byte wukui;

        /// unsigned char
        public byte byDealer;

        /// unsigned char
        public byte qiangjin;

        /// unsigned char
        public byte laizi;

        /// unsigned char
        public byte flower;

        /// unsigned char[4]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] byLaiziCards;

        /// unsigned char
        public byte halfQYS;

        /// unsigned char
        public byte allQYS;

        /// unsigned char
        public byte goldDragon;

        /// unsigned char[37]
        [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 37)]
        public byte[] nNSNum;

        /// unsigned char
        public byte bankerfirst;
    }




    public class huTips
    {
#if !UNITY_EDITOR && UNITY_IPHONE
                        const string LUADLL = "__Internal";
#else
        const string LUADLL = "dstars";
#endif

        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        extern static void init();

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        extern static int TingCount();

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        extern static void setEnvironment(ref tagENVIRONMENT tn);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        extern static void getTingCount(ref tagTING_COUNT tn);

        

        public void initTing() {
            init();
        }

        public int checkTingCount() {
            return TingCount();
        }

        public string getTingInfo() {
            string tingJsonStr = "";
            JsonData data = new JsonData();
            data.SetJsonType(JsonType.Array);
            tagTING_COUNT tn = new tagTING_COUNT();
            getTingCount(ref tn);
            for (int i = 0; i < tn.m_TingNode.Length; i++)
            {
                tagTING_NODE tNode = tn.m_TingNode[i];
                //Debug.Log("tNode.bCanTing == " + tNode.bCanTing);
                //Debug.Log("tNode.bIsYouJin == " + tNode.bIsYouJin);
                //Debug.Log("tNode.flag == " + tNode.flag);
                //Debug.Log("tNode.szGiveCard == " + tNode.szGiveCard);
                //Debug.Log("tNode.bCanTing == " + tNode.bCanTing);
                if (tNode.bCanTing == 1) {
                    JsonData nodeJson = new JsonData();
                    nodeJson["bIsYouJin"] = tNode.bIsYouJin == 1 ? true : false;
                    nodeJson["flag"] = tNode.flag ;
                    nodeJson["give"] = tNode.szGiveCard;
                    nodeJson["win"] = new JsonData();
                    nodeJson["win"].SetJsonType(JsonType.Array);

                    for (int k = 0; k < tNode.szTingInfo.Length; k++)
                    {
                        tagTINGINFO_NODE ttNode = tNode.szTingInfo[k];
                        if (ttNode.szTingCard > 0)
                        {
                            JsonData itemData = new JsonData();
                            itemData["nFan"] = ttNode.byTingFanNumber;
                            itemData["nCard"] = ttNode.szTingCard;
                            itemData["nLeft"] = ttNode.szTingCardleft;

                            //Debug.Log("ttNode.bTing ====== " + ttNode.bTing);
                            //Debug.Log("ttNode.byTingFanNumber ====== " + ttNode.byTingFanNumber);
                            //Debug.Log("ttNode.szTingCard ====== " + ttNode.szTingCard);
                            //Debug.Log("ttNode.szTingCardleft ====== " + ttNode.szTingCardleft);
                            nodeJson["win"].Add(itemData);
                        }

                    }
                    data.Add(nodeJson);
                }
            }
            tingJsonStr = data.ToJson();
           // Debug.Log("getTingInfo--------------" + tingJsonStr);
            return tingJsonStr;
        }


        public void setTingEnvironment(string envJson) {
            //Debug.Log("huTips +++++++++ setTingEnvironment " + envJson);
            tagENVIRONMENT env = new tagENVIRONMENT();
            JsonData envJsonData = JsonMapper.ToObject(envJson);
            byte byChair = (byte)envJsonData["byChair"];
            byChair--;
            env.byChair = byChair;
            byte byTurn = (byte)envJsonData["byTurn"];
            byTurn--;
            env.byTurn = byTurn;
            byte tLast = (byte)envJsonData["tLast"];
            env.tLast = tLast;
            byte byFlag = (byte)envJsonData["byFlag"];
            env.byFlag = byFlag;
            byte byRoundWind = (byte)envJsonData["byRoundWind"];
            env.byRoundWind = byRoundWind;
            byte byPlayerWind = (byte)envJsonData["byPlayerWind"];
            env.byPlayerWind = byPlayerWind;
            byte byTilesLeft = (byte)envJsonData["byTilesLeft"];
            env.byTilesLeft = byTilesLeft;
            env.tHand = new byte[68];
            env.byHandCount = new byte[4];
            env.tSet = new byte[60];
            env.bySetCount = new byte[4];
            env.gamestyle = 36;
            env.tGive = new byte[160];
            env.byGiveCount = new byte[4];
            env.byFlowerCount = new byte[4];
            env.byTing = new byte[4];
            env.byDoFirstGive = new byte[4];
            env.byRecv = new byte[6];
            byte gamestyle = (byte)envJsonData["gamestyle"];
            env.gamestyle = gamestyle;
            byte qianggang = (byte)envJsonData["qianggang"];
            env.qianggang = qianggang;
            byte menqing = (byte)envJsonData["menqing"];
            env.menqing = menqing;
            byte bkd = (byte)envJsonData["bkd"];
            env.bkd = bkd;
            byte wukui = (byte)envJsonData["wukui"];
            env.wukui = wukui;
            byte byDealer = (byte)envJsonData["byDealer"];
            byDealer--;
            env.byDealer = byDealer;
            byte qiangjin = (byte)envJsonData["qiangjin"];
            env.qiangjin = qiangjin;
            byte laizi = (byte)envJsonData["laizi"];
            env.laizi = laizi;
            byte flower = (byte)envJsonData["flower"];
            env.flower = flower;
            env.byLaiziCards = new byte[4];

            byte halfQYS = (byte)envJsonData["halfQYS"];
            env.halfQYS = halfQYS;
            byte allQYS = (byte)envJsonData["allQYS"];
            env.allQYS = allQYS;
            byte goldDragon = (byte)envJsonData["goldDragon"];
            env.goldDragon = goldDragon;
            env.nNSNum = new byte[37];

            byte bankerfirst = (byte)envJsonData["bankerfirst"];
            env.bankerfirst = bankerfirst;
            
            JsonData tHandJson = envJsonData["tHand"];
            for (int i = 0; i < tHandJson.Count; i++) {
                JsonData tHand = tHandJson[i];
                for (int j =0; j< tHand.Count;j++ ) {
                    //byte n = (byte)tHand[j];
                    env.tHand[i * tHand.Count + j] = (byte)tHand[j];
                }
            }

            JsonData byHandCountJson = envJsonData["byHandCount"];
            for (int i = 0; i < byHandCountJson.Count; i++)
            {
                env.byHandCount[i] = (byte)byHandCountJson[i];
            }

            JsonData tSetJson = envJsonData["tSet"];
            for (int i = 0; i < tSetJson.Count; i++)
            {
                JsonData tSetJson1 = tSetJson[i];
                for (int j = 0; j < tSetJson1.Count; j++)
                {
                    JsonData tSetJson2 = tSetJson1[j];
                    for (int k = 0; k < tSetJson2.Count; k++)
                    {
                        //byte n = (byte)tSetJson2[k];
                        int index = i * (tSetJson1.Count* tSetJson2.Count) + j * tSetJson2.Count + k;
                        env.tSet[index] = (byte)tSetJson2[k];
                    }    
                }
            }

            JsonData bySetCountJson = envJsonData["bySetCount"];
            for (int i = 0; i < bySetCountJson.Count; i++)
            {
                env.bySetCount[i] = (byte)bySetCountJson[i];
            }

            JsonData tGiveJson = envJsonData["tGive"];
            for (int i = 0; i < tGiveJson.Count; i++)
            {
                JsonData tGive = tGiveJson[i];
                for (int j = 0; j < tGive.Count; j++)
                {
                    env.tGive[i * tGive.Count + j] = (byte)tGive[j];
                }
            }

            JsonData byGiveCountJson = envJsonData["byGiveCount"];
            for (int i = 0; i < byGiveCountJson.Count; i++)
            {
                env.byGiveCount[i] = (byte)byGiveCountJson[i];
            }

            JsonData byFlowerCountJson = envJsonData["byFlowerCount"];
            for (int i = 0; i < byFlowerCountJson.Count; i++)
            {
                env.byFlowerCount[i] = (byte)byFlowerCountJson[i];
            }

            JsonData byTingJson = envJsonData["byTing"];
            for (int i = 0; i < byTingJson.Count; i++)
            {
                env.byTing[i] = (byte)byTingJson[i];
            }

            JsonData byDoFirstGiveJson = envJsonData["byDoFirstGive"];
            for (int i = 0; i < byDoFirstGiveJson.Count; i++)
            {
                env.byDoFirstGive[i] = (byte)byDoFirstGiveJson[i];
            }
            JsonData byRecvJson = envJsonData["byRecv"];
            for (int i = 0; i < byRecvJson.Count; i++)
            {
                env.byRecv[i] = (byte)byRecvJson[i];
            }
            JsonData byLaiziCardsJson = envJsonData["byLaiziCards"];
            for (int i = 0; i < byLaiziCardsJson.Count; i++)
            {
                env.byLaiziCards[i] = (byte)byLaiziCardsJson[i];
            }
            JsonData nNSNumJson = envJsonData["nNSNum"];
            for (int i = 0; i < nNSNumJson.Count; i++)
            {
                env.nNSNum[i] = (byte)nNSNumJson[i];
            }

            setEnvironment(ref env);
        }

    }
}
