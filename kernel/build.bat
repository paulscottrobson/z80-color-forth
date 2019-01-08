@echo off
rem
rem		Tidy up
rem
del /Q boot.img 
del /Q ..\files\*.img 
rem
rem		Build the bootloader
rem
pushd ..\bootloader
call build.bat
popd
rem
rem		Build the vocabulary file.
rem
pushd ..\core-vocabulary
call build.bat
popd
rem
rem		Assemble the kernel
rem
..\bin\snasm kernel.asm boot.img
rem
rem		Insert vocabulary into the image file.
rem
if exist boot.img copy boot.img ..\files\boot_clean.img
