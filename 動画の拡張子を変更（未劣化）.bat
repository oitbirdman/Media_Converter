@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: -------------------------------------------------------
:: 動画拡張子変換バッチ（FFmpeg使用・無劣化コピー）
:: -------------------------------------------------------

:: FFmpegがインストールされているか確認
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [エラー] ffmpeg が見つかりません。
    echo.
    echo このツールを使用するには FFmpeg が必要です。
    echo 公式サイトからダウンロードしてパスを通すか、
    echo このバッチファイルと同じフォルダに ffmpeg.exe を置いてください。
    echo.
    pause
    exit /b
)

:: ファイルがドラッグ＆ドロップされていない場合のチェック
if "%~1"=="" (
    echo.
    echo -------------------------------------------------------
    echo  [使い方]
    echo  変換したい動画ファイルを、このアイコンに
    echo  ドラッグ＆ドロップしてください（複数可）。
    echo -------------------------------------------------------
    echo.
    pause
    exit /b
)

:: 変換形式の選択メニュー
cls
echo.
echo  変換先のフォーマットを選んでください。
echo  ※映像・音声データはそのままコピーするため、画質劣化はありません。
echo.
echo  [1] .mp4  (一般的・推奨)
echo  [2] .mov  (Mac/iPhone向け)
echo  [3] .webm (Web向け)
echo  [4] .mkv  (多機能コンテナ)
echo.
set /p "selection= 番号を入力してください (1-4): "

:: 選択に応じた拡張子の設定
if "%selection%"=="1" set "target_ext=.mp4"
if "%selection%"=="2" set "target_ext=.mov"
if "%selection%"=="3" set "target_ext=.webm"
if "%selection%"=="4" set "target_ext=.mkv"

if not defined target_ext (
    echo.
    echo [エラー] 無効な番号です。終了します。
    pause
    exit /b
)

:: 処理実行
echo.
echo 変換を開始します...
echo.

:process_loop
if "%~1"=="" goto end_process

set "input_file=%~1"
set "output_file=%~dpn1%target_ext%"

echo 処理中: "%~nx1" ---^> "%~n1%target_ext%"

:: FFmpegコマンド実行
:: -i: 入力ファイル
:: -c copy: 再エンコードなしでストリームをコピー（高速・無劣化）
:: -map 0: すべてのストリームを含める
:: -y: 同名ファイルがある場合は上書き
ffmpeg -i "%input_file%" -c copy -map 0 -y "%output_file%" -loglevel error

if %errorlevel% neq 0 (
    echo [警告] "%~nx1" の変換中にエラーが発生しました。
    echo コーデックが変換先のコンテナに対応していない可能性があります。
)

shift
goto process_loop

:end_process
echo.
echo -------------------------------------------------------
echo  すべての処理が完了しました。
echo -------------------------------------------------------
pause