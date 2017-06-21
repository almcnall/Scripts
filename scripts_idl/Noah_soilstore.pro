pro Noah_soilstore

;the purpose of this program is to look at the outputs (AET,RO,P) from the catchment model.

indir = strcompress('/gibber/lis_data/OUTPUT/EXPA02/NOAH/daily/', /remove_all)
cd, indir

ifile = file_search('sm0{1,2,3,4}_200{6,7}*.img')

nx = 720.
ny = 350.
nd = 730. 

;intialize arrays
ingrid = fltarr(nx,ny)
sm01 = fltarr(nx,ny,nd)
sm02 = fltarr(nx,ny,nd)
sm03 = fltarr(nx,ny,nd)
sm04 = fltarr(nx,ny,nd)


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

;extract data for pixels of interest:
tssm01=sm01[226,184,*] ;this is spp humidity how does this relate to relative humidity again
tssm02=sm02[226,184,*] 
tssm03=sm03[226,184,*] 
tssm04=sm04[226,184,*] 


tssm01=reform(tssm01,1,730)
tssm02=reform(tssm02,1,730)
tssm03=reform(tssm03,1,730)
tssm04=reform(tssm04,1,730)

print, [tssm01, tssm02, tssm03, tssm04]

print,aet*86400


end