;Delete folders recursively
FOR /D /R %%X IN (__history) DO RD /S /Q "%%X"
FOR /D /R %%X IN (backup) DO RD /S /Q "%%X"

rmdir /S /Q logs dcu dcu.android dcu.win32

erase /F /Q /S *.~* *.ddp *.drc *.dcp *.dcu
erase /F /Q /S *.o *.or *.ppu *.compiled *.local
erase /F /Q /S *.tmp *.log thumbs.db *.map descript.ion *.skincfg *.identcache *.tvsconfig *.mi *.LOG.txt *.stat bugreport.txt

erase /F /Q /S /A:H *.~* *.ddp *.drc *.dcp *.dcu
erase /F /Q /S /A:H *.o *.or *.ppu *.compiled *.local
erase /F /Q /S /A:H *.tmp *.log thumbs.db *.map descript.ion *.skincfg *.identcache *.tvsconfig *.mi *.LOG.txt *.stat bugreport.txt