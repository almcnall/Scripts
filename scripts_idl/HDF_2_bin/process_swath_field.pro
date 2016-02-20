;*========================================================================
;* process_swath_field.pro - extract flat binary file from hdfeos swath field
;*
;* 28-Sep-2001  Terry Haran  tharan@colorado.edu  492-1847
;* National Snow & Ice Data Center, University of Colorado, Boulder
;$Header: /export/data/hdfeos2bin/src/idl/process_swath_field.pro,v 1.3 2001/09/28 22:09:42 haran Exp $
;*========================================================================*/

;+
; NAME:
;	process_swath_field
;
; PURPOSE:
;       Extract data array from a hdfeos swath field and write the array to
;       a flat binary data file. Guaranteed to work with the
;       following types of files:
;         MOD10_L2 - 5 min swath snow cover 500 m
;         MOD29 - 5 min swath sea ice 1 km
;       It may also work with other types of hdfeos files.
;
; CATEGORY:
;	Modis.
;
; CALLING SEQUENCE:
;       process_swath_field, swath_id, name, 
;                            output_dir [, /verbose]
;
; ARGUMENTS:
;    Inputs:
;       swath_id: swath id returned from eos_sw_attach.
;       name: name of the field to be processed.
;
;    Outputs:
;       output_dir: name of the existing directory that will hold the
;         output file.
;
; KEYWORDS:
;       verbose: if set, then informational messages are displayed
;
; EXAMPLE:
;       process_swath_field, swath_id, 'Latitude', $
;                            'MOD10_L2.A2001121.0005.003.2001240182349.hdf.dir'
;
; ALGORITHM:
;
; REFERENCE:
;       http://hdfeos.gsfc.nasa.gov/hdfeos/workshop.cfm
;-

PRO process_swath_field, swath_id, name, output_dir, verbose=verbose

usage = 'usage: process_swath_field, swath_id, name, ' + $
        'output_dir, [, /verbose]'
                   
  if n_params() ne 3 then $
    message, usage

  if n_elements(verbose) eq 0 then $
    verbose = 0

  if verbose then $
    message, /informational, 'Processing swath field: ' + name

  ;
  ;  Get the rank (number of dimensions), dimensions, type,
  ;  and list of dimension names
  ;

  if eos_sw_fieldinfo(swath_id, name, $
                      rank, dims, type, dim_list) ne 0 then begin
      message, /informational, $
               'Cannot read field info: ' + name
  endif else begin
      ;
      ;  Read the data array for the field into buffer
      ;

      if eos_sw_readfield(swath_id, name, buffer) ne 0 then begin
          message, /informational, $
                   'Cannot read field: ' + name
      endif else begin

          ;
          ;  Write out field data
          ;

          write_field, name, rank, dims, type, dim_list, $
                       buffer, output_dir, verbose=verbose
      endelse
  endelse

END ; process_swath_field
