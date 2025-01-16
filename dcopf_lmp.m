function [x, lmp, lineflow] = dcopf_lmp(gexdata, dexdata, busdata, linedata, slack)
% 基于直流最优潮流（DCOPF）模型计算节点边际电价（LMP）
% 输入参数：
%   gexdata - 发电机数据矩阵
%   dexdata - 负荷数据矩阵
%   busdata - 母线数据矩阵
%   linedata - 线路数据矩阵
%   slack - 平衡节点编号
% 输出参数：
%   x - 发电机出力 (MW)
%   lmp - 节点边际电价 ($/MWh)
%   lineflow - 线路功率传输 (MW)

% 计算发电转移分布因子（GSF）矩阵
sf = GenerationShiftFactor(linedata, busdata, slack); % 调用外部函数计算GSF矩阵
% 提取系统维度
nbus = size(busdata, 1); % 母线数量
nd = size(dexdata, 1);   % 负荷数量
ng = size(gexdata, 1);   % 发电机数量

% 提取线路容量
prat = linedata(:, 7);   % 每条线路的最大功率传输容量

% 创建发电机和负荷的关联矩阵
Ag = zeros(nbus, ng); % 发电机关联矩阵
Ad = zeros(nbus, nd); % 负荷关联矩阵

% 填充发电机关联矩阵 Ag（将发电机连接到母线）
for i = 1:nbus
    for j = 1:ng
        if gexdata(j, 4) == i % 检查发电机 j 是否连接到母线 i
            Ag(i, j) = 1;
        end
    end
end

% 填充负荷关联矩阵 Ad（将负荷连接到母线）
for i = 1:nbus
    for j = 1:nd
        if dexdata(j, 4) == i % 检查负荷 j 是否连接到母线 i
            Ad(i, j) = 1;
        end
    end
end

%% 构建直流最优潮流（DCOPF）问题
% 目标函数：最小化总发电成本
f = gexdata(:, 2)'; % 发电机的边际成本

% 等式约束：总发电量 = 总负荷
Aeq = -ones(1, ng); % 发电机出力的总和
Beq = -sum(busdata(:, 5)); % 系统中的总负荷

% 不等式约束：线路功率传输限制
A1 = sf * Ag; % 发电转移分布因子矩阵乘以发电机关联矩阵
pd = busdata(:, 5); % 每个母线的有功负荷
B1 = prat + sf * pd; % 线路功率的上限
B2 = prat - sf * pd; % 线路功率的下限

% 合并不等式约束
A = [A1; -A1]; % 线路功率限制的约束矩阵
B = [B1; B2];  % 线路功率的上下限

% 发电机出力限制
lb = gexdata(:, 5); % 发电机的最小出力
ub = gexdata(:, 6); % 发电机的最大出力
% 求解直流最优潮流问题
[x, fval, exitflag, output, lamda] = linprog(f, A, B, Aeq, Beq, lb, ub);

if exitflag == 1
    % 提取结果
    % 提取结果
    genergy = lamda.eqlin; % 等式约束的影子价格（LMP的能量分量）
    conjcost = (lamda.ineqlin' * [-sf; sf])'; % LMP的阻塞分量
    lmp = genergy + conjcost; % 节点边际电价（LMP）

    % 计算线路功率
    lineflow = sf * (Ag * x - pd); % 每条线路的功率传输
else
    error('优化问题未求解成功，请检查输入数据和约束条件。');
end
end