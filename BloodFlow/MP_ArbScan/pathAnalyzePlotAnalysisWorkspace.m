
% time data
timeDataVars = whos('*time_axis');
cmd=sprintf('t = %s;',timeDataVars(1).name);
eval(cmd);
% diameter data
diameterDataVars = whos('*_diameter_um');
nDiameterLines = numel(diameterDataVars);
cmd = sprintf('nDataPoints = numel(%s);',diameterDataVars(1).name);
eval(cmd)
diameterData = zeros(nDataPoints,numel(diameterDataVars));
%gather
for iData = 1 : nDiameterLines
    cmd = sprintf('diameterData(:,%d) = %s;',iData,diameterDataVars(iData).name);
    eval(cmd);
end
%velocity
velocityDataVars = whos('*_radon_um_per_s');
nVelocityLines = numel(velocityDataVars);
% cmd = sprintf('nDataPoints = numel(%s);',velocityDataVars(1).name);
% eval(cmd)
velocityData = zeros(nDataPoints,numel(velocityDataVars));
%gather
for iData = 1 : nVelocityLines
    cmd = sprintf('velocityData(:,%d) = %s;',iData,velocityDataVars(iData).name);
    eval(cmd);
end
figure
subplot(3,1,1);
plot(t,diameterData);axis tight
title(thisFileBaseName,'Interpreter','none')
ylabel('Diameter (\mum)')
subplot(3,1,2);
plot(t,velocityData/1000);axis tight
xlabel('time(s)')
ylabel('Velocity (mm/s)')
legend
linkaxes(findobj(gcf,'type','axes'),'x')

% set(gcf,'name',);

export_fig([thisFileBaseName '.png'])

