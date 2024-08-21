function data = getZipFileContentDat(zipFile,subDatfilename)

entry = zipFile.getEntry(subDatfilename);
inputStream  = zipFile.getInputStream(entry);

% Read the contents of the file
buffer = java.io.ByteArrayOutputStream();
org.apache.commons.io.IOUtils.copy(inputStream, buffer);
byteArray = buffer.toByteArray();

% Convert the byte array to a MATLAB uint8 array
byteArray = typecast(byteArray, 'uint8');

% Determine the number of integers in the buffer
numIntegers = numel(byteArray) / 4;

% Preallocate data array
data = zeros(numIntegers,1);

% Interpret bytes as integers (assuming big-endian)
for i = 1:numIntegers
     % Calculate the start index of the current integer
    startIdx = (i - 1) * 4 + 1;
    
    % Extract 4 bytes and convert to integer (considering big-endian)
    intBytes = byteArray(startIdx:startIdx+3); % Extract 4 bytes
    data(i) = typecast(flip(intBytes), 'int32');
end