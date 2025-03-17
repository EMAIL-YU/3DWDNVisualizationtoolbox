function reaction(inp_name,bulk,tank,wall,bulkg,wallg)


fid = fopen(inp_name);
lr = 0; str = []; str1=[];source_in=0;f=0;str3={};

while ~feof(fid)
    lr = lr+1;
    str{lr} = fgetl(fid);
    if strfind(str{lr},'[REACTIONS]')
        source_in = lr+1;
        f=1;
    end
    %
    if isempty(strfind(str{lr},'[REACTIONS]'))
        if (strfind(str{lr},'[')+f)==2
            next_in =lr;
            f=0;
        end
    end
end

%% write text
str3=str(1:next_in-1);

str4=str(source_in:next_in-1);
str4=rot90(str4,-1);
%% 

str4{1} = sprintf('Order Bulk            	%.1f',bulk);
str4{2} = sprintf('Order Tank            	%.1f',tank);
str4{3} = sprintf('Order Wall            	%.1f',wall);
str4{4} = sprintf('Global Bulk           	%.2f',bulkg);
str4{5} = sprintf('Global Wall           	%.2f',wallg);

str4=rot90(str4);

fclose(fid);
%% 

str5 = [str3(1:source_in-1) str4];
%% 

str6 = [str5 str(next_in:end)];
%str3=[str3 str(next_in:end)];

fid = fopen(inp_name,'w');
for lw = 1 : length(str6)
    fprintf(fid,'%s\n',str6{lw});
end
fclose(fid);
fclose all

