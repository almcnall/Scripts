function get_domain25, domain

    ;this function cleans up the parameters for the different
    ;domains at 0.25 degrees.

    ;West Africa (5.35 N - 17.65 N; 18.65 W - 25.85 E)
    ;  map_ulx = -17.125 & map_lrx = 25.625
    ;  map_uly = 17.875 & map_lry = 5.125
    if domain eq 'WA' then begin
      map_ulx = -17.125
      map_lrx = 25.625
      map_uly = 17.875
      map_lry = 5.125
    endif
    
    ;East Africa VIC
    if domain eq 'EA' then begin
      map_ulx = 21.875
      map_lrx = 51.125
      map_uly = 23.125
      map_lry = -11.875
    endif
    
    ;Southern Africa
    ;map_ulx = 5.875 & map_lrx = 51.125
    ;map_uly = 6.625 & map_lry = -34.625
    ;NX = 486, NY = 443
    if domain eq 'SA' then begin
      map_ulx = 5.875
      map_lrx = 51.125
      map_uly = 6.625
      map_lry = -34.625
    endif

    ulx = (180.+ map_ulx)*4.
    lrx = (180.+ map_lrx)*4.-1
    uly = (50.- map_uly)*4. 
    lry = (50.- map_lry)*4.-1
    NX = lrx - ulx + 2
    NY = lry - uly + 2
    
    params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
    return, params

END