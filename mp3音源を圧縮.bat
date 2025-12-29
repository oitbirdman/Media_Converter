@echo off
setlocal enabledelayedexpansion

echo ======================================================
echo   MP3 Compression Script (Progress & ETA)
echo ======================================================

:: Check if any file was dropped
if "%~1"=="" (
    echo [ERROR] No files detected.
    echo Please drag and drop MP3 files onto this bat file.
    pause
    exit /b
)

:: Check FFmpeg
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] FFmpeg was not found. 
    echo Please install FFmpeg and add it to your PATH.
    pause
    exit /b
)

:: Set output directory to the batch file's location
set "BASE_OUT_DIR=%~dp0"

:: Count total files
set total_files=0
for %%f in (%*) do (
    if /i "%%~xf"==".mp3" (
        set /a total_files+=1
    )
)

if %total_files% equ 0 (
    echo [ERROR] No MP3 files found in your selection.
    pause
    exit /b
)

echo Total MP3 files: %total_files%
echo Output location: %BASE_OUT_DIR%
echo Starting compression...
echo.

:: Get Start Time in seconds
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /a "start_time_s=(((%%a*60)+1%%b %% 100)*60)+1%%c %% 100"
)

set current_count=0

:: Process dropped files
for %%f in (%*) do (
    if /i "%%~xf"==".mp3" (
        set /a current_count+=1
        
        :: Visual Progress Bar (Queue)
        set "bar="
        set /a "prog=(current_count*20)/total_files"
        for /L %%i in (1,1,!prog!) do set "bar=!bar!#"
        for /L %%i in (!prog!,1,19) do set "bar=!bar!-"
        
        echo ------------------------------------------------------
        echo  Queue: [!bar!] !current_count!/%total_files%
        echo  Processing: "%%~nxf"
        
        :: Estimate Remaining Time
        if !current_count! gtr 1 (
            for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
                set /a "current_time_s=(((%%a*60)+1%%b %% 100)*60)+1%%c %% 100"
            )
            set /a "elapsed=!current_time_s! - !start_time_s!"
            if !elapsed! lss 0 set /a "elapsed+=86400"
            
            set /a "avg_time=!elapsed! / (!current_count! - 1)"
            set /a "rem_files=%total_files% - !current_count! + 1"
            set /a "eta_s=!avg_time! * !rem_files!"
            echo  Estimated time remaining: ~!eta_s! seconds
        ) else (
            echo  Estimated time remaining: Calculating...
        )
        echo ------------------------------------------------------
        
        :: Conversion (Outputs to the batch file's directory)
        ffmpeg -hide_banner -i "%%~f" -codec:a libmp3lame -b:a 64k -ac 1 -map_metadata 0 "%BASE_OUT_DIR%%%~nf_compressed.mp3" -y -loglevel info -stats

        if !errorlevel! equ 0 (
            echo.
            echo [OK] Completed: "%%~nf_compressed.mp3"
        ) else (
            echo.
            echo [ERROR] Failed: "%%~f"
        )
        echo.
    )
)

echo ======================================================
echo   All processes completed! [!current_count!/%total_files%]
echo   Files saved in: %BASE_OUT_DIR%
echo ======================================================
pause