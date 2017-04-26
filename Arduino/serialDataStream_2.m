
%inspired by http://www.vidnis.com/2014/10/matlab-code-for-live-stream-plotting.html

clear all;
cla
clc;

delete(instrfindall);             % if any port is already opened by MATLAB its gonna find and                                                  close it



%% this initialized the serial port (add to the START - function in GUI)
s = serial ('/dev/tty.usbmodem1411');            %Here I have chosen COM7 Port
s.BaudRate = 19200;        % the baud rate with which my date is received 115200
s.Terminator = 'LF';          %Here since I am sending the data in a string format I am basically sending an end character as carriage return '\r', This script understands this as the end and considers all the data before this as the acquired data
s.InputBufferSize=2^16;
count =1;                           % A temporary variable declared
fopen (s);                           % Opening the port, in my case COM 7
s.ReadAsyncMode = 'manual';
readasync(s)

KEEP_READING = 1;

while KEEP_READING                          % Infinite loop starts here


arduinoMessage = readAndParseArduionoSerialMessage(s)

%check here if user pressed "STOP" button or if error.

% DEV ONLY stop after 10000 msec
if arduinoMessage.experimentElapsedTime>10000
    KEEP_READING = 0;
end

end      
% end of the infinite loop




fclose (s) ;                            % closing COM port
delete (s)                             % deleting serial port object

