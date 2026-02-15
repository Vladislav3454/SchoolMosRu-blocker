@echo off
chcp 65001 >nul
title Блокировщик сайтов MOS.RU

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Требуются права администратора!
    echo Запустите файл от имени администратора.
    pause
    exit
)

:: РАСШИРЕННЫЙ СПИСОК ВСЕХ ДОМЕНОВ MOS.RU
set SITES=school.mos.ru www.school.mos.ru my.school.mos.ru uchebnik.mos.ru dnevnik.mos.ru journal.mos.ru api.school.mos.ru login.mos.ru id.mos.ru authedu.mosreg.ru

set HOSTS=%SystemRoot%\System32\drivers\etc\hosts

:menu
cls
echo ==================================================
echo      БЛОКИРОВЩИК САЙТОВ MOS.RU
echo ==================================================
echo.
echo Сайт для блокировки: school.mos.ru и поддомены
echo.

:: Проверка статуса блокировки
findstr /C:"school.mos.ru" "%HOSTS%" >nul 2>&1
if %errorLevel% equ 0 (
    echo Статус: 🔴 ЗАБЛОКИРОВАНЫ
) else (
    echo Статус: 🟢 РАЗБЛОКИРОВАНЫ
)

echo.
echo ==================================================
echo 1 - Включить блокировку
echo 2 - Выключить блокировку
echo 3 - Полная очистка кэша (если не работает)
echo 0 - Выход
echo ==================================================
echo.

set /p choice="Введите номер действия: "

if "%choice%"=="1" goto block
if "%choice%"=="2" goto unblock
if "%choice%"=="3" goto deep_clean
if "%choice%"=="0" goto exit
echo.
echo ❌ Неверный выбор! Попробуйте снова.
timeout /t 2 >nul
goto menu

:block
echo.
echo Блокировка сайтов...
echo.

:: Проверяем, не заблокировано ли уже
findstr /C:"school.mos.ru" "%HOSTS%" >nul 2>&1
if %errorLevel% equ 0 (
    echo ⚠️  Сайты уже заблокированы!
    echo.
    echo 💡 Если сайты всё равно открываются:
    echo    1. Нажмите "3" для полной очистки кэша
    echo    2. Закройте ВСЕ окна браузера
    echo    3. Откройте браузер заново
) else (
    echo. >> "%HOSTS%"
    echo # === БЛОКИРОВКА MOS.RU === >> "%HOSTS%"
    
    for %%s in (%SITES%) do (
        echo 127.0.0.1 %%s >> "%HOSTS%"
        echo ::1 %%s >> "%HOSTS%"
    )
    
    echo # === КОНЕЦ БЛОКИРОВКИ MOS.RU === >> "%HOSTS%"
    echo.
    echo ✅ Сайты успешно заблокированы!
    echo.
    echo Очистка DNS кэша...
    ipconfig /flushdns >nul 2>&1
    echo ✅ DNS кэш очищен!
    echo.
    echo ⚠️  ВАЖНО:
    echo    1. Закройте ВСЕ окна браузера полностью
    echo    2. Откройте браузер заново
    echo    3. Если не помогло - нажмите "3" для полной очистки
)
echo.
pause
goto menu

:unblock
echo.
echo Разблокировка сайтов...
echo.

findstr /C:"school.mos.ru" "%HOSTS%" >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  Сайты уже разблокированы!
) else (
    :: Удаляем все строки, содержащие домены из списка
    findstr /V /C:"school.mos.ru" /C:"uchebnik.mos.ru" /C:"dnevnik.mos.ru" /C:"journal.mos.ru" /C:"login.mos.ru" /C:"id.mos.ru" /C:"authedu.mosreg.ru" /C:"=== БЛОКИРОВКА MOS.RU ===" "%HOSTS%" > "%HOSTS%.tmp"
    move /Y "%HOSTS%.tmp" "%HOSTS%" >nul
    echo ✅ Сайты успешно разблокированы!
    echo.
    echo Очистка DNS кэша...
    ipconfig /flushdns >nul 2>&1
    echo ✅ DNS кэш очищен!
    echo.
    echo ⚠️  Закройте браузер и откройте заново!
)
echo.
pause
goto menu

:deep_clean
cls
echo ==================================================
echo      ПОЛНАЯ ОЧИСТКА КЭША
echo ==================================================
echo.
echo Выполняется глубокая очистка...
echo.

echo [1/5] Очистка DNS кэша...
ipconfig /flushdns >nul 2>&1
echo ✅ DNS кэш очищен

echo.
echo [2/5] Сброс настроек Winsock...
netsh winsock reset >nul 2>&1
echo ✅ Winsock сброшен

echo.
echo [3/5] Сброс настроек TCP/IP...
netsh int ip reset >nul 2>&1
echo ✅ TCP/IP сброшен

echo.
echo [4/5] Очистка кэша браузеров...
echo Закройте ВСЕ окна браузеров перед продолжением!
pause

:: Очистка кэша Chrome
if exist "%LocalAppData%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache" 2>nul
    echo ✅ Кэш Chrome очищен
)

:: Очистка кэша Edge
if exist "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" (
    rd /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" 2>nul
    echo ✅ Кэш Edge очищен
)

:: Очистка кэша Firefox
if exist "%LocalAppData%\Mozilla\Firefox\Profiles" (
    for /d %%p in ("%LocalAppData%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%p\cache2" rd /s /q "%%p\cache2" 2>nul
    )
    echo ✅ Кэш Firefox очищен
)

echo.
echo [5/5] Перезапуск сетевых служб...
net stop dnscache >nul 2>&1
net start dnscache >nul 2>&1
echo ✅ Службы перезапущены

echo.
echo ==================================================
echo ✅ ПОЛНАЯ ОЧИСТКА ЗАВЕРШЕНА!
echo ==================================================
echo.
echo ⚠️  ОБЯЗАТЕЛЬНО:
echo    1. Закройте эту программу
echo    2. Перезагрузите компьютер
echo    3. После перезагрузки блокировка заработает
echo.
echo Хотите перезагрузить компьютер сейчас? (Y/N)
set /p reboot="Ваш выбор: "

if /i "%reboot%"=="Y" (
    echo.
    echo Перезагрузка через 10 секунд...
    shutdown /r /t 10
    echo Нажмите любую клавишу для отмены перезагрузки
    pause >nul
    shutdown /a
    echo Перезагрузка отменена
    timeout /t 2 >nul
)

goto menu

:exit
echo.
echo Выход из программы...
timeout /t 1 >nul
exit