pro day2month_Noah

ifile1 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm01*.img')
ifile2 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm02*.img')
ifile3 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm03*.img')
ifile4 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Sm04*.img')
ifile5 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Evap*.img')
ifile6 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Rain_*.img')
ifile7 = file_search('/jower/sandbox/mcnally/fromKnot/EXP02/daily/ESol_*.img')
ifile8 = file_search('/jower/sandbox/mcnally/fromKnot/EXP01/daily/Qsuf_*.img')


nx = 720
ny = 250

mo = ['01','02','03','04','05','06','07','08','09','10','11','12']
yr =['2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
meangrid = fltarr([nx,ny,132])
ingrid = fltarr(nx,ny)
cnt = 0 

ifile = ifile8

for y = 0,n_elements(yr)-1 do begin
  for m = 0,n_elements(mo)-1 do begin
    year = strmid(ifile,49,4)
    month = strmid(ifile,53,2)
    index = where(year eq yr[y] AND month eq mo[m], count)
    buffer = fltarr(nx,ny,n_elements(index))
    for i=0,n_elements(index)-1 do begin
      openr,1,ifile[index[i]]  
      readu,1,ingrid
      close,1
      buffer = ingrid+buffer
      if i eq n_elements(index)-1 then begin
        ;avg = buffer/i+1
        avg = buffer ;I want rainfall totals not averages (I prolly want evap totals too...
        meangrid[*,*,cnt] = avg
      endif
    endfor
 ofile = '/jower/sandbox/mcnally/fromKnot/EXP01/monthly/Qsuf_'+yr[y]+mo[m]+'.img' & print, ofile
 openw,1,ofile
 writeu,1,avg
 close,1
   cnt++
   endfor
endfor
print, 'hold'
end  
;;
;wxind = FLOOR((2.632 + 20.) / 0.10)
;wyind = FLOOR((13.6456 + 5) / 0.10)  