# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		m7c.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date :		6th January 2019
#		Purpose :	Python M7 compiler.
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
		self.dictionary = self.binary.getDictionary()						# load current dictionary
																			# standard routines 
		self.standardHeader = self.dictionary["sys.stdheaderroutine"]["address"]
		self.macroHeader = self.dictionary["sys.stdmacroroutine"]["address"]
		self.macroExecHeader = self.dictionary["sys.stdexecmacroroutine"]["address"]
		self.variableHandler = self.dictionary["sys.variableroutine"]["address"]

		#self.binary.echo = False
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
		# 		Immediate words :<name> variable and compiles>
		#
		if cmd.startswith(":") and cmd != ":":								
																			# build record
			newFunc = { "name":cmd[1:],"page":self.binary.getCodePage(),"address":self.binary.getCodeAddress() }			
			if newFunc["name"] in self.dictionary:							# check duplication
				raise CompilerException("Name duplicated {0}".format(newFunc["name"]))
			self.dictionary[newFunc["name"]] = newFunc						# add to compiler dict
			if not newFunc["name"].startswith("_"): 						# add to binary if not _
				self.binary.addDictionary(newFunc["name"],newFunc["page"],newFunc["address"])
			if newFunc["name"] == "main":									# main word ?
				self.binary.setBoot(newFunc["page"],newFunc["address"]+3)	# +3 for code not header
			self.binary.cByte(0xCD)											# call
			self.binary.cWord(self.standardHeader+3)						# +3 for code not header
			return
		#
		if cmd == "variable":
			vh = self.variableHandler + 3									# replacement
			self.binary.write(self.binary.getCodePage(),self.binary.getCodeAddress()-2,vh & 255)
			self.binary.write(self.binary.getCodePage(),self.binary.getCodeAddress()-1,vh >> 8)
			self.binary.cWord(0)
			return
		#
		if cmd == "compiles>":
			self.binary.setCodeAddress(self.binary.getCodeAddress()-3)		# unpicks the header.
			return
		#
		#		Words in dictionary. Identify what to do by examining the compiler call
		#		if there isn't one, we can't compile it (without emulating a Z80 !)
		#
		if cmd in self.dictionary:
			page = self.dictionary[cmd]["page"]								# get word position
			address = self.dictionary[cmd]["address"]
			if self.binary.read(page,address) != 0xCD:						# check CALL xxxx
				raise CompilerException("Word {0} cannot be compiled.".format(cmd))
																			# get the call to compile
			compExec = self.binary.read(page,address+1)+self.binary.read(page,address+2)*256-3

			if compExec == self.standardHeader:								# standard (callable routine)
				self.binary.cByte(0xCD)
				self.binary.cWord(address+3)
																			# macro, copy code in.
			elif compExec == self.macroHeader or compExec == self.macroExecHeader:
				count = self.binary.read(page,address+3)					# bytes in macro
				assert count < 8
				for i in range(0,count):									# copy each byte
					self.binary.cByte(self.binary.read(page,address+i+4))

			elif compExec == self.variableHandler:							# variable word.
				self.loadConstant(address+3)

			else:															# some other wierd word.
				raise CompilerException("Unknown compilation code for "+cmd)
			return
		raise CompilerException("Unknown word '{0}'".format(cmd))
	#
	#		Load a constant into A, A->B first
	#	
	def loadConstant(self,const):
		self.binary.cByte(0xEB)												# ex de,hl
		self.binary.cByte(0x21)												# ld hl,xxxx
		self.binary.cWord(const & 0xFFFF)
	#
	#		Compile a branch with test but no target
	#
	def compileBranch(self,negativeTest):
		if negativeTest:
			self.binary.cByte(0xCB)											# bit 7,h
			self.binary.cByte(0x7C)
		else:
			self.binary.cByte(0x7C)											# ld a,h
			self.binary.cByte(0xB5)											# or l
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
			self.forLoop = self.binary.getCodeAddress()
			self.binary.cByte(0x2B)											# dec hl
			self.binary.cByte(0xE5)											# push hl
		if cmd == "i":
			self.binary.cByte(0xE1)											# pop hl
			self.binary.cByte(0xE5)											# push hl
		if cmd == "next":
			self.binary.cByte(0xE1)											# pop hl
			self.binary.cByte(0x7C)											# ld a,h
			self.binary.cByte(0xB5)											# or l
			self.binary.cByte(0xC2)											# jp nz,xxxx
			self.binary.cWord(self.forLoop)

if __name__ == "__main__":
	print("*** M7 Python Compiler ***")
	cc = Compiler()
	cc.binary.echo = False
	for f in sys.argv[1:]:
		print("\tCompiling '"+f+"'")
		cc.compileFile(f)
	cc.binary.save()
	print("Saved binary.")
	sys.exit(0)

# TODO:
# 		test words.