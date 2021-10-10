# Coffee + Codons
## Issue 01

> First published 9 Oct 2021

![Poster](https://github.com/BINFSOC/Coffee-and-Codons-01/blob/03937e3deec4b9568a72de280a440e89ef997fd8/CAC001.png)

## Introduction 

**Coffee + Codons** is a new publication from [BINFSOC](https://www.unswbinfsoc.com) which contains short, little walkthroughs for practical bioinformatics tools or just as a practise for beginners.  We also might share some already existing tools or tricks that we come across.  The main idea is that these should be quick enough that you can follow along, while enjoying a cup of coffee.  So grab your favourite mug, make yourself a beverage and follow along in this simple tutorial for making a command-line tool that translates DNA to protein. 





## Translate

>This activity is for beginners to writing shell scripts, or those who just want to brush up on their UNIX skills.

In this activity, we'll try and create a simple shell script that translates a nucleotide sequence to an amino acid sequence (protein).  We'll try to do it with
simple UNIX tools that we already have at our disposal. 

### The goal 

Our desired functionality (at first) is to treat the input to the program as one big sequence.  An alternative would be to treat characters on a new line as a different sequence, but for now lets just handle one.  Our use case should look like 

```
$ echo 'gttttttttttattgttgacggcagccccctcntag' | translate 
VFFLLLTAAPS*
$
```
Note that we are translating each **codon** (a 3-letter group of nucleotides) that appears in our input sequence into the appropriate amino acid character, including the **STOP** codon denoted by `*`.  This can be done with a few tools; namely `tr` (**tr**anslate) and `sed` (**s**tream **ed**itor).  

### Setup

The first step is to create a new directory with the sample files given, so go ahead and clone the repository with `$ git clone`.  

Our next step is to make a file to store our script, which we will write in `bash`.  As always, we add our **hashbang** to the top of the file so our shell knows how to interpret our file.  The best way to do this is to specify our `env` path instead of an **absolute** path to our `bash` installation.  This way, other users can use our script no matter where their `bash` is installed.  We can also change our permissions of the file so that we can execute the script from our shell.

```bash
$ pwd 
/home/CoffeeAndCodons/Translate
$ touch translate.sh
$ echo "#! /usr/bin/env bash" > translate.sh 
$ chmod +x translate.sh
```

### Formatting the input

Using your favourite text editor, open up `translate.sh` and add the following command  
```bash
tr -d '\n' |
```

This will remove all the newline characters found in the input, so that we are left with just the characters of the nucleotide sequence.  The `-d` flag 
is used to tell `tr` to simply remove each occurrence of the given character (see more options with `$ man tr`).  Note that the
beauty of shell scripting like this is that we can just call commands in our file; and since these in-built programs already work as 'pipeline' tools, we
don't have to worry about reading in from `STDIN` and outputting to `STDOUT`.

The next step would be to handle different cases (i.e. lowercase letters are different to uppercase).  The simplest way is to convert everything to uppercase.  Again, a little trick using `tr`:
```bash
tr '[:lower:]' '[:upper:]' 
```

To check if this works, try giving your program some input.  You can run your program from the command line and give some sample input using `echo`, again piping this through using the `|` character.

**NOTE:** you can always run the program from any directory by just typing in the name, by adding it to your `$PATH` variable.  Alternatively you may have to type `./transcribe.sh` instead. 

```bash
$ echo 'abc' | transcribe 
ABC
```

### Formatting the output 

If your program's output isn't nicely separated from the shell's next prompt, you can add this to the end of the script:
```bash
echo -e
```
This will add a newline character after the output. 

### Translating with sed

Now we can attempt to 'translate' our DNA into amino acid letter codes.  We can use **regex** matching for our 3-letter codons, and simply edit the input stream from `STDIN` in-place.  A good tool for this is `sed`, which provides a kind of 'find and replace' functionality.  For example, let's focus on **Tryptophan**, or Trp.  Trp's single letter code is `W`, and its codon is `TGG`.  Let's try this using `sed`, continuing our main pipeline in our script (remember to add the `|` symbol after the last `tr` command on the previous line)
```bash
sed "s/TGG/W/" 
```
The `s` symbol tells `sed` that we are replacing whatever we match.  The thing we're 'finding' is between the first two `/`'s, and the thing we're replacing is between the 2nd and 3rd `/`'s.  So, our program should now 'translate' the `TGG` codon to our amino acid `W`.

Let's see if it works.

```bash
$ echo 'TGG' | translate 
```

We can also try more complex input to see if our find-and-replace correctly ignores other letters.
```bash
'ATGGAAAAAAA'
'GGTTGG'
'eeeeeTggeeeee'
```

It looks like our program can successfully translate Trp codons.  But what happens if we try 
```bash
$ echo 'TGGTGGTGG' 
```

Is the output what we expect? 

See if you can figure out how to fix the problem.  

***HINT:** try other 'tags' for sed.  Remember to use the manual if in doubt!*

```bash
man sed
sed --help
```



### Additional codons

In the first amino acid we translated, **Tryptophan**, we only needed to 'find and replace' one codon.  But this was because Trp is the only amino acid that has precisely 1 codon!  All the others have more than one way of being translated; so we need to account for this.  For example, **Proline** (Pro) is encoded by `CCA`, `CCC`, `CCG`, and `CCT`.  This amounts to a lot of `sed` commands!  However, we can use the `sed`'s ability to handle *regex* expressions in the find-replace function using the `s///` delimeters.  In the case of **Proline**, we can simply use the face that the codons are two `C`'s followed by any nucleotide letter and write the following:

```sed
s/CC./P/g
```

where `P` is the one-letter symbol for Proline, and `CC.` matches the codons for it.  We're using the `.` here to mean 'any character' exactly once, after the two `C` characters.  Of course, this means that this regex also recognises codons such as `CCX`, `CC$` and so on.  But we're assuming that we get a valid nucleotide sequence here as our input.   

***BONUS:** add an input checker at the beginning to ensure only valid nucleotide sequences are given.* 
  
***EXTRA BONUS:** see if you can add the translation for RNA sequences, not just DNA.  How might you distinguish the two?  Could the program even 
automatically determine if it was RNA vs DNA?  When might the input be ambiguous?*

### Storing regex information in a separate file

As you might be already able to see, we're going to get a lot of lines needed for our `sed` commands, each piped into one another.  A solution is
to have all our necessary `s///g` blocks in a separate **file**, and let `sed` use the whole file to handle everything in one go.  

You might want to look up a codon table for all the different codons for different amino acids, such as [this one](http://www.hgmd.cf.ac.uk/docs/cd_amino.html).  Keep in mind that there are more than one codon tables out there, for different organisms.  

Using your favourite text editor again, make a file called `codon.sed` and fill it with all the regex phrases, one per line that we will need to handle all amino acids.  Remember that matching one out of a given set of characters can be done using `[]`.  For example, `[ACGTN]` matches exactly one `A`, or a `C`, or a `G` and so on.  

Use the man page for sed to figure out how to use this file in a single pipeline command, and update our `translate.sh` with this new line. 

### A problem 

The problem with using `sed` to go one-by-one through each amino acid is that the **order** in which we find-and-replace **matters**.  As an example, consider the input sequence `CATCAT`.  The expected output should be `HH`, as `CAT` codes for **Histadine**.  However, depending on how you have ordered your `codon.sed` regexes, you might also get **Isoleucine** (`CIAT`) or even **Serine** (`CASAT`)!  This is because the two `CAT` codons create a different codon overlapping in between them; both `TCA` and `ATC`.  

The good news is that we don't have to change our entire code -- in fact, there is a very simple command we can add just before the main `sed` command (the one that uses our codon file).  

Can you think of a way to use another `sed` command before, that solves the problem of 'overlapping codons'?  Note: you might have to add another command **after** the main `sed` line too, to 'cleanup' anything you've changed in the input.    
  
***HINT:** what do you know about codons?  Can you use anything to make certain constraints?*
  
***EXTRA HINT:** are there any characters we can safely assume are not in the original input sequence? Are there any characters you know for certain are not in the input?*



### The codon table

As we mentioned before, the mappings for each 3-letter combination of nucleotides to each amino acid is dependent on a *codon table*.  We simply hardcoded this into the various regexes used by `sed`. 

Perhaps a more elegant way would be to have this table in-built to our program, and the ability to 'swap in' various other tables that suit our needs (for example, the **mitochondrial code** or other organisms that use different codon mappings.  You can read more about this [here](https://en.wikipedia.org/wiki/List_of_genetic_codes)).  

As an additional activity, see if you can add a command line argument to the program that allows the user to input a given codon table (perhaps in CSV format); or maybe they can specify one of several 'default', in-built tables.  

### Extra features

*Some additional features you might like to try and add, as a challenge:*

- Handle frameshifts
- Handle ambiguity codes (for example, `N` means 'any nucleotide'
- Convert between RNA and DNA sequences 
- Automatically detect nucleotide sequences versus amino acid sequences 
- Error handling (if user gives invalid input for example)


### Solution

If you want to see the overall implementation, you can look at the `src` folder in this repository.  However, if you want to get the most out of this, try doing the 'problem solving' yourself before looking at the solution!  

If you've implemented any challenge solutions and want to contribute to the official solution, feel free to add a pull request or send an email to [the BINFsights team](mailto:binfsights@unswbinfsoc.com).  We'd also love any feedback you have, or ideas for future *Coffee+Codons* publications. 

>This tutorial by Cam McMenamie (cam@unswbinfsoc.com) 
