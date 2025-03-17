function wrt_source_F(inp_name, Node_n, Q_load, Pattern)
% Node_n=11;Q_load=5;Pattern=2;

fid = fopen(inp_name);
lr = 0; str = []; str1=[];source_in=0;f=0;str3={};
while ~feof(fid)
    lr = lr+1;
    str{lr} = fgetl(fid);
            if strfind(str{lr},'[SOURCES]')
                source_in = lr;
                f=1;
            end
% 
            if isempty(strfind(str{lr},'[SOURCES]'))
                if (strfind(str{lr},'[')+f)==2
                next_in =lr;
                f=0;
                end
            end
end

fclose(fid);

str3=str(1:next_in-1);
str3=[str3 sprintf('%d     SETPOINT    %.2f        %d',Node_n,Q_load,Pattern)]; 
str3=[str3 str(next_in:end)];

fid = fopen(inp_name,'w');
for lw = 1 : length(str3)
    fprintf(fid,'%s\n',str3{lw});
end
fclose(fid);
fclose all
