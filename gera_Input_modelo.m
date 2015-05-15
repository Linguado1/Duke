%% Prepara entradas do Caixa

% CaixaInicial = Outros_Passivos + DividaInicial + Capital_Social_Inicial + Reserva_Lucros_Inicial + Reserva_Capital_Inicial + Ajustes_Inicial + LucroParcialPeriodo + LucroRetidoInicial + JSCP_ParcialPeriodo - PPE_Inicial_Total;    

% Rendimento do Caixa
juros_Caixa = [(1:mesesSimulacao)' Caixa_em_TJLP*sim_TJLP(:,2:end) + Caixa_em_IPCA*sim_IPCA(:,2:end) + Caixa_em_IGPM*sim_IGPM(:,2:end) + Caixa_em_CDI*sim_CDI(:,2:end) + Caixa_em_Outro*sim_Outro(:,2:end)];

if sum(CaixaInicial<0)>0 && simulacao == 1
    choice = questdlg('Aviso: O caixa inicial está negativo. Deseja continuar?','Caixa inicial negativo','Sim','Não','Sim');
    
    if strcmp(choice, 'Não')
        msgbox('Simulação abortada.');
        break
    end
end

%%
Input.time = (0:tempoSimulacao)';

Input.signals(01).values = [0;24*vetor_diasMes';zeros(tempoSimulacao-size(vetor_diasMes,2),1)];
Input.signals(01).dimensions = 1;

Input.signals(11).values = [zeros(1,realidadesPorSimulacao);PLD(:,2:end);zeros(tempoSimulacao-size(PLD,1),realidadesPorSimulacao)];
Input.signals(11).dimensions = realidadesPorSimulacao;

Input.signals(12).values = [zeros(1,realidadesPorSimulacao);GSF(:,2:end);zeros(tempoSimulacao-size(GSF,1),realidadesPorSimulacao)];
Input.signals(12).dimensions = realidadesPorSimulacao;

Input.signals(02).values = [0 ; GF_sazonalizada(:,2);zeros(tempoSimulacao-size(GF_sazonalizada,1),1)];
Input.signals(02).dimensions = 1;

Input.signals(21).values = [zeros(1,realidadesPorSimulacao);sim_TJLP(:,2:end);zeros(tempoSimulacao-size(sim_TJLP,1),realidadesPorSimulacao)];
Input.signals(21).dimensions = realidadesPorSimulacao;

Input.signals(09).values = cumprod(1+[zeros(1,realidadesPorSimulacao);sim_IPCA(:,2:end);zeros(tempoSimulacao-size(sim_IPCA,1),realidadesPorSimulacao)],1);
Input.signals(09).dimensions = realidadesPorSimulacao;

Input.signals(10).values = cumprod(1+[zeros(1,realidadesPorSimulacao);sim_IGPM(:,2:end);zeros(tempoSimulacao-size(sim_IGPM,1),realidadesPorSimulacao)],1);
Input.signals(10).dimensions = realidadesPorSimulacao;

Input.signals(25).values = cumprod(1+[zeros(1,realidadesPorSimulacao);sim_CDI(:,2:end);zeros(tempoSimulacao-size(sim_CDI,1),realidadesPorSimulacao)],1);
Input.signals(25).dimensions = realidadesPorSimulacao;

Input.signals(28).values = [zeros(1,realidadesPorSimulacao);juros_Caixa(:,2:end);zeros(tempoSimulacao-size(juros_Caixa,1),realidadesPorSimulacao)];
Input.signals(28).dimensions = realidadesPorSimulacao;

% Apagar
Input.signals(13).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(13).dimensions = 1;

% Apagar
Input.signals(14).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(14).dimensions = 1;

% Apagar
Input.signals(22).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(22).dimensions = 1;

Input.signals(23).values = [0;CurvaReajuste(:,2:end);zeros(tempoSimulacao-size(CurvaReajuste,1),1)];
Input.signals(23).dimensions = 1;

% Apagar
Input.signals(26).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(26).dimensions = 1;

% Apagar
Input.signals(18).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(18).dimensions = 1;

% Apagar
Input.signals(15).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(15).dimensions = 1;

% Apagar
Input.signals(16).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(16).dimensions = 1;

% Apagar
Input.signals(19).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(19).dimensions = 1;

% Apagar
Input.signals(17).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(17).dimensions = 1;

Input.signals(27).values = [CapitalSocial(:,2:end);zeros(tempoSimulacao-(size(CapitalSocial,1)-1),1)]; % Capital Social tem tamanho maior para acolher o Capital Social Inicial
Input.signals(27).dimensions = 1;

% Apagar
Input.signals(20).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(20).dimensions = 1;

Input.signals(24).values = [taxa_paga_dividendos(1,2:end); taxa_paga_dividendos(:,2:end);zeros(tempoSimulacao-size(taxa_paga_dividendos,1),1)];
Input.signals(24).dimensions = 1;

Input.signals(03).values = [0;energiaContratada_Total(:,2:end)]; %%%%% 2:end?
Input.signals(03).dimensions = 1;

Input.signals(04).values = [zeros(1,realidadesPorSimulacao);receitaContratada_Total(:,2:end)]; %%%%% 2:end?
Input.signals(04).dimensions = realidadesPorSimulacao;

Input.signals(05).values = [zeros(1,realidadesPorSimulacao);PIS_COFINS_ICMS_Contratos_Total(:,2:end)]; %%%%% 2:end?
Input.signals(05).dimensions = realidadesPorSimulacao;

Input.signals(06).values = MtM_Total_Dividas(:,2:end);
Input.signals(06).dimensions = realidadesPorSimulacao;

Input.signals(07).values = [zeros(1,realidadesPorSimulacao);PnLCash_Total_Dividas(:,2:end)];
Input.signals(07).dimensions = realidadesPorSimulacao;

Input.signals(08).values = [zeros(1,realidadesPorSimulacao);PnLnonCash_Total_Dividas(:,2:end)];
Input.signals(08).dimensions = realidadesPorSimulacao;

Input.signals(29).values = PremioPrePagamento_total(:,2:end);
Input.signals(29).dimensions = realidadesPorSimulacao;

Input.signals(30).values = PremioReducaoCapital_total(:,2:end);
Input.signals(30).dimensions = realidadesPorSimulacao;

Input.signals(31).values = [zeros(1,realidadesPorSimulacao);Amortizacao_Total_Dividas(:,2:end)];
Input.signals(31).dimensions = realidadesPorSimulacao;

Input.signals(52).values = [zeros(1,realidadesPorSimulacao);JurosCash_Total_Dividas(:,2:end)];
Input.signals(52).dimensions = realidadesPorSimulacao;

Input.signals(53).values = [zeros(1,realidadesPorSimulacao);CorrecaoCash_Total_Dividas(:,2:end)];
Input.signals(53).dimensions = realidadesPorSimulacao;

Input.signals(54).values = [0;NominalInicial_Total_Dividas(:,2:end)];
Input.signals(54).dimensions = 1;


Input.signals(32).values = [0;compraMRE(:,2:end);zeros(tempoSimulacao-size(compraMRE,1),1)];
Input.signals(32).dimensions = 1;

Input.signals(33).values = [0;vendaMRE(:,2:end);zeros(tempoSimulacao-size(vendaMRE,1),1)];
Input.signals(33).dimensions = 1;

Input.signals(55).values = [0;otherOperatingRevenues(:,2:end);zeros(tempoSimulacao-size(otherOperatingRevenues,1),1)];
Input.signals(55).dimensions = 1;

Input.signals(34).values = [0;regulatoryFees(:,2:end);zeros(tempoSimulacao-size(regulatoryFees,1),1)];
Input.signals(34).dimensions = 1;

Input.signals(43).values = [0;OeM_expenses(:,2:end);zeros(tempoSimulacao-size(OeM_expenses,1),1)];
Input.signals(43).dimensions = 1;

Input.signals(44).values = [0;OeM_labor(:,2:end);zeros(tempoSimulacao-size(OeM_labor,1),1)];
Input.signals(44).dimensions = 1;

Input.signals(45).values = [0;AeG_expenses(:,2:end);zeros(tempoSimulacao-size(AeG_expenses,1),1)];
Input.signals(45).dimensions = 1;

Input.signals(46).values = [0;AeG_labor(:,2:end);zeros(tempoSimulacao-size(AeG_labor,1),1)];
Input.signals(46).dimensions = 1;

Input.signals(35).values = [0;propertyAndOtherTaxes(:,2:end);zeros(tempoSimulacao-size(propertyAndOtherTaxes,1),1)];
Input.signals(35).dimensions = 1;

Input.signals(36).values = [0;operatingIncome(:,2:end);zeros(tempoSimulacao-size(operatingIncome,1),1)];
Input.signals(36).dimensions = 1;

Input.signals(37).values = [0;otherIncome(:,2:end);zeros(tempoSimulacao-size(otherIncome,1),1)];
Input.signals(37).dimensions = 1;

Input.signals(38).values = [0;depreciacao(:,2:end);zeros(tempoSimulacao-size(depreciacao,1),1)];
Input.signals(38).dimensions = 1;

Input.signals(51).values = [0;otherInterestExpenses(:,2:end);zeros(tempoSimulacao-size(otherInterestExpenses,1),1)];
Input.signals(51).dimensions = 1;

Input.signals(39).values = [0;deferredIncomeTaxes(:,2:end);zeros(tempoSimulacao-size(deferredIncomeTaxes,1),1)];
Input.signals(39).dimensions = 1;

Input.signals(47).values = [0;variacaoAtivosCirculantes(:,2:end);zeros(tempoSimulacao-size(variacaoAtivosCirculantes,1),1)];
Input.signals(47).dimensions = 1;

Input.signals(48).values = [0;variacaoPassivosCirculantes(:,2:end);zeros(tempoSimulacao-size(variacaoPassivosCirculantes,1),1)];
Input.signals(48).dimensions = 1;

Input.signals(49).values = [0;Contingencia(:,2:end);zeros(tempoSimulacao-size(Contingencia,1),1)];
Input.signals(49).dimensions = 1;

Input.signals(40).values = [0;returnOfCapitals_dividendsFromInvestments(:,2:end);zeros(tempoSimulacao-size(returnOfCapitals_dividendsFromInvestments,1),1)];
Input.signals(40).dimensions = 1;

Input.signals(50).values = [0;cashFlowsFromInvestinglActivities(:,2:end);zeros(tempoSimulacao-size(cashFlowsFromInvestinglActivities,1),1)];
Input.signals(50).dimensions = 1;

Input.signals(41).values = [0;cashFlowsFromFinancialActivities_Outros(:,2:end);zeros(tempoSimulacao-size(cashFlowsFromFinancialActivities_Outros,1),1)];
Input.signals(41).dimensions = 1;

Input.signals(42).values = [0;otherShareholdersEquity(:,2:end);zeros(tempoSimulacao-size(otherShareholdersEquity,1),1)];
Input.signals(42).dimensions = 1;


save('Input.mat', ...
'Input');

load('Input.mat');

%% Prepara vetores de PPE

num_PPE_Reservatorio = [0 ones(1,PPE_Periodo_Reservatorio)]*(1/PPE_Periodo_Reservatorio);
den_PPE_Reservatorio = [1 zeros(1,PPE_Periodo_Reservatorio)];
num_PPE_Edificacoes = [0 ones(1,PPE_Periodo_Edificacoes)]*(1/PPE_Periodo_Edificacoes);
den_PPE_Edificacoes = [1 zeros(1,PPE_Periodo_Edificacoes)];
num_PPE_Maquinas = [0 ones(1,PPE_Periodo_Maquinas)]*(1/PPE_Periodo_Maquinas);
den_PPE_Maquinas = [1 zeros(1,PPE_Periodo_Maquinas)];
num_PPE_Veiculos = [0 ones(1,PPE_Periodo_Veiculos)]*(1/PPE_Periodo_Veiculos);
den_PPE_Veiculos = [1 zeros(1,PPE_Periodo_Veiculos)];
num_PPE_Moveis = [0 ones(1,PPE_Periodo_Moveis)]*(1/PPE_Periodo_Moveis);
den_PPE_Moveis = [1 zeros(1,PPE_Periodo_Moveis)];
num_Ajustes = [0 ones(1,PeriodoDepreciacao_Ajustes)]*(1/PeriodoDepreciacao_Ajustes);
den_Ajustes = [1 zeros(1,PeriodoDepreciacao_Ajustes)];

%% Distribuição dos custos das debêntures no Resultado Financeiro
PeriodoCustoSemestral = 6;
PeriodoCustoAnual = 12;

num_CustoSemestral = ones(1,PeriodoCustoSemestral)*(1/PeriodoCustoSemestral);
den_CustoSemestral = [1 zeros(1,PeriodoCustoSemestral-1)];
num_CustoAnual = ones(1,PeriodoCustoAnual)*(1/PeriodoCustoAnual);
den_CustoAnual = [1 zeros(1,PeriodoCustoAnual-1)];

% antigo
num_Premio = ones(1,PeriodoPremio)*(1/PeriodoPremio);
den_Premio = [1 zeros(1,PeriodoPremio-1)];


%% Prepara entradas de Dividendos

atrasoMeses = mod(month(DataInicial)-1,periodoDividendos);
if atrasoMeses == 0
    atrasoMeses = periodoDividendos;
end

vetor_DividendosAPagarInicial = [zeros(1,periodoDividendos-atrasoMeses) Dividendos_A_Pagar_Inicial zeros(1,atrasoMeses-1)];

IC_DividendosAPagarInicial = [repmat(vetor_DividendosAPagarInicial(1),numRealidades,1); zeros(realidadesPorSimulacao-numRealidades,1)];
vetor_DividendosAPagarInicial(1) = 0;
vetor_DividendosAPagarInicial = [repmat(vetor_DividendosAPagarInicial,numRealidades,1); zeros(realidadesPorSimulacao-numRealidades,periodoDividendos)];

%% Prepara entradas de JSCP

atrasoMeses_JSCP = mes_JSCP-month(DataInicial);
if atrasoMeses_JSCP < 0
    vetor_JSCP_APagarInicial = zeros(1,PeriodoJSCP);
else
    vetor_JSCP_APagarInicial = [zeros(1,atrasoMeses_JSCP) JSCP_A_Pagar_Inicial zeros(1,PeriodoJSCP-atrasoMeses_JSCP-1)];
end

vetor_JSCP_APagarInicial = [repmat(vetor_JSCP_APagarInicial,numRealidades,1); zeros(realidadesPorSimulacao-numRealidades,PeriodoJSCP)];

%% GERA PARAMETROS PARA SEREM LIDOS PELO .exe (GERAÇÃO APENAS UMA VEZ)
% Para adicionar variáveis ao param_struct, ir em Configuration
% Parameters/Optimization/Signals and Parameters/Configure(Inline
% parameters) em seguida rodar a função abaixo.

% Após gerados os parametros necessários, estruturar corretamente e rodar
% sempre apenas a seção abaixo (Modifica parametros de entrada do .exe).

param_struct = rsimgetrtp('Duke_Simulink_13a','AddTunableParamInfo','on');
save('param_struct.mat','param_struct');

%% Modifica parametros de entrada do .exe

load('param_struct.mat');

indice = 1;

param_struct.parameters(1,1).values(indice) = Ajustes_Inicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = CFURH;
indice = indice + 1;
param_struct.parameters(1,1).values(indice:indice+realidadesPorSimulacao-1) = CaixaInicial; % 1x100
indice = indice + realidadesPorSimulacao;
param_struct.parameters(1,1).values(indice) = Capital_Social_Inicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice:indice+realidadesPorSimulacao-1) = DividaInicial; % 1x100
indice = indice + realidadesPorSimulacao;
param_struct.parameters(1,1).values(indice:indice+realidadesPorSimulacao-1) = IC_DividendosAPagarInicial; % 100x1
indice = indice + realidadesPorSimulacao;
param_struct.parameters(1,1).values(indice) = IR_diferido_acumulado_inicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = JSCP_ParcialPeriodo;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = JSCP_RetidoInicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = Limite_Reserva_Lucros;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = Limite_Reserva_Lucros_Capital;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = LucroParcialPeriodo;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = LucroRetidoInicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = Outros_Passivos;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PIS_COFINS_Cumulativo;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PPE_Inicial_Edificacoes;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PPE_Inicial_Maquinas;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PPE_Inicial_Moveis;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PPE_Inicial_Reservatorio;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PPE_Inicial_Terreno;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PPE_Inicial_Veiculos;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PeriodoIR_diferido;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = PeriodoJSCP;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = Reserva_Capital_Inicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = Reserva_Lucros_Inicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = TEIFa;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = TEIP;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = TEO;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = TFSEE;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = Taxa_Anual_Reserva;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = Taxa_diferimento;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = aliquotaIR;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = contribuicaoCCEE;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = deducaoP_D;
indice = indice + 1;
param_struct.parameters(1,1).values(indice:indice+length(den_Ajustes)-1) = den_Ajustes;
indice = indice + length(den_Ajustes);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Edificacoes)-1) = den_PPE_Edificacoes;
indice = indice + length(den_PPE_Edificacoes);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Maquinas)-1) = den_PPE_Maquinas;
indice = indice + length(den_PPE_Maquinas);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Moveis)-1) = den_PPE_Moveis;
indice = indice + length(den_PPE_Moveis);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Reservatorio)-1) = den_PPE_Reservatorio;
indice = indice + length(den_PPE_Reservatorio);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Veiculos)-1) = den_PPE_Veiculos;
indice = indice + length(den_PPE_Veiculos);
param_struct.parameters(1,1).values(indice:indice+length(den_Premio)-1) = den_Premio;
indice = indice + length(den_Premio);
param_struct.parameters(1,1).values(indice) = garantiaFisica;
indice = indice + 1;
param_struct.parameters(1,1).values(indice:indice+realidadesPorSimulacao*mes_JSCP-1) = inicializa_JSCP;
indice = indice + realidadesPorSimulacao*mes_JSCP;
param_struct.parameters(1,1).values(indice) = mes_DataInicial;
indice = indice + 1;
param_struct.parameters(1,1).values(indice:indice+length(den_Ajustes)-1) = num_Ajustes;
indice = indice + length(den_Ajustes);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Edificacoes)-1) = num_PPE_Edificacoes;
indice = indice + length(den_PPE_Edificacoes);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Maquinas)-1) = num_PPE_Maquinas;
indice = indice + length(den_PPE_Maquinas);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Moveis)-1) = num_PPE_Moveis;
indice = indice + length(den_PPE_Moveis);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Reservatorio)-1) = num_PPE_Reservatorio;
indice = indice + length(den_PPE_Reservatorio);
param_struct.parameters(1,1).values(indice:indice+length(den_PPE_Veiculos)-1) = num_PPE_Veiculos;
indice = indice + length(den_PPE_Veiculos);
param_struct.parameters(1,1).values(indice:indice+length(num_Premio)-1) = num_Premio;
indice = indice + length(num_Premio);
param_struct.parameters(1,1).values(indice) = periodoDividendos;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = refInd;
indice = indice + 1;
param_struct.parameters(1,1).values(indice) = taxaMinorityInterest;
indice = indice + 1;
param_struct.parameters(1,1).values(indice:indice+realidadesPorSimulacao*periodoDividendos-1) = vetor_DividendosAPagarInicial; % 100x6
indice = indice + realidadesPorSimulacao*periodoDividendos;
param_struct.parameters(1,1).values(indice:indice+realidadesPorSimulacao*PeriodoJSCP-1) = vetor_JSCP_APagarInicial; % 100x6
indice = indice + realidadesPorSimulacao*PeriodoJSCP;

indice = 1;

param_struct.parameters(1,2).values(indice) = mes_JSCP;
indice = indice + 1;
param_struct.parameters(1,2).values(indice) = periodoDividendos_delay;


save('param_struct.mat','param_struct');

% clearvars -except Ajustes_Inicial CFURH CaixaInicial Capital_Social_Inicial DividendPayoutRate JSCPAcumuladoInicial Limite_Reserva_Lucros Limite_Reserva_Lucros_Capital ...
%     LucroRetidoInicial Outros_Passivos PIS_COFINS_Cumulativo PPE_Inicial_Edificacoes PPE_Inicial_Maquinas PPE_Inicial_Moveis PPE_Inicial_Reservatorio PPE_Inicial_Terreno ...
%     PPE_Inicial_Veiculos PPE_Periodo_Edificacoes PPE_Periodo_Maquinas PPE_Periodo_Moveis PPE_Periodo_Reservatorio PPE_Periodo_Veiculos PeriodoDepreciacao_Ajustes ...
%     Reserva_Capital_Inicial Reserva_Lucros_Inicial TEIFa TEIP TEO TFSEE Taxa_Anual_Reserva aliquotaIR contribuicaoCCEE deducaoP_D garantiaFisica juros_Cash ...
%     juros_ContasAPagar juros_ContasAReceber juros_PassivoCurtoPrazo periodoDividendos refInd tempoSimulacao numRealidades DataInicial JSCP_ParcialPeriodo ...
%     vetor_DividendosAPagarInicial vetor_JSCP_APagarInicial LucroParcialPeriodo periodoDividendos_delay IC_DividendosAPagarInicial IC_JSCP_APagarInicial DividaInicial...
%     JSCP_RetidoInicial

