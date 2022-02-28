function SortDataForPrism

[inputFile, pathToFile] = uigetfile('*.csv');

if inputFile == 0
    return;
end
if not(endsWith(inputFile, '.csv'))
    return;
end

DataArray = readcell(sprintf('%s%s', pathToFile, inputFile));
ColumnNames = DataArray(1,:);
if contains(string(ColumnNames), "FILENAME") == zeros(size(ColumnNames))
    return;
end
if contains(string(ColumnNames), "VOL MAP2") == zeros(size(ColumnNames))
    return;
end

FilenameCol = find(contains(ColumnNames, "FILENAME"), 1);
VolumeCol = find(contains(ColumnNames, "VOL MAP2"), 1);

FilenameData = DataArray(:, FilenameCol);
FilenameData = FilenameData(2:end, :);
VolumeData = DataArray(:, VolumeCol);
VolumeData = VolumeData(2:end, :);

DataToSort = [FilenameData, VolumeData];

ContraData = DataToSort(contains(FilenameData, "CONTRA", 'IgnoreCase',true), :);

SNIContraData = ContraData(startsWith(string(ContraData(:, 1)), "D", 'IgnoreCase',true), :);
NaiveContraData = ContraData(startsWith(string(ContraData(:, 1)), "Naive", 'IgnoreCase',true), :);

IpsiData = DataToSort(contains(FilenameData, "IPSI",'IgnoreCase',true ), :);
IpsiMiddleData = IpsiData(contains(IpsiData(:, 1), "MIDDLE", 'IgnoreCase',true), :);
IpsiStumpData = IpsiData(contains(IpsiData(:, 1), "STUMP", 'IgnoreCase',true), :);
IpsiProximalData = IpsiData(contains(IpsiData(:, 1), "PROXIMAL", 'IgnoreCase',true), :);
IpsiDistalData = IpsiData(contains(IpsiData(:, 1), "DISTAL", 'IgnoreCase',true), :);
IpsiProximalData = [IpsiProximalData; IpsiDistalData];
IpsiSuralData = IpsiData(contains(IpsiData(:, 1), "SURAL", 'IgnoreCase',true), :);
NaiveIpsiData = IpsiData(startsWith(string(IpsiData(:, 1)), "Naive", 'IgnoreCase',true), :);

SNIContraData = cell2mat(SNIContraData(:, 2));
NaiveContraData = cell2mat(NaiveContraData(:, 2));

IpsiMiddleData = cell2mat(IpsiMiddleData(:, 2));
IpsiStumpData = cell2mat(IpsiStumpData(:, 2));
IpsiProximalData = cell2mat(IpsiProximalData(:, 2));
IpsiSuralData = cell2mat(IpsiSuralData(:, 2));
NaiveIpsiData = cell2mat(NaiveIpsiData(:, 2));

ArraySizes = [size(SNIContraData), size(NaiveContraData), size(IpsiMiddleData), size(IpsiStumpData), size(IpsiProximalData), size(IpsiSuralData), size(NaiveIpsiData)];
MaximumSize = max(ArraySizes);
if length(SNIContraData) < MaximumSize
    SNIContraData = vertcat(SNIContraData, NaN(MaximumSize - length(SNIContraData), 1));
end
if length(NaiveContraData) < MaximumSize
    NaiveContraData = vertcat(NaiveContraData, NaN(MaximumSize - length(NaiveContraData), 1));
end
if length(IpsiMiddleData) < MaximumSize
    IpsiMiddleData = vertcat(IpsiMiddleData, NaN(MaximumSize - length(IpsiMiddleData), 1));
end
if length(IpsiStumpData) < MaximumSize
    IpsiStumpData = vertcat(IpsiStumpData, NaN(MaximumSize - length(IpsiStumpData), 1));
end
if length(IpsiProximalData) < MaximumSize
    IpsiProximalData = vertcat(IpsiProximalData, NaN(MaximumSize - length(IpsiProximalData), 1));
end
if length(IpsiSuralData) < MaximumSize
    IpsiSuralData = vertcat(IpsiSuralData, NaN(MaximumSize - length(IpsiSuralData), 1));
end
if length(NaiveIpsiData) < MaximumSize
    NaiveIpsiData = vertcat(NaiveIpsiData, NaN(MaximumSize - length(NaiveIpsiData), 1));
end

OutputData = horzcat(NaiveContraData(:), NaiveIpsiData(:), SNIContraData(:), IpsiMiddleData(:), IpsiStumpData(:), IpsiProximalData(:), IpsiSuralData(:));
header = ["NAIVE CONTRA", "NAIVE IPSI", "SNI CONTRA", "SNI IPSI MIDDLE", "SNI IPSI STUMP", "SNI IPSI PROXIMAL", "SNI IPSI SURAL"];

pathToWrite = pathToFile + "/" + extractBetween(inputFile, 1, max(strfind(inputFile, "."))) + "_sorted.csv";

writematrix(header, pathToWrite, 'WriteMode','overwrite');
writematrix(OutputData, pathToWrite, 'WriteMode','append');

