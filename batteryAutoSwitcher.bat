@echo off

@REM powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e

@REM High perf: 9df557d5-8a11-42bf-88e4-c9737e89d41d
@REM Balanced:  381b4222-f694-41f0-9685-ff5bb260df2e
@REM WMIC Path Win32_Battery Get BatteryStatus
	@REM 1 - not in charge
	@REM 2 - in charge
@REM WMIC PATH Win32_Battery Get EstimatedChargeRemaining

@REM powercfg -ALIASES # Lists named aliases for available profiles.
@REM powercfg -S SCHEME_MIN #Activates the (High-Performance) Scheme with the alias SCHEME_MIN
@REM powercfg -S SCHEME_MAX #Activates the (Max-Energie-Saving) Scheme with the alias SCHEME_MAX
@REM powercfg -S SCHEME_BALANCED # ... Balanced Energie Scheme

:start
timeout /t 5 /nobreak>nul

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

	if "%batteryRem%" LSS "75" (
		echo Activating battery saving...
		@REM powercfg -S SCHEME_MAX
		ENDLOCAL
		goto start
	) else (
		echo Battery more than 75%.
		ENDLOCAL
		goto start
	)
)

if "%chargingType%"=="2" (
	echo Battery on charge.
	ENDLOCAL
	goto start
)

REM echo *****************************
REM echo * Battery balanced mode: ON *
REM echo *****************************

timeout /t 2 /nobreak>nul

exit