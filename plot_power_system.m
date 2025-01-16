function plot_power_system(busdata, linedata, gexdata, dexdata)
    % 绘制电力系统示意图
    % 输入参数：
    %   busdata: 母线数据矩阵
    %   linedata: 线路数据矩阵
    %   gexdata: 发电机数据矩阵
    %   dexdata: 负荷数据矩阵

    % 创建图形窗口
    figure;
    hold on;
    title('电力系统示意图', 'FontSize', 14);
    axis off; % 隐藏坐标轴

    % 创建图的节点和边
    num_buses = size(busdata, 1);
    nodes = (1:num_buses)';
    edges = linedata(:, 1:2); % 提取起始和终止母线
    weights = linedata(:, 7); % 线路容量作为权重

    % 创建 graph 对象
    G = graph(edges(:, 1), edges(:, 2), weights);

    % 使用自动布局绘制图
    h = plot(G, 'Layout', 'force', 'LineWidth', 2, ...
             'EdgeColor', [0.5 0.5 0.5], 'NodeLabel', {});

    % 获取节点位置
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

    % 绘制节点符号
    for i = 1:num_buses
        x = node_positions(i, 1);
        y = node_positions(i, 2);
        
        switch node_type(i)
            case 1 % 只有发电机
                rectangle('Position', [x-0.1, y-0.1, 0.2, 0.2], 'Curvature', [1, 1], ...
                          'EdgeColor', 'r', 'LineWidth', 1.5, 'FaceColor', [1 0.8 0.8]);
                text(x, y, 'G', 'FontSize', 10, 'Color', 'r', 'HorizontalAlignment', 'center');
            case 2 % 只有负荷
                patch([x-0.1, x+0.1, x], [y-0.1, y-0.1, y+0.1], ...
                      'g', 'EdgeColor', 'k', 'LineWidth', 1.5, 'FaceColor', [0.8 1 0.8]);
                text(x, y, 'L', 'FontSize', 10, 'Color', 'g', 'HorizontalAlignment', 'center');
            case 3 % 既有发电机又有负荷
                rectangle('Position', [x-0.1, y-0.1, 0.2, 0.2], 'EdgeColor', 'b', 'LineWidth', 1.5, 'FaceColor', [0.8 0.8 1]);
                text(x, y, 'GL', 'FontSize', 10, 'Color', 'b', 'HorizontalAlignment', 'center');
            otherwise % 无发电机和负荷
                plot(x, y, 'ko', 'MarkerSize', 10, 'LineWidth', 2);
        end
        
        % 绘制母线标签
        text(x, y + 0.15, ['Bus ' num2str(busdata(i, 1))], ...
             'FontSize', 12, 'Color', 'k', 'HorizontalAlignment', 'center');
    end

    % 绘制线路标注（阻抗）
    for i = 1:size(linedata, 1)
        from_bus = linedata(i, 1);
        to_bus = linedata(i, 2);
        
        % 计算线路中点
        mid_x = (node_positions(from_bus, 1) + node_positions(to_bus, 1)) / 2;
        mid_y = (node_positions(from_bus, 2) + node_positions(to_bus, 2)) / 2;
        
        % 计算线路角度
        dx = node_positions(to_bus, 1) - node_positions(from_bus, 1);
        dy = node_positions(to_bus, 2) - node_positions(from_bus, 2);
        angle = atan2(dy, dx); % 线路角度
        
        % 标注线路信息（与线路平行，偏移一定距离）
        offset_distance = 0.15; % 标注信息与线路的偏移距离
        text(mid_x - offset_distance * sin(angle), mid_y + offset_distance * cos(angle), ...
             sprintf('R=%.2f, X=%.2f', linedata(i, 3), linedata(i, 4)), ...
             'FontSize', 8, 'HorizontalAlignment', 'center', 'Rotation', angle * 180/pi, ...
             'BackgroundColor', 'w', 'Margin', 1);
    end

    % 添加图例
    legend_labels = {'发电机 (G)', '负荷 (L)', '发电机+负荷 (GL)'};
    legend(legend_labels, 'Location', 'best', 'FontSize', 10);

    hold off;
end