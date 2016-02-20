;*========================================================================
;* hdfeos2bin.pro - extract flat binary files from hdfeos file
;*
;* 27-Sep-2001  Terry Haran  tharan@colorado.edu  492-1847
;* National Snow & Ice Data Center, University of Colorado, Boulder
;$Header: /export/data/hdfeos2bin/src/idl/hdfeos2bin.pro,v 1.4 2001/10/01 21:02:44 haran Exp $
;*========================================================================*/

;+
; NAME:
;	hdfeos2bin
;
; PURPOSE:
;       Extract data arrays from a hdfeos file and write the arrays to
;       separate flat binary data files. Guaranteed to work with the
;       following types of files:
;         MOD10_L2 - 5 min swath snow cover 500 m
;         MOD10A1 - ISIN gridded daily snow cover 500 m
;         MOD10A2 - ISIN gridded 8-day snow cover 500 m
;         MOD29 - 5 min swath sea ice 1 km
;         MOD29P1D - EASE gridded daytime sea-ice 1 km
;         MOD29P1N - EASE gridded nighttime sea-ice 1 km
;       It may also work with other types of hdfeos files.
;
; CATEGORY:
;	Modis.
;
; CALLING SEQUENCE:
;       hdfeos2bin, hdfeos_file, [, /verbose]
;
; ARGUMENTS:
;    Inputs:
;       hdfeos_file: name of the hdfeos file to be read. May contain wild
;       cards.

;    Outputs:
;       For each hdfeos file "file.hdf" processed, a corresponding
;       subdirectory called "file.hdf.dir" is created in the directory
;       containing "file.hdf". This subdirectory will contain the output
;       files. If the subdirectory already exists, its contents are
;       unchanged. See write_field.pro for an explanation of the output
;       filenames.
;
; KEYWORDS:
;       verbose: if set, then informational messages are displayed
;
; EXAMPLE:
;      hdfeos2bin, '*.hdf'
;
; REQUIREMENTS:
;      IDL 5.3 or higher on a UNIX or WINDOWS platform.
;
; REFERENCE:
;      http://hdfeos.gsfc.nasa.gov/hdfeos/workshop.cfm
;-

PRO hdfeos2bin, hdfeos_file, verbose=verbose

usage = 'usage: hdfeos2bin, hdfeos_file, [, /verbose]'
                   
  if n_params() ne 1 then $
    message, usage

  if n_elements(verbose) eq 0 then $
    verbose = 0

  ;
  ;  Convert the first three characters of the IDL version to a number
  ;

  idl_version = 0.0
  reads, strmid(!version.release, 0, 3), idl_version

  ;
  ;  Make sure we're on a platform we support
  ;

  if idl_version lt 5.3 then $
    message, 'This program requires IDL 5.3 or higher'
  if (!version.os_family ne 'Windows') and $
     (!version.os_family ne 'unix') then $
    message, 'This program only runs under Windows or unix'

  ;
  ;  Get an array of filenames matching hdfeos_file
  ;

  files = findfile(hdfeos_file, count=file_count)
  if file_count le 0 then $
    message, 'Cannot find any files matching ' + hdfeos_file

  ;
  ;  Process each file separately
  ;

  for file_num = 0L, file_count - 1 do begin
      file = files[file_num]
      if verbose then begin
          message, /informational, ' '
          message, /informational, 'Processing file ' + file
      endif

      ;
      ;  Create a directory to hold the output files
      ;

      output_dir = file + '.dir'
      if verbose then $
        message, /informational, 'Creating output directory ' + output_dir
      if idl_version gt 5.3 then begin
          file_mkdir, output_dir
      endif else begin
          if !version.os_family eq 'unix' then $
            spawn, 'mkdir ' + output_dir, /sh $
          else $
            spawn, 'mkdir ' + output_dir
      endelse

      ;
      ;  ***** START SWATH *****
      ;  Try to get a list of the swath objects in the file
      ;
      
      swath_count = eos_sw_inqswath(file, swath_list)
      if swath_count gt 0 then begin
          if verbose then $
            message, /informational, 'File ' + file + $
                                     ' contains' + string(swath_count) + $
                                     ' swath object(s)'

          ;
          ;  Open the file for swath processing
          ;

          if verbose then $
            message, /informational, 'Opening file ' + file + ' as swath'
          fid = eos_sw_open(file, /read)
          if fid eq -1 then begin
              message, /informational, 'Cannot open ' + file + ' as swath'
          endif else begin

              ;
              ;  Create a string array holding the swath names
              ;

              swath_names = strsplit(swath_list, ',', /extract)

              ;
              ;  Process each swath object separately
              ;  (there's usually only one, but let's keep it general)
              ;

              for swath_num = 0, swath_count - 1 do begin
                  swath_name = swath_names[swath_num]

                  ;
                  ;  Attach to the swath object
                  ;

                  if verbose then $
                    message, /informational, 'Attaching to swath object ' + $
                                             swath_name
                  swath_id = eos_sw_attach(fid, swath_name)
                  if swath_id eq -1 then begin
                      message, /informational, $
                               'Cannot attach to swath object ' + swath_name
                  endif else begin

                      ;
                      ;  Process the swath object
                      ;

                      process_swath, swath_id, output_dir, verbose=verbose

                      ;
                      ;  Detach from the swath object
                      ;

                      if verbose then $
                        message, /informational, $
                                 'Detaching from swath object ' + swath_name
                      if eos_sw_detach(swath_id) ne 0 then $
                        message, /informational, $
                                 'Cannot detach from swath object ' + $
                                 swath_name
                  endelse
              endfor
          endelse

          ;
          ;  Close the file for swath processing
          ;

          if verbose then $
            message, /informational, 'Closing file ' + file + ' as swath'
          if eos_sw_close(fid) ne 0 then $
                    message, /informational, $
                             'Cannot close file ' + file + ' as swath'
      endif
      ;
      ;  ***** END SWATH *****
      ;

      ;
      ;  ***** START GRID *****
      ;  Try to get a list of the grid objects in the file
      ;
      
      grid_count = eos_gd_inqgrid(file, grid_list)
      if grid_count gt 0 then begin
          if verbose then $
            message, /informational, 'File ' + file + $
                                     ' contains' + string(grid_count) + $
                                     ' grid object(s)'

          ;
          ;  Open the file for grid processing
          ;

          if verbose then $
            message, /informational, 'Opening file ' + file + ' as grid'
          fid = eos_gd_open(file, /read)
          if fid eq -1 then begin
              message, /informational, 'Cannot open ' + file + ' as grid'
          endif else begin

              ;
              ;  Create a string array holding the grid names
              ;

              grid_names = strsplit(grid_list, ',', /extract)

              ;
              ;  Process each grid object separately
              ;  (there's usually only one, but let's keep it general)
              ;

              for grid_num = 0, grid_count - 1 do begin
                  grid_name = grid_names[grid_num]

                  ;
                  ;  Attach to the grid object
                  ;

                  if verbose then $
                    message, /informational, 'Attaching to grid object ' + $
                                             grid_name
                  grid_id = eos_gd_attach(fid, grid_name)
                  if grid_id eq -1 then begin
                      message, /informational, $
                               'Cannot attach to grid object ' + grid_name
                  endif else begin

                      ;
                      ;  Process the grid object
                      ;

                      process_grid, grid_id, output_dir, verbose=verbose

                      ;
                      ;  Detach from the grid object
                      ;

                      if verbose then $
                        message, /informational, $
                                 'Detaching from grid object ' + grid_name
                      if eos_gd_detach(grid_id) ne 0 then $
                        message, /informational, $
                                 'Cannot detach from grid object ' + $
                                 grid_name
                  endelse
              endfor
          endelse

          ;
          ;  Close the file for grid processing
          ;

          if verbose then $
            message, /informational, 'Closing file ' + file + ' as grid'
          if eos_gd_close(fid) ne 0 then $
                    message, /informational, $
                             'Cannot close file ' + file + ' as grid'
      endif
      ;
      ;  ***** END GRID *****
      ;

      ;
      ;  If we didn't find any data to process,
      ;  then remove the output directory
      ;

      if (swath_count le 0) and (grid_count le 0) then begin
          message, /informational, 'File ' + file + $
                                   ' contains no swath or grid objects'
          if verbose then $
            message, /informational, 'Deleting output directory ' + output_dir
          if idl_version gt 5.3 then begin
              file_delete, output_dir
          endif else begin
              if !version.os_family eq 'unix' then $
                spawn, 'rmdir ' + output_dir, /sh $
              else $
                spawn, 'rmdir ' + output_dir
          endelse
      endif
  endfor

END ; hdfeos2bin
