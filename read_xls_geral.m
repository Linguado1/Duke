%% Inicializa��o

load('isDiaUtil');

tipo = data{2,4};
tipo_BNDES = data{2,8};

if strcmp(tipo,'IPCA') || strcmp(tipo,'IGPM')
    
    % IPCA
    n_col_apos_ipca = 21;
    col_primeiro_ipca = 2;
    col_ultimo_ipca = size(data, 2) - n_col_apos_ipca;
    range_leitura_ipca = col_primeiro_ipca : col_ultimo_ipca;

    ipca_aux = cell2mat(data(2:end, col_primeiro_ipca));
    length_ipca = length(ipca_aux(~isnan(ipca_aux)));   
    ipca = zeros(length_ipca,2);

    ipca(:, range_leitura_ipca) = cell2mat(data(2:(length_ipca + 1), range_leitura_ipca));

    n_cenarios = col_ultimo_ipca - col_primeiro_ipca + 1;

    column = col_ultimo_ipca;

    % Fator Indexador
    column = column + 1;
    fatorIPCA = data{2,column};
    ipca = ipca * fatorIPCA;

    %Tipo
    column = column + 1;
    tipo = data{2,column};

    % Spread
    column = column + 1;
    spread = data{2, column};

    % Valor Nominal
    column = column + 1;
    nominal = data{2, column};

    % Datas de pagamento de juros
    column = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
        dateJuros(i-1,1) = datenum(data{i, column}, 'dd/mm/yyyy');
        end
    end  

    % Datas e valores de amortiza��o
    column = column + 1;
    column_mais_um = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
        amortizacao(i-1, 1) = datenum(data{i, column}, 'dd/mm/yyyy');
        amortizacao(i-1, 2) = data{i, column_mais_um};
        end
    end  

    % Data de emiss�o
    column = column + 2;
    dateEmissao = datenum(data{2, column},'dd/mm/yyyy');

    % Data final
    column = column + 1;
    dateFinal = datenum(data{2, column},'dd/mm/yyyy');

    % N�mero de Debentures
    column = column + 1;
    NumeroDebentures = data{2, column};
    
    % Custos de emiss�o (taxa sobre valor total - DRE rateado at� o fim)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    pCustoEmissao = sum(cell2mat(data(~filtroNAN, column)));
    
    % Taxa CETIP (taxa mensal sobre o saldo)
    column = column + 1;
    pTaxaCETIP = data{2, column};
    
    % Valor a ser pago como custo de manutan��o (mensal)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    valorCustoMensal = sum(cell2mat(data(~filtroNAN, column)));
    
    % Valor a ser pago como custo de manutan��o (semestral)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    valorCustoSemestral = sum(cell2mat(data(~filtroNAN, column)));
    
    % Valor a ser pago como custo de manutan��o (anual)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    valorCustoAnual = sum(cell2mat(data(~filtroNAN, column)));
    
    % Datas de Redu��o de Capital Social
    dateReducaoCapital = 0;
    column = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
        dateReducaoCapital(i-1,1) = datenum(data{i, column}, 'dd/mm/yyyy');
        end
    end
    
    % Premio de Redu��o de Capital Social
    pPremioReducaoCapital = 0;
    column = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
        pPremioReducaoCapital(i-1,1) = data{i, column};
        end
    end
    
    % Pr�mio de Pr� Pagamento
    column = column + 1;
    pPremioPrePagamento = data{2, column}; 
    
    % Coluna de datas de atualiza��o de IPCA

    % Se as datas forem inseridas diretamente
    if ~ data{4, size(data, 2) - 2}
        ipca(:, 1) = datenum(cell2mat(data(2:(length_ipca + 1), 1)), 'dd/mm/yyyy');

    % Se o par�metro de entrada for o dia �til do m�s
    else
        diaUtilAtualizacao = data{2, 1};
        anoEmissao = year(dateEmissao);
        mesEmissao = month(dateEmissao);
        anoFinal = year(dateFinal);
        mesFinal = month(dateFinal);

        % Primeira data � qualquer anterior � Data de Emiss�o da deb�nture
        indiceData = 2;

        for i = mesEmissao : 12
            indicesDiaUtil = find(isDiaUtil(2, ((month(isDiaUtil(1, :)) == i) & (year(isDiaUtil(1, :)) == anoEmissao))), diaUtilAtualizacao);
            dataAtualizacao = [num2str(indicesDiaUtil(end)) '/' num2str(i) '/' num2str(anoEmissao)];
            ipca(indiceData, 1) = datenum(dataAtualizacao, 'dd/mm/yyyy');
            indiceData = indiceData + 1;
        end

        for i = anoEmissao + 1 : anoFinal - 1
            for j = 1 : 12
                indicesDiaUtil = find(isDiaUtil(2, ((month(isDiaUtil(1, :)) == j) & (year(isDiaUtil(1, :)) == i))), diaUtilAtualizacao);
                dataAtualizacao = [num2str(indicesDiaUtil(end)) '/' num2str(j) '/' num2str(i)];
                ipca(indiceData, 1) = datenum(dataAtualizacao, 'dd/mm/yyyy');
                indiceData = indiceData + 1;
            end
        end

        for i = 1 : mesFinal
            indicesDiaUtil = find(isDiaUtil(2, ((month(isDiaUtil(1, :)) == i) & (year(isDiaUtil(1, :)) == anoFinal))), diaUtilAtualizacao);
            dataAtualizacao = [num2str(indicesDiaUtil(end)) '/' num2str(i) '/' num2str(anoFinal)];
            ipca(indiceData, 1) = datenum(dataAtualizacao, 'dd/mm/yyyy');
            indiceData = indiceData + 1;
        end
    end

    % Par�metro de atualiza��o do price
    column = column + 1;
    pAP = cell2mat(data(2, column));

    % Par�metro de contagem do n�mero de dias �teis do m�s
    pCM = cell2mat(data(6, column));

    % Par�metro de atualiza��o do IPCA
    pAIPCA = cell2mat(data(8, column));

    % Par�metro c�lculo do IPCA acumulado
    pUIPCA = cell2mat(data(10, column));

    % TRUE: Saidas DRE �ltimo �til dia do m�s FALSE: �ltimo dia do m�s
    pFimUtil = cell2mat(data(12, column));

    % TRUE: Entrada de indexador em porcentagem
    pIpcaPorcentagem = cell2mat(data(14, column));
    if pIpcaPorcentagem
        entradaIpca = [ipca(:,1) cumprod(1+ipca(:,2))];
    else
        entradaIpca = ipca;
    end

    % Vetor com n�meros de casas para a calculadora
    column = column + 2;
    nC(1 : 9) = cell2mat(data(1 : 9, column));

    %% Constr�i a deb�nture
    
    n_cenarios = realidadesPorSimulacao;
    
    %     db = DebentureManager2(entradaIpca, spread, nominal, dateJuros, amortizacao, dateEmissao, dateFinal, isDiaUtil, n_cenarios, pAP, pCM, pAIPCA, pUIPCA, pFimUtil, nC);
    %     db = DebentureManager2(entradaIpca, tipo, spread, nominal, dateJuros, amortizacao, dateEmissao, dateFinal, isDiaUtil, n_cenarios, pAP, pCM, pAIPCA, pUIPCA, nC);
    db = DebentureManager2(entradaIpca, tipo, spread, nominal, dateJuros, amortizacao, dateEmissao, dateFinal, pPremioPrePagamento, pPremioReducaoCapital, dateReducaoCapital, ...
        pCustoEmissao, pTaxaCETIP, valorCustoMensal, valorCustoSemestral, valorCustoAnual, isDiaUtil, n_cenarios, pAP, pCM, pAIPCA, pUIPCA, nC);
    db.NumeroDebentures = NumeroDebentures;
    
    clear dateJuros amortizacao pPremioPrePagamento pPremioReducaoCapital dateReducaoCapital
    
elseif strcmp(tipo,'CDI')
    
    
    %% CDI
%     n_col_apos_cdi = 10;
%     col_primeira_cdi = 2;
%     col_ultima_cdi = size(data, 2) - n_col_apos_cdi;
%     range_leitura_cdi = col_primeira_cdi : col_ultima_cdi;
% 
%     n_cenarios = col_ultima_cdi - col_primeira_cdi + 1;
% 
%     cdi = cell2mat(data(2:end, range_leitura_cdi));
%     cdi = cdi(~ isnan(cdi));
% 
%     n_linhas_cdi = size(cdi, 1) / n_cenarios;
% 
%     cdi = reshape(cdi, n_linhas_cdi, n_cenarios);
% 
%     column = col_ultima_cdi;

    n_col_apos_cdi = 19;
    col_primeira_cdi = 2;
    col_ultima_cdi = size(data, 2) - n_col_apos_cdi;
    range_leitura_cdi = col_primeira_cdi : col_ultima_cdi;

    n_cenarios = col_ultima_cdi - col_primeira_cdi + 1;

    cdi = cell2mat(data(2:end, range_leitura_cdi));
    cdi = cdi(~ isnan(cdi));

    n_linhas_cdi = size(cdi, 1) / n_cenarios;

    cdi = reshape(cdi, n_linhas_cdi, n_cenarios);

    column = col_ultima_cdi;

    % Fator multiplicador
    column = column + 1;
    fatorMultiplicador = data{2, column};
    cdi=cdi*fatorMultiplicador;

    % Tipo
    column = column + 1;
    tipo = data{2, column};

    % Spread
    column = column + 1;
    spread = data{2, column};

    % Valor Nominal
    column = column + 1;
    nominal = data{2, column};

    % Datas de pagamento de juros
    column = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
            dateJuros(i-1,1) = datenum(data{i, column}, 'dd/mm/yyyy');
        end
    end

    % Datas e valores de amortiza��o
    column = column + 1;
    column_mais_um = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
            amortizacao(i-1, 1) = datenum(data{i, column}, 'dd/mm/yyyy');
            amortizacao(i-1, 2) = data{i, column_mais_um};
        end
    end

    % Data de emiss�o
    column = column + 2;
    dateEmissao = datenum(data{2, column},'dd/mm/yyyy');

    % Data final
    column = column + 1;
    dateFinal = datenum(data{2, column},'dd/mm/yyyy');

    % N�mero de Debentures
    column = column + 1;
    NumeroDebentures = data{2, column};
    
    % Custos de emiss�o (taxa sobre valor total - DRE rateado at� o fim)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    pCustoEmissao = sum(cell2mat(data(~filtroNAN, column)));
    
    % Taxa CETIP (taxa mensal sobre o saldo)
    column = column + 1;
    pTaxaCETIP = data{2, column};
    
    % Valor a ser pago como custo de manutan��o (mensal)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    valorCustoMensal = sum(cell2mat(data(~filtroNAN, column)));
    
    % Valor a ser pago como custo de manutan��o (semestral)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    valorCustoSemestral = sum(cell2mat(data(~filtroNAN, column)));
    
    % Valor a ser pago como custo de manutan��o (anual)
    column = column + 1;
    filtroNAN = [1; isnan(cell2mat(data(2:end, column)))];
    valorCustoAnual = sum(cell2mat(data(~filtroNAN, column)));
    
    % Datas de Redu��o de Capital Social
    column = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
        dateReducaoCapital(i-1,1) = datenum(data{i, column}, 'dd/mm/yyyy');
        end
    end
    
    % Premio de Redu��o de Capital Social
    column = column + 1;
    for i = 2 : size(data, 1)
        if isnan(datenum(data{i, column}))
            break;
        else
        pPremioReducaoCapital(i-1,1) = data{i, column};
        end
    end
    
    % Pr�mio de Pr� Pagamento
    column = column + 1;
    pPremioPrePagamento = data{2, column}; 
    
    % Par�metro de atualiza��o do price
    column = column + 1;
    pAP = cell2mat(data(2, column));
    pFimUtil = cell2mat(data(4, column));
    pEntradaMensal = cell2mat(data(6, column));

    if pEntradaMensal

        rangeDias = dateEmissao:dateFinal;
        nDias=length(rangeDias);
        cdiDiario = zeros(nDias,n_cenarios);
        cdiEsteMes = cdi(1,:);
        countCDI=1;
        esteMes = month(dateEmissao);
        for k=1:nDias

            if month(rangeDias(k))~=esteMes;
                countCDI=countCDI+1;
                esteMes=month(rangeDias(k));
                cdiEsteMes = cdi(countCDI,:);
            end

            cdiDiario(k,:)=cdiEsteMes;
        end

        cdi=cdiDiario;
    end

    %% Constr�i a deb�nture
    
    n_cenarios = realidadesPorSimulacao;
        
    db = DebentureManager(cdi, spread, nominal, dateJuros, amortizacao, dateEmissao, dateFinal, pPremioPrePagamento, pPremioReducaoCapital, dateReducaoCapital, ...
        pCustoEmissao, pTaxaCETIP, valorCustoMensal, valorCustoSemestral, valorCustoAnual, isDiaUtil, n_cenarios, pAP, pFimUtil);
    db.NumeroDebentures = NumeroDebentures;

elseif strcmp(tipo_BNDES,'BNDES')
    
    %% L� os dados de entrada de source_filename
    
%     % source_filename = 'excel_source_ex4teste';
%     [source_filepath , source_filename] = uigetfile({'*.xlsm;*.xlsx;*.xls' , 'EXCEL (*xlsm,*.xlsx,*.xls)'}, 'Abrir Planilha');
%     
%     source_filename = [source_filename source_filepath];
%     
%     [~, ~, data] = xlsread(source_filename);
    
    % TJLP
    TJLP=data{2,1};
    
    % Spread
    spread=data{2,2};
    
    % Valor Liberado
    ValorLiberado=cell2mat(data(2:end,3));
    ValorLiberado = ValorLiberado(~ isnan(ValorLiberado));
    
    % Datas de Libera��o
    for k = 2 : size(data, 1)
        
        if isnan(data{k,4})
            break;
        else
            DataLiberacao(k-1)=datenum(data{k,4},'dd/mm/yyyy');
        end
        
    end
    
    % Fim da Carencia
    DataFimCarencia = datenum(data{2,5},'dd/mm/yyyy');
    
    % Datas Pagamento de Juros
    for k = 2 : size(data, 1)
        
        if isnan(data{k,6})
            break;
        else
            DataPagamentoJuros(k-1)=datenum(data{k,6},'dd/mm/yyyy');
        end
        
    end
    
    % Prazo da D�vida
    DataFimDivida = datenum(data{2,7},'dd/mm/yyyy');
    
    %% Constr�i e roda a deb�nture
    db = DividaBNDES(TJLP, spread, ValorLiberado', DataLiberacao, DataFimCarencia, DataPagamentoJuros, DataFimDivida, isDiaUtil);
%     db.generate();
    
end