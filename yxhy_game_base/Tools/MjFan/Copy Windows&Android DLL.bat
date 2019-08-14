cd %~dp0

copy Project.android\libs\armeabi-v7a\libdstars.so ..\..\Assets\Plugins\Android\libs\armeabi-v7a /y
copy Project.android\libs\x86\libdstars.so ..\..\Assets\Plugins\Android\libs\x86 /y

copy Project.windows\Release\x64\dstars.dll ..\..\Assets\Plugins\x86_64 /y
copy Project.windows\Release\x86\dstars.dll ..\..\Assets\Plugins\x86 /y

pause