REM >Occurs
REM Counts the number of occurrences of each symbol in an ASCII file
REM R. R. Thomas
REM v0.1 25/1/92; v0.11 15/10/95; v0.2 13/11/96 (WordTimes)
REM v0.3 14/11/96; v0.31 25/11/96 (Occurs)
REM 21/02/97 (improved sort) Eric Hutton

ON ERROR PROCerror

syntax$="Occurs [-counts] [-nonalpha] [-words] <file> [-results <file>]"
size%=512
DIM buf% size%-1

SYS "OS_GetEnv" TO com$
t%=INSTR(com$," -quit ")
IF t% THEN tail$=MID$(com$,INSTR(com$," ",t%+LEN" -quit ")+1) ELSE tail$=""
SYS "XOS_ReadArgs","Counts/S,Nonalpha/S,Words/S,File,Results,Debug/S",tail$,buf%,size% TO ;f%

IF (f% AND 1) OR buf%!12=0 THEN PROChelp
counts%=!buf%
nonalpha%=buf%!4
letters%=buf%!8
in$=FNos_getstring(buf%!12):in%=0
out$=FNos_getstring(buf%!16):out%=0
debug%=buf%!20

chains%=500
DIM hash%(chains%-1):hash%()=-1
maxwords%=18000
DIM word$(maxwords%-1),no%(maxwords%-1),next%(maxwords%-1):next%()=-1
DIM snext%(maxwords%-1),sl%(255)
DIM letter% 255
FOR i%=0 TO 32:letter%?i%=0:NEXT
FOR i%=127 TO 255:letter%?i%=0:NEXT
FOR i%=33 TO 126
IF nonalpha% THEN letter%?i%=TRUE ELSE IF letters% THEN letter%?i%=FNisalpha(CHR$(i%)) ELSE letter%?i%=FNisalnum(CHR$(i%))
NEXT
letter%?ASC("_")=TRUE

words%=-1
in%=OPENIN(in$)
IF in%=0 THEN ERROR EXT 1,"Occurs: could not open file "+in$
PRINT "Reading "+in$+": 0%"+CHR$(13);
percent%=0:gap%=EXT#in%/100:next_percent%=gap%

REPEAT
word$=FNword
IF letters% THEN word$=FNtolower(word$)
word%=FNexists(word$)
IF word%>=0 THEN no%(word%)+=1 ELSE IF word$<>"" THEN PROCinsert(word$,word%)
IF PTR#in%>next_percent% THEN
PRINT "Reading "+in$+": ";percent%;"%"+CHR$(13);
percent%+=1
next_percent%+=gap%
ENDIF
UNTIL EOF#in%
CLOSE#in%
in%=0
PRINT "Reading "+in$+": 100%"

IF words%=0 THEN PRINT "There are no words in "+in$:END

IF debug% THEN
PRINT "No. of links on each chain"
t%=0
FOR i%=0 TO chains%-1
j%=0:h%=hash%(i%)
IF h%<>-1 THEN REPEAT:h%=next%(h%):j%+=1:UNTIL h%=-1
PRINT j%
t%+=j%
NEXT
PRINT "Total links: ";t%
ENDIF

REM...PROCsort

PROCpresort
PROCnsort

IF out$<>"" THEN
out%=OPENOUT(out$)
IF out%=0 THEN ERROR EXT 1,"Occurs: could not open file "+out$
BPUT#out%,"Occurrences of words (";
IF letters% THEN BPUT#out%,"letters only"; ELSE IF nonalpha% THEN BPUT#out%,"space-delimited"; ELSE BPUT#out%,"alphanumerics";
BPUT#out%,") in "+in$
BPUT#out%,"There are "+STR$(words%+1)+" words"
FOR i%=0 TO words%
BPUT#out%,word$(next%(i%))+","+STR$(no%(next%(i%)))
NEXT
CLOSE#out%
OSCLI("SetType "+out$+" Text")
ELSE
PRINT "There are ";words%+1;" words"
PRINT "Word";TAB(40);"# occurrences"
FOR i%=0 TO words%
PRINT word$(next%(i%));TAB(40)no%(next%(i%))
NEXT
ENDIF

END

DEFFNword
LOCAL word$
REPEAT
char%=BGET#in%
UNTIL letter%?char% OR EOF#in%
IF EOF#in% THEN =""
REPEAT
word$+=CHR$(char%)
char%=BGET#in%
UNTIL letter%?char%=0 OR EOF#in%
=word$

DEFFNexists(word$)
LOCAL h%,n%
h%=FNhash(word$)
n%=hash%(h%)
IF n%<0 THEN =NOT(maxwords%)
WHILE word$(n%)<>word$ AND next%(n%)>0:n%=next%(n%):ENDWHILE
IF word$(n%)=word$ THEN =n% ELSE =NOT(n%)

DEFPROCinsert(word$,point%)
words%+=1
IF words%=maxwords% THEN ERROR 0,"Too many different words in "+in$
word$(words%)=word$:no%(words%)=1
IF point%=NOT(maxwords%) THEN hash%(FNhash(word$))=words% ELSE next%(NOT(point%))=words%
ENDPROC

DEFFNhash(word$)
LOCAL i%,g%,h%
IF word$="" THEN =0
FOR i%=1 TO LEN(word$)
h%=(h%<<4)+ASC(MID$(word$,i%,1))
g%=h% AND &F0000000
IF g% THEN h%=(h% EOR (g%>>24)) EOR g%
NEXT
=(h% AND &7FFFFFFF) MOD chains%


DEFPROCpresort
LOCAL i%,j%,sld%
FOR i%=0 TO words%:next%(i%)=i%:NEXT
REM count occurances of each initial character...
sl%()=0
FOR j%=0 TO words%:k%=ASC(word$(next%(j%))):sl%(k%)+=1:NEXT
REM Convert counts to start addresses, in the sort area (snext% array)...
sld%=words%+1
FOR j%=255 TO 0 STEP -1
  sl%(j%)=sld%-sl%(j%)
  sld%=sl%(j%)
  NEXT
ENDPROC

DEFPROCnsort
LOCAL sstart%,send%,j%,k%,s%
REM split contents of next% array by first character into snext% array...
PRINT "Sorting..."
FOR j%=0 TO words%
  k%=ASC(word$(j%))
  snext%(sl%(k%))=next%(j%)
  sl%(k%)+=1
NEXT
REM replace back into next% array...
FOR j%=0 TO words%:next%(j%)=snext%(j%):NEXT
REM then bubble sort on each character in turn....
sstart%=0
FOR k%=0 TO 255
IF sl%(k%)<>sstart% THEN
    send%=sl%(k%)-1
    IF send%>sstart% THEN
      IF k%>31 AND k%<128 THEN PRINT CHR$(k%);
      REPEAT
       inorder%=TRUE
       FOR j%=sstart%+1 TO send%
        IF word$(next%(j%-1))>word$(next%(j%)) THEN SWAP next%(j%-1),next%(j%):inorder%=FALSE
       NEXT
     UNTIL inorder%=TRUE
    ENDIF
sstart%=send%
ENDIF
NEXT
PRINT " "
ENDPROC


DEFPROChelp
PRINT "Occurs 0.31 (25 Nov 1996)   R. R. Thomas"
PRINT "Counts the number of occurrences of each symbol in a file"
PRINT ""
PRINT "Usage: "+syntax$
PRINT "-counts gives output sorted by frequency; default is"
PRINT "alphabetic order of words"
PRINT "-result gives a file to write the results to"
PRINT "By default words consist of alphanumerics and underscores"
PRINT "-nonalpha treats all space-delimited sequences as words"
PRINT "-words treats only letter sequences as words, and converts"
PRINT "them all to lower case before processing"
END
ENDPROC

DEFPROCerror
ON ERROR OFF
IF debug% THEN PRINT REPORT$+" at line "+STR$(ERL):END
IF in% THEN CLOSE#in%
IF out% THEN CLOSE#out%
ERROR EXT 1,REPORT$
ENDPROC


REM BLib routines

DEFFNos_getstring(P%)
LOCAL S$:S$="":WHILE ?P%>31 S$+=CHR$(?P%):P%+=1:ENDWHILE
=S$

DEFFNisalnum(C$)
LOCAL C%:C%=ASC(C$):IF (C%>96 AND C%<123) OR (C%>64 AND C%<91) OR (C%>47 AND C%<58) THEN =TRUE
=FALSE

DEFFNisalpha(C$)
LOCAL C%:C%=ASC(C$):IF (C%>96 AND C%<123) OR (C%>64 AND C%<91) THEN =TRUE
=FALSE

DEFFNtolower(S$)
LOCAL R$,A%,C%,L%:L%=LEN(S$):R$="":IF L%=0 THEN =""
FORA%=1 TO L%:C%=ASC(MID$(S$,A%,1)):IF C%>64 AND C%<91 THEN C%+=32
R$+=CHR$(C%):NEXT:=R$
