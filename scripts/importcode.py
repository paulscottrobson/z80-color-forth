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

#
#	Colours:
#	$81 	Blue 		in code marker (ignore) if used at all.
#	$82		Red 		define word (and header)							:word (not :)
#	$83		Magenta 	define variable (and variable common code,space)	&word (not &&)
#	$84		Green 		execute macro,compile word or number code 			word
#	$85		Cyan 		compile macro,compile word, or number code 			{word}
#	$86		Yellow 		execute word or number code 						[word]
#	$87		White 		comment  (double slashes mean rest of line a comment)
#
import sys
from imagelib import *
#
#		Initialise
#
image = ColorForthImage()
page = image.bootstrapPage()
print("Importing into bootstrap page ${0:02x}".format(page))
paging = 512
for i in range(0,0x4000):
	image.write(page,0xC000+i,0xFF)
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
		#	For each word, look at it to see if is defining, execute, compile (etc.)
		#
		colour = 0x84 									# Green $84
		if word[0] == ":":								# Red $82
			colour = 0x82
			word = word[1:]
		elif word[0] == "&" and word != "&&":			# Magenta $83
			colour = 0x83
			word = word[1:]
		elif word[0] == "[" and word[-1] == "]":		# Yellow $86
			colour = 0x86
			word = word[1:-1]
		elif word[0] == "{" and word[-1] == "}":		# Cyan $85
			colour = 0x85
			word = word[1:-1]
		#
		#	If it's not a string make it lower case, just because you should.
		#
		if word[0] != '"' or word[-1] != "":			
			word = word.lower()
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