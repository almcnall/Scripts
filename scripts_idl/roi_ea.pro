pro ROI_EA

;;if I want these to match the LVT_TS_locations:
;#names: south, east, north, west
;ALL
;-11.75 22.05 22.95 51.35 1
;HORN
;2.0 43.0 12.0 51.35 1
;EAST
;0.0 22.05 12.0 30.0 1
;MPALA
;0.0 36.0 1.0 37.0 1
;TIGRAY
;13.5 38.5 14.5 39.5 1
;SHEKA
;9.0 35.0 10.0 36.0 1

res = 0.1 ; 0.1 or res
  ;Mpala Kenya:
mpala_xy = fltarr(2)
mpala_xy[0] = FLOOR( (36.8701 - map_ulx)/ res)
mpala_xy[1] = FLOOR( (0.4856 - map_lry) / res)

mpala2_xy = fltarr(2)
mpala2_xy[0] = FLOOR( (37 - map_ulx)/ res)
mpala2_xy[1] = FLOOR( (0.3 - map_lry) / res)

  ;Adwa, tigray region (14,39.4) NDVI has higher freq variation that soil moisture here
tigray_xy = fltarr(2)
tigray_xy[0] = FLOOR( (39 - map_ulx)/ res)
tigray_xy[1] = FLOOR( (14 - map_lry) / res)

  ;Sheka (dense veg), veg is prob not water limited here so anti-correlation
  ;makes more sense. it was even significant neg corr (-0.2) when lagged, I think
sheka_xy = fltarr(2)
sheka_xy[0] = FLOOR( (35.46 - map_ulx)/ res)
sheka_xy[1] = FLOOR( (8.8 - map_lry) / res);9.5 west welga

  ;Bale
bale_xy = fltarr(2)
bale_xy[0] = FLOOR( (39 - map_ulx)/ res)
bale_xy[1] = FLOOR( (7 - map_lry) / res)

  ;Yirol, South Sudan
yirol_xy = fltarr(2)
yirol_xy[0] = FLOOR( (30.26 - map_ulx)/ res)
yirol_xy[1] = FLOOR( (6.6 - map_lry) / res)

;South of Sana, Yemen
;44.319851 E, 15.168454N
wyemen_xy = fltarr(2)
wyemen_xy[0] = FLOOR( (44.32 - map_ulx)/ res)
wyemen_xy[1] = FLOOR( (15.17 - map_lry) / res)
