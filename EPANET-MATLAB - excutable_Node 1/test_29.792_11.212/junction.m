function junction=junction(inpname)

fid = fopen(inpname);
lr = 0; str = []; str1=[];source_in=0;f=0;str3={};
while ~feof(fid)
    lr = lr+1;
    str{lr} = fgetl(fid);
            if strfind(str{lr},'[PIPES]')
                source_in = lr+2;
                f=1;
            end
% 
            if isempty(strfind(str{lr},'[PIPES]'))
                if (strfind(str{lr},'[')+f)==2
                next_in =lr-1;
                f=0;
                end
            end
end

str3=str(source_in:next_in-1);
next_in2 = next_in-source_in;
str4 = reshape(str3,[next_in2 1]);
node2 = string(str4);

newStr = strip(node2);
newStr1 = split(newStr,"	");
%pat = "      " | lettersPattern;
%newStr2 = split(newStr,pat);
node3 = str2double(newStr1);
%node4 = str2double(newStr2);

%node3error = anynan(node3);
%node4error = anynan(node4);

%if node3error == 0;
%    node5 = node3(:,1);
%else 
%    node5 = node4(:,1);
%end

node6 = node3(:,1);
junction = reshape(node6,1,[])

end