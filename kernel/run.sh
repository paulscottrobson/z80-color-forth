sh build.sh
cp ../files/boot_clean.img boot.img
python ../scripts/cfc.py demo.cfc
if [ -e boot.img ]
then
	wine ../bin/CSpect.exe -zxnext -cur -brk -exit -w3 ../files/bootloader.sna 
	ls >/dev/null
fi



