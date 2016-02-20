.run
;this program creates the headerfiles that are needed to open image files in ENVI

 year = indgen(30) + 1979
 dekad = indgen(36) + 1
for y = 0, 29 do begin
 for d = 0, 35 do begin
  if (d lt 9) then s = '0' else s = ' '
  ff = strcompress(string('ppt',year(y),s,dekad(d),'.hdr'),/remove_all)
    openw,1,ff
    printf,1,'ENVI'
    printf,1,'description = {'
    printf,1,'  File Imported into ENVI.}'
    printf,1,'samples = 301'
    printf,1,'lines   = 321'
    printf,1,'bands   = 1'
    printf,1,'header offset = 0'
    printf,1,'file type = ENVI Standard'
    printf,1,'data type = 4'
    printf,1,'interleave = bil'
    printf,1,'sensor type = Unknown'
    printf,1,'byte order = 0'
    printf,1,'wavelength units = Unknown'
    close,1
    free_lun,1
 endfor
endfor
end
_______________________________________________________________________.run
;
.run
 dekad = indgen(36) + 1
 for d = 0, 35 do begin
  if (d lt 9) then s = '0' else s = ' '
  ff = strcompress(string('ppt',s,dekad(d),'.hdr'),/remove_all)
    openw,1,ff
    printf,1,'ENVI'
    printf,1,'description = {'
    printf,1,'  File Imported into ENVI.}'
    printf,1,'samples = 108'
    printf,1,'lines   = 75'
    printf,1,'bands   = 1'
    printf,1,'header offset = 0'
    printf,1,'file type = ENVI Standard'
    printf,1,'data type = 4'
    printf,1,'interleave = bil'
    printf,1,'sensor type = Unknown'
    printf,1,'byte order = 0'
    printf,1,'wavelength units = Unknown'
    close,1
    free_lun,1
 endfor
end
