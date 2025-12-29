@echo off
:: 文字コードをUTF-8に設定
chcp 65001 >nul
setlocal enabledelayedexpansion

:: カレントディレクトリに移動
cd /d "%~dp0"

:CHECK_TOOLS
:: ツールの存在確認
set "MISSING="
where yt-dlp >nul 2>nul
if %errorlevel% neq 0 if not exist "yt-dlp.exe" set "MISSING=yt-dlp.exe "
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 if not exist "ffmpeg.exe" set "MISSING=!MISSING!ffmpeg.exe"

if not "!MISSING!"=="" (
    echo [エラー] 以下のツールが見つかりません: !MISSING!
    echo 同じフォルダに配置するか、パスを通してください。
    pause
    exit /b
)

:INPUT_URL
cls
echo ========================================================
echo YouTube 音声抽出ツール (URL直接指定)
echo ========================================================
echo.
set /p URL="YouTubeのURLを入力してください: "

if "%URL%"=="" (
    echo URLが空です。
    timeout /t 2 >nul
    goto INPUT_URL
)

:SELECT_FORMAT
echo.
echo 出力形式を選択してください:
echo [1] MP3 (圧縮 - 192kbps程度)
echo [2] WAV (無圧縮 - 高音質)
echo [Q] キャンセルして終了
echo ========================================================
set /p choice="番号を入力 (1/2/Q): "

if /i "%choice%"=="Q" exit /b
if "%choice%"=="1" (
    set "EXT=mp3"
    set "DL_OPTS=--extract-audio --audio-format mp3 --audio-quality 0"
    goto DOWNLOAD
)
if "%choice%"=="2" (
    set "EXT=wav"
    set "DL_OPTS=--extract-audio --audio-format wav"
    goto DOWNLOAD
)

echo 無効な選択です。
goto SELECT_FORMAT

:DOWNLOAD
echo.
echo 処理を開始します。しばらくお待ちください...
echo ------------------------------------------------

:: yt-dlpを実行
:: -o でファイル名を「動画タイトル.拡張子」に指定
yt-dlp %DL_OPTS% -o "%%(title)s.%%(ext)s" "%URL%"

if !errorlevel! equ 0 (
    echo.
    echo [成功] 抽出が完了しました。
) else (
    echo.
    echo [失敗] エラーが発生しました。URLが正しいか確認してください。
)

echo ------------------------------------------------
echo [1] 続けて別のURLを処理する
echo [2] 終了する
set /p final="番号を入力: "
if "%final%"=="1" goto INPUT_URL

exit /b