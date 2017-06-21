;;;WORKSHEET FOR ANALYSIS OF SCENARIOS

;;; get all the background data put in place, this is standard from 
;;; other code (may need to compile some other code to get it right
   NX = 751     ; number of columns
   NY = 801     ; number of rows

   start_mo = 9         ; month of the start of season
   start_dek = ((start_mo-1) * 3) + 1   ; dekad number of the first dekad of start_mo
   end_mo = 3           ; last month to look at rainfall
   end_dek = (end_mo * 3)               ; dekad number of the third dekad of end_mo

   ; create 4-dimensional line of cubes that is NX x NY x nyrs x ndeks
   rain4d = FILLRAIN(start_dek,end_dek,NX,NY)

   ; get SOS for the 4-d array
   SOS_out = GET_SOS(rain4d)

   ; flip the SOS data right-side up
   SOS_out = REVERSE(SOS_out,2)

   ; subset greater horn
   ulx   = 284                   ; upper-left x
   uly   = 402                   ; upper-left y
   lrx   = 705                   ; lower-right x
   lry   = 732                   ; lower-right y
 
   SA_x = lrx - ulx +1
   SA_y = lry - uly +1

   SA_SOS = SOS_out(ulx:lrx,uly:lry,*)

   ; read in LGP file
   SA_LGP = BYTARR(NX,NY)
   fname = '/home/husak/ssn_analysis/south/lgp_south16.bil'
   close,1
   openr,1,fname
   readu,1,SA_LGP
   close,1
   SA_LGP = SA_LGP(ulx:lrx,uly:lry)

   ; find max dekad for the end-of-season
   s = size(SA_SOS)            ; get the size of the SOS cube
   if s(0) eq 2 then nyears = 1 else nyears = s(3)      ; set the number of seasons in SOS cube
   SA_EOS = BYTARR(SA_x,SA_y,nyears)
   for i=0,nyears-1 do begin            ; for each year in the SOS cube
      tmp_sos = SA_SOS(*,*,i)
      tmp_eos = BYTARR(SA_x,SA_y)
      good_sos = where(tmp_sos ne 60 AND SA_LGP ne 0, count_good)      ; find valid start and end to season locations
      if count_good gt 0 then $
         tmp_eos(good_sos) = tmp_sos(good_sos) + SA_LGP(good_sos) -1    ; add SOS to LGP to get the EOS
      SA_EOS(*,*,i) = tmp_eos
   endfor
   eossn_max = max(SA_EOS)     ; find the maximum eos
   eossn_max = eossn_max + start_dek	; account for the start dekad, which doesn't appear elsewhere
   if eossn_max gt 36 then eossn_max = eossn_max - 36   ; adjust if it runs over the new year

   ; get all needed rainfall for calculations flip and clip to region
   if eossn_max - start_dek lt 6 AND eossn_max - start_dek gt 0 then $
      print,'max_dekad is shortly after start dekad',eossn_max, start_dek
   rain4d = FILLRAIN(start_dek, eossn_max,NX,NY)
   rain4d = REVERSE(rain4d,2)
   rain4d = rain4d(ulx:lrx,uly:lry,*,*)
;;; okay, that's the end of setting everything up

NX = 422
NY = 331
nyrs = 13	; number of years in history
nsims = 100	; number of simulations

;read in seasonal average
ssnave = FLTARR(NX,NY)
close,1
openr,1,'full_season_ave_12yr'
readu,1,ssnave
close,1

month = [12, 12, 12, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5]
dekad = [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]

t=0

for t=0,N_ELEMENTS(month)-1 do begin
   ; find the current accumulation
   current_sos = SA_SOS(*,*,nyears-2)
   current_accum = FLTARR(SA_x,SA_y)
   current_dek = ((month[t] - 1) * 3) + dekad[t]
   if current_dek lt start_dek then dek_since_start = ((current_dek + 36) - start_dek) +1 $
      else dek_since_start = (current_dek - start_dek) +1
   cur_gt = BYTARR(SA_x,SA_y) 	; set the length of growth for current season
   bad_locs = where(current_sos eq 60 OR SA_LGP eq 0, count_bad, COMPLEMENT=good_locs, NCOMPLEMENT=count_good)
   if count_bad gt 0 then $
      cur_gt(bad_locs) = 60
   if count_good gt 0 then begin
      for i=LONG(0),count_good-1 do begin
         tmp_sos = current_sos[good_locs[i]]
	 tmp_cgt = dek_since_start - tmp_sos
	 if tmp_cgt gt SA_LGP[good_locs[i]] then $
	    tmp_cgt = SA_LGP[good_locs[i]]
	 if tmp_cgt le 0 then begin
	    cur_gt[good_locs[i]] = 60
	 endif else begin
            cur_gt[good_locs[i]] = tmp_cgt
	    tmpxy = ARRAY_INDICES(current_sos,good_locs)       ; find the x/y pairs for all good_locs
	    current_accum[good_locs[i]] = $
	       SCREEN_TOTAL(rain4d(tmpxy[0,i],tmpxy[1,i],nyrs-2,tmp_sos:tmp_sos+tmp_cgt-1)) 
	 endelse
      endfor
   endif

   ; read in the simulated endings
   sim_ends = FLTARR(NX,NY,nsims)
   close,1
   openr,1,STRING(FORMAT='("simulated_ends.",I2.2,I1.1)',month[t],dekad[t])
   readu,1,sim_ends
   close,1

   ; combine simulated endings with season-to-date and get PON
   sim_ssns = FLTARR(NX,NY,nsims)
   sim_pon = FLTARR(NX,NY,nsims)
   for i=0,nsims-1 do begin 
      sim_ssns[*,*,i] = current_accum + sim_ends[*,*,i]
      sim_pon[*,*,i] = sim_ssns[*,*,i] / ssnave
   endfor

   ; get counts of different thresholds
   lo_thresh = 0.85		; set low threshold
   hi_thresh = 1.15		; set high threshold
   NumBelow,sim_pon,lo_thresh,lo_count,lo_cube		; get count below lo_thresh
   NumAbove,sim_pon,hi_thresh,hi_count,hi_cube		; get count above hi_thresh
   mid_count = nsims - (lo_count + hi_count) 		; get count between the two
   ; cancel out years without a defined LGP
   lo_count(where(cur_gt eq 60)) = !VALUES.F_NAN
   mid_count(where(cur_gt eq 60)) = !VALUES.F_NAN
   hi_count(where(cur_gt eq 60)) = !VALUES.F_NAN

   close,1
   openw,1,STRING(FORMAT='("PON_counts.",I2.2,I1.1)',month[t],dekad[t])
   writeu,1,[[[lo_count]],[[mid_count]],[[hi_count]]]
   close,1

endfor

;;; classify the counts in to the triangles and make an image

   p_most = 2./3.		; hi probability for legend division
   p_least = 1./3.		; lo probability for legend division
   most_cut = p_most * nsims	; hi number cutoff
   least_cut = p_least * nsims	; lo number cutoff
   ct_cube = FLTARR(NX,NY,3)

   ; some mapping stuff
   t_colors = [[232, 232,  54],[235, 125, 134],[243, 243, 147], $
               [133, 197, 156],[221,  17,  86],[227,  64, 139], $
               [138, 127, 183],[ 79, 177, 202],[ 25, 106, 154]]
   map_ulx = -20.05 + (ulx * 0.1)
   map_lrx = -20.05 + (lrx * 0.1)
   map_uly = 40.05 - (uly * 0.1)
   map_lry = 40.05 - (lry * 0.1)

   ; now read in the data and map it
for t=0,17 do begin
   close,1
   openr,1,STRING(FORMAT='("PON_counts.",I2.2,I1.1)',month[t],dekad[t])
   readu,1,ct_cube
   close,1

   t_class = BYTARR(NX,NY)
   
   ; set the triangle for each class
   t_class(where(ct_cube[*,*,1] ge most_cut)) = 1
   t_class(where(ct_cube[*,*,1] lt most_cut AND ct_cube[*,*,1] ge least_cut AND $
                 ct_cube[*,*,0] lt most_cut AND ct_cube[*,*,0] ge least_cut AND $
		 ct_cube[*,*,2] lt least_cut)) = 2
   t_class(where(ct_cube[*,*,1] lt most_cut AND ct_cube[*,*,1] ge least_cut AND $
                 ct_cube[*,*,0] lt least_cut AND ct_cube[*,*,2] lt least_cut)) = 3
   t_class(where(ct_cube[*,*,1] lt most_cut AND ct_cube[*,*,1] ge least_cut AND $
                 ct_cube[*,*,2] lt most_cut AND ct_cube[*,*,2] ge least_cut AND $
                 ct_cube[*,*,0] lt least_cut)) = 4
   t_class(where(ct_cube[*,*,0] ge most_cut)) = 5
   t_class(where(ct_cube[*,*,0] lt most_cut AND ct_cube[*,*,0] ge least_cut AND $
                 ct_cube[*,*,1] lt least_cut AND ct_cube[*,*,2] lt least_cut)) = 6
   t_class(where(ct_cube[*,*,0] lt most_cut AND ct_cube[*,*,0] ge least_cut AND $
                 ct_cube[*,*,2] lt most_cut AND ct_cube[*,*,2] ge least_cut AND $
                 ct_cube[*,*,1] lt least_cut)) = 7
   t_class(where(ct_cube[*,*,2] lt most_cut AND ct_cube[*,*,2] ge least_cut AND $
                 ct_cube[*,*,0] lt least_cut AND ct_cube[*,*,1] lt least_cut)) = 8
   t_class(where(ct_cube[*,*,2] ge most_cut)) = 9

   wmap = IMAGE(CONGRID(t_class,2*NX,2*NY), $
             IMAGE_DIMENSIONS=[FLOAT(NX)/10.0,FLOAT(NY)/10.0], IMAGE_LOCATION=[map_ulx,map_lry], $
             DIMENSIONS=[2.5*NX,2.5*NY],AXIS_STYLE=2,GRID_UNITS=2, $
             RGB_TABLE=[[255,255,255],[t_colors]],/ORDER, $
             FONT_SIZE=20,TITLE=STRING(FORMAT='(''Scenario Forecast Month='',I2.2,'' Dekad='',I1.1)',month[t],dekad[t]))
   map = MAP('Geographic', $
     ;LIMIT = [map_lry, map_ulx, map_uly, map_lrx], $
     LIMIT = [-35.0, map_ulx, map_uly, map_lrx], $
     /OVERPLOT)
   map.mapgrid.linestyle = 6; 'dotted'
   map.mapgrid.label_show = 0;	turn off labels
   ;map.mapgrid.color = [150, 150, 150]
   ;map.mapgrid.label_position = 0
   ;map.mapgrid.label_color = 'black'
   ;map.mapgrid.FONT_SIZE = 10

   m1 = MAPCONTINENTS(/COUNTRIES, $
     COLOR = [0, 0, 0], THICK=2, $
     FILL_BACKGROUND = 0)

   wmap.save,STRING(FORMAT='(''tri_map.'',I2.2,I1.1,''.png'')',month[t],dekad[t]),RESOLUTION=200,/TRANSPARENT
endfor
