pro NDVI4soilsites108
;
;the purpose of this program is to look at NDVI time series from 2005-2006 (2008?) over my sites of interest from file 108 in Niger.
;I'll be comparing 10 day NDVI with 10day soil moisture.
;looking back at this on 7/5/12 lets see how i did back in april
;I should use the same 750m box that i did for the wankama1 & 2 sites, for the millet110 and fallow110 sites 2005-2006

;min lat: 2   (or I had calculated 1.58306N but that might be wrong or center/eduge pixel issue)
;max lat: 21.0000N
;min lon: -19E
;max lon:?
;resolution: 2.4130000000e-03 degree = 250m

indir = strcompress('/jabber/sandbox/mcnally/west_africa_emodis/', /remove_all)
ifile = file_search(indir+'WA*{2005,2006,2007,2008}*.img')

nx = 19271
ny =  7874
buffer = fltarr(nx,ny)

;temp=image(buffer)

;if I had a list of the lat lons then I could automate this... but well start off with one. 
;[Wankama1, Wankama2] (wankama2 pretty close to millet...13.644;2.6299)
;lat = [13.6456,13.6448] ;y
;lon = [2.632,2.630]

;how do I test different regions around the point of interest....I should do this for Kat's points too. 
;see points2ROI.pro, add lat lons for WK1,W2,TK108,F110 and M110
;lat = [13.6456, 13.6448, 13.5483, 13.6476, 13.644] 
;lon = [  2.632,    2.63,  2.6966,  2.6337,  2.6299] 
;check out the benin sites
lat = [9.74530, 9.79506 ] ;y
lon = [1.6053,  1.7145];x

;Nalohou       9.74530     1.60530 
;Belefoungou   9.79506     1.71450  
 
;change latlons to x,y
y=(lat-2)/0.002413 ;this checks out with ENVI, not sure about pixel corners.
x=(lon+19)/0.002413

;see how the sites plot up on the ndvi image
temp=plot(x[0:1],y[0:1],sym_size=3,'m+', /overplot)

        
;********ok, now make a box around this point....01,2 extra pixels*******
;make a vector of the different number of pixels that I want to increase the size by.

;open an ndvi file,get the value for the point (take the average, silly for 1 point) close the file open the next one. 
grow = [0,1]
avgNDVI = fltarr(n_elements(y),n_elements(ifile),n_elements(grow))

for g=0, n_elements(grow)-1 do begin
  top    = y+grow[g]
  bottom = y-grow[g]
  left   = x-grow[g]
  right  = x+grow[g]
  for h=0,n_elements(ifile)-1 do begin  
    ;open up the ndvi file....
    openr,1,ifile[h]
    readu,1,buffer
    close,1
  
   for j=0,n_elements(y)-1 do begin ;&$
     ROI=buffer[left[j]:right[j],bottom[j]:top[j]]  ;&$
    ;take the average of the array
     temp=mean(roi,dimension=1)   ;&$
     avg=mean(temp,dimension=1)  ;&$
  ;save it
     if g eq 0 then avgNDVI[j,h,g]=temp else $
     avgNDVI[j,h,g]=avg  ;&$
    endfor;j - sites
  endfor;n - each dekad in timeseries
endfor;g - averaging over different sizes
print, 'hold here'

ofile=('/jabber/chg-mcnally/AMMAVeg/avergeNDVI_NT_B.csv')
;re-write them all out together. 
;ofile=('/jabber/Data/mcnally/AMMAVeg/avergeNDVI_WK12MF_TK.dat')

;close, 1
;openw,1,ofile
;writeu,1,avgNDVI
;close, 1

;check out the data:
ifile = file_search('/jabber/chg-mcnally/AMMAVeg/avergeNDVI_NT_B.csv')
ingrid = fltarr(2,144,2)

openr,1,ifile
readu,1,ingrid
close,1

p1 = plot(ingrid[0,*,0], name = 'Nal250', 'g')
p2 = plot(ingrid[0,*,1], name = 'Nal500', 'b', /overplot)
p3 = plot(ingrid[1,*,0], name = 'Bel250', 'r', /overplot)
p4 = plot(ingrid[1,*,1], name = 'Bel500', 'orange', /overplot)
p4.title = 'NDVI at 250 and 500m Benin sites: Nal fallow, Bel Forest'
p1.xtickfont_size = 14
p1.ytickfont_size = 14
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=14) ;
end 
  
  