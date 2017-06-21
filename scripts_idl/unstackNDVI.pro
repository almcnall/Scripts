PRO unstackNDVI

;this program takes the 5469 x 4399 x 210 stack from M. Budde and writes them to indiviual files.
  close, /all
  wkdir=strcompress('/gibber/lis_data/',/remove_all)
  odir=strcompress('/gibber/lis_data/malawi_ndvi_indv/',/remove_all)
  file_mkdir, odir
  cd, wkdir
  
  nx    = 683.  ;5469.
  ny    = 1636. ;4399.
  bands = 210.
  
  
  file = file_search('malawi_ndvi.img') ;zim_2000_2009081_sm
  
  tmp  = bytarr(nx,ny,bands)
  ogrid= bytarr(nx,ny)
  
  openr,1,file
    
  day = 49 ;start day
  year= 2000 ;start year
  
  for i=0,bands-1 do begin
     
     ofile=strcompress(odir+string(year)+STRING(FORMAT='(I3.3)',day)+'mal_ndvi.img', /remove_all)
     print, ofile
     
     ogrid=tmp[*,*,i]
     
     readu,1,ogrid
     print, 'reading ' +file
     
     openw,2,ofile
          writeu,2,ogrid
     print, 'writing ' +ofile
     day=day+16
     
     close, 2
     if (day gt 353) then year= year + 1 
     if (day gt 353) then day = 1 
     if (year eq 2009) AND (day gt 244) then break
  endfor ;bands
  
  end
  
  
  
  