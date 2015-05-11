function [energiaContratada, energiaContratada_Total, receitaContratada, receitaContratada_Total, PIS_COFINS_ICMS_Contratos, PIS_COFINS_ICMS_Contratos_Total] = calculaContratos(mesesSimulacao, vetorContratos, dataInSimN)

%     dataInSimN = datenum(dataInSimS, 'dd/mm/yyyy');

    dataFinSimN = addtodate(dataInSimN, mesesSimulacao, 'month');
        
    numCenarios = size(vetorContratos{1}.index, 1);
    numMesesSim = mesesSimulacao+1;
    numContratos = length(vetorContratos);
    
    datasSim = datenum([repmat('01/',numMesesSim,1) num2str(month(dataInSimN)+(0:mesesSimulacao)') repmat(['/' num2str(year(dataInSimN))],numMesesSim,1)],'dd/mm/yyyy');

    
%% Energia, Valor e Impostos

    energiaContratada = zeros(numMesesSim,numContratos);
    energiaContratada_Total = zeros(numMesesSim, 2);
    
    receitaContratada = zeros(numMesesSim, numCenarios, numContratos);
    receitaContratada_Total = zeros(numMesesSim, numCenarios+1);
    
    PIS_COFINS_ICMS_Contratos = zeros(numMesesSim, numCenarios, numContratos);
    PIS_COFINS_ICMS_Contratos_Total = zeros(numMesesSim, numCenarios+1);
    
    for i = 1 : numContratos
        
        duracaoContrato = months(vetorContratos{i}.dataInicio,vetorContratos{i}.dataFinal)+1;
        datasContrato = datenum([repmat('01/',duracaoContrato,1) num2str(month(vetorContratos{i}.dataInicio)+(0:duracaoContrato-1)') repmat(['/' num2str(year(vetorContratos{i}.dataInicio))],duracaoContrato,1)],'dd/mm/yyyy');
        
        filtro1 = datasContrato >= dataInSimN;
        filtro2 = datasContrato <= dataFinSimN;
        filtroContratos = filtro1 & filtro2;
        
        datasFiltradas = datasContrato(filtroContratos);
        
        if ~isempty(datasFiltradas)
            duracaoFiltrada = months(datasFiltradas(1),datasFiltradas(end))+1;

            indexDataInicio = find(datasSim==datasFiltradas(1));

            energiaContratada(indexDataInicio:indexDataInicio+duracaoFiltrada-1,i) = vetorContratos{i}.energiaContratada(filtroContratos,:);
            receitaContratada(indexDataInicio:indexDataInicio+duracaoFiltrada-1,:,i) = vetorContratos{i}.Receita(:,filtroContratos)';
    %         PIS_COFINS_ICMS_Contratos(indexDataInicio:indexDataInicio+duracaoFiltrada-1,:,i) = vetorContratos{i}.pisPago(:,filtroContratos)' + vetorContratos{i}.cofinsPago(:,filtroContratos)' + vetorContratos{i}.icmsPago(:,filtroContratos)';
            PIS_COFINS_ICMS_Contratos(indexDataInicio:indexDataInicio+duracaoFiltrada-1,:,i) = vetorContratos{i}.ImpostoPago(:,filtroContratos)';
        end
            

        clear datasContrato duracaoContrato filtro1 filtro2 filtroContratos datasFiltradas indexDataInicio duracaoFiltrada
    end
    
    energiaContratada(isnan(energiaContratada))=0;
    receitaContratada(isnan(receitaContratada))=0;
    PIS_COFINS_ICMS_Contratos(isnan(PIS_COFINS_ICMS_Contratos))=0;
    
    energiaContratada_Total(:,1) =  1 : numMesesSim;
    energiaContratada_Total(:,2) = sum(energiaContratada,2);
    
    receitaContratada_Total(:,1) = 1 : numMesesSim;
    receitaContratada_Total(:,2:end) = sum(receitaContratada,3);

    PIS_COFINS_ICMS_Contratos_Total(:,1) = 1 : numMesesSim;
    PIS_COFINS_ICMS_Contratos_Total(:,2:end) = sum(PIS_COFINS_ICMS_Contratos,3);
    
end




