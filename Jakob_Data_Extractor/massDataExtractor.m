clear
clc

myFolder = '/Users/jakobloverde/Documents/MATLAB/STF-1/allOperationData';

fprintf("Starting data processing...\n");
dataBase_exp1 = organizer_exp1(myFolder);
dataBase_exp2 = organizer_exp2(myFolder);

fprintf("Data processing completed successfully.\n");

save('dataBase_exp2.mat', 'dataBase_exp2');
save('dataBase_exp1.mat', 'dataBase_exp1');


% xlswrite('experimentDataBase.xlsx', cell2mat(dataBase));


%% This funciton cycles through every file in the specified folder that
%  contains "_exp2_" and then uses the converter and data finder functions 
%  to organize all of the useable data into cells into a n x 2 array - 
%  where n is the size of the file

function [cellArrayData] = organizer_exp2(folder)
  
    % Sentile if folder doesn't exist
    % Check to make sure that folder actually exists.  Warns user if it doesn't.
    if ~isfolder(folder)
        errorMessage = sprintf(['Error: The following folder does not' ...
        'exist:\n%s\nPlease specify a new folder.'], folder);
        uiwait(warndlg(errorMessage));
        folder = uigetdir(); % Ask for a new one.
        if folder == 0
             % User clicked Cancel
             return;
        end
    end
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(folder, '**/*_exp2_*.csv'); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    
    big_matrix = cell(length(theFiles), 2);
    counter = 1;
    for k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);
        fprintf(1, 'PROCESSING Experiment 2 %s\n', fullFileName);
        

        strData = dataFinder_exp2(fullFileName);
        for i = 1 : length(dataFinder_exp2(fullFileName))
            usableData = char(strData(i,1));

            matrix = converter_exp2(usableData);
            cellData = mat2cell(matrix,[26 0]); %uneeded extra cell produced here
           
            big_matrix(counter,2 ) = cellData(1, 1); % bc of above always take the first cell
            big_matrix(counter, 1) = cellstr(string(baseFileName));
            
            counter = counter + 1;
        end 
    end
    
    
    cellArrayData = big_matrix;
    
end

function [cellArrayData] = organizer_exp1(folder)
  
    % Sentile if folder doesn't exist
    % Check to make sure that folder actually exists.  Warns user if it doesn't.
    if ~isfolder(folder)
        errorMessage = sprintf(['Error: The following folder does not' ...
        'exist:\n%s\nPlease specify a new folder.'], folder);
        uiwait(warndlg(errorMessage));
        folder = uigetdir(); % Ask for a new one.
        if folder == 0
             % User clicked Cancel
             return;
        end
    end
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(folder, '**/*_exp1_*.csv'); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    
    big_matrix = cell(length(theFiles), 2);
    counter = 1;
    for k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(theFiles(k).folder, baseFileName);
        fprintf(1, 'PROCESSING Experiment 1 %s\n', fullFileName);
        

        strData = dataFinder_exp1(fullFileName);
        for i = 1 : length(dataFinder_exp1(fullFileName))
            usableData = char(strData(i,1));

            matrix = converter_exp1(usableData);
            cellData = mat2cell(matrix,[24 0]); %uneeded extra cell produced here
           
            big_matrix(counter,2 ) = cellData(1, 1); % bc of above always take the first cell
            big_matrix(counter, 1) = cellstr(string(baseFileName));
            
            counter = counter + 1;
        end 
    end
    
    
    cellArrayData = big_matrix;
    
end

%% Function checks to see how many rows contain data 
%  then takes the data from the last column in the correlated
%  rows to convert into a string array    
function [dataString] = dataFinder_exp2(fileToCheck)
    
    dataSet = readtable(fileToCheck,'Delimiter', ',');
    check_EXP2 = 'CSEE_EXP2_TLM_T';

    fileType = string(dataSet{1,2});

    rowDataCounter = 0;

    % This is to check if the file is from exp 2 and how many rows of 
    % data there are
    if (strcmp(check_EXP2, fileType) == 1)
        for i = 1 : size(dataSet,1)
            if (strcmp(check_EXP2, string(dataSet{i,2})))
                rowDataCounter = rowDataCounter + 1;
            end
        end

    else disp('Wrong file!');

    end

    dataString = strings(rowDataCounter,1);
    %data is always in the last column
    
    for i = 1 : rowDataCounter
        dataString(i, 1) = dataSet{i, size(dataSet,2)};
    end

end
%% Function checks to see how many rows contain data 
%  then takes the data from the last column in the correlated
%  rows to convert into a string array    
function [dataString] = dataFinder_exp1(fileToCheck)
    dataSet = readtable(fileToCheck,'Delimiter', ',');
    if(isempty(dataSet))
        disp("Empty file");
        dataString = "";
    else
        check_EXP1 = 'CSEE_EXP1_TLM_T';

        fileType = string(dataSet{1,2});

        rowDataCounter = 0;

        % This is to check if the file is from exp 2 and how many rows of 
        % data there are
        if (strcmp(check_EXP1, fileType) == 1)
            for i = 1 : size(dataSet,1)
                if (strcmp(check_EXP1, string(dataSet{i,2})))
                    rowDataCounter = rowDataCounter + 1;
                end
            end

        else disp('Wrong file!');

        end

        dataString = strings(rowDataCounter,1);
        %data is always in the last column

        for i = 1 : rowDataCounter
            dataString(i, 1) = dataSet{i, size(dataSet,2)};
        end
    end 
end
%% Takes a string a hex string that fits the data structure of exp 2 and places the values in the correct slot in a matrix
%  1. Reshapes the data into arrays of length 17
%  2. Gets the data from a single row and breaks into list of chars
%     stored in the variable 'data'
%  3. Converts the hex data into decimal data and stores them in the
%     correct position according to the data structure for exp 2
%  THIS FUNCTION ASSUMES YOU HAVE THE CELL DATA ALREADY SELECTED DOES
%  NOT GET THE DATA
function [dataMatrix] = converter_exp2(hexidicmalString)
    
    %% Parses string into different arrays of length 17
        % answer: 
        % https://www.mathworks.com/matlabcentral/answers/109411-split-string-into-3-letter-each
    
    tinyMatrix = zeros(16, 9);
    parcedMatrix = cellstr(reshape(hexidicmalString,34,[])');
    hexArray = strings(16, 1); % This is a numbering for the 

    %% Covert individual arrays into a decimal value then store into a matrix
        % LED number is 1 Byte, ADC Readings 3*2 bytes(X,Y,Z) [2,3], Voltage is 2 bytes[4,5], Current 2
        % bytes[6,7], SECOND ADC readings 3*2 bytes (X,Y,Z)[8,9]
        % every row will have 9 columns hence zeros(16,9)
        % process the data little endian style
    
    for row = 1 : size(parcedMatrix, 1) %This indexes 
        indexModifier = 2;
        %ROW was never being updated!
        data = cellstr(reshape(char(parcedMatrix(row)), 2,[])');
        %reshapes the current row into a string array with 2 bytes
        %the data is not 1 byte it is 2 bytes
        for column = 1 : 9 %every 17 bytes make a new row 
            %fist column is LED number, etc... with only 9
            %1st ADC readings
            if(column == 1)
                hexString = data(1,column);
                hexConversion = hex2dec(hexString);
                hexArray(row, 1) = hexString; % This shows the literal 
                % hex value for the LED number
                tinyMatrix(row , 1) = hexConversion;
           
            end
            if(column >= 2)
                hexString = strcat(data(indexModifier+1),data(indexModifier)); %need to concatenate two character
                hexConversion = hex2dec(hexString);
                tinyMatrix(row, column) = hexConversion;
                indexModifier = indexModifier+2;
                %indexModifier only needs to be updated here since it is
                %only used here
               
            end 
        end 
    end 
    
    %% Adding headers
    tinyMatrix = cat(2,hexArray,tinyMatrix); %%%PROBLEM
    headers = {'LED Hex','LED Number', 'x1', 'y1', 'z1', 'Voltage', 'Current', 'x2','y2','z2'};
    dataMatrix = [headers; num2cell(tinyMatrix); headers];
     
end
%% TODO make a converter for _exp1_
%% Takes a string a hex string that fits the data structure of exp 1 and places the values in the correct slot in a matrix
%  1. Reshapes the data into arrays of length 17
%  2. Gets the data from a single row and breaks into list of chars
%     stored in the variable 'data'
%  3. Converts the hex data into decimal data and stores them in the
%     correct position according to the data structure for exp 2
%  THIS FUNCTION ASSUMES YOU HAVE THE CELL DATA ALREADY SELECTED DOES
%  NOT GET THE DATA
function [dataMatrix] = converter_exp1(hexidicmalString)
    
    %% Parses string into different arrays of length 65
        % answer: 
        % https://www.mathworks.com/matlabcentral/answers/109411-split-string-into-3-letter-each
    if(strcmp(hexidicmalString,""))
        dataMatrix = zeros(24,65);
    else 
        tinyMatrix = zeros(24, 65);
        parcedMatrix = cellstr(reshape(hexidicmalString,258,[])');

        %% Covert individual arrays into a decimal value then store into a matrix
            % LED number is 1 Byte [1]
            % Voltage 64 Bytes 2^6 [2...65]
            % Current is 64 Bytes 2^6 [66...65]
            % every row will have 65 columns hence zeros(24,65)
            % process the data little endian style
        
        for row = 1 : size(parcedMatrix, 1) %This indexes 
            %ROW was never being updated!
            data = cellstr(reshape(char(parcedMatrix(row)), 2,[])');
            %reshapes the current row into a string array with 2 bytes
            %the data is not 1 byte it is 2 bytes
            indexModifier = 2;
            for column = 1 : 65 %every 17 bytes make a new row 
                %fist column is LED number, etc... with only 9
                %1st ADC readings

                if(column == 1)
                hexString = data(1,column);
                hexConversion = hex2dec(hexString);
                tinyMatrix(row , 1) = hexConversion;
                end
                if(column >= 2)
                    hexString = strcat(data(indexModifier+1),data(indexModifier)); %need to concatenate two character
                    hexConversion = hex2dec(hexString);
                    tinyMatrix(row, column) = hexConversion;
                    indexModifier = indexModifier+2;
                    %indexModifier only needs to be updated here since it is
                    %only used here
                end 
            end
        end
        dataMatrix = tinyMatrix;
    end
 
end