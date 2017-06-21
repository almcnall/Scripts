PRO janfeb_ndvi

;this program averages the months of january and february for
; the ndvi files...

;expdir = 'EXP020'

wdir = strcompress("/gibber/lis_data/malawi_ndvi_indv/",/remove_all)
odir = strcompress("/gibber/lis_data/febmar_ndvi/",/remove_all)
FILE_MKDIR,odir ;changed from avg to total 10/24

print,wdir
cd,wdir 

nx    = 683.  ;5469.
ny    = 1636.  ;4399.
bands = 4. ;for jan/feb or feb/mar for each year

buffer = bytarr(nx,ny)   ;each jan and feb file for a yr
datain = bytarr(nx,ny,bands)
dataout= bytarr(nx,ny)

jan1='001'
jan2='017'
feb1='033'
feb2='049'
mar1='065'
mar2='081'

  ;FOR j =0, n_elements(vars)-1 DO BEGIN
   FOR yr = 2001, 2009 DO BEGIN
   img1= file_search(strcompress(+string(yr)+feb1+'mal_ndvi.img',/remove_all));finds all the files in a month for a particular variable
   img2= file_search(strcompress(+string(yr)+feb2+'mal_ndvi.img',/remove_all))
   img3= file_search(strcompress(+string(yr)+mar1+'mal_ndvi.img',/remove_all))
   img4= file_search(strcompress(+string(yr)+mar2+'mal_ndvi.img',/remove_all))
   
   openr,1,img1
   openr,2,img2
   openr,3,img3
   openr,4,img4
   
    
   readu,1,buffer
   buffer(where(buffer eq 96)) = !VALUES.F_NAN
   datain[*,*,0]=buffer
   
   readu,2,buffer
   buffer(where(buffer eq 96)) = !VALUES.F_NAN
   datain[*,*,1]=buffer
   
   readu,3,buffer
   buffer(where(buffer eq 96)) = !VALUES.F_NAN
   datain[*,*,2]=buffer
   
   readu,4,buffer
   buffer(where(buffer eq 96)) = !VALUES.F_NAN
   datain[*,*,3]=buffer
   print, 'done reading for '+string(yr)
   
 
   for x=0,nx-1 do for y=0,ny-1 do begin ;take mean
    dataout[x,y] = mean(datain[x,y,*],/NAN);
    print, 'calculating mean at ' +string(x)+string(y)
   endfor ;the mean loop  
   
   of1 = strcompress(+odir+string(yr)+'_febmar.img',/remove_all)
   openw,5,of1
   writeu,5,dataout
   
   close,/all
   print,"wrote " + of1 
   
   endfor ;year
 end
   