function msxgenerator(inpname)
clear; close('all'); clc;
cd

currrent_dir= pwd;
start_toolkit;

%% 
[inpname,msxname,node,time,Q_load,formation,parameter1,parameter2,Pattern,condition]=inputfile;

inpname = strcat(inpname,'.inp')

d = epanet(inpname);
%% 

msx={};
msx.FILENAME = strcat(inpname(1:end-4),'.msx');

msx.TITLE = 'MSX';

msx.AREA_UNITS = 'FT2'; %AREA_UNITS FT2/M2/CM2
msx.RATE_UNITS = 'DAY'; %TIME_UNITS SEC/MIN/HR/DAY
msx.SOLVER = 'EUL'; %SOLVER EUL/RK5/ROS2
msx.TIMESTEP = 60; %TIMESTEP in seconds
msx.ATOL = 0.01;  %ATOL value
msx.RTOL = 0.001;  %RTOL value

msx.SPECIES={'BULK CL2 MG 0.01 0.001'};

msx.COEFFICIENTS = {'PARAMETER Kb 0.3', 'PARAMETER Kw 1'};

msx.TERMS = {'Kf 1.5826e-4 * RE^0.88 / D'};

msx.PIPES = {'RATE CL2 -Kb*CL2-(4/D)*Kw*Kf/(Kw+Kf)*CL2'};

msx.TANKS = {'RATE CL2 -Kb*CL2'};

msx.SOURCES = {'SETPOINT 1389 CL2 60 CL2pattern'};

msx.GLOBAL = {'Global CL2 0'};

msx.QUALITY = {'NODE 1389 CL2 60'};

msx.PARAMETERS = {''};

msx.PATTERNS = {'CL2pattern    1   1  1   1  1   1  1   1  1  1  1  1  1 1 1 1 1 1 1 1 1 1 1'};

msx
d.writeMSXFile(msx);

%% 

fid = fopen(msx.FILENAME);
lr = 0; str = []; str1=[];source_in=0;f=0;str3={};
while ~feof(fid)
    lr = lr+1;
    str{lr} = fgetl(fid);
            if strfind(str{lr},'[REPORT]')
                source_in = lr;
                f=1;
            end
% 
            if isempty(strfind(str{lr},'[REPORT]'))
                if (strfind(str{lr},'[')+f)==2
                next_in =lr;
                f=0;
                end
            end
end

fclose(fid);

str3=str(1:lr-1);
str3=[str3 sprintf('SPECIE  CL2  YES')]; 
str3=[str3 str(lr:end)];

fid = fopen(msx.FILENAME,'w');
for lw = 1 : length(str3)
    fprintf(fid,'%s\n',str3{lw});
end
fclose(fid);
fclose all