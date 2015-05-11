%% Variáveis primordiais
clear

tic
tempoSimulacao=180;
realidadesPorSimulacao = 1; %%% MUDAR PARA 500!!!!!! -> 1.5GB
% numRealidades = realidadesPorSimulacao;
w = waitbar(0,'Simulando...');

%% Seleciona planilhas e inputs

% Nome do cenário
% nomeCenario = inputdlg('Forneça um nome ao cenário a ser simulado (apenas letras, números e "_")','Nome do cenário');
nomeCenario = {'cenario_teste2_13a'};

% Planilha de entrada
% [source_filepath , source_filename] = uigetfile({'*.xlsm;*.xlsx;*.xls' , 'EXCEL (*xlsm,*.xlsx,*.xls)'}, 'Abrir Planilha de Parametros');
source_filename = pwd;
source_filepath = '\Parametros_entrada_v3.xlsx';

% Contratos
% Pasta_Contratos = uigetdir(pwd,'Selecionar pasta de contratos');
Pasta_Contratos = [pwd '\Contratos_0'];

% Debêntures
% Pasta_Debentures = uigetdir(pwd,'Selecionar pasta de dívidas');
Pasta_Debentures = [pwd '\Debentures_0_1_2'];

% Resultados
% Pasta_Resultados = uigetdir(pwd,'Selecionar pasta para o registro dos resultados');
Pasta_Resultados = [pwd '\Arquivos_resultados'];

% Graficos
% gera_Graficos = questdlg('Deseja que sejam gerados gráficos com os resultados deste cenário?', ...
%     'Resultados de cenário individual', ...
%     'Sim', ...
%     'Não', ...
%     'Sim');
gera_Graficos = 'Não';
if strcmp(gera_Graficos, 'Sim')
%     Pasta_Graficos = uigetdir(pwd,'Selecionar pasta para os gráficos deste cenário');
    Pasta_Graficos = [pwd '\Gráficos_unicos'];
end

%% Le parametros

% gera as variaveis, linha por linha
read_parametros_v2
% numRealidades_total = 1;
% realidadesPorSimulacao = 200;

numSimulacoes = ceil((numRealidades_total)/realidadesPorSimulacao);

%%
% if numSimulacoes ~= 1
%     w = waitbar(0,'Simulando...');
% end

for simulacao = 1:numSimulacoes
    
    if simulacao == numSimulacoes
        if mod(numRealidades_total,realidadesPorSimulacao) == 0
            numRealidades = realidadesPorSimulacao;
        else
            numRealidades = mod(numRealidades_total,realidadesPorSimulacao);
        end
    else
        numRealidades = realidadesPorSimulacao;
    end
    
    %% Le curvas
    
    %gera vetores de curvas
    read_curvas_v2
    
    if simulacao == 1
        % gera vetor_dataNumerica e vetor_diasMes
        dataFinal = addtodate(DataInicial, mesesSimulacao-1, 'month');
        contador = 1;
        dataNumerica = DataInicial;
        vetor_diasMes =[];
        vetor_dataNumerica = DataInicial;
        while dataNumerica <= dataFinal
            datasSimulacao(contador, 1) = dataNumerica;
            dataNumerica = addtodate(dataNumerica, 1, 'month');
            vetor_diasMes = [vetor_diasMes dataNumerica - vetor_dataNumerica(end)];
            vetor_dataNumerica = [vetor_dataNumerica dataNumerica];
            contador = contador + 1;
        end
    end % if simulacao
    
    %% Le contratos
    
    read_contratos_v3
    
    [~, energiaContratada_Total, ~, receitaContratada_Total, ~, PIS_COFINS_ICMS_Contratos_Total] = calculaContratos(tempoSimulacao, Contratos, DataInicial);
    
    %% Le debentures
    
    read_debentures
    
    [~,MtM_Total_Dividas,~,~,PnLnonCash_Total_Dividas,JurosCash_Total_Dividas,...
        CorrecaoCash_Total_Dividas,PnLCash_Total_Dividas,~,Amortizacao_Total_Dividas,~,NominalInicial_Total_Dividas,...
        valorCustoEmisao_total, valorCustoEmisao_distribuido_total, valorCustoCETIP_total, valorCustoMensal_total, valorCustoSemestral_total, valorCustoAnual_total,...
        PremioPrePagamento_total,PremioReducaoCapital_total,valorPremioReducaoCapital_distribuido_total,~] = calculaDebentures_v2(tempoSimulacao, Debentures, DataInicial);
    
    %% Prepara entradas
    
    % Variáveis para o Caixa Inicial
    mes_DataInicial = month(DataInicial);
    DividaInicial = MtM_Total_Dividas(1,2:end);
    Capital_Social_Inicial = CapitalSocial(1,2:end);

    % Variáveis para o Dividendos e JSCP
    periodoDividendos_delay = periodoDividendos;
    inicializa_JSCP = zeros(realidadesPorSimulacao,mes_JSCP);
    JSCP_RetidoInicial = 0; % Input?
    PeriodoJSCP = 12;
    PeriodoIR_diferido = 12;
      
    % gera o Input.mat para o modelo
    gera_Input_modelo
    
    %% Roda modelo
    
    if exist('w','var')
        waitbar(simulacao/numSimulacoes)
    end
    
    %simula
    sim('Duke_Simulink_13a');
    
%     !Duke_Simulink_13a -i Input.mat -p param_struct.mat -o Output.mat
%     load('Output.mat');
    
    if simulacao ~= 1
        for i=[1:5 7:12 14 15 17 19:length(yout.signals)]
            yout.signals(1,i).values = [yout_ant.signals(1,i).values yout.signals(1,i).values];
        end
    end
    yout_ant = yout;
    
end

if exist('w','var')
    close(w)
end

%% Gera gráficos e planilha
pause(1)

numRealidades = numRealidades_total;

% Limpa memória
% clearvars -except Pasta_Saida vetor_dataNumerica yout numRealidades mesesSimulacao fatorSaida gera_Graficos_Excel Pasta_mat nomeCenario

if ~exist(Pasta_Resultados,'dir')
    mkdir(Pasta_Resultados);
end
save([Pasta_Resultados '\' nomeCenario{1,1}],'vetor_dataNumerica', 'yout', 'numRealidades', 'mesesSimulacao', 'fatorSaida');

gera_Saidas
toc