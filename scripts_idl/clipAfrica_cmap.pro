PRO clipAfrica_cmap

; this program subsets the global CMAP data to the Africa domain
; Africa:  20W - 55E,  40S - 40N  @ 0.25 degrees 75 x  80   degrees      300 x 320  pixels
;                                 @ 2.5 degree                            31 x  33  pixels     
indir  = strcompress('/jabber/LIS/Data/reshapeCMAP/moncube/', /remove_all)
outdir = strcompress('/jabber/LIS/Data/reshapeCMAP/moncube/Africa/' , /remove_all)

file_mkdir,outdir

cd, indir
infile = file_search('*.img')
nfile  = n_elements(infile)

inx  = 144.
iny  = 72.
outx = 30.
outy = 32.
bands = 10; analysis from 2000-2009

globe = fltarr(inx,iny,bands)
afr   = fltarr(outx,outy,bands)

for i=0,n_elements(infile)-1 do begin
   ;i=0
   openu,1,infile[i]
   readu,1,globe                           
   
   afr = globe(64:94,20:52,*)   ;I can't figure out why this is wrong...  
    
  ofile1 = strcompress(outdir+'afr_'+infile[i], /remove_all) ;
  ;ofile2 = strcompress(outdir+infile[i], /remove_all) ;
  print,   ofile1
  
  openw, 2,ofile1
  writeu,2,Afr
  
;  openw,3,ofile2
;  writeu,3,globe
  
  close, /all
  
endfor

end


   

