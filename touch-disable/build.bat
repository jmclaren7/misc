@echo off
setlocal

:: Find the .NET Framework C# compiler
set CSC=
for %%I in (
    "%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    "%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) do (
    if exist %%I (
        set CSC=%%I
        goto :found
    )
)

echo ERROR: Could not find .NET Framework C# compiler
exit /b 1

:found
echo Using compiler: %CSC%
echo.

:: Create output directory
if not exist "bin" mkdir bin

:: Compile the application
echo Compiling TouchDisable.exe...
%CSC% /nologo /target:winexe /out:bin\TouchDisable.exe /win32manifest:app.manifest /win32icon:icon32.ico ^
    /reference:System.dll ^
    /reference:System.Drawing.dll ^
    /reference:System.Windows.Forms.dll ^
    Program.cs

if %ERRORLEVEL% neq 0 (
    echo.
    echo BUILD FAILED
    exit /b 1
)

echo.
echo BUILD SUCCESSFUL
echo Output: bin\TouchDisable.exe
echo.
echo NOTE: Run as Administrator to enable/disable touch screen
