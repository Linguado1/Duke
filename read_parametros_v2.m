
source_filename = [source_filename source_filepath];

[~,~,Parametros_Entrada_raw] = xlsread(source_filename,'Parametros','B:B');


%% Verifica entradas

try
    DataInicial = datenum(Parametros_Entrada_raw(1),'dd/mm/yyyy');
catch e
    msgbox('Erro: Formato de data desconhecido.')
    break
end

if isnan(DataInicial)
    msgbox('Erro: Data Inicial não preenchida.')
    break
end

if day(DataInicial)~=1
    choice = questdlg(['A data inicial deve ser dia 1º. Deseja que o modelo utilize a data "01/' num2str(month(DataInicial), '%.2d') '/' num2str(year(DataInicial), '%.4d') '"?'], ...
        'Correção da data inicial', ...
        'Sim', ...
        'Não', ...
        'Sim');
    switch choice
        case 'Sim'
            DataInicial = datenum(['01/' num2str(month(DataInicial), '%.2d') '/' num2str(year(DataInicial), '%.4d')],'dd/mm/yyyy');
        case 'Não'
            msgbox('Erro: Data inicial não permitida.');
            break
    end
end

try
    numerosConstantes = cell2mat(Parametros_Entrada_raw(2:end));
catch
    msgbox('Erro: Planilha preenchida incorretamente.')
    break
end

dadosNumeroConstantes=numerosConstantes(~isnan(numerosConstantes));

if length(dadosNumeroConstantes)<61  
    msgbox('Erro: Planilha incompleta.')
    break
end

%% Gera variaveis

linha = 1;

mesesSimulacao = dadosNumeroConstantes(linha);
linha = linha + 1;
numRealidades_total = dadosNumeroConstantes(linha); %%%%%% numRealidades 
linha = linha + 1;
garantiaFisica = dadosNumeroConstantes(linha);
linha = linha + 1;
potenciaInstala = dadosNumeroConstantes(linha);
linha = linha + 1;
TEO = dadosNumeroConstantes(linha);
linha = linha + 1;
contribuicaoCCEE = dadosNumeroConstantes(linha);
linha = linha + 1;
TAR = dadosNumeroConstantes(linha);
linha = linha + 1;
CFURH = dadosNumeroConstantes(linha)*TAR;
linha = linha + 1;
BeneficioAnual = dadosNumeroConstantes(linha);
linha = linha + 1;
TFSEE = dadosNumeroConstantes(linha)*BeneficioAnual*potenciaInstala;
linha = linha + 1;
TEIFa = dadosNumeroConstantes(linha);
linha = linha + 1;
TEIP = dadosNumeroConstantes(linha);
linha = linha + 1;
TEIFref = dadosNumeroConstantes(linha);
linha = linha + 1;
TEIPref = dadosNumeroConstantes(linha);
linha = linha + 1;

refInd=(1-TEIFref)*(1-TEIPref);

% PIS e COFINS sobre compras Spot e MRE
PIS_cum = dadosNumeroConstantes(linha);
linha = linha + 1;
COFINS_cum = dadosNumeroConstantes(linha);
linha = linha + 1;
PIS_COFINS_Cumulativo = PIS_cum + COFINS_cum;

% PIS e COFINS sobre Receita de cContratos
PIS_Naocum = dadosNumeroConstantes(linha);
linha = linha + 1;
COFINS_Naocum = dadosNumeroConstantes(linha);
linha = linha + 1;
PIS_COFINS_Nao_Cumulativo = PIS_Naocum + COFINS_Naocum;

deducaoP_D = dadosNumeroConstantes(linha);% 1% da Receita LÃ­quida
linha = linha + 1;

reajusteSalario = dadosNumeroConstantes(linha);
linha = linha + 1;

taxaMinorityInterest = dadosNumeroConstantes(linha);
linha = linha + 1;

PeriodoPremio = dadosNumeroConstantes(linha);
linha = linha + 1;

%Dez/2013
PPE_Inicial_Terreno = dadosNumeroConstantes(linha);
linha = linha + 1;
PPE_Inicial_Reservatorio = dadosNumeroConstantes(linha);
linha = linha + 1;
PPE_Inicial_Edificacoes = dadosNumeroConstantes(linha);
linha = linha + 1;
PPE_Inicial_Maquinas = dadosNumeroConstantes(linha);
linha = linha + 1;
PPE_Inicial_Veiculos = dadosNumeroConstantes(linha);
linha = linha + 1;
PPE_Inicial_Moveis = dadosNumeroConstantes(linha);
linha = linha + 1;

PPE_Inicial_Total = sum([PPE_Inicial_Moveis PPE_Inicial_Veiculos PPE_Inicial_Maquinas PPE_Inicial_Edificacoes PPE_Inicial_Reservatorio PPE_Inicial_Terreno]);

PPE_Periodo_Reservatorio = round(12/dadosNumeroConstantes(linha));
linha = linha + 1;
PPE_Periodo_Edificacoes = round(12/dadosNumeroConstantes(linha));
linha = linha + 1;
PPE_Periodo_Maquinas = round(12/dadosNumeroConstantes(linha));
linha = linha + 1;
PPE_Periodo_Veiculos = round(12/dadosNumeroConstantes(linha));
linha = linha + 1;
PPE_Periodo_Moveis = round(12/dadosNumeroConstantes(linha));
linha = linha + 1;

Outros_Passivos = dadosNumeroConstantes(linha);
linha = linha + 1;

Reserva_Capital_Inicial = dadosNumeroConstantes(linha);
linha = linha + 1;
Reserva_Lucros_Inicial= dadosNumeroConstantes(linha);% DEZ/2012
linha = linha + 1;
Ajustes_Inicial= dadosNumeroConstantes(linha);% DEZ/2012
linha = linha + 1;

Limite_Reserva_Lucros= dadosNumeroConstantes(linha);
linha = linha + 1;
Limite_Reserva_Lucros_Capital= dadosNumeroConstantes(linha);
linha = linha + 1;

PeriodoDepreciacao_Ajustes =  dadosNumeroConstantes(linha);
linha = linha + 1;

Taxa_Anual_Reserva= dadosNumeroConstantes(linha);
linha = linha + 1;

aliquotaIR= dadosNumeroConstantes(linha);
linha = linha + 1;
Taxa_diferimento= dadosNumeroConstantes(linha);
linha = linha + 1;
IR_diferido_acumulado_inicial= dadosNumeroConstantes(linha);
linha = linha + 1;

periodoDividendos = dadosNumeroConstantes(linha);
linha = linha + 1;
CaixaInicial = dadosNumeroConstantes(linha);
linha = linha + 1;
LucroRetidoInicial = dadosNumeroConstantes(linha);
linha = linha + 1;
LucroParcialPeriodo = dadosNumeroConstantes(linha);
linha = linha + 1;
Dividendos_A_Pagar_Inicial = dadosNumeroConstantes(linha);
linha = linha + 1;
JSCP_ParcialPeriodo = dadosNumeroConstantes(linha);
linha = linha + 1;
JSCP_A_Pagar_Inicial = dadosNumeroConstantes(linha);
linha = linha + 1;
mes_JSCP = dadosNumeroConstantes(linha);
linha = linha + 1;

% Distribuição de rendimentos do Caixa
verificaDistribuicao = dadosNumeroConstantes(linha);
linha = linha + 1;
Caixa_em_TJLP = dadosNumeroConstantes(linha);
linha = linha + 1;
Caixa_em_IPCA = dadosNumeroConstantes(linha);
linha = linha + 1;
Caixa_em_IGPM = dadosNumeroConstantes(linha);
linha = linha + 1;
Caixa_em_CDI = dadosNumeroConstantes(linha);
linha = linha + 1;
Caixa_em_Outro = dadosNumeroConstantes(linha);
linha = linha + 1;

% Fatores multiplicativos
fatores_TJLP=(1+ dadosNumeroConstantes(linha)); 
linha = linha + 1;
fatores_IPCA=(1+ dadosNumeroConstantes(linha)); 
linha = linha + 1;
fatores_IGPM=(1+ dadosNumeroConstantes(linha)); 
linha = linha + 1;
fatores_CDI=(1+ dadosNumeroConstantes(linha)); 
linha = linha + 1;
fatores_Outro=(1+ dadosNumeroConstantes(linha)); 
linha = linha + 1;

% Desvio padrão
desvioPadrao_TJLP = dadosNumeroConstantes(linha);
linha = linha + 1;
desvioPadrao_IPCA = dadosNumeroConstantes(linha);
linha = linha + 1;
desvioPadrao_IGPM = dadosNumeroConstantes(linha);
linha = linha + 1;
desvioPadrao_CDI = dadosNumeroConstantes(linha);
linha = linha + 1;
desvioPadrao_Outro_Indice = dadosNumeroConstantes(linha);
linha = linha + 1;

fatorSaida = dadosNumeroConstantes(linha); 


%% Verifica consistência das variáveis

if (month(DataInicial)==1 || month(DataInicial)==7)
    if LucroParcialPeriodo ~= 0
        msgbox('Erro: O lucro parcial do período deve ser nulo para simulações a partir do início do semestre. Lucros acumulados de semestres anteriores devem ser inseridos em "Lucro acumulado inicial".')
        break
    elseif JSCP_ParcialPeriodo ~= 0
        msgbox('Erro: O JSCP parcial do período deve ser nulo para simulações a partir do início do semestre.')
        break
    end
end

if verificaDistribuicao ~= 1
    msgbox('Erro: Distribuição de rendimentos do Caixa inconsistente.')
    break
end


