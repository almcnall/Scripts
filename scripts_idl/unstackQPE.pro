PRO unstackQPE

;this program takes the 12 x 31 x 98 stack of Malawi rainfall and writes them to indiviual files.

exp      = 'EXP017'
name     = 'trmm'
;unbiased ='UB'

  close, /all
  wkdir=strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/',/remove_all)
  odir=strcompress('/gibber/lis_data/OUTPUT/'+exp+'/TEMPLATE/UBrainmonthMal/',/remove_all)
  file_mkdir, odir
  cd, wkdir
  
  nx    = 12.  ;5469.
  ny    = 31. ;4399.
  bands = 98.
  
  
  file = file_search('UBmonth'+name+'_mal') ;zim_2000_2009081_sm
  
  tmp  = fltarr(nx,ny,bands)
  ogrid= fltarr(nx,ny)
  
  openr,1,file
    
  month = 2 ;start day
  year= 2009 ;start year
  
  for i=0,bands-1 do begin
     
     ofile=strcompress(odir+'ubmal_'+string(year)+STRING(FORMAT='(I2.2)',month)+'.img', /remove_all)
     print, ofile
     
     ogrid=tmp[*,*,i]
     
     readu,1,ogrid
     print, 'reading ' +file
     
     openw,2,ofile
          writeu,2,ogrid
     print, 'writing ' +ofile
    month=month-1
     
     close, 2
     if (month lt 1) then year= year - 1 
     if (month lt 1) then month = 12 
     if (year eq 2001) AND (month lt 01) then break
  endfor ;bands
  
  end
  
  
  
  