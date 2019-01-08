# ***************************************************************************************************************
# ***************************************************************************************************************
#
#		Name : 		makecore.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		8th December 2019
#		Purpose :	Build core assembly file with macro and forth words.
#
# ***************************************************************************************************************
# ***************************************************************************************************************

import os,re,sys
#
#		Build composite .core files
#
src = ""
for root,dirs,files in os.walk("."):
	for f in files:
		if f[-5:] == ".core":
			src = src + "~".join(open(root+os.sep+f).readlines())
#
#		Process it
#
src = src.split("~")
src = [x.replace("\t"," ").rstrip() for x in src]
src = [x if x.find(";") < 0 else x[:x.find(";")].rstrip() for x in src]
src = [x for x in src if x.strip() != ""]
src = "~".join(src)+"~"
#
#		Divide it and generate
#
src = src.split("@@")
index = 0
hOut = open(".."+os.sep+"kernel"+os.sep+"temp"+os.sep+"__words.asm","w")
for defn in [x for x in src if x != ""]:
	m = re.match("^(\w+)\.(\w+)\s+(.*?)\~(.*)\~\@end\~?$",defn)
	assert m is not None,defn
	assert m.group(1) in ["word","macro","macroonly"]
	name = m.group(3)
	wrapper = m.group(2)
	src = "\n".join(["\t"+x.strip() if x.startswith(" ") else x for x in m.group(4).split("~")])
	assert src.find("ret~") < 0,"Ret in "+name
	synonyms = [x for x in name.split("::") if x != ""]
	for name in synonyms:
		if m.group(1) != "macroonly":
			hOut.write("\n@forth "+name+"\n")
			if wrapper != "ret":
				hOut.write("\tpop "+wrapper+"\n")
			hOut.write(src+"\n")
			hOut.write("\tjp ("+wrapper+")\n" if wrapper != "ret" else "\tret\n")			
		if m.group(1) != "word":
			hOut.write("\n@macro "+name+"\n")
			hOut.write("\tld b,_end_{0}-_start_{0}\n".format(index))
			hOut.write("\tcall MacroExpansion\n")
			hOut.write("_start_"+str(index)+"\n")
			hOut.write(src+"\n")
			hOut.write("_end_"+str(index)+"\n")
			index += 1
hOut.close()			

