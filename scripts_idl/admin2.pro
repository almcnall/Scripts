pro afripop

;the purpose of this script is to open the 0.1 degree admin 2 map and subset it to the EA, SA, WA domains

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;I also want to add the Yemen data to the East Africa map...
indir = '/discover/nobackup/almcnall/SHPfiles/'
ingrid = read_tiff(indir+'rfe2_g2008_1.tif')
ingrid = reverse(ingrid,2)


;;;;;;;;;;;Southern Africa WRSI/Noah window;;;;;;;;;
;
;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E)
;params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry, ulx, lrx, uly, lry]

params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

    ulx = (20.+ map_ulx)*10.
    ;lrx = (20.+ map_lrx)*10.-1 ;SA needed minus one
    lrx = (20.+ map_lrx)*10. ;EA does not
    uly = abs(-40.- map_uly)*10. 
    ;lry = abs(-40.- map_lry)*10.-1
    lry = abs(-40.- map_lry)*10.



;NX = 486 & NY = 443
;map_ulx = 6.05  & map_lrx = 54.55
;map_uly = 6.35  & map_lry = -37.85

;ulx = (17.531+map_ulx)/0.00833  & lrx = 8858-((56.25-map_lrx)/0.00833)
;uly = (47+map_uly)/0.00833   & lry = (47.+map_lry)/0.00833

;print, ulx, lrx, uly, lry
;NX = lrx - ulx
;NY = uly - lry

SAafr=ingrid[ulx:lrx,lry:uly]
;write out binary file that LIS can read:
;options big_endian
;UNDEF  -9999.
saafr(where(saafr eq 0)) = -9999
byteorder,saafr,/XDRTOF

ofile = strcompress(indir+'/WA_admin1.1gd4r')
openw,1,ofile
writeu,1,saafr
close,1

afr(where(afr lt 0)) = !values.f_nan


SA10 = congrid(afr,486,443)
temp = image(sa10,transparency=0)
temp = image(qs,/overplot,transparency=50, rgb_table=4)
;ofile = indir+'SAfrica_POP_10km.tiff'
;write_tiff, ofile, sa10, /FLOAT

;;;;;;;;;West Africa (5.35 N - 17.65 N; 18.65 W - 25.85 E)
NX = 446 & NY = 124
; west africa domain
map_ulx = -18.65 & map_lrx = 25.85
map_uly = 17.65 & map_lry = 5.35

;x direction is ~1degree and y is ~0.5 degree..
;ulx = abs((17.531+map_ulx))/0.00833  
ulx = 0 ;since World pop doesn't go far enought west
lrx = 8858-((56.25-map_lrx)/0.00833)
uly = (47+map_uly)/0.00833   & lry = (47.+map_lry)/0.00833

print, ulx, lrx, uly, lry
NX = lrx - ulx
NY = uly - lry

afr=ingrid[ulx:lrx,lry:uly]
afr(where(afr lt 0)) = !values.f_nan
;I should actually pad this out so it is the correct size
xpad = floor((18.66-17.531)/0.00833) & print, xpad ;how tall in the y directions do you need to be?
pad = fltarr(xpad,1478)*!values.f_nan
WA = [pad,afr] & help, WA

WA10 = congrid(WA,446,124)
temp = image(wa10,transparency=0)
temp = image(qs,/overplot,transparency=50, rgb_table=4)
;ofile = indir+'WAfrica_POP_10km.tiff'
;write_tiff, ofile, wa10, /FLOAT

;;;;;;;;;;;East Africa WRSI/Noah window;;;;;;;;;
;East Africa (11.75 S - 22.95 N; 22.0 E - 51.35 E)
NX = 294 & NY = 348
;East Africa WRSI/Noah window
map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;define the subset of the continental domain
ulx = (17.531+map_ulx)/0.00833  & lrx = 8858-((56.25-map_lrx)/0.00833)
uly = (47+map_uly)/0.00833   & lry = (47.+map_lry)/0.00833

print, ulx, lrx, uly, lry
NX = lrx - ulx
NY = uly - lry

afr=ingrid[ulx:lrx,lry:uly]
afr(where(afr lt 0)) = !values.f_nan

EA10 = congrid(afr,294,348)
temp = image(ea10,transparency=0, max_value=10)
temp = image(qs,/overplot,transparency=50, rgb_table=4)
;ofile = indir+'EAfrica_POP_10km.tiff'
;write_tiff, ofile, ea10, /FLOAT

;;Yemen domain to add to EA UL=41.816E, 19N

;Yemen in the east africa window..he east/south extent will be too far.
dims = size(yemgrid, /dimensions) & print, dims
yNX = dims[0]
yNY = dims[1]

map_ulx = 41.816  & map_lrx = 54.52
map_uly = 19.0  & map_lry = 12.15

map_ulx = 22.  & map_lrx = 51.35
map_uly = 22.95  & map_lry = -11.75

;i need to add pixels in the xleft, crop on xright should i regrid these things first? probably, faster.
ulx = (41.816-map_ulx)/0.00833  & lrx = 1525-((54.52-map_lrx)/0.00833)
;add to ytop, add to y bottom, not enought, why?
uly = (map_uly-19.0)/0.00833   & lry = (12.15-map_lry)/0.00833
print, ulx, lrx, uly, lry

top = intarr(ynx,uly)*!values.f_nan
bot = intarr(ynx,lry)*!values.f_nan
left = intarr(ulx, 4169)*!values.f_nan

v = [ [bot],[yemgrid],[top] ] & help, v
h = [ [left, v[0:lrx,*] ] ] 

help, h, afr
h01 = congrid(h,294,348)
Afr01 = congrid(afr,294,348)

merge =  [ [[afr01]],[[h01]]] & help, merge
AfrYem = total(merge,3,/nan) & help, afryem
ofile = indir+'EAfricaYEM_POP_10km.tiff'
write_tiff, ofile, AfrYem, /FLOAT

;EA10 = congrid(afr,294,348)
;temp = image(ea10,transparency=0, max_value=10)
;temp = image(qs,/overplot,transparency=50, rgb_table=4)
;;ok, two pixels off seems fine, now can i congrid them?
;temp = image(h)

;print, ulx, lrx, uly, lry
;NX = lrx - ulx
;NY = uly - lry
