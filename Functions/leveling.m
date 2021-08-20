% This function enable to flatten the surface
% INPUT: data is a 2D matrix
function data_leveled = leveling(data)

%we start with H(n,m) = A*(n-1)+B*(m-1)+H(1,1)
% where n and m are index of the matrix (>= 1)
data = data - data(1,1); % Here H is now H(n,m) = A*(n-1)+B*(m-1)
% To get B, I fit the row n = 1:
c = polyfit((0:size(data,2)-1),data(1,:),1); % linear fit ax+b
B = c(1); % Only the slope
% To get A, I fit the first column m = 1
c = polyfit((0:size(data,2)-1),data(:,1)',1); % linear fit ax+b
A = c(1); % Only the slope
% The glass surface matrix is then:
[M,N] = meshgrid(0:size(data,1)-1,0:size(data,2)-1);
dataref = A*N + B*M;
data_leveled = data - dataref;
end