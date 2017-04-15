xv = FINDGEN(11) / 10.
yv = FINDGEN(11) / 10.
;bigx = [MIN(xverts),MAX(xverts)]
;bigy = [MIN(yverts),MAX(yverts)]
bigx = [0.0,0.0,1.0]
bigy = [0.0,1.0,0.0]

; get colors for each
tmp = IMAGE(dist(255),RGB_TABLE=49,/BUFFER) & tmprgb = tmp.rgb_table
wcolor = tmprgb[*,xv*200]
tmp = IMAGE(dist(255),RGB_TABLE=62,/BUFFER) & tmprgb = tmp.rgb_table
dcolor = tmprgb[*,xv*200]
tmp = IMAGE(dist(255),RGB_TABLE=53,/BUFFER) & tmprgb = tmp.rgb_table
ncolor = tmprgb[*,xv*200]

w = WINDOW(WINDOW_TITLE='Test Tri',DIMENSIONS = [600,600],MARGIN=0.1)
!null = PLOT([0.0,1.0,1.0,0.0],[0.0,0.0,1.0,1.0],/NODATA,AXIS_STYLE=1,/CURRENT, $
  XTITLE='Probability of Above-Normal',YTITLE='Probability of Below-Normal', $
  XTICKVALUES=xv, YTICKVALUES=yv, XTICKLEN=0, YTICKLEN=0, XCOLOR='Gray', YCOLOR='Gray', $
  XTEXT_COLOR='Black', YTEXT_COLOR='Black')
bigt = POLYLINE(bigx,bigy, '-', CONNECTIVITY=[4,0,1,2,0], THICK=2, COLOR='Gray',/OVERPLOT,/DATA)

; make the wet polygons
for i=10,6,-1 do !null = POLYGON([xv[i],xv[i-1],xv[i-1],xv[i]], $
  [0,0,1.0-xv[i-1],1.0-xv[i]],THICK=2,COLOR='Gray',/DATA,FILL_COLOR=wcolor[*,i])
i=5 & !null = POLYGON([xv[i],xv[i-1],xv[i-1],xv[i]], $
  [0,0.2,xv[i-1],1.0-xv[i]],THICK=2,COLOR='Gray',/DATA,FILL_COLOR=wcolor[*,i])
; make the dry polygons
for i=10,6,-1 do !null = POLYGON([0,0,1.0-yv[i-1],1.0-yv[i]], $
  [yv[i],yv[i-1],yv[i-1],yv[i]],THICK=2,COLOR='Gray',/DATA,FILL_COLOR=dcolor[*,i])
i=5 & !null = POLYGON([0,0.2,yv[i-1],1.0-yv[i]], $
  [yv[i],yv[i-1],yv[i-1],yv[i]],THICK=2,COLOR='Gray',/DATA,FILL_COLOR=dcolor[*,i])
; make the normal polygons
for i=0,4 do !null = POLYGON([0.0,0.0,xv[i+1],xv[i]], [yv[i],yv[i+1],0.0,0.0], $
  THICK=2,COLOR='Gray',/DATA,FILL_COLOR=ncolor[*,10-i])
i=5 & !null = POLYGON([0.0,0.2,xv[i-1],xv[i]], [yv[i],yv[i-1],0.2,0.0], $
  THICK=2,COLOR='Gray',/DATA,FILL_COLOR=ncolor[*,10-i])

;; add colorbars
cbtitle = TEXT(0.73,0.90,'Probability of Dominant Tercile',ALIGNMENT=0.5,FONT_STYLE=1)
cb1 = COLORBAR(RGB_TABLE=dcolor[*,5:10],ORIENTATION=0,/BORDER,POSITION=[0.55,0.85,0.92,0.88],TAPER=0, $
  TICKNAME = STRING(xv[4:10],f='(f3.1)'),TITLE='Below-Normal')
cb1 = COLORBAR(RGB_TABLE=ncolor[*,5:10],ORIENTATION=0,/BORDER,POSITION=[0.55,0.73,0.92,0.76],TAPER=0, $
  TICKNAME = STRING(xv[4:10],f='(f3.1)'),TITLE='Normal')
cb1 = COLORBAR(RGB_TABLE=wcolor[*,5:10],ORIENTATION=0,/BORDER,POSITION=[0.55,0.61,0.92,0.64],TAPER=0, $
  TICKNAME = STRING(xv[4:10],f='(f3.1)'),TITLE='Above-Normal')
