pro make_monthcube_princeton

;this script reshapes the files that Kristi Arsenault sent on 3/29/12 from data by year
;data to monthcubes. 
;big_endian 1jan1948
;xdef 360 linear 0.500000 1.000000
;ydef 180 linear -89.500000 1
;tdef 636 linear 1jan1948 1mo

ifile=file_search('/home/LIS/z-jabber/Data/PRINCETON/*.bin')
nx=360
ny=180
nz=12
ingrid=fltarr(nx,ny,nz)

;make sure all files are the same size...
 jan =fltarr(nx,ny,n_elements(ifile))
 feb =fltarr(nx,ny,n_elements(ifile)) 
 mar =fltarr(nx,ny,n_elements(ifile)) 
 apr =fltarr(nx,ny,n_elements(ifile))
 may =fltarr(nx,ny,n_elements(ifile)) 
 jun =fltarr(nx,ny,n_elements(ifile)) 
 jul =fltarr(nx,ny,n_elements(ifile)) 
 aug =fltarr(nx,ny,n_elements(ifile)) 
 sep =fltarr(nx,ny,n_elements(ifile)) 
 oct =fltarr(nx,ny,n_elements(ifile)) 
 nov =fltarr(nx,ny,n_elements(ifile)) 
 dec =fltarr(nx,ny,n_elements(ifile)) 


for i=0,n_elements(ifile)-1 do begin

  openr,1,ifile[i]
  readu,1,ingrid
  close,1
  byteorder,ingrid,/XDRTOF    
  small=where(ingrid lt 0, complement=good, count)
  huge=where(ingrid gt 2000, complement=norm, count)  
  ingrid(huge)=1000
  ingrid(small)=!values.f_nan
    ;then need to mutliply by number of days per month (sorry pete!)
    jan[*,*,i]=ingrid[*,*,0]*86400
    feb[*,*,i]=ingrid[*,*,1]*86400
    mar[*,*,i]=ingrid[*,*,2]*86400
    apr[*,*,i]=ingrid[*,*,3]*86400
    may[*,*,i]=ingrid[*,*,4]*86400
    jun[*,*,i]=ingrid[*,*,5]*86400
    jul[*,*,i]=ingrid[*,*,6]*86400
    aug[*,*,i]=ingrid[*,*,7]*86400
    sep[*,*,i]=ingrid[*,*,8]*86400
    oct[*,*,i]=ingrid[*,*,9]*86400
    nov[*,*,i]=ingrid[*,*,10]*86400
    dec[*,*,i]=ingrid[*,*,11]*86400
print, ifile[i]   
endfor;i

;test plot
;stack=total(jan,3)   
;p1=image(stack)

ofile1=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_01.img')
ofile2=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_02.img')
ofile3=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_03.img')
ofile4=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_04.img')
ofile5=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_05.img')
ofile6=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_06.img')
ofile7=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_07.img')
ofile8=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_08.img')
ofile9=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_09.img')
ofile10=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_10.img')
ofile11=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_11.img')
ofile12=strcompress('/home/LIS/z-jabber/Data/PRINCETON/moncubie/princeton_12.img')

openw,1,ofile1
openw,2,ofile2
openw,3,ofile3
openw,4,ofile4
openw,5,ofile5
openw,6,ofile6
openw,7,ofile7
openw,8,ofile8
openw,9,ofile9
openw,10,ofile10
openw,11,ofile11
openw,12,ofile12

writeu,1,jan
writeu,2,feb
writeu,3,mar
writeu,4,apr
writeu,5,may
writeu,6,jun
writeu,7,jul
writeu,8,aug
writeu,9,sep
writeu,10,oct
writeu,11,nov
writeu,12,dec

close, /all

print, 'done!'

end

