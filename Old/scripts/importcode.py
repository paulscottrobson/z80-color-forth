# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		importcode.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		19th November 2018
#		Purpose :	Import code into bootstrap area
#
# ***************************************************************************************
# ***************************************************************************************

import sys
from imagelib import *
#
#		Initialise
#
image = ColorForthImage()
page = image.sourcePageInfo()[0]
print("Importing into bootstrap page ${0:02x}".format(page))
paging = 512
for p in range(0,image.sourcePageInfo()[1] >> 5):
	for i in range(0,0x4000):
		image.write(page+p,0xC000+i,0xFF)
address = 0xC000
#
#		Work through all the source
#
for f in sys.argv[1:]:
	start = address
	src = [x if x.find("//") < 0 else x[:x.find("//")] for x in open(f).readlines()]
	src = " ".join([x.replace("\t"," ").replace("\n"," ") for x in src])
	src = [x for x in src.split(" ") if x != ""]
	for word in src:
		#
		#	For each word, look at it to see if is defining (x2), or execute
		#
		colour = 0x84 									# Green (compile)

		if (word+"  ")[:2] == "::":						# Magenta (variable)
			colour = 0x83
			word = word[2:]
		elif word[0] == ":":							# Red (define)
			colour = 0x82
			word = word[1:]
		elif word[0] == "{" and word[-1] == "}": 		# Cyan (compile)
			colour = 0x85
			word = word[1:-1]
		elif word[0] == "[" and word[-1] == "]": 		# Yellow (execute)
			colour = 0x86
			word = word[1:-1]

		#print("{0:02x} {1}".format(colour,word))
		#
		#	Make the final word and check it fits.
		#
		xword = chr(colour)+word
		if int(address/paging) != int((address+len(xword)+2)/paging):
			while address % paging != 0:
				image.write(page,address,0xFF)
				address += 1				
		#
		#	Store the word
		#
		for c in xword:
			image.write(page,address,ord(c))
			address += 1
	print("\tImported file '{0}' ${1:04x} to ${2:04x}".format(f,start,address-1))
#		
#		and write out
#
image.save()
