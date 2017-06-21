;*========================================================================
;* write_field.pro - write field data to a flat binary file
;*
;* 28-Sep-2001  Terry Haran  tharan@colorado.edu  492-1847
;* National Snow & Ice Data Center, University of Colorado, Boulder
;$Header: /data/haran/hdfeos2bin/src/idl/write_field.pro,v 1.5 2005/02/18 22:23:04 haran Exp $
;*========================================================================*/

;+
; NAME:
;	write_field
;
; PURPOSE:
;       Write extracted field data to a flat binary file.
;
; CATEGORY:
;	Modis.
;
; CALLING SEQUENCE:
;       write_field, swath_id, name, rank, dims, type, dim_list, buffer, $ 
;                    output_dir [, /verbose]
;
; ARGUMENTS:
;    Inputs:
;       swath_id: swath id returned from eos_sw_attach.
;       name: string representing the name of the field to be processed.
;       rank: long int representing the number of dimensions in the field.
;       dims: long int array of dimensions values.
;       type: long int defining the hdf data type of the field as follows:
;          DFNT_UCHAR	3L	-- not allowed here
;          DFNT_CHAR	4L      -- not allowed here
;          DFNT_FLOAT32	5L
;          DFNT_DOUBLE	6L
;          DFNT_INT8	20L	
;          DFNT_UINT8	21L
;          DFNT_INT16	22L
;          DFNT_UINT16	23L
;          DFNT_INT32	24L
;          DFNT_UINT32	25L
;       dim_list: string containing comma-delimited list of dimension names.
;       buffer: data array containing the field data.
;
;    Outputs:
;       output_dir: name of the existing directory that will hold the
;         output file.
;         The output filename will be constructed as follows:
;           <sname>_<stype>_<dims[0]>_<dims[1]>_...<dims[rank-1]>.img
;              where
;              sname is name with spaces and slashes replaced by underbars.
;              stype is a two character string defined as follows:
;                type         stype    idl_type
;                DFNT_UCHAR     u1     string  -- not allowed here
;                DFNT_CHAR      s1     string  -- not allowed here
;                DFNT_FLOAT32	f4     float
;                DFNT_DOUBLE	f8     double
;                DFNT_INT8      s1     byte
;                DFNT_UINT8	u1     byte
;                DFNT_INT16	s2     int
;                DFNT_UINT16	u2     uint
;                DFNT_INT32	s4     long
;                DFNT_UINT32	u4     ulong
;
; KEYWORDS:
;       verbose: if set, then informational messages are displayed
;
; EXAMPLE:
;       write_field, 'Latitude', 2L, [271L, 406L], 5L, $
;                    'Coarse_swath_pixels_5km,Coarse_swath_lines_5km', $
;                    buffer, $
;                    'MOD10_L2.A2001121.0005.003.2001240182349.hdf.dir'
;       This would create the following file in existing directory
;       MOD10_L2.A2001121.0005.003.2001240182349.hdf.dir:
;         Latitude_f4_00271_00406.img
;
; ALGORITHM:
;
; REFERENCE:
;       http://hdfeos.gsfc.nasa.gov/hdfeos/workshop.cfm
;-

PRO write_field, name, rank, dims, type, dim_list, buffer, $
                 output_dir, verbose=verbose

usage = 'usage: write_field, name, rank, dims, type, dim_list, buffer, ' + $
        'output_dir, [, /verbose]'
                   
  if n_params() ne 7 then $
    message, usage

  if n_elements(verbose) eq 0 then $
    verbose = 0

  if verbose then begin
      
      ;
      ;  Create string array of dimension names
      ;

      dim_names = strsplit(dim_list, ',', /extract)

      ;
      ;  Print information about the field
      ;

      message, /informational, 'field: ' + name
      message, /informational, '  type:' + string(type)
      message, /informational, '  rank:' + string(rank)
      for dim_num = 0, rank - 1 do begin
          dim_num_s = string(dim_num, format='(i1)')
          message, /informational, '  dimension[' + dim_num_s + $
                                   ']: ' + string(dims[dim_num]) + $
                                   '  ' + dim_names[dim_num]
      endfor
  endif

  ;
  ;  Construct stype string
  ;

  case type of
      3L:  stype = ''   ;DFNT_UCHAR -- not allowed here
      4L:  stype = ''   ;DFNT_CHAR  -- not allowed here
      5L:  stype = 'f4' ;DFNT_FLOAT32
      6L:  stype = 'f8' ;DFNT_DOUBLE
      20L: stype = 's1' ;DFNT_INT8
      21L: stype = 'u1' ;DFNT_UINT8
      22L: stype = 's2' ;DFNT_INT16
      23L: stype = 'u2' ;DFNT_UINT16
      24L: stype = 's4' ;DFNT_INT32
      25L: stype = 'u4' ;DFNT_UINT32
      else: stype = ''
  endcase
  if stype eq '' then begin
      message, /informational, 'Ilegal type: ' + string(type)
  endif else begin

      ;
      ;  Replace spaces and slashes with underbars in name by first creating
      ;  a string array, each element of which is a word in name,
      ;  and then concatenating the words with intervening underbars
      ;  to create the string sname.
      ;

      words = strsplit(name, ' ', /extract)
      word_count = n_elements(words)
      sname = ''
      for word_num = 0, word_count - 1 do begin
          sname = sname + words[word_num]
          if word_num ne word_count - 1 then $
            sname = sname + '_'
      endfor

      name = sname
      words = strsplit(name, '/', /extract)
      word_count = n_elements(words)
      sname = ''
      for word_num = 0, word_count - 1 do begin
          sname = sname + words[word_num]
          if word_num ne word_count - 1 then $
            sname = sname + '_'
      endfor

      ;
      ;  Construct output filename
      ;

      filename = sname + '_' + stype
      for dim_num = 0, rank - 1 do $
        filename = filename + '_' + string(dims[dim_num], format='(i5.5)')
      filename = filename + '.img'

      ;
      ;  Write the field data to a flat binary file
      ;

      if verbose then $
        message, /informational, 'Writing field data to file ' + filename
      cd, output_dir
      openw, lun, filename, /get_lun
      writeu, lun, buffer
      free_lun, lun
      cd, '..'

  endelse

END ; write_field

