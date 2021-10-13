@echo off

powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e

@REM High perf: 9df557d5-8a11-42bf-88e4-c9737e89d41d
@REM Balanced:  381b4222-f694-41f0-9685-ff5bb260df2e
@REM WMIC Path Win32_Battery Get BatteryStatus
	@REM 1 - not in charge
	@REM 2 - in charge
@REM WMIC PATH Win32_Battery Get EstimatedChargeRemaining

echo *****************************
echo * Battery balanced mode: ON *
echo *****************************

timeout /t 1 /nobreak>nul

exit