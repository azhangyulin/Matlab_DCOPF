function sf = GenerationShiftFactor(linedata, busdata, slack)
    % 计算发电转移因子矩阵（Generation Shift Factor Matrix）
    % 输入参数：
    %   linedata - 线路数据矩阵，包含起始节点、终止节点、电阻、电抗等信息
    %   busdata - 母线数据矩阵
    %   slack - 松弛节点编号
    % 输出参数：
    %   sf - 发电转移因子矩阵

    NL = length(linedata(:,1));  % 获取线路数量
    nbus = length(busdata(:,1)); % 获取母线数量
    sn = linedata(:,1);          % 线路的起始节点
    rn = linedata(:,2);          % 线路的终止节点
    X = linedata(:,4);           % 线路的电抗

    % 初始化导纳矩阵 y1
    y1 = zeros(nbus, nbus);

    % 形成负的导纳矩阵 [Y]
    for i = 1:NL
        y1(sn(i), rn(i)) = y1(sn(i), rn(i)) - 1/X(i);  % 填充非对角线元素
        y1(rn(i), sn(i)) = y1(rn(i), sn(i)) - 1/X(i);  % 对称填充非对角线元素
        y1(sn(i), sn(i)) = y1(sn(i), sn(i)) + 1/X(i);  % 更新对角线元素
        y1(rn(i), rn(i)) = y1(rn(i), rn(i)) + 1/X(i);  % 更新对角线元素
    end

    y = y1;  % 将 y1 赋值给 y

    % 处理松弛节点
    ns = slack;  % 获取松弛节点编号

    % 将第 nbus 行移动到第 ns 行
    y(ns, :) = y(nbus, :);

    % 将第 nbus 列移动到第 ns 列
    y(:, ns) = y(:, nbus);

    % 移除最后一行和最后一列，得到 [B']
    n = nbus - 1;
    Bp = y(1:n, 1:n);

    rec = inv(Bp);  % 计算 Bp 的逆矩阵

    % 初始化线路电抗矩阵 xx 和节点关联矩阵 node
    xx = zeros(NL, NL);
    node = zeros(NL, nbus);

    for i = 1:NL
        xx(i, i) = 1/X(i);  % 填充 xx 的对角线元素
        node(i, sn(i)) = 1;  % 起始节点标记为1
        node(i, rn(i)) = -1; % 终止节点标记为-1
    end

    % 处理节点关联矩阵中的松弛节点
    node(:, ns) = node(:, nbus);
    node(:, nbus) = [];

    % 计算发电转移因子矩阵 sf
    sf = xx * node * rec;

    % 恢复松弛节点列
    sf = [sf zeros(NL, 1)];
    sf(:, nbus) = sf(:, ns);
    sf(:, ns) = zeros(NL, 1);
end