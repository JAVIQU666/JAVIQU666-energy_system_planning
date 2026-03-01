function [A,T,c,h] =getparaDR(E_Load,H_Load,C_Load,PV,WT,omigae,omigah,omigac) %传入子问题产生的割集
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Price_gas = 0.4588; 

% for i=1:23
%     Price_gas = [Price_gas,0.01088+0.05*i];
% end
%Price_ele = [0.3818,0.3818,0.3818,0.3818,0.3818,0.3818,0.3818,1.3222,0.8395,0.8395,0.8395,1.3222,1.3222,1.3222,1.3222,1.3222,0.8395,0.8395,0.8395,1.3222,1.3222,1.3222,0.8395,0.8395]/0.5+0.5;
Price_ele = [0.3818,0.4018,0.4218,0.4418,0.4618,0.4818,0.5018,1.5222,0.9095,0.8595,0.7595,1.1022,1.1222,1.3222,1.1422,1.1622,0.9705,0.8695,0.8295,1.2722,1.1772,1.5522,0.7295,0.6495]/0.5+0.5;

Equip_set();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 变量声明
% Nchp = [0 0 0];
% Nashp = [0 0 0];
% Nghp = [0 0 0];
% Neb = [0 0 0];
% Ngb = [0 0 0];
% Nac = [0 0 0];
% Nec = [0 0 0];
% Npv = [0 0 0];
% Nwt = [0 0 0];
% 
% NES = 0;
% NHS = 0;
% NCS = 0;

Npv = intvar(1,2);
Nwt = intvar(1,2);
Nchp = intvar(1,2);
Nashp = intvar(1,2);
Nghp = intvar(1,2);
Neb = intvar(1,2);
Ngb = intvar(1,2);
Nac = intvar(1,2);
Nec = intvar(1,2);
NES = intvar(1,1);
NHS = intvar(1,1);
NCS = intvar(1,1);

Pac = sdpvar(24,2);
Pec = sdpvar(24,2);
Pgird = sdpvar(24,1);
Pgas = sdpvar(24,1);
Pchp = sdpvar(24,2);
Pashp = sdpvar(24,2);
Pghp = sdpvar(24,2);
Peb = sdpvar(24,2);
Pgb = sdpvar(24,2);

Ppv = sdpvar(24,2);
Pwt = sdpvar(24,2);
Ech = sdpvar(24,1);
Edis = sdpvar(24,1);
Hch = sdpvar(24,1);
Hdis = sdpvar(24,1);
Cch = sdpvar(24,1);
Cdis = sdpvar(24,1);

DREup = sdpvar(24,1);
DRHup = sdpvar(24,1);
DRCup = sdpvar(24,1);
DREdn = sdpvar(24,1);
DRHdn = sdpvar(24,1);
DRCdn = sdpvar(24,1);

Eloss = sdpvar(24,1);
Hloss = sdpvar(24,1);
Closs = sdpvar(24,1);


Constraints = [];
Constraints = [Constraints, Pgird + Pchp*CHPeffg2e' - Pashp*[1 1]' - Pghp*[1 1]' - Peb*[1 1]' - Pec*[1 1]' +  Ppv*PVeff' + Pwt*WTeff' + Edis - Ech == E_Load - DREup + DREdn - Eloss];

Constraints = [Constraints, Pchp*CHPeffg2h' + Pashp*ASHPeff' + Pghp*GHPeff' + Peb*EBeff' + Pgb*GBeff' - Pac*[1 1]' + Hdis - Hch == H_Load - DRHup + DRHdn - Hloss];

Constraints = [Constraints, Pec*ECeff' + Pac*ACeff' + Cdis - Cch == C_Load + DRCup - DRCdn - Closs];

Constraints = [Constraints, Pgas == Pchp*[1 1]' + Pgb*[1 1]'];

Constraints = [Constraints,  Eloss <= E_Load];
Constraints = [Constraints,  Hloss <= H_Load];
Constraints = [Constraints,  Closs <= C_Load];

for i=1:2
    Constraints = [Constraints,  Ppv(:,i) <= PV*Npv(i).*PVcap(i)];
    Constraints = [Constraints,  Pwt(:,i) <= WT*Nwt(i).*WTcap(i)];
end
Constraints = [Constraints,  DREup <= E_Load*omigae];
Constraints = [Constraints,  DREdn <= E_Load*omigae];

Constraints = [Constraints,  DRHup <= H_Load*omigah];
Constraints = [Constraints,  DRHdn <= H_Load*omigah];

Constraints = [Constraints,  DRCup <= C_Load*omigac];
Constraints = [Constraints,  DRCdn <= C_Load*omigac];

for i=1:2
    Constraints = [Constraints,  Pchp(:,i) <= Nchp(i).*CHPcap(i)];
    Constraints = [Constraints,  Pashp(:,i) <= Nashp(i).*ASHPcap(i)];
    Constraints = [Constraints,  Pghp(:,i) <= Nghp(i).*GHPcap(i)];
    Constraints = [Constraints,  Peb(:,i) <= Neb(i).*EBcap(i)];
    Constraints = [Constraints,  Pgb(:,i) <= Ngb(i).*GBcap(i)]; 
    Constraints = [Constraints,  Pac(:,i) <= Nac(i).*ACcap(i)];
    Constraints = [Constraints,  Pec(:,i) <= Nec(i).*ECcap(i)];

end

Constraints = [Constraints,  Pgird <= pgridmax];
Constraints = [Constraints,  Pgas <= pgas];

% Constraints = [Constraints, Esoc(24,:) == NES*ESsocinit*EScap];
% Constraints = [Constraints, Esoc(1,:) == NES*ESsocinit*EScap + 0.9*Ech(1,:) - Edis(1,:)/0.9];
% Constraints = [Constraints, Esoc(2:24,:) == Esoc(1:23,:) + 0.9*Ech(2:24,:) - Edis(2:24,:)/0.9];
% 
% Constraints = [Constraints, Hsoc(24,:) == NHS*HSsocinit*HScap];
% Constraints = [Constraints, Hsoc(1,:) == NHS*HSsocinit*HScap + 0.9*Hch(1,:) - Hdis(1,:)/0.9];
% Constraints = [Constraints, Hsoc(2:24,:) == Hsoc(1:23,:) + 0.9*Hch(2:24,:) - Hdis(2:24,:)/0.9];
% 
% Constraints = [Constraints, Csoc(24,:) == NCS*CSsocinit*CScap];
% Constraints = [Constraints, Csoc(1,:) == NCS*CSsocinit*CScap + 0.9*Cch(1,:) - Cdis(1,:)/0.9];
% Constraints = [Constraints, Csoc(2:24,:) == Csoc(1:23,:) + 0.9*Cch(2:24,:) - Cdis(2:24,:)/0.9];

for j=1:24
    temp = 0;
    for k=1:j
        temp = temp + 0.9*Ech(k,:) - Edis(k,:)/0.9;
    end
    if j ~= 24
        Constraints = [Constraints, NES*ESSocmin*EScap-NES*ESsocinit*EScap <= temp <= NES*ESSocmax*EScap-NES*ESsocinit*EScap];
    end
    if j == 24
        Constraints = [Constraints, temp <= 0];
        Constraints = [Constraints, temp >= 0];
    end
end

for j=1:24
    temp = 0;
    for k=1:j
        temp = temp + 0.9*Hch(k,:) - Hdis(k,:)/0.9;
    end
    if j ~= 24
        Constraints = [Constraints, NHS*HSSocmin*HScap-NHS*HSsocinit*HScap <= temp <= NHS*HSSocmax*HScap-NHS*HSsocinit*HScap];
    end
    if j == 24
        Constraints = [Constraints, temp <= 0];
        Constraints = [Constraints, temp >= 0];
    end
end

for j=1:24
    temp = 0;
    for k=1:j
        temp = temp + 0.9*Cch(k,:) - Cdis(k,:)/0.9;
    end
    if j ~= 24
        Constraints = [Constraints, NCS*CSSocmin*CScap-NCS*CSsocinit*CScap <= temp <= NCS*CSSocmax*CScap-NCS*CSsocinit*CScap];
    end
    if j == 24
        Constraints = [Constraints, temp <= 0];
        Constraints = [Constraints, temp >= 0];
    end
end
%% DR
for j=1:24
    temp = 0;
    for k=1:j
        temp = temp + 0.999*DREup(k,:) - DREdn(k,:)/0.999;
    end
%     if j ~= 24
%         Constraints = [Constraints, NES*ESSocmin*EScap-NES*ESsocinit*EScap <= temp <= NES*ESSocmax*EScap-NES*ESsocinit*EScap];
%     end
    if j == 24
        Constraints = [Constraints, temp <= 0];
        Constraints = [Constraints, temp >= 0];
    end


for j=1:24
    temp = 0;
    for k=1:j
        temp = temp + 0.999*DRHup(k,:) - DRHdn(k,:)/0.999;
    end
%     if j ~= 24
%         Constraints = [Constraints, NES*ESSocmin*EScap-NES*ESsocinit*EScap <= temp <= NES*ESSocmax*EScap-NES*ESsocinit*EScap];
%     end
    if j == 24
        Constraints = [Constraints, temp <= 0];
        Constraints = [Constraints, temp >= 0];
    end
end


for j=1:24
    temp = 0;
    for k=1:j
        temp = temp + 0.999*DRCup(k,:) - DRCdn(k,:)/0.999;
    end
%     if j ~= 24
%         Constraints = [Constraints, NES*ESSocmin*EScap-NES*ESsocinit*EScap <= temp <= NES*ESSocmax*EScap-NES*ESsocinit*EScap];
%     end
    if j == 24
        Constraints = [Constraints, temp <= 0];
        Constraints = [Constraints, temp >= 0];
    end
end


%%
Constraints = [Constraints,  Ech <= NES*ESchrate*EScap];
Constraints = [Constraints,  Edis <= NES*ESdisrate*EScap];
%Constraints = [Constraints, NES*ESSocmin <= Esoc(1:23,:) <= NES*ESSocmax];

Constraints = [Constraints,  Hch <= NHS*HSchrate*HScap];
Constraints = [Constraints,  Hdis <= NHS*HSdisrate*HScap];
%Constraints = [Constraints, NHS*HSSocmin <= Hsoc(1:23,:) <= NHS*HSSocmax];

Constraints = [Constraints,  Cch <= NCS*CSchrate*CScap];
Constraints = [Constraints,  Cdis <= NCS*CSdisrate*CScap];
%Constraints = [Constraints, NCS*CSSocmin <= Csoc(1:23,:) <= NCS*CSSocmax];



Objective = Price_ele*Pgird + sum(Price_gas*Pgas) + sum(Pchp*CHPmain') + sum(Pashp*ASHPmain') + sum(Pghp*GHPmain') + ...
           sum(Peb*EBmain') + sum(Pgb*GBmain') + sum(Pac*ACmain') + sum(Pec*ECmain') + sum(Ppv*PVmain') + ...
           sum(Pwt*WTmain') + sum(ESmain*(Ech+Edis)) + sum(HSmain*(Hch+Hdis)) + sum(CSmain*(Cch+Cdis)) + ...
           + sum(50*(DREup+DREdn)) + sum(100*(DRHup+DRHdn)) + sum(50*(DRCup+DRCdn)) + ...
           sum(Eloss*900) + sum(Hloss*900) + sum(Closs*900);

options = sdpsettings('solver','gurobi','verbose',0);
[model,recoverymodel,diagnostic,internalmodel] = export(Constraints,Objective);
eq = size(find(model.sense=='='),1);
ineq = size(find(model.sense=='<'),1);
A1 = [full(model.A),[zeros(eq,ineq);eye(ineq)]];
A = A1(:,22:end);
T = A1(:,1:21);
h = model.rhs;% h+Tx
c = [model.obj(22:end);zeros(ineq,1)];
A = sparse(A);
T = sparse(T);
h = sparse(h);% h+Tx
c = sparse(c);
end

