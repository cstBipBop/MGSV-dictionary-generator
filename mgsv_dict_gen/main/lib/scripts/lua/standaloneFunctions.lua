--rename to commonFunctions.lua
local this={}
local t=math
local ceil=t.ceil
local sqrt=t.sqrt
--os.execute('echo '..package.path..'\n')
--package.path = package.path .. ";../?.lua"
--os.execute('echo '..'package '..package.path..'\n')
--local Decipher=require('directoryStructure')
--print('Decipher path: '..tostring(Decipher))
--os.execute('echo '..tostring(Decipher.userInput)..'\n')
--local Decipher=require('mgsv_dictionary_gen_r2/main/lib/scripts/lua/directoryStructure')
--os.execute('echo '..Decipher.getSubfolderFullPath(Decipher.main.self)..'\n')
--Decipher=Decipher.getSubfolderFullPath(Decipher.main.self)
--Decipher=io.popen'cd'

--do
--	io.popen([[cmd /v:ON & (
--		pushd ]]..Decipher..[[echo cd)]])
--end

--Decipher=require(Decipher)

t={}
--[[do -- avoids multiple table rehashings in functions
	local n=Decipher.userInput
	if n.method.bruteForce then
		n=n.funcConfig.bruteForce.overrideStopCountWithInt[1] and n.funcConfig.overrideStopCountWithInt[2] or Decipher.defaultCfg.bruteForceStopCount
		if not n then
			n=2e6
		end
	elseif n.method.dictionaryAttack then
		n=2e6 -- temp value
	end

	for i=1,#ceil(sqrt(n)) do
		t[i]=false
	end
end]]

do
	for i=1,ceil(sqrt(2e6)) do
		t[i]=false
	end
end

	--n=n.method.bruteForce and n.funcConfig.bruteForce.overrideStopCountWithInt[1] and n.funcConfig.bruteForce.overrideStopCountWithInt[2]


--using non-descriptive args and vars in some of these to recycle variables w/o misleading names

function this.fileStatus(file)
	if not file then return nil,'arg file is falsey!'
		elseif file=='file (closed)' then return 'closed'
		elseif file:find('file %(%x+%)') then return 'open'
		elseif type(file)=='userdata' then return nil,'recieved userdata but could not determine file\'s state'
		else return nil,'invalid arg type, expected userdata, got '..type(file)
	end
end

--function this.removeTableDuplicates(t,previousTable)

function this.removeTableDuplicates(t,previousTable) -- t=newTable
	local n=#previousTable

	for i=1,#t do
		n=n+1
		previousTable[n]=t[i]
	end

	n=0
	t={}
	local aDuplicate={}

	for i=1,#t do
		if not aDuplicate[previousTable[i]] then
			n=n+1
			t[n]=previousTable[i]
			aDuplicate[t[n]]=true
		end
	end
	aDuplicate,n,previousTable,t=nil

	return t
end

function this.verifyAndRemoveDuplicateTableHashes(hashedTableValues,tableOfValidHashes) -- t=newTable
	local n=0
	local isValid={}

	for i=1,#tableOfValidHashes do
		isValid[tableOfValidHashes[i]]=true
	end
	tableOfValidHashes=nil

	local d={} -- table of duplicates
	--for i=1,m.abs(m.sqrt(#hashedTableValues)) -- 
	local t={}

	for i=1,#hashedTableValues do
		if not d[hashedTableValues[i]] then
			n=n+1
			t[n]=new[i]
			d[t[n]]=true
		end
	end

	d={}
	for i=1,#t do
		if isValid[t[i]] then
			n=n+1
			d[#d+1]=t[i]
		end
	end
	isValid,n,new,t=nil

	return d
end

--local test,error=this.fileStatus()
--print(test,error)

return this