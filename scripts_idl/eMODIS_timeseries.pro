pro eMODIS_timeseries
;
;the purpose of this program is to look at NDVI time series from 2005-2006 over my sites of interest in Niger.
;I'll be comparing 10 day NDVI with daily soil moisture..be aware of the spatial domian shift: 
;for 2001 to 2010.113 is different from 2010.123(?) to rest of data

;what is the best way to compare daily SM and 10day NDVI?
;If I want to compare NDVI and rainfall I could aggregate to 0.25 degrees.
;If I just want to compare NDVI and SM then 250m is ok.

indir='/jabber/sandbox/mcnally/west_africa_emodis/'
;outdir='/jabber/Data/mcnally/AMMAVeg/'

cd, indir

;min lat: 2   (or I had calculated 1.58306N but that might be wrong or center/eduge pixel issue)
;max lat: 21.0000N
;min lon: -19E
;max lon:?
;resolution: 2.4130000000e-03 degree = 250m
;where are my points of interest?
;fallow: 2.63370E, 13.6476N
;millet: 2.6299 13.644

;millet
my=(13.644-2)/0.002413 ;this checks out with ENVI, not sure about pixel corners.
mx=(2.6299+19)/0.002413

;fallow
fy=(13.647-2)/0.002413 ;this checks out with ENVI, not sure about pixel corners.
fx=(2.6337+19)/0.002413

;I should clip out for theo's whole box...3/29

ifile=file_search(indir+'WA*{2005,2006,2007,2008}*.img')

nx = 19271
ny =  7874
buffer=fltarr(nx,ny)
fpoi=fltarr(n_elements(ifile))
mpoi=fltarr(n_elements(ifile))
roi=fltarr(3,2,n_elements(ifile))

;read in a file, pull out ROI, chuck the file. then open a new one, rather than stacking then cliping. 
;i.e. get, clip, stack
;I think I want to make a little cube to explore in ENVI.
for i=0,n_elements(ifile)-1 do begin 
  openr,1,ifile[i]
  readu,1,buffer ;this will be full west africa.
  close,1
  
  fpoi[i]=buffer[fx,fy]
  mpoi[i]=buffer[mx,my]
  roi[*,*,i]=buffer[mx:fx,my:fy]
  
endfor

print, 'holdhere'

ofile='/jabber/Data/mcnally/AMMAVeg/NDVI_at_MF110.dat
openw,1,ofile
writeu,1,roi



;ok, NDVI10 day and rainfall...
;What is the max NDVI for the season? cumm. 10 day rainfall?


end 
  
  