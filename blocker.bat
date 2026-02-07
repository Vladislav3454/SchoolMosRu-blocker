@echo off
chcp 65001 >nul
title Блокировщик сайтов

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Требуются права администратора!
    echo Запустите файл от имени администратора.
    pause
    exit
)

set SITE=school.mos.ru
set HOSTS=%SystemRoot%\System32\drivers\etc\hosts

:menu
cls
echo ==================================================
echo      БЛОКИРОВЩИК САЙТОВ
echo ==================================================
echo.
echo Сайт для блокировки: %SITE%

:: Проверка статуса блокировки
findstr /C:"%SITE%" "%HOSTS%" >nul 2>&1
if %errorLevel% equ 0 (
    echo Статус: 🔴 ЗАБЛОКИРОВАН
) else (
    echo Статус: 🟢 РАЗБЛОКИРОВАН
)

echo.
echo ==================================================
echo 1 - Включить блокировку
echo 2 - Выключить блокировку
echo 0 - Выход
echo ==================================================
echo.

set /p choice="Введите номер действия: "

if "%choice%"=="1" goto block
if "%choice%"=="2" goto unblock
if "%choice%"=="0" goto exit
echo.
echo ❌ Неверный выбор! Попробуйте снова.
timeout /t 2 >nul
goto menu

:block
:: Проверяем, не заблокирован ли уже
findstr /C:"%SITE%" "%HOSTS%" >nul 2>&1
if %errorLevel% equ 0 (
    echo.
    echo ⚠️  Сайт уже заблокирован!
) else (
    echo. >> "%HOSTS%"
    echo 127.0.0.1 %SITE% >> "%HOSTS%"
    echo 127.0.0.1 www.%SITE% >> "%HOSTS%"
    echo.
    echo ✅ Сайт %SITE% успешно заблокирован!
    echo.
    echo Очистка DNS кэша...
    ipconfig /flushdns >nul 2>&1
    echo ✅ DNS кэш очищен!
)
echo.
pause
goto menu

:unblock
:: Проверяем, заблокирован ли сайт
findstr /C:"%SITE%" "%HOSTS%" >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ⚠️  Сайт уже разблокирован!
) else (
    :: Создаем временный файл без строк с сайтом
    findstr /V /C:"%SITE%" "%HOSTS%" > "%HOSTS%.tmp"
    move /Y "%HOSTS%.tmp" "%HOSTS%" >nul
    echo.
    echo ✅ Сайт %SITE% успешно разблокирован!
    echo.
    echo Очистка DNS кэша...
    ipconfig /flushdns >nul 2>&1
    echo ✅ DNS кэш очищен!
)
echo.
pause
goto menu

:exit
echo.
echo Выход из программы...
timeout /t 1 >nul
exit