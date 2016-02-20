PRO clipAfrica_cmorph

; this program subsets the global PERSIANN data to the Africa domain
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      300 x 320  pixels

indir  = strcompress('/jabber/LIS/Data/CMORPH/moncubie/', /remove_all) ;now at /jower/LIS/data/tarballs 5/19/11
outdir = strcompress('/jabber/LIS/Data/CMORPH/moncubie/Africa_CMOR/' , /remove_all) ;now at /jower/LIS/data/Africa_PERS 5/19/11

file_mkdir,outdir

cd, indir
infile = file_search('*.img')
nfile  = n_elements(infile)

inx    = 1440.
iny    = 480.
nbands = 6.
outx = 300.
outy = 320.


globe = fltarr(inx,iny,nbands)
afr   = fltarr(outx,outy,nbands)

for i=0,n_elements(infile)-1 do begin
   ;i=0
   openu,1,infile[i]
   readu,1,globe                                ;persiann data starting at 0.125 deg chopping africa
   byteorder,globe,/XDRTOF
   ;data_in[*,*,i] = globe ;use this if I want to stack all of the files....do I? Prolly not. 
   
   globe(where(globe lt 0)) = 9999 ;
   
  ;AfrL = globe(1360:1439,80:399) ;this gets west africa, it has been chopped off by the PM so it is on the right side o' original image
  ;AfrR = globe(0:219,80:399)     ;this is most of africa: most of africa is east of the prime meridian (PM), 80-399 is the north-south so that doesn't change  
  ;Afr = [AfrL, AfrR]             ;this concatinates the western chunck to the eastern majority
  
  Afr = [globe(1360:1439,80:399,*), globe(0:219,80:399,*)] ;this is how you do it all in one line
  
  ofile = strcompress(outdir+infile[i], /remove_all) ; I need to rename these silly files....
  print,   ofile
  
  Afr[*,*,*] = REVERSE(Afr[*,*,*],2)
  openw, 2,ofile
  writeu,2,Afr
  
  close, /all
  
endfor

end


   

