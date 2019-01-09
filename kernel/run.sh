sh build.sh
cp ../files/boot_clean.img boot.img
#python ../scripts/m7c.py demo.m7
if [ -e boot.img ]
then
	wine ../bin/CSpect.exe -zxnext -cur -brk -exit -w3 ../files/bootloader.sna 
fi



