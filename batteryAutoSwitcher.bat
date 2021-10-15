@echo off

goto start

:repeat
timeout /t "%interval%" /nobreak>nul

ENDLOCAL
set startingSaving=75
set interval=5

:start

SETLOCAL ENABLEDELAYEDEXPANSION
SET count=1
FOR /F "tokens=* USEBACKQ" %%F IN (`WMIC Path Win32_Battery Get BatteryStatus`) DO (
  SET var!count!=%%F
  SET /a count=!count!+1
)

set /a chargingType="%var2%"

if "%chargingType%"=="1" (
	SET count=1
	FOR /F "tokens=* USEBACKQ" %%F IN (`WMIC Path Win32_Battery Get EstimatedChargeRemaining`) DO (
	SET var!count!=%%F
	SET /a count=!count!+1
	)

	set /a batteryRem="%var2%"

	if "%batteryRem%" LSS "%startingSaving%" (
		echo Activating battery saving...
		@REM powercfg -S SCHEME_MAX
		goto repeat
	) else (
		echo Battery more than %startingSaving%%%.
		goto repeat
	)
)

if "%chargingType%"=="2" (
	echo Battery on charge.
	goto repeat
)

REM echo *****************************
REM echo * Battery balanced mode: ON *
REM echo *****************************

timeout /t 2 /nobreak>nul

exit