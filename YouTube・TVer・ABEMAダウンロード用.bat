@echo off
setlocal enabledelayedexpansion
title yt-dlp Auto Downloader (YouTube/TVer/ABEMA)

echo ========================================================
echo  Video Auto Downloader
echo  (YouTube/TVer/ABEMA Supported)
echo ========================================================
echo.

REM --- yt-dlpの存在確認 ---
where yt-dlp >nul 2>nul
if %errorlevel% neq 0 (
    if not exist "yt-dlp.exe" (
        echo [ERROR] yt-dlp.exe not found.
        echo Please place yt-dlp.exe in this folder.
        pause
        exit /b
    )
)

:INPUT
echo Paste URL (YouTube, TVer, or ABEMA) and press Enter:
set /p "VIDEO_URL=> "

if "!VIDEO_URL!"=="" (
    goto :INPUT
)

echo.
echo --------------------------------------------------------
echo  Analyzing URL type...
echo --------------------------------------------------------

REM --- サービス判定ロジック ---

REM 1. Amazon Prime Video / Hulu (非対応) の判定と警告
echo "!VIDEO_URL!" | find /i "amazon.co.jp" >nul
if !errorlevel! equ 0 set "IS_DRM=1"
echo "!VIDEO_URL!" | find /i "hulu.jp" >nul
if !errorlevel! equ 0 set "IS_DRM=1"

if "!IS_DRM!"=="1" (
    echo.
    echo [X] UNSUPPORTED SERVICE DETECTED
    echo Amazon Prime Video and Hulu are protected by DRM.
    echo yt-dlp cannot download encrypted content from these services.
    echo.
    color 0c
    pause
    color 07
    goto :INPUT
)

REM 2. TVer判定
echo "!VIDEO_URL!" | find /i "tver.jp" >nul
if !errorlevel! equ 0 (
    echo.
    echo [i] TVer URL detected.
    echo [i] Skipping YouTube-specific checks.
    set "DL_OPTS="
    goto :DOWNLOAD_EXEC
)

REM 3. ABEMA判定 (新規追加)
echo "!VIDEO_URL!" | find /i "abema.tv" >nul
if !errorlevel! equ 0 (
    echo.
    echo [i] ABEMA URL detected.
    echo [i] Skipping YouTube-specific checks.
    REM ABEMAの場合、クライアントオプションが必要な場合があるため念のため最低限の設定で通過
    set "DL_OPTS="
    goto :DOWNLOAD_EXEC
)

REM --- YouTube用 判定ロジック (既存) ---
echo [i] YouTube/Other URL detected. Checking video type...

REM 結果を一時ファイルに書き出す
yt-dlp --print "%%(is_live)s" --no-warnings --no-playlist "!VIDEO_URL!" > "_is_live.tmp" 2>nul

REM 判定処理
set "IS_LIVE=False"
if exist "_is_live.tmp" (
    set /p IS_LIVE=<"_is_live.tmp"
    del "_is_live.tmp"
)

REM 判定結果による分岐
set "DL_OPTS="

echo !IS_LIVE! | find "True" > nul
if %errorlevel% equ 0 (
    echo.
    echo [!] LIVE STREAM DETECTED
    echo [!] Recording from start (--live-from-start)
    set "DL_OPTS=--live-from-start"
    color 0d
) else (
    echo.
    echo [i] Normal Video detected
    color 0b
)

:DOWNLOAD_EXEC
echo.
echo --------------------------------------------------------
echo  Downloading...
echo --------------------------------------------------------
echo.

REM --- ダウンロード実行 ---
yt-dlp !DL_OPTS! "!VIDEO_URL!"

if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Completed!
    color 0a
) else (
    echo.
    echo [ERROR] Download failed.
    echo Possible causes:
    echo  - Premium/DRM protected content (ABEMA Premium etc.)
    echo  - Invalid URL
    echo  - Network error
    color 0c
)

echo.
echo Press any key to continue...
pause > nul
color 07
goto :INPUT