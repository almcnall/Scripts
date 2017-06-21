;;; THIS PROGRAM IS A WORKSHEET DESIGNED TO MAKE THE TRIVARIATE
;;; LEGEND IN IDL NEW GRAPHICS

; THE BIG TRIANGLE IS AN EQUILATERAL TRIANGLE WITH VERTICES AT
; (0,0), (1,0) AND (0.5,0.866025)

; set scale to make the big triangle bigger/smaller and x/y offsets
t_scl = 0.9
x_off = 0.05
y_off = 0.1
; define the vertices of the outer triangle
hiy = SQRT(0.75)	; defines the height of the triangle
bigx = [0.0, 0.5, 1.0]
bigy = [0.0, hiy, 0.0]

w = WINDOW(WINDOW_TITLE='Test Tri',DIMENSIONS = [600,600],MARGIN=0.1)
bigt = POLYLINE(bigx*t_scl+x_off,bigy*t_scl+y_off, $
       CONNECTIVITY = [4,0,1,2,0], THICK = 3 , COLOR = 'Gray')

; define the vertices of the 9 inner triangles moving from top-bottom
; left-right.  vertices always defined moving left-right regardless of y
yrows = [hiy,2. * hiy / 3., hiy / 3., 0] ;y-vertices from top to bottom
lilx = [[1./3.,1./2.,2./3.],[1./6.,1./3.,1./2.],[1./3.,1./2.,2./3.], $
        [1./2.,2./3.,5./6.],[0.,   1./6.,1./3.],[1./6.,1./3.,1./2.], $
        [1./3.,1./2.,2./3.],[1./2.,2./3.,5./6.],[2./3.,5./6.,1.   ]]
lily = [[yrows[1],yrows[0],yrows[1]],[yrows[2],yrows[1],yrows[2]],[yrows[1],yrows[2],yrows[1]], $
        [yrows[2],yrows[1],yrows[2]],[yrows[3],yrows[2],yrows[3]],[yrows[2],yrows[3],yrows[2]], $
        [yrows[3],yrows[2],yrows[3]],[yrows[2],yrows[3],yrows[2]],[yrows[3],yrows[2],yrows[3]]]
for i=0,8 do !null = POLYLINE(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off, $
                     CONNECTIVITY=[4,0,1,2,0],THICK=3,COLOR='gray')

; define the triangle colors and fill them in
t_colors = [[232, 232,  54],[235, 125, 134],[243, 243, 147], $
            [133, 197, 156],[221,  17,  86],[227,  64, 139], $
            [138, 127, 183],[ 79, 177, 202],[ 25, 106, 154]] 
; fill in fully filled triangles
w = WINDOW(WINDOW_TITLE='Test Tri',DIMENSIONS = [600,600],MARGIN=0.1)
for i=0,8 do !null = POLYGON(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off, $
                     FILL_COLOR=t_colors[*,i],THICK=3,COLOR='gray')

; define the centerpoints of each small triangle
; first, the linear centerpoints...between each row/column
cenx = [1./2.,1./3.,1./2.,2./3.,1./6.,1./3.,1./2.,2./3.,5./6.]
ceny = [5.*hiy/6.,hiy/2.,hiy/2.,hiy/2.,hiy/6.,hiy/6.,hiy/6.,hiy/6.,hiy/6.]
; now the triangle centroids (only y values are different)
xroid = [1./2.,1./3.,1./2.,2./3.,1./6.,1./3.,1./2.,2./3.,5./6.]
yroid = [yrows[1]+tan(!PI/6)*(1./6.),yrows[2]+tan(!PI/6)*(1./6.),yrows[1]-tan(!PI/6)*(1./6.), $
         yrows[2]+tan(!PI/6)*(1./6.),yrows[3]+tan(!PI/6)*(1./6.),yrows[2]-tan(!PI/6)*(1./6.), $
	 yrows[3]+tan(!PI/6)*(1./6.),yrows[2]-tan(!PI/6)*(1./6.),yrows[3]+tan(!PI/6)*(1./6.)]
	 
fill_fracs =[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
; draw triangles with all triangles plotted from their centroid
w = WINDOW(WINDOW_TITLE='Test Tri',DIMENSIONS = [600,600],MARGIN=0.1)
for i=0,8 do begin
   dump = little_tri_fill(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off,fill_fracs[i], $
          TXCEN=xroid[i]*t_scl+x_off,TYCEN=yroid[i]*t_scl+y_off, $
	  TXFILL=XFILLS,TYFILL=YFILLS)
   !null = POLYGON(xfills,yfills, $
                   FILL_COLOR=t_colors[*,i],LINESTYLE=6)
   !null = POLYLINE(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off, $
                   CONNECTIVITY=[4,0,1,2,0],THICK=3,COLOR='gray')
endfor
; draw traingles with centerpoint on the same y-value for all in a row
w = WINDOW(WINDOW_TITLE='Test Tri',DIMENSIONS = [600,600],MARGIN=0.1)
for i=0,8 do begin
   dump = little_tri_fill(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off,fill_fracs[i], $
          TXFILL=XFILLS,TYFILL=YFILLS)
   !null = POLYGON(xfills,yfills, $
                   FILL_COLOR=t_colors[*,i],LINESTYLE=6)
   !null = POLYLINE(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off, $
                   CONNECTIVITY=[4,0,1,2,0],THICK=3,COLOR='gray')
endfor

;add hashes and axis titles
hashl = 0.03	; hash length
hashx = [[1./6.,1./6.-hashl],      [1./3.,1./3.-hashl],      [2./3.,2./3.+(0.5*hashl)], $
         [5./6.,5./6.+(0.5*hashl)],[2./3.,2./3.+(0.5*hashl)],[1./3.,1./3.+(0.5*hashl)]]
hashy = [[yrows[2],yrows[2]],            [yrows[1],yrows[1]],            [yrows[1],yrows[1]+(hiy*hashl)], $
         [yrows[2],yrows[2]+(hiy*hashl)],[yrows[3],yrows[3]-(hiy*hashl)],[yrows[3],yrows[3]-(hiy*hashl)]]
for i=0,5 do $
   !null = POLYLINE(hashx[*,i]*t_scl+x_off,hashy[*,i]*t_scl+y_off, $
           THICK=3,COLOR='gray')

axis_lab = ['Least Likely','Somewhat Likely','Most Likely']

;;AMY'S Soil moisture percentiles;;;;;
w = WINDOW(WINDOW_TITLE='Test Tri',DIMENSIONS = [600,600],MARGIN=0.1)
for i=0,8 do !null = POLYGON(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off, $
  FILL_COLOR=t_colors[*,i],THICK=3,COLOR='gray')
for i=0,5 do $
  !null = POLYLINE(hashx[*,i]*t_scl+x_off,hashy[*,i]*t_scl+y_off, $
  THICK=3,COLOR='gray')

n_lab = TEXT(([0.,1.,2.]/6. + (0.8/12.))*t_scl+x_off,([hiy/6.,hiy/2.,5.*hiy/6.])*t_scl+y_off, $
  axis_lab,BASELINE=[0.5,hiy,0.0],COLOR='gray', ALIGNMENT=0.5, FONT_SIZE=FIX(20.*t_scl))
a_lab = TEXT(([0.,1.,2.]/6. + (7.2/12.))*t_scl+x_off,([5.*hiy/6.,hiy/2.,hiy/6.])*t_scl+y_off, $
  axis_lab,BASELINE=[0.5,-1*hiy,0.0],COLOR=[25,106,154], ALIGNMENT=0.5, FONT_SIZE=FIX(20.*t_scl))
b_lab = TEXT(([2.,1.,0.]/3. + (1./6.))*t_scl+x_off,([-0.04,-0.04,-0.04])*t_scl+y_off, $
  axis_lab,COLOR=[221,17,86], ALIGNMENT=0.5, FONT_SIZE=FIX(20.*t_scl))
n_title = TEXT((1./6.)*t_scl+x_off,(hiy/2.)*t_scl+y_off,'NORMAL: 33 %ile < SM < 67 %ile', $
  BASELINE=[0.5,hiy,0.0],COLOR='gray', ALIGNMENT=0.5, FONT_SIZE=FIX(25.*t_scl))
a_title = TEXT((5./6.)*t_scl+x_off,(hiy/2.)*t_scl+y_off,'WET: SM > 67 %ile', $
  BASELINE=[0.5,-1*hiy,0.0],COLOR=[25,106,154], ALIGNMENT=0.5, FONT_SIZE=FIX(25.*t_scl))
b_title = TEXT((1./2.)*t_scl+x_off,(-0.1)*t_scl+y_off,'DRY: SM < 33 %ile', $
  COLOR=[221,17,86], ALIGNMENT=0.5, FONT_SIZE=FIX(25.*t_scl))
t_labels = TEXT([1./2.,1./6.,5./6.]*t_scl+x_off,([yrows[1],yrows[3],yrows[3]]+hiy/9.)*t_scl+y_off, $
  ['NORMAL','DRY','WET'], VERTICAL_ALIGNMENT=0.8,ALIGNMENT=0.5,FONT_SIZE=FIX(25.*t_scl))

; GREG'S RAINFALL ANALYSIS label the normal axis
;w = WINDOW(WINDOW_TITLE='Test Tri',DIMENSIONS = [600,600],MARGIN=0.1)
;for i=0,8 do !null = POLYGON(lilx[*,i]*t_scl+x_off,lily[*,i]*t_scl+y_off, $
;                     FILL_COLOR=t_colors[*,i],THICK=3,COLOR='gray')
;for i=0,5 do $
;   !null = POLYLINE(hashx[*,i]*t_scl+x_off,hashy[*,i]*t_scl+y_off, $
;           THICK=3,COLOR='gray')
;
;   n_lab = TEXT(([0.,1.,2.]/6. + (0.8/12.))*t_scl+x_off,([hiy/6.,hiy/2.,5.*hiy/6.])*t_scl+y_off, $
;                axis_lab,BASELINE=[0.5,hiy,0.0],COLOR='gray', ALIGNMENT=0.5, FONT_SIZE=FIX(20.*t_scl)) 
;   a_lab = TEXT(([0.,1.,2.]/6. + (7.2/12.))*t_scl+x_off,([5.*hiy/6.,hiy/2.,hiy/6.])*t_scl+y_off, $
;               axis_lab,BASELINE=[0.5,-1*hiy,0.0],COLOR=[25,106,154], ALIGNMENT=0.5, FONT_SIZE=FIX(20.*t_scl)) 
;   b_lab = TEXT(([2.,1.,0.]/3. + (1./6.))*t_scl+x_off,([-0.04,-0.04,-0.04])*t_scl+y_off, $
;                axis_lab,COLOR=[221,17,86], ALIGNMENT=0.5, FONT_SIZE=FIX(20.*t_scl)) 
;   n_title = TEXT((1./6.)*t_scl+x_off,(hiy/2.)*t_scl+y_off,'NORMAL: 85% < Rain < 115%', $
;                  BASELINE=[0.5,hiy,0.0],COLOR='gray', ALIGNMENT=0.5, FONT_SIZE=FIX(25.*t_scl))
;   a_title = TEXT((5./6.)*t_scl+x_off,(hiy/2.)*t_scl+y_off,'WET: Rain > 115%', $
;                  BASELINE=[0.5,-1*hiy,0.0],COLOR=[25,106,154], ALIGNMENT=0.5, FONT_SIZE=FIX(25.*t_scl))
;   b_title = TEXT((1./2.)*t_scl+x_off,(-0.1)*t_scl+y_off,'DRY: Rain < 85%', $
;                  COLOR=[221,17,86], ALIGNMENT=0.5, FONT_SIZE=FIX(25.*t_scl))
;   t_labels = TEXT([1./2.,1./6.,5./6.]*t_scl+x_off,([yrows[1],yrows[3],yrows[3]]+hiy/9.)*t_scl+y_off, $
;                   ['NORMAL','DRY','WET'], VERTICAL_ALIGNMENT=0.8,ALIGNMENT=0.5,FONT_SIZE=FIX(25.*t_scl))


