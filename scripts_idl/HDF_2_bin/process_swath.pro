;*========================================================================
;* process_swath.pro - extract flat binary files from hdfeos swath object
;*
;* 27-Sep-2001  Terry Haran  tharan@colorado.edu  492-1847
;* National Snow & Ice Data Center, University of Colorado, Boulder
;$Header: /export/data/hdfeos2bin/src/idl/process_swath.pro,v 1.4 2001/09/28 22:10:10 haran Exp $
;*========================================================================*/

;+
; NAME:
;	process_swath
;
; PURPOSE:
;       Extract data arrays from a hdfeos swath object and write the arrays to
;       separate flat binary data files. Guaranteed to work with the
;       following types of files:
;         MOD10_L2 - 5 min swath snow cover 500 m
;         MOD29 - 5 min swath sea ice 1 km
;       It may also work with other types of hdfeos files.
;
; CATEGORY:
;	Modis.
;
; CALLING SEQUENCE:
;       process_swath, swath_id, output_dir, [, /verbose]
;
; ARGUMENTS:
;    Inputs:
;       swath_id: swath id returned from eos_sw_attach.
;    Outputs:
;       output_dir: name of the existing directory that will hold the
;         output files.
;
; KEYWORDS:
;       verbose: if set, then informational messages are displayed
;
; EXAMPLE:
;       process_swath, swath_id, $
;                      'MOD10_L2.A2001121.0005.003.2001240182349.hdf.dir'
;
; ALGORITHM:
;
; REFERENCE:
;       http://hdfeos.gsfc.nasa.gov/hdfeos/workshop.cfm
;-

PRO process_swath, swath_id, output_dir, verbose=verbose

usage = 'usage: process_swath, swath_id, output_dir, [, /verbose]'
                   
  if n_params() ne 2 then $
    message, usage

  if n_elements(verbose) eq 0 then $
    verbose = 0

  ;
  ;  Get list of geolocation fields
  ;  Discard ranks and types as process_swath_field will get them
  ;

  if verbose then $
    message, /informational, 'Retrieving list of swath geolocation fields'

  geofield_count = eos_sw_inqgeofields(swath_id, geofield_list, $
                                       geofield_ranks, geofield_types)
  if geofield_count eq -1 then begin
      message, /informational, $
               'Cannot retrieve list of swath geolocation fields'
  endif else begin

      ;
      ;  Create a string array holding the geofield names
      ;

      geofield_names = strsplit(geofield_list, ',', /extract)

      ;
      ;  Process each geofield
      ;

      for geofield_num = 0, geofield_count - 1 do $
        process_swath_field, swath_id, $
                             geofield_names[geofield_num], $
                             output_dir, $
                             verbose=verbose
  endelse

  ;
  ;  Get list of data fields
  ;  Discard ranks and types as process_swath_field will get them
  ;

  if verbose then $
    message, /informational, 'Retrieving list of swath data fields'

  datafield_count = eos_sw_inqdatafields(swath_id, datafield_list, $
                                         datafield_ranks, datafield_types)
  if datafield_count eq -1 then begin
      message, /informational, $
               'Cannot retrieve list of swath data fields'
  endif else begin

      ;
      ;  Create a string array holding the datafield names
      ;

      datafield_names = strsplit(datafield_list, ',', /extract)

      ;
      ;  Process each datafield
      ;

      for datafield_num = 0, datafield_count - 1 do $
        process_swath_field, swath_id, $
                             datafield_names[datafield_num], $
                             output_dir, $
                             verbose=verbose
  endelse

END ; process_swath
