

##### Temperature response functions
briere<-function(t, c, Tm, T0){
  b=c()
  for (i in 1:length(t)){
  if (t[i]>T0 && t[i]<Tm)  {b[i]<-(c*t[i]*(t[i]-T0)*sqrt(Tm-t[i]))} else {b[i]<-(0)}
  }
  b
}

linear<-function(t, inter, slope){
  b=c()
  for (i in 1: length(t)){
  if  (inter+slope*t[i]>0) {b[i]<-inter+slope*t[i]} else {b[i]<-0}
  }
  b
}

quad<-function(t, inter, slope, qd){
  b=c()
  for (i in 1:length(t)){
  if (inter+slope*t[i]+qd*t[i]^2>0) {b[i]<-inter+slope*t[i]+qd*t[i]^2} else {b[i]<-0}
  }
  b
}

##### Functional response parameters
temp = seq(16.5,39,0.01)
a = briere(temp,0.000203,42.3,11.7)
PDR = briere(temp,0.000111,34.4,14.7)
MDR = briere(temp,0.000111,34,14.7)
EFD = quad(temp,-97.7,8.61,-0.153)
p = quad(temp,0.522,0.0367,-0.000828)
e2a = quad(temp,-4.77,0.453,-0.00924)
bc = quad(temp,-206,25.2,-0.54)
mu = quad(temp,0.586,-0.0467,0.00105)
N = 1000
r = 1/12
k = 1/(N*r)

EIP = 1/PDR

##### Ro and m equations
m = EFD*e2a*MDR/mu^2
Ro = (k*(a^2*bc*m*exp(-mu*EIP))/(mu))^0.5

##### Plot Ro vs. T
matplot(temp,Ro/max(Ro),
  type="l",lty=1,ylab="R0",lwd=2,
  xlab="Temperature (C)",col=1,
  yaxt='n')
