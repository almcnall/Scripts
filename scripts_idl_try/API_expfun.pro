function API_expfun,X,A

;this function is called by API pro so that an exponential function is fit using
;lmfit.switched over to R...

;The function to be fit must be written as an IDL function and compiled prior to 
;calling LMFIT. The function must accept a vector X (the independent variables) 
;and a vector A containing the fitted function\u2019s parameter values. It must 
;return an N_ELEMENTS(A)+1-element vector in which the first (zeroth) element is the 
;evaluated function value and the remaining elements are the partial derivatives 
;with respect to each parameter in A.

;beta1
b1
;precip i-n
p
;beta2
b2
;n (time step)
