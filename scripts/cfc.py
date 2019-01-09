# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		cfc.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date :		6th January 2019
#		Purpose :	Python Color Forth compiler.
#
# ***************************************************************************************
# ***************************************************************************************

from imagelib import *
import re,os,sys

# ***************************************************************************************
#								Exception for Compiler
# ***************************************************************************************

class CompilerException(Exception):
	def __init__(self,msg):
		self.errorMessage = "{0} ({1}:{2})".format(msg,CompilerException.FILENAME,CompilerException.LINENUMBER)

CompilerException.LINENUMBER = 0
CompilerException.FILENAME = ""

# ***************************************************************************************
#									 Compiler class
# ***************************************************************************************

class Compiler(object):
	#
	#		Set up compiler.
	#
	def __init__(self,source = "boot.img"):
		self.binary = MemoryImage(source)	
		self.forthDictionary = self.binary.getDictionary(True)			# load current dictionaries
		self.macroDictionary = self.binary.getDictionary(False)
		self.useForthDictionary = True
		self.binary.echo = True
	#
	#		Compile a file
	#
	def compileFile(self,fileName):
		try:
			CompilerException.FILENAME = fileName
			src = open(fileName).readlines()
			self.compileArray(src)
		except FileNotFoundError:
			print("Couldn't compile file "+fileName)
			sys.exit(1)
		except CompilerException as cex:
			print(cex.errorMessage)
			sys.exit(1)
	#
	#		Compile a string array
	#
	def compileArray(self,source):
		self.ifBranch = None
		self.beginLoop = None
		self.forLoop = None
		self.defOpen = False

		for ln in range(0,len(source)):										# go through all lines
			CompilerException.LINENUMBER = ln + 1							# update current line
			line = source[ln].replace("\t"," ").strip()						# remove TAB
			line = line if line.find("//") < 0 else line[:line.find("//")]	# remove comment
			for cmd in [x for x in line.split(" ") if x != ""]:				# compile all bits
				self.compile(cmd)
	#
	#		Compile a single command. Red words are prefixed with ':', other words
	# 		are green, except for compiles> which is handled seperately.
	#
	def compile(self,cmd):
		if self.binary.echo:												# headline
			print("{0} {1} {0}".format("===============",cmd))
		# 
		#		String
		#
		if cmd[0] == '"':
			self.binary.cByte(0x18)											# JR xx
			self.binary.cByte(len(cmd))
			address = self.binary.getCodeAddress()
			for c in cmd[1:]:												# text
				self.binary.cByte(ord(c) if c != "_" else 32)
			self.binary.cByte(0x00)											# ASCIIZ
			self.loadConstant(address)
			return

		cmd = cmd.lower()													# case irrelevant outside string
		#
		#		Constant
		#
		if re.match("^\-?\d+$",cmd) is not None:
			self.loadConstant(int(cmd))
			return
		#
		# 		Structures
		#
		if cmd == "if" or cmd == "-if":
			self.ifBranch = self.compileBranch(cmd.startswith("-"))
			return
		if cmd == "then":			
 			self.setBranch(self.ifBranch,self.binary.getCodeAddress())
 			return
		if cmd == "begin":
 			self.beginLoop = self.binary.getCodeAddress()
 			return
		if cmd == "-until" or cmd == "until":
 			br = self.compileBranch(cmd.startswith("-"))
 			self.setBranch(br,self.beginLoop)
 			return
		if cmd == "for" or cmd == "next" or cmd == "i":
			self.forCompile(cmd)
			return
 		#
		# 		Modifiers !! and @@ hack the ex de,hl ; ld hl,xxxx sequence.
		#
		if cmd == "!!" or cmd == "@@":
			p = self.binary.getCodePage()
			if cmd == "!!":
				self.binary.write(p,self.binary.getCodeAddress()-4,0x00)	# nop
				self.binary.write(p,self.binary.getCodeAddress()-3,0x22)	# ld (xxxx),hl
			else:
				self.binary.write(p,self.binary.getCodeAddress()-3,0x2A)	# ld hl,(xxxx)
			return
		#
		# 		Defining words :<name> variable, forth and macro
		#
		if cmd.startswith(":") and cmd != ":":								
			if self.defOpen:
				raise CompilerException("Unclosed definition")																			
																			# build record
			newFunc = { "name":cmd[1:],"page":self.binary.getCodePage(),"address":self.binary.getCodeAddress() }			
			if newFunc["name"] in self.forthDictionary or newFunc["name"] in self.macroDictionary:						
				raise CompilerException("Name duplicated {0}".format(newFunc["name"]))

			if self.useForthDictionary:										# Put record in local copy
				self.forthDictionary[newFunc["name"]] = newFunc				
			else:
				self.macroDictionary[newFunc["name"]] = newFunc				

			if not newFunc["name"].startswith("_"): 						# add to binary if not a _<identifier>
				self.binary.addDictionary(newFunc["name"],newFunc["page"],newFunc["address"],self.useForthDictionary)

			if newFunc["name"] == "main":									# main word ?
				self.binary.setBoot(newFunc["page"],newFunc["address"])	

			self.defOpen = True 											# in a definition
			self.defStart = self.binary.getCodeAddress()					# prefix here.
			self.closeAddress = None
			self.binary.cByte(0xE1)											# pop HL
			self.binary.cByte(0x22)											# LD (xxxx),hl
			self.binary.cWord(0x00)											# placeholder.
			return
		#
		if cmd == ";":	
			self.closeDefinition()											# close a definition.
			return 
		#
		if cmd == "forth" or cmd == "macro":
			self.useForthDictionary = (cmd == "forth")
			return
		#
		#		Words in dictionary. 
		#
		if cmd in self.macroDictionary:
			page = self.macroDictionary[cmd]["page"]						# get word position
			address = self.macroDictionary[cmd]["address"]					# get word address
			first = self.binary.read(page,address)							# check it's LD B,nn
			if first != 0x06:
				raise CompilerException("Can't compile macro words in Python compiler.")
			count = self.binary.read(page,address+1)
			assert count > 0 and count <= 6,"Bad macro expansion ?"
			for i in range(0,count):										# copy it out.
				self.binary.cByte(self.binary.read(page,address+5+i))
			return

		if cmd in self.forthDictionary:
			page = self.forthDictionary[cmd]["page"]						# get word position
			address = self.forthDictionary[cmd]["address"]					# get word address
			self.binary.cByte(0xCD)
			self.binary.cWord(address)
			return
		# 
		raise CompilerException("Unknown word '{0}'".format(cmd))
	#
	#		Close a definition
	#
	def closeDefinition(self):
		if self.closeAddress is None:										# first closing.
			if not self.defOpen:											# not in one
				raise CompilerException("Not in a definition")
			self.closeAddress = self.binary.getCodeAddress()				# remember where it is
			self.binary.cByte(0xC3)											# JP xxxx
			self.binary.cWord(0)
			tgt = self.closeAddress+1 										# where we overwrite
			self.binary.write(self.binary.getCodePage(),self.defStart+2,tgt & 0xFF)
			self.binary.write(self.binary.getCodePage(),self.defStart+3,tgt >> 8)
			self.defOpen = False 											# def not open.
		else:
			self.binary.cByte(0xC3)											# jump to exit
			self.binary.cWord(self.closeAddress)							# as already closed.
		if self.ifBranch is not None:										# close THEN if open.
			self.setBranch(self.ifBranch,self.binary.getCodeAddress())
			self.ifBranch = None

	#
	#		Load a constant into A, A->B first
	#	
	def loadConstant(self,const):
		self.binary.cByte(0xD5)												# push de
		self.binary.cByte(0x11)												# ld de,xxxx
		self.binary.cWord(const & 0xFFFF)
	#
	#		Compile a branch with test but no target
	#
	def compileBranch(self,negativeTest):
		if negativeTest:
			self.binary.cByte(0xCB)											# bit 7,d
			self.binary.cByte(0x7A)
		else:
			self.binary.cByte(0x7A)											# ld a,d
			self.binary.cByte(0xB3)											# or e
		self.binary.cByte(0xCA)												# jp z,xxxx
		self.binary.cWord(self.binary.getCodeAddress())
		return self.binary.getCodeAddress() - 2
	#
	#		Update the branch target
	#
	def setBranch(self,branch,target):
		self.binary.write(self.binary.getCodePage(),branch,target & 0xFF)
		self.binary.write(self.binary.getCodePage(),branch+1,target >> 8)
	#
	#		For loop code
	#
	def forCompile(self,cmd):

		if cmd == "for":
			self.binary.cByte(0xEB)											# ex de,hl
			self.binary.cByte(0xD1)											# pop de
			self.forLoop = self.binary.getCodeAddress()
			self.binary.cByte(0x22)											# ld (xxxx),hl
			self.binary.cWord(0x00)
		#
		if cmd == "next":
			patch = self.binary.getCodeAddress()+1 							# where to store count
			self.binary.write(self.binary.getCodePage(),self.forLoop+1,patch & 0xFF)
			self.binary.write(self.binary.getCodePage(),self.forLoop+2,patch >> 8)

			self.binary.cByte(0x21)											# ld hl,$0000
			self.binary.cWord(0x0000)

			self.binary.cByte(0x2B)											# dec hl
			self.binary.cByte(0x7C)											# ld a,h
			self.binary.cByte(0xB5)											# or l
			self.binary.cByte(0xC2)											# jp nz,xxxx
			self.binary.cWord(self.forLoop)

		if cmd == "i":
			pass
			
if __name__ == "__main__":
	print("*** ColorForth Python Compiler ***")
	cc = Compiler()
	#cc.binary.echo = False
	for f in sys.argv[1:]:
		print("\tCompiling '"+f+"'")
		cc.compileFile(f)
	cc.binary.save()
	print("Saved binary.")
	sys.exit(0)

# TODO:
# 		test words.