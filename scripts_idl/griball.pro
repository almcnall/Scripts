;this program extracts grib file data and writes it to binary (ENVI in)

PRO bigboyz, year

;allows IDL to run ENVI functions, w/o opening ENVI

COMPILE_OPT strictarr
ENVI, /RESTORE_base_save_files
envi_batch_init

;sets the working directory and other directories for reading and writing

dir = '/jabber/mifuf/' ;'/jabber/michael/historical/MONTHLY/' ;change to \, for win
cd, dir

;ndir = '/jabber/michael/historical/MONTHLY/NOAHAET/'
vdir = '/jabber/michael/historical/MONTHLY/VICAET/'
;cdir = '/jabber/michael/historical/MONTHLY/CLMAET/'

;initializes parameters and arrays

nx = 360
ny = 150
gulx = -180.0 ;eastings
guly = 90.0 ;northings
LL_res = 1.0 ;pixel size
flag = 9.0*10.0^20.0
newflag = -999.0
;noahETC = FLTARR(nx, ny)
;noahETI = FLTARR(nx, ny)
;noahETS = FLTARR(nx, ny)
;noahET = FLTARR(nx, ny)
;clmETC = FLTARR(nx, ny)
;clmETI = FLTARR(nx, ny)
;clmETS = FLTARR(nx, ny)
;clmET = FLTARR(nx, ny)
vicETC = FLTARR(nx, ny)
vicETI = FLTARR(nx, ny)
vicETS = FLTARR(nx, ny)
vicET = FLTARR(nx, ny)
;noahETC1 = FLTARR(nx, ny)
;noahETI1 = FLTARR(nx, ny)
;noahETS1 = FLTARR(nx, ny)
;noahET1 = FLTARR(nx, ny)
;clmETC1 = FLTARR(nx, ny)
;clmETI1 = FLTARR(nx, ny)
;clmETS1 = FLTARR(nx, ny)
;clmET1 = FLTARR(nx, ny)
vicETC1 = FLTARR(nx, ny)
vicETI1 = FLTARR(nx, ny)
vicETS1 = FLTARR(nx, ny)
vicET1 = FLTARR(nx, ny)

;retrieves map projection information to be assigned to ENVI header

map_info = envi_map_info_create(/geographic, $
datum='WGS-84', $
mc=[0,0,gulx,guly], ps=[LL_res,LL_res], $ ;[0,0] = [x,y] tie points
units=envi_translate_projection_units('Degrees'))

;looks for monthly grib files

;srch_strn = strcompress('gldas.' + STRING(year) + '*noah*.grb', /remove_all)
srch_strv = strcompress('gldas.' + STRING(year) + '*vicwb*.grb', /remove_all)
;srch_strc = strcompress('gldas.' + STRING(year) + '*clm*.grb', /remove_all)

;fnamesn = findfile(srch_strn)
fnamesv = findfile(srch_strv, count = numfiles)
;fnamesc = findfile(srch_strc, count = numfiles)

FOR i = 0, numfiles - 1 DO BEGIN

	IF file_test(fnamesv[i]) THEN BEGIN

		print, fnamesv[i] ;process tracker

		;extracts year and month from file names
		
		first = strpos(fnamesv[i],'s.')
		yrmo = strmid(fnamesv[i],first + 2, 6)
		mo = strmid(fnamesv[i], first + 6, 2)

		;string array out

		;noutc = strcompress('MNOAHETC' + STRING(yrmo) + '.bin', /remove_all)
		;nouti = strcompress('MNOAHETI' + STRING(yrmo) + '.bin', /remove_all)
		;nouts = strcompress('MNOAHETS' + STRING(yrmo) + '.bin', /remove_all)
		voutc = strcompress('MVICETC' + STRING(yrmo) + '.bin', /remove_all)
		vouti = strcompress('MVICETI' + STRING(yrmo) + '.bin', /remove_all)
		vouts = strcompress('MVICETS' + STRING(yrmo) + '.bin', /remove_all)
		;coutc = strcompress('MCLMETC' + STRING(yrmo) + '.bin', /remove_all)
		;couti = strcompress('MCLMETI' + STRING(yrmo) + '.bin', /remove_all)
		;couts = strcompress('MCLMETS' + STRING(yrmo) + '.bin', /remove_all)

		;shell scripts to read .grb files and output them as binary
		
		;NOAHCexe = 'wgrib -s ' + fnamesn[i] + ' | ' + 'grep ":TRANS:"' + ' | ' + 'wgrib -i -bin ' + fnamesn[i] + ' -o ' + noutc 
		;NOAHIexe = 'wgrib -s ' + fnamesn[i] + ' | ' + 'grep ":EVCW:"' + ' | ' + 'wgrib -i -bin ' + fnamesn[i] + ' -o ' + nouti 
		;NOAHSexe = 'wgrib -s ' + fnamesn[i] + ' | ' + 'grep ":EVBS:"' + ' | ' + 'wgrib -i -bin ' + fnamesn[i] + ' -o ' + nouts

		VICCexe = 'wgrib -s ' + fnamesv[i] + ' | ' + 'grep ":TRANS:"' + ' | ' + 'wgrib -i -bin ' + fnamesv[i] + ' -o ' + voutc 
		VICIexe = 'wgrib -s ' + fnamesv[i] + ' | ' + 'grep ":EVCW:"' + ' | ' + 'wgrib -i -bin ' + fnamesv[i] + ' -o ' + vouti 
		VICSexe = 'wgrib -s ' + fnamesv[i] + ' | ' + 'grep ":EVBS:"' + ' | ' + 'wgrib -i -bin ' + fnamesv[i] + ' -o ' + vouts

		;CLMCexe = 'wgrib -s ' + fnamesc[i] + ' | ' + 'grep ":TRANS:"' + ' | ' + 'wgrib -i -bin ' + fnamesc[i] + ' -o ' + coutc 
		;CLMIexe = 'wgrib -s ' + fnamesc[i] + ' | ' + 'grep ":EVCW:"' + ' | ' + 'wgrib -i -bin ' + fnamesc[i] + ' -o ' + couti 
		;CLMSexe = 'wgrib -s ' + fnamesc[i] + ' | ' + 'grep ":EVBS:"' + ' | ' + 'wgrib -i -bin ' + fnamesc[i] + ' -o ' + couts

		;executes shell scripts

		;spawn, NOAHCexe
		;spawn, NOAHIexe
		;spawn, NOAHSexe
		spawn, VICCexe
		spawn, VICIexe
		spawn, VICSexe
		;spawn, CLMCexe
		;spawn, CLMIexe
		;spawn, CLMSexe

		;opens binary files for reading
		
		;close, 1
		;openr, 1, noutc 
		;readu, 1, noahETC
		;close, 1

		;close, 2
		;openr, 2, nouti
		;readu, 2, noahETI
		;close, 2

		;close, 3
		;openr, 3, nouts
		;readu, 3, noahETS
		;close, 3

		close, 4
		openr, 4, voutc 
		readu, 4, vicETC
		close, 4

		close, 5
		openr, 5, vouti
		readu, 5, vicETI
		close, 5

		close, 6
		openr, 6, vouts
		readu, 6, vicETS
		close, 6

		;close, 7
		;openr, 7, coutc 
		;readu, 7, clmETC
		;close, 7

		;close, 8
		;openr, 8, couti
		;readu, 8, clmETI
		;close, 8

		;close, 9
		;openr, 9, couts
		;readu, 9, clmETS
		;close, 9

		;rotates each image in the y direction 180deg
		
		;noahETC = reverse(noahETC, 2)
		;noahETI = reverse(noahETI, 2)
		;noahETS = reverse(noahETS, 2)
		;clmETC = reverse(clmETC, 2)
		;clmETI = reverse(clmETI, 2)
		;clmETS = reverse(clmETS, 2)
		vicETC = reverse(vicETC, 2)
		vicETI = reverse(vicETI, 2)
		vicETS = reverse(vicETS, 2)

		;reassigns flag value
		
		good = 0
		bad = 0
		good = where(vicETC LT flag AND vicETI LT flag AND vicETS LT flag, count, complement = bad) ;noahETC LT flag AND noahETI LT flag AND noahETS LT flag AND clmETC LT flag AND clmETI LT flag AND clmETS LT flag AND 

		IF count GT 100 THEN BEGIN

			;converts mm/s in to mm/day

			;clmETC = 3600.0 * 24.0 * clmETC
			;clmETI = (-1.0) * 3600.0 * 24.0 * clmETI
			;clmETS = 3600.0 * 24.0 * clmETS
			vicETC = 3600.0 * 24.0 * vicETC
			vicETI = 3600.0 * 24.0 * vicETI
			vicETS = 3600.0 * 24.0 * vicETS
			;noahETC = 3600.0 * 24.0 * noahETC
			;noahETI = 3600.0 * 24.0 * noahETI
			;noahETS = 3600.0 * 24.0 * noahETS

			;sums components to get total ET

			;clmET = clmETC + clmETI + clmETS
			vicET = vicETC + vicETI + vicETS
			;noahET = noahETC + noahETI + noahETS

			;assigns new flag

			;noahETC[bad] = newflag
			;noahETI[bad] = newflag
			;noahETS[bad] = newflag
			;noahET[bad] = newflag
			;clmETC[bad] = newflag
			;clmETI[bad] = newflag
			;clmETS[bad] = newflag
			;clmET[bad] = newflag
			vicETC[bad] = newflag
			vicETI[bad] = newflag
			vicETS[bad] = newflag
			vicET[bad] = newflag

			;shifts images to the left by 1 deg	
		
			;clmETC1[0:nx-2,*] = clmETC[1:nx-1,*]
			;clmETC1[nx-1,*] = clmETC[0,*]
			;clmETC1[nx-1,*] = clmETC[0,*]
			;clmETS1[0:nx-2,*] = clmETS[1:nx-1,*]
			;clmETS1[nx-1,*] = clmETS[0,*]
			;clmETS1[nx-1,*] = clmETS[0,*]
			;clmETI1[0:nx-2,*] = clmETI[1:nx-1,*]
			;clmETI1[nx-1,*] = clmETI[0,*]
			;clmETI1[nx-1,*] = clmETI[0,*]
			;clmET1[0:nx-2,*] = clmET[1:nx-1,*]
			;clmET1[nx-1,*] = clmET[0,*]
			;clmET1[nx-1,*] = clmET[0,*]

			vicETC1[0:nx-2,*] = vicETC[1:nx-1,*]
			vicETC1[nx-1,*] = vicETC[0,*]
			vicETC1[nx-1,*] = vicETC[0,*]
			vicETS1[0:nx-2,*] = vicETS[1:nx-1,*]
			vicETS1[nx-1,*] = vicETS[0,*]
			vicETS1[nx-1,*] = vicETS[0,*]
			vicETI1[0:nx-2,*] = vicETI[1:nx-1,*]
			vicETI1[nx-1,*] = vicETI[0,*]
			vicETI1[nx-1,*] = vicETI[0,*]
			vicET1[0:nx-2,*] = vicET[1:nx-1,*]
			vicET1[nx-1,*] = vicET[0,*]
			vicET1[nx-1,*] = vicET[0,*]

			;noahETC1[0:nx-2,*] = noahETC[1:nx-1,*]
			;noahETC1[nx-1,*] = noahETC[0,*]
			;noahETC1[nx-1,*] = noahETC[0,*]
			;noahETS1[0:nx-2,*] = noahETS[1:nx-1,*]
			;noahETS1[nx-1,*] = noahETS[0,*]
			;noahETS1[nx-1,*] = noahETS[0,*]
			;noahETI1[0:nx-2,*] = noahETI[1:nx-1,*]
			;noahETI1[nx-1,*] = noahETI[0,*]
			;noahETI1[nx-1,*] = noahETI[0,*]
			;noahET1[0:nx-2,*] = noahET[1:nx-1,*]
			;noahET1[nx-1,*] = noahET[0,*]
			;noahET1[nx-1,*] = noahET[0,*]

			;assigns string array for writting	

			;noutc1 = strcompress(ndir + 'MNOAH' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aetc', /remove_all)
			;nouti1 = strcompress(ndir + 'MNOAH' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aeti', /remove_all)
			;nouts1 = strcompress(ndir + 'MNOAH' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aets', /remove_all)
			;nout1 = strcompress(ndir + 'MNOAH' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aet', /remove_all)
			voutc1 = strcompress(vdir + 'MVIC' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aetc', /remove_all)
			vouti1 = strcompress(vdir + 'MVIC' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aeti', /remove_all)
			vouts1 = strcompress(vdir + 'MVIC' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aets', /remove_all)
			vout1 = strcompress(vdir + 'MVIC' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aet', /remove_all)
			;coutc1 = strcompress(cdir + 'MCLM' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aetc', /remove_all)
			;couti1 = strcompress(cdir + 'MCLM' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aeti', /remove_all)
			;couts1 = strcompress(cdir + 'MCLM' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aets', /remove_all)
			;cout1 = strcompress(cdir + 'MCLM' + STRING(format='(I4.4,I2.2)', year, i + 1) + '.aet', /remove_all)
			
			;close, 10
			;openw, 10, noutc1
			;writeu, 10, noahETC1
			;close, 10
	
			;close, 11
			;openw, 11, nouti1
			;writeu, 11, noahETI1
			;close, 11
	
			;close, 12
			;openw, 12, nouts1
			;writeu, 12, noahETS1
			;close, 12

			;close, 13
			;openw, 13, nout1
			;writeu, 13, noahET1
			;close, 13
	
			close, 14
			openw, 14, voutc1
			writeu, 14, vicETC1
			close, 14
	
			close, 15
			openw, 15, vouti1
			writeu, 15, vicETI1
			close, 15
	
			close, 16
			openw, 16, vouts1
			writeu, 16, vicETS1
			close, 16

			close, 17
			openw, 17, vout1
			writeu, 17, vicET1
			close, 17

			;close, 18
			;openw, 18, coutc1
			;writeu, 18, clmETC1
			;close, 18
	
			;close, 19
			;openw, 19, couti1
			;writeu, 19, clmETI1
			;close, 19
	
			;close, 20
			;openw, 20, couts1
			;writeu, 20, clmETS1
			;close, 20

			;close, 21
			;openw, 21, cout1
			;writeu, 21, clmET1
			;close, 21
	
			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average Canopy AET -- NOAH (mm/day)', $
			;file_type = 0, fname = noutc1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE	
	
			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average Wet Canopy AET -- NOAH (mm/day)', $
			;file_type = 0, fname = nouti1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE	
	
			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average Soil AET -- NOAH (mm/day)', $
			;file_type = 0, fname = nouts1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE

			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average AET -- NOAH (mm/day)', $
			;file_type = 0, fname = nout1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE		
	
			envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			descrip = 'Monthly Average Canopy AET -- VIC (mm/day)', $
			file_type = 0, fname = voutc1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			map_info=map_info, $
			DEF_BANDS=[0], $
			/WRITE		
	
			envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			descrip = 'Monthly Average Wet Canopy AET -- VIC (mm/day)', $
			file_type = 0, fname = vouti1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			map_info=map_info, $
			DEF_BANDS=[0], $
			/WRITE	
	
			envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			descrip = 'Monthly Average Soil AET -- VIC (mm/day)', $
			file_type = 0, fname = vouts1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			map_info=map_info, $
			DEF_BANDS=[0], $
			/WRITE	

			envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			descrip = 'Monthly Average AET -- VIC (mm/day)', $
			file_type = 0, fname = vout1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			map_info=map_info, $
			DEF_BANDS=[0], $
			/WRITE	
	
			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average Canopy AET -- CLM (mm/day)', $
			;file_type = 0, fname = coutc1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE		
	
			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average Wet Canopy AET -- CLM (mm/day)', $
			;file_type = 0, fname = couti1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE	
	
			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average Soil AET -- CLM (mm/day)', $
			;file_type = 0, fname = couts1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE	

			;envi_setup_head, byte_order = 0, data_type = 4, $ ;data type = 1 for byte, 2 for int, 4 for float
			;descrip = 'Monthly Average AET -- CLM (mm/day)', $
			;file_type = 0, fname = cout1, interleave = 0, nb = 1, nl = ny, ns = nx, $ ;+'.hdr' only for win
			;map_info=map_info, $
			;DEF_BANDS=[0], $
			;/WRITE	
	
		ENDIF

	ENDIF

ENDFOR

spawn, 'rm *.bin'

END	

		