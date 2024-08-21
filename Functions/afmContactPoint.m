% This function finds the contact point in Force-Distance curve, as
% described by Benitez et al., 2013. The R package has been converted into
% a matlab file and adapted.
% reference:
% Benitez R., Moreno-Flores S., Bolos V. J. and Toca-Herrera J.L. (2013). "A 
% new automatic contact point detection algorithm for AFM force curves". 
% Microscopy research and technique, \strong{76} (8), pp. 870-876.
% 
% v0: Antoine ALLARD, 15/06/2021
%% INPUTS
% force: array Nx1 that contains the force data
% distance: array Nx1 that contains the distance data
% params: structure that contains the following parameters:
% Window: width of the window for the local regression (number of points)
% Mul1: first multiplier for the first alarm threshold
% Mul2: second multiplier for the second alarm threshold
% Lagdiff: lag for estimating the differences in Delta (or slopes) signal. By 
% default it takes the same value as the window width.
% Delta: Logical. If TRUE, then the statistic for determining the contact point is
% the differences between two consecutive values of the slope of the local regression
% line. If FALSE then the slope itself is used.
% Loess: Logical. If TRUE, a loess smoothing is done
% prior to the determination of the contact point.
% Span: The span of the smoothing.
% MinNoise and Max Noise: interval for calculating the noise
% 
%% OUTPUTS
% CP: the contact point value.
% iCP: the position in the array for the contact point value.
% delta: the delta signal.
% noise: the noise of the delta signal
%%
function [CP,newForce,iCP,delta,noise] = afmContactPoint(force,distance,params)

n = length(force);

% Smoothing the data
if params.Loess
    window = params.Span*n;
    method = 'loess';
    newForce = smoothdata(force,1,method,window);
else % No smoothing
    newForce = force;
end

% Creating the arrays: 
% bRoll -> slopes in a rolling windows
% delta -> change in slopes.
width = params.Window;
bRoll = movingslope(newForce,width);
delta = [bRoll(1+params.Lagdiff:end);nan(params.Lagdiff,1)]-bRoll; % To replace lagmatrix
% delta = lagmatrix(bRoll,-params.Lagdiff)-bRoll;
if ~params.Delta
    delta = bRoll;
end
delta(1:width) = 0;
delta(isnan(delta)) = 0;

noise = std(delta(max(int16(n*params.MinNoise),1):int16(n*params.MaxNoise)),'omitnan');
tol1 = params.Mul1*noise;
tol2 = params.Mul2*noise;

if tol2 > max(abs(delta))
    tol2 = max(abs(delta)) - 0.05*(max(abs(delta))-min(abs(delta)));
end

idxGrTol2 = find(abs(delta) > tol2,1,'first');
idxSmTol1 = find(abs(delta) < tol1);
iCP = idxSmTol1(find(idxSmTol1 < idxGrTol2,1,'last'));

if iCP > 1 && all(delta(iCP))
    eps = (-tol1 + delta(iCP+1))/(delta(iCP+1)-delta(iCP));
else
    eps = 0;
end
z_contact = distance(iCP);
z_contact = z_contact + eps*(distance(iCP+1)-z_contact);
CP = z_contact;

end