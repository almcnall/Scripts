%this script calls the function api.m which calculates the difference
%between the api model and the observations. then this script solves for
%the appropriate beta, gamma and constat parameters by minimizing the
%difference. 
%rain1=load('/jabber/chg-mcnally/AMMARain/RFE_UBRFE_and_station_dekads.csv')%2005-2008
%rain1 =load('/jabber/chg-mcnally/AMMARain/WKRFE_TKRFE_WKUBRF_TKUBRF_amma2013.csv');
%rain1 =load('/jabber/chg-mcnally/AMMARain/wankamaWest_station_filled_dekads.csv')
rain1 = load('/jabber/chg-mcnally/AMMARain/KLEE.South_station_dekad.csv');
%rain1 = load('/jabber/chg-mcnally/AMMARain/Agoufou_UBRFE_amma2013.csv')
%rain1 = load('/jabber/chg-mcnally/AMMARain/Agoufou_station_dekads.csv')

%soil = load('/jabber/chg-mcnally/AMMASOIL/Agoufou_avg0102SM.csv')% 0.6cm
%soil = load('/jabber/chg-mcnally/AMMASOIL/observed_avgTKWK06_11_filled.csv');
%soil = load('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Wankama_sm_0.400000_0.700000_CS616_2_10dayavg_VWC.csv')
%soil = load('/jabber/chg-mcnally/AMMASOIL/observed_TKWK1WK2.csv')
%load('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
%did i updates these?? prolly not....
soil = load('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')
%soil = Mpala_dekad; %25:66
%y = soil(11:144) %Agoufou 2005,06,07,08
y = soil(25:66)/100;   %Mpala 
%y = soil(28:68); %KLEE
rain = rain1(25:66) %wkrfe
%rain = rain1(37:144);%2005-2008 -> 2006:2008
%y=soil(1:108);%2006-2011 2006:2008
% red = station, RFE = green, 
%lsqnonlin arguments - write a function that calculates the residuals
%between non linear model and data (so that there is something to minimize!)
%, and an initial guess for parameters
x0=[0.001 0.9 0.02];
result = lsqnonlin(@(x) api_sim(x,rain)-y, x0)

%this api is fit-y
sim=api_sim(result,rain) ;
S6out = [y sim];
csvwrite('/jabber/chg-mcnally/API_Agoufou_UBRFrainsoil.csv',S6out);
