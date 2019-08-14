@echo off

set XLS_NAME=%1
set SHEET_NAME=%2
set DATA_DEST=%3



echo.
echo =========Compilation of %XLS_NAME%.xls=========


::---------------------------------------------------
::第一步，将xls经过xls_deploy_tool转成data和proto
::---------------------------------------------------
set STEP1_XLS2PROTO_PATH=step1_xls2proto

@echo on
cd %STEP1_XLS2PROTO_PATH%

@echo off
echo TRY TO DELETE TEMP FILES:
del *_pb2.py
del *_pb2.pyc
del *.proto
del *.data
del *.log
del *.txt

@echo on
python xls_deploy_tool.py %SHEET_NAME% ..\DataConfig\%XLS_NAME%.xlsx c



::---------------------------------------------------
::第二步：把proto翻译成lua
::---------------------------------------------------
cd ..

set STEP2_PROTO2LUA_PATH=.\step2_proto2lua
set PROTO_DESC=proto.protodesc
set SRC_OUT=..\src

cd %STEP2_PROTO2LUA_PATH%

@echo off
echo TRY TO DELETE TEMP FILES:
del *.cs
del *.protodesc
del *.txt


@echo on
dir ..\%STEP1_XLS2PROTO_PATH%\*.proto /b  > protolist.txt

@echo on
for /f "delims=." %%i in (protolist.txt) do protoc --proto_path=..\%STEP1_XLS2PROTO_PATH% ..\%STEP1_XLS2PROTO_PATH%\*.proto --plugin=protoc-gen-lua="protoc-gen-lua.bat" --lua_out=.\ 


cd ..

::---------------------------------------------------
::第三步：将data和cs拷到Assets里
::---------------------------------------------------

@echo off
set OUT_PATH=..\Assets
set DATA_DEST=Resources\ProtobufDataConfig
set LUA_DEST=XY_Lua\protobuf_conf_parser


@echo on
copy %STEP1_XLS2PROTO_PATH%\*.data %OUT_PATH%\%DATA_DEST%\*.bytes
copy %STEP2_PROTO2LUA_PATH%\*.lua %OUT_PATH%\%LUA_DEST%\*.lua

::---------------------------------------------------
::第四步：清除中间文件
::---------------------------------------------------
@echo off
echo TRY TO DELETE TEMP FILES:
cd %STEP1_XLS2PROTO_PATH%
del *_pb2.py
del *_pb2.pyc
del *.proto
del *.data
del *.log
del *.txt
cd ..
cd %STEP2_PROTO2LUA_PATH%
del *.lua
del *.protodesc
del *.txt
cd ..


@echo on