%this is the paw estimated with Wankama station data 2006-2008
spaw = load('/jabber/chg-mcnally/WKPAW_complete_TS.csv') ;
soil = load('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Wankama_sm_0.100000_0.400000_CS616_2_10dayavg_VWC.csv');

good = isfinite(spaw);
pix = soil(good);
pmn = mean(pix);
        pstd = std(pix);
        testcdf(:,1) = pix;
        testcdf(:,2) = normcdf(pix,pmn,pstd);
        [normrej,normp] = kstest(pix,testcdf)
        pix(find(pix <= 0)) = 1;
        pars = gamfit(pix);
        testcdf(:,1) = pix;
        testcdf(:,2) = gamcdf(pix,pars(1),pars(2));
        [gamrej,gamp] = kstest(pix,testcdf)
%% check PAW estimated with Agoufou station data
%I guess i need a complete time series...
spaw = load('/jabber/chg-mcnally/AGPAW_complete_TS.csv');
soil = load('/jabber/chg-mcnally/AMMASOIL/AMMA2013/dekads/Agoufou_sm_0.600000_0.600000_CS616_1_10dayavg_VWC.csv'); 

good = isfinite(spaw);
pix = soil(good);
pmn = mean(pix);
        pstd = std(pix);
        testcdf(:,1) = pix;
        testcdf(:,2) = normcdf(pix,pmn,pstd);
        [normrej,normp] = kstest(pix,testcdf)
        pix(find(pix <= 0)) = 1;
        pars = gamfit(pix);
        testcdf(:,1) = pix;
        testcdf(:,2) = gamcdf(pix,pars(1),pars(2));
        [gamrej,gamp] = kstest(pix,testcdf)
%% check out the modeled distributions
allpaw = load('/jabber/chg-mcnally/NPAW_RPAW_AG_WK_BT.csv');
NAG = allpaw(:,1);
NWK = allpaw(:,2);
NBT = allpaw(:,3);
RAG = allpaw(:,4);
RWK = allpaw(:,5);
RBT = allpaw(:,6);

Rsite = RAG;
soil = RAG;

good = isfinite(Rsite);
pix = soil(good);
pmn = mean(pix);
        pstd = std(pix);
        testcdf(:,1) = pix;
        testcdf(:,2) = normcdf(pix,pmn,pstd);
        %test emperical vs norm w/ emperical params
        [normrej,normp] = kstest(pix,testcdf)
        pix(find(pix <= 0)) = 1;
        pars = gamfit(pix);
        %test emperical vs gam w/ emperical params
        testcdf(:,1) = pix;
        testcdf(:,2) = gamcdf(pix,pars(1),pars(2));
        [gamrej,gamp] = kstest(pix,testcdf)
        %test emperical from 