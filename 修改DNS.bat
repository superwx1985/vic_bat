@echo off
:: Check for Administrator rights
openfiles >nul 2>&1
if '%errorlevel%' neq '0' (
    echo Requesting administrator rights...
    goto UACPrompt
) else ( 
    goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~f0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

@echo off
setlocal enabledelayedexpansion

REM 设置域名和DNS服务器
set /p DOMAIN=请输入需要解析的域名: 
set DEFAULT_DNS=114.114.114.114
set /p DNS=请输入DNS(默认是%DEFAULT_DNS%): 
if "%DNS%"=="" (
    set DNS=%DEFAULT_DNS%
)

REM 查询域名的DNS
for /f "tokens=2" %%a in ('nslookup -type^=A %DOMAIN% %DNS% ^| find "Addresses:"') do set IP=%%a
if "%IP%"=="" (
    echo ##### 通过 %DNS% 没有解析到 %DOMAIN% 的IP #####
    goto end
) else (
    echo ##### 通过 %DNS% 解析到 %DOMAIN% 的IP是 %IP% #####
)

REM 检查域名是否已经存在于hosts文件
findstr /i %DOMAIN% %windir%\System32\drivers\etc\hosts >nul

if %errorlevel% equ 0 (
    REM 如果存在，则修改该条目
    for /f "tokens=1,* delims=:" %%a in ('findstr /n /i %DOMAIN% %windir%\System32\drivers\etc\hosts') do (
        set LINE=%%a
        set CONTENT=%%b
        goto replaceLine
    )
) else (
    REM 如果不存在，则添加新条目
    echo %IP% %DOMAIN%>> %windir%\System32\drivers\etc\hosts
    goto flushdns
)

:replaceLine
REM 创建临时文件
set newfile=%temp%\newhosts.tmp
REM 读取hosts文件并修改指定行
(
    for /f "delims=" %%i in (%windir%\System32\drivers\etc\hosts) do (
        set /a x+=1
        if "!x!"=="%LINE%" (
            echo %IP% %DOMAIN%
        ) else (
            echo %%i
        )
    )
) > %newfile%

REM 覆盖原始文件
copy /y %newfile% %windir%\System32\drivers\etc\hosts >nul
del %newfile%
echo ##### 更新hosts文件 #####

:flushdns
REM 刷新DNS缓存
ipconfig /flushdns

:end
pause
goto :eof
