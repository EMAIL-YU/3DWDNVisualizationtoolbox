%% Clear - Start Toolkit
clear; close('all'); clc;
cd

% C:\Users\USER\Dropbox\EPA_NET_MATLAB\EPANET-Matlab-Toolkit-master\EPANET-Matlab-Toolkit-master\examples\movie-example
% dir_start_toolkit = 'F:\Dropbox\Dropbox\EPA_NET_MATLAB\EPANET-Matlab-Toolkit-master\EPANET-Matlab-Toolkit-master';

start_toolkit;

%% find parameters

[inpname,msxname,node,time,Q_load,formation,parameter1,parameter2,Pattern,bulk,tank,wall,bulkg,wallg,condition]=inputfile;

%% modify inp file - pattenr and source
% dir_inp = 'F:\Dropbox\Dropbox\EPA_NET_MATLAB\EPANET-Matlab-Toolkit-master\EPANET-Matlab-Toolkit-master\examples\movie-example\DG_inp';

cd

inpname = strcat(inpname,'.inp')
msxname = strcat(msxname,'.msx')
%% 

msxgenerator(inpname);
%% 

mu = sprintf('%0.3f',parameter1)
sigma = sprintf('%0.3f',parameter2)

newdir =strcat('test','_',mu,'_',sigma);
mkdir(newdir);

patternname = 'wrt_pattern_F.m';
sourcename = 'wrt_source_F.m';
moviename = 'movie_frame.m';
movienetworkname = 'movie_network.m';

amount = simulationcondition(inpname,condition,node);
fullnode = fullnode(inpname);
fullnode =rot90(fullnode,-1);
fullnode3=fullnode;
junction = junction(inpname);
junctionsize = size(junction,2);

Pattern_val = make_time_accident('weibul',parameter1,parameter2,0,30,time);

hotspot3 = [];

    source = fullfile(inpname);
    destination = fullfile(newdir,inpname);
    copyfile(source,destination)

    source1 = fullfile(msxname);
    destination1 = fullfile(newdir,msxname);
    copyfile(source1,destination1)

    source2 = fullfile(patternname);
    destination2 = fullfile(newdir,patternname);
    copyfile(source2,destination2)

    source3 = fullfile(sourcename);
    destination3 = fullfile(newdir,sourcename);
    copyfile(source3,destination3)

    source4 = fullfile(moviename);
    destination4 = fullfile(newdir,moviename);
    copyfile(source4,destination4)

    source5 = fullfile(movienetworkname);
    destination5 = fullfile(newdir,movienetworkname);
    copyfile(source5,destination5)

cd(newdir);
for iii=1:length(amount)

    
    new_name=strcat(inpname(1:end-4),'_', num2str(amount(iii)),'.inp');
    inpname2=new_name;
    copyfile(inpname,new_name);
    
    new_name2=strcat(msxname(1:end-4),'_', num2str(amount(iii)),'.msx');
    msxname2=new_name2;
    copyfile(msxname,new_name2);

    wrt_source_F(inpname2,amount(iii),Q_load,Pattern);
    wrt_pattern_F(inpname2,Pattern,Pattern_val);
    reaction(inpname2,bulk,tank,wall,bulkg,wallg);

    
    %% 
    d = epanet(inpname2);

%% 

    % t_d = 1;
    % duration_hrs = t_d*24;
    % duration_sec = duration_hrs*60*60;
    % d.setTimeSimulationDuration(duration_sec);
    %
    species = 'CL2'; % d.getMSXSpeciesNameID;

    % Qmsx_species_CL2 = d.getMSXComputedQualitySpecie(species);
    % Qmsx_species_CL2 = d.getComputedQualityTimeSerie;
    Qmsx_species_CL2 = d.getComputedQualityTimeSeries % Value x Node, Value x Link)
    d.setFlowUnitsCMH
    flow1 = d.getComputedHydraulicTimeSeries
    flow = d.getLinkFlows;


    %% set simulation related settings
    bulk_specie_id = species;
    wall_specie_id = '';
    colorbarposition = 'southoutside';

    %% Set movie related settings
    hyd = 0; % code 1 for hydraulics, code 0 for quality
    labelvalues = [0 10 20 30 40];
    labelstrings ={'0' '10' '20' '30' '40'};
    % ylabelinfo = {'Chlorine (mg/L)', 12};
    ylabelinfo = {'THMs (mg/L)', 12};
    titleinfo = {strcat('THMs',' node',num2str(amount(iii)),' after'),12};
    V = Qmsx_species_CL2.NodeQuality';
    L = Qmsx_species_CL2.LinkQuality';
    fig = [];                   % Use a new figure window
    movname = [inpname(1:end-4),'.avi']; % Movie name
    quality = 100;              % 0-100 movie quality (related to data compression)
    fps = 8;                    % Frame rate - # to display per second
    PData.c = 'jet';            % colormap - see 'help colormap'
    PData.logtransv = 'n';      % Do not log transform the data
    PData.vmin = 0;             % min vertex value for plot color mapping
    PData.vmax = 10;   % max vertex value
    PData.lmin = 0;
    PData.lmax = max(max(L));
    PData.lwidth = 2;           % Width of links in points
    PData.vsize = 1;            % Size of vertices in points (0 == omits verts)
    PData.tsize = 10;           % Size of tank/reservoir nodes
    PData.legend = 'v';         % Show a colorbar legend for vertex data
    SData = [];                 % No special node symbols


    %% Write the Movie File
    
    if condition == 'false';    
    movie_network(V,L,fig,movname,...
        quality,fps,PData,SData,d,bulk_specie_id,[],...
        hyd,labelvalues,labelstrings,ylabelinfo,titleinfo,colorbarposition);
    end    

    % Show the Movie
    %     winopen(movname);
    
    Results = d.getComputedTimeSeries;
    Quality2 = d.getComputedQualityTimeSeries;
    Quality3 = sum(Quality2.NodeQuality>0);
    Diffusion(iii) = nnz(Quality3);

    % hotspot anlysis
    Quality4 = Quality3>1;
    Quality5 = double(Quality4);
    Quality6 =reshape(Quality5,[],1);
    hotspot3 = [hotspot3 Quality6];

    Simulationtime = Quality2.Time;
    nodequality = Quality2.NodeQuality;

    linkid = d.LinkNameID(1,1:junctionsize);
    linkquality = Quality2.LinkQuality(1:end,1:junctionsize);

    close all

end

    hotspot4 =rot90(hotspot3);
    hotspot5 =sum(hotspot4>0);
    hotspot5 =rot90(hotspot5,-1);
    hotspot5 = hotspot5(1:end,1);

    Qualityresult = reshape(Diffusion,iii,1);
    %%

    if condition == 'false';
        hotspot6 = 0;
    else
        hotspot6 = hotspot5;
    end

    if condition == 'false';
        fullnode = node;
    else
        fullnode = fullnode;
    end

%% 

    filename = 'testdata.xlsx';
    sheet = 'Monte-Carlo_simulation';
    B = [fullnode;];
    xl2Range = 'A2';
    xlswrite(filename,B,sheet,xl2Range);

    E = [Qualityresult;];
    xl4Range = 'B2';
    xlswrite(filename,E,sheet,xl4Range);

    F = [hotspot6;];
    xl5Range = 'C2';
    xlswrite(filename,F,sheet,xl5Range);
%% 

    A = {'node','Diffusion','hotspot';};
    xlRange = 'A1';
    xlswrite(filename,A,sheet,xlRange);
    %% 

    if condition == 'false';
        C = [Simulationtime,nodequality;];
        D = [Simulationtime,linkquality;];
    else
        C = 'N';
        D = 'N';
    end

    sheet1 = 'Single_simulation(Node)';
    sheet2 = 'Single_simulation(Pipe)';
    xlswrite(filename,C,sheet1,xl2Range)
    xlswrite(filename,D,sheet2,xl2Range)

    fullnode2 =rot90(fullnode3,1);
    E = [fullnode2;];
    xl3Range = 'B1';
    xlswrite(filename,E,sheet1,xl3Range)
    xlswrite(filename,linkid,sheet2,xl3Range)
    
    %%

% 작업공간에 있는 flow1 변수를 불러옵니다 (이미 작업공간에 존재한다고 가정)
% load('workspace.mat'); % 필요한 경우, 작업공간을 파일로부터 불러옵니다

% flow1.velocity를 엑셀 파일로 저장합니다
filename = 'Flow_data.xlsx'; % 저장할 엑셀 파일 이름
data = flow1.Flow; % 저장할 데이터

% data를 테이블로 변환 (필요한 경우)
dataTable = array2table(data);

% 테이블을 엑셀 파일로 작성
writetable(dataTable, filename);

