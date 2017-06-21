FUNCTION quick_amy_wrapper,inyear,inmonth,inday
;I moved this over to my directory and modified it 5/12/14
;what file do I use this with? chirps4LISWRSI.pro
;
;4/10/15 update for chirps2.0
;move data from /home/ftp_out/products/CHIRPS-2.0/africa_daily/tifs/p05
;to /home/sandbox/people/mcnally/CHIRPS4LIS/ for unzipping
;for i in {1981..2015}; do mkdir $i;done
;revist 9/8/15, how do i run this? compile this, Afr05_to_Afr10.pro and run the commented for-loop below
;6/4/16 still need this to run LIS-WRSI. srsly.
;
;ndays = [31,28,31,30,31,30,31,31,30,31,30,31]
;;for inyear=2015,2015 do begin &$
;  inyear=2015
;  for inmonth=3,8 do begin &$
;  for inday=1,ndays[inmonth-1] do dump = quick_amy_wrapper(inyear,inmonth,inday) &$
;;endfor &$
;endfor

   in_data_dir = '/home/sandbox/people/mcnally/CHIRPS4LIS/'

   out_data_dir = '/home/ftp_out/people/mcnally/lis/CHIRPS-v2.0/' ;chirps-v2.0.1981.12.31.tif
   
   infile = in_data_dir + STRING(FORMAT= '(I4.4,''/chirps-v2.0.'',I4.4,''.'',I2.2,''.'',I2.2,''.tif'')',inyear,inyear,inmonth,inday)
   outfile = out_data_dir + STRING(FORMAT='(I4.4,''/all_products.bin.'',I4.4,I2.2,I2.2)',inyear,inyear,inmonth,inday)

   chirpsday = READ_TIFF(infile)

   dayp1 = Afr05_to_Afr10(chirpsday)

   close,1
   openw,1,outfile,/SWAP_ENDIAN
   writeu,1,REVERSE(dayp1,2)
   close,1

   return,1
   print, outfile

END
   
