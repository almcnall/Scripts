
;check out the new txt files from the spinups.

ifile=file_search('/jabber/LIS/OUTPUT/spinupcheck/WK*soil*.txt')
sm=read_ascii(ifile[2],delimiter=' ')
layers4=sm.field1[1,*] ;all four layers before splitting
sm1=fltarr((n_elements(layers4)/4)+1)
sm2=fltarr((n_elements(layers4)/4)+1)
sm3=fltarr((n_elements(layers4)/4)+1)
sm4=fltarr((n_elements(layers4)/4)+1)

count=0
j=0 & k=0 & l=0 &m=0
for i=0,n_elements(layers4[0,*]) do begin &$
  if count eq 0 then begin &$
    sm1[j]=layers4[i] & count++ & j++ & continue &$
  endif &$
  if count eq 1 then begin &$
    sm2[k]=layers4[i] & count++ & k++ & continue &$
  endif &$
  if count eq 2 then begin &$
    sm3[l]=layers4[i] & count++ & l++ & continue &$
  endif &$
  if count eq 3 then begin &$
    sm4[m]=layers4[i] & count = 0 & m++ & continue &$\
  endif &$
endfor 

;until today my coversions were all off by a factor of 10! 7/17 (was mixing my mm of water and cm of soil)
p1=plot(sm1/100)
p2=plot(sm2/300, /overplot, thick=3,color='b')
p3=plot(sm3/600, /overplot, thick=3,color='g')
p4=plot(sm4/1000, /overplot, color='r')
p1.title='LIS-Noah3.2 forced with 6hrly station data'
p1.title.font_size=18
xticks=['2005', '2006','2007','2008']
p1.xtickname=xticks

p1.name='avg SM 0-10cm'
p2.name='avg SM 10-40cm'
p3.name='avg SM 40-100cm'
p4.name='avg SM 100-200cm'
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) 
;************and the rainfall****************

ifile=file_search('/jabber/LIS/OUTPUT/spinupcheck/*rain.txt')
r=read_ascii(ifile[0],delimiter=' ')
rain=r.field1[1,*] ;all four layers before splitting
p2=plot(rain)
p2.title='rfe2_gdas in kg/m2/s'



;check it against the station data....
ifile=file_search('/jabber/Data/mcnally/AMMARain/wankamaEast_3hrly_2005_2008.dat')

idat=fltarr(3,11680)

openr,1,ifile
readu,1,idat
close,1

p1=plot(idat[2,*])
