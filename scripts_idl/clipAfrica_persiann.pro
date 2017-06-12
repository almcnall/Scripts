PRO clipAfrica_persiann

; this program subsets the global PERSIANN data to the Africa domain
; Africa:  20W - 55E,  40S - 40N  75 x  80   degrees      300 x 320  pixels

indir  = strcompress('/jabber/LIS/Data/PERSIANN/', /remove_all) ;moved here 3/29/12
outdir = strcompress('/gibber/lis_data/Africa_PERS' , /remove_all) ;now at /jower/LIS/data/Africa_PERS 5/19/11

file_mkdir,outdir

cd, indir
infile = file_search('*.1gd4r')
nfile  = n_elements(infile)

inx  = 1440.
iny  = 480.
outx = 300.
outy = 320.

globe = fltarr(inx,iny)
afr   = fltarr(outx,outy)

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
  
  Afr = [globe(1360:1439,80:399), globe(0:219,80:399)] ;this is how you do it all in one line
  
  ofile = strcompress(outdir+'/'+infile[i], /remove_all) ; I need to rename these silly files....
  print,   ofile
  
  Afr[*,*] = REVERSE(Afr[*,*],2)
  openw, 2,ofile
  writeu,2,Afr
  
  close, /all
  
endfor

end


   

