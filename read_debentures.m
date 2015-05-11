if simulacao == 1
    
    pause(1)
    
    Dir_Debenture = dir([Pasta_Debentures '\Debenture*']);
    Dir_Divida = dir([Pasta_Debentures '\Divida_BNDES*']);
    Dir_Debenture_e_BNDES = [Dir_Debenture; Dir_Divida];
    
    if isempty(Dir_Debenture_e_BNDES)
        msgbox('Erro: Não há arquivos de dívida nesta pasta.');
        break
    end
    
    Debenture_Num = length(Dir_Debenture_e_BNDES);
    Debentures = cell(2,Debenture_Num);
    Dados = cell(1,Debenture_Num);
    
    for j=1:Debenture_Num
        
        % Name of the current Debenture
        Debenture_atual = Dir_Debenture_e_BNDES(j).name;
        
        % Import data from the xls sheet of the current Debenture
        [~, ~, Dados{j}] = xlsread([Pasta_Debentures '\' Debenture_atual]);
    end
    
    
    NumeroDebentures_vetor=ones(1,Debenture_Num);
    Divida_Debenture=zeros(1,Debenture_Num);
    
    vetorDatasDebentureSimulacao=zeros(Debenture_Num,length(vetor_dataNumerica));
    
    h = waitbar(0,'Carregando dívidas...');
    
end % if simulacao

for j=1:Debenture_Num
    
    data = Dados{j};
    read_xls_geral
%     read_xls_geral_semPremio
    
    Debentures{1,j}=db;
    
    if ~strcmp(tipo_BNDES,'BNDES')
        NumeroDebentures_vetor(j) = Debentures{1,j}.NumeroDebentures;
        
        %     inicio_Index=find(raw_IPCA(:,1)==Debentures{1,j}.dateEmissao);
        %     fim_Index=find(raw_IPCA(:,1)==Debentures{1,j}.dateFinal);
        
        inicio_Index = find(raw_IPCA(:,1) <= Debentures{1,j}.dateEmissao,1,'last');
        fim_Index = find(raw_IPCA(:,1) <= Debentures{1,j}.dateFinal,1,'last');
        
        startDebenture = find(vetor_dataNumerica <= Debentures{1,j}.dateEmissao,1,'last');
        endDebenture = find(vetor_dataNumerica <= Debentures{1,j}.dateFinal,1,'last');
        
    else
        startDebenture = find(vetor_dataNumerica <= Debentures{1,j}.dateLiberacao(1),1,'last');
        endDebenture = find(vetor_dataNumerica <= Debentures{1,j}.dateFimAmortizacao,1,'last');
    end
    
    if isempty(startDebenture) && ~isempty(endDebenture)
        startDebenture = 1;
    end
    
    if startDebenture==endDebenture
        startDebenture = [];
        endDebenture = [];
    end
    
    vetorDatasDebentureSimulacao(j,(startDebenture:endDebenture)) = 1;
    
    if strcmp(tipo,'IPCA')
        debentureIPCA = raw_IPCA(inicio_Index:fim_Index,2:end);
        Debentures{1,j}.ipca = [Debentures{1,j}.ipca(:,1) [ones(1,numRealidades) ones(1,realidadesPorSimulacao-numRealidades);cumprod(1+debentureIPCA);zeros(size(Debentures{1,j}.ipca(:,1),1)-size(debentureIPCA,1)-1,realidadesPorSimulacao)]];
        %         Debentures{1,j}.n_cenarios = numRealidades;
    elseif strcmp(tipo,'IGPM')
        debentureIGPM = raw_IGPM(inicio_Index:fim_Index,2:end);
        Debentures{1,j}.ipca = [Debentures{1,j}.ipca(:,1) [ones(1,numRealidades) ones(1,realidadesPorSimulacao-numRealidades);cumprod(1+debentureIGPM);zeros(size(Debentures{1,j}.ipca(:,1),1)-size(debentureIGPM,1)-1,realidadesPorSimulacao)]];
        %         Debentures{1,j}.n_cenarios = numRealidades;
    elseif strcmp(tipo,'CDI')
        %         Debentures{1,j}.n_cenarios = numRealidades;
        geraCDIdiario
        Debentures{1,j}.cdi = debentureCDI;
    elseif strcmp(tipo_BNDES,'BNDES')
        inicio_BNDES = find(raw_TJLP(:,1) <= Debentures{1,j}.dateLiberacao(1),1,'last');
        Debentures{1,j}.TJLP = raw_TJLP(inicio_BNDES,2:end);
    end
        
    Debentures{1,j}.generate;
    
    if simulacao == 1
        waitbar(j/Debenture_Num)
    end

    if strcmp(tipo,'IPCA') ||  strcmp(tipo,'IGPM')
%         gera_Saidas_debenture
    end
    
end

if simulacao == 1
    close(h)
    
    if find(sum(vetorDatasDebentureSimulacao,1)==0)
        choice = questdlg('Aviso: Haverá meses sem dívidas vigentes. Deseja continuar?','Meses sem dívida','Sim','Não','Sim');
        
        if strcmp(choice, 'Não')
            msgbox('Simulação abortada.');
            break
        end
    end
    
end

NumeroDebentures_cell = num2cell(NumeroDebentures_vetor);
Debentures(2,1:Debenture_Num)=NumeroDebentures_cell;


