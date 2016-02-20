%this script calls the function api.m which calculates the difference
%between the api model and the observations. then this script solves for
%the appropriate beta, gamma and constat parameters by minimizing the
%difference. 

%rain =load('/raid/chg-mcnally/WKRFE_TKRFE_WKUBRF_TKUBRF_amma2013.csv');
load('/raid/chg-mcnally/Mpala_KLEE_ubRFE2011_2012.csv')
rain = [Mpala_KLEE_ubRFE2011_2012(:,1)', NaN, NaN, NaN]'; %1-mpala,2-klee

%soil=load('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
soil=load('/raid/chg-mcnally/Mpala_dekad.csv')
%soil=load('/raid/chg-mcnally/observed_avgTKWK06.11.csv');

y = soil;
y = soil(25:66)/100;  %Mpala  
%y = soil(28:68); %KLEE

%rain = rain(:,3);% WK UBRFE
rain = rain(25:66);%i dunno if this is right.

%lsqnonlin arguments - write a function that calculates the residuals
%between non linear model and data (so that there is something to minimize!)
%, and an initial guess for parameters
x0 = [0.001 0.9 0.02];
result = lsqnonlin(@(x) api_sim(x,rain) - y, x0);
sim = api_sim(result,rain); % I changed the name from api_sim to just api..ops
out = [y sim];
result
%csvwrite('/raid/chg-mcnally/API_ubrf_Mpala_930.csv',out);


%% make a API maps!
NX = 720; %250
NY = 350;
NZ = 432; %396;
apimap=NaN(NX,NY,NZ);

%this file is huge, but worked. Maybe better to read in one at a time.
%infile = '/jabber/LIS/Data/ubRFE2/dekads/sahel/sahel_200101_201232.img'
infile =dir('/raid/chg-mcnally/ubRFE04.19.2013/dekads/sahel/*.img')
%infile = '/jabber/LIS/Data/ubRFE2/dekads/horn/horn_ubrfe_2001_201232_dek.img'

for i = 1:NZ
  fid = fopen(['/raid/chg-mcnally/ubRFE04.19.2013/dekads/sahel/',infile(i).name],'r');
  buffer = fread(fid,NX*NY,'float');
  fclose(fid);
  %buffer = reshape(buffer,NX,NY);
  ndeks(:,i) = buffer;
end

ndeks=reshape(ndeks,NX,NY,NZ);
imagesc(rot90(sum(ndeks,3)));
imagesc(rot90(ndeks(:,:,428)));
for X = 1:NX
    for Y = 1:NY
      %make the rainfall a vector
      rain=reshape(ndeks(X,Y,:),NZ,1);
      %max(rain)
      result = [0.0002 0.7905 0.0401] %WKTK
      %result = [0.0607 0.6360 7.4746];%Mpala2 @ API3
      %result = [0.1664 0.5345 26.2655];%KLEE @ API?
      %result = [0.1578 0.5785 26.7596];%KLEE @ API3

      %result = [0.0003 0.7027 0.0327];%wankama
      sim2=api_sim(result,rain);
      %plot(sim2)
      apimap(X,Y,:)=sim2;
    end
end
map=rot90(nanmean(apimap,3));
clims=[ 0.001 20];
imagesc(map(:,:)); colorbar;

%to get the grandmean
m=nanmean(apimap,3);
m2=nanmean(m,2);
m3=nanmean(m2,3);

fid = fopen('/raid/chg-mcnally/API_2001_2012_sahel_WKTKparams_930.img', 'w');
fwrite(fid, apimap, 'float');
fclose(fid); 



