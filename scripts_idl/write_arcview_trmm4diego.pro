pro write_arcview_trmm4diego

wkdir=strcompress('/jabber/Data/mcnally/trmm4diego/',/remove_all)
odir=strcompress('/jabber/Data/mcnally/trmm4diego_arcview/',/remove_all)
file_mkdir,odir

cd,wkdir

infiles = file_search('WHem*.img')

COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT

for i = 0, n_elements(infiles) - 1 do begin

  ofile=strmid(infiles[i],0,18)+'bil'
  
  ENVI_OPEN_FILE,infiles[i],R_FID=fid,/NO_REALIZE
  ENVI_FILE_QUERY,fid,DIMS=dims,nl=nl,nb=nb,FILE_TYPE=file_type
  ;print, data_type
  cd,odir
  
  ENVI_OUTPUT_TO_EXTERNAL_FORMAT,/ARCVIEW,DIMS=dims,FID=fid,OUT_NAME=ofile,POS=[0]
  
  cd,wkdir
  ENVI_FILE_MNG,id=fid,/remove

endfor
;
end
