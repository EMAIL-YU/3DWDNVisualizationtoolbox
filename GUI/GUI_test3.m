function createMyGUI()
    % Create the main figure for the GUI
    fig = uifigure('Name', 'INP File Processor', 'Position', [100, 100, 700, 450], ...
        'Color', 'white'); % Set background color to white

    % Add a large panel for the symbol drawing placeholder
    pnlSymbol = uipanel(fig, 'Position', [30, 150, 350, 250]);

    % Remove the label (lblSymbol) since we will insert an image
    % Display an image in the pnlSymbol panel
    img = uiimage(pnlSymbol, 'Position', [25, 25, 300, 200]); 
    img.ImageSource = 'C:\Users\Owner\Desktop\~2024 증강현실 상수관망 연구\GUI\simbol.png'; % 이미지 파일 경로
    img.ScaleMethod = 'fit'; % Set image to fit the panel

    % Add a panel for the action buttons
    pnlButtons = uipanel(fig, 'Position', [420, 150, 230, 250], ...
        'Title', 'Operations', 'FontSize', 14, 'BackgroundColor', 'white');

    % Add a button to load the INP file inside the button panel
    btnLoadINP = uibutton(pnlButtons, 'push', ...
        'Position', [35, 160, 160, 40], ...
        'Text', 'Load INP File', 'FontSize', 12, ...
        'ButtonPushedFcn', @(btn, event) loadINPFile());

    % Add a button to select the save folder inside the button panel
    btnSaveFolder = uibutton(pnlButtons, 'push', ...
        'Position', [35, 100, 160, 40], ...
        'Text', 'Select Save Folder', 'FontSize', 12, ...
        'ButtonPushedFcn', @(btn, event) chooseOutputFolder());

    % Add a button to run the code inside the button panel
    btnRunCode = uibutton(pnlButtons, 'push', ...
        'Position', [35, 40, 160, 40], ...
        'Text', 'Run Code', 'FontSize', 12, ...
        'ButtonPushedFcn', @(btn, event) runCode());

    % Add a label for instructions at the bottom of the figure
    lblInstructions = uilabel(fig, 'Position', [30, 50, 600, 70], ...
        'Text', sprintf('Instructions:\n1. Load the INP file \n2. Select the save folder \n3. Click "Run Code" to execute.'), ...
        'FontSize', 12, 'BackgroundColor', 'white', 'VerticalAlignment', 'top');
    
    % Global variables to store file and folder information
    global inpFilePath;
    global outputFolderPath;

    inpFilePath = ''; % Placeholder for INP file path
    outputFolderPath = ''; % Placeholder for output folder
    % Function to load the INP file
    function loadINPFile()
        [file, path] = uigetfile('*.inp', 'Select the INP File');
        if isequal(file, 0)
            disp('No file selected');
        else
            inpFilePath = fullfile(path, file);
            disp(['Selected INP file: ', inpFilePath]);
        end
    end



   function runCode()
    if isempty(inpFilePath)
        uialert(fig, 'Please select an INP file first!', 'Error');
        return;
    end

    if isempty(outputFolderPath)
        uialert(fig, 'Please select an output folder first!', 'Error');
        return;
    end

    % INP 파일 처리 코드 시작
    fid = fopen(inpFilePath, 'r');  % INP 파일을 읽기 모드로 열기

    if fid ~= -1  % 파일이 유효한 경우
        data = textscan(fid, '%s', 'Delimiter', '\n');  % 줄 단위로 데이터 읽기
        fclose(fid);  % 파일 닫기

        % 섹션 데이터 추출
        sections = {'[JUNCTIONS]', '[PIPES]', '[COORDINATES]'};
        section_data = cell(numel(sections), 1);
        current_section = '';

        for i = 1:numel(data{1})
            line = data{1}{i};

            % 섹션 식별
            if startsWith(line, '[') && endsWith(line, ']')
                current_section = line;
                continue;
            end

            % 현재 섹션 데이터 추출
            if ismember(current_section, sections)
                section_index = find(strcmp(current_section, sections));
                section_data{section_index} = [section_data{section_index}; {strsplit(line, '\t')}];
            end
        end

        % 추출한 데이터 확인 (이 부분은 디버깅을 위해 추가)
        for i = 1:numel(sections)
            section_name = sections{i};
            section_index = find(strcmp(section_name, sections));
            disp(section_name);
            disp(section_data{section_index});
        end
    else
        disp('파일 열기 오류');  % 파일 열기 실패 시 오류 메시지 출력
        return;
    end

        % Extract the data
        Junction_data = section_data{1};
        Pipes_data = section_data{2};
        Coordinates_data = section_data{3};

        % Convert to arrays
        Junction_data = cellfun(@(x) str2double(x), Junction_data, 'UniformOutput', false);
        Pipes_data = cellfun(@(x) str2double(x), Pipes_data, 'UniformOutput', false);
        Coordinates_data = cellfun(@(x) str2double(x), Coordinates_data, 'UniformOutput', false);

        % Create tables to store extracted data
        pipedataextracted = table();
        for i = 2:numel(Pipes_data)-1
            lineData = Pipes_data{i};
            data2th = lineData(2);
            data3th = lineData(3);
            data4th = lineData(4);
            data5th = lineData(5);
            pipedataextracted = [pipedataextracted; table(data2th, data3th, data4th, data5th)];
        end

        % Extract Junction Data
        junctionDataExtracted = table();
        for i = 2:numel(Junction_data)-1
            lineData = Junction_data{i};
            data2nd = lineData(2);
            junctionDataExtracted = [junctionDataExtracted; table(data2nd)];
        end

        % Extract Coordinates Data
        CoordinatesDataExtracted = table();
        for i = 2:numel(Coordinates_data)-1
            lineData = Coordinates_data{i};
            data2nd = lineData(2);
            data3rd = lineData(3);
            CoordinatesDataExtracted = [CoordinatesDataExtracted; table(data2nd, data3rd)];
        end

       
% 세 개의 테이블 중 최소 행 수 확인
minRows = min([size(pipedataextracted, 1), size(CoordinatesDataExtracted, 1), size(junctionDataExtracted, 1)]);

% 최소 행 수만큼 반복
for i = 1:minRows
    % 각 테이블에서 행 인덱스를 사용하여 데이터 추출
    pipesDataLine = pipedataextracted{i, [1, 2, 3, 4]};
    coordinatesDataLine = CoordinatesDataExtracted{i, [1, 2]};
    junctionDataLine = junctionDataExtracted{i, 1};
    
    % 결과 출력
    disp("Pipes Data Line:");
    disp(pipesDataLine);
    
    disp("Coordinates Data Line:");
    disp(coordinatesDataLine);
    
    disp("Junction Data Line:");
    disp(junctionDataLine);
end

% 연결된 데이터를 저장할 새로운 테이블 초기화
connectedCoordinatesTable = table();

% pipedataextracted의 행을 반복
for i = 1:size(pipedataextracted, 1)
    % 연결된 점의 번호 가져오기
    pointNumbers = pipedataextracted{i, [1, 2]};

    % CoordinatesDataExtracted에서 해당 번호의 좌표 가져오기
    pointCoordinates = CoordinatesDataExtracted{pointNumbers, [1, 2]};
    
    % 좌표를 하나의 열로 합치기
    combinedCoordinates = reshape(pointCoordinates', 1, []);
    
    % 새로운 행을 생성하여 데이터 추가
    newRow = table(combinedCoordinates(1), combinedCoordinates(2), combinedCoordinates(3), combinedCoordinates(4), 'VariableNames', {'X1', 'Y1', 'X2', 'Y2'});
    
    % 새로운 행을 connectedCoordinatesTable에 추가합니다.
    connectedCoordinatesTable = [connectedCoordinatesTable; newRow];
end

% 결과 테이블을 표시합니다.
disp('연결된 좌표 테이블:');
disp(connectedCoordinatesTable);
%%

% 연결된 데이터를 저장할 새로운 테이블 초기화
LengthpointTable = table();

% connectedCoordinatesTable의 행을 반복
for i = 1:size(connectedCoordinatesTable, 1)
    % X1, Y1, X2, Y2 좌표를 가져옵니다.
    X1 = connectedCoordinatesTable{i, 'X1'};
    Y1 = connectedCoordinatesTable{i, 'Y1'};
    X2 = connectedCoordinatesTable{i, 'X2'};
    Y2 = connectedCoordinatesTable{i, 'Y2'};
    
    % 점 사이 거리 값을 계산하여 새로운 행을 생성합니다.
    pointlength = sqrt((X2 - X1)^2 + (Y2 - Y1)^2) ;

    newRow = table(pointlength, 'VariableNames', {'점사이거리'});
    
    % 새로운 행을 midpointTable에 추가합니다.
    LengthpointTable = [LengthpointTable; newRow];
end


%%
LengthTable = table();
RatioTable = table();

Length = pipedataextracted(:, 3);

% 테이블의 특정 열을 배열로 변환
columnToMultiply = table2array(Length);

% 배열에 34.82를 곱함
columnToMultiply = columnToMultiply * 34.82;

% 다시 테이블로 변환하여 테이블에 할당
LengthTable.data4th = columnToMultiply;

LengthTable = horzcat(LengthpointTable, LengthTable);

for i = 1:size(LengthTable, 1)
    point = LengthTable{i, '점사이거리'};
    reallength = LengthTable{i, 'data4th'};

    ratio = (reallength / point);

    newRow = table(ratio, 'VariableNames', {'길이비율'});

    % 새로운 행을 RatioTable에 추가합니다.
    RatioTable = [RatioTable; newRow];
end
%%

RatioCoordinatesTable = table();

for i = 1:size(connectedCoordinatesTable, 1)

    X1 = connectedCoordinatesTable{i, 'X1'};
    Y1 = connectedCoordinatesTable{i, 'Y1'};
    X2 = connectedCoordinatesTable{i, 'X2'};
    Y2 = connectedCoordinatesTable{i, 'Y2'};
    R = RatioTable{i,"길이비율"};

    a = X1*R;
    b = Y1*R;
    c = X2*R;
    d = Y2*R;

    newRow = table(a,b,c,d,'VariableNames',{'X1','Y1','X2','Y2'});
    
    
    % 새로운 행을 midpointTable에 추가합니다.
    RatioCoordinatesTable = [RatioCoordinatesTable; newRow];

end




%%

% 연결된 데이터를 저장할 새로운 테이블 초기화
midpointTable = table();

% connectedCoordinatesTable의 행을 반복
for i = 1:size(RatioCoordinatesTable, 1)
    % X1, Y1, X2, Y2 좌표를 가져옵니다.
    X1 = RatioCoordinatesTable{i, 'X1'};
    Y1 = RatioCoordinatesTable{i, 'Y1'};
    X2 = RatioCoordinatesTable{i, 'X2'};
    Y2 = RatioCoordinatesTable{i, 'Y2'};
    
    % 중간값을 계산하여 새로운 행을 생성합니다.
    midX = (X1 + X2) / 2;
    midY = (Y1 + Y2) / 2;
    
    newRow = table(midX, midY, 'VariableNames', {'중간_X', '중간_Y'});
    
    % 새로운 행을 midpointTable에 추가합니다.
    midpointTable = [midpointTable; newRow];
end

% 결과 테이블을 표시합니다.
disp('중간 좌표 테이블:');
disp(midpointTable);



%%

% 연결된 데이터를 저장할 새로운 테이블 초기화
connectedCoordinatesTable_2 = table();

% pipedataextracted의 행을 반복
for i = 1:size(pipedataextracted, 1)
    % 연결된 점의 번호 가져오기
    pointNumbers = pipedataextracted{i, [1, 2]};

    % junctionDataExtracted에서 해당 번호의 데이터 가져오기
    junctionData = junctionDataExtracted{pointNumbers, 1};

    % CoordinatesDataExtracted에서 해당 번호의 좌표 가져오기
    pointXCoordinates = CoordinatesDataExtracted{pointNumbers, 1};

  % 좌표와 junctionData를 수평으로 결합
    combinedCoordinates_2 = horzcat(pointXCoordinates, junctionData);

    % 새로운 행을 생성하여 데이터 추가
    newRow = table(combinedCoordinates_2(1), combinedCoordinates_2(3), combinedCoordinates_2(2), combinedCoordinates_2(4), 'VariableNames', {'X1', 'Z1', 'X2', 'Z2'});

    % 새로운 행을 connectedCoordinatesTable에 추가합니다.
    connectedCoordinatesTable_2 = [connectedCoordinatesTable_2; newRow];
end

% 결과 테이블을 표시합니다.
disp('연결된 좌표 테이블:');
disp(connectedCoordinatesTable_2);

%%

% connectedCoordinatesTable_3 변수를 초기화하고 빈 테이블 생성
connectedCoordinatesTable_3 = table();

% connectedCoordinatesTable_2의 일부 열과 pipedataextracted의 열을 결합
connectedCoordinatesTable_3 = [pipedataextracted(:, 1), pipedataextracted(:, 2), connectedCoordinatesTable_2(:, "Z1"), connectedCoordinatesTable_2(:, "Z2")];

%%

% 연결된 데이터를 저장할 새로운 테이블 초기화
midpointTable_2 = table();

% connectedCoordinatesTable의 행을 반복
for i = 1:size(connectedCoordinatesTable_2, 1)
    % X1, Y1, X2, Y2 좌표를 가져옵니다.
    Z1 = connectedCoordinatesTable_2{i, 'Z1'};
    Z2 = connectedCoordinatesTable_2{i, 'Z2'};
    
    % 중간값을 계산하여 새로운 행을 생성합니다.
  
    midZ = (Z1 + Z2) / 2;
    
    newRow = table(midZ, 'VariableNames', {'중간_Z'});
    
    % 새로운 행을 midpointTable에 추가합니다.
    midpointTable_2 = [midpointTable_2; newRow];
end



%%

% 연결된 데이터를 저장할 새로운 테이블 초기화
slopeTable_1 = table();

% connectedCoordinatesTable의 행을 반복
for i = 1:size(connectedCoordinatesTable, 1)
    % X1, Y1, X2, Y2 좌표를 가져옵니다.
    X1 = connectedCoordinatesTable{i, 'X1'};
    Y1 = connectedCoordinatesTable{i, 'Y1'};
    X2 = connectedCoordinatesTable{i, 'X2'};
    Y2 = connectedCoordinatesTable{i, 'Y2'};
    
    % 기울기를 계산합니다.
    slope_rad = atan2(Y2 - Y1, X2 - X1);

    slope_deg = rad2deg(slope_rad);

    
    newRow = table(slope_deg, 'VariableNames', {'기울기(라디안)'});
    
    % 새로운 행을 slopeTable에 추가합니다.
    slopeTable_1 = [slopeTable_1; newRow];

end

    
%%


% 결과를 저장할 빈 테이블 생성
slopeTable_2 = table();

Length_2 = columnToMultiply;

connectedCoordinatesTable_3 = table2array(connectedCoordinatesTable_3);

% 각 행을 반복하면서 차이 계산 및 결과 테이블에 추가
for i = 1:size(connectedCoordinatesTable_3, 1)
    point1 = connectedCoordinatesTable_3(i, 1); % 첫 번째 점 번호
    point2 = connectedCoordinatesTable_3(i, 2); % 두 번째 점 번호
    z1 = connectedCoordinatesTable_3(i, 3);     % 첫 번째 점의 Z 값
    z2 = connectedCoordinatesTable_3(i, 4);     % 두 번째 점의 Z 값
    
    % 점 번호를 비교하여 계산
    if point1 > point2
        diff = z1 - z2; % 높은 번호에서 낮은 번호를 뺍니다.
    else
        diff = z2 - z1; % 낮은 번호에서 높은 번호를 뺍니다.
    end

    diff = diff*34.82;

    slope_rad_2 = atan(diff / Length_2);

    slope_deg_2 =rad2deg(slope_rad_2);
    
    
    % 결과 테이블에 추가
    newRow = table(slope_deg_2, 'VariableNames', {'기울기(라디안)'});
    slopeTable_2= [slopeTable_2; newRow];
end

% 결과 출력
disp(slopeTable_2);
%%

% 조건에 따라 값을 수정합니다.
for i = 1:size(slopeTable_1, 1)
    for j = 1:size(slopeTable_1, 2)
        value = slopeTable_1{i, j};
        
        % 값이 0, 90, -90, 또는 180인 경우 90을 더합니다.
        if value == 0 || value == 90 || value == -90 || value == 180
            slopeTable_1{i, j} = value + 90;

            else
            % 값이 0, 90, -90, 180이 아닌 경우
            if value > 0
                % 양수인 경우
                slopeTable_1{i, j} = -(value - 90);
            else
                % 음수인 경우
                slopeTable_1{i, j} = -(value + 90);
            end
        end
    end
end

% 수정된 table을 저장합니다.
writetable(slopeTable_1, 'modifiedTable.xlsx'); % 수정된 데이터를 원하는 파일 형식에 맞게 저장합니다.
%%

resultFolderPath = 'C:\Users\Owner\Desktop\part1';

% 폴더가 존재하지 않으면 생성
if ~exist(resultFolderPath, 'dir')
    mkdir(resultFolderPath);
end

% 저장할 폴더 경로 설정

saveFolderPath = outputFolderPath;  % 선택한 폴더 경로로 수정

multiplier_1 = 34.82;
multiplier_2 = 5.17;

 % 파일 저장 단계
    for i = 1:size(pipedataextracted, 1)  % pipedataextracted의 행 수에 맞게 루프 실행
        pipesDataLine = table2array(pipedataextracted(i, [1, 2, 3, 4]));
        midpointDataLine = table2array(midpointTable(i, :));
        midpointTable_Z_DataLine = table2array(midpointTable_2(i, :)); % 각각의 행에 해당하는 값 추출
        slope_degrees1_Data = table2array(slopeTable_1(i,:));
        slope_degrees2_Data = table2array(slopeTable_2(i,:));

        % 각 파일 이름을 고유하게 설정하여 동일한 파일이 덮어씌워지지 않도록
        fileName = ['text' num2str(i) '.txt'];
        filePath = fullfile(outputFolderPath, fileName);

        % 파일 쓰기
        fid = fopen(filePath, 'w');  % 파일을 저장할 때 저장 경로 지정
        if fid == -1
            disp(['Error opening file: ' filePath]);
            continue;
        end

        fprintf(fid, '%d\n%d\n%d\n', pipesDataLine(4), pipesDataLine(4), pipesDataLine(3));
        fprintf(fid, '%d\n%d\n%d\n', midpointDataLine(1), midpointTable_Z_DataLine * 34.82, midpointDataLine(2));
        fprintf(fid, '%d\n%d\n%d\n', slope_degrees2_Data(7), slope_degrees1_Data, 0);

        fclose(fid);

        disp([num2str(i), ' data saved to "', filePath, '"']);
    end
   end
   % Function to select the save folder
    function chooseOutputFolder()
        outputFolderPath = uigetdir();  % Open folder selection dialog
        if isequal(outputFolderPath, 0)
            disp('No folder selected');
        else
            disp(['Selected folder: ', outputFolderPath]);
        end
    end
end

