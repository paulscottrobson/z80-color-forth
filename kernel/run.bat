@echo off
call build.bat
python ..\scripts\importcode.py demo.cf
..\bin\cspect.exe -zxnext -brk -esc -w3 ..\files\bootloader.sna
