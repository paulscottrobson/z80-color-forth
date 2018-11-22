# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		makedictionary.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		16th November 2018
#		Purpose :	Extract dictionary items from listing and put in image.
#
# ***************************************************************************************
# ***************************************************************************************

import re,imagelib
from labels import *

print("Importing core words into dictionary.")
image = imagelib.ColorForthImage()
labels = LabelExtractor("boot.img.vice").getLabels()
count = 0
keys = [x for x in labels.keys() if x[:7] == "cforth_"]
keys = [x for x in keys if x[-6:] == "_forth" or x[-6:] == "_macro"]
keys.sort(key = lambda x:labels[x])

for label in keys:
	name = "".join([chr(int(x,16)) for x in label[7:-6].split("_")])
	address = labels[label]
	isMacro = label[-6:] == "_macro"
	#print(name,address,isMacro)
	#
	#	FORTH and MACRO go in both pages, so they are executed in yellow or green modes.
	#	
	if name == "forth" or name == "macro":
		assert not isMacro
		image.addDictionary(name,image.getCodePage(),address,False)
		image.addDictionary(name,image.getCodePage(),address,True)
	else:
		image.addDictionary(name,image.getCodePage(),address,isMacro)
	count += 1
image.save()
print("\tImported {0} words.".format(count))
