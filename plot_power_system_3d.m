function plot_power_system_3d(busdata, linedata, gexdata, dexdata, node_prices)
    % 绘制三维电力系统示意图
    % 输入参数：
    %   busdata: 母线数据矩阵
    %   linedata: 线路数据矩阵
    %   gexdata: 发电机数据矩阵
    %   dexdata: 负荷数据矩阵
    %   node_prices: 节点电价矩阵，格式为 [节点编号, 电价]

    % 创建图形窗口
    figure;
    hold on;
    title('三维电力系统示意图', 'FontSize', 14);
    grid on;
    view(3); % 设置为三维视图

    % 创建图的节点和边
    num_buses = size(busdata, 1);
    nodes = (1:num_buses)';
    edges = linedata(:, 1:2); % 提取起始和终止母线
    weights = linedata(:, 7); % 线路容量作为权重

    % 创建 graph 对象
    G = graph(edges(:, 1), edges(:, 2), weights);

    % 使用自动布局获取节点位置
    h = plot(G, 'Layout', 'force', 'LineWidth', 2, ...
             'EdgeColor', [0.5 0.5 0.5], 'NodeLabel', {});
    node_positions = [h.XData', h.YData'];

    % 标记每个节点的属性（发电机、负荷或两者都有）
    node_type = zeros(num_buses, 1); % 0: 无, 1: 发电机, 2: 负荷, 3: 两者都有
    for i = 1:size(gexdata, 1)
        bus = gexdata(i, 4);
        node_type(bus) = node_type(bus) + 1; % 标记发电机
    end
    for i = 1:size(dexdata, 1)
        bus = dexdata(i, 4);
        node_type(bus) = node_type(bus) + 2; % 标记负荷
    end

    % 提取节点电价
    % 将 node_prices 转换为节点编号和电价的映射
    price_map = containers.Map(node_prices(:, 1), node_prices(:, 2));
    
    % 初始化电价向量
    prices = zeros(num_buses, 1);
    for i = 1:num_buses
        if isKey(price_map, busdata(i, 1)) % 检查节点编号是否存在
            prices(i) = price_map(busdata(i, 1)); % 获取对应电价
        else
            prices(i) = 0; % 如果节点编号不存在，电价设为 0
        end
    end

    % 绘制节点电价曲面
    [X, Y] = meshgrid(linspace(min(node_positions(:, 1)) - 0.5, max(node_positions(:, 1)) + 0.5, 200), ...
                      linspace(min(node_positions(:, 2)) - 0.5, max(node_positions(:, 2)) + 0.5, 200));
    Z = griddata(node_positions(:, 1), node_positions(:, 2), prices, X, Y, 'cubic');
    surf(X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.6);
    colormap parula; % 使用 parula 颜色映射
    colorbar;

    % 绘制节点符号（投影在 xy 平面）
    for i = 1:num_buses
        x = node_positions(i, 1);
        y = node_positions(i, 2);
        z = 0; % 投影在 xy 平面
        
        switch node_type(i)
            case 1 % 只有发电机
                plot3(x, y, z, 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'r');
                text(x, y, z, 'G', 'FontSize', 10, 'Color', 'k', 'HorizontalAlignment', 'center');
            case 2 % 只有负荷
                plot3(x, y, z, 'g^', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'g');
                text(x, y, z, 'L', 'FontSize', 10, 'Color', 'k', 'HorizontalAlignment', 'center');
            case 3 % 既有发电机又有负荷
                plot3(x, y, z, 'bs', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'b');
                text(x, y, z, 'GL', 'FontSize', 10, 'Color', 'k', 'HorizontalAlignment', 'center');
            otherwise % 无发电机和负荷
                plot3(x, y, z, 'ko', 'MarkerSize', 10, 'LineWidth', 2);
        end
        
        % 绘制母线标签
        text(x + 0.1, y, z + 0.15, ['Bus ' num2str(busdata(i, 1))], ...
             'FontSize', 10, 'Color', 'k', 'HorizontalAlignment', 'left');
    end

    % 绘制线路（投影在 xy 平面）
    for i = 1:size(linedata, 1)
        from_bus = linedata(i, 1);
        to_bus = linedata(i, 2);
        
        % 获取起点和终点的坐标
        x1 = node_positions(from_bus, 1);
        y1 = node_positions(from_bus, 2);
        z1 = 0; % 投影在 xy 平面
        
        x2 = node_positions(to_bus, 1);
        y2 = node_positions(to_bus, 2);
        z2 = 0; % 投影在 xy 平面
        
        % 绘制线路
        line([x1, x2], [y1, y2], [z1, z2], 'Color', 'k', 'LineWidth', 2);
    end

    % 添加图例
    legend_labels = {'发电机 (G)', '负荷 (L)', '发电机+负荷 (GL)'};
    legend(legend_labels, 'Location', 'best', 'FontSize', 10);

    hold off;
end