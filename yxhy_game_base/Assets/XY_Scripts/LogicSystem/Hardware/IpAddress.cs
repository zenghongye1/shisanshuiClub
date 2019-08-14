using UnityEngine;
using System.Collections;
using System.Net.NetworkInformation;
using System.Net.Sockets;


public class IpAddress
{
    private static string m_ipAddress = null;

    public static void Init()
    {
        if (m_ipAddress == null)
        {
            try
            {
                NetworkInterface[] adapters = NetworkInterface.GetAllNetworkInterfaces();
                foreach (NetworkInterface adapter in adapters)
                {
                    if (adapter.Supports(NetworkInterfaceComponent.IPv4))
                    {
                        UnicastIPAddressInformationCollection uniCast = adapter.GetIPProperties().UnicastAddresses;
                        if (uniCast.Count > 0)
                        {
                            foreach (UnicastIPAddressInformation uni in uniCast)
                            {
                                //得到IPv4的地址。 AddressFamily.InterNetwork指的是IPv4
                                if (uni.Address.AddressFamily == AddressFamily.InterNetwork)
                                {
                                    m_ipAddress = uni.Address.ToString();
                                    return;
                                }
                            }
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                LuaInterface.Debugger.LogWarning(string.Format("GetIpAddress: {0}", ex.ToString()));
            }
        }
    }

    /// <summary>
    /// 获取手机网络IP地址
    /// </summary>
    /// <returns></returns>
    public static string GetIpAddress()
    {
        return m_ipAddress;
    }
}
