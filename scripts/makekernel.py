# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		makekernel.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		29th December 2018
#		Purpose :	Build the main kernel file, and the dictionary file.
#
# ***************************************************************************************
# ***************************************************************************************

def scramble(word):
	word = word.strip().lower()
	return "_".join(["{0:02x}".format(ord(x)) for x in word])

import re,os,sys
print("Generating kernel file.....")
#
#		Get the sources list
#
sources = []
for root,dirs,files in os.walk("lib.source"):
	for file in files:
		sources.append(root+os.sep+file)
sources.sort()
#
#		Create the output.
#
dictionary = {}
hOut = open("temp"+os.sep+"__source.asm","w")
for file in sources:
	print("\tProcessing {0}.".format(file))
	currentWord = None
	for l in [x.rstrip().replace("\t"," ") for x in open(file).readlines()]:
		if l.startswith("@word"):	
			hOut.write("\n; =============== "+l+" ==============\n\n")
			m = re.match("\@word\.(ix|ret)\s*(.*)\s*$",l)
			assert m is not None,"Bad line "+l
			currentWord = m.group(2)			
			currentScramble = scramble(currentWord)
			currentWrapper = m.group(1)
			#print("\t\tCode   word "+currentWord+" ("+currentWrapper+")")
			hOut.write("define_{0}:\n".format(currentScramble))
			if currentWrapper == "ix":
				hOut.write("  pop ix\n")
			dictionary[currentWord] = { "dict":"forth","name":currentWord,"label":"define_"+currentScramble}

		elif l.startswith("@copier"):
			hOut.write("\n; =============== "+l+" ==============\n\n")
			currentWord = l[7:].strip().lower()
			currentScramble = scramble(currentWord)
			currentWrapper = None
			assert currentWord != "","Bad line "+l
			#print("\t\tCopier word "+currentWord)
			hOut.write("define_{0}:\n".format(currentScramble))
			hOut.write("  nop\n")
			hOut.write("  call copyIntoCodeSpace\n")
			hOut.write("  db end_{0}-start_{0}\n".format(currentScramble))
			hOut.write("start_{0}:\n".format(currentScramble))
			dictionary[currentWord] = { "dict":"macro","name":currentWord,"label":"define_"+currentScramble}

		elif l == "@end":
			assert currentWord is not None,"@end when word closed"
			if currentWrapper is None:
				hOut.write("end_{0}:\n".format(currentScramble))
			elif currentWrapper == "ix":
				hOut.write("  jp (ix)\n")
			elif currentWrapper == "ret":
				hOut.write("  ret\n")
			else:
				assert False

			currentWord = None
		else:
			hOut.write(l+"\n")
hOut.close()
#
#		Output dictionary.
#
hOut = open("temp"+os.sep+"__dictionary.asm","w")
hOut.write("  org $c000\n")
for key in [x for x in dictionary.keys()]:
	hOut.write("    db  {0}\n".format(len(key)))
	hOut.write("    db  FirstCodePage\n")
	hOut.write("    dw  {0}\n".format(dictionary[key]["label"]))
	size = len(key) if dictionary[key]["dict"] == "forth" else 0x80+len(key)
	hOut.write("    db  {0},\"{1}\"\n".format(size,key))
hOut.write("    db  0\n")
hOut.close()
		