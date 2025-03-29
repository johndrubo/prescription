@echo off
REM This script will apply a patch to a local dependency if needed.

echo Applying patch

REM Path to the package to patch
set TARGET_DIR=C:\Users\johnd\AppData\Local\Pub\Cache\hosted\pub.dev\google_mlkit_smart_reply-0.9.0\android\src\main\
set MANIFEST_FILE=%TARGET_DIR%\AndroidManifest.xml

REM Check if directory exists
if not exist "%TARGET_DIR%" (
    echo Target directory %TARGET_DIR% does not exist. Check if the path is correct.
    exit /b 1
)

REM Create a temporary file
set TEMP_FILE=%TEMP%\temp_manifest.xml

REM Use findstr to filter out the package attribute line
type "%MANIFEST_FILE%" | findstr /v "package=\"com.google_mlkit_smart_reply\"" > "%TEMP_FILE%"

REM Copy the modified file back
copy /y "%TEMP_FILE%" "%MANIFEST_FILE%"

echo Patch applied successfully.
exit /b 0 