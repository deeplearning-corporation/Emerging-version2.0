@echo off
cd /d %~dp0
echo ========================================
echo µ÷ÊÔ±àÒë Emerging libc Ô´ÎÄ¼ş
echo Ä¿Â¼: %CD%
echo ========================================
echo.

:: ¼ì²éÔ´ÂëÄ¿Â¼
if not exist libc\src (
    echo [´íÎó] ÕÒ²»µ½Ô´ÂëÄ¿Â¼: %CD%\libc\src
    pause
    exit /b 1
)

:: ÏÔÊ¾Ô´ÂëÎÄ¼ş
echo Ô´ÂëÎÄ¼şÁĞ±í:
dir libc\src\*.asm
echo.

:: ´´½¨Ä¿±êÄ¿Â¼
if not exist obj mkdir obj

:: ±àÒëÃ¿¸öÎÄ¼ş²¢ÏÔÊ¾ÏêÏ¸´íÎó
cd libc\src

echo ±àÒë crt0.asm...
nasm -f win64 -o ..\..\obj\crt0.obj crt0.asm
if errorlevel 1 echo [´íÎó] crt0.asm ±àÒëÊ§°Ü & pause

echo ±àÒë stdio.asm...
nasm -f win64 -o ..\..\obj\stdio.obj stdio.asm
if errorlevel 1 echo [´íÎó] stdio.asm ±àÒëÊ§°Ü & pause

echo ±àÒë stdlib.asm...
nasm -f win64 -o ..\..\obj\stdlib.obj stdlib.asm
if errorlevel 1 echo [´íÎó] stdlib.asm ±àÒëÊ§°Ü & pause

echo ±àÒë string.asm...
nasm -f win64 -o ..\..\obj\string.obj string.asm
if errorlevel 1 echo [´íÎó] string.asm ±àÒëÊ§°Ü & pause

echo ±àÒë math.asm...
nasm -f win64 -o ..\..\obj\math.obj math.asm
if errorlevel 1 echo [´íÎó] math.asm ±àÒëÊ§°Ü & pause

echo ±àÒë memory.asm...
nasm -f win64 -o ..\..\obj\memory.obj memory.asm
if errorlevel 1 echo [´íÎó] memory.asm ±àÒëÊ§°Ü & pause

echo ±àÒë file.asm...
nasm -f win64 -o ..\..\obj\file.obj file.asm
if errorlevel 1 echo [´íÎó] file.asm ±àÒëÊ§°Ü & pause

echo ±àÒë time.asm...
nasm -f win64 -o ..\..\obj\time.obj time.asm
if errorlevel 1 echo [´íÎó] time.asm ±àÒëÊ§°Ü & pause

echo ±àÒë syscall.asm...
nasm -f win64 -o ..\..\obj\syscall.obj syscall.asm
if errorlevel 1 echo [´íÎó] syscall.asm ±àÒëÊ§°Ü & pause

cd ..\..
echo.
echo ========================================
echo ±àÒëÍê³É!
dir obj\*.obj
echo ========================================
pause