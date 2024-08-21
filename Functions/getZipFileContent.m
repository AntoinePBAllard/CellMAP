function data = getZipFileContent(zipFile,subfilename)
entry = zipFile.getEntry(subfilename);
inputStream  = zipFile.getInputStream(entry);

% % Extract the entries from the ZipFile.
% entries = zipFile.getEntries;
% 
% entryName = [];
% % Get Zip File Paths
% while entries.hasMoreElements && ~strcmp(entryName,subfilename)
%     entry = entries.nextElement;
%     entryName = char(entry.getName);
% end
% inputStream  = zipFile.getInputStream(entry);
%Read the contents of the file
buffer = java.io.ByteArrayOutputStream();
org.apache.commons.io.IOUtils.copy(inputStream, buffer);
data = char(typecast(buffer.toByteArray(), 'uint8')');

inputStream.close;