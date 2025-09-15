function [] = wait_for_experimenter_ok(ok_key)

FlushEvents('keyDown');
while(1)
    temp = GetChar;
    if (temp == ok_key)
        break;
    end
end