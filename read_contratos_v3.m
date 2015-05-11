if simulacao == 1
    
    pause(1)
    
    data1 = [];
    data2 = [];
    data_novo = [];
    
    Dir_Contratos = dir([Pasta_Contratos '\Contrato_v3*']);
    Dir_Novos_Contratos = dir([Pasta_Contratos '\Novo*']);
    
    if isempty(Dir_Contratos)
        msgbox('Erro: Não há arquivos de contrato nesta pasta.');
        break
    end
    
    % Concatena planilhas
    for k=1:length(Dir_Contratos);
        
        Contrato_atual = Dir_Contratos(k).name;
        
        [~, ~, data_xls1] = xlsread([Pasta_Contratos '\' Contrato_atual],1);
        [~, ~, data_xls2] = xlsread([Pasta_Contratos '\' Contrato_atual],2);
        
        if k ==1
            data1 = [data1; data_xls1];
            data2 = [data2; data_xls2];
        else
            data1 = [data1; data_xls1(2:end,:)];
            data2 = [data2; data_xls2(2:end,:)];
        end
    end
    
    for k=1:length(Dir_Novos_Contratos)
        
        Contrato_atual = Dir_Novos_Contratos(k).name;
        
        [~, ~, data_xls_novo] = xlsread([Pasta_Contratos '\' Contrato_atual],1);
        
        data_novo = [data_novo; data_xls_novo(2:end,:)];
    end
    try
        data_novo = cell2mat(data_novo);
    catch
        msgbox(['Erro: Planilha de novos contratos preenchida incorretamente.' sprintf('\n') '(Obs: datas devem estar no formato "Geral")'])
        break
    end
    
    % Monta e filtra matriz
    DadosContratos=cell(size(data1,1)-1,size(data1,2)+size(data2,2)-1);
    DadosContratos(:,1:size(data1,2)) = data1(2:end,:);
    
    filtroContratoZero = cell2mat(DadosContratos(:,1)) == 0;
    DadosContratos = DadosContratos(~filtroContratoZero,:);
    
    [IdContratos,~,index1]=unique(cell2mat(DadosContratos(:,1)));
    Ncontratos=length(IdContratos);
    
    if isempty(data_novo)
        IdNovosContratos = [];
    else
        [IdNovosContratos,~,index_novo]=unique(data_novo(:,1));
    end
    NcontratosNovos=length(IdNovosContratos);
    
    IdContratos_tot = [IdContratos;IdNovosContratos];
    Ncontratos_tot = length(IdContratos_tot);
    
    for k=1:Ncontratos
        thisContrato=IdContratos(k);
        index2=find(cell2mat(data2(2:end,1))==thisContrato)+1;
        tamanhoThisContrato = sum(index1==k);
        DadosContratos(index1==k,size(data1,2)+1:end) = repmat(data2(index2,2:end),tamanhoThisContrato,1);
    end
    
    DadosContratos=cell2mat(DadosContratos);
    
    for k=1:Ncontratos
        thisContrato=IdContratos(k);
        filtroContratoAtual = DadosContratos(:,1) == thisContrato;
        DadosContratos(filtroContratoAtual,8) = min(DadosContratos(filtroContratoAtual,2));
        DadosContratos(filtroContratoAtual,9) = max(DadosContratos(filtroContratoAtual,2));
    end
    
    [~,ordem_data] = sort(DadosContratos(:,2));
    DadosContratos = DadosContratos(ordem_data,:);
    [~,ordem_contrato] = sort(DadosContratos(:,1));
    DadosContratos = DadosContratos(ordem_contrato,:);
    
    filtroBaseZero = DadosContratos(:,10) == 0;
    filtroAniversarioZero = DadosContratos(:,11) == 0;
    filtroDatasZero = filtroBaseZero & filtroAniversarioZero;
    DadosContratos(filtroDatasZero,10:11) = repmat(DadosContratos(filtroDatasZero,8),1,2);
    
    filtroBaseZero = DadosContratos(:,10) == 0;
    DadosContratos(filtroBaseZero,10) = DadosContratos(filtroBaseZero,11);
    
    filtroAniversarioZero = DadosContratos(:,11) == 0;
    DadosContratos(filtroAniversarioZero,11) = DadosContratos(filtroAniversarioZero,10);
    
    DadosContratos=DadosContratos(:,[1 3:end]);
    
    DadosContratos(:,7) = DadosContratos(:,7)+693960;
    
    filtroContratoAntigo = DadosContratos(:,7) < DataInicial;
    DadosContratos(filtroContratoAntigo,7) = DataInicial;
    
    DadosContratos(:,8) = DadosContratos(:,8)+693960;
    DadosContratos(:,9) = DadosContratos(:,9)+693960;
    DadosContratos(:,10) = DadosContratos(:,10)+693960;
    
    if ~isempty(data_novo)
        data_novo(:,7) = data_novo(:,7)+693960;
        data_novo(:,8) = data_novo(:,8)+693960;
        data_novo(:,9) = data_novo(:,9)+693960;
        data_novo(:,10) = data_novo(:,10)+693960;
    end
    
    vetor_dataNumerica_contrato = [];
    % gera dados mes a mes dos novos contratos
    for k=1:NcontratosNovos
        thisContrato=IdNovosContratos(k);
        index_novo2=find(data_novo(:,1)==thisContrato);
        dataInicial_contrato = data_novo(index_novo2,7);
        dataFinal_contrato = data_novo(index_novo2,8);
        contador_contrato = 1;
        dataNumerica_contrato = dataInicial_contrato;
        vetor_dataNumerica_contrato = dataInicial_contrato;
        while dataNumerica_contrato < dataFinal_contrato
            dataNumerica_contrato = addtodate(dataNumerica_contrato, 1, 'month');
            vetor_dataNumerica_contrato = [vetor_dataNumerica_contrato dataNumerica_contrato];
            contador_contrato = contador_contrato + 1;
        end
        DadosContratos = [DadosContratos; repmat(data_novo(index_novo2,:),length(vetor_dataNumerica_contrato),1)];
    end
    
    filtroNaN = isnan(DadosContratos);
    
    if sum(sum(filtroNaN))~=0
        filtroContratoErrado = sum(filtroNaN,2)>0;
        contratosErrados = unique(DadosContratos(filtroContratoErrado,1));
        
        strContratos=[];
        for contr = 1:length(contratosErrados)
            strContratos = [strContratos sprintf('\n') num2str(contratosErrados(contr))];
        end
        
        escolha=questdlg(['Os seguintes contratos estão preenchidos incorretamente:' sprintf('\n') strContratos sprintf('\n\n') 'Deseja que o modelo ignore estes contratos?'],'Planilha de contratos incorreta','Sim','Não','Sim');
        
        if strcmp(escolha,'Sim')
            DadosContratos = DadosContratos(~filtroContratoErrado,:);
            [IdContratos_tot,~,~]=unique(DadosContratos(:,1));
            Ncontratos_tot=length(IdContratos_tot);
        else
            msgbox('Simulação abortada.')
            break
        end
    end
    
    Contratos=cell(Ncontratos_tot,1);
    vetorDatasContratoSimulacao = zeros(Ncontratos_tot,length(vetor_dataNumerica_contrato));
    contratosComDataErrada = zeros(Ncontratos_tot);
    strContratosDataErrada=[];
    
    h = waitbar(0,'Carregando contratos...');
    
end % if simulacao

% Gera os contratos
for k=1:Ncontratos_tot
    
	filtro=(DadosContratos(:,1)==IdContratos_tot(k));
    
    filtro_aux=1:size(DadosContratos,1);
    filtro = filtro_aux(filtro);
    
    if DadosContratos(filtro(1),7)<DadosContratos(filtro(1),9)
        
        contratosComDataErrada(k)=1;
        strContratosDataErrada = [strContratosDataErrada sprintf('\n') num2str(IdContratos_tot(k))];
        DadosContratos(filtro,7) = DadosContratos(filtro,9);

    end
    
    startContrato = find(vetor_dataNumerica_contrato <= DadosContratos(filtro(1),7),1,'last');
    endContrato = find(vetor_dataNumerica_contrato <= DadosContratos(filtro(1),8),1,'last');

    if isempty(startContrato) && ~isempty(endContrato)
        startContrato = 1;
    end

    if startContrato==endContrato
        startContrato = [];
        endContrato = [];
    end

    vetorDatasContratoSimulacao(k,(startContrato:endContrato)) = 1;
      
	startIPCA = find(raw_IPCA(:,1) <= DadosContratos(filtro(1),9));
	endIPCA = find(raw_IPCA(:,1) <= DadosContratos(filtro(1),8));
	IPCA_contrato = raw_IPCA(startIPCA(end):endIPCA(end),2:end);

	startIGPM = find(raw_IGPM(:,1) <= DadosContratos(filtro(1),9));
	endIGPM = find(raw_IGPM(:,1) <= DadosContratos(filtro(1),8));
	IGPM_contrato = raw_IGPM(startIGPM(end):endIGPM(end),2:end);
    
    if  ~isempty(data_novo)
        if (DadosContratos(filtro(1),7)<=dataInicial_contrato && DadosContratos(filtro(1),8)>dataInicial_contrato)
            inicioSemContratos=0;
        end
    end

	index = [IPCA_contrato .* DadosContratos(filtro(1),5) + IGPM_contrato .* DadosContratos(filtro(1),6); zeros((size(DadosContratos,1)-length(IGPM_contrato)),realidadesPorSimulacao)];
       
	Contratos{k} = ContratoManager(index', DadosContratos(filtro,2), DadosContratos(filtro,3), DadosContratos(filtro(1),4), DadosContratos(filtro(1),7), DadosContratos(filtro(1),8), DadosContratos(filtro(1),9), month(DadosContratos(filtro(1),10)),DadosContratos(filtro(1),1));
	Contratos{k}.generate;
    
    if simulacao == 1
        waitbar(k/Ncontratos_tot)
    end
end

if simulacao == 1
    close(h)
end

if ~isempty(strContratosDataErrada)
    choice = questdlg(['A data inicial dos contratos:' sprintf('\n') strContratosDataErrada sprintf('\n') sprintf('\n') 'é posterior à sua data base. Deseja que o modelo utilize a data base como inicial?'],'Planilha de contratos incorreta','Sim','Não','Sim');
    
    if strcmp(choice, 'Não')
        msgbox('Simulação abortada.');
        break
    end
    
end

if find(sum(vetorDatasContratoSimulacao,1)==0)
    choice = questdlg('Aviso: Haverá meses sem contratos vigentes. Deseja continuar?','Meses sem contrato','Sim','Não','Sim');
    
    if strcmp(choice, 'Não')
        msgbox('Simulação abortada.');
        break
    end
    
end
