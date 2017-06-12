pro make_lis_monthcubes  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; The purpose of this script is to cat the monthly total/averge for a specific variable into a monthly cube.
;;*************************************************************************

expdir = 'EXP028' 
  if expdir eq 'EXP028' then data='ubRFE2'
  
indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/month_total_units/",/remove_all)
outdir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/monthcubie/", /remove_all)

file_mkdir, outdir
cd, indir
;vars = strarr(9); length = 9
;vars= ['airtem', 'evap', 'soilm1', 'soilm2', 'soilm3','soilm4','rain', 'runoff', 'Qsub'] 
vars = strarr(1); length = 9
vars= ['PoET'] 

months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11','12' ]

count=0
ofile=strarr(108)

for i= 0, n_elements(vars)-1 do begin            ;for each variable
  for j=0 , n_elements(months)-1  do begin       ;for each of the files find the month...
  ifiles=file_search(vars[i]+'*'+months[j]+'_tot.img') 
    
    nbands = float(n_elements(ifiles)) ;freq of month in time series
    nx     = 301.
    ny     = 321. 
    
    buffer   = fltarr(nx,ny) ; 
    data_in  = fltarr(nx,ny,nbands);   
    
     FOR k = 0, nbands-1 do begin ; for each day
           ; open up file and read unformatted into 'data_in'
           openr,lun,ifiles[k],/get_lun
           readu, lun, buffer
           data_in[*,*,k] = buffer ;open up all the files in a month and read into data_in
           close,/all
     endfor ; end k
    
    ofile=strcompress(outdir+vars[i]+"_"+months[j]+".img", /REMOVE_ALL)
    openw, 2, ofile; do I make the filenames here or above?
    writeu,2, data_in
    close,2
   endfor; j
endfor; i
end; program
