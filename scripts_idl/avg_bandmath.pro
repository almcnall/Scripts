PRO avg_bandmath, month

;allows IDL to run ENVI functions, w/o opening ENVI

COMPILE_OPT strictarr
ENVI, /RESTORE_base_save_files
envi_batch_init

;sets the working directory and other directoris for reading and writing

dir = '/jower/LIS/Code/src/OUTPUT/Zoundsb/NOAH/monthly/'

;intializes the variables

nx = 301 ;# of columns
ny = 321 ;# of rows
year = 2009

IF month = 1 OR month = 2 OR month = 3 OR month = 4 THEN year = year + 1

;retrieves CVMVC(MVC) array cubes by composite period
fnames = strcompress(dir + 'evap_' + STRING(format = '(I4.4,I2.2)',year,month) + '.img', /remove_all)
print,fnames

nz = fix((n_elements(fnames)/(nx*ny)) ;# of composite periods

;intializes the arrays

NDVIf = FLTARR(nx, ny, nz)
nave = FLTARR(nx, ny)


  close, 1
  openr, 1, fnames
  readu, 1, NDVIf
  close, 1

FOR i = 0, nx - 1 DO BEGIN

  FOR j = 0, ny - 1 DO BEGIN

    nave[i, j] = mean(NDVIf[i, j, *], /NAN)

  ENDFOR

ENDFOR

;writes composite to new .bsq + ENVI header file

out_n = strcompress(dir + STRING(format = '(''savhrrave'', I2.2)', comp), /remove_all)

close, 2
openw, 2, out_n
writeu, 2, nave
close, 2

;assigns ENVI header

envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1(byte), 2(int), 4(float)
descrip = 'SAVI Float + NAN (Cube = Comp #)', $
file_type = 0, fname = out_n, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
map_info=map_info, $
DEF_BANDS=[0], $
/WRITE

END