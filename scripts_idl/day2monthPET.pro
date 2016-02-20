pro day2monthPET
; this script averages M. Marshall's RefPET calculations....
;
expdir = 'PET'

wdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/",/remove_all)
odir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/monthcubie/",/remove_all) 

print,wdir
cd,wdir 

nx= 1440. ;longitude
ny=  600. ;latitude

ofiles   =strarr(108)
monthcube=fltarr(nx,ny)
;list 'um instead of looping
;month   = ['01','02','03','04','05','06','07','08','09','10','11','12']
;year    = ['2001','2002','2003','2004','2005','2006','2007','2008','2009'] 

FOR yr = 2001, 2009 DO BEGIN 
   if yr MOD 4 ne 0 then days = [31,28,31, 30,31,30, 31,31,30, 31,30,31] $
   else days = [31,29,31, 30,31,30, 31,31,30, 31,30,31]
   print, days[1]
   
   infile = file_search(strcompress('DGLDAS'+string(yr)+'*.pet',/remove_all))
   buffer = fltarr(nx,ny)
 
 count = 0 ; initialize counter  
 for i = 0, n_elements(days)-1 do begin ;the month loop
   daycube=fltarr(nx,ny,days[i])
   for j = 0, days[i]-1 do begin
    print, 'open and read'+infile[count]
    openr,1,infile[count] ;opens one file at a time   
    readu,1,buffer                ;reads the file into the buffer
    close,1 
    daycube[*,*,j]=buffer
    print,'adding buffer daycube '+string(i)+''
    count++ ;count=count+1
   endfor;j

  for x=0,nx-1 do for y=0,ny-1 do begin ;convert units
    monthcube[x,y] = mean(daycube[x,y,*],/NAN); 
    ofile=strcompress(odir+'PET_'+STRING(yr)+STRING(FORMAT='(I2.2)',i+1)+'.img',/REMOVE_ALL) ;two digit day
  endfor ;end x and y
  openw,2,ofile
  writeu,2,monthcube
  close,2
 endfor; i  
 endfor;year
end; program