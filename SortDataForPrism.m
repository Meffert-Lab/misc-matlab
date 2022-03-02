function SortDataForPrism

%-- CHANGE THESE PARAMS --%
%dayString = 'D3';
dayString = 'D7';
%dayString = 'D28';

%Select one combination of stainString and DataColumnName
stainString = 'MAP2';
%DataColumnName = sprintf("%s %s", 'VOL', stainString);
DataColumnName = sprintf("%s %s %s", 'VOL', 'IN', stainString);
%DataColumnName = sprintf("%s %s %s %s", 'VOL', 'IN', stainString, 'NORM');
%stainString = 'S100';
%DataColumnName = sprintf("%s %s", 'VOL', stainString);
%DataColumnName = sprintf("%s %s %s%s", 'VOL', 'IN', stainString, '-COLOC');
%DataColumnName = sprintf("%s %s %s%s %s", 'VOL', 'IN', stainString, '-COLOC', 'NORM');

FilenameCol = 'FILENAME';

%FileType = '.csv';
%FileType = '.xls';
FileType = '.xlsx';
%--                     --%

[inputFile, pathToFile] = uigetfile(sprintf('%s%s', '*', FileType));

if inputFile == 0
    msgbox('NO INPUT FILE');
    return;
end
if not(endsWith(inputFile, FileType))
    msgbox('WRONG FILE TYPE');
    return;
end

DataArray = readcell(sprintf('%s%s', pathToFile, inputFile));

intermediate = cellfun(@ismissing, DataArray, 'UniformOutput',false);
for a = 1:numel(intermediate)
    if length(cell2mat(intermediate(a))) > 1
        intermediate(a) = {false};
    end
end

for a = 1:numel(intermediate)
    if cell2mat(intermediate(a))
        DataArray(a) = {''};
    end
end

ColumnNames = DataArray(1,:);
ColumnNames(isempty(ColumnNames)) = '';
if contains(string(ColumnNames), FilenameCol) == zeros(size(ColumnNames))
    msgbox('FILENAME COL DOES NOT MATCH');
    return;
end
if contains(string(ColumnNames), DataColumnName) == zeros(size(ColumnNames))
    msgbox('DATA COL DOES NOT MATCH');
    return;
end

FilenameCol = find(contains(ColumnNames, FilenameCol), 1);
VolumeCol = find(contains(ColumnNames, DataColumnName), 1);

FilenameData = DataArray(:, FilenameCol);
FilenameData = FilenameData(2:end, :);
VolumeData = DataArray(:, VolumeCol);
VolumeData = VolumeData(2:end, :);

tempFilenameData = FilenameData;
tempVolumeData = VolumeData;
index = 1;

for a=1:numel(FilenameData)
    if strcmpi(FilenameData(a), '') || strcmpi(VolumeData(a), '')
        tempFilenameData(index:end - 1) = tempFilenameData(index+1:end);
        tempFilenameData = tempFilenameData(1:end - 1);
        tempVolumeData(index:end - 1) = tempVolumeData(index+1:end);
        tempVolumeData = tempVolumeData(1:end -1);
        index = index - 1;
        
    end
    index = index + 1;
end


FilenameData = tempFilenameData;
VolumeData = tempVolumeData;
DataToSort = [FilenameData, VolumeData];

ConditionType = extractBetween(FilenameData, 1, 4);

UniqueConditions = unique(ConditionType);
UniqueConditions = cell2mat(UniqueConditions);
NumOccurences = zeros(size(UniqueConditions, 1), 1);
for a = 1:size(UniqueConditions, 1)
    NumOccurences(a) = sum(count(ConditionType, UniqueConditions(a, :)));
end

TotalPadding = NumOccurences + 1;

CompareCols = [];

for a = 1:length(TotalPadding)
    CompareCols = vertcat(CompareCols, repmat(UniqueConditions(a, :), TotalPadding(a), 1));
end

ContraData = DataToSort(contains(FilenameData, "CONTRA", 'IgnoreCase',true), :);

SNIContraData = ContraData(startsWith(string(ContraData(:, 1)), dayString, 'IgnoreCase',true), :);
NaiveContraData = ContraData(startsWith(string(ContraData(:, 1)), "Naive", 'IgnoreCase',true), :);

IpsiData = DataToSort(contains(FilenameData, "IPSI",'IgnoreCase',true ), :);
NaiveIpsiData = IpsiData(startsWith(string(IpsiData(:, 1)), "Naive", 'IgnoreCase',true), :);

IpsiData = IpsiData(startsWith(string(IpsiData(:, 1)), dayString, 'IgnoreCase',true), :);

IpsiMiddleData = IpsiData(contains(IpsiData(:, 1), "MIDDLE", 'IgnoreCase',true), :);
IpsiStumpData = IpsiData(contains(IpsiData(:, 1), "STUMP", 'IgnoreCase',true), :);
IpsiProximalData = IpsiData(contains(IpsiData(:, 1), "PROXIMAL", 'IgnoreCase',true), :);
IpsiDistalData = IpsiData(contains(IpsiData(:, 1), "DISTAL", 'IgnoreCase',true), :);
IpsiProximalData = [IpsiProximalData; IpsiDistalData];
IpsiSuralData = IpsiData(contains(IpsiData(:, 1), "SURAL", 'IgnoreCase',true), :);

%ArraySizes = [size(SNIContraData), size(NaiveContraData), size(IpsiMiddleData), size(IpsiStumpData), size(IpsiProximalData), size(IpsiSuralData), size(NaiveIpsiData)];
% TODO: swap out "length" for size of 1st dim
MaximumSize = sum(TotalPadding);
if length(SNIContraData) < MaximumSize
    SNIContraData = vertcat(SNIContraData, repmat({'', NaN}, MaximumSize - length(SNIContraData), 1));
end
if length(NaiveContraData) < MaximumSize
    NaiveContraData = vertcat(NaiveContraData, repmat({'', NaN}, MaximumSize - length(NaiveContraData), 1));
end
if length(IpsiMiddleData) < MaximumSize
    IpsiMiddleData = vertcat(IpsiMiddleData, repmat({'', NaN}, MaximumSize - length(IpsiMiddleData), 1));
end
if length(IpsiStumpData) < MaximumSize
    IpsiStumpData = vertcat(IpsiStumpData, repmat({'', NaN}, MaximumSize - length(IpsiStumpData), 1));
end
if length(IpsiProximalData) < MaximumSize
    IpsiProximalData = vertcat(IpsiProximalData, repmat({'', NaN}, MaximumSize - length(IpsiProximalData), 1));
end
if length(IpsiSuralData) < MaximumSize
    IpsiSuralData = vertcat(IpsiSuralData, repmat({'', NaN}, MaximumSize - length(IpsiSuralData), 1));
end
if length(NaiveIpsiData) < MaximumSize
    NaiveIpsiData = vertcat(NaiveIpsiData, repmat({'', NaN}, MaximumSize - length(NaiveIpsiData), 1));
end

for b = 1:length(CompareCols)
    if not(startsWith(SNIContraData(b, 1), char(CompareCols(b, :))))
        SNIContraData(b+1:end, :) = SNIContraData(b:end-1, :);
        SNIContraData(b, 1:2) = {'', NaN};
    end
    if not(startsWith(NaiveContraData(b, 1), CompareCols(b, :)))
        NaiveContraData(b+1:end, :) = NaiveContraData(b:end-1, :);
        NaiveContraData(b, 1:2) = {'', NaN};
    end
    if not(startsWith(NaiveIpsiData(b, 1), CompareCols(b, :)))
        NaiveIpsiData(b+1:end, :) = NaiveIpsiData(b:end-1, :);
        NaiveIpsiData(b, 1:2) = {'', NaN};
    end
    if not(startsWith(IpsiMiddleData(b, 1), CompareCols(b, :)))
        IpsiMiddleData(b+1:end, :) = IpsiMiddleData(b:end-1, :);
        IpsiMiddleData(b, 1:2) = {'', NaN};
    end
    if not(startsWith(cell2mat(IpsiStumpData(b, 1)), CompareCols(b, :)))
        IpsiStumpData(b+1:end, :) = IpsiStumpData(b:end-1, :);
        IpsiStumpData(b, 1:2) = {'', NaN};
    end
    if not(startsWith(IpsiProximalData(b, 1), CompareCols(b, :)))
        IpsiProximalData(b+1:end, :) = IpsiProximalData(b:end-1, :);
        IpsiProximalData(b, 1:2) = {'', NaN};
    end
    if not(startsWith(IpsiSuralData(b, 1), CompareCols(b, :)))
        IpsiSuralData(b+1:end, :) = IpsiSuralData(b:end-1, :);
        IpsiSuralData(b, 1:2) = {'', NaN};
    end
end

SNIContraData = cell2mat(SNIContraData(:, 2));
NaiveContraData = cell2mat(NaiveContraData(:, 2));

IpsiMiddleData = cell2mat(IpsiMiddleData(:, 2));
IpsiStumpData = cell2mat(IpsiStumpData(:, 2));
IpsiProximalData = cell2mat(IpsiProximalData(:, 2));
IpsiSuralData = cell2mat(IpsiSuralData(:, 2));
NaiveIpsiData = cell2mat(NaiveIpsiData(:, 2));

OutputData = horzcat(NaiveContraData(:), NaiveIpsiData(:), SNIContraData(:), IpsiMiddleData(:), IpsiStumpData(:), IpsiProximalData(:), IpsiSuralData(:));
header = ["NAIVE CONTRA", "NAIVE IPSI", "SNI CONTRA", "SNI IPSI MIDDLE", "SNI IPSI STUMP", "SNI IPSI PROXIMAL", "SNI IPSI SURAL"];

pathToWrite = pathToFile + "/" + extractBetween(inputFile, 1, max(strfind(inputFile, ".")) - 1) + "_sorted_" + dayString + stainString + ".csv";

writematrix(header, pathToWrite, 'WriteMode','overwrite');
writematrix(OutputData, pathToWrite, 'WriteMode','append');
msgbox('DONE');
return;
