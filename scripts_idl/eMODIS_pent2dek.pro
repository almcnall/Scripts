pro eMODIS_pent2dek
; grab the even numbered continental pentadal ndvi to get the dekads
;initally I was filling in the end of 2011 so there is funny code re: parts of 2011
;I updated just to deal with 2012 - get the data with the crappy naming convention, 
;fix the naming convention, pull out the even pentads (since I just want dekads), and then write them 
;out again. **I am not sure if this clips them, but probably not....

ifile = file_search('/jower/sandbox/mcnally/eMODIS_continental/*12.tif'); 
;ifile = file_search('/jabber/sandbox/shared/Amy-eMODIS/*12.tif')
;elev  = file_search('/jabber/sandbox/shared/Amy-eMODIS/*11.tif')
;first parse out the files that have double digit dekads....
;p = strarr(9)
;pp = strarr(n_elements(ifile)-9)
;cc = 0
;c = 0
;for i = 0,n_elements(ifile)-1 do begin &$
;if strmid(ifile[i],51,1) eq 'f' then begin &$
; pp[cc] = ifile[i]  &$
; cc++  &$
; endif else if strmid(ifile[i],43,1) ne 'f' then begin &$
;   p[c] = ifile[i] &$
;   c++ &$
; endif  &$
;endfor
;
;renam = strarr(n_elements(p))
;for i = 0,n_elements(p)-1 do begin &$
;  renam[i] = strcompress(strmid(p[i],0,44)+'0'+strmid(p[i],44,7),/remove_all) &$
;  indata = READ_TIFF(p[i],R,G,B,GEOTIFF=g_tags,ORIENTATION=o_tate,PLANARCONFIG=p_conf) &$
;  WRITE_TIFF,renam[i],indata,RED=R,GREEN=G,BLUE=B,GEOTIFF=g_tags_master,ORIENTATION=o_tate_master,PLANARCONFIG=p_conf  &$
;endfor
;  


;end of 2011, the problem pents and the rest of 2012
;filelist = [elev, renam, pp]
;just pull out the even numbers since we want dekads not pentads
ifile = file_search('/jower/sandbox/mcnally/eMODIS_continental/????12.tif')
even = strarr(n_elements(ifile)/2)
cnt = 0
for i = 0,n_elements(ifile)-1 do begin &$
  if fix(strmid(ifile[i],44,2)) MOD 2 eq 0 then begin  &$
    even[cnt] = ifile[i] &$
    cnt++ &$
  endif &$
endfor

;as if that wasn't bad enough...how do i match this awful naming convention
;outname = ['data.2011.113.tiff','data.2011.121.tiff', 'data.2011.122.tiff','data.2011.123.tiff']

;make out names
outname = strarr(36)
yyyy = 2012
mo = ['01','02','03','04','05','06','07','08','09','10','11','12']
dk = ['1','2','3']
cnt = 0
for i = 0, n_elements(mo)-1 do begin &$
  for j = 0,n_elements(dk)-1 do begin &$
    outname[cnt] = ['data.2012.'+mo[i]+dk[j]+'.tiff'] &$
    cnt++ &$
  endfor  &$;j
endfor ;i

;dek = 2
;oname = strarr(n_elements(even))
;for f = 0, n_elements(even)-1 do begin &$
;    dek++ &$
;    
;    if strmid(even[f],36,4) eq '6011' then m = 9 &$
;    oname[f] = strcompress('data.20'+strmid(even[f],38,2)+'.'+string(mo[m])+string(dek)+'.tiff', /remove_all) &$
;    
;    print, dek &$
;    if dek eq 3 then dek = 0 AND m++ &$
;    if m eq 12 then m = 0  &$
;endfor  
;make sure that they match up properly...
print, [transpose(outname), transpose(even)]

;not toally sure what this is doing....but i think i pulled this from chop_tif_worksheet
masterfilename = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/data.2010.113.tiff'
masterinfo = FILE_INFO(masterfilename)
mastertif = READ_TIFF(masterfilename, R, G, B, GEOTIFF=g_tags_master, ORIENTATION = o_tate_master,PLANARCONFIG = p_conf_master)
masterdims = SIZE(mastertif)
masterNY = masterdims[2]

for e = 0,n_elements(even)-1 do begin &$
  indata = READ_TIFF(even[e],R,G,B,GEOTIFF=g_tags,ORIENTATION=o_tate,PLANARCONFIG=p_conf) &$
  out_dir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/new_2012/'  &$
  WRITE_TIFF,out_dir+outname[e],indata(*,0:masterNY-1),RED=R,GREEN=G,BLUE=B,GEOTIFF=g_tags_master,ORIENTATION=o_tate_master,PLANARCONFIG=p_conf  &$
  print, outname[e] &$
endfor;e