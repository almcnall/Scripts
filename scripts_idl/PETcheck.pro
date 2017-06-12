pro PETcheck

;the purpose of this program is to look at NOAH and EROS daily PET and RefET to 
;see if it matches Ramier et al. (2009) figure 6. NOAH won't match reference et but things look fine. end of check 11/24 11:30am

;checking out daily PET to compare with Ramier et al. (2009)
 expdir = 'EXPA02'
 cd, '/gibber/lis_data/OUTPUT/'+expdir+'/NOAH/daily/'
 ff = file_search('PoET*.img')
 
nx = 720.
ny = 350.
ifile=fltarr(nx,ny)
buffer=fltarr(nx,ny,n_elements(ff))
; this part isn;t working quite right. to get the matching value from what I extracted as upopercenter in ENVI I need to use 
; 226, 165. this is not what I get when I enter in the lat lons and subtract from the edges....
lon=2.7
lat=13.5

POI=fltarr(2)
POI[0]=(lon+19.95)*10 ;given the way that the image is rotated it needs to shift right by ~20 and since 'zero'=29.95 I have to adjust accordingly
POI[1]=(29.95-lat)*10
 
for i=0, n_elements(ff)-1 do begin
 openr,1,ff[i]
 readu,1,ifile
 close,1
 buffer(*,*,i)=ifile
endfor

print, 'hold here'
;pixel=buffer(226,165,*)*86400 ;EROS data needs to be divided by 100 since they have been scaled for integer storage
;p1=plot(pixel)
;p1=plot(ts_smooth(pixel, 15), /overplot, color='green')



end