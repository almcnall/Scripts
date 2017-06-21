;*========================================================================
;* process_grid.pro - extract flat binary files from hdfeos grid object
;*
;* 27-Sep-2001  Terry Haran  tharan@colorado.edu  492-1847
;* National Snow & Ice Data Center, University of Colorado, Boulder
;$Header: /export/data/hdfeos2bin/src/idl/process_grid.pro,v 1.3 2001/09/28 22:08:51 haran Exp $
;*========================================================================*/

;+
; NAME:
;	process_grid
;
; PURPOSE:
;       Extract data arrays from a hdfeos grid object and write the arrays to
;       separate flat binary data files. Guaranteed to work with the
;       following types of files:
;         MOD10_L2 - 5 min grid snow cover 500 m
;         MOD29 - 5 min grid sea ice 1 km
;       It may also work with other types of hdfeos files.
;
; CATEGORY:
;	Modis.
;
; CALLING SEQUENCE:
;       process_grid, grid_id, output_dir, [, /verbose]
;
; ARGUMENTS:
;    Inputs:
;       grid_id: grid id returned from eos_gd_attach.
;    Outputs:
;       output_dir: name of the existing directory that will hold the
;         output files.
;
; KEYWORDS:
;       verbose: if set, then informational messages are displayed
;
; EXAMPLE:
;       process_grid, grid_id, $
;                     'MOD10A1.A2001121.h10v02.003.2001241142912.hdf'
;
; ALGORITHM:
;
; REFERENCE:
;       http://hdfeos.gsfc.nasa.gov/hdfeos/workshop.cfm
;-

PRO process_grid, grid_id, output_dir, verbose=verbose

usage = 'usage: process_grid, grid_id, output_dir, [, /verbose]'
                   
  if n_params() ne 2 then $
    message, usage

  if n_elements(verbose) eq 0 then $
    verbose = 0

  ;
  ;  Get list of data fields
  ;  Discard ranks and types as process_grid_field will get them
  ;

  if verbose then $
    message, /informational, 'Retrieving list of grid data fields'

  datafield_count = eos_gd_inqfields(grid_id, datafield_list, $
                                     datafield_ranks, datafield_types)
  if datafield_count eq -1 then begin
      message, /informational, $
               'Cannot retrieve list of grid data fields'
  endif else begin

      ;
      ;  Create a string array holding the datafield names
      ;

      datafield_names = strsplit(datafield_list, ',', /extract)

      ;
      ;  Process each datafield
      ;

      for datafield_num = 0, datafield_count - 1 do $
        process_grid_field, grid_id, $
                            datafield_names[datafield_num], $
                            output_dir, $
                            verbose=verbose
  endelse

END ; process_grid
