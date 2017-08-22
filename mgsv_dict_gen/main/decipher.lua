-- local dir=io.popen"cd":read'*l' -- apparently exe needs full path when not in current folder
local Library=require('lib/scripts/lua/directoryStructure')

local this={
	command={
		doExe=false
	},

	defaultCfg={
		bruteForceStopCount=2e6, -- start to run into memory issues beyond 2e6 lines, dependent on length of entries
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
			qarStr='lib/dictionary/qar/tabledStrings'
		},

		hashes={
			lngFull='lib/hash/lng/full.txt',
			lngUndefined='lib/hash/lng/undefined.txt',

			qarAll_cat11='lib/hash/qar/hashes_all_cat11.txt', -- hashes_all_cat[concatenationLength]
			qarAll_full='lib/hash/qar/hashes_full.txt',
			qarChunk_cat11='lib/hash/qar/undefined_chunk_cat11.txt',
			qarChunk_full='lib/hash/qar/undefined_chunk_full.txt',
			qarTex_full='lib/hash/qar/undefined_textures_full.txt',
			qarTex_cat11='lib/hash/qar/undefined_textures_cat11.txt'
		},
		
		exe={
			path=Library.getSubfolderFullPath(Library.main.lib.exe.qar)..'\\mgsvPathHasher.exe',
			str32=Library.getSubfolderFullPath(Library.main.lib.exe.lng)..'\\Fox.StrCode32.exe'
			--path=dir..'/lib/exe/qar/mgsvPathHasher.exe',
			--str32=dir..'/lib/exe/lng/Fox.StrCode32.exe'
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

-- localized global vanilla lua table functions
local ceil=math.ceil
local random=math.random
local sqrt=math.sqrt

local time=os.clock
local cmd=os.execute

local open=io.open
local run=io.popen

local s_char=string.char
local s_find=string.find
local s_format=string.format
local s_gfind=string.gfind
local s_gsub=string.gsub

local concat=table.concat


--localized global vanilla lua vars/non-table functions
local assert=assert
local collectgarbage=collectgarbage
local pairs=pairs
local tostring=tostring
local type=type

math.randomseed(os.time())
random()

this.userInput={
	
	method={
		dictionaryAttack=false,
		bruteForce=true
	},
	
	files={
		dictionary=this.lib.dictionary.gameLower,
		exe=this.lib.exe.path,
		hashes=this.lib.hashes.qarTex_cat11,
		luaTable=this.lib.dictionary.qarStr
	},
	
	luaConfig={ -- user settings that affect whole file; should rename at some point
		backup=false, -- creates a copy of the new dictionary after closing; slower but ensures a good file always exists in the event of a crash or whatever corrupting files while performing io
		debug=false, -- dummy
		consoleFeedback=false -- dummy
	},
	
	funcConfig={
		bruteForce={
			defaultSymbols={}, -- any characters not covered by as2Table
			as2Table={az=false,AZ=false,num=true}, -- what character sets to generate
			appendDefaultSymbolsToDefaultAsciiTables=false,
			overrideStopCountWithInt={false,25e4} -- [1]=enabled/disabled; [2]=0<[2]<2e6; adjust this if creating absurdely long entries
		},

		dictionaryAttack={
			overrideTimeEachLoopWithInt={true,1}, -- [1]=enabled/disabled; [2]=0<[2]
			numberOfChars={true,3}
		},

		strings={ -- /Assets/tpp/chara/dld/Pictures/dld0_body0_def_srm -- /Assets/tpp/chara/dl, c1, /Pictures/dl, c1, c2, _, wFi1, c3, _def_, wFi2 -- w1, c5, w2, c5, c6, _, wFi1, c7, w3, wFi2
			_='_',
			slash='/',
			w1='/Assets/tpp/chara/dl',
			w2='/Pictures/dl',
			w3='_def_',
			w4='',
			w5='',
			w6='',
			w7=''
		},
		
		importedTable={
			fo1=false,
			fo2=false,
			fo3=false,

			fi1={'file','texture','generic','paramPart'},
			fi2={'file','texture','generic','paramLayer'},
			fi3=false,
			fi4=false
		}
	}
}

local backupEnabled=this.userInput.luaConfig.backup

function this:init()
	
	assert(self, 'no argument given to e.init()')

	if type(self.files.dictionary)=='string' then
		local t={}
		local file=open(self.files.dictionary)

		for line in file:lines() do
			t[#t+1]=line
		end

		this.dict.words=t
	end

	local tbl=type(self.files.luaTable)=='string' and self.files.luaTable or false

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
		file=open(file)

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

	if self.files.exe==this.lib.exe.str32 then -- lng
		this.dict.hashes=import(self.files.hashes,true)
		this.files.input=this.lib.workFiles.lngIn
		this.files.output=this.lib.workFiles.lngOut
		this.files.dictionary=this.lib.target.lng
		this.command.doExe=Library.quotePath(this.lib.exe.str32)..' '..this.files.input
	else -- qar
		this.hashIsQAR=true
		this.dict.hashes=import(self.files.hashes)
		this.files.input=this.lib.workFiles.qarIn
		this.files.output=this.lib.workFiles.qarOut
		this.files.dictionary=this.lib.target.qar
		this.command.doExe=Library.quotePath(this.lib.exe.path)..' '..this.files.input
	end

	this.files.hashList=self.files.hashes

	this.files.backup=s_gsub(this.files.dictionary,'.txt','_backup.txt')

	this.dict.entries=import(this.files.dictionary)

	this.dict.words=import(self.files.dictionary)
	this.files.wordList=self.files.dictionary

	this.files.exe=self.files.exe

	return self
end

this.userInput=this.init(this.userInput)
this.init=nil
table.remove(this.lib)
collectgarbage()


function this.backup() -- deprecated
	
	cmd(s_format('copy "%s" "%s"',this.files.dictionary,this.files.backup))
end


local cmmnFunc=require('lib/scripts/lua/standaloneFunctions')
this.removeDuplicateEntries=cmmnFunc.removeTableDuplicates -- newTable,previousTable


function this.removeDuplicateEntries(new, old)
	local n=#old

	for i=1,#new do							-- append entries from new table to the end of old table
		n=n+1
		old[n]=new[i]
	end

	n=0
	local aDuplicate={}
	local t={}								-- table t is the returned table

	for i=1,#old do							-- (Duplicate entry removal) if entry from table 'old' has not been added to table aDuplicate: raise n by one, add entry to table t at position n, and add entry to table aDuplicate.
		if not aDuplicate[old[i]] then
			n=n+1
			t[n]=old[i]
			aDuplicate[old[i]]=true
		end
	end

	return t
end

function this.verifyHashAndRemoveDuplicates(new, hashList)
	local n=0
	local isValid={}

	for i=1,#hashList do						-- import table of hashes in [183d24ba]=true format.
		isValid[hashList[i]]=true
	end

	local aDuplicate={}
	local t={}

	for i=1,#new do								-- (Duplicate entry removal) if entry from table 'new' arg has not been added to table aDuplicate: raise n by one, place entry in table t at position n, and add entry to table aDuplicate. 
		if not aDuplicate[new[i]] then
			n=n+1
			t[n]=new[i]
			aDuplicate[t[n]]=true
		end
	end

	aDuplicate=nil

	local m={}									-- table m is the returned table

	for i=1,#t do								-- (Cross examine entry hash with list of known hashes) if entry from table t is a valid hash: append it to table m.
		if isValid[t[i]] then
			n=n+1
			m[#m+1]=t[i]
		end
	end

	return m
end

function this.createNewDictionary()
	collectgarbage() -- required, else lua randomly screws up line additions to table

	

	--cmd('echo '..time()..': entries')

	--[[
		local n=0
		local file=open(e.files.input)
		
		for line in file:lines() do
			n=n+1
			oEntries[n]=line
		end
		
		n=0
	]]

	--cmd('echo '..time()..': creating output file')

	run(this.command.doExe)

	local oEntries={}
	local oHashes={}
	local n=0
	local file=open(this.files.output)

	gfind=s_gfind
	do
		local bufferSize=2^13
		if this.hashIsQAR then
			while true do
				local lines,rest=file:read(bufferSize,'*line')
				if not lines then break end
				if rest then lines=lines..rest end
				for entry,hash in gfind(lines,'(%S+)%s%x(%x%x%x%x%x%x%x%x%x%x%x)') do
					n=n+1
					oEntries[n]=entry
					oHashes[n]=hash
					--cmd(string.format('echo hash=%s entry=%s',hash,entry))
				end
			end
		else
			while true do
				local lines,rest=file:read(bufferSize,'*line')
				if not lines then break end
				if rest then lines=lines..rest..' ' end
				for entry,hash in gfind(lines,'(%S+)%s(%d+)%s') do
					n=n+1
					oEntries[n]=entry
					oHashes[n]=hash+0
				end
			end
		end
	end
	file:close()
	collectgarbage()

	assert(#oEntries==#oHashes, string.format('#oEntries~=#oHashes. #oEntries=%s #oHashes=%s. Possible cause: poor memory management. Lower bruteForce count or dictionaryAttack time and try again. Else add a collectgarbage() line before the problem code.', #oEntries, #oHashes))

	cmd('echo '..#oEntries)
	cmd('echo last entry = '..oEntries[#oEntries])

	local o=this.verifyHashAndRemoveDuplicates(oHashes,this.dict.hashes)

	for i=1,#o do
		for I=1,n do
			if o[i]==oHashes[I] then
				o[i]=oEntries[I]
			end
		end
	end

	oEntries,oHashes=nil
	--cmd('echo '..time()-temp_startTime)
	return this.removeDuplicateEntries(o,this.dict.entries)
end

function this.loop()
	local t=this.createNewDictionary()
	
	local dict=this.files.dictionary
	local file=open(dict,'w')

	for i=1,#t do
		file:write(t[i],'\n')
	end
	file:close()

	--if backupEnabled then e.backup() end
	if backupEnabled then
		cmd(s_format('copy "%s" "%s"',this.files.dictionary,this.files.backup))
	end

	local import=function(file)
		local n=0
		local t={}
		file=open(file)

		for line in file:lines() do
			n=n+1
			t[n]=line
		end

		return t
	end

	this.dict.entries=import(dict)
	file=open(this.files.input,'w')
	return file
end

function this:buildASCII()
	assert(self and type(self)=='table', 'expected table arg in e:buildASCII(), got type '..type(self)..' with value '..tostring(self))
	
	local conversion={az={97,122},AZ={65,90},num={48,57}}
	local order={'az','AZ','num'}
	local t=self.defaultSymbols or {}
	local n=#t
	local s_char=s_char

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

function this:bruteForce()--e.userinput.funcConfig
	assert(self and type(self)=='table', 'expected table arg in e:bruteForce(), got type '..type(self)..' with value '..tostring(self))

	local t=self.strings
	local _=t._
	local slash=t.slash

	local word={
		t.w1,
		t.w2,
		t.w3,
		t.w4,
		t.w5
	}

	local fileWord={}
	local folderWord={}
	local NUL={''}

	do
		local t=self.importedTable

		fileWord={
			t.fi1 or NUL,
			t.fi2 or NUL,
			t.fi3 or NUL,
			t.fi4 or NUL
		}

		folderWord={
			t.fo1 or NUL,
			t.fo2 or NUL,
			t.fo3 or NUL
		}
	end

	local file=open(this.files.input,'w')

	local ASCII={
		numeric=this.buildASCII{as2Table={num=true}},

		alpha_all=this.buildASCII{as2Table={az=true, AZ=true}},
		alpha_lower=this.buildASCII{as2Table={az=true}},
		alpha_upper=this.buildASCII{as2Table={AZ=true}},

		alphanumeric=this.buildASCII{as2Table={az=true, AZ=true, num=true}},
		alphanumeric_lower=this.buildASCII{as2Table={az=true, num=true}},
		alphanumeric_upper=this.buildASCII{as2Table={AZ=true, num=true}},

		user=this.buildASCII(self.bruteForce)
	}

	if self.bruteForce.defaultSymbols and 0<#self.bruteForce.defaultSymbols and self.bruteForce.appendDefaultSymbolsToDefaultAsciiTables then
		for k,v in pairs(ASCII) do
			for i=1,#self.bruteForce.defaultSymbols do
				v[#v+1]=self.bruteForce.defaultSymbols[i]
			end
			ASCII[k]=v
		end
	end

	local charTableAssigns={
		[1]=ASCII.user,
		[2]=ASCII.user,
		[3]=ASCII.user,
		[4]=NUL,
		[5]=NUL,
		[6]=NUL,
		[7]=NUL
	}

	local startCount=self.bruteForce.overrideStopCountWithInt[1] and self.bruteForce.overrideStopCountWithInt[2] or this.defaultCfg.bruteForceStopCount
	if this.defaultCfg.bruteForceStopCount<startCount or startCount<1 then
		startCount=this.defaultCfg.bruteForceStopCount
	end
	local n=startCount
	--local char={}
	local char1,char2,char3,char4,char5,char6,char7
	local wFi1,wFi2,wFi3,wFi4
	local wFo1,wFo2,wFo3
	t=nil

	for i=1,#charTableAssigns[7] do char7=charTableAssigns[7][i] -- w1, fi1, n, fi2, w2
		for i=1,#charTableAssigns[6] do char6=charTableAssigns[6][i]
			for i=1,#charTableAssigns[5] do char5=charTableAssigns[5][i]
				for i=1,#charTableAssigns[4] do char4=charTableAssigns[4][i]
					for i=1,#charTableAssigns[3] do char3=charTableAssigns[3][i]
						for i=1,#charTableAssigns[2] do char2=charTableAssigns[2][i]
							for i=1,#charTableAssigns[1] do char1=charTableAssigns[1][i]
								for i=1,#folderWord[1] do wFo1=folderWord[1][i]
									for i=1,#folderWord[2] do wFo2=folderWord[2][i]
										for i=1,#folderWord[3] do wFo3=folderWord[3][i]
											for i=1,#fileWord[1] do wFi1=fileWord[1][i]
												for i=1,#fileWord[2] do wFi2=fileWord[2][i]
													for i=1,#fileWord[3] do wFi3=fileWord[3][i]
														for i=1,#fileWord[4] do wFi4=fileWord[4][i]

															file:write(word[1], char3, word[2], char3, char2, _, wFi1, char1, word[3], wFi2,'\n')
															n=n-1

															if n<1 then
																--cmd('echo '..time()..': max generated line count of '..startCount..' reached; calling e.loop()')
																n=startCount
																file:close()
																file=this.loop()
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

	file=this.loop()
	file:close()
end

function this:dictionaryAttack()
	assert(self and type(self)=='table', 'expected table arg in e:dictionaryAttack(), got type '..type(self)..' with value '..tostring(self))

	
	local time=time
	local start=time()+1
	local random=random
	local file=open(this.files.input,'w')

	local char={true,true,true,true}

	do
		if type(self.dictionaryAttack.numberOfChars)=='table' and self.dictionaryAttack.numberOfChars[1] and self.dictionaryAttack.numberOfChars[2] then
			local t={}
			local n=self.dictionaryAttack.numberOfChars[2]

			assert(type(n)=='number' and n%1==0, string.format('e.userInput.funcConfig.dictionaryAttack[2] invalid. Expected whole number, got type %s with value of %s.',type(n),n))
			assert(0<n, string.format('e.userInput.funcConfig.dictionaryAttack.numberOfChars[2] < 0\n%s < 0',n))
			
			for i=1,n do
				t[i]=true
			end

			char=t
		end
	end

	local n=#char

	local a,b,c
	local dict=this.dict.words
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
			file=this.loop()
			start=time()+1
			os.exit(exit)
		end

		for i=1,n do
			char[i]=dict[random(len)]
		end

		file:write(char[1],_,char[2],_,char[3],'\n')
	end
end

function this.main()
	local func

	if this.userInput.method.dictionaryAttack then
		func=this.dictionaryAttack
		assert(not this.userInput.method.bruteForce,'expected only one method in e.userInput.method, got multiple')
	elseif this.userInput.method.bruteForce then
		func=this.bruteForce
	end

	assert(func,'all expected e.userInput.method keys are falsey!')

	func(this.userInput.funcConfig)
end

this.main()
