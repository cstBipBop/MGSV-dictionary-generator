# MGSV-dictionary-generator
lua 5.1.5

Builds QAR and LNG dictionaries with lua. Checks for duplicates and verifies generated entries by checking against hash lists.
Can do either a dictionary or brute-force attack.

Uses Atvaarks' Fox.StrCode32.exe and a slightly modified version of unknown123's mgsv_path_hasher.exe (changed default switches).

# Manual

Written for vanilla lua 5.1.5

Script location: main\decipher.lua

## Input options (e.userInput):

method{ -- set desired attack method to true and others to false

  dictionaryAttack = boolean,

  bruteForce = boolean

}

files={ -- select key from e.lib

  dictionary = table key, -- list of words to use in attack
  
  exe = table key,
  
  hashes = table key, -- hash list to validate generated entries with
  
  luaTable = table key -- loads lua file with tabled dictionary; intended for use with QAR paths

}

luaConfig={

  backup = boolean, -- creates copy of new dictionary on file close; performance hit but ensures a good copy always exists; failsafe in event of crash during io
  
  debug = dummy,
  
  consoleFeedback = dummy
 
}

funcConfig.bruteForce={

  defaultSymbols={'','\_'}, -- must be table; use any characters not covered by as2Table
  
  as2Table={az=boolean,AZ=boolean,num=boolean}, -- controls what character sets are generated in e.buildASCII(); {a-z, A-Z, 0-9}
  
  overrideStopCountWithInt={boolean,int} -- if [1]==true then ovverides default stop count set by e.defaultCfg.bruteForceStopCount, unless int is less than 1 or greater than default stop count
  
}

funcConfig.strings -- set custom strings

funcConfig.importedTable -- set key for table specified by e.userInput.files.luaTable; e.g. fi1={'file','source','location'}

## Editing method functions

### e:bruteForce()

  For best performance, always readjust the values of Roman numeral vars and use vars further in the for blocks first. Roman numerals can be set to either the dummy table {''} or the ASCII table. e.g. local I,II,III,IV,V,VI,VII=dummy,dummy,dummy,dummy,ASCII,ASCII,ASCII
  
  Generated entry format needs to be manually adjusted.
  
  e.g. file\:write(w1,wFo1,w2,wFi1,\_,wFi2,c5,c6,c7,w3,w2,wFi1,\_,wFi2,c5,c6,c7,\_,wFi3,\_,wFi4,'\n')
  
### e:dictionaryAttack()

  Generated entry format needs to be manually adjusted, similarly to e:bruteForce(). For best performance, comment out letter unused letter vars in while loop. a,b,c hold random line selections from the selected attack dictionary.
