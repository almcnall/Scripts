pro Noah_nigerdrought

;the purpose of this program is to look at the outputs (AET,RO,P) from the catchment model.

indir = strcompress('/gibber/lis_data/OUTPUT/EXPA03/NOAH/daily/', /remove_all)
cd, indir

ifile = file_search('{Qlhf,Qshf,evap,rain,TVeg,ESol}*200*.img')

;just one yeat for starters so they all equal 365
;nsm1=n_elements(file_search('sm01*2005*.img')) & nsm2=n_elements(file_search('sm02*2005*.img'))
;nsm3=n_elements(file_search('sm03*2005*.img')) & nsm4=n_elements(file_search('sm04*2005*.img'))
nx = 17.
ny = 12.
nd = 2922. ;uh~ 2008 has 366 days

;intialize arrays
ingrid = fltarr(nx,ny)
evap = fltarr(nx,ny,nd)
rain = fltarr(nx,ny,nd)
TVeg = fltarr(nx,ny,nd)
ESol = fltarr(nx,ny,nd)
Qlhf = fltarr(nx,ny,nd);2007 nd=365
Qshf = fltarr(nx,ny,nd);2007 nd=365
;Ghfl = fltarr(nx,ny,nd);2007 nd=307
;SWnt = fltarr(nx,ny,nd);2007 nd=307
;LWnt = fltarr(nx,ny,nd);2007 nd=307

;intialize counters
cnt1=0 & cnt2=0 & cnt3=0 & cnt4=0 & cnt5=0 & cnt6=0

for i = 0,n_elements(ifile)-1 do begin 

   openr,1,ifile[i]
   readu,1,ingrid
   close,1
   ;can I do the 5 day totals in here?
   if strmid(ifile[i],0,4) eq 'Qlhf' then begin
     Qlhf[*,*,cnt1]=reverse(ingrid,2)
     cnt1++
   endif
   if strmid(ifile[i],0,4) eq 'Qshf' then begin
     Qshf[*,*,cnt2]=reverse(ingrid,2)
     cnt2++
   endif
   if strmid(ifile[i],0,4) eq 'evap' then begin
     evap[*,*,cnt3]=reverse(ingrid,2)
     cnt3++
   endif
   if strmid(ifile[i],0,4) eq 'rain' then begin
     rain[*,*,cnt4]=reverse(ingrid,2)
     cnt4++
   endif
   if strmid(ifile[i],0,4) eq 'ESol' then begin;fix these when rest is fixed.
     ESol[*,*,cnt5]=reverse(ingrid,2)
     cnt5++
   endif
   if strmid(ifile[i],0,4) eq 'TVeg' then begin;fix these when rest is fixed.
     TVeg[*,*,cnt6]=reverse(ingrid,2)
     cnt6++
   endif

endfor;i
;which pixels are 13.5 and 2.6 now?

 
 print, 'hold here'
 
; r02=total(rain[5,5,0:364],3)*86400
; r03=total(rain[5,5,365:729],3)*86400
; r04=total(rain[5,5,730:1095],3)*86400
; r05=total(rain[5,5,1096:1460],3)*86400
; r06=total(rain[5,5,1461:1825],3)*86400
; r07=total(rain[5,5,1826:2190],3)*86400
; r08=total(rain[5,5,2191:2556],3)*86400
; r09=total(rain[5,5,2557:2921],3)*86400
 
 rs02=(rain[5,5,0:364])*86400
   rr02=total(rs02(151:243)) & print,rr02
 rs03=(rain[5,5,365:729])*86400
    rr03=total(rs03(151:243)) & print,rr03
 rs04=(rain[5,5,730:1094])*86400 ;took out a day so that I could concatinate them
    rr04=total(rs04(151:243)) & print,rr04
 rs05=(rain[5,5,1096:1460])*86400
    rr05=total(rs05(151:243))& print,rr05
 rs06=(rain[5,5,1461:1825])*86400
    rr06=total(rs06(151:243)) &  print,rr06
 rs07=(rain[5,5,1826:2190])*86400
    rr07=total(rs07(151:243)) & print,rr07
 rs08=(rain[5,5,2191:2555])*86400 ;took out the leap day for convience
    rr08=total(rs08(151:243)) & print,rr08
 rs09=(rain[5,5,2557:2921])*86400
    rr09=total(rs09(151:243))& print,rr09
    
rainbar=[rr02,rr03,rr04,rr05,rr06,rr07,rr08,rr09]   
 
;parse out into year
 e02=evap[5,5,0:364]*86400
 e03=evap[5,5,365:729]*86400
 e04=evap[5,5,730:1094]*86400 ;removed day from leap yr
 e05=evap[5,5,1096:1460]*86400
 e06=evap[5,5,1461:1825]*86400
 e07=evap[5,5,1826:2190]*86400
 e08=evap[5,5,2191:2555]*86400;removed day from leap yr
 e09=evap[5,5,2557:2921]*86400
 
 ;get the growing season total jun-sept
 er02=total(e02(*,*,151:243)) & print,er02
 er03=total(e03(*,*,151:243)) & print,er03
 er04=total(e04(*,*,151:243)) & print,er04
 er05=total(e05(*,*,151:243))& print,er05
 er06=total(e06(*,*,151:243)) &  print,er06
 er07=total(e07(*,*,151:243)) & print,er07
 er08=total(e08(*,*,151:243)) & print,er08
 er09=total(e09(*,*,151:243))& print,er09
 
evapbar=[er02,er03,er04,er05,er06,er07,er08,er09]
EtoPratio=evapbar/rainbar

p1=plot(evapbar,/overplot)
LWnet = reform(LWnt[226,184,*],1,nd)
SWnet = reform(SWnt[226,184,*],1,nd)
Grnd = reform(Ghfl[226,184,*],1,nd)
Shfl = reform(Qshf[226,184,*],1,nd)
Lhfl = reform(Qlhf[226,184,*],1,nd)
Rnet = LWnet+SWnet
LSG = Grnd+Shfl+Lhfl

print, [LWnet,SWnet,Grnd,Shfl,Lhfl,Rnet,LSG]


;extract data for pixels of interest:
aet=evap[226,184,*] ;this is spp humidity how does this relate to relative humidity again
aet=reform(aet,1,365)
print,aet*86400

;timeseries for niger
;tevap = evap[xmin:xmax,ymin:ymax,*]
;tQsub = Qsub[xmin:xmax,ymin:ymax,*]
;tQsuf = Qsuf[xmin:xmax,ymin:ymax,*]
;train = rain[xmin:xmax,ymin:ymax,*]
;tTVeg = TVeg[xmin:xmax,ymin:ymax,*]
;tESol = ESol[xmin:xmax,ymin:ymax,*]


;********************************************************************
;totevap = total(tevap[p,q,*]*84600)
;totrain = total(train[p,q,*]*84600)
;totro = total(tqsuf[p,q,*]*84600)+total(tqsub[p,q,*]*86400)
;totsuf = total(tqsuf[p,q,*]*84600)
;totsub = total(tqsub[p,q,*]*86400)
;
;totTveg=total(tTVeg[p,q,*]) ;uh, what is going on here?!
;totEsol=total(tESol[p,q,*]*86400)


print, 'wait here'


end