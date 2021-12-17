function M = catnan3(A,B)
if isempty(A)
    M = B;
elseif isempty(B)
    M = A;
elseif size(A,1) == size(B,1) && size(A,2) == size(B,2) && size(A,3) == size(B,3)
    M = cat(3,A,B);
else
    a = [size(A,1) size(A,2)];
    b = [size(B,1) size(B,2)];
    c = b - a;
    if c(1) > 0
        A(end+1:end+c(1),:,:) = NaN;
    elseif c(1) < 0
        B(end+1:end-c(1),:,:) = NaN;
    end
    if c(2) > 0
        A(:,end+1:end+c(2),:) = NaN;
    elseif c(2) < 0
        B(:,end+1:end-c(2),:) = NaN;
    end
    M = cat(3,A,B);
end