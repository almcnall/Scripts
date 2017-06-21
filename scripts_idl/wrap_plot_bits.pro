 wrap_plot_bits
; this program doesn't work but has good stuff in it re:re-centering an image
; plotting it and figuring out where the countries,lat/lon are supposed to be. 
; 

file_mkdir,outdir

cd, indir
infile = file_search('*.1gd4r')
nfile  = n_elements(infile)

inx  = 1440.
iny  = 480.
outx = 301.
outy = 321.

globe     = fltarr(inx,iny)
africa    = fltarr(outx,outy)
data_in   = fltarr(inx,iny,nfile)
stack     = fltarr(inx,iny)
glb_shift = fltarr(inx,iny)

 for i=0,n_elements(infile)-1 do begin
   ;i=0
   openu,1,infile[i]
   readu,1,globe                                ;persiann data starting at 0.125 deg chopping africa
   byteorder,globe,/XDRTOF
   ;this shift isn't needed for subsetting africa
   glb_shift=[globe(720:1439,*),globe(0:719,*)] ;concatinates half the globe to 1st half
   data_in[*,*,i] = glb_shift
   close, /all
 endfor  
 
 data_in(where(data_in lt 0)) = 9999 ;
 average_small, data_in, rgrid       ;This procedure computes the AVERAGE of a the nk
                                     ;fields stored in the array tab (nbcol,nblign,nk).

 for x=0,inx-1 do for y=0,iny-1 do begin
   stack[x,y]  = mean(data_in[x,y,*],/NAN) 
 endfor     

 stack[*,*] = REVERSE(stack[*,*],2)
 
 ofile = strcompress(+outdir+'/stacked.img', /remove_all)
 print, ofile
 ;openw, 2,ofile
 ;writeu,2,stack
 
  mve,stack                 ;print out the max min mean and std deviation of var
 rgrid = reverse(stack,2)  ;IDL reads from bottom to top, needs to be reversed to plot
 
 window,1,xsize=1440, ysize=480
 pos1 = [.05,.05,.91,.95] ;for full window
 loadct,1,rgb_table=tmpct ;34 is rainbow
 tmpct = reverse(tmpct,1) ;this is my color bar
 tvlct,tmpct 
 
 tvim,rgrid, title='global rain avg ', range=[0,430,10], /scale, lcharsize=1.8, /noframe, pos = pos1
 map_set,0,0,/cont,/cyl,limit=[-59.875,0,58.875,360],/noerase,/noborder,mlinethick=2,color=100, pos=pos1
 
; map_set, 0,0,/cont,/cyl,limit=[-19.5,30,-8,42.75],/noerase, /noborder,pos=pos1, mlinethick=1,& 
;             color=125
map_continents, /countries, color=125,   mlinethick=2
 
 ;close, /all

 end
 
 
  pos1 = [.05,.55,.91,.95] ;for half window
  pos2 = [.05,.05,.91,.50] ;for half window
 
 !p.multi=[0,1,2] ;for multiple windows
 ERASE
 ;range sets display colors, check the min/max/mean with mve
  tvim,data_IN(*,*,70), title='global WRAPPED ', range=[0,430,50], /scale, lcharsize=1.8, /noframe   , pos = pos1
  map_set,0,180,/cont,/cyl,limit=[-60,-0,60,360],/noerase,/noborder,mlinethick=2,color=100, pos=pos1
  
 
  tvim,globe, title='global INPUT ', range=[0,430,50], /scale, lcharsize=1.8, /noframe  , pos = pos2
  map_set,0,0,/cont,/cyl,limit=[-60,-180,60,180],/noerase,/noborder,mlinethick=2,color=100, pos=pos2
  
  
  AfrL = globe(1360:1439,80:399)
  AfrR = globe(0:219,80:399)
  Afr = [AfrL, AfrR]
  
  Afr = [globe(1360:1439,80:399), globe(0:219,80:399)]
  
  pos1 = [.05,.05, .6,.95]
  tvim,Afr, title='Africa ', range=[0,430,50], /scale, lcharsize=1.8, /noframe  , pos = pos1
   map_set,0,0,/cont,/cyl,limit=[-40,-20,40,55],/noerase,/noborder,mlinethick=2,color=100, pos=pos1
  
  
  
 