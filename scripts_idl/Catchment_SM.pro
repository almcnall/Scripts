pro Catchment_SM

;the purpose of this program is to look at the outputs from the catchment model.

indir = strcompress('/gibber/lis_data/OUTPUT/EXPC01/CLSM/daily/', /remove_all)
cd, indir

ifile = file_search('sm*2005*.img')

;just one yeat for starters so they all equal 365
;nsm1=n_elements(file_search('sm01*2005*.img')) & nsm2=n_elements(file_search('sm02*2005*.img'))
;nsm3=n_elements(file_search('sm03*2005*.img')) & nsm4=n_elements(file_search('sm04*2005*.img'))
nx = 300
ny = 320
nd = 365

;intialize arrays
ingrid = fltarr(nx,ny)
sm01 = fltarr(nx,ny,nd)
sm02 = fltarr(nx,ny,nd)
sm03 = fltarr(nx,ny,nd)
sm04 = fltarr(nx,ny,nd)

tsm01=fltarr(2,2,nd)
tsm02=fltarr(2,2,nd)
tsm03=fltarr(2,2,nd)
tsm04=fltarr(2,2,nd)

;intialize counters
cnt1=0 & cnt2=0 & cnt3=0 & cnt4=0 

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
   if strmid(ifile[i],0,4) eq 'sm01' then begin

     sm01[*,*,cnt1]=reverse(ingrid,2)
     cnt1++
   endif
   if strmid(ifile[i],0,4) eq 'sm02' then begin
     sm02[*,*,cnt2]=reverse(ingrid,2)
     cnt2++
   endif
   if strmid(ifile[i],0,4) eq 'sm03' then begin
     sm03[*,*,cnt3]=reverse(ingrid,2)
     cnt3++
   endif
   if strmid(ifile[i],0,4) eq 'sm04' then begin
     sm04[*,*,cnt4]=reverse(ingrid,2)
     cnt4++
   endif

endfor;i

tsm01 = sm01[xmin:xmax,ymin:ymax,*]
tsm02 = sm02[xmin:xmax,ymin:ymax,*]
tsm03 = sm03[xmin:xmax,ymin:ymax,*]
tsm04 = sm04[xmin:xmax,ymin:ymax,*]

print, 'wait here'

;**************plots*********************not sure the depths with catchment...
p1=plot(tsm01[0,0,*])
p1=plot(tsm01[1,1,*], /overplot, color='blue')
p2=plot(tsm02[0,0,*])
p2=plot(tsm02[1,1,*], /overplot,color='blue')
end