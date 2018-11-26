@echo off
call build.bat
..\bin\CSpect.exe -zxnext -cur -brk -exit -w3 kernel.sna
