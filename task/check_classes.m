function [res_classes] = check_classes(res_Inputs, var_floats)


for ii = 1:length(res_Inputs)
    check = zeros(1, length(var_floats));
    for hh = 1:length(var_floats)
        if strcmp(var_floats{hh}, res_Inputs{ii})
            check(hh) = 1;
        end
    end
    if sum(check)
        if ii == length(res_Inputs)
            res_classes{ii} = '%3.4f\n';
        else
            res_classes{ii} = '%3.4f\t ';
        end%if ii
    else
        if ii == length(res_Inputs)
            res_classes{ii} = '%d\n';
        else
            res_classes{ii} = '%d\t ';
        end%if ii
    end
end%for ii

