using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;

namespace Fox.StrCode32
{
    public class Program
    {
        private static ulong GetStrCode32(string text)
        {
            const ulong seed0 = 0x9ae16a3b2f90404f;
            byte[] seed1Bytes = new byte[sizeof(ulong)];
            for (int i = text.Length - 1, j = 0; i >= 0 && j < sizeof(ulong); i--, j++)
            {
                seed1Bytes[j] = Convert.ToByte(text[i]);
            }
            ulong seed1 = BitConverter.ToUInt64(seed1Bytes, 0);
            ulong maskedHash = CityHash.CityHash.CityHash64WithSeeds(text, seed0, seed1) & 0x3FFFFFFFFFFFF;
            return maskedHash;
        }

        public static void Main(string[] args)
        {

        	bool reverse = false;
        	bool print_to_console = false;
        	bool help = false;
        	foreach (string arg in args)
	        {
	        	if (arg == "/r")
	        	{
	        		reverse = true;	//flip hash order to fmdl/fv2 format
	        	}
	        	if (arg == "/p")
	        	{
	        		print_to_console = true;
	        	}
	        	if (arg == "/h")
	        	{
	        		help = true;	//display options in console
	        	}
	        }

	        if (help)
	        {
	        	Console.WriteLine("mgsv path hasher\nhttps://github.com/unknown321/mgsv_path_hasher");
        		Console.WriteLine("Options:\n\t'main.exe /r' - reverse hash to fmdl/fv2 format\n\t" + 
									"'main.exe /p' - print hashes to console\n\t" + 
									"'main.exe /h' - help\n");
        	}

	        if (!File.Exists("input.txt"))
	        {
	        	Console.WriteLine("No 'input.txt' found!");
	        	return;
	        }
        	string[] names = File.ReadAllLines("input.txt");
        	List<string> hashed_names = new List<string>();

        	List<string> entries=new List<string>();
        	entries.Add("local this={");

			const string assets_const = "/Assets/";
			foreach (string filename in names)
			{
				string text = "";
				string hash = "";
				if (filename.StartsWith(assets_const))
				{
					text = filename.Substring(assets_const.Length);
				}
				else 
				{
					text = filename;
				}
				entries.Add('"' + text + '"' + ',');
				ulong testStrCode32 = GetStrCode32(text);
				hash = testStrCode32.ToString("x");
				if (hash.Length < 13)
					hash = hash.PadLeft(13,'0');
				hash = hash.Substring(hash.Length-13,13);
				if (reverse)
				{ 
					int chunkSize = 2;
			        int stringLength = hash.Length;
			        string reversedHash = "";
			        for (int i = 0; i < stringLength ; i += chunkSize)
			        {
			            if (i + chunkSize > stringLength) chunkSize = stringLength  - i;
			            reversedHash = hash.Substring(i, chunkSize) + reversedHash;
			        }
			        hash = reversedHash;
			    }
			    hashed_names.Add(filename + "\t" + hash);
			    if ((print_to_console) && (help))
			    	Console.WriteLine(filename + "\t" + hash);
			}

			//File.WriteAllLines("output.txt", hashed_names);
			//if (help)
				//Console.WriteLine("\ndone");
			//return;

			File.WriteAllLines("output.txt", hashed_names);
			entries.Add("}\nreturn this");
			File.WriteAllLines("output.lua",entries);
			return;
		}}
}