;;;WORKSHEET FOR ANALYSIS OF SCENARIOS
;; greg husak's original code in worksheet.pro
;; 1/30/17 revisit for routine ESP...get countmap from make_countmap.pro, or readin.
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;this number varies based
;e.g. CHIRPS January = 1054 = 31days*34yrs
nsims = n_elements(ifile)+16

;;; classify the counts in to the triangles and make an image

   p_most = 2./3.		; hi probability for legend division
   p_least = 1./3.	; lo probability for legend division
   p_mhi = 0.412      ;middle triangle from 30-40%
   p_mlow = 0.235
   most_cut = p_most * nsims	; hi number cutoff
   least_cut = p_least * nsims	; lo number cutoff
   clow_cut = p_mlow * nsims    ;low range of climatology
   chigh_cut = p_mhi * nsims    ;high range of climatology
   
   ct_cube = FLTARR(NX,NY,3)

   ; some mapping stuff
   ;bright yellow, soft red, very soft yellow, 
   ;           cyan-lime yellow, vivid pink, bright pink, 
   ;           dsaturated blue, moderate cyan, dark blue, white smoke
   t_colors = [[232, 232,  54],[235, 125, 134],[243, 243, 147], $
               [133, 197, 156],[221,  17,  86],[227,  64, 139], $
               [138, 127, 183],[ 79, 177, 202],[ 25, 106, 154], [192,192,192] ]

   ; now read in the data and map it
   ;;rangeland mask for SM01
   indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
   mfile_E = file_search(indir+'lis_input_ea_elev.nc')

   VOI = 'LANDCOVER'
   LC = get_nc(VOI, mfile_E)
   range = where(LC[*,*,6] gt 0.1, complement=other)
   Emask = bytarr(NX,NY)+1.0
   Emask(other) = !values.f_nan
   Emask(range) = 1
   
   emask3 = rebin(emask, nx, ny, 3)
   
   help, countmap
   
   ct_cube = countmap*emask3
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
   ;if they are 33,33,33 +/-
   t_class(where(ct_cube[*,*,0] ge clow_cut AND ct_cube[*,*,1] ge clow_cut AND ct_cube[*,*,2] ge clow_cut AND $
                ct_cube[*,*,0] le chigh_cut AND ct_cube[*,*,1] le chigh_cut AND ct_cube[*,*,2] le chigh_cut  )) = 10
           

;;can this be plotted with the EA_plots script?
   wmap = IMAGE(CONGRID(t_class,2*NX,2*NY), $
             IMAGE_DIMENSIONS=[FLOAT(NX)/10.0,FLOAT(NY)/10.0], IMAGE_LOCATION=[map_ulx,map_lry], $
             DIMENSIONS=[2.5*NX,2.5*NY],AXIS_STYLE=2,GRID_UNITS=2, $
             RGB_TABLE=[[255,255,255],[t_colors]], $
             FONT_SIZE=2)
   map = MAP('Geographic', $
     LIMIT = [map_lry, map_ulx, map_uly, map_lrx], $
     ;LIMIT = [-35.0, map_ulx, map_uly, map_lrx], $
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
   wmap.title = 'prob of wet/avg/dry June 1, weight 2004, 2012 grey 24-41%'
   wmap.save, '/home/almcnall/IDLplots/test_ESP.png'
;endfor


