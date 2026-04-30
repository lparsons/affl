@echo off
echo.
echo =======================================
echo    AFFL League Data Updater
echo =======================================
echo.

echo Updating standings from Sleeper API...
C:\Ruby32-x64\bin\ruby.exe _scripts\update_standings.rb

echo.
echo Building Jekyll site...
C:\Ruby32-x64\bin\ruby.exe C:\Ruby32-x64\bin\bundle exec jekyll build

echo.
echo =======================================
echo    Update Complete!
echo =======================================
echo.
echo To serve the site locally, run:
echo C:\Ruby32-x64\bin\ruby.exe C:\Ruby32-x64\bin\bundle exec jekyll serve
echo.
echo Or use: .\bin\jekyll.cmd serve
echo Then visit: http://localhost:4000
echo.
pause
