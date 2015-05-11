function [ PLD, GSF ] = Gera_PLD_GSF( Dados_mes, nCenarios, DataInicio, Periodo, Tipo )
%Gera_PLD_GSF Gera vetores de PLD e GSF para o modelo da Duke
%   PLD e GSF ser�o matrizes em que a 1a coluna � o tempo de simula��o (de
%   1 ao numero de meses de simula��o) e cada outra coluna � uma realidade.
%
%   nCenarios � o n�mero de realidades a serem geradas
%   DataInicio � a data inicial da simula��o (t0) em datenum.
%   Periodo � o n�mero de meses a serem simulados.
%   Tipo define a amostragem. 'Insample' para amostrar "in sample" ou
%       'Dist' para amostrar de uma distribui��o

    PLD = zeros(Periodo,nCenarios+1);
    GSF = zeros(Periodo,nCenarios+1);
    
    PLD(:,1) = 1:Periodo;
    GSF(:,1) = 1:Periodo;
    
    mesInicio = month(DataInicio);
    
    if strcmp(Tipo, 'Insample')
        for k=1:Periodo
            thisMes = mod((mesInicio+k-1)-1,12)+1; % -1 +1 para fazer 1:12
            dadosMes = Dados_mes{thisMes};
            indexSorteio = randi(size(dadosMes,1),nCenarios,1);
            PLD(k,2:end) = dadosMes(indexSorteio,1);
            GSF(k,2:end) = dadosMes(indexSorteio,2);
        end
    elseif strcmp(Tipo, 'Dist')
        distCell = cell(12,2);
        for mes=1:12
            dadosMes = Dados_mes{mes};
            pd_pld = fitdist(dadosMes(:,1),'Exponential');
            pd_gsf = fitdist(dadosMes(:,2),'Normal');
            distCell{mes,1} = pd_pld;
            distCell{mes,2} = pd_gsf;
        end
        
        for k=1:Periodo
            thisMes = mod((mesInicio+k-1)-1,12)+1; % -1 +1 para fazer 1:12
            PLD(k,2:end) = random(distCell{thisMes,1},nCenarios,1);
            GSF(k,2:end) = random(distCell{thisMes,2},nCenarios,1);
        end
    else
        disp('Tipo n�o reconhecido.');
    end

end

