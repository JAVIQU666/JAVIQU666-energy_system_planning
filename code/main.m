clear;
clc;
close all;
warning off;
DisRate = 0.06; % discount rate
yr = 20;
load('wtld1_lv8760');
load('pvld1_lv8760');
load('ld17_lv8760');
load('eld1_lv8760');
load('hld1_lv8760');
load('cld1_lv8760');
E_load = E_LOAD*0.003;
E_Load = reshape(E_load,24,365);

H_load = H_LOAD*0.002;
H_Load = reshape(H_load,24,365);

C_load = C_LOAD*0.001;
C_Load = reshape(C_load,24,365);

PV = reshape(PV,24,365);
WT = reshape(WT,24,365);

CtgProb = [0.695769612131314	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.00702797588011428	0.0215186477978757	0.0215186477978757	0.0215186477978757];
CtgProb = CtgProb/100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LL=[E_Load;H_Load;C_Load;PV;WT];
flag=find(H_Load(1,:)>0);
hflag1=flag(1);
hflag2=flag(end);
flag=find(C_Load(1,:)>0);
cflag1=flag(1);
cflag2=flag(end);
Esort = sort([LL(:,1:cflag1-1),LL(:,cflag2+1:hflag1-1)],2,'ascend');
Hsort = sort(LL(:,hflag1:hflag2),2,'ascend');
Csort = sort(LL(:,cflag1:cflag2),2,'ascend');
LL = [Esort,Hsort,Csort];
E_Load=LL(1:24,:)*5;
H_Load=LL(25:48,:)*20;
C_Load=LL(49:72,:)*5;
PV=LL(73:96,:);
WT=LL(97:120,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Equip_set();
%% 主程序准备
iter=0;
MpCuts=[];
z = 0;
%主问题提前准备

r = (DisRate*(1+DisRate)^yr)/((1+DisRate)^yr-1);
Maxiter = 2000;
E = zeros(Maxiter,21);
E2 = zeros(Maxiter,21);
e = zeros(Maxiter,1);
totsp = 20;
spnum = 0;
plc = 0;
sp(1:totsp) = struct('f',[],'invB',[],'w',[],'xb',[],'xn',[],'xbflag',[],'num',[]);

numspnum = zeros(1,2000);

E_Load(find(E_Load == 0)) = 0.000001;
H_Load(find(H_Load == 0)) = 0.000001;
C_Load(find(C_Load == 0)) = 0.000001;
PV(find(PV==0))=0.00001;
WT(find(WT==0))=0.00001;

omigae = 0.0;
omigah = 0.0;
omigac = 0.20;
%[A,T,c,h] = getparaDR(E_Load(:,1),H_Load(:,1),C_Load(:,1),PV(:,1),WT(:,1),omigae,omigah,omigac);
%[A,T,c,h] = getparaeco(E_Load(:,1),H_Load(:,1),C_Load(:,1),PV(:,1),WT(:,1));
[A,T,c,h] = getpara(E_Load(:,1),H_Load(:,1),C_Load(:,1),PV(:,1),WT(:,1));

Cpntnum = intvar(1,21);
Cpntnummax = [PVMaxNum*ones(1,2),WTMaxNum*ones(1,2),CHPMaxNum*ones(1,2),ASHPMaxNum*ones(1,2),GHPMaxNum*ones(1,2),EBMaxNum*ones(1,2),GBMaxNum*ones(1,2),ACMaxNum*ones(1,2),ECMaxNum*ones(1,2),ESMaxNum,HSMaxNum,CSMaxNum];

Cpntnummin = [PVMinNum*ones(1,2),WTMinNum*ones(1,2),CHPMinNum*ones(1,2),ASHPMinNum*ones(1,2),GHPMinNum*ones(1,2),EBMinNum*ones(1,2),GBMinNum*ones(1,2),ACMinNum*ones(1,2),ECMinNum*ones(1,2),ESMinNum,HSMinNum,CSMinNum];
Inv = [PVinv,WTinv,CHPinv,ASHPinv,GHPinv,EBinv,GBinv,ACinv,ECinv,EScap,HScap,CScap];
cap = [PVcap,WTcap,CHPcap,ASHPcap,GHPcap,EBcap,GBcap,ACcap,ECcap,EScap,HScap,CScap];
tic
while true
    iter=iter+1;

    %% master problem

    if iter>1
        z = sdpvar(1,1);
        for j=1:iter-1
            MpCuts = [MpCuts; E(j,:)* Cpntnum' + z >= e(j)];
            %MpCuts = [MpCuts; E(j,:)* (Cpntnum)' - E2(j,:)* (Cpntnum + Cpntnumy)' + z >= e(j)];
        end
    end

    %MpObjective = z + r * 100 * Inv * Cpntnum';
    MpObjective = z + r * Inv .* cap * Cpntnum';
    MpConstraints=[];
    MpConstraints = [MpConstraints; MpCuts];
    MpConstraints = [MpConstraints; Cpntnummin <= Cpntnum <= Cpntnummax];


    ops=sdpsettings('verbose',0,'solver','gurobi','usex0',0);
    solution = optimize(MpConstraints, MpObjective, ops);

    MpCpntNum = round(value(Cpntnum'));
    %MpCpntNum = [10	10	10	10	10	10	10	10	10	1	1	1	10	10	1	1	1	1	10	1	9	5	4	1	1	1	1	30	30	30]';
    %MpCpntNum = [20 20 20 20 1 1 4 10 1 1 1 5 4 8 1 10 22 60 10 1 1]'; %DR
    %MpCpntNum = [20 20 20 20 1 1 4 9 1 1 1 1 4 8 1 10 6 60 4 1 1]'; %eco
    %MpCpntNum = [20	20	20	20	1	1	3	10	1	4	1	8	4	8	1	10	22	60	10	4	1]';%ERTP;
    %MpCpntNum = [20	20	20	20	1	1	3	10	1	4	1	8	4	8	1	10	25	60	10	1	1]';
    %MpCpntNum = [20 20 20 20 0 2 3 10 0 9 0 10 6 3 0 10 32 60 10 0 0]';
    Mpz(iter)=value(z);

    %% operation subproblems 8760
    plc = zeros(365,1);
    spnum = 0;
    for i = 1 : 365
        h(1:24) = E_Load(:,i);
        h(25:48) = H_Load(:,i);
        h(49:72) = C_Load(:,i);
        h(97:120) = E_Load(:,i);
        h(121:144) = H_Load(:,i);
        h(145:168) = C_Load(:,i);
        T(169:192,1) = -PV(:,i)*PVcap(1);
        T(193:216,4) = -WT(:,i)*WTcap(1);
        T(217:240,2) = -PV(:,i)*PVcap(2);
        T(241:264,5) = -WT(:,i)*WTcap(2);
        %         h(265:288) = E_Load(:,i)*omigae;
        %         h(289:312) = E_Load(:,i)*omigae;
        %         h(313:336) = H_Load(:,i)*omigah;
        %         h(337:360) = H_Load(:,i)*omigah;
        %         h(361:384) = C_Load(:,i)*omigac;
        %         h(385:408) = C_Load(:,i)*omigac;
        flag = 0;
        %[A1,T1,c1,h1] = getpara(E_Load(:,i),H_Load(:,i),C_Load(:,i),PV(:,i),WT(:,i));
        %[b] = getb(E_Load(:,i),H_Load(:,i),C_Load(:,i),PV(:,i),WT(:,i),MpNchp,MpNashp,MpNghp,MpNeb,MpNgb,MpNac,MpNec,MpNpv,MpNwt,MpNES,MpNHS,MpNCS);
        b = h - T*MpCpntNum;

        for kk=spnum:-1:max(spnum-5,1)
            ii = mod(kk-1,totsp)+1;
            if (sp(ii).invB*b >= -1e-5)
                sp(ii).num = sp(ii).num + 1;
                e(iter,1) = e(iter) + CtgProb(1)*sp(ii).w*h;
                E(iter,:) = E(iter,:) + CtgProb(1)*sp(ii).w*T;
                plc(i,1) =  CtgProb(1)*sp(ii).w*b;
                flag = 1;
                break;
            end
        end
        if flag == 0
            spnum = spnum + 1;
            [sp(mod(spnum-1,totsp)+1)] = sp_mosekcal(A,b,c);
            e(iter,1) = e(iter) + CtgProb(1)*sp(mod(spnum-1,totsp)+1).w*h;
            E(iter,:) = E(iter,:) + CtgProb(1)*sp(mod(spnum-1,totsp)+1).w*T;
            plc(i,1) =  CtgProb(1)*sp(mod(spnum-1,totsp)+1).f;
        else
            if kk~=spnum
                tmp = sp(mod(kk-1,totsp)+1);
                sp(mod(kk-1,totsp)+1) = sp(mod(spnum-1,totsp)+1);
                sp(mod(spnum-1,totsp)+1) = tmp;
            end
        end
        numspnum(1,iter) = spnum;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nnnspnum=[];
    %% N-1
    sp(1:totsp) = struct('f',[],'invB',[],'w',[],'xb',[],'xn',[],'xbflag',[],'num',[]);
    
    for k=1:21
            TmpMpCpntNum = MpCpntNum;
            TmpMpCpntNum(k)=MpCpntNum(k)-1;
            spnum = 0;
            for i=1:365
                h(1:24) = E_Load(:,i);
                h(25:48) = H_Load(:,i);
                h(49:72) = C_Load(:,i);
                h(97:120) = E_Load(:,i);
                h(121:144) = H_Load(:,i);
                h(145:168) = C_Load(:,i);
                T(169:192,1) = -PV(:,i)*PVcap(1);
                T(193:216,4) = -WT(:,i)*WTcap(1); 
                T(217:240,2) = -PV(:,i)*PVcap(2);
                T(241:264,5) = -WT(:,i)*WTcap(2);
                %                 h(265:288) = E_Load(:,i)*omigae;
                %                 h(289:312) = E_Load(:,i)*omigae;
                %                 h(313:336) = H_Load(:,i)*omigah;
                %                 h(337:360) = H_Load(:,i)*omigah;
                %                 h(361:384) = C_Load(:,i)*omigac;
                %                 h(385:408) = C_Load(:,i)*omigac;
                flag = 0;

                b = h - T*TmpMpCpntNum;
                
                h1 = b + T*MpCpntNum;
                %h1 = b + T*MpCpntNum - T*MpCpntNumyy;
                for kk=spnum:-1:max(spnum-5,1)
                    ii = mod(kk-1,totsp)+1;
                    if (sp(ii).invB*b >= -1e-5)
                        sp(ii).num = sp(ii).num + 1;
                        e(iter,1) = e(iter) + CtgProb(k+1)*sp(ii).w*h1;
                        E(iter,:) = E(iter,:) + CtgProb(k+1)*sp(ii).w*T;
                        plc(i,1) =  CtgProb(2)*sp(ii).w*b;
                        flag = 1;
                        break;
                    end
                end
                if flag == 0
                    spnum = spnum + 1;
                    [sp(mod(spnum-1,totsp)+1)] = sp_mosekcal(A,b,c);
                    e(iter,1) = e(iter) + CtgProb(k+1)*sp(mod(spnum-1,totsp)+1).w*h1;
                    E(iter,:) = E(iter,:) + CtgProb(k+1)*sp(mod(spnum-1,totsp)+1).w*T;
                    plc(i,1) =  CtgProb(2)*sp(mod(spnum-1,totsp)+1).f;
                else
                    if kk~=spnum
                        tmp = sp(mod(kk-1,totsp)+1);
                        sp(mod(kk-1,totsp)+1) = sp(mod(spnum-1,totsp)+1);
                        sp(mod(spnum-1,totsp)+1) = tmp;
                    end
                end
            end
            numspnum(k+1,iter) = spnum;
    end
%     %% N-2
%     for k=1:20
%         TmpMpCpntNum = MpCpntNum;
%         TmpMpCpntNum(k)=MpCpntNum(k)-1;
%         for j =k+1:21
%             TmpMpCpntNum(j)=MpCpntNum(j)-1;
%             spnum = 0;
%             for i=1:365
%                 h(1:24) = E_Load(:,i);
%                 h(25:48) = H_Load(:,i);
%                 h(49:72) = C_Load(:,i);
%                 h(97:120) = E_Load(:,i);
%                 h(121:144) = H_Load(:,i);
%                 h(145:168) = C_Load(:,i);
%                 T(169:192,1) = -PV(:,i)*PVcap(1);
%                 T(193:216,4) = -WT(:,i)*WTcap(1);
%                 T(217:240,2) = -PV(:,i)*PVcap(2);
%                 T(241:264,5) = -WT(:,i)*WTcap(2);
%                 %                 h(265:288) = E_Load(:,i)*omigae;
%                 %                 h(289:312) = E_Load(:,i)*omigae;
%                 %                 h(313:336) = H_Load(:,i)*omigah;
%                 %                 h(337:360) = H_Load(:,i)*omigah;
%                 %                 h(361:384) = C_Load(:,i)*omigac;
%                 %                 h(385:408) = C_Load(:,i)*omigac;
%                 flag = 0;
%                 b = h - T*TmpMpCpntNum;
%                 h1 = b + T*MpCpntNum;
% 
%                 for kk=spnum:-1:max(spnum-5,1)
%                     ii = mod(kk-1,totsp)+1;
%                     if (sp(ii).invB*b >= -1e-5)
%                         sp(ii).num = sp(ii).num + 1;
%                         e(iter,1) = e(iter) + 100*CtgProb(2)*CtgProb(2)*sp(ii).w*h1;
%                         E(iter,:) = E(iter,:) + 100*CtgProb(2)*CtgProb(2)*sp(ii).w*T;
%                         plc(i,1) =  100*CtgProb(2)*CtgProb(2)*sp(ii).w*b;
%                         flag = 1;
%                         break;
%                     end
%                 end
%                 if flag == 0
%                     spnum = spnum + 1;
%                     [sp(mod(spnum-1,totsp)+1)] = sp_mosekcal(A,b,c);
%                     e(iter,1) = e(iter) + 100*CtgProb(2)*CtgProb(2)*sp(mod(spnum-1,totsp)+1).w*h1;
%                     E(iter,:) = E(iter,:) + 100*CtgProb(2)*CtgProb(2)*sp(mod(spnum-1,totsp)+1).w*T;
%                     plc(i,1) =  100*CtgProb(2)*100*CtgProb(2)*sp(mod(spnum-1,totsp)+1).f;
%                 else
%                     if kk~=spnum
%                         tmp = sp(mod(kk-1,totsp)+1);
%                         sp(mod(kk-1,totsp)+1) = sp(mod(spnum-1,totsp)+1);
%                         sp(mod(spnum-1,totsp)+1) = tmp;
%                     end
%                 end
%             end
%             nnnspnum = [nnnspnum,spnum];
%         end
% 
%     end
%     %% N-3
%     for k=1:19
%         TmpMpCpntNum = MpCpntNum;
%         TmpMpCpntNum(k)=MpCpntNum(k)-1;
%         for j =k+1:20
%             TmpMpCpntNum(j)=MpCpntNum(j)-1;
%             for kk =j+1:21
%                 TmpMpCpntNum(kk)=MpCpntNum(kk)-1;
%                 spnum = 0;
%                 for i=1:365
%                     h(1:24) = E_Load(:,i);
%                     h(25:48) = H_Load(:,i);
%                     h(49:72) = C_Load(:,i);
%                     h(97:120) = E_Load(:,i);
%                     h(121:144) = H_Load(:,i);
%                     h(145:168) = C_Load(:,i);
%                     T(169:192,1) = -PV(:,i)*PVcap(1);
%                     T(193:216,4) = -WT(:,i)*WTcap(1);
%                     T(217:240,2) = -PV(:,i)*PVcap(2);
%                     T(241:264,5) = -WT(:,i)*WTcap(2);
%                     %                 h(265:288) = E_Load(:,i)*omigae;
%                     %                 h(289:312) = E_Load(:,i)*omigae;
%                     %                 h(313:336) = H_Load(:,i)*omigah;
%                     %                 h(337:360) = H_Load(:,i)*omigah;
%                     %                 h(361:384) = C_Load(:,i)*omigac;
%                     %                 h(385:408) = C_Load(:,i)*omigac;
%                     flag = 0;
%                     b = h - T*TmpMpCpntNum;
%                     h1 = b + T*MpCpntNum;
% 
%                     for kk=spnum:-1:max(spnum-5,1)
%                         ii = mod(kk-1,totsp)+1;
%                         if (sp(ii).invB*b >= -1e-5)
%                             sp(ii).num = sp(ii).num + 1;
%                             e(iter,1) = e(iter) + 100*CtgProb(2)*CtgProb(2)*CtgProb(2)*sp(ii).w*h1;
%                             E(iter,:) = E(iter,:) + 100*CtgProb(2)*CtgProb(2)*CtgProb(2)*sp(ii).w*T;
%                             plc(i,1) =  100*CtgProb(2)*CtgProb(2)*CtgProb(2)*sp(ii).w*b;
%                             flag = 1;
%                             break;
%                         end
%                     end
%                     if flag == 0
%                         spnum = spnum + 1;
%                         [sp(mod(spnum-1,totsp)+1)] = sp_mosekcal(A,b,c);
%                         e(iter,1) = e(iter) + 100*CtgProb(2)*CtgProb(2)*CtgProb(2)*sp(mod(spnum-1,totsp)+1).w*h1;
%                         E(iter,:) = E(iter,:) + 100*CtgProb(2)*CtgProb(2)*CtgProb(2)*sp(mod(spnum-1,totsp)+1).w*T;
%                         plc(i,1) =  100*CtgProb(2)*CtgProb(2)*100*CtgProb(2)*sp(mod(spnum-1,totsp)+1).f;
%                     else
%                         if kk~=spnum
%                             tmp = sp(mod(kk-1,totsp)+1);
%                             sp(mod(kk-1,totsp)+1) = sp(mod(spnum-1,totsp)+1);
%                             sp(mod(spnum-1,totsp)+1) = tmp;
%                         end
%                     end
%                 end
%             end
%         end
% 
%     end

    %w(iter) = e(iter) - E(iter,:)* (MpCpntNum + MpCpntNumy - 1);
    w(iter) = e(iter) - E(iter,:)* MpCpntNum;
    display([' w: ',num2str(w(iter)), ' z: ',num2str(Mpz(iter)),]);

    if w(iter) - Mpz(iter) < 0.01
        break
    end
end
toc

