@echo off
:: 文字コードをUTF-8(65001)に変更して文字化けを防止
chcp 65001 >nul
setlocal enabledelayedexpansion

:: カレントディレクトリをバッチファイルの場所に移動
cd /d "%~dp0"

:: ------------------------------------------------
:: メニュー表示：出力形式の選択
:: ------------------------------------------------
:MENU
cls
echo ========================================================
echo 動画から音声を抽出します。
echo FFmpegが同じフォルダ、またはパスの通った場所に必要です。
echo ========================================================
echo [1] MP3 (一般的な圧縮音声 - 軽量)
echo [2] WAV (無圧縮 - 高音質)
echo ========================================================
set /p choice="番号を入力してEnterを押してください (1 or 2): "

if "%choice%"=="1" (
    set "EXT=mp3"
    :: -vn: 映像無効, -acodec libmp3lame: MP3変換, -q:a 2: 高品質VBR(可変ビットレート)
    set "FFMPEG_ARGS=-vn -acodec libmp3lame -q:a 2"
    goto PROCESS
)
if "%choice%"=="2" (
    set "EXT=wav"
    :: -vn: 映像無効, -acodec pcm_s16le: CD音質(16bit PCM)
    set "FFMPEG_ARGS=-vn -acodec pcm_s16le -ar 44100 -ac 2"
    goto PROCESS
)

:: 無効な入力の場合
echo 無効な選択です。
timeout /t 2 >nul
goto MENU

:: ------------------------------------------------
:: 処理実行ループ
:: ------------------------------------------------
:PROCESS
:: 引数（ドラッグ＆ドロップされたファイル）がない場合
if "%~1"=="" (
    cls
    echo.
    echo 警告: ファイルが選択されていません。
    echo 動画ファイルをこのバッチファイルにドラッグ＆ドロップしてください。
    echo.
    pause
    exit /b
)

echo.
echo 処理を開始します...
echo ------------------------------------------------

:LOOP
if "%~1"=="" goto END

set "INPUT_FILE=%~1"
:: 出力ファイル名: 元のファイル名 + .拡張子
set "OUTPUT_FILE=%~dpn1.%EXT%"

echo 変換中: "%INPUT_FILE%"


:: ffmpegコマンド実行
ffmpeg -i "%INPUT_FILE%" %FFMPEG_ARGS% "%OUTPUT_FILE%" -y -hide_banner -loglevel error

if !errorlevel! neq 0 (
    echo [エラー] 変換に失敗しました: "%INPUT_FILE%"
    echo FFmpegが見つからないか、ファイルが破損している可能性があります。
) else (
    echo [完了] 保存先: "%OUTPUT_FILE%"
)

:: 次のファイルへ（シフト）
shift
goto LOOP

:END
echo ------------------------------------------------
echo 全ての処理が完了しました。
pause