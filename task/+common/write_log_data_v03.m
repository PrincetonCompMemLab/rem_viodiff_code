function write_log_data_v03(res_Inputs_names, res_Inputs_values, var_floats, ~)
%v03: only record in the screen
[res_classes] = check_classes(res_Inputs_names, var_floats);

sent_full = [];
sent = [];
for ii = 1:length(res_Inputs_names)
    sent_full = [sent_full [res_Inputs_names{ii} ':' res_classes{ii}]];
    sent = [sent [res_classes{ii}]];
end

fprintf(sent_full,res_Inputs_values);

