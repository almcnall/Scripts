PRO ubrf_daily

;this program calculates the contribution of each day for a given month of rainfall
;this percentage is then applied to the monthly unbiased rainfall data to 
;create daily unbiased rainfall estimates
;AM 11/17/10
;
;define some things
exp   ='EXP017'
name  ='trmm'
nx    = 301.
ny    = 321.
small = 10. ;keeps pon from being divided by 0.

;initalize the arrays
bias_month_tot = fltarr(nx,ny)
day_of_month   = fltarr(nx,ny)
pomonth        = fltarr(nx,ny)
unb_month      = fltarr(nx,ny)
ubrf_day       = fltarr(nx,ny)

month_tot_dir = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/month_total_units',/remove_all)
daydir        = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/daily',/remove_all)
mubrf_dir     = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/ubrfv2', /remove_all) ;monthly ubrfs
;odir          = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/pomonth/', /remove_all)
odir2         = strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/daily_ubrf', /remove_all)

;file_mkdir, odir if I want to see percent of normals
file_mkdir, odir2

;daily biased rainfall files
cd, daydir
day_file = file_search('*.img')

;take the monthly totals that have already been created and pon them from the unbiased months
cd, month_tot_dir ; biased: this skips the step of summing up the daily values b/c I already did it. 
month_tot=file_search('*.img')
  
;initalize month file counter
count = 0 

;for all the days in all the years
for j=0, n_elements(day_file) do begin
   
   ;definitions for string matching  
   dyr  = strmid(day_file[j],5,4)
   dmo  = strmid(day_file[j],9,2)
   dday = strmid(day_file[j],11,2)
   myr  = strmid(month_tot[count],5,4)
   mmo  = strmid(month_tot[count],9,2)
    
    ;advance month file when last day of month is reached
    if (myr ne dyr) OR  (mmo ne dmo) then count=count+1
    ;if (myr eq dyr) AND (mmo eq dmo) then begin;if the year and the month match then
     
     ;open up the month_total file
     cd, month_tot_dir 
     openu,1, month_tot[count]
     readu,1, bias_month_tot
    
    ;and open the day file
     cd, daydir
     openu,2,day_file[j]
     readu,2,day_of_month
    
    ;calculate daily contribution to the monthly total
     pomonth=(day_of_month*86400)/(bias_month_tot) ;changes kg/m2/s to mm/day

     ;get the monthly_unbiased rainfall
     cd, mubrf_dir
     all_mubrf=file_search('*'+name+'.img')  
     
     ;open the unbiased monthly files
     openu,3,all_mubrf[count]
     readu,3,unb_month
     
     ;calculate the daily unbiased rainfall
     ubrf_day=pomonth*unb_month
     
     ;write the daily unbiased rainfall
     ub_file = strcompress(+odir2+'/ubrf_'+name+'_'+dyr+dmo+dday+'.img', /remove_all)
     openw, 4,ub_file
     writeu,4,ubrf_day
     
     close, /all
;     
;     ofile  = strcompress(+odir+'pom_'+dyr+dmo+dday+'.img', /remove_all)     
;     openw,3,ofile
;     writeu,3,pomonth ;write out the percent of month for each day
;     close,/all
  ;endif   
  endfor
end   
 