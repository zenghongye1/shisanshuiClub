using UnityEngine;
using System;
using System.Collections.Generic;

namespace Framework
{
    public interface IServiceLocator
    {
        void BindService<TServiceInterface>(object service) where TServiceInterface : class;
        object GetService(Type serviceType);
    }

    public sealed class ServiceContainer : IServiceLocator
    {
        Dictionary<Type, object> _serviceSearchMap = new Dictionary<Type, object>();
        public IEnumerable<object> AllServices 
        {
            get { return _serviceSearchMap.Values; }
        }

        public void BindService<TServiceInterface>(object service) where TServiceInterface : class
        {
            if (service is TServiceInterface)
            {
                if (!_serviceSearchMap.ContainsKey((typeof(TServiceInterface))))
                {
                    _serviceSearchMap.Add(typeof(TServiceInterface), service);
                }
                else
                {
                    throw new Exception(String.Format("KeyDuplicatedError when binding {0} of Type {1} to TServiceInterface {2}",
                        service, service.GetType(), typeof(TServiceInterface)));
                }
            }
            else
            {
                throw new Exception(String.Format("TypeError when binding {0} of Type {1} to TServiceInterface {2}", 
                    service, service.GetType(), typeof(TServiceInterface)));
            }
        }

        public TServiceInterface GetService<TServiceInterface>() where TServiceInterface : class
        {
            return _serviceSearchMap[typeof(TServiceInterface)] as TServiceInterface;
        }

        public object GetService(Type serviceType)
        {
            return _serviceSearchMap[serviceType];
        }
    }
}
