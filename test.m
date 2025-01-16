% 载入电力系统数据
load IEEE8NodeData.mat
%%
slack = 1;

[x, lmp, lineflow] = dcopf_lmp(IEEE8NodeData.gexdata, IEEE8NodeData.dexdata, IEEE8NodeData.busdata, IEEE8NodeData.linedata, slack);
%% 显示结果
disp('发电机出力 (MW):');
disp(x')

disp('节点边际电价 ($/MWh):');
disp(lmp')

disp('线路功率传输 (MW):');
disp(lineflow')
%% 绘制示意图
% 调用函数绘制电力系统示意图
plot_power_system(IEEE8NodeData.busdata, IEEE8NodeData.linedata, IEEE8NodeData.gexdata, IEEE8NodeData.dexdata);

plot_power_system_3d(IEEE8NodeData.busdata, IEEE8NodeData.linedata, IEEE8NodeData.gexdata, IEEE8NodeData.dexdata, IEEE8NodeData.node_prices)