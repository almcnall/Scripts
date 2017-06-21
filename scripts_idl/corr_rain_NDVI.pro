;********the standard NDVI cummulative rainfall correlation plot- repeat nicholson/others******
;map the 4 dek cummulative rainfall & ndvi, maybe check....
;read in UBRFE -- do I have this for RFE2 as well?
;read in the big cube of rainfall data so i can check out the correponding timeseries.
;ifile = file_search('/jabber/LIS/Data/ubRFE2/dekads/sahel/*.img')
;update 11/21/14 before submitting to RSE
ifile = file_search('/raid/chg-mcnally/ubRFE04.19.2013/dekads/sahel/*img')
;ifile = file_search('/jabber/LIS/Data/CPCOriginalRFE2/dekads/sahel/*.img')

nx = 720
ny = 350
nz = n_elements(ifile)

ingrid = fltarr(nx,ny)
ubcube = fltarr(nx,ny,nz)

for i = 0,n_elements(ifile)-1 do begin &$
  ;i = 0
  openr,1,ifile[i]  &$
  readu,1,ingrid &$
  close,1 &$
  
  ubcube[*,*,i] = ingrid &$
endfor

;add up the current + three previous dekads (nicholson says 3 previous months (9deks!)...how do i decide?)
;is this going to have current, 1, 2 and 3 month totals?
sumrain6 = fltarr(nx,ny,nz)
sumrain6[*,*,*] = !values.f_nan
;highest lag0 correlation at current+9 dekads of rainfall
;but this is showing current + 2 previous months?
for d = 6,nz-1 do begin &$
  sumrain6[*,*,d] = total(ubcube[*,*,d-6:d],3,/nan) &$
endfor

sumrain7 = fltarr(nx,ny,nz)
sumrain7[*,*,*] = !values.f_nan
;highest lag0 correlation at current+9 dekads of rainfall
;but this is showing current + 2 previous months?
for d = 7,nz-1 do begin &$
  sumrain7[*,*,d] = total(ubcube[*,*,d-7:d],3,/nan) &$
endfor

sumrain8 = fltarr(nx,ny,nz)
sumrain8[*,*,*] = !values.f_nan
;highest lag0 correlation at current+9 dekads of rainfall
;but this is showing current + 2 previous months?
for d = 8,nz-1 do begin &$
  sumrain8[*,*,d] = total(ubcube[*,*,d-8:d],3,/nan) &$
endfor

sumrain9 = fltarr(nx,ny,nz)
sumrain9[*,*,*] = !values.f_nan
;highest lag0 correlation at current+9 dekads of rainfall
;but this is showing current + 2 previous months?
for d = 9,nz-1 do begin &$
  sumrain9[*,*,d] = total(ubcube[*,*,d-9:d],3,/nan) &$
endfor

;read in the NDVI cube to investigate correlation with cummulative rainfall
nfile = file_search('/raid/MODIS/eMODIS/01degree/sahel/data*.img')
ingrid = fltarr(nx,ny)
ncube = fltarr(nx,ny,nz)
for n = 0,n_elements(nfile)-1 do begin &$
  openr,1,nfile[n] &$
  readu,1,ingrid &$
  close,1  &$
  ncube[*,*,n] = ingrid &$
  
endfor
cor6 = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    cor6[x,y] = correlate(sumrain6[x,y,6:431-6],ncube[x,y,6:431-6]) &$
  endfor &$
endfor

pos = cor6
pos(where(pos lt 0.2))=!values.f_nan
nve, pos

p1=image(pos, rgb_table=4, max_value=1)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], title = 'cor6',font_size=20)


;how does this work? correlate the 
cor7 = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    cor7[x,y] = correlate(sumrain7[x,y,7:431-7],ncube[x,y,7:431-7]) &$
  endfor &$
endfor

pos = cor7
pos(where(pos lt 0.2))=!values.f_nan

p1=image(pos, rgb_table=4, max_value=1)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], title = 'cor7',font_size=20)
             
cor8 = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    cor8[x,y] = correlate(sumrain8[x,y,8:431-8],ncube[x,y,8:431-8]) &$
  endfor &$
endfor

pos = cor8
pos(where(pos lt 0.2))=!values.f_nan

p1=image(pos, rgb_table=4, max_value=1)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], title = 'cor8',font_size=20)
             
cor9 = fltarr(nx,ny)
for x = 0,nx-1 do begin &$
  for y = 0,ny-1 do begin &$
    cor9[x,y] = correlate(sumrain9[x,y,9:431-9],ncube[x,y,9:431-9]) &$
  endfor &$
endfor

pos = cor9
pos(where(pos lt 0.2))=!values.f_nan

p1=image(pos, rgb_table=0, max_value=1)
c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07], title = 'cor9',font_size=20)

ofile = '/raid/chg-mcnally/NDVI_UBRFcorr_current_plus6deks.img'
openw,1,ofile
writeu,1,pos
close,1



  p1 = image(cor, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'correlation between NDVI and current + 7 dekads of UBRFE2 rainfall'
  p1.title.font_size = 14
;test = image(ingrid, rgb_table = 4)
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)
temp = plot(ncube[xind,yind,*])

  
lag=[0,1,2,3,4,5]
print, c_correlate(sumrain[xind,yind,9:387],ncube[xind,yind,9:387],lag);
print, c_correlate(ubcube[xind,yind,3:390],ncube[xind,yind,3:390],lag); 5 lag for rain and ndvi

;read in FCLIM data to make annual rainfall total mask (how would I plot contours?)
fx = 1501
fy = 1601
fz = 12
climgrid = LONARR(fx,fy,fz)

climfile = file_search('/jabber/LIS/Data/FCLIM_Afr/*.img')
openr,1, climfile
readu,1, climgrid
close,1

climgrid = float(climgrid[*,*,*])
null = where(climgrid lt 0, count) & print, count
climgrid(null) = !values.f_nan
totclim = reverse(total(climgrid,3, /nan),2)
temp = image(totclim, rgb_table=20)

;matches up correctly
totclimCoarse = congrid(totclim, 751,801)
xrt = (751-1)-3/0.1  ;RFE goes to 55, sahel goes to 52 plus an extra pixel
ybot = (35/0.1)+1    ;sahel starts at -5S
ytop = (801-1)-10/0.1  ; &$sahel stops at 30N
xlt = 1.              ;and I guess sahel starts at 19W, rather than 20....
sahel = totclimcoarse[xlt:xrt,ybot:ytop] 

out = where(sahel gt 1200. OR sahel lt 150., complement = in, count) & print, count
mask = intarr(nx,ny)
mask(in) = 1
mask(out) = 0

ofile = '/jabber/Data/mcnally/FCLIMshael_rainmask4NDVI.img'
;openw,1,ofile
;writeu,1,mask
;close,1


maskedcor = cor*mask
  p1 = image(maskedcor, image_dimensions=[72.0,35.0], image_location=[-20,-5], dimensions=[nx/100,ny/100], $
           rgb_table=20)
  c = COLORBAR(target=p1,ORIENTATION=0,/BORDER_ON, $
             POSITION=[0.3,0.04,0.7,0.07])
  p1 = MAP('Geographic',LIMIT = [-5, -20, 30, 52], /overplot)
  p1 = MAPCONTINENTS(/COUNTRIES,  COLOR = [120, 120, 120])
  p1.title = 'correlation between NDVI and current + 7 dekads of UBRFE2 rainfall (150-1200mm annual rainfall)'
  p1.title.font_size = 24



