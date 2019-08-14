cd %~dp0
del libs /a/q/s
del obj /a/q/s

ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=Application.mk