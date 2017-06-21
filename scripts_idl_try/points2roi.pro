pro points2roi

;the purpose of this file to to extract data from a 10km area around kat's
;DHS lat/lon points 
;map info = 21.00000000, 15.00100000, 2.4130000000e-03, 2.4130000000e-03, WGS-84, units=Degrees
;10/22/2013 try this again with new stuff that kat wants.

;read in the kenya data
kfile = file_search('/home/sandbox/people/mcnally/ForKatNDVI/easub.24*')
nx = 12847
ny = 8290
nbands = 11

buffer = bytarr(nx,ny)
easub = bytarr(nx,ny,nbands)
for i = 0,n_elements(kfile)-1 do begin &$
  openr,1,kfile[i] &$
  readu,1,buffer &$
  close,1 &$
  easub[*,*,i] = buffer &$
endfor

;make sure things look ok
reasub = reverse(easub,2)
temp = image(reasub[*,*,0])

;these must be the DHC lon/lats
;fname = ('/raid/chg-mcnally/ForKatNDVI/amy2008')
fname = ('/home/sandbox/people/mcnally/ForKatNDVI/amy2003')

  valid = query_ascii(fname,info) ;checks compatability with read_ascii
  print, valid
  myTemplate = ASCII_TEMPLATE(fname); go to line 41
  latlons = read_ascii(fname, delimiter=',' ,template=myTemplate);

ID = transpose(latlons.field1)
lon = transpose(latlons.field2)
lat = transpose(latlons.field3)

;;********change lon-lat to xy*********************
; x=intarr(elements(unqlon))
;  21.00000000, 15.00100000
 x = reform((lon-21.0886)/0.0024); becasue it is -29.95W and (2.5*20 = 50pixels) that is .05 off of 20 which should be the center of the pixel.
  ;y = reform((lat+5)/0.0024) ;becasue it is -5S
  ;y = reform((lat+5.0192)/0.0024) ;becasue it is -5S
 y = reform((lat+4.9808)/0.0024) ;becasue it is -5S (more south, not exact...)

temp = plot(x[0:1],y[0:1],sym_size = 3,'m+', /overplot)
;temp=plot(x[2:236],y[2:236], /overplot, 'm+') ;25 is the bad row in 2008
;temp=plot(x[26:238],y[26:238], /overplot, 'm+')

;print ndvi at each x,y...this does it for 1 pixel...
I = 1
P1 = PLOT(REASUB[X[I],Y[I],*],XTICKV=[1,3,5,7,9],XTICKNAME = ['2002','2004','2006','2008','2010'],$
        TITLE='DHS ID'+STRING(I), YTITLE = 'NDVI*100')
        
;********ok, now make a 10km box around this point....20 pixels in 5k*******
top = y+20
bottom = y-20
left = x-20
right = x+20

avgNDVI = fltarr(n_elements(reasub[0,0,*]),n_elements(y))

for i = 0,n_elements(y)-1 do begin &$
  ;the ndvi values at the 'exact' locations
  ;print, reasub[x[i],y[i],*]  ;&$
  ;make the array....a 41x41x11 array -- buffer * 11 yrs
  ROI = float(reasub[left[i]:right[i],bottom[i]:top[i],*])  &$
  zero = where(ROI eq 0, complement = good, count)&$
  ROI(zero) = !values.f_nan &$
  if count gt 0 then print, count &$
  ;take the average of the array
  temp = mean(roi,dimension = 1, /NAN)   &$
  avg = mean(temp,dimension = 1, /NAN)  &$
  ;save it
  avgNDVI[*,i] = avg  &$
endfor

;block out the points of interest on the map..
buffer = reasub
;for i = 0,n_elements(y)-1 do begin &$
;  buffer[left[i]:right[i],bottom[i]:top[i],0] = 88888 &$
;  p1 = image(buffer[*,*,0], /overplot) &$
;endfor
;p1.title = 'east africa DHS points w/ 10km buffer'
;
ofile = strcompress('/jabber/sandbox/mcnally/ForKatNDVI/NDVIatPnts2003v2.dat')
;ofile = strcompress('/jabber/sandbox/mcnally/ForKatNDVI/NDVIatPnts2008.csv')

;avg NDVI is 11 yrsx398 DHS sites?
;14x398 array, ID, lon, lat, [2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011]
oarray=[ID,lon,lat,avgNDVI[*,*]]
CLOSE, /ALL

;write_csv,ofile,oarray


openw,1,ofile
writeu,1,oarray
CLOSE,1

;*************************************
 shp43 = OBJ_new('IDLffShape','/raid/chg-mcnally/ForKatNDVI/shp_10.22.2013/KEGE43FL.shp')
 shp43->GetProperty, N_entities=num_ent,Entity_TYPE=ent_type,Attribute_info=atts
 vals43 = shp43->getAttributes( /ALL) ;can I cat the years here?
 
END