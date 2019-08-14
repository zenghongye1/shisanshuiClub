cd %~dp0

xcopy Source\*.h  ..\..\Assets\Plugins\iOS\dstars\ /y/s
xcopy Source\*.def  ..\..\Assets\Plugins\iOS\dstars\ /y/s

xcopy Project.ios\build\libdstars.a  ..\..\Assets\Plugins\iOS\ /y
xcopy Project.mac\build\dstars.bundle  ..\..\Assets\Plugins\dstars.bundle\ /y/e/s

pause