@echo off
cd /d %~dp0
set path=C:\java\jdk-1.8\bin;%path%;

:change_package
set /p var=请输入aab包名（不包含.abb后缀）

:loop
set o=-1
echo.
echo 对%var%.aab进行操作
echo 1 - aab转apks
echo 2 - 安装apks到手机
echo 3 - 重新输入aab包名
echo 0 - exit
set /p o=请输入选项：
echo.

if /i "%o%"=="1" (
echo 处理 %var%.aab to %var%.apks ...
java -jar bundletool-all-1.7.0.jar build-apks --bundle=%var%.aab  --output=%var%.apks  --ks=GreenworksGreenGuide.keystore  --ks-pass=pass:Green2017!  --ks-key-alias=GreenworksGreenGuide --key-pass=pass:Green2017!
echo %var%.aab to %var%.apks 完成
) else if /i "%o%"=="2" (
echo 请在手机查看是否有同意调试或安装的选项，并且确保旧版本app已删除
java -jar bundletool-all-1.7.0.jar install-apks --apks=%var%.apks
echo %var%.apks 已发送到手机
) else if /i "%o%"=="3" (
goto change_package
) else if /i "%o%"=="0" (
goto loop_end
) else (
echo 请输入正确的选项
)
goto loop
:loop_end
