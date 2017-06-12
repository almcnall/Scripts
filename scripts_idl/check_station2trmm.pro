
ifile=file_search('/jabber/Data/mcnally/AMMARain/WankamaEast_grid/200508/*')

ingrid=fltarr(1440,400)
stack=fltarr(1440,400)
for i=0, n_elements(ifile)-1 do begin  &$
  close, 1 &$
  openr,1,ifile[i] &$
  readu,1,ingrid &$
  close,1 &$
  byteorder,ingrid,/XDRTOF &$
  stack=ingrid+stack &$
endfor

afr= stack(640:940,40:360) ;Africa:  20W - 55E,  40S - 40N  75 x  80   degrees


sdir = strcompress('/jabber/Data/mcnally/AMMARain/', /remove_all)
sfile = file_search(sdir+'wankamaEast_3hrly_2005_2008.dat')
ncol = 3 ;year, doy, rain(mm)
nrow = 11680
WEast=fltarr(ncol,nrow)

close,1
openr,1,sfile
readu,1,wEast
close,1

;***********************************************************************
ifile=file_search('/home/mcnally/EROS_test/station*img')
ingrid=fltarr(1440,400,30)
stack=fltarr(1440,400)

close,1
openr,1,ifile[3]
readu,1,ingrid
byteorder,ingrid,/XDRTOF
close,1

rain=total(ingrid,3)
temp=mean(ingrid,dimension=1)
rain=mean(temp,dimension=1)
mve, rain[640:940,40:360]
