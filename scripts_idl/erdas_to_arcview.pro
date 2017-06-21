pro erdas_to_arcview
;
wkdir=strcompress('/gibber/lis_data/fclim_v4',/remove_all)
cd, wkdir

filter = '*img' ; this need to change with the filename too!
file_mkdir,'arcview_format'
infiles = file_search(filter)

COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT

for i = 0, n_elements(infiles) - 1 do begin

  ofile=strcompress('fclimv4_'+strmid(infiles[i],6,2)+'.bil',/remove_all)
  
  ENVI_OPEN_FILE,infiles[i],R_FID=fid,/NO_REALIZE
  ENVI_FILE_QUERY,fid,DIMS=dims,nl=nl,nb=nb,FILE_TYPE=file_type
  ;print, data_type
  cd,'arcview_format'
  
  ENVI_OUTPUT_TO_EXTERNAL_FORMAT,/ARCVIEW,DIMS=dims,FID=fid,OUT_NAME=ofile,POS=[0]
  
  cd,'..'
  ENVI_FILE_MNG,id=fid,/remove

endfor
;
end
