@echo off
call build.bat
copy ..\files\boot_clean.img boot.img
rem python ..\scripts\m7c.py demo.m7
if exist boot.img ..\bin\CSpect.exe -zxnext -cur -brk -exit -w3 ..\files\bootloader.sna 


