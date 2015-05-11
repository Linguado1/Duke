load('isDiaUtil.mat');
rangeDias_aux = Debentures{1,j}.dateEmissao:Debentures{1,j}.dateFinal;
inicioDiaUtil = find(isDiaUtil(1,:)==Debentures{1,j}.dateEmissao);
fimDiaUtil = find(isDiaUtil(1,:)==Debentures{1,j}.dateFinal);
rangeDias = rangeDias_aux(1==isDiaUtil(2,inicioDiaUtil:fimDiaUtil));

nDias=length(rangeDias);
cdiDiario = zeros(nDias,Debentures{1,j}.n_cenarios);
thisCDI = raw_CDI(inicio_Index:fim_Index,2:end);
cdiEsteMes = thisCDI(1,:);
countCDI=1;
esteMes = month(Debentures{1,j}.dateEmissao);
for k=1:nDias
    
    if month(rangeDias(k))~=esteMes;
        countCDI=countCDI+1;
        esteMes=month(rangeDias(k));
        cdiEsteMes = thisCDI(countCDI,:);
    end
    
    cdiDiario(k,:)=cdiEsteMes;
end

debentureCDI=cdiDiario;