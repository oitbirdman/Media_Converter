@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: ImageMagickがインストールされているか確認
where magick >nul 2>&1
if %errorlevel% neq 0 (
    echo [エラー] ImageMagickが見つかりません。
    echo ImageMagickをインストールしてから再実行してください。
    echo https://imagemagick.org/script/download.php
    pause
    exit /b
)

:: ファイルがドラッグ＆ドロップされているか確認
if "%~1"=="" (
    echo -------------------------------------------------------
    echo  画像をこのバッチファイルにドラッグ＆ドロップしてください。
    echo -------------------------------------------------------
    pause
    exit /b
)

:MENU
cls
echo =======================================================
echo  画像形式変換ツール (ImageMagick使用)
echo =======================================================
echo  変換したい形式の番号を入力してください。
echo.
echo  [1] JPEG (.jpg)
echo  [2] PNG  (.png)
echo  [3] GIF  (.gif)
echo  [4] WebP (.webp)
echo  [5] SVG  (.svg)
echo  [6] TIFF (.tiff)
echo  [7] BMP  (.bmp)
echo.
set /p "CHOICE=番号を入力してください (1-7): "

if "%CHOICE%"=="1" set "EXT=.jpg" & goto PROCESS
if "%CHOICE%"=="2" set "EXT=.png" & goto PROCESS
if "%CHOICE%"=="3" set "EXT=.gif" & goto PROCESS
if "%CHOICE%"=="4" set "EXT=.webp" & goto PROCESS
if "%CHOICE%"=="5" set "EXT=.svg" & goto PROCESS
if "%CHOICE%"=="6" set "EXT=.tiff" & goto PROCESS
if "%CHOICE%"=="7" set "EXT=.bmp" & goto PROCESS

echo 無効な選択です。もう一度入力してください。
pause
goto MENU

:PROCESS
echo.
echo 変換を開始します... 形式: %EXT%
echo.

:: ドラッグ＆ドロップされた全ファイルを処理
:LOOP
if "%~1"=="" goto END

set "INPUT_FILE=%~1"
set "OUTPUT_FILE=%~dpn1%EXT%"

echo 処理中: "%~nx1" -^> "%~n1%EXT%"

:: ImageMagickによる変換実行
:: SVGへの変換などの特殊ケースも自動処理されます
magick "%INPUT_FILE%" "%OUTPUT_FILE%"

if %errorlevel% neq 0 (
    echo [失敗] 変換できませんでした: "%~nx1"
) else (
    echo [成功] 変換完了
)

shift
goto LOOP

:END
echo.
echo =======================================================
echo  すべての処理が完了しました。
echo =======================================================
pause