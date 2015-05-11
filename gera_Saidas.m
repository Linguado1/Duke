
if ~Pasta_Resultados
    msgbox('Compilação de resultados abortada.')
    break
end

% load('Output.mat')

conv_data_mat2xls = -693960;

Vetor_menos1dia = [0 ones(1,length(vetor_dataNumerica)-1)];
vetor_dataNumericaMenosUm = vetor_dataNumerica - Vetor_menos1dia;
vetor_dataAnual = year(vetor_dataNumericaMenosUm(2:12:end));

yout.signals(6).values = repmat(squeeze(yout.signals(6).values),1,numRealidades);
yout.signals(13).values = repmat(squeeze(yout.signals(13).values),1,numRealidades);
yout.signals(16).values = repmat(squeeze(yout.signals(16).values),1,numRealidades);
yout.signals(18).values = repmat(squeeze(yout.signals(18).values),1,numRealidades);
yout.signals(29).values = repmat(squeeze(yout.signals(29).values),1,numRealidades);

% filtroDatasFimAno=find((month(vetor_dataNumericaMenosUm(1:mesesSimulacao+1))==12));
filtroDatasFimTrimestre=find(mod(month(vetor_dataNumericaMenosUm(1:mesesSimulacao+1)),3)==0);
if filtroDatasFimTrimestre(1) == 1 && filtroDatasFimTrimestre(2) == 2
    filtroCovenants = filtroDatasFimTrimestre(2:end);
else
    filtroCovenants = filtroDatasFimTrimestre;
end

vetorDatasCovenants = vetor_dataNumericaMenosUm(filtroCovenants);

vetorDebt_EBITDA = yout.signals(22).values(filtroCovenants,1:numRealidades);
vetorEBITDA_FinancialResult = yout.signals(23).values(filtroCovenants,1:numRealidades);
vetorDebt_DebtEquity = yout.signals(24).values(filtroCovenants,1:numRealidades);

vetorEBITDA_FinancialResult = max(min(vetorEBITDA_FinancialResult,200),-10);

tamanho_Covenants = size(vetorDebt_DebtEquity,1);
Matriz_Covenants = zeros(tamanho_Covenants,numRealidades,3);

Matriz_saidas = [ ...
    % Income Statement
    % Incluir (:,1:numRealidades) se realidadesPorSimulacao > 1
    squeeze(yout.signals(1).values(:,1:numRealidades))';...
    -squeeze(yout.signals(2).values(:,1:numRealidades))';...
    squeeze(yout.signals(3).values(:,1:numRealidades))';...
    -squeeze(yout.signals(4).values(:,1:numRealidades))';...
    squeeze(yout.signals(5).values(:,1:numRealidades))';...
    -squeeze(yout.signals(6).values(:,1:numRealidades))';...
    squeeze(yout.signals(7).values(:,1:numRealidades))';...
    squeeze(yout.signals(8).values(:,1:numRealidades))';...
    -squeeze(yout.signals(25).values(:,1:numRealidades))';...
     squeeze(yout.signals(9).values(:,1:numRealidades))';...
    -squeeze(yout.signals(10).values(:,1:numRealidades))';...
     squeeze(yout.signals(11).values(:,1:numRealidades))';...
    
    % BS Ativos
    squeeze(yout.signals(12).values(:,1:numRealidades))';...
    squeeze(yout.signals(13).values(:,1:numRealidades))';...
    
    % BS Passivos
    squeeze(yout.signals(14).values(:,1:numRealidades))';...
    squeeze(yout.signals(15).values(:,1:numRealidades))';...
    
    % BS Equity
    squeeze(yout.signals(16).values(:,1:numRealidades))';...
    squeeze(yout.signals(17).values(:,1:numRealidades))';...
    squeeze(yout.signals(18).values(:,1:numRealidades))';...
    squeeze(yout.signals(19).values(:,1:numRealidades))';...
    
    % PnLs
    squeeze(yout.signals(20).values(:,1:numRealidades))';...
    squeeze(yout.signals(21).values(:,1:numRealidades))';...
    
    % Dividendos, JSCP e Redução Capital
    squeeze(yout.signals(27).values(:,1:numRealidades))';...
    squeeze(yout.signals(26).values(:,1:numRealidades))';...
    -squeeze(yout.signals(29).values(:,1:numRealidades))';...
    
    % Dívidas
    squeeze(yout.signals(15).values(:,1:numRealidades))';...
    squeeze([zeros(1,numRealidades);JurosCash_Total_Dividas(:,2:numRealidades+1)])';...
    squeeze([zeros(1,numRealidades);CorrecaoCash_Total_Dividas(:,2:numRealidades+1)])';...
    squeeze(yout.signals(28).values(:,1:numRealidades))'...
    
    ];
    
    Matriz_plota = reshape(Matriz_saidas(:,1:mesesSimulacao+1)',size(Matriz_saidas(:,1:mesesSimulacao+1),2),numRealidades,size(Matriz_saidas,1)/numRealidades);
    
    Matriz_Covenants = [ ...
        (vetorDebt_EBITDA)';
        (vetorEBITDA_FinancialResult)';
        (vetorDebt_DebtEquity)';
        ];
    
    Matriz_plota_Covenants = reshape(Matriz_Covenants',size(Matriz_Covenants,2),numRealidades,size(Matriz_Covenants,1)/numRealidades);
    
    Nomes_Colunas_DRE = {...
    % Income Statement
    'Receita Operacional'; ...
    'Deducoes Operacionais'; ...
    'Receita Liquida'; ...
    'Despesas'; ...
    'EBITDA'; ...
    'Depreciacao'; ...
    'EBIT'; ...
    'Resultado Financeiro'; ...
    'JCP'; ...
    'EBT'; ...
    'Imposto de Renda Pago'; ...
    'Lucro Liquido'; ...
    };...
    Nomes_Colunas_BP = {
    % BS Ativos
    'Caixa'; ...
    'PPE'; ...

    % BS Passivos
    'Passivos CurtoPrazo'; ...
    'MtM Total Dividas'; ...
    
    % BS Equity
    'Ajustes'; ...
    'Reserva'; ...
    'Capital Social'; ...
    'Lucro Retido'; ...
    };...
    Nomes_Colunas_PnL = {
    % PnLs
    'PnLCash Total Dividas'; ...
    'PnLnonCash Total Dividas'; ...
    };...
    Nomes_Colunas_Dividendos = {
    % Dividendos e JSCP
    'Dividendos pagos'; ...
    'JCP pagos'; ...
    'Redução de Capital paga'; ...
    };...
    Nomes_Colunas_Dividas = {
    % Dividas
    'Valor de Financiamento';...
    'Pagamento de Juros';...
    'Pagamento de CM';...
    'Pagamento de Principal';...
    };...
    Nomes_Colunas_Cov = {
    % Covenants
    'Debt/EBITDA';...
    'EBITDA/Financial Results';...
    'Debt/(Debt+Share Capital)';...
    };...
    
    
Nomes_Colunas = [Nomes_Colunas_DRE; Nomes_Colunas_BP; Nomes_Colunas_PnL; Nomes_Colunas_Dividendos; Nomes_Colunas_Dividas;Nomes_Colunas_Cov];

Matriz_DRE_anual = zeros(floor(size(Matriz_plota,1)/12),numRealidades,length(Nomes_Colunas_DRE));
Matriz_BP_anual = zeros(floor(size(Matriz_plota,1)/12),numRealidades,length(Nomes_Colunas_BP));

for i=1:floor(size(Matriz_plota,1)/12)
    Matriz_DRE_anual(i,:,:) = sum(Matriz_plota(12*(i-1)+2:12*i+1,:,1:length(Nomes_Colunas_DRE)),1);
    Matriz_BP_anual(i,:,:) = Matriz_plota(12*i+1,:,length(Nomes_Colunas_DRE)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP));
end

formatOut = 'mmm/yy';

string_dataNumerica = datestr(vetor_dataNumericaMenosUm(1:end), formatOut);
string_dataNumericaCovenants = datestr(vetorDatasCovenants, formatOut);

Matriz_plota_Covenants_media = squeeze(mean(Matriz_plota_Covenants,2));

filtroNaN_Covenats = isnan(Matriz_plota_Covenants_media(:,2));
filtro_1000_Covenats = Matriz_plota_Covenants_media(:,2)>1000;
filtro_nDivida_Covenats = Matriz_plota_Covenants_media(:,3)==0;

%% Plota saídas

if strcmp(gera_Graficos, 'Sim')
    
    h_w = waitbar(0,'Gerando gráficos...');
    
    FontSize = 18;
    FontSize_label = 11;
    periodoPlot_Covenats = 1;
    percentis = [0 10 50 90 100];
    cor = 'b';
    destaque = 1;
    visaoGeral = 1;
    
    if mesesSimulacao <= 24 % até 2 anos
        periodoPlot = 1;
    elseif mesesSimulacao > 24 && mesesSimulacao <= 60 % 2 a 5 anos
        periodoPlot = 3;
    elseif mesesSimulacao > 60 && mesesSimulacao <= 120 % 5 a 10 anos
        periodoPlot = 6;
        periodoPlot_Covenats = 2;
    elseif mesesSimulacao > 120 % mais que 10 anos
        periodoPlot = 12;
        periodoPlot_Covenats = 2;
    end
    
    mesTickPeriodicoInicial = (1+floor(month(vetor_dataNumericaMenosUm(1))/periodoPlot-0.001))*periodoPlot - month(vetor_dataNumericaMenosUm(1))+2;
    mesTickPeriodicoInicial_Covenants = (1+floor(month(vetor_dataNumericaMenosUm(1))/periodoPlot_Covenats-0.001))*periodoPlot_Covenats - month(vetor_dataNumericaMenosUm(1))+2;

    for k=1:size(Matriz_plota,3)
        
        h = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
        if numRealidades == 1
            stairs(squeeze(Matriz_plota(:,:,k))/1e6,'Linewidth',1.2);
        else
            Tubo(Matriz_plota(:,:,k)/1e6);
        end
        title(Nomes_Colunas{k},'FontSize',FontSize)
        
        set(gca,'XLim',[0 size(Matriz_plota,1)+1])
        %     set(gca,'XLim',[0 241])
        set(gca,'xtick',[mesTickPeriodicoInicial:periodoPlot:size(Matriz_plota,1)])
        set(gca,'xticklabel',string_dataNumerica([mesTickPeriodicoInicial:periodoPlot:end],:),'FontSize',FontSize_label);
        rotateXLabels(gca,90);
        ylabel ('Milhões de Reais','FontSize',FontSize);
        grid on
        
        saveas(h,[Pasta_Graficos '\' Nomes_Colunas{k}],'png');
        
        waitbar(k/(size(Matriz_plota,3)+size(Matriz_plota_Covenants,3)))
    end
    
    Nomes_Covenants = {...
        'Debt DIV EBITDA';...
        'EBITDA DIV Financial Results';...
        'Debt DIV Debt MAIS Share Capital';...
        };
    
    for k=1:size(Matriz_plota_Covenants,3)
        
        h = figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
        if numRealidades == 1
            stairs(squeeze(Matriz_plota_Covenants(~filtroNaN_Covenats,:,k)),'Linewidth',1.2);
        else
            Tubo(Matriz_plota_Covenants(~filtroNaN_Covenats,:,k));
        end
        title(Nomes_Colunas{k+size(Matriz_plota,3)},'FontSize',FontSize)
        
        set(gca,'XLim',[0 size(Matriz_plota_Covenants,1)+1])
        %     set(gca,'XLim',[0 241])
        set(gca,'xtick',1:periodoPlot_Covenats:size(Matriz_plota_Covenants,1))
        set(gca,'xticklabel',string_dataNumericaCovenants(1:periodoPlot_Covenats:end,:),'FontSize',FontSize_label);
        rotateXLabels(gca,90);
        grid on
        
        saveas(h,[Pasta_Graficos '\' Nomes_Covenants{k}],'png');
        
        waitbar((k+(size(Matriz_plota,3)))/(size(Matriz_plota,3)+size(Matriz_plota_Covenants,3)))
    end
    
    close(h_w)
    close all
    
end

%% Gera planilha

if fatorSaida == 1e6
    fatorSaida_texto = '_EM_MILHOES';
else if fatorSaida == 1e3
        fatorSaida_texto = '_EM_MILHARES';
    else
        fatorSaida_texto = '';
    end
end

Matriz_planilha_Covenants = num2cell(Matriz_plota_Covenants_media);

Matriz_planilha_Covenants(filtroNaN_Covenats,1:2) = {'Não há EBITDA'};
Matriz_planilha_Covenants(filtro_1000_Covenats,2) = {'EBITDA >> FinancialResult'};
Matriz_planilha_Covenants(filtro_nDivida_Covenats,[1 3]) = {'Não há dívida'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TEMPO NAS LINHAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,1:12),2))'/fatorSaida]','IncomeStatement',['A2:M' num2str(size(Matriz_plota,1)+1)])
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], ['Datas' Nomes_Colunas(1:12,1)'],'IncomeStatement','A1:M1')
% 
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,13:20),2))'/fatorSaida]','BalanceSheet',['A2:I' num2str(size(Matriz_plota,1)+1)])
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], ['Datas' Nomes_Colunas(13:20,:)'],'BalanceSheet','A1:I1')
% 
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,21:22),2))'/fatorSaida]','PnLs',['A2:C' num2str(size(Matriz_plota,1)+1)])
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], ['Datas' Nomes_Colunas(21:22,:)'],'PnLs','A1:C1')
% 
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,23:24),2))'/fatorSaida]','Dividendos',['A2:C' num2str(size(Matriz_plota,1)+1)])
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], ['Datas' Nomes_Colunas(23:24,:)'],'Dividendos','A1:C1')
% 
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetorDatasCovenants+conv_data_mat2xls]','Covenants',['A2:A' num2str(size(vetorDatasCovenants,2)+1)]);
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],Matriz_planilha_Covenants,'Covenants',['B2:D' num2str(size(Matriz_Covenants,2)+1)]);
% xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], ['Datas' Nomes_Colunas(25:end,:)'],'Covenants','A1:D1')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(Matriz_plota,1) > 25
    colunas = ['B1:' char(floor((size(Matriz_plota,1))/26)-1+'A') char(rem((size(Matriz_plota,1)),26)+'A')];
else
    colunas = ['B1:' char((size(Matriz_plota,1))+'A')];
end

if size(Matriz_planilha_Covenants,1) > 25
    colunas_covenants = [char(floor((size(vetorDatasCovenants,2))/26)-1+'A') char(rem((size(vetorDatasCovenants,2)),26)+'A')];
else
    colunas_covenants = char((size(vetorDatasCovenants,2))+'A');
end

colunas_anual = ['B1:' char((length(vetor_dataAnual))+'A')];

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,1:length(Nomes_Colunas_DRE)),2))'/fatorSaida],'IncomeStatement (Reais)',[colunas num2str(size(Nomes_Colunas_DRE,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_DRE']','IncomeStatement (Reais)',['A1:A' num2str(size(Nomes_Colunas_DRE,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)),2))'/fatorSaida],'BalanceSheet (Reais)',[colunas num2str(size(Nomes_Colunas_BP,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_BP']','BalanceSheet (Reais)',['A1:A' num2str(size(Nomes_Colunas_BP,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)),2))'/fatorSaida],'PnLs (Reais)',[colunas num2str(size(Nomes_Colunas_PnL,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_PnL']','PnLs (Reais)',['A1:A' num2str(size(Nomes_Colunas_PnL,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+length(Nomes_Colunas_Dividendos)),2))'/fatorSaida],'Dividendos (Reais)',[colunas num2str(size(Nomes_Colunas_Dividendos,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_Dividendos']','Dividendos (Reais)',['A1:A' num2str(size(Nomes_Colunas_Dividendos,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+length(Nomes_Colunas_Dividendos)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+length(Nomes_Colunas_Dividendos)+length(Nomes_Colunas_Dividas)),2))'/fatorSaida],'Dívidas (Reais)',[colunas num2str(size(Nomes_Colunas_Dividas,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_Dividas']','Dívidas (Reais)',['A1:A' num2str(size(Nomes_Colunas_Dividas,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],vetorDatasCovenants+conv_data_mat2xls,'Covenants',['B1:' colunas_covenants num2str(1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],Matriz_planilha_Covenants','Covenants',['B2:' colunas_covenants num2str(size(Nomes_Colunas_Cov,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_Cov']','Covenants',['A1:A' num2str(size(Nomes_Colunas_Cov,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataAnual; squeeze(mean(Matriz_DRE_anual,2))'/fatorSaida],'IncomeStatement Ano (Reais)',[colunas_anual num2str(size(Nomes_Colunas_DRE,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_DRE']','IncomeStatement Ano (Reais)',['A1:A' num2str(size(Nomes_Colunas_DRE,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataAnual; squeeze(mean(Matriz_BP_anual,2))'/fatorSaida],'BalanceSheet Ano (Reais)',[colunas_anual num2str(size(Nomes_Colunas_BP,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_BP']','BalanceSheet Ano (Reais)',['A1:A' num2str(size(Nomes_Colunas_BP,1)+1)])


% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%% Em Dolares %%%

DRE_dolares = bsxfun(@times,squeeze(mean(Matriz_plota(:,:,1:length(Nomes_Colunas_DRE)),2))',dolar_limitado);
BP_dolares = bsxfun(@times,squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)),2))',dolar_limitado);
DRE_dolares_anual = zeros(floor(size(Matriz_plota,1)/12),length(Nomes_Colunas_DRE));
BP_dolares_anual = zeros(floor(size(Matriz_plota,1)/12),length(Nomes_Colunas_BP));

for i=1:floor(size(Matriz_plota,1)/12)
    DRE_dolares_anual(i,:) = sum(DRE_dolares(:,12*(i-1)+2:12*i+1),2);
    BP_dolares_anual(i,:) = BP_dolares(:,12*i+1);
end

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; DRE_dolares/fatorSaida],'IncomeStatement (Dólares)',[colunas num2str(size(Nomes_Colunas_DRE,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_DRE']','IncomeStatement (Dólares)',['A1:A' num2str(size(Nomes_Colunas_DRE,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; BP_dolares/fatorSaida],'BalanceSheet (Dólares)',[colunas num2str(size(Nomes_Colunas_BP,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_BP']','BalanceSheet (Dólares)',['A1:A' num2str(size(Nomes_Colunas_BP,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; bsxfun(@times,squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)),2))',dolar_limitado)/fatorSaida],'PnLs (Dólares)',[colunas num2str(size(Nomes_Colunas_PnL,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_PnL']','PnLs (Dólares)',['A1:A' num2str(size(Nomes_Colunas_PnL,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; bsxfun(@times,squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+length(Nomes_Colunas_Dividendos)),2))',dolar_limitado)/fatorSaida],'Dividendos (Dólares)',[colunas num2str(size(Nomes_Colunas_Dividendos,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_Dividendos']','Dividendos (Dólares)',['A1:A' num2str(size(Nomes_Colunas_Dividendos,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataNumericaMenosUm(:,1:mesesSimulacao+1)+conv_data_mat2xls; bsxfun(@times,squeeze(mean(Matriz_plota(:,:,length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+length(Nomes_Colunas_Dividendos)+1:length(Nomes_Colunas_DRE)+length(Nomes_Colunas_BP)+length(Nomes_Colunas_PnL)+length(Nomes_Colunas_Dividendos)+length(Nomes_Colunas_Dividas)),2))',dolar_limitado)/fatorSaida],'Dívidas (Dólares)',[colunas num2str(size(Nomes_Colunas_Dividas,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_Dividas']','Dívidas (Dólares)',['A1:A' num2str(size(Nomes_Colunas_Dividas,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataAnual; DRE_dolares_anual'/fatorSaida],'IncomeStatement Ano (Dólares)',[colunas_anual num2str(size(Nomes_Colunas_DRE,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_DRE']','IncomeStatement Ano (Dólares)',['A1:A' num2str(size(Nomes_Colunas_DRE,1)+1)])

xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto],[vetor_dataAnual; BP_dolares_anual'/fatorSaida],'BalanceSheet Ano (Dólares)',[colunas_anual num2str(size(Nomes_Colunas_BP,1)+1)])
xlswrite([Pasta_Resultados '\Saida_Financeira_' nomeCenario{1,1} fatorSaida_texto], [' ' Nomes_Colunas_BP']','BalanceSheet Ano (Dólares)',['A1:A' num2str(size(Nomes_Colunas_BP,1)+1)])


msgbox('Resultados salvos com sucesso.')

    