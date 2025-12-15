@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ==========================================
:: 音声ファイル形式変換バッチ (FFmpeg使用)
:: 作成日: 2025-12-14
:: ==========================================

:: FFmpegの存在確認
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [エラー] ffmpeg.exe が見つかりません。
    echo このバッチファイルと同じフォルダに ffmpeg.exe を置くか、パスを通してください。
    echo.
    pause
    exit /b
)

:: 引数（ファイル）がない場合は終了
if "%~1"=="" (
    echo 変換したい音声ファイルをこのアイコンにドラッグ＆ドロップしてください。
    echo 複数ファイルの同時変換も可能です。
    echo.
    pause
    exit /b
)

:MENU
cls
echo ========================================================
echo  変換したい形式（拡張子）の番号を入力してください
echo ========================================================
echo  [1] .mp3  (一般的な音楽形式)
echo  [2] .wav  (非圧縮・高音質)
echo  [3] .aac  (動画などで使われる形式)
echo  [4] .flac (可逆圧縮・高音質)
echo  [5] .m4a  (Apple製品などで標準的)
echo ========================================================
set /p CHOICE="番号を選択してください (1-5): "

if "%CHOICE%"=="1" set "EXT=.mp3" & goto CONVERT
if "%CHOICE%"=="2" set "EXT=.wav" & goto CONVERT
if "%CHOICE%"=="3" set "EXT=.aac" & goto CONVERT
if "%CHOICE%"=="4" set "EXT=.flac" & goto CONVERT
if "%CHOICE%"=="5" set "EXT=.m4a" & goto CONVERT

echo 無効な選択です。もう一度入力してください。
timeout /t 2 >nul
goto MENU

:CONVERT
cls
echo 変換を開始します... ターゲット拡張子: %EXT%
echo.

:: ドラッグ＆ドロップされた全ファイルを処理
:LOOP
if "%~1"=="" goto FINISH

set "INPUT_FILE=%~1"
set "FILENAME=%~n1"
set "OUTPUT_FILE=%~dp1%FILENAME%%EXT%"

echo 処理中: "%INPUT_FILE%"
echo 　→ 出力: "%OUTPUT_FILE%"

:: FFmpegコマンド実行
:: -i : 入力ファイル
:: -y : 上書き許可 (必要に応じて外してください)
:: -loglevel error : エラー以外は表示しない（画面をスッキリさせるため）
ffmpeg -i "%INPUT_FILE%" -y -loglevel error "%OUTPUT_FILE%"

if %errorlevel% neq 0 (
    echo [失敗] 変換に失敗しました: "%INPUT_FILE%"
) else (
    echo [成功] 完了
)
echo --------------------------------------------------------

:: 次のファイルへシフト
shift
goto LOOP

:FINISH
echo.
echo 全ての処理が完了しました。
pause