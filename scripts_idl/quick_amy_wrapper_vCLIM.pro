FUNCTION quick_amy_wrapper_vCLIM,inmonth,inday
;june 10, 2014 modified quick_amy_wrapper to preprocess the climatology to 0.1 degree, -9999.0, big endian
;
   ;INX = 1500
   ;INY = 1600

   in_data_dir = '/home/sandbox/people/mcnally/CHIRPS-1.8/avg30yr'
   
   out_data_dir = '/home/ftp_out/people/mcnally/lis/CHIRPS/avg30yr/'
  
   infile = in_data_dir +'/chirps-v1.8.'+STRING(FORMAT= '(I2.2,''.'',I2.2,''.tif'')',inmonth,inday) & help, infile
   
   outfile = out_data_dir +'all_products.bin.'+STRING(FORMAT='(I2.2,''.'',I2.2)',inmonth,inday) & print, outfile


   chirpsday = READ_TIFF(infile)

   dayp1 = Afr05_to_Afr10(chirpsday)
   good = where(finite(dayp1), complement=nan)
   dayp1(nan) = -9999.0
   
   close,1
   openw,1,outfile,/SWAP_ENDIAN
   writeu,1,REVERSE(dayp1,2)
   close,1

   return,1

END
   


