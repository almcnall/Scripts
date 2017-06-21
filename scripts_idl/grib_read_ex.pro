 FUNCTION GRIB_READ_EX,filename, HEADER=header
  ON_ERROR, 2
  IF(filename eq !null) THEN MESSAGE, 'File is undefined.'
 
  f = GRIB_OPEN(filename)
 
  data = PTRARR(GRIB_COUNT(filename))
  if(ARG_PRESENT(header)) THEN header = MAKE_ARRAY(GRIB_COUNT(filename), /OBJ)
 
  h = GRIB_NEW_FROM_FILE(f)
  i=0
    WHILE(h NE !NULL) DO BEGIN
    ; Get values array
    values = GRIB_GET_VALUES(h)
    data[i] = PTR_NEW(values)
 
    ; Get header information if requested
    IF (ARG_PRESENT(header)) THEN BEGIN
      kiter = GRIB_KEYS_ITERATOR_NEW(h, /COMPUTED)
      header[i] = LIST()
      res = GRIB_KEYS_ITERATOR_NEXT(kiter)
      WHILE (res EQ 1) DO BEGIN
        key = GRIB_KEYS_ITERATOR_GET_NAME(kiter)
        IF (STRCMP(key, 'values', /FOLD_CASE) EQ 0) THEN BEGIN
          IF (GRIB_GET_SIZE(h, key) GT 1) THEN $
            val = GRIB_GET_ARRAY(h, key)ELSE val = GRIB_GET(h, key)
          IF (STRCMP(key, '7777', /FOLD_CASE) EQ 1) THEN key = 'end_section'
          key_value = CREATE_STRUCT(key, val)
          header[i].add, key_value
        ENDIF
        res = GRIB_KEYS_ITERATOR_NEXT(kiter)
      ENDWHILE
      GRIB_KEYS_ITERATOR_DELETE, kiter
    ENDIF
 
    GRIB_RELEASE, h
    h = GRIB_NEW_FROM_FILE(f)
    i++
  ENDWHILE
 
  GRIB_CLOSE, f
  RETURN, data
END
