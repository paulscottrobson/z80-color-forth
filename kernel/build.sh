#
#		Tidy up
#
rm boot.img ../files/boot.img kernel.lst
#
#		Build the bootloader
#
pushd ../bootloader
sh build.sh
popd
#
#		Build the assembler file with the vocabulary
#
pushd ../vocabulary
sh build.sh
popd
#
#		Assemble the kernel
#
zasm -buw kernel.asm -o boot.img -l kernel.lst
#
#		Insert vocabulary into the image file.
#
if [ -e boot.img ]
then
	python ../scripts/makedictionary.py
	cp boot.img ../files
fi
