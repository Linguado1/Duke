function [MtM_Dividas,MtM_Total_Dividas,JurosNonCash_Dividas,CorrecaoNonCash_Dividas,PnLnonCash_Total_Dividas,JurosCash_Total_Dividas,...
    CorrecaoCash_Total_Dividas,PnLCash_Total_Dividas,Amortizacao_Dividas,Amortizacao_Total_Dividas,NominalInicial_Dividas,NominalInicial_Total_Dividas, ...
    valorCustoEmisao_total, valorCustoEmisao_distribuido_total, valorCustoCETIP_total, valorCustoMensal_total, valorCustoSemestral_total, valorCustoAnual_total, ...
    valorPremioPrePagamento_total,valorPremioReducaoCapital_total, valorPremioReducaoCapital_distribuido_total, datasSim] = calculaDebentures_v2(mesesSimulacao, vetorDebentures, dataInSimN)

load isDiaUtil;

% dataInSimS = '15/09/2008';
% dataInSimN = datenum(dataInSimS, 'dd/mm/yyyy');

monthInSimN = month(dataInSimN);
yearInSimN = year(dataInSimN);

dataFinSimN = addtodate(dataInSimN, mesesSimulacao, 'month')-1;

monthFinSimN = month(dataFinSimN);
yearFinSimN = year(dataFinSimN);

numMesesSim = mesesSimulacao;
datasSim = zeros(numMesesSim, 1);

if monthInSimN==1
    monthInSimN_DividaInicial=12;
    yearInSimN_DividaInicial = yearInSimN-1;
else
    monthInSimN_DividaInicial=monthInSimN-1;
    yearInSimN_DividaInicial=yearInSimN;
end

ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == monthInSimN_DividaInicial & year(isDiaUtil(1,:)) == yearInSimN_DividaInicial), 1, 'last');
ultimoDiaUtilS = num2str(ultimoDiaUtil);

dataDividaInicial = datenum([ultimoDiaUtilS '/' num2str(monthInSimN_DividaInicial) '/' num2str(yearInSimN_DividaInicial)], 'dd/mm/yyyy');

cont = 1;

anoS = num2str(yearInSimN);
for i = monthInSimN : 12
    ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == i & year(isDiaUtil(1,:)) == yearInSimN), 1, 'last');
    ultimoDiaUtilS = num2str(ultimoDiaUtil);
    mesS = num2str(i);
    datasSim(cont, 1) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
    cont = cont + 1;
end

for i = (yearInSimN + 1) : (yearFinSimN - 1)
    for j = 1 : 12
        ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == j & year(isDiaUtil(1,:)) == i), 1, 'last');
        ultimoDiaUtilS = num2str(ultimoDiaUtil);
        mesS = num2str(j);
        anoS = num2str(i);
        datasSim(cont, 1) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
        cont = cont + 1;
    end
end

anoS = num2str(yearFinSimN);
for i = 1 : monthFinSimN
    ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == i & year(isDiaUtil(1,:)) == yearFinSimN), 1, 'last');
    ultimoDiaUtilS = num2str(ultimoDiaUtil);
    mesS = num2str(i);
    datasSim(cont, 1) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
    cont = cont + 1;
end

% for i = 1 : numMesesSim
%     datasSim(i, 1) = datasSimAux;
%     datasSimAux = addtodate(datasSimAux, 1, 'month');
% end

numDbs = size(vetorDebentures,2);

%% Price (MtM)

datasPriceDb = zeros(numMesesSim+1, numDbs);
numCenarios = vetorDebentures{1, 1}.n_cenarios;
MtM_Dividas = zeros(numMesesSim+1, numCenarios + 1, numDbs);
MtM_Total_Dividas = zeros(numMesesSim+1, numCenarios + 1);
datasSimMtM = [dataDividaInicial;datasSim];


for i = 1 : numDbs
    datasPriceDbAux = vetorDebentures{1, i}.Datas_FimDoMes;
    if strcmp(vetorDebentures{1, i}.tipo,'BNDES')
        datasPriceDbAux = datasPriceDbAux';
    end
    priceDbAux = vetorDebentures{1, i}.MtM_FimDoMes;
    filtro1 = datasPriceDbAux >= datasSimMtM(1);
    filtro2 = datasPriceDbAux <= datasSimMtM(end);
    filtroPrice = filtro1 & filtro2;

    if sum(filtroPrice) ~= 0
        datasPriceDbAux2(:, i) = datasPriceDbAux(filtroPrice);  
        numDatasValidas = length(datasPriceDbAux2(:, i));
        filtroPrice = repmat(filtroPrice, 1, numCenarios);

        priceDbAux2 = reshape(priceDbAux(filtroPrice), numDatasValidas, numCenarios); 
        for j = 1 : size(datasPriceDbAux2, 1)
            MtM_Dividas(datasSimMtM == datasPriceDbAux2(j, i), 2 : end, i) = priceDbAux2(j, :)*vetorDebentures{2,i};
            datasPriceDb(datasSimMtM == datasPriceDbAux2(j, i)) = datasPriceDbAux2(j, i);
        end
        MtM_Dividas(:, 1, i) = 0 : numMesesSim;
    end
    clear datasPriceDbAux priceDbAux filtro1 filtro2 filtroPrice datasPriceDbAux2 numDatasValidas priceDbAux2  
end

MtM_Total_Dividas(:,1)= 0 : numMesesSim;
MtM_Total_Dividas(:,2:end) = sum(MtM_Dividas(:,2:end,:),3);

%% Juros Acumulado / Juros Acumulado + Correção Acumulada (PnL non-cash)

datasJurosADb = zeros(numMesesSim, numDbs);
JurosNonCash_Dividas = zeros(numMesesSim, numCenarios + 1, numDbs);

datasCorrecaoADb = zeros(numMesesSim, numDbs);
CorrecaoNonCash_Dividas = zeros(numMesesSim, numCenarios + 1, numDbs);

PnLnonCash_Total_Dividas = zeros(numMesesSim, numCenarios + 1);

for i = 1 : numDbs
    datasJurosADbAux = vetorDebentures{1, i}.Datas_FimDoMes;
    if strcmp(vetorDebentures{1, i}.tipo, 'CDI') || strcmp(vetorDebentures{1, i}.tipo, 'BNDES')
        jurosADbAux = vetorDebentures{1, i}.PnL_FimDoMes;
    else
        jurosADbAux = vetorDebentures{1, i}.PnL_Juros_FimDoMes;
    end
    filtro1 = datasJurosADbAux >= datasSim(1);
    filtro2 = datasJurosADbAux <= datasSim(end);
    filtroJurosA = filtro1 & filtro2;
    if sum(filtroJurosA) ~= 0
        datasJurosADbAux2(:, i) = datasJurosADbAux(filtroJurosA);   
        numDatasValidas = length(datasJurosADbAux2(:, i));
        filtroJurosA = repmat(filtroJurosA, 1, numCenarios);
        jurosADbAux2(:, :, i) = reshape(jurosADbAux(filtroJurosA), numDatasValidas, numCenarios); 
        for j = 1 : size(datasJurosADbAux2, 1)
            JurosNonCash_Dividas(datasSim == datasJurosADbAux2(j, i), 2 : end, i) = jurosADbAux2(j, :, i)*vetorDebentures{2,i};
            datasJurosADb(datasSim == datasJurosADbAux2(j, i)) = datasJurosADbAux2(j, i);
        end
        JurosNonCash_Dividas(:, 1, i) = 1 : numMesesSim;
    end
    clear filtro1 filtro2 numDatasValidas
    
    if strcmp(vetorDebentures{1, i}.tipo, 'IPCA') || strcmp(vetorDebentures{1, i}.tipo, 'IGPM')
        datasCorrecaoADbAux = vetorDebentures{1, i}.Datas_FimDoMes;
        correcaoADbAux = vetorDebentures{1, i}.PnL_Correcao_FimDoMes;
        filtro1 = datasCorrecaoADbAux >= datasSim(1);
        filtro2 = datasCorrecaoADbAux <= datasSim(end);
        filtroCorrecaoA = filtro1 & filtro2;
        if sum(filtroCorrecaoA) ~= 0
            datasCorrecaoADbAux2(:, i) = datasCorrecaoADbAux(filtroCorrecaoA);
            numDatasValidas = length(datasCorrecaoADbAux2(:, i));
            filtroCorrecaoA = repmat(filtroCorrecaoA, 1, numCenarios);
            correcaoADbAux2(:, :, i) = reshape(correcaoADbAux(filtroCorrecaoA), numDatasValidas, numCenarios);
            for j = 1 : size(datasCorrecaoADbAux2, 1)
                CorrecaoNonCash_Dividas(datasSim == datasCorrecaoADbAux2(j, i), 2 : end, i) = correcaoADbAux2(j, :, i)*vetorDebentures{2,i};
                datasCorrecaoADb(datasSim == datasCorrecaoADbAux2(j, i)) = datasCorrecaoADbAux2(j, i);
            end
        end
    CorrecaoNonCash_Dividas(:, 1, i) = 1 : numMesesSim;
    end
    clear datasJurosADbAux jurosADbAux filtro1 filtro2 numDatasValidas filtroJurosA datasJurosADbAux2 jurosADbAux2 datasCorrecaoADbAux correcaoADbAux filtroCorrecao datasCorrecaoADbAux2 correcaoADbAux2
end

PnLnonCash_Total_Dividas(:,1)= 1 : numMesesSim;
PnLnonCash_Total_Dividas(:,2:end) = sum(JurosNonCash_Dividas(:,2:end,:),3) + sum(CorrecaoNonCash_Dividas(:,2:end,:),3);

%% Juros Pago / Juros Pago + Correção Paga (PnL cash)

datasJurosDb = zeros(numMesesSim, numDbs);
JurosCash_Dividas = zeros(numMesesSim, numCenarios + 1, numDbs);

datasCorrecaoDb = zeros(numMesesSim, numDbs);
CorrecaoCash_Dividas = zeros(numMesesSim, numCenarios + 1, numDbs);

JurosCash_Total_Dividas=zeros(numMesesSim, numCenarios + 1);
CorrecaoCash_Total_Dividas=zeros(numMesesSim, numCenarios + 1);
PnLCash_Total_Dividas=zeros(numMesesSim, numCenarios + 1);

for i = 1 : numDbs
    datasJurosDbAux = vetorDebentures{1, i}.dateJuros;
    for j = 1 : length(datasJurosDbAux)
        mes = month(datasJurosDbAux(j));
        ano = year(datasJurosDbAux(j));
        ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == mes & year(isDiaUtil(1,:)) == ano), 1, 'last');
        ultimoDiaUtilS = num2str(ultimoDiaUtil);
        mesS = num2str(mes);
        anoS = num2str(ano);
        datasJurosDbAux(j) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
    end
    if strcmp(vetorDebentures{1, i}.tipo, 'BNDES')
        jurosDbAux = vetorDebentures{1, i}.jurosPagos;
    else
        jurosDbAux = vetorDebentures{1, i}.juros;
    end
    filtro1 = datasJurosDbAux >= datasSim(1);
    filtro2 = datasJurosDbAux <= datasSim(end);
    filtroJuros = filtro1 & filtro2;
    if sum(filtroJuros) ~= 0
        datasJurosDbAux2(:, i) = datasJurosDbAux(filtroJuros);
        numDatasValidas = length(datasJurosDbAux2(:, i));
        filtroJuros = repmat(filtroJuros, 1, numCenarios);
        jurosDbAux2(:, :, i) = reshape(jurosDbAux(filtroJuros), numDatasValidas, numCenarios);
        for j = 1 : size(datasJurosDbAux2, 1)
            JurosCash_Dividas(datasSim == datasJurosDbAux2(j, i), 2 : end, i) = jurosDbAux2(j, :, i)*vetorDebentures{2,i};
            datasJurosDb(datasSim == datasJurosDbAux2(j, i)) = datasJurosDbAux2(j, i);
        end
        JurosCash_Dividas(:, 1, i) = 1 : numMesesSim;
    end
    clear filtro1 filtro2 numDatasValidas

    if strcmp(vetorDebentures{1, i}.tipo, 'IPCA') || strcmp(vetorDebentures{1, i}.tipo, 'IGPM')
        
        datasCorrecaoDbAux = vetorDebentures{1, i}.amortizacao(:,1);
        for j = 1 : length(datasCorrecaoDbAux)
            mes = month(datasCorrecaoDbAux(j));
            ano = year(datasCorrecaoDbAux(j));
            ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == mes & year(isDiaUtil(1,:)) == ano), 1, 'last');
            ultimoDiaUtilS = num2str(ultimoDiaUtil);
            mesS = num2str(mes);
            anoS = num2str(ano);
            datasCorrecaoDbAux(j) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
        end
        correcaoDbAux = vetorDebentures{1, i}.correcaoPaga;
        filtro1 = datasCorrecaoDbAux >= datasSim(1);
        filtro2 = datasCorrecaoDbAux <= datasSim(end);
        filtroCorrecao = filtro1 & filtro2;
        if sum(filtroCorrecao) ~= 0
            datasCorrecaoDbAux2(:, i) = datasCorrecaoDbAux(filtroCorrecao);
            numDatasValidas = length(datasCorrecaoDbAux2(:, i));
            filtroCorrecao = repmat(filtroCorrecao, 1, numCenarios);
            correcaoDbAux2(:, :, i) = reshape(correcaoDbAux(filtroCorrecao), numDatasValidas, numCenarios);
            for j = 1 : size(datasCorrecaoDbAux2, 1)
                CorrecaoCash_Dividas(datasSim == datasCorrecaoDbAux2(j, i), 2 : end, i) = correcaoDbAux2(j, :, i)*vetorDebentures{2,i};
                datasCorrecaoDb(datasSim == datasCorrecaoDbAux2(j, i)) = datasCorrecaoDbAux2(j, i);
            end
            CorrecaoCash_Dividas(:, 1, i) = 1 : numMesesSim;
        end
    end
    
    clear datasJurosDbAux jurosDbAux filtro1 filtro2 numDatasValidas filtroJuros datasJurosDbAux2 jurosDbAux2 datasCorrecaoDbAux correcaoDbAux filtroCorrecao datasCorrecaoDbAux2 correcaoDbAux2
end

JurosCash_Total_Dividas(:,1)= 1 : numMesesSim;
JurosCash_Total_Dividas(:,2:end) = sum(JurosCash_Dividas(:,2:end,:),3);

CorrecaoCash_Total_Dividas(:,1)= 1 : numMesesSim;
CorrecaoCash_Total_Dividas(:,2:end) = sum(CorrecaoCash_Dividas(:,2:end,:),3);

PnLCash_Total_Dividas(:,1)= 1 : numMesesSim;
PnLCash_Total_Dividas(:,2:end) = sum(JurosCash_Dividas(:,2:end,:),3) + sum(CorrecaoCash_Dividas(:,2:end,:),3);
    

%% Amortização

datasAmortizacaoDb = zeros(numMesesSim, numDbs);
Amortizacao_Dividas = zeros(numMesesSim, numCenarios + 1, numDbs);

Amortizacao_Total_Dividas=zeros(numMesesSim, numCenarios + 1);

for i = 1 : numDbs

    if strcmp(vetorDebentures{1, i}.tipo, 'IPCA') || strcmp(vetorDebentures{1, i}.tipo, 'IGPM') || strcmp(vetorDebentures{1, i}.tipo, 'CDI')
        
        datasAmortizacaoDbAux = vetorDebentures{1, i}.amortizacao(:,1);
        for j = 1 : length(datasAmortizacaoDbAux)
            mes = month(datasAmortizacaoDbAux(j));
            ano = year(datasAmortizacaoDbAux(j));
            ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == mes & year(isDiaUtil(1,:)) == ano), 1, 'last');
            ultimoDiaUtilS = num2str(ultimoDiaUtil);
            mesS = num2str(mes);
            anoS = num2str(ano);
            datasAmortizacaoDbAux(j) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
        end
        amortizacaoDbAux = repmat(vetorDebentures{1, i}.amortizacao(:,2),1,numCenarios);
        filtro1 = datasAmortizacaoDbAux >= datasSim(1);
        filtro2 = datasAmortizacaoDbAux <= datasSim(end);
        filtroAmortizacao = filtro1 & filtro2;
        if sum(filtroAmortizacao) ~= 0
            datasAmortizacaoDbAux2(:, i) = datasAmortizacaoDbAux(filtroAmortizacao);
            numDatasValidas = length(datasAmortizacaoDbAux2(:, i));
            filtroAmortizacao = repmat(filtroAmortizacao, 1, numCenarios);
            amortizacaoDbAux2(:, :, i) = reshape(amortizacaoDbAux(filtroAmortizacao), numDatasValidas, numCenarios);
            for j = 1 : size(datasAmortizacaoDbAux2, 1)
                Amortizacao_Dividas(datasSim == datasAmortizacaoDbAux2(j, i), 2 : end, i) = amortizacaoDbAux2(j, :, i)*vetorDebentures{2,i};
                datasAmortizacaoDb(datasSim == datasAmortizacaoDbAux2(j, i)) = datasAmortizacaoDbAux2(j, i);
            end
            Amortizacao_Dividas(:, 1, i) = 1 : numMesesSim;
        end
        
    elseif strcmp(vetorDebentures{1, i}.tipo, 'BNDES')
        
        datasAmortizacaoDbAux = vetorDebentures{1, i}.Datas_FimDoMes(vetorDebentures{1, i}.Datas_FimDoMes> vetorDebentures{1, i}.dateFimCarencia & vetorDebentures{1, i}.Datas_FimDoMes<= vetorDebentures{1, i}.dateFimAmortizacao);
        for j = 1 : length(datasAmortizacaoDbAux)
            mes = month(datasAmortizacaoDbAux(j));
            ano = year(datasAmortizacaoDbAux(j));
            ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == mes & year(isDiaUtil(1,:)) == ano), 1, 'last');
            ultimoDiaUtilS = num2str(ultimoDiaUtil);
            mesS = num2str(mes);
            anoS = num2str(ano);
            datasAmortizacaoDbAux(j) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
        end
        amortizacaoDbAux = vetorDebentures{1, i}.amortizacaoPaga;
        filtro1 = datasAmortizacaoDbAux >= datasSim(1);
        filtro2 = datasAmortizacaoDbAux <= datasSim(end);
        filtroAmortizacao = filtro1 & filtro2;
        if sum(filtroAmortizacao) ~= 0
            datasAmortizacaoDbAux2(:, i) = datasAmortizacaoDbAux(filtroAmortizacao);
            numDatasValidas = length(datasAmortizacaoDbAux2(:, i));
            filtroAmortizacao = repmat(filtroAmortizacao, 1, numCenarios);
            amortizacaoDbAux2(:, :, i) = reshape(amortizacaoDbAux(filtroAmortizacao), numDatasValidas, numCenarios);
            for j = 1 : size(datasAmortizacaoDbAux2, 1)
                Amortizacao_Dividas(datasSim == datasAmortizacaoDbAux2(j, i), 2 : end, i) = amortizacaoDbAux2(j, :, i)*vetorDebentures{2,i};
                datasAmortizacaoDb(datasSim == datasAmortizacaoDbAux2(j, i)) = datasAmortizacaoDbAux2(j, i);
            end
            Amortizacao_Dividas(:, 1, i) = 1 : numMesesSim;
        end
        
    end
    
    clear datasAmortizacaoDbAux amortizacaoDbAux filtro1 filtro2 numDatasValidas filtroAmortizacao datasAmortizacaoDbAux2 amortizacaoDbAux2
end

Amortizacao_Total_Dividas(:,1)= 1 : numMesesSim;
Amortizacao_Total_Dividas(:,2:end) = sum(Amortizacao_Dividas(:,2:end,:),3);


%% Valor Nominal Inicial

datasNominalInicialDb = zeros(numMesesSim, numDbs);
NominalInicial_Dividas = zeros(numMesesSim, 2, numDbs);

NominalInicial_Total_Dividas=zeros(numMesesSim, 2);

for i = 1 : numDbs

    if strcmp(vetorDebentures{1, i}.tipo, 'IPCA') || strcmp(vetorDebentures{1, i}.tipo, 'IGPM') || strcmp(vetorDebentures{1, i}.tipo, 'CDI')
        
        dataNominalInicialDbAux = vetorDebentures{1, i}.dateEmissao;
        mes = month(dataNominalInicialDbAux);
        ano = year(dataNominalInicialDbAux);
        ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == mes & year(isDiaUtil(1,:)) == ano), 1, 'last');
        ultimoDiaUtilS = num2str(ultimoDiaUtil);
        mesS = num2str(mes);
        anoS = num2str(ano);
        dataNominalInicialDbAux = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
            
        nominalInicialDbAux = vetorDebentures{1, i}.nominalInicial;
        filtro1 = dataNominalInicialDbAux >= datasSim(1);
        filtro2 = dataNominalInicialDbAux <= datasSim(end);
        filtroNominalInicial = filtro1 & filtro2;
        if sum(filtroNominalInicial) ~= 0           
            NominalInicial_Dividas(datasSim == dataNominalInicialDbAux, 2, i) = nominalInicialDbAux*vetorDebentures{2,i};
            datasNominalInicialDb(datasSim == dataNominalInicialDbAux) = dataNominalInicialDbAux;
        end        
        NominalInicial_Dividas(:, 1, i) = 1 : numMesesSim;
        
    elseif strcmp(vetorDebentures{1, i}.tipo, 'BNDES')
        
        dataNominalInicialDbAux = vetorDebentures{1, i}.dateLiberacao';
        for j = 1 : length(dataNominalInicialDbAux)
            mes = month(dataNominalInicialDbAux(j));
            ano = year(dataNominalInicialDbAux(j));
            ultimoDiaUtil = find(isDiaUtil(2, month(isDiaUtil(1,:)) == mes & year(isDiaUtil(1,:)) == ano), 1, 'last');
            ultimoDiaUtilS = num2str(ultimoDiaUtil);
            mesS = num2str(mes);
            anoS = num2str(ano);
            dataNominalInicialDbAux(j) = datenum([ultimoDiaUtilS '/' mesS '/' anoS], 'dd/mm/yyyy');
        end
        nominalInicialDbAux = vetorDebentures{1, i}.liberacao';
        filtro1 = dataNominalInicialDbAux >= datasSim(1);
        filtro2 = dataNominalInicialDbAux <= datasSim(end);
        filtroNominalInicial = filtro1 & filtro2;
        if sum(filtroNominalInicial) ~= 0
            datasNominalInicialDbAux2(:, i) = dataNominalInicialDbAux(filtroNominalInicial);
            nominalInicialDbAux2(:, i) = nominalInicialDbAux(filtroNominalInicial);
            for j = 1 : size(datasNominalInicialDbAux2, 1)
                NominalInicial_Dividas(datasSim == datasNominalInicialDbAux2(j, i), 2, i) = nominalInicialDbAux2(j, i)*vetorDebentures{2,i};
                datasNominalInicialDb(datasSim == datasNominalInicialDbAux2(j, i)) = datasNominalInicialDbAux2(j, i);
            end
            NominalInicial_Dividas(:, 1, i) = 1 : numMesesSim;
        end
        
     end
    
    clear dataNominalInicialDbAux nominalInicialDbAux filtro1 filtro2 numDatasValidas filtroNominalInicial datasNominalInicialDbAux2 nominalInicialDbAux2
end

NominalInicial_Total_Dividas(:,1)= 1 : numMesesSim;
NominalInicial_Total_Dividas(:,2) = sum(NominalInicial_Dividas(:,2,:),3);


%% Prêmios de Pré Pagamento e Redução de Capital

% Inicializa variáveis
valorPremioPrePagamento = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorPremioReducaoCapital = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorPremioReducaoCapital_distribuido = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));

valorPremioPrePagamento_total = zeros(numMesesSim+1, numCenarios + 1);
valorPremioReducaoCapital_total = zeros(numMesesSim+1, numCenarios + 1);
valorPremioReducaoCapital_distribuido_total = zeros(numMesesSim+1, numCenarios + 1);

for i=1:size(vetorDebentures,2)
    
    if ~strcmp(vetorDebentures{1,i}.tipo,'BNDES')
        
        dataPrePag_Mes = [num2str(month(vetorDebentures{1,i}.dateFinal)) '/' num2str(year(vetorDebentures{1,i}.dateFinal))];
        
        filtroPrePagamento_Mes = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') == datenum(dataPrePag_Mes,'mm/yyyy');
        
        % Se é último dia da dívida, paga Prêmio de Pre Pagamento
        if sum(filtroPrePagamento_Mes) >0;
            valorPremioPrePagamento(filtroPrePagamento_Mes,:,i) = vetorDebentures{1,i}.price(end-1, :) * vetorDebentures{1,i}.pPremioPrePagamento * vetorDebentures{2,i};
        end
        
        for iReducao = 1:length(vetorDebentures{1,i}.dateReducaoCapital)
            
            dataReducao_Mes = [num2str(month(vetorDebentures{1,i}.dateReducaoCapital(iReducao))) '/' num2str(year(vetorDebentures{1,i}.dateReducaoCapital(iReducao)))];
            
            filtroReducaoCapital_Mes = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') == datenum(dataReducao_Mes,'mm/yyyy');
            filtroReducaoCapital_Dia = vetorDebentures{1,i}.datas == vetorDebentures{1,i}.dateReducaoCapital(iReducao);
            
            filtroReducaoCapitalDistribuido = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') >= datenum(dataReducao_Mes,'mm/yyyy') ...
            & datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') <= datenum(vetorDebentures{1,i}.dateFinal);
        
            periodoDistribui_ReducaoCapital = sum(vetorDebentures{1,i}.Datas_FimDoMes >= vetorDebentures{1,i}.dateReducaoCapital(iReducao) ...
                & vetorDebentures{1,i}.Datas_FimDoMes <= datenum(vetorDebentures{1,i}.dateFinal));
            
            % Se é dia de redução de capital, paga Prêmio de Redução de Capital
            if sum(filtroReducaoCapital_Mes) >0;
                valorPremioReducaoCapital(filtroReducaoCapital_Mes,:,i) = vetorDebentures{1,i}.price(filtroReducaoCapital_Dia, :) * vetorDebentures{1,i}.pPremioReducaoCapital(iReducao) * vetorDebentures{2,i};
                valorPremioReducaoCapital_distribuido(filtroReducaoCapitalDistribuido,:,i) = valorPremioReducaoCapital(filtroReducaoCapital_Mes,:,i)/periodoDistribui_ReducaoCapital;
            end
        end
    end
end

valorPremioPrePagamento_total(:,1) =  0 : numMesesSim;
valorPremioPrePagamento_total(:,2:end) = sum(valorPremioPrePagamento,3);

valorPremioReducaoCapital_total(:,1)=  0 : numMesesSim;
valorPremioReducaoCapital_total(:,2:end) = sum(valorPremioReducaoCapital,3);

valorPremioReducaoCapital_distribuido_total(:,1)=  0 : numMesesSim;
valorPremioReducaoCapital_distribuido_total(:,2:end) = sum(valorPremioReducaoCapital_distribuido,3);


%% Custo de emissão

% Inicializa variáveis
valorCustoEmisao = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorCustoEmisao_distribuido = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorCustoEmisao_total = zeros(numMesesSim+1, numCenarios + 1);
valorCustoEmisao_distribuido_total = zeros(numMesesSim+1, numCenarios + 1);

for i=1:size(vetorDebentures,2)
    
    if ~strcmp(vetorDebentures{1,i}.tipo,'BNDES')
        
        dataEmissao_Mes = [num2str(month(vetorDebentures{1,i}.dateEmissao)) '/' num2str(year(vetorDebentures{1,i}.dateEmissao))];
        filtroEmissao_Mes = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') == datenum(dataEmissao_Mes,'mm/yyyy');
        filtroEmissaoDistribuido = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') >= datenum(dataEmissao_Mes,'mm/yyyy') ...
            & datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') <= datenum(vetorDebentures{1,i}.dateFinal);
        
        periodoDistribui_Emissao = sum(vetorDebentures{1,i}.Datas_FimDoMes >= vetorDebentures{1,i}.dateEmissao ...
            & vetorDebentures{1,i}.Datas_FimDoMes <= datenum(vetorDebentures{1,i}.dateFinal));

        % Se é dia de emissão, paga custo de emissão
        if sum(filtroEmissao_Mes) >0;
            valorCustoEmisao(filtroEmissao_Mes,:,i) = vetorDebentures{1,i}.nominalInicial * vetorDebentures{1,i}.pCustoEmissao * vetorDebentures{2,i};
            valorCustoEmisao_distribuido(filtroEmissaoDistribuido,:,i) = valorCustoEmisao(filtroEmissao_Mes,:,i)/periodoDistribui_Emissao;
        end
    end
end

valorCustoEmisao_total(:,1) =  0 : numMesesSim;
valorCustoEmisao_total(:,2:end) = sum(valorCustoEmisao,3);

valorCustoEmisao_distribuido_total(:,1) =  0 : numMesesSim;
valorCustoEmisao_distribuido_total(:,2:end) = sum(valorCustoEmisao_distribuido,3);

%% Custo CETIP

% Inicializa variáveis
valorCustoCETIP = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorCustoCETIP_total = zeros(numMesesSim+1, numCenarios + 1);

for i=1:size(vetorDebentures,2)
    
    if ~strcmp(vetorDebentures{1,i}.tipo,'BNDES')
        
        filtroDatas_Mes = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') == datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy');
        
        % Paga CETIP todo mes
        if sum(filtroDatas_Mes) >0;
            valorCustoCETIP(filtroDatas_Mes,:,i) = vetorDebentures{1,i}.price(filtroDatas_Mes, :) * vetorDebentures{1,i}.pTaxaCETIP * vetorDebentures{2,i};
        end
    end
end

valorCustoCETIP_total(:,1) =  0 : numMesesSim;
valorCustoCETIP_total(:,2:end) = sum(valorCustoCETIP,3);

%% Custos mensais

% Inicializa variáveis
valorCustoMensal = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorCustoMensal_total = zeros(numMesesSim+1, numCenarios + 1);

for i=1:size(vetorDebentures,2)
    
    if ~strcmp(vetorDebentures{1,i}.tipo,'BNDES')
        
        for iCusto = 1:length(vetorDebentures{1,i}.Datas_FimDoMes)
            
            dataCusto_Mes = [num2str(month(vetorDebentures{1,i}.Datas_FimDoMes(iCusto))) '/' num2str(year(vetorDebentures{1,i}.Datas_FimDoMes(iCusto)))];
            dataCusto_Dia = [num2str(day(vetorDebentures{1,i}.dateEmissao)) '/' dataCusto_Mes];
            
            filtroCusto_Mes = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') == datenum(dataCusto_Mes,'mm/yyyy');
            filtroCusto_Dia = vetorDebentures{1,i}.datas == datenum(dataCusto_Dia,'dd/mm/yyyy');
            
            % Paga curtos mensais
            if sum(filtroCusto_Mes) >0;
                if strcmp(vetorDebentures{1,i}.tipo,'CDI')
                    valorCustoMensal(filtroCusto_Mes,:,i) = vetorDebentures{1,i}.cdiAcumulado(filtroCusto_Dia, :) * vetorDebentures{1,i}.valorCustoMensal * vetorDebentures{2,i};
                else
                    valorCustoMensal(filtroCusto_Mes,:,i) = vetorDebentures{1,i}.ipcaAcumuladoTruncado(filtroCusto_Dia, :) * vetorDebentures{1,i}.valorCustoMensal * vetorDebentures{2,i};
                end
            end
            
        end
    end
end

valorCustoMensal_total(:,1) =  0 : numMesesSim;
valorCustoMensal_total(:,2:end) = sum(valorCustoMensal,3);

%% Custos semestrais

% Inicializa variáveis
valorCustoSemestral = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorCustoSemestral_total = zeros(numMesesSim+1, numCenarios + 1);

for i=1:size(vetorDebentures,2)
    
    if ~strcmp(vetorDebentures{1,i}.tipo,'BNDES')
        
        for iCusto = 1:6:length(vetorDebentures{1,i}.Datas_FimDoMes)
            
            dataCusto_Semestre = [num2str(month(vetorDebentures{1,i}.Datas_FimDoMes(iCusto))) '/' num2str(year(vetorDebentures{1,i}.Datas_FimDoMes(iCusto)))];
            dataCusto_Dia = [num2str(day(vetorDebentures{1,i}.dateEmissao)) '/' dataCusto_Semestre];
            
            filtroCusto_Semestre = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') == datenum(dataCusto_Semestre,'mm/yyyy');
            filtroCusto_Dia = vetorDebentures{1,i}.datas == datenum(dataCusto_Dia,'dd/mm/yyyy');
            
            % Paga custos semestrais
            if sum(filtroCusto_Semestre) >0;
                if strcmp(vetorDebentures{1,i}.tipo,'CDI')
                    valorCustoSemestral(filtroCusto_Semestre,:,i) = vetorDebentures{1,i}.cdiAcumulado(filtroCusto_Dia, :) * vetorDebentures{1,i}.valorCustoSemestral * vetorDebentures{2,i};
                else
                    valorCustoSemestral(filtroCusto_Semestre,:,i) = vetorDebentures{1,i}.ipcaAcumuladoTruncado(filtroCusto_Dia, :) * vetorDebentures{1,i}.valorCustoSemestral * vetorDebentures{2,i};
                end
            end
            
        end
    end
end

valorCustoSemestral_total(:,1) =  0 : numMesesSim;
valorCustoSemestral_total(:,2:end) = sum(valorCustoSemestral,3);

%% Custos anuais

% Inicializa variáveis
valorCustoAnual = zeros(length(datasSimMtM),numCenarios,size(vetorDebentures,2));
valorCustoAnual_total = zeros(numMesesSim+1, numCenarios + 1);

for i=1:size(vetorDebentures,2)
    
    if ~strcmp(vetorDebentures{1,i}.tipo,'BNDES')
        
        for iCusto = 1:12:length(vetorDebentures{1,i}.Datas_FimDoMes)
            
            dataCusto_Ano = [num2str(month(vetorDebentures{1,i}.Datas_FimDoMes(iCusto))) '/' num2str(year(vetorDebentures{1,i}.Datas_FimDoMes(iCusto)))];
            dataCusto_Dia = [num2str(day(vetorDebentures{1,i}.dateEmissao)) '/' dataCusto_Ano];
            
            filtroCusto_Ano = datenum(datestr(datasSimMtM,'mm/yyyy'),'mm/yyyy') == datenum(dataCusto_Ano,'mm/yyyy');
            filtroCusto_Dia = vetorDebentures{1,i}.datas == datenum(dataCusto_Dia,'dd/mm/yyyy');
            
            % Paga custos anuais
            if sum(filtroCusto_Ano) >0;
                if strcmp(vetorDebentures{1,i}.tipo,'CDI')
                    valorCustoAnual(filtroCusto_Ano,:,i) = vetorDebentures{1,i}.cdiAcumulado(filtroCusto_Dia, :) * vetorDebentures{1,i}.valorCustoAnual * vetorDebentures{2,i};
                else
                    valorCustoAnual(filtroCusto_Ano,:,i) = vetorDebentures{1,i}.ipcaAcumuladoTruncado(filtroCusto_Dia, :) * vetorDebentures{1,i}.valorCustoAnual * vetorDebentures{2,i};
                end
            end
            
        end
    end
end

valorCustoAnual_total(:,1) =  0 : numMesesSim;
valorCustoAnual_total(:,2:end) = sum(valorCustoAnual,3);

end

