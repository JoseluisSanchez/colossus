cd res
copy cls.rc+manifest.rc colossus.rc
c:\bcc55\bin\brc32 -ic:\bcc55\include;c:\fivetech\fwh1012\include -r colossus.rc
copy colossus.res ..
cd ..
