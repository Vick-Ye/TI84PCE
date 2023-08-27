@echo off
set /p file=
set input=src\%file%.asm
set output=bin\%file%.8xp
echo %input%
tools\spasm.exe -E -T %input% %output% -I Project