local this={
	documentation={self='/documentation'},--dummy
	gameLib={
		self='/gameLib',
		lng={
			self='/gameLib/lng',
			mgo='/gameLib/lng/mgo',
			tpp='/gameLib/lng/tpp'
		},
		qar={
			self='/gameLib/qar',
			mgo='/gameLib/lng/mgo',
			tpp='/gameLib/lng/tpp'
		}
	},
	main={
		self='/main',
		lib={
			self='/main/lib',
			dictionary={
				self='/main/lib/dictionary',
				lang='/main/lib/dictionary/lang',
				qar='/main/lib/dictionary/qar',
				toolDictionary='/main/lib/dictionary/toolDictionary'
			},
			exe={
				self='/main/lib/exe',
				lng='/main/lib/exe/lng',
				qar='/main/lib/exe/qar'
			},
			hash={
				self='/main/lib/hash',
				lng='/main/lib/hash/lng',
				qar='/main/lib/hash/qar'
			},
			scripts={
				self='/main/lib/scripts',
				batch='/main/lib/scripts/batch',
				lua='/main/lib/scripts/lua'
			}
		}
	}
}

this.pathToHere=io.popen'cd':read('*l')
this.masterPath=this.pathToHere:match('^(.*mgsv_dict_gen)')

print(this.masterPath)
--this.masterPath=this.masterPath:match(('^(.*)'..this.main.lib.scripts.lua:gsub('/','\\')..'$'))

function this.makeUniform(slash)return(
	slash=='/' and self:gsub('\\','/')or
	slash=='\\'and self:gsub('/','\\')
)end

function this:uniformBackSlashes()return self:gsub('/','\\')end
function this:uniformForwardSlashes()--[[print(tostring(self.self));]]return self:gsub('\\','/')end
function this.getMasterPath()return this.uniformForwardSlashes(this.masterPath), this.masterPath end

function this:getSubfolderFullPath()
	--print(tostring(self.self))
	self=type(self)=='table'and self.self or type(self)=='string'and self or nil
	if not self then return nil,nil,true end
	local forLua,forCmd=this.getMasterPath()
	return forLua..self, forCmd..this.uniformBackSlashes(self)
end

-- returns '/' format
function this.getFileRelativePath(string,slash)return this.makeUniform(string,this.masterPath..slash) end

--print(this.pathToHere)
--print('masterpath = '..this.masterPath)
--print(this.getMasterPath())
--print(this.getSubfolderFullPath(this.gameLib.lng.tpp))
--debug.debug()

this.debug={
	unitTests={
		function()return'yay\n'end
	}
}

this.currentMessage=false

this.messageTable={
	Test={
		{msg='test',func=this.debug.unitTests[1]}
	}
}
--print(this.messageTable.Test[1].func())

--this.currentMessage='test'

--while this.currentMessage do
	--for k,v in pairs(this.messageTable)do
			--os.execute('echo '..this.messageTable[k][v])
			--os.execute('echo '..this.messageTable.Test[1].func())
		--print('k='..k)
		--print('v='..)
		--if this.messageTable.Test[1].msg==this.currentMessage then
		--os.execute('echo '..this.messageTable[k][v])
		--os.execute('echo '..this.messageTable[k[v]].func())
		--end
	--end
	--this.currentMessage=false
--end

--print(this.debug.unitTests[1])

return this
