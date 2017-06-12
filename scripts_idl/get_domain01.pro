function get_domain01, domain

    ;this function cleans up the parameters for the different
    ;domains at 0.1 degrees.

    ;West Africa (5.35 N - 17.65 N; 18.65 W - 25.85 E)
    ; west africa domain
    if domain eq 'WA' then begin
      map_ulx = -18.65
      map_lrx = 25.85
      map_uly = 17.65
      map_lry = 5.35
    endif
    
    ;East Africa WRSI/Noah window
    if domain eq 'EA' then begin
      map_ulx = 22.
      map_lrx = 51.35
      map_uly = 22.95 
      map_lry = -11.75
    endif
    
    ;Southern Africa WRSI/Noah window
    ;Southern Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E)
    ;NX = 486, NY = 443
    if domain eq 'SA' then begin
      map_ulx = 6.05
      map_lrx = 54.55
      map_uly = 6.35
      map_lry = -37.85
    endif
    
    ;Continental Africa (37.85 S - 6.35 N; 6.05 E - 54.55 E)
    ;SOUTH_WEST_CORNER_LAT = -39.95f ;
    ;SOUTH_WEST_CORNER_LON = -20.05f ;
    ;Run domain lower left lat:         -39.950
    ;Run domain lower left lon:         -20.050
    ;Run domain upper right lat:         39.950
    ;Run domain upper right lon:         54.950
    ;NX = 751, NY = 800
    if domain eq 'AF' then begin
      map_ulx = -20.050
      map_lrx = 54.95
      map_uly = 39.95
      map_lry = -39.95
    endif

    ulx = (180.+ map_ulx)*10.
    lrx = (180.+ map_lrx)*10.-1
    uly = (50.- map_uly)*10. 
    lry = (50.- map_lry)*10.-1
    NX = lrx - ulx + 2
    NY = lry - uly + 2
    
    params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry, ulx, lrx, uly, lry]
    return, params

END