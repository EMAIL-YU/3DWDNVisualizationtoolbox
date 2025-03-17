function wrt_pattern_F(inp_name, Node_n, pattern_va)

fid = fopen(inp_name);
lr = 0; str = []; str1=[];source_in=0;f=0;str3={};
% pattern_va = [ones(15,1).*0.5];
while ~feof(fid)
    lr = lr+1;
    str{lr} = fgetl(fid);
    if strfind(str{lr},'[PATTERNS]')
        source_in = lr;
        f=1;
    end
    %
    if isempty(strfind(str{lr},'[PATTERNS]'))
        if (strfind(str{lr},'[')+f)==2
            next_in =lr;
            f=0;
        end
    end
end

fclose(fid);
%% write text
str3=str(1:next_in-1);

for ii = 1:fix(length(pattern_va)/6)
    str3=[str3 sprintf('%d          %.6f          %.6f          %.6f          %.6f          %.6f          %.6f',Node_n,pattern_va(1+(ii-1)*6), pattern_va(2+(ii-1)*6),pattern_va(3+(ii-1)*6),pattern_va(4+(ii-1)*6),pattern_va(5+(ii-1)*6),pattern_va(6+(ii-1)*6))];
end
%% write
str_rem='';
rem_val = rem(length(pattern_va),6);
if rem_val>0
    for iir = 1:rem_val
        str_rem = append(str_rem,'  ',num2str(pattern_va(length(pattern_va)-rem_val+iir)));
    end
    str_rem_F = append(num2str(Node_n),'    ',str_rem);
    str3=[str3 str_rem_F];
end
%% read


str3=[str3 str(next_in:end)];

fid = fopen(inp_name,'w');
for lw = 1 : length(str3)
    fprintf(fid,'%s\n',str3{lw});
end
fclose(fid);
fclose all

