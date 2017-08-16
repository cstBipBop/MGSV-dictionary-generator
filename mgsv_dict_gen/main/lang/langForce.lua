--this still isn't finished being rewritten

local this={}

local dict={
	lang={}, -- lang_dictionary
	hashes={}, -- hash list
	new={}, -- tbd
	words={} -- dictionary attack word list
}

local lib={
	hash={
		full='lib/hash/lng/full.txt',
		undefined='lib/hash/lng/undefined.txt'
	},
	dict={
		eng='lib/dictionary/englishDictionary.txt',
		gameLeadCap='lib/dictionary/lng/gameStrings_leadHigh.txt',
		gameLower='lib/dictionary/lng/gameStrings_low.txt'
	},
	exe={
		str32='Fox.StrCode32.exe'
	}
}

local files={
	hashList=false,
	atkDict=false,
	langDict='lang_dictionary.txt',
	backup=false,
	generatedIds='temp.txt',
	result='',
	exe=false
}

files.backup=G.strGSub(files.langDict,'.txt','_backup.txt')
files.result=G.strGSub(file.generatedIds,'.txt','_result.txt')

local command={
	doExeOnTarget=false
}

--global lua
local G={
	open=io.open,
	run=io.popen,
	ceil=math.ceil,
	random=math.random,
	sqrt=math.sqrt,
	time=os.clock,
	cmd=os.execute,
	strChar=string.char,
	strFormat=string.format,
	concat=table.concat
}

math.randomseed(G.time())
G.random()

function this.errorMessage(caller,func,block,msg)
	local file=io.open('___ERROR.txt','w')
	msg=('error: [caller]'..tostring(caller)..'|[function]'..tostring(func)..'|[block]'..tostring(block)..'|[message]'..tostring(msg))
	file:write(msg)
	file:close()
end

function this:init()
	files.atkDict=self.lib.dictionary
	files.exe=self.lib.exe
	files.hashList=self.lib.hash
	local f=files

	do
		local t={'atkDict','exe','hashList'}

		for i=1,#t do
			if not f[t[i]] then
				this.errorMessage('this.Main()','this.init(self)','user file input validation','self.lib contains invalid selection for table files.'..t[i])
				os.exit(exit)
			end
		end
	end

	local import=function(file,isHash)
		local n=0
		local t={}

		if isHash then
			for line in file:lines() do
				n=n+1
				t[n]=line+0 -- implicit tonumber()
			end
		else
			for line in file:lines() do
				n=n+1
				t[n]=line
			end
		end

		return t
	end

	dict.hashes=import(f.hashList,true)
	dict.lang=import(f.langDict)
	if self.method.dictionaryAttack then
		dict.words=import(f.atkDict)
	end
	command.doExeOnTarget=f.exe..' '..f.result
end

function this.backup() -- runs after closing file; essentially a failsafe in event of crash, blackout, etc. while lua is performing i/o.
	local g=G
	g.cmd(g.strFormat('copy "%s" "%s"', files.langDict, files.backup))
end

function this.removeLangIdDuplicates(newIds,oldIds)
	local n=#oldIds

	for i=1,#newIds do
		n=n+1
		oldIds[n]=newIds[i]
	end

	n=0
	local duplicate={}
	local t={}

	for i=1,#oldIds do
		if not duplicate[oldIds[i]] then
			n=n+1
			t[n]=oldIds[i]
			duplicate[oldIds[i]]=true
		end
	end

	n,duplicate,newIds,oldIds=nil

	return t
end

function this.verifyHashAndRemoveDuplicates(newHashes,validHashes)
	local n=0
	local isValid={}

	for i=1,#validHashes do
		isValid[validHashes[i]]=true
	end

	validHashes=nil
	local duplicate={}
	local t={}

	for i=1,#newHashes do
		if not duplicate[newHashes[i]] then
			n=n+1
			t[n]=newHashes[i]
			duplicate[t[n]]=true
		end
	end

	duplicate=nil
	newHashes=t
	t={}
	n=0

	for i=1,#newHashes do
		if isValid[newHashes[i]] then
			n=n+1
			t[n]=newHashes[i]
		end
	end

	return t
end

function this.createNewDictionary()
	local f=files
	local g=G

	g.run(command.doExeOnTarget)
	local file=g.open(f.result)
	local n=0
	local r={}
	
	for line in file:lines() do
		n=n+1
		r[n]=line
	end

	local rLangs={}

	for i=1,(g.ceil(g.sqrt(n))) do -- avoiding double table rehashings in string.match block
		rLangs[i]=true
	end

	local rHashes=rLangs

	for i=1,n do
		rHashes[i]=((r[i]:match('%s([%d+]+)'))+0) -- implicit tonumber()
		rLangs[i]=r[i]:match('([%a+%d+_-]+)%s')
	end

	r=nil
	r=this.verifyHashAndRemoveDuplicates(rHashes,dict.hashes)

	for i=1,#r do
		for I=1,n do
			if r[i]==rHashes[I] then
				r[i]=rLangs[I]
			end
		end
	end

	rHashes,rLangs=nil

	return this.removeLangIdDuplicates(r,dict.lang)
end

function this.NAMEME()
	local open=G.open
	local f=files
	local file=open(f.langDict,'w')
	local t=this.createNewDictionary()

	for i=1,#t do
		file:write(t[i],'\n')
	end
	file:close()
	if config.backup then this.backup()end

	t={}
	file=open(f.langDict)
	local n=0

	for line in file:lines() do
		n=n+1
		t[n]=line
	end
end



function this:bruteForce()
	local ASCII={'',_}
	local n=#ASCII
	local a,b,c,d,e,f,g
	local id={true,true,true,true}
	local G=G
	local strChar=G.strChar
	local concat=G.concat

	if self.az then
		for i=97,122 do
			n=n+1
			ASCII[n]=strChar(i)
		end
	end

	if self.AZ then
		for i=65,90 do
			n=n+1
			ASCII[n]=strChar(i)
		end
	end

	if self.num then
		for i=48,57 do
			n=n+1
			ASCII[n]=strChar(i)
		end
	end

	local lastChar=ASCII[n]
	local strLen=string.rep(lastChar,config.strRepeat)
	local max=w1..strLen
	local open=G.open
	local F=files
	local file=open(F.generatedIds,'w')
	local len=n
	local customStrings=config.userDefinesStrings
	n=0

	for i=1,len do a=ASCII[i]
		for i=1,len do b=ASCII[i]
			for i=1,len do c=ASCII[i]
				for i=1,len do d=ASCII[i]
					for i=1,len do e=ASCII[i]
						for i=1,len do f=ASCII[i]
							for i=1,len do g=ASCII[i]

								id={
									customStrings.w1,
									c,
									d,
									e,
									customStrings._,
									customStrings.w2,
									f,
									g
								}
								file:write(concat(id),'\n')
								
								n=n+1

								if n==14e5 then
									n=0
									file:close()
									
								end

								if n==14e5 or id==max then
									n=0
									file:close()
									local t=this.runFoxString()
									file=open(F.langDict,'w')
									for i=1,#t do
										file:write(t[i],'\n')
									end
									file:close()
									if config.backup then this.backup()end
									file=open(F.langDict)
									t={}
									for line in file:lines() do
										n=n+1
										t[n]=line
									end
									dict.lang=t
									t=nil
									n=0
									if id==max then
										os.exit(exit)
									end
									file=open(F.generatedIds,'w')
								end
							end
						end
					end
				end
			end
		end
	end
end

function this:dictionaryAttack()
	local g=G
	local time=g.time
	local start=time()+1
	local concat=g.concat
	local random=g.random
	local file=g.open(files.generatedIds,'w')
	g=nil
	local a,b,c
	local dict=dict.words
	local len=#dict
	local t={true,true,true,true}

	while true do
		if start<time() then
			file:close()
			return
		end
		
		a=dict[random(len)]
		b=dict[random(len)]
		--c=dict[random(len)]
		
		t={
			self.w1,
			a,
			self._,
			b,
			self.w2
		}
		file:write(concat(t),'\n')
	end
end

function this:Main()
	this.init()

	local func

	if self.method.dictionaryAttack then
		func=this.dictionaryAttack(config.userDefinesStrings)
	else
		func=this.bruteForce(config.userDefinesStrings)
	end

	self=nil
	local f=files
	local t
	local open=G.open
	local file=open(f.langDict,'w')

	while true do
		func()
	end
end

function draft()
this.Main(
	{
		method={
			dictionaryAttack=true,--higher priority
			bruteForce=false
		},

		lib={
			dictionary=lib.dictionary.gameLower,
			exe=lib.exe.str32,
			hash=lib.hash.undefined
		},

		config={
			backup=false,
			debug=false,
			errorMessages=true,
			messageOnNewEntry=true,
			len=0,
			strRepeat=0,
			strings={
				_='_',
				w1='',
				w2='',
				w3='',
				w4='',
				w5=''
			},
			idForm={'w1','_',1,'_',2,'_','w2'}
		}
	}
)
end