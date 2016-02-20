;;; THIS WORKSHEET WILL READ THE ORIGINAL NDVI FILES SUPPLIED BY MIKE BUDDE
;;; AND IF THE FILE IS FROM THE LARGER WINDOW (I.E. POST NOVEMBER 2010)
;;; THEN IT WILL WRITE OUT A SUBSET VERSION OF THE FILE, EXCLUDING THE 
;;; BOTTOM LINES SO ALL THE NDVI DATA WILL HAVE THE SAME FORMAT 
;;;
;;; Created by: Greg Husak
;;; Date: February 28, 2012
;modified on 9/27/2012(AM) to fix the anom files, and on 11/21/12 to chop 2011-2012 
; first read in one of the old files to get the geotiff tags and such
;masterfilename = '/jabber/sandbox/shared/Amy-eMODISll/data.2010.113.tiff'
masterfilename = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/data.2010.113.tiff'
;masterfilename = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/anom.2010.113.tiff'

masterinfo = FILE_INFO(masterfilename)
mastertif = READ_TIFF(masterfilename, R, G, B, GEOTIFF=g_tags_master, ORIENTATION = o_tate_master,PLANARCONFIG = p_conf_master)
masterdims = SIZE(mastertif)
masterNY = masterdims[2]

; now find all the tiff files original files that have the extra lines
data_dir = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/dekads/'
out_dir = '/jabber/sandbox/shared/eMODIS/'
cd,data_dir
fnames = FILE_SEARCH('data*.tiff')
;fnames = FILE_SEARCH('anom*.tiff')

; check the files to see if they have the extra lines, if they do, then read in the original data and write out the 
; chopped version
foreach f,fnames DO BEGIN 	; for each file
   finfo = FILE_INFO(f)		; get the file info for that file, especially size
   if finfo.size NE masterinfo.size THEN BEGIN		; if size doesn't match the master size then...
      indata = READ_TIFF(f,R,G,B,GEOTIFF=g_tags,ORIENTATION=o_tate,PLANARCONFIG=p_conf)	; read in original data
      ; write out the subset of the data, only the same number of lines as the master file
      WRITE_TIFF,out_dir+f,indata(*,0:masterNY-1),RED=R,GREEN=G,BLUE=B, $		
         GEOTIFF=g_tags_master,ORIENTATION=o_tate_master,PLANARCONFIG=p_conf
   endif
endforeach


