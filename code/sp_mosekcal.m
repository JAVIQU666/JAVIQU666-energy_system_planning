function [sp] = sp_mosekcal(a,b,c)
%     prob.a=A;
%     prob.c=c';
%     prob.blc=b;
%     prob.buc=b;
    prob.a=a;
    prob.c=c;
    prob.blc=b;
    prob.buc=b;
    
    prob.blx=zeros(size(c,1),1);
    prob.bux=[];
    cmd='minimize echo(0)';
    mosek_opt.MSK_IPAR_NUM_THREADS =  1;
    
    [~,res]=mosekopt(cmd,prob,mosek_opt);
    % [~,res]=mosekopt(cmd,prob);
    %     sp.x = res.sol.bas.xx;
    sp.f=res.sol.bas.pobjval; %
    sp.xbflag = res.sol.bas.skx(:,1)=='B';  %
    cb=find(res.sol.bas.skc(:,1)=='B');
    flagskc = res.sol.bas.skc(:,1)=='B';
    flagskx = res.sol.bas.skx(:,1)=='B';

%     x = sdpvar(size(c,1),1);
%       C = [a*x == b;x>=0];
%         o = c'*x;
%         ops=sdpsettings('verbose',0,'solver','gurobi','usex0',0);
%     solution = optimize(C, o, ops);
%      reshape(value(x(1:24*35)),24,35)
    
%     if size(find(sp.xbflag == 1),1) ~= size(a,1)
%         xn = find(sp.xbflag == 0);
%         temp = find(a(xn(2),:)~=0);
%         sp.xbflag(temp(2)) = 1;
%     end
    sp.xb = find(sp.xbflag == 1);
    sp.xn = find(sp.xbflag == 0);

    sp.invB=inv(a(:,sp.xb));
    sp.w=c(sp.xb)'/a(:,sp.xb);
    %sp.w=c(sp.xb)*sp.invB;
    sp.w = sp.w;
    sp.num = 1;

end

