pro write_arcview_file
;

indir='/jabber/LIS/Data/worldclim/africa/scaled_R0/
;indir='/jabber/sandbox/mcnally/R0_arc/'
ifile = file_search(indir+'R0*img') ;they don't yet have the ppt prefix
odir='/jabber/sandbox/mcnally/R0_arc/'
;file_mkdir,'arcview_format'
;infiles = file_search(filter)

;rotate images for arcmap and envi
nx=9001
ny=9601
buffer=fltarr(nx,ny)

;just had to open up the files to flip them....
for i=0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[i] &$
  readu,1,buffer &$
  close,1 &$
  
  buffer=reverse(buffer,2) &$
  buffer=buffer*1000
  buffer=fix(buffer)
  
  ofile=strcompress(odir+strmid(ifile[i],44,5)+'.img', /remove_all) &$
  openw,1,ofile &$
  writeu,1,buffer &$
  close,1 &$
  
endfor

COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT

for i=5,n_elements(ifile)-1 do begin

  ofile=strcompress(odir+strmid(ifile[i],31,5)+'.bil', /remove_all)
  
  ENVI_OPEN_FILE,ifile[i],R_FID=fid,/NO_REALIZE
  ENVI_FILE_QUERY,fid,DIMS=dims,nl=nl,nb=nb,FILE_TYPE=file_type
  ;print, data_type
  
  ENVI_OUTPUT_TO_EXTERNAL_FORMAT,/ARCVIEW,DIMS=dims,FID=fid,OUT_NAME=ofile,POS=[0]
  ENVI_FILE_MNG,id=fid,/remove

endfor

end
