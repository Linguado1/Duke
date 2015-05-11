classdef ContratoManager < handle
    %CONTRATO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % Entrada
        
        index % Vetor com a curva do indexador de infla��o
        energiaContratada % Vetor da quantidade de MWmedio contratado m�s a m�s
        valorMWh % Vetor de pre�os do MWh m�s a m�s
        Imposto % Valor conjunto de impostos a ser pagos
%         PIS % Taxa de imposto PIS
%         COFINS % Taxa de imposto COFINS
%         ICMS % Taxa de imposto ICMS
        dataInicio % Data de in�cio do contrato
        dataFinal % Data de finaliza��o do contrato
        dataBase % Data base de infla��o
        mesAtualizacaoInflacao % Mes de atualizacao da inflacao
        numCenarios % N�mero de cen�rios
        
        % Auxiliar
        
        iMes % indice do 'for'
        datas % Vetor com as datas mensais (01/mm/yyyy)
        diasDoMes % N dias do m�s
        energiaMensal % Vetor energiaContratada * nHoras_mes
        valorAtualizadoMWh % Vetor mensal do pre�o do MWh inflacionado
        indexAcumulado % Vetor mensal da infla��o acumulada
        indexAplicado % Vetor com a infla��o aplicada
        mesesBaseInicio % Meses da data base at� inicio
        datasInflacao % Datas da data base at� final
        termNumber % Identificador do contrato
        
        % Saidas
        
        Receita % Vetor com a receita mensal
        ImpostoPago % Vetor com o imposto total pago no mes
%         pisPago % Vetor com a PIS pago no mes
%         cofinsPago % Vetor com a COFINS pago no mes
%         icmsPago % Vetor com a ICMS pago no mes
        
        
    end
    
    methods (Access = private)
        
        function receitaMensal(this)
            
            this.iMes=this.iMes+1;
            
            diaAtual=this.datas(this.iMes);
            
            this.valorAtualizadoMWh(:,this.iMes) = this.valorMWh(this.iMes) * this.indexAplicado(:,this.iMes);
            
            this.diasDoMes(this.iMes) = eomday(year(diaAtual),month(diaAtual));
            
            this.energiaMensal(this.iMes) = this.diasDoMes(this.iMes) * 24 * this.energiaContratada(this.iMes);
            
            this.Receita(:,this.iMes) = this.energiaMensal(this.iMes)*this.valorAtualizadoMWh(:,this.iMes);
            
            this.ImpostoPago(:,this.iMes) = this.Receita(:,this.iMes)*this.Imposto;
%             this.pisPago(:,this.iMes) = this.Receita(:,this.iMes)*this.PIS;
%             this.cofinsPago(:,this.iMes) = this.Receita(:,this.iMes)*this.COFINS;
%             this.icmsPago(:,this.iMes) = this.Receita(:,this.iMes)*this.ICMS;
            
        end
        
    end
    
    methods
        
        function this = ContratoManager(index,energiaContratada,valorMWh,Imposto,dataInicio,dataFinal,dataBase,mesAtualizacaoInflacao,termNumber)
            
            this.index=index;
            this.energiaContratada=energiaContratada;
            this.valorMWh=valorMWh;
            this.Imposto=Imposto;
%             this.PIS=PIS;
%             this.COFINS=COFINS;
%             this.ICMS=ICMS;
            this.dataInicio=dataInicio;
            this.dataFinal=dataFinal;
            this.dataBase=dataBase;
            this.mesAtualizacaoInflacao=mesAtualizacaoInflacao;
            this.numCenarios=size(index,1);
            this.termNumber = termNumber;
            
        end
        
        function generate(this)
            
            duracao=months(this.dataInicio,this.dataFinal)+1;
            
            this.energiaMensal = zeros(this.numCenarios,duracao);
            this.diasDoMes = zeros(this.numCenarios,duracao);
            this.valorAtualizadoMWh = zeros(this.numCenarios,duracao);
            this.indexAplicado = zeros(this.numCenarios,duracao);
            
            this.mesesBaseInicio = months(this.dataBase,this.dataInicio);
            
            this.indexAcumulado = [cumprod(1 + this.index,2)];
            duracaoInflacao=size(this.indexAcumulado,2)-1;
            
            if this.mesesBaseInicio<1 %% POG para fazer sentido
                this.mesesBaseInicio=1;
            end
                      
            this.indexAplicado(:,1)=this.indexAcumulado(:,this.mesesBaseInicio);
            
            this.Receita=zeros(this.numCenarios,duracao);
            
            this.datas = datenum([repmat('01/',duracao,1) num2str([month(this.dataInicio):month(this.dataInicio)+duracao-1]') repmat(['/' num2str(year(this.dataInicio))],duracao,1)],'dd/mm/yyyy');
            this.datasInflacao = datenum([repmat('01/',duracaoInflacao,1) num2str([month(this.dataBase)+1:month(this.dataBase)+duracaoInflacao]') repmat(['/' num2str(year(this.dataBase))],duracaoInflacao,1)],'dd/mm/yyyy');
                     
            indexAplicado_aux=zeros(this.numCenarios,duracaoInflacao);
            
            for mesInflacao = 1:duracaoInflacao
                
                diaAtual=this.datasInflacao(mesInflacao);
                
                if month(diaAtual)==this.mesAtualizacaoInflacao

                    indexAplicado_aux(:,mesInflacao) = this.indexAcumulado(:,mesInflacao);

                else
                    if mesInflacao==1
                        indexAplicado_aux(:,mesInflacao)=1;
                    else
                        indexAplicado_aux(:,mesInflacao) = indexAplicado_aux(:,mesInflacao-1);
                    end
                end
                
            end
                
            this.indexAplicado = indexAplicado_aux(:,this.mesesBaseInicio:end);
            
            this.iMes=0;
            
            for i=1:duracao
                this.receitaMensal();
            end
            
        end
        
    end
    
end

