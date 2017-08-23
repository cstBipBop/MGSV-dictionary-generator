# MGSV-dictionary-generator
lua 5.1.5

Builds QAR and LNG dictionaries with lua. Checks for duplicates and verifies generated entries by checking against hash lists.
Can do either a dictionary or brute-force attack.

Uses Atvaarks' Fox.StrCode32.exe and a slightly modified version of unknown123's mgsv_path_hasher.exe (changed default switches).

# Manual

Written for vanilla lua 5.1.5

Script location: main\decipher.lua

Note: The first run of the script may fail due to anti-viruses scanning the exe. Just run it again if it crashes and it should no longer happen. In some cases it may happen more than once initially, just try again with the default settings until the problem resolves. Error will produce something to the effect of:

 decipher.lua:357: attempt to concatenate field '?' (a nil value)
 
 stack traceback:
 
        decipher.lua:357: in function 'createNewDictionary'
        decipher.lua:375: in function 'loop'
        decipher.lua:553: in function 'func'
        decipher.lua:624: in function 'main'
        decipher.lua:627: in main chunk
        \[C]: ?

## Input options (this.userInput):

method={ -- set desired attack method to true and others to false

  dictionaryAttack = boolean,

  bruteForce = boolean

}

files={ -- select key from this.lib

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
  
  as2Table={az=boolean,AZ=boolean,num=boolean}, -- controls what character sets are generated in this.buildASCII(); {a-z, A-Z, 0-9}
  
  appendDefaultSymbolsToDefaultAsciiTable = boolean, -- sets whether to add entries in the defaultSymbols table to all ASCII char tables
  
  overrideStopCountWithInt={boolean,int} -- if [1]==true then ovverides default stop count set by this.defaultCfg.bruteForceStopCount, unless int is less than 1 or greater than default stop count
  
}

funcConfig.strings -- set custom strings

funcConfig.importedTable -- set key for table specified by this.userInput.files.luaTable; e.g. fi1={'file','source','location'}

## Editing method functions

### this:bruteForce()

  Function takes this.userinput.funcConfig as self arg. Table word consists of self.strings entries. NUL is a 1 length table with an empty string as the only entry, used as a psuedo nil value in the for loop. fileWord and folderWord tables recieve their entries from self.importedTable. If the user does not specify an entry or it is not valid, the NUL table is used as a substitute to prevent a script crash.
  
  Table ASCII was changed on 08/22/2017 to consist of several subtables with preset ASCII tables for more efficient attack attempts. These subtables include the user defined one created in self.bruteForce. The keys used should make the purpose of each table self-explanatory; each consists of varying alpha, numeric, and casing combinations.
  
  charTableAssigns is where ASCII subtables are assigned by the user and is later accessed in the for loop. An example usage would be charTableAssigns={[1]=ASCII.alpha_lower, [2]=ASCII.alpha_lower, [3]=ASCII.user, [4]=ASCII.numeric, [5]=NUL, [6]=NUL, [7]=NUL}.
  
  The generated entry format needs to be manually adjusted within the for loop. char[n] == carTableAssigns[n][i], wFo[n] == folderWord[n][i], wFi[n] == fileWord[n][i], and the word table is a static one unaffected by the loop (just specify which indice you want to use).
  
  i.e. file\:write(word[1], char3, word[2], char3, char2, \_, wFi1, char1, word[3], wFi2, '\n')
  
### this:dictionaryAttack()

  Generated entry format needs to be manually adjusted, similarly to this:bruteForce(). For best performance, comment out letter unused letter vars in while loop. a,b,c hold random line selections from the selected attack dictionary.
