pro warp_ENVI_image_to_geocoords

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDL code to warp ENVI Standard images from native projection to geographic
; non-projected coordinates. Run with ENVI on.
;
; INPUTS: ground control point file and ENVI Standard imagery
;
; OUTPUTS: warped ENVI image, stored in created subdirectory called "warped"
;
; by Michael Toomey, mtoomey@geog.ucsb.edu
; last modified: May 16, 2010
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;USER-DEFINED VARIABLES;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ground control pts file
gcp_file = 'warp.3.points_1.5.pts'
; Search filter for input imagery
filter = 'ppt*bil'
; output cell size - X and Y direction (Double precision)
xcellsize     = 0.3D
ycellsize     = 0.3D
; output datum
datum      = 'WGS-84'
; array of band positions for image data
data_pos       = 0L
; background value
background      = -1.
; method for resampling, where:
;0  RST with nearest neighbor,
;1  RST with bilinear
;2  RST with cubic convolution
;3  Polynomial with nearest neighbor (specify 'degree', or comment it)
;4  Polynomial with bilinear (")
;5  Polynomial with cubic convolution (")
;6  Triangulation with nearest neighbor
;7  Triangulation with bilinear
;8  Triangulation with cubic convolution
method         = 3
degree         = 2
;;;;;;;;;;;;;;;;;;;;;;;END OF USER-DEFINED VARIABLES;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; make sub-directory
file_mkdir,'warped'

; set up PROJECTION structure using Geographic, and default of WGS-84
; datum and default Units of Degrees
proj = envi_proj_create(/geographic)

; open ground control points file as ASCII and convert to double floating point
result = read_ascii(gcp_file)
GCP_pts = double(result.field1)

; upper left pixel coordinates
X0 = GCP_pts(0,0)
Y0 = GCP_pts(1,0)

; populate list of input files
infiles = file_search(filter)

; open I FOR loop to open all files, warp them and then create output image
for i=0,n_elements(infiles)-1 do begin

    ; open original image in ENVI, do not open in Available Files List
    envi_open_file,infiles[i],r_fid=fid,/no_realize
    envi_file_query,fid, dims=dims

    ; change directory to subdirectory to create output file
    cd, 'warped'
    ; warp images
    envi_doit,'envi_register_doit',method=method,degree=degree,out_name=infiles[i],pixel_size=[xcellsize,ycellsize],proj=proj,pts=GCP_pts,r_fid=r_fid,w_fid=fid,w_dims=dims,X0=X0,Y0=Y0,w_pos=data_pos

    ; return to upper directory
    cd,'..'

	; close input and output files
	envi_file_mng,id=fid,/remove
	envi_file_mng,id=r_fid,/remove

; end I FOR loop
endfor

end
