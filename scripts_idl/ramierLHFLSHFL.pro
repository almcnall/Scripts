pro ramierLHFLSHFL

;the purpose of this program is to extract the LHFL and SHFL from
;the noah runs to compare with Ramier et al. (2009) -make sure I don't have the bad 2006 pixel!
;since I could not find a 'read arc raster' function I remade all the .bil.hdrs to include map info
;then i stacked all the daily global RefST images in ENVI from 2005-2007. Then I extracted the time series for the 
;pixel at 2.5E, 13.5N...since envi has the time series reversed, I coppied the numbers into excel
;flopped the vector, saved it as a txt file and then re-imported it into this IDL script.

;petdir=strcompress('/jabber/Data/mcnally/', /remove_all)
indir = strcompress('/gibber/lis_data/OUTPUT/EXPA02/NOAH/daily/', /remove_all)
cd, indir
;
;ETfile = file_search(petdir+'erosRefET2005_2007.txt')
;buffer  = read_ascii(ETfile, count = count, missing_value = -999 )
;refET=buffer.field1

ifile = file_search('Qair_200{5,6,7,8}*.img')

;just one yeat for starters so they all equal 365
;nsm1=n_elements(file_search('sm01*2005*.img')) & nsm2=n_elements(file_search('sm02*2005*.img'))
;nsm3=n_elements(file_search('sm03*2005*.img')) & nsm4=n_elements(file_search('sm04*2005*.img'))
nx = 720.
ny = 350.
nd = 1461. ;'365*4+1 2008 leap yr

LHF = fltarr(nx,ny,nd)
SHF = fltarr(nx,ny,nd)
evap = fltarr(nx,ny,nd)
temp = fltarr(nx,ny,nd)
humd = fltarr(nx,ny,nd)
ingrid = fltarr(nx,ny)

;these should actually be listed as lat lons, not xys...
  lonmn = 2.55 &  lonmx = 2.85 & latmx = 13.65 &  latmn = 13.45
  xmax = (lonmx+19.95)*10
  xmin = (lonmn+19.95)*10
  
  ymax = (latmx+4.95)*10
  ymin = (latmn+4.95)*10


cnt1 = 0 & cnt2 = 0 & cnt3 = 0
for i=0,n_elements(ifile)-1 do begin
  openr,1,ifile[i]
  readu,1,ingrid
  close,1
   ;can I do the 5 day totals in here?
   if strmid(ifile[i],0,4) eq 'Qair' then begin
     humd[*,*,cnt1]=reverse(ingrid,2)
     cnt1++
   endif
;  if strmid(ifile[i],0,4) eq 'tair' then begin
;     temp[*,*,cnt1]=reverse(ingrid,2)
;     cnt1++
;   endif
;   if strmid(ifile[i],0,4) eq 'Qlhf' then begin
;     LHF[*,*,cnt1]=reverse(ingrid,2)
;     cnt1++
;   endif
;   if strmid(ifile[i],0,4) eq 'Qshf' then begin
;     SHF[*,*,cnt2]=reverse(ingrid,2)
;     cnt2++
;   endif
;    if strmid(ifile[i],0,4) eq 'evap' then begin
;     evap[*,*,cnt3]=reverse(ingrid,2)
;     cnt3++
;   endif
endfor ;i
print, 'hold here'

hh=humd[226,184,*] ;this is spp humidity how does this relate to relative humidity again
hh=reform(hh,1,1461)
print, hh*100




tt=temp[226,184,*]
tt=reform(tt,1,1461)-272.15

;timeseries for niger
;tLHF = LHF[xmin:xmax,ymin:ymax,*]
;tSHF = SHF[xmin:xmax,ymin:ymax,*]
;tevap = evap[xmin:xmax,ymin:ymax,*]
;p=2 ;4
;q=1 ;2
;;raimier likes to go from june2005-jun2007 - we can do that: Jun1=DOY 152
;
;p1=plot(tLHF[p,q,152:882]) ;june2005-jun2007 - we can do that: Jun1=DOY 152
;p1=plot(tSHF[p,q,152:882], /overplot, color='blue')
;p1=plot(refET[152:882]/100, /overplot, color='red')
;
;;print out to plot in excel*************
;LHX=reform(tLHF[p,q,152:882],731) ;june2005-jun2007 - we can do that: Jun1=DOY 152
;SHX=reform(tSHF[p,q,152:882],731)
;RET=reform(refET[152:882]/100,731)
;
;;and the smoothed versions:
;smLHX=ts_smooth(LHX,15)
;smSHX=ts_smooth(SHX,15)
;smRET=ts_smooth(RET,15)
;out=[reform(smLHX,1,731), reform(smSHX,1,731), reform(smRET,1,731)]
;***************************



end