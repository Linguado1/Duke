%% Comparação de receitas dos contratos

load('Receitas_planilha.mat')

receita_contratosSemImposto = [];
propIPCA = [];
propIGPM = [];

for i=1:length(Contratos)
%     if Contratos{i,1}.Imposto == 0
        if strcmp(Contratos{i,1}.agreement_type,'Conventional') | strcmp(Contratos{i,1}.agreement_type,'Swing')
            receita_contratosSemImposto = [receita_contratosSemImposto; [repmat(Contratos{i,1}.termNumber,length(Contratos{i,1}.datas),1) Contratos{i,1}.datas Contratos{i,1}.valorAtualizadoMWh' Contratos{i,1}.Receita']];
            propIPCA = [propIPCA; repmat(Contratos{i,1}.ipca,length(Contratos{i,1}.datas),1)];
            propIGPM = [propIGPM; repmat(Contratos{i,1}.igpm,length(Contratos{i,1}.datas),1)];
        end
%     end
end

% save('receita_contratosSemImposto','receita_contratosSemImposto')

[~,b] = sort(Receitas_planilha(:,2));
Receitas_planilha = Receitas_planilha(b,:);

[~,b] = sort(Receitas_planilha(:,1));
Receitas_planilha = Receitas_planilha(b,:);

[~,b] = sort(receita_contratosSemImposto(:,2));
receita_contratosSemImposto = receita_contratosSemImposto(b,:);
propIPCA = propIPCA(b,:);
propIGPM = propIGPM(b,:);

[~,b] = sort(receita_contratosSemImposto(:,1));
receita_contratosSemImposto = receita_contratosSemImposto(b,:);
propIPCA = propIPCA(b,:);
propIGPM = propIGPM(b,:);

Receitas_planilha(:,5) = receita_contratosSemImposto(:,3);
Receitas_planilha(:,6) = receita_contratosSemImposto(:,4);

Receitas_planilha(:,7) = Receitas_planilha(:,3) - Receitas_planilha(:,5);
Receitas_planilha(:,8) = Receitas_planilha(:,4) - Receitas_planilha(:,6);
Receitas_planilha(:,9) = propIPCA;
Receitas_planilha(:,10) = propIGPM;

[~,b] = sort(Receitas_planilha(:,8));
Receitas_planilha = Receitas_planilha(b,:);
