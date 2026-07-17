%% Rotational Center Analysis
% based on the trajectory of the oligomer center and the rotational angle
% evolution

clear;

%% 1. import file (.xls)
% see example file for format (5 columns: 'Time', 'X', 'Y', 'Angle', 'Distance')
filename = 'arc0_filtered.xls';
if ~exist(filename, 'file')
    error('no file can be found %s，plz check.', filename);
end

step = 3; % time interval for calculation

% create a subfolder for data storage
subFolderName = 'subfolder';
if ~exist(subFolderName, 'dir')
    mkdir(subFolderName);
end

% extract data from the imported file
dataTbl = readtable(filename);
Time = dataTbl.Time;
X = dataTbl.X;
Y = dataTbl.Y;
Angle_deg = dataTbl.Angle;

% convert angle unit from degree to rad
Angle_rad = unwrap(deg2rad(Angle_deg));

%% 2. calculation of ICR
idx1 = 1 : step : (length(Time) - step);
idx2 = idx1 + step;

numIntervals = length(idx1);
ICR_rel_x = NaN(numIntervals, 1);
ICR_rel_y = NaN(numIntervals, 1);
ICR_abs_x = NaN(numIntervals, 1);
ICR_abs_y = NaN(numIntervals, 1);
T_mid = zeros(numIntervals, 1);

for k = 1:numIntervals
    i1 = idx1(k);
    i2 = idx2(k);
    
    dt = Time(i2) - Time(i1);
    dX = X(i2) - X(i1);
    dY = Y(i2) - Y(i1);
    dTheta = Angle_rad(i2) - Angle_rad(i1);

    if abs(dTheta) > 1e-5
        ICR_rel_x(k) = -dY / dTheta;
        ICR_rel_y(k) = dX / dTheta;
        ICR_abs_x(k) = -dY / dTheta + (X(i2) + X(i1))/2;
        ICR_abs_y(k) = dX / dTheta + (Y(i2) + Y(i1))/2;
    end

    T_mid(k) = (Time(i1) + Time(i2)) / 2;
end

%% 3. save data
outputData = table(T_mid, ICR_abs_x, ICR_abs_y, ICR_rel_x, ICR_rel_y, ...
    'VariableNames', {'Time_s', 'ICR_Abs_X', 'ICR_Abs_Y', 'ICR_Rel_X', 'ICR_Rel_Y'});
writetable(outputData, fullfile(subFolderName, 'Rotation_Center_Results.csv'));

%% 4. data visualization
savePath = subFolderName;

figure('Color', 'w', 'Name', 'Absolute Path');
plot(X, Y, 'k--', 'LineWidth', 0.5, 'DisplayName', 'ROI Center Path'); hold on;
scatter(ICR_abs_x, ICR_abs_y, 15, T_mid, 'filled', 'DisplayName', 'ICR Absolute');
colorbar;
xlabel('X Position'); ylabel('Y Position');
title('Rotation Center Absolute Trajectory (Colored by Time)');
legend('Location', 'best');
grid on; axis equal;xlim([0,184]);ylim([0,148]);set(gca, 'YDir', 'reverse');
saveas(gcf, fullfile(savePath, 'ICR_Absolute_Path.png'));
savefig(fullfile(savePath, 'ICR_Absolute_Path.fig'));