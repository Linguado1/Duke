if simulacao == 1
    
    [~,~,Curvas_Entrada_raw] = xlsread(source_filename,'Curvas');
    
    count_linhas=2;
    % Filtra linhas finais
    for k=3:size(Curvas_Entrada_raw,1)
        if ~isnan(Curvas_Entrada_raw{k,1})
            count_linhas = count_linhas+1;
        else
            break
        end
    end
    
    Curvas_Entrada = Curvas_Entrada_raw(3:count_linhas,:);
    
    for k=1:size(Curvas_Entrada,1)
        coluna = 1;
        
        % Datas
        Datas_entrada(k) = datenum(Curvas_Entrada{k,coluna},'dd/mm/yyyy');
        
        coluna = coluna +1;
        coluna = coluna +1;
        
        taxa_paga_dividendos_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        vetorPagaDividendos_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        
        vetorPagaJSCP_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        PLD_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        
        GSF_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        
        GF_sazonalizada_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        %Juros - Rendimentos
        TJLP_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        IPCA_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        IGPM_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        CDI_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        Outro_Indice_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
                
        dolar_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        compraMRE_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        vendaMRE_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        regulatoryFees_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        OeM_expenses_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        OeM_labor_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        AeG_expenses_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        AeG_labor_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        propertyAndOtherTaxes_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        operatingIncome_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        otherIncome_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        depreciacao_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        otherInterestExpenses_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        deferredIncomeTaxes_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        variacaoAtivosCirculantes_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        variacaoPassivosCirculantes_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        Contingencia_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        returnOfCapitals_dividendsFromInvestments_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        cashFlowsFromInvestinglActivities_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        cashFlowsFromFinancialActivities_Outros_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        CapitalSocial_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
        otherShareholdersEquity_entrada(k,1) = Curvas_Entrada{k,coluna};
        coluna = coluna +1;
        coluna = coluna +1;
        
    end
    
end % if simulacao

if numRealidades_total == 1
    TJLP_realidades = [TJLP_entrada zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    IPCA_realidades = [IPCA_entrada zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    IGPM_realidades = [IGPM_entrada zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    CDI_realidades = [CDI_entrada zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    Outro_Indice_realidades = [Outro_Indice_entrada zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
%     dolar_realidades = [dolar_entrada zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
else
    TJLP_realidades = [repmat(TJLP_entrada,1,numRealidades) + desvioPadrao_TJLP.*randn(size(Curvas_Entrada,1),numRealidades) zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    IPCA_realidades = [repmat(IPCA_entrada,1,numRealidades) + desvioPadrao_IPCA.*randn(size(Curvas_Entrada,1),numRealidades) zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    IGPM_realidades = [repmat(IGPM_entrada,1,numRealidades) + desvioPadrao_IGPM.*randn(size(Curvas_Entrada,1),numRealidades) zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    CDI_realidades = [repmat(CDI_entrada,1,numRealidades) + desvioPadrao_CDI.*randn(size(Curvas_Entrada,1),numRealidades) zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
    Outro_Indice_realidades = [repmat(Outro_Indice_entrada,1,numRealidades) + desvioPadrao_Outro_Indice.*randn(size(Curvas_Entrada,1),numRealidades) zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
%     dolar_realidades = [repmat(dolar_entrada,1,numRealidades) + desvioPadrao_Outro_Indice.*randn(size(Curvas_Entrada,1),numRealidades) zeros(size(Curvas_Entrada,1),realidadesPorSimulacao-numRealidades)];
end

raw_TJLP = [Datas_entrada' fatores_TJLP*TJLP_realidades];
raw_IPCA = [Datas_entrada' fatores_IPCA*IPCA_realidades];
raw_IGPM = [Datas_entrada' fatores_IGPM*IGPM_realidades];
raw_CDI = [Datas_entrada' fatores_CDI*CDI_realidades];
raw_Outro_Indice = [Datas_entrada' fatores_Outro*Outro_Indice_realidades];
% raw_dolar = [Datas_entrada' dolar_realidades];

indexInicio = find(Datas_entrada==DataInicial);
indexFim = find(Datas_entrada==addtodate(DataInicial, mesesSimulacao-1, 'month'));

load('PLD_GSF_mes.mat');

if numRealidades_total == 1
    PLD = [(1:mesesSimulacao)' PLD_entrada(indexInicio:indexFim) zeros(mesesSimulacao,realidadesPorSimulacao-numRealidades)];
    GSF = [(1:mesesSimulacao)' GSF_entrada(indexInicio:indexFim) zeros(mesesSimulacao,realidadesPorSimulacao-numRealidades)];
else
    [ PLD, GSF ] = Gera_PLD_GSF( Dados_mes, realidadesPorSimulacao, DataInicial, mesesSimulacao, 'Insample' );
end
    
GF_sazonalizada = [(1:mesesSimulacao)' [GF_sazonalizada_entrada(indexInicio:indexFim);zeros(tempoSimulacao-size(GF_sazonalizada_entrada,1),1)]];

taxa_paga_dividendos = [(1:mesesSimulacao)' taxa_paga_dividendos_entrada(indexInicio:indexFim)];

sim_TJLP = [(1:mesesSimulacao)' raw_TJLP(indexInicio:indexFim,2:end)];
sim_IPCA = [(1:mesesSimulacao)' raw_IPCA(indexInicio:indexFim,2:end)];
sim_IGPM = [(1:mesesSimulacao)' raw_IGPM(indexInicio:indexFim,2:end)];
sim_CDI = [(1:mesesSimulacao)' raw_CDI(indexInicio:indexFim,2:end)];
sim_Outro = [(1:mesesSimulacao)' raw_Outro_Indice(indexInicio:indexFim,2:end)];
% sim_dolar = [(1:mesesSimulacao)' raw_dolar(indexInicio:indexFim,2:end)];

dolar_limitado = dolar_entrada(indexInicio-1:indexFim)';

CurvaReajuste = [(1:mesesSimulacao)' cumprod(repmat((1+reajusteSalario)^(1/12),mesesSimulacao,1))];

CapitalSocial = [(0:mesesSimulacao)' CapitalSocial_entrada((indexInicio-1):indexFim)]; % Considera o Capital Social do mês anterior ao inicio como Capital Social Inicial

compraMRE = [(1:mesesSimulacao)' compraMRE_entrada(indexInicio:indexFim)];
vendaMRE = [(1:mesesSimulacao)' vendaMRE_entrada(indexInicio:indexFim)];

regulatoryFees = [(1:mesesSimulacao)' regulatoryFees_entrada(indexInicio:indexFim)];

OeM_expenses = [(1:mesesSimulacao)' OeM_expenses_entrada(indexInicio:indexFim)];
OeM_labor = [(1:mesesSimulacao)' OeM_labor_entrada(indexInicio:indexFim)];
AeG_expenses = [(1:mesesSimulacao)' AeG_expenses_entrada(indexInicio:indexFim)];
AeG_labor = [(1:mesesSimulacao)' AeG_labor_entrada(indexInicio:indexFim)];

propertyAndOtherTaxes = [(1:mesesSimulacao)' propertyAndOtherTaxes_entrada(indexInicio:indexFim)];

operatingIncome = [(1:mesesSimulacao)' operatingIncome_entrada(indexInicio:indexFim)];
otherIncome = [(1:mesesSimulacao)' otherIncome_entrada(indexInicio:indexFim)];

depreciacao = [(1:mesesSimulacao)' depreciacao_entrada(indexInicio:indexFim)];

otherInterestExpenses = [(1:mesesSimulacao)' otherInterestExpenses_entrada(indexInicio:indexFim)];

deferredIncomeTaxes = [(1:mesesSimulacao)' deferredIncomeTaxes_entrada(indexInicio:indexFim)];

variacaoAtivosCirculantes = [(1:mesesSimulacao)' variacaoAtivosCirculantes_entrada(indexInicio:indexFim)];

variacaoPassivosCirculantes = [(1:mesesSimulacao)' variacaoPassivosCirculantes_entrada(indexInicio:indexFim)];

Contingencia = [(1:mesesSimulacao)' Contingencia_entrada(indexInicio:indexFim)];

returnOfCapitals_dividendsFromInvestments = [(1:mesesSimulacao)' returnOfCapitals_dividendsFromInvestments_entrada(indexInicio:indexFim)];

cashFlowsFromInvestinglActivities = [(1:mesesSimulacao)' cashFlowsFromInvestinglActivities_entrada(indexInicio:indexFim)];

cashFlowsFromFinancialActivities_Outros = [(1:mesesSimulacao)' cashFlowsFromFinancialActivities_Outros_entrada(indexInicio:indexFim)];

% accountsReceivable_Trade = [(1:mesesSimulacao)' accountsReceivable_Trade_entrada(indexInicio:indexFim)];
% 
% insurance = [(1:mesesSimulacao)' insurance_entrada(indexInicio:indexFim)];
% 
% otherCurrentAssets = [(1:mesesSimulacao)' otherCurrentAssets_entrada(indexInicio:indexFim)];
% 
% nonCurrentAssets = [(1:mesesSimulacao)' nonCurrentAssets_entrada(indexInicio:indexFim)];
% 
% accountsPayable = [(1:mesesSimulacao)' accountsPayable_entrada(indexInicio:indexFim)];
% 
% taxesPayable = [(1:mesesSimulacao)' taxesPayable_entrada(indexInicio:indexFim)];
% 
% otherCurrentLiabilities = [(1:mesesSimulacao)' otherCurrentLiabilities_entrada(indexInicio:indexFim)];
% 
% otherNonCurrentLiabilities = [(1:mesesSimulacao)' otherNonCurrentLiabilities_entrada(indexInicio:indexFim)];

otherShareholdersEquity = [(1:mesesSimulacao)' otherShareholdersEquity_entrada(indexInicio:indexFim)];
