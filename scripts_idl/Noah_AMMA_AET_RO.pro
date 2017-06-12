pro Noah_AMMA_AET_RO

;the purpose of this program is to look at the outputs (AET,RO,P) from the catchment model.

indir = strcompress('/gibber/lis_data/OUTPUT/EXPA02/NOAH/daily/', /remove_all)
cd, indir

ifile = file_search('{Qlhf,Qshf,Ghfl,SWnt,LWnt}*200{5,6,7}*.img')

;just one yeat for starters so they all equal 365
;nsm1=n_elements(file_search('sm01*2005*.img')) & nsm2=n_elements(file_search('sm02*2005*.img'))
;nsm3=n_elements(file_search('sm03*2005*.img')) & nsm4=n_elements(file_search('sm04*2005*.img'))
nx = 720.
ny = 350.
nd = 1095. ;uh~ 2008 has 366 days

;intialize arrays
;ingrid = fltarr(nx,ny)
;evap = fltarr(nx,ny,nd)
;Qsub = fltarr(nx,ny,nd)
;Qsuf = fltarr(nx,ny,nd)
;rain = fltarr(nx,ny,nd)
;TVeg = fltarr(nx,ny,nd)
;ESol = fltarr(nx,ny,nd)

ingrid = fltarr(nx,ny)
Qlhf = fltarr(nx,ny,nd);2007 nd=365
Qshf = fltarr(nx,ny,nd);2007 nd=365
Ghfl = fltarr(nx,ny,nd);2007 nd=307
SWnt = fltarr(nx,ny,nd);2007 nd=307
LWnt = fltarr(nx,ny,nd);2007 nd=307

;tevap=fltarr(3,3,nd)
;tQsub=fltarr(3,3,nd)
;tQsuf=fltarr(3,3,nd)
;train=fltarr(3,3,nd)
;tTVeg=fltarr(3,3,nd)
;tESol=fltarr(3,3,nd)


;intialize counters
cnt1=0 & cnt2=0 & cnt3=0 & cnt4=0 & cnt5=0 & cnt6=0

;these should actually be listed as lat lons, not xys...am I reversing these correctly?
;  lonmn = 2.55 &  lonmx = 2.85 & latmx = 13.65 &  latmn = 13.45
;  xmax = (lonmx+19.95)*10
;  xmin = (lonmn+19.95)*10
;  
;  ymax=(latmx+4.95)*10
;  ymin=(latmn+4.95)*10

;or for the values at 2.5 and 13.5 
  xmid = 226
  ymid = 184
 


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
   if strmid(ifile[i],0,4) eq 'Ghfl' then begin
     Ghfl[*,*,cnt3]=reverse(ingrid,2)
     cnt3++
   endif
   if strmid(ifile[i],0,4) eq 'SWnt' then begin
     SWnt[*,*,cnt4]=reverse(ingrid,2)
     cnt4++
   endif
   if strmid(ifile[i],0,4) eq 'LWnt' then begin;fix these when rest is fixed.
     LWnt[*,*,cnt5]=reverse(ingrid,2)
     cnt5++
   endif
;   if strmid(ifile[i],0,4) eq 'ESol' then begin;fix these when rest is fixed.
;     ESol[*,*,cnt6]=reverse(ingrid,2)
;     cnt6++
;   endif

endfor;i

 xmid = 226
 ymid = 184
 
 print, 'hold here'

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