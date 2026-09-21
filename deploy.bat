@echo off
setlocal EnableExtensions

cd /d "%~dp0"

echo ========================================
echo GeoGames - deploy till GitHub Pages
echo ========================================
echo.

where git >nul 2>&1
if errorlevel 1 goto :no_git

git rev-parse --show-toplevel >nul 2>&1
if errorlevel 1 goto :not_repo

for /f "delims=" %%R in ('git rev-parse --show-toplevel') do set "REPO_ROOT=%%R"
cd /d "%REPO_ROOT%"

for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if /I not "%BRANCH%"=="main" goto :wrong_branch

git remote get-url origin >nul 2>&1
if errorlevel 1 goto :no_remote

set "MESSAGE=%~1"
if "%MESSAGE%"=="" set "MESSAGE=Uppdatera GeoGames"

echo Lagger endast webbplatsens filer...
git add -- deploy.bat index.html worldgame.html sveriges-kommuner.html goteborg-primaromraden.html
if errorlevel 1 goto :git_error

git diff --cached --quiet
set "DIFF_EXIT=%ERRORLEVEL%"
if "%DIFF_EXIT%"=="0" goto :nothing_to_commit
if not "%DIFF_EXIT%"=="1" goto :git_error

echo.
echo Filer som kommer att publiceras:
git diff --cached --name-only
echo.

git commit -m "%MESSAGE%"
if errorlevel 1 goto :git_error

echo.
echo Pushar till origin/main...
git push origin main
if errorlevel 1 goto :git_error

echo.
echo Klart! GitHub Pages bygger nu webbplatsen.
echo Adress: https://tadrian.github.io/GeoGames/
goto :done

:nothing_to_commit
echo Inga nya andringar att publicera.
echo Kontrollera att GitHub Pages ar aktiverat under Settings - Pages.
goto :done

:no_git
echo FEL: Git finns inte i PATH.
goto :fail

:not_repo
echo FEL: deploy.bat maste ligga i ett Git-repository.
goto :fail

:wrong_branch
echo FEL: aktuell branch ar "%BRANCH%". Byt till main innan deploy.
goto :fail

:no_remote
echo FEL: GitHub-remoten "origin" saknas.
goto :fail

:git_error
echo FEL: Git kunde inte slutföra deployen.
goto :fail

:done
echo.
pause
exit /b 0

:fail
echo.
pause
exit /b 1
