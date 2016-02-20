pro Noah_catch_AET_RO

;the purpose of this program is to look at the outputs (AET,RO,P) from the catchment model.

indir = strcompress('/gibber/lis_data/OUTPUT/EXPN01/NOAH/daily/', /remove_all)
cd, indir

ifile = file_search('{TVeg,ESol,rain,evap,Qsub,Qsuf}*2005*.img')

;just one yeat for starters so they all equal 365
;nsm1=n_elements(file_search('sm01*2005*.img')) & nsm2=n_elements(file_search('sm02*2005*.img'))
;nsm3=n_elements(file_search('sm03*2005*.img')) & nsm4=n_elements(file_search('sm04*2005*.img'))
nx = 300
ny = 320
nd = 365

;intialize arrays
ingrid = fltarr(nx,ny)
evap = fltarr(nx,ny,nd)
Qsub = fltarr(nx,ny,nd)
Qsuf = fltarr(nx,ny,nd)
rain = fltarr(nx,ny,nd)
TVeg = fltarr(nx,ny,nd)
ESol = fltarr(nx,ny,nd)

tevap=fltarr(2,2,nd)
tQsub=fltarr(2,2,nd)
tQsuf=fltarr(2,2,nd)
train=fltarr(2,2,nd)
tTVeg=fltarr(2,2,nd)
tESol=fltarr(2,2,nd)


;intialize counters
cnt1=0 & cnt2=0 & cnt3=0 & cnt4=0 & cnt5=0 & cnt6=0

;these should actually be listed as lat lons, not xys...
  lonmn = 2.55 &  lonmx = 2.85 & latmx = 13.65 &  latmn = 13.45
  xmax = (lonmx+20)*4
  xmin = (lonmn+20)*4
  
  ymax=(latmx+40)*4
  ymin=(latmn+40)*4


for i = 0,n_elements(ifile)-1 do begin

   openr,1,ifile[i]
   readu,1,ingrid
   close,1
   ;can I do the 5 day totals in here?
   if strmid(ifile[i],0,4) eq 'evap' then begin
     evap[*,*,cnt1]=reverse(ingrid,2)
     cnt1++
   endif
   if strmid(ifile[i],0,4) eq 'Qsub' then begin
     Qsub[*,*,cnt2]=reverse(ingrid,2)
     cnt2++
   endif
   if strmid(ifile[i],0,4) eq 'Qsuf' then begin
     Qsuf[*,*,cnt3]=reverse(ingrid,2)
     cnt3++
   endif
   if strmid(ifile[i],0,4) eq 'rain' then begin
     rain[*,*,cnt4]=reverse(ingrid,2)
     cnt4++
   endif
   if strmid(ifile[i],0,4) eq 'TVeg' then begin;fix these when rest is fixed.
     TVeg[*,*,cnt5]=reverse(ingrid,2)
     cnt5++
   endif
   if strmid(ifile[i],0,4) eq 'ESol' then begin;fix these when rest is fixed.
     ESol[*,*,cnt6]=reverse(ingrid,2)
     cnt6++
   endif

endfor;i

;timeseries for niger
tevap = evap[xmin:xmax,ymin:ymax,*]
tQsub = Qsub[xmin:xmax,ymin:ymax,*]
tQsuf = Qsuf[xmin:xmax,ymin:ymax,*]
train = rain[xmin:xmax,ymin:ymax,*]
tTVeg = TVeg[xmin:xmax,ymin:ymax,*]
tESol = ESol[xmin:xmax,ymin:ymax,*]

p=1
;water balance, looks pretty good. Does catchment use a greenveg fraction?
totevap=total(tevap[p,p,*]*84600)
totrain=total(train[p,p,*]*84600)
totro=total(tqsuf[p,p,*]*84600)+total(tqsub[p,p,*]*86400)
totsuf=total(tqsuf[p,p,*]*84600)
totsub=total(tqsub[p,p,*]*86400)

totTveg=total(tTVeg[p,p,*]*86400)
totEsol=total(tESol[p,p,*]*86400)

print, [totevap,totrain,(totevap/totrain)*100,totro,(totro/totrain)*100]
print, [totTveg,(totTveg/totevap)*100,totESol,(totESol/totevap*100)]
print, [totsuf,(totsuf/totro)*100, totsub,(totsub/totro)*100]

print, 'wait here'
;p1=plot((tevap[0,0,*])-(tevap[1,1,*]))
;p1=plot((tQsuf[0,0,*])-(tQsuf[1,1,*]), title='2 site diff Qsuf')
;p1=plot((train[0,0,*])-(train[1,1,*]), title='2 site diff Rain')
;
;p1=plot(tevap[0,0,*]*84600)
;p1=plot(tevap[1,1,*]*84600,/overplot, color='blue')
;p1=plot(train[0,0,*]*84600, color='blue', /overplot)
;p1=plot(tQsub[0,0,*]*84600, color='red', /overplot)
;p1=plot(tQsuf[0,0,*]*84600, color='red', /overplot)

;make 5 day totals of both rainfall and AET: could do this in upper loop but gets confusing...
;this should also be fast by just looking at the pixels of interest. Do I keep them
;separate or do I average them?
end