pro improve_rfeV2

;the purpose of this script is to replace the five pixels that cover the  niger study site with 
;the station data avaialable from AMMA. It calls the function FUNreadAMMA to read rainfall data from
;the two different files and this script concatinates them in inarr.

indir = '/jabber/Data/mcnally/AMMARain/'
cd, indir

fname = file_search(indir+'143-CL.Rain_Nc.csv')
data = FUNread_AMMA(fname)

fname = file_search(indir+'132-CE.Rain_up*.csv')
data2 = FUNread_AMMA(fname)

inarr=[[data],[data2]]
position=intarr(1,n_elements(inarr[0,*]))
position[*,*]=!values.f_nan
inarr=[inarr,position]
;now I need to group the data according to location then by day
;group by location: add a pixel id to the list of station data.
;data = yr, mo, day, lat, lon, rain, x, y

yr = inarr[0,*]
mo = inarr[1,*]
dy = inarr[2,*]
lat = inarr[3,*]
lon = inarr[4,*]
rain = inarr[5,*]
;
;assigns a position to each of the values in the big array
uplft = where(lon ge 2.55 AND lon le 2.65 AND lat gt 13.55) & inarr(8,uplft)=0
upcnt = where(lon gt 2.65 AND lon le 2.75 AND lat gt 13.55) & inarr(8,upcnt)=1

dnlft = where(lon ge 2.55 AND lon le 2.65 AND lat le 13.55) & inarr(8,dnlft)=2
dncnt = where(lon gt 2.65 AND lon le 2.75 AND lat le 13.55) & inarr(8,dncnt)=3
dnrgt = where(lon gt 2.75 AND lon le 2.85 AND lat le 13.55) & inarr(8,dnrgt)=4

years = yr(rem_dup(yr))
  years = years[1:4]
months = mo(rem_dup(mo))
  month = months[1:7]
days = dy(rem_dup(dy))
  days = days[1:31]

outarr=fltarr(5,1540)
i=0 & j=0 & k=0 & l=0 & q=0 & counter=0
for l=0,3 do begin
  for i=0,n_elements(years)-1 do begin
    for j=0,n_elements(months)-1 do begin
      for k=0,n_elements(days)-1 do begin     
        q=where(inarr[8,*] eq l AND yr eq years[i] AND mo eq months[j] AND dy eq days[k] AND rain gt -1, count)
        if count eq 0 AND total(inarr[5,q]) lt -1 then continue
         rmean = mean(inarr[5,q])
         outarr[*,counter] = [years[i], months[j], days[k], mean(inarr[5,q]), l]
         counter++
       endfor;k
     endfor;j
   endfor;i
 endfor;l
 print, 'hold here'
 end

;ok, so now the data has been averaged by day by pixel. 
;;*************replace the values in the rfe files *******************
; print, 'stop here please'
;cd, '/jabber/LIS/Data/ubRFE2/'
;ingrid=fltarr(751,801)
;;replace all of the grids of interest from 2005 to 2008. That mean ll (all zeros 2205&6) and lr (all zeros 2005)
;; this might be a problem....
;fname=file_search('*{2005,2006,2007,2008}*') ;ug, I think that this is a problem for lower left and lower right....
;
;for m=0, n_elements(fname)-1 do begin
;  openr,1,fname[m]
;  readu,1,ingrid
;  byteorder,ingrid, /XDRTOF
;  close,1
;  
;  ;zero out the unqpix....
;  ingrid(unqpix[0,0], unqpix[1,0]) = 0.
;  ingrid(unqpix[0,1], unqpix[1,1]) = 0.
;  ingrid(unqpix[0,2], unqpix[1,2]) = 0.
;  ingrid(unqpix[0,3], unqpix[1,3]) = 0.
;  ingrid(unqpix[0,4], unqpix[1,4]) = 0.
;  
; ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+fname[m], /remove_all)
; openw,1,ofile
; byteorder,ingrid,/XDRTOF
; writeu,1,ingrid
; close,1
;  
;endfor; m
;
;cd, '/jabber/LIS/Data/AMMArfe_grid/'
;
;for l=0, n_elements(uqyr)-1 do begin
;  ;l=0
;  rfile = file_search('all_products.bin.'+uqyr[l]+uqmo[l]+uqdy[l]); this is only for days when vals were recorded
;  openr,1,rfile
;  readu,1,ingrid
;  byteorder,ingrid,/XDRTOF
;  close, 1
;  
;  ;as long as the value is a number then replace it...starting 20050827
;  if finite(ul(3,l)) eq 1 then ingrid(unqpix[0,0], unqpix[1,0]) = ul(3,l) ; the first entry of the dates there are 125 of these...make sure these are in correct order
;  if finite(lc(3,l)) eq 1 then ingrid(unqpix[0,1], unqpix[1,1]) = lc(3,l)
;  if finite(uc(3,l)) eq 1 then ingrid(unqpix[0,2], unqpix[1,2]) = uc(3,l)
;  if finite(lr(3,l)) eq 1 then ingrid(unqpix[0,3], unqpix[1,3]) = lr(3,l);these start later.
;  if finite(ll(3,l)) eq 1 then ingrid(unqpix[0,4], unqpix[1,4]) = ll(3,l);these start later. 
; 
; ofile = strcompress('/jabber/LIS/Data/AMMArfe_grid/'+rfile, /remove_all)
; openw,1,ofile
; byteorder,ingrid,/XDRTOF
; writeu,1,ingrid
; close,1
;endfor ;l
; 
;print, 'hello'  
 