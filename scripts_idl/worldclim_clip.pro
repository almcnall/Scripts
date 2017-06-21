pro worldclim_clip

;the purpose of this program is to read in the worldclim data
;chop it down to africa. versio two is a totally different script that makes an R0 map. 
;there is a problem with this script that needs to be re-run 6/29/12

;MinX          -180
;MaxX          180
;MinY          -60
;MaxY          90

;first read in the world clim data.
;but now that I am re-doing this part I am going to skip the clip part
;just read in the africa clipped files
;indir='/jabber/LIS/Data/worldclim/'
;cd, indir
;ifile=file_search('tmean_*bil')
ifile=file_search('/jabber/LIS/Data/worldclim/africa/worldclim_africa/tmean*.bil')

;;set the dimensions of the in (global) and out (africa)
;nx=43200
;ny=18000
ox=9001
oy=9601

;ingrid=intarr(nx,ny)
afr=intarr(ox,oy)
monthly=intarr(ox,oy,n_elements(ifile))
for i=0,n_elements(ifile)-1 do begin &$
  print, ifile[i]  &$
  openr,1,ifile[i] &$
  readu,1,afr &$
  ;readu,1,ingrid &$
  close,1 &$
  afr=reverse(afr,2) &$

  ;afr=ingrid(19200:28200,2400:12000) &$
  monthly[*,*,i]=afr &$
  mve, afr
  print, 'i='+string(i) ;just so I can see that something is happening
  
   ; make a list of possible temperatures....i could have just done this once...oh well  
;    list = rem_dup(afr[*,*,*])
;    tlist = afr(list)/10.
  ;write out the list of temperatures. minus the first -9999 value
 endfor
 print, 'hold here'
 list = rem_dup(monthly) ;using this 3d array might not be best....
 tlist = monthly(list)/10.
 
 print, 'hold here'
ofile='/jabber/LIS/Data/worldclim/africa/annual_temp_rangeAfrv2.txt
write_csv,ofile,tlist[1:n_elements(tlist)-1]
; print, ' writing ' +ofile
  
;  ofile=indir+'africa/'+ifile[i]
;  openw,1,ofile
;  writeu,1,afr
;  close,1
;  print, 'wrote '+ofile
;endfor



end
