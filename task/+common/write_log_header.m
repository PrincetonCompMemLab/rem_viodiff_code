function [] = write_log_header(dataFile, seed, experimentName, SN, NM, runNum)

fprintf(dataFile,'*********************************************\n');
fprintf(dataFile,'* %s\n', experimentName);
fprintf(dataFile,['* Date/Time: ' datestr(now,0) '\n']);
fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
fprintf(dataFile,['* Subject Number: ' SN '\n']);
fprintf(dataFile,['* Subject Name: ' NM '\n']);
fprintf(dataFile,['* Run Number: ' num2str(runNum) '\n']);
fprintf(dataFile,'*********************************************\n\n');


fprintf('*********************************************\n');
fprintf('* %s\n', experimentName);
fprintf(['* Date/Time: ' datestr(now,0) '\n']);
fprintf(['* Seed: ' num2str(seed) '\n']);
fprintf(['* Subject Number: ' SN '\n']);
fprintf(['* Subject Name: ' NM '\n']);
fprintf(['* Run Number: ' num2str(runNum) '\n']);
fprintf('*********************************************\n\n');


end