pro hrly_to_day

; ********************notes*************************************
; AM 8/17/10: attempt to modify day_to_month
; **************************************************************

wdir = strcompress("/jower/LIS/RUN/OUTPUT/EXP006/NOAH", /remove_all)
print,wdir
cd,wdir 

dates = ['200909', '200910', '200911', '200912', '201001','201002', '201003', '201004'] 
for i = 0, n_elements(dates)-1 do begin
  files = file_search('daily/20??/soilm1_'+dates[i]+'??.img') ; makes an array of file names
    for n = 0, n_elements(files)-1 do begin 
          cat_days = [cat_days, read_binary('dates(i)+files(i)'), data_dims=[301,321], data_type =4, endian=
          'native')         
    write,  cat_days, '../month'
end do 
  
    
   
    

