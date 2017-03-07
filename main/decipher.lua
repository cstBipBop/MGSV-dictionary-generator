local dir=io.popen"cd":read'*l' -- apparently exe needs full path when not in current folder

local e={
	command={
		doExe=false
	},
	defaultCfg={
		bruteForceStopCount=2e6,
		timeEachDictionaryAttack=1
	},
	dict={
		entries={},
		hashes={},
		new={},
		words={}
	},
	hashIsQAR=nil,
	lib={
		dictionary={
			eng='lib/dictionary/englishDictionary.txt',
			gameLeadCap='lib/dictionary/lang/gameStrings_leadHigh.txt',
			gameLower='lib/dictionary/lang/gameStrings_low.txt',
			qarStr='lib/dictionary/qar/tabledStrings'--,
			--qarStrComp='lib/dictionary/qar/tabledStringsCompiled'
		},
		hashes={
			lngFull='lib/hash/lng/full.txt',
			lngUndefined='lib/hash/lng/undefined.txt',
			qar='lib/hash/qar/hashes.txt'
		},
		exe={
			path=dir..'/lib/exe/qar/mgsvPathHasher.exe',
			str32=dir..'/lib/exe/lng/Fox.StrCode32.exe'
		},
		target={
			lng='lang_dictionary.txt',
			qar='qar_dictionary.txt'
		},
		workFiles={
			lngIn='lib/exe/lng/temp.txt',
			lngOut='lib/exe/lng/temp_result.txt',
			qarIn='input.txt',
			qarOut='output.txt'
		}
	},
	files={
		hashList=false,
		wordList=false,
		dictionary=false,
		backup=false,
		input=false,
		output=false,
		exe=false
	}
}

local L={
	ceil=math.ceil,
	random=math.random,
	sqrt=math.sqrt,

	time=os.clock,
	cmd=os.execute,

	open=io.open,
	run=io.popen,

	s_char=string.char,
	s_format=string.format,
	s_gsub=string.gsub,

	concat=table.concat
}

local assert=assert
local collectgarbage=collectgarbage
local ipairs=ipairs
local pairs=pairs
local tostring=tostring
local type=type

math.randomseed(os.time())
L.random()

e.userInput={
	method={
		dictionaryAttack=false,
		bruteForce=true
	},
	files={
		dictionary=e.lib.dictionary.gameLower,
		exe=e.lib.exe.path,
		hashes=e.lib.hashes.qar,
		luaTable=e.lib.dictionary.qarStr
	},
	luaConfig={
		backup=false, -- creates a copy of the new dictionary after closing; slower but ensures a good file always exists in the event of a crash or whatever corrupting files while performing io
		debug=false, -- dummy
		consoleFeedback=false -- dummy
	},
	funcConfig={
		bruteForce={
			defaultSymbols={'','_'}, -- any characters not covered by as2Table
			as2Table={az=true,AZ=true,num=true}, -- what character sets to generate
			overrideStopCountWithInt={false,2} -- [1]=enabled/disabled; [2]=0<[2]<2e6; adjust this if creating absurdely long entries
		},
		strings={
			_='_',
			slash='/',
			w1='/Assets/tpp/common_source/environ/',
			w2='/cm_',
			w3='/sourceimages/',
			w4='',
			w5='',
			w6='',
			w7=''
		},
		importedTable={
			fo1={'folder','source','location'},
			fo2=false,
			fo3=false,

			fi1={'file','source','location'},
			fi2={'file','source','material'},
			fi3={'file','source','preLayer'},
			fi4={'file','texture','generic','paramLayer'}
		}
	}
}

local backupEnabled=e.userInput.luaConfig.backup

function e:init()
	local l=L
	assert(self, 'no argument given to e.init()')

	if type(self.files.dictionary)=='string' then
		local t={}
		local file=l.open(self.files.dictionary)

		for line in file:lines() do
			t[#t+1]=line
		end

		e.dict.words=t
	end

	local tbl=type(self.files.luaTable=='string') and self.files.luaTable or false

	if tbl then
		tbl=require(tbl)
		for k,v in pairs(self.funcConfig.importedTable) do
			if type(v)=='table' then
				local t=tbl
				for i=1,#v do
					t=t[self.funcConfig.importedTable[k][i]]
				end
				self.funcConfig.importedTable[k]=t
			end
		end
	end

	tbl=nil

	local import=function(file,stringAsNumber)
		local n=0
		local t={}
		file=l.open(file)

		if stringAsNumber then
			for line in file:lines() do
				n=n+1
				t[n]=line+0
			end
		else
			for line in file:lines() do
				n=n+1
				t[n]=line
			end
		end

		return t
	end

	if self.files.exe==e.lib.exe.str32 then -- lng
		e.dict.hashes=import(self.files.hashes,true)
		e.files.input=e.lib.workFiles.lngIn
		e.files.output=e.lib.workFiles.lngOut
		e.files.dictionary=e.lib.target.lng
		e.command.doExe=e.lib.exe.str32..' '..e.files.input
	else -- qar
		e.hashIsQAR=true
		e.dict.hashes=import(self.files.hashes)
		e.files.input=e.lib.workFiles.qarIn
		e.files.output=e.lib.workFiles.qarOut
		e.files.dictionary=e.lib.target.qar
		e.command.doExe=e.lib.exe.path..' '..e.files.input
	end

	e.files.hashList=self.files.hashes

	e.files.backup=l.s_gsub(e.files.dictionary,'.txt','_backup.txt')

	e.dict.entries=import(e.files.dictionary)

	e.dict.words=import(self.files.dictionary)
	e.files.wordList=self.files.dictionary

	e.files.exe=self.files.exe

	return self
end

e.userInput=e.init(e.userInput)
e.init=nil
--table.remove(e.lib)
--collectgarbage()

function e.backup()
	local l=L
	l.cmd(l.s_format('copy "%s" "%s"',e.files.dictionary,e.files.backup))
end

function e.removeDuplicateEntries(new,old)
	local n=#old
	os.execute('echo dupeRemoval')
	os.execute('echo #new='..#new)

	for i=1,#new do
		n=n+1
		old[n]=new[i]
	end

	n=0
	local aDuplicate={}
	local t={}

	for i=1,#old do
		if not aDuplicate[old[i]] then
			n=n+1
			t[n]=old[i]
			aDuplicate[old[i]]=true
		end
	end

	n,aDuplicate,new,old=nil
	os.execute('echo '..#t)

	return t
end

function e.verifyHashAndRemoveDuplicates(new,hashList)
	local n=0
	local isValid={}
	--os.execute('echo '..new[1]..new[2])
	--new={72f968ae18b,72f968ae18b}

	for i=1,#hashList do
		isValid[hashList[i]]=true
	end
	--os.execute('echo #hashList = '..#hashList)
	--os.execute('echo isValid[72f968ae18b] == '..tostring(isValid['72f968ae18b']))

	--hashList=nil
	local aDuplicate={}
	local t={}


	for i=1,#new do
		if not aDuplicate[new[i]] then
			n=n+1
			t[n]=new[i]
			aDuplicate[t[n]]=true
		end
	end
	os.execute('echo '..#t) --1

	aDuplicate=nil
	local m={}
	for i=1,#t do
		if isValid[t[i]] then
			n=n+1
			m[#m+1]=t[i]
		end
	end


	--[====[for i=1,#new do
		if isValid[new[i] ] then
			n=n+1
			t[n]=new[i]
			os.execute('echo isValid t[n]=new[i] = '..tostring(t[n]))
		end
	end--]====]

	new,n,isValid=nil

	return m
end

function e.createNewDictionary()
	os.execute('echo '..os.clock()..':start of e.createNewDictionary()')
	local l=L

	os.execute('echo '..os.clock()..':creating output file')
	l.run(e.command.doExe)
	local file=l.open(e.files.output)
	l=nil
	local n=0
	local o={}

	os.execute('echo '..os.clock()..':freeing memory')
	collectgarbage() -- required, else lua randomly screws up line additions to table
	os.execute('echo '..os.clock()..':garbage done. importing lines from output file.')
	for line in file:lines() do
		n=n+1
		o[n]=line
	end
	os.execute('echo '..os.clock()..':done. splitting table o')

	local oEntries={}
	local oHashes={}

	if e.hashIsQAR then
		for i=1,n do
			oEntries[i]=o[i]:match('^(.*)%s')
			oHashes[i]=o[i]:match('...........$')
		end
	else
		for i=1,n do
			oEntries[i]=o[i]:match('^(.*)%s')
			oHashes[i]=(o[i]:match('%s(%d+)$')+0)
		end
	end

	o=nil
	os.execute('echo '..os.clock()..':freeing memory')
	collectgarbage()
	os.execute('echo '..os.clock()..':done. calling e.verifyHashAndRemoveDuplicates()')
	o=e.verifyHashAndRemoveDuplicates(oHashes,e.dict.hashes)
	os.execute('echo '..os.clock()..':done. freeing memory')
	collectgarbage()
	os.execute('echo '..os.clock()..':done. creating new output table')

--[
	n=0
	for i=1,#oHashes do
		n=n+1
		if o[n]==oHashes[i] then
			o[i]=oEntries[i]
		end
	end
--]]
--[==[
	for i=1,#o do
		for I=1,n do
			if o[i]==oHashes[I] then
				o[i]=oEntries[I]
			end
		end
	end--]==]
	os.execute('echo '..os.clock()..':done. freeing memory')
	collectgarbage()
	os.execute('echo '..os.clock()..':done. calling e.removeDuplicateEntries')

	oEntries,oHashes=nil
	--collectgarbage()

	return e.removeDuplicateEntries(o,e.dict.entries)
end

function e.loop()
	os.execute('echo '..os.clock()..':start of e.loop(). calling e.createNewDictionary()')
	local t=e.createNewDictionary()
	os.execute('echo '..os.clock()..'done. back in e.loop()')
	local l=L
	local dict=e.files.dictionary
	os.execute('echo dictionary=='..tostring(dict))
	local file=l.open(dict,'w')

	for i=1,#t do
		file:write(t[i],'\n')
	end
	file:close()

	if backupEnabled then e.backup() end

	local import=function(file)
		local n=0
		local t={}
		file=l.open(file)

		for line in file:lines() do
			n=n+1
			t[n]=line
		end

		return t
	end

	e.dict.entries=import(dict)
	file=l.open(e.files.input,'w')
	return file
end

function e:buildASCII()
	assert(self and type(self)=='table', 'expected table arg in e:buildASCII(), got type '..type(self)..' with value '..tostring(self))
	local conversion={az={97,122},AZ={65,90},num={48,57}}
	local order={'az','AZ','num'}
	local t=self.defaultSymbols or {''}
	local n=#t
	local s_char=L.s_char

	for i=1,#order do
		if self.as2Table[order[i]] then
			for i=conversion[order[i]][1],conversion[order[i]][2] do
				n=n+1
				t[n]=s_char(i)
			end
		end
	end

	return t
end

function e:bruteForce()--e.userinput.funcConfig
	assert(self and type(self)=='table', 'expected table arg in e:bruteForce(), got type '..type(self)..' with value '..tostring(self))

	local ASCII=e.buildASCII(self.bruteForce)
	local t=self.strings
	local _=t._
	local slash=t.slash
	local w1,w2,w3,w4,w5=t.w1,t.w2,t.w3,t.w4,t.w3
	local wFo1,wFo2,wFo3,wFi1,wFi2,wFi3,wFi4

	t=self.importedTable or false
	local fo1,fo2,fo3,fi1,fi2,fi3,fi4
	local dummy={''}
	if t then
		fo1,fo2,fo3=t.fo1 or dummy,t.fo2 or dummy,t.fo3 or dummy
		fi1,fi2,fi3,fi4=t.fi1 or dummy,t.fi2 or dummy,t.fi3 or dummy,t.fi4 or dummy
	end

	local file=L.open(e.files.input,'w')
	local I,II,III,IV,V,VI,VII=dummy,dummy,dummy,dummy,ASCII,ASCII,ASCII
	local startCount=self.bruteForce.overrideStopCountWithInt[1] and self.bruteForce.overrideStopCountWithInt[2] or e.defaultCfg.bruteForceStopCount
	if e.defaultCfg.bruteForceStopCount<startCount or startCount<1 then
		startCount=e.defaultCfg.bruteForceStopCount
	end
	local n=startCount
	t=nil
	local concat=L.concat
	local c1,c2,c3,c4,c5,c6,c7

	for i=1,#I do c1=I[i]
		for i=1,#II do c2=II[i]
			for i=1,#III do c3=III[i]
				for i=1,#IV do c4=IV[i]
					for i=1,#V do c5=V[i]
						for i=1,#VI do c6=VI[i]
							for i=1,#VII do c7=VII[i]
								for i=1,#fo1 do wFo1=fo1[i]
									for i=1,#fo2 do wFo2=fo2[i]
										for i=1,#fo3 do wFo3=fo3[i]
											for i=1,#fi1 do wFi1=fi1[i]
												for i=1,#fi2 do wFi2=fi2[i]
													for i=1,#fi3 do wFi3=fi3[i]
														for i=1,#fi4 do wFi4=fi4[i]

															--file:write(concat(w1,wFi1,_,wFi2,w3),'\n')
															--file:write(w1,wFi1,_,wFi2,w3,'\n')
															--file:write(concat({w1,wFo1,w2,wFi1,_,wFi2,c7,c6,c5,w3,w2,wFi1,_,wFi2,c7,c6,c5,_,wFi3,_,wFi4}),'\n')
															--file:write(w1,wFo1,w2,wFi1,_,wFi2,c7,c6,c5,w3,w2,wFi1,_,wFi2,c7,c6,c5,_,wFi3,_,wFi4,'\n')
															file:write('/Assets/tpp/ui/texture/Resource/keyitem/icon/ui_kit_sicula_covisitor_alp','\n')
															n=n-1

															if n<1 then
																os.execute('echo '..os.clock()..': max gen count of '..startCount..' reached. calling e.loop()')
																n=startCount
																--os.execute('echo '..n)
																file:close()
																file=e.loop()
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if tostring(file)~='file (closed)' then
		file:close()
	end
	file=e.loop()
	file:close()
end

function e:dictionaryAttack()
	assert(self and type(self)=='table', 'expected table arg in e:dictionaryAttack(), got type '..type(self)..' with value '..tostring(self))

	local l=L
	local time=l.time
	local start=time()+1
	local concat=l.concat
	local random=l.random
	local file=l.open(e.files.input,'w')
	l=nil
	local a,b,c
	local dict=e.dict.words
	local len=#dict
	local t=self.strings
	local _=t._
	local slash=t.slash
	local w1,w2,w3,w4,w5=t.w1,t.w2,t.w3,t.w4,t.w5
	t=nil
	collectgarbage()

	while true do
		if start<time() then
			file:close()
			file=e.loop()
			start=time()+1
		end

		a=dict[random(len)]
		b=dict[random(len)]
		c=dict[random(len)]

		file:write(w1,w2,_,a,_,b,slash,c,'\n')
	end
end

function e.main()
	local func

	if e.userInput.method.dictionaryAttack then
		func=e.dictionaryAttack
		assert(not e.userInput.method.bruteForce,'expected only one method in e.userInput.method, got multiple')
	elseif e.userInput.method.bruteForce then
		func=e.bruteForce
	end

	assert(func,'all expected e.userInput.method keys are falsey!')

	func(e.userInput.funcConfig)
end

e.main()
