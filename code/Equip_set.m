%% CHP
CHPeffg2h = [0.44 0.44];
CHPeffg2e = [0.58 0.50];
CHPinv = [2870 2500];
CHPmain = [0.021 0.010];
CHPcap = [5000 600];
CHPMaxNum = 10;
CHPMinNum = 1;
%% ASHP
ASHPeff = [2.9 3.16];
ASHPinv = [1250 1180];
ASHPmain = [0.007 0.010];
ASHPcap = [5000 300];
ASHPMaxNum = 10;
ASHPMinNum = 1;
%% GHP
GHPeff = [4.32 4.9];
GHPinv = [5400 5000];
GHPmain = [0.01 0.015];
GHPcap = [5000 800];
GHPMaxNum = 10;
GHPMinNum = 1;
%% EB
EBeff = [3.2 3.6];
EBinv = [2270 2100];
EBmain = [0.1 0.08];
EBcap = [500 200];
EBMaxNum = 10;
EBMinNum = 1;
%% GB
GBeff = [0.94 0.85];
GBinv = [730 520];
GBmain = [0.01 0.007];
GBcap = [3000 300];
GBMaxNum = 10;
GBMinNum = 1;
%% AC
ACeff = [3.6 3.7];
ACinv = [1250 1180];
ACmain = [0.007 0.001];
ACcap = [4000 300];
ACMaxNum = 10;
ACMinNum = 1;
%% EC
ECeff = [2.9 3];
ECinv = [750 660];
ECmain = [0.002 0.003];
ECcap = [200 40];
ECMaxNum = 60;
ECMinNum = 1;
%% 电网气网
pgridmax = 50000;
pgas = 20000;

%% PV
PVeff = [1 1];
PVinv = [1180 1160];
PVmain = [0.001 0.008];
PVcap = [40 10];
PVMaxNum = 20;
PVMinNum = 1;
%% WT
WTeff = [1 1];
WTinv = [370 490];
WTmain = [0.07 0.05];
WTcap = [200 60];
WTMaxNum = 20;
WTMinNum = 1;
%% ES
ESSocmin = 0.2;
ESSocmax = 0.8;
ESsocinit = 0.5;
ESchrate = 0.2;
ESdisrate = 0.2;
ESinv = 80;
ESmain = 0.051;
EScap = 400;
ESMaxNum = 10;
ESMinNum = 1;
%% HS
HSSocmin = 0.2;
HSSocmax = 0.8;
HSsocinit = 0.5;
HSchrate = 0.2;
HSdisrate = 0.2;
HSinv = 430;
HSmain = 0.002;
HScap = 400;
HSMaxNum = 30;
HSMinNum = 1;
%% CS
CSSocmin = 0.2;
CSSocmax = 0.8;
CSsocinit = 0.5;
CSchrate = 0.2;
CSdisrate = 0.2;
CSinv = 120;
CSmain = 0.038;
CScap = 400;
CSMaxNum = 10;
CSMinNum = 1;


