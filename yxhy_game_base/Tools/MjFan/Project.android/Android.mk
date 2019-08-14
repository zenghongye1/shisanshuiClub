LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE     := dstars
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../Source
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../jsoncpp-src-0.5.0/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../jsoncpp-src-0.5.0/lib_json/json

MY_CPP_LIST := $(wildcard $(LOCAL_PATH)/../Source/*.cpp)
MY_CPP_LIST += $(wildcard $(LOCAL_PATH)/../Source/common/*.cpp)
MY_CPP_LIST += $(wildcard $(LOCAL_PATH)/../Source/mj/*.cpp)
MY_CPP_LIST += $(wildcard $(LOCAL_PATH)/../jsoncpp-src-0.5.0/lib_json/*.cpp)

LOCAL_SRC_FILES := $(MY_CPP_LIST:$(LOCAL_PATH)/%=%)
 
LOCAL_LDLIBS     := -llog -landroid
LOCAL_CFLAGS    := -DANDROID_NDK

include $(BUILD_SHARED_LIBRARY)