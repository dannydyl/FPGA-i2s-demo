% Clear workspace and close all figures
clear;
clc;
close all;

% Create a serial object for COM4
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

try
    s = serialport('COM4', 115200, 'Timeout', 10);
catch e
    disp('Error opening serial port:');
    disp(e.message);
    return;
end

% Initialize control variables
global isRunning dataBuffer outputFile
isRunning = false;
dataBuffer = [];
sample = uint32(0);
sampleCount = 0;
outputFile = 'C:\Users\danny\OneDrive\Desktop\FPGA\i2s_demo\uart_data.csv';

% Check if the directory exists
[filepath, ~, ~] = fileparts(outputFile);
if ~exist(filepath, 'dir')
    disp(['Directory does not exist: ', filepath]);
    mkdir(filepath);
    disp('Directory created.');
end

if isfile(outputFile)
    delete(outputFile); % Clear file contents if it exists
    disp('Existing file deleted.');
end

% Setup UI
fig = uifigure('Name', 'Serial Data Capture');
startStopButton = uibutton(fig, 'state', 'Text', 'Start', ...
    'Position', [20 20 100 30], 'ValueChangedFcn', @toggleDataCollection);

% Function to start/stop data collection
function toggleDataCollection(src, ~)
    global isRunning dataBuffer outputFile
    if src.Value
        src.Text = 'Stop';
        isRunning = true;
        disp('Data collection started.');
    else
        src.Text = 'Start';
        isRunning = false;
        % Save remaining data to file when stopping
        if ~isempty(dataBuffer)
            try
                writematrix(dataBuffer, outputFile, 'WriteMode', 'append');
                disp(['Data appended to file: ', outputFile]);
            catch e
                disp('Error writing to file:');
                disp(e.message);
            end
            dataBuffer = [];
        end
        disp('Data collection stopped.');
    end
end

% Main loop
try
    while isvalid(fig)
        if isRunning && s.NumBytesAvailable > 0
            data = read(s, s.NumBytesAvailable, "uint8");
            for i = 1:length(data)
                sample = bitor(bitshift(sample, 8), uint32(data(i)));
                sampleCount = sampleCount + 1;
                if sampleCount == 3
                    dataBuffer = [dataBuffer; sample];
                    sample = uint32(0);
                    sampleCount = 0;
                    if size(dataBuffer, 1) >= 100
                        try
                            writematrix(dataBuffer, outputFile, 'WriteMode', 'append');
                            disp(['Data chunk appended to file: ', outputFile]);
                        catch e
                            disp('Error writing to file:');
                            disp(e.message);
                        end
                        dataBuffer = [];
                    end
                end
            end
        end
        pause(0.1);
    end
catch e
    disp('Error during serial read:');
    disp(e.message);
end

% Close the serial port when done
clear s;
disp('Serial connection closed.');
disp(['Final file location: ', outputFile]);
if isfile(outputFile)
    disp('File exists at the specified location.');
else
    disp('File does not exist at the specified location.');
end