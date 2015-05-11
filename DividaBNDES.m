classdef DividaBNDES < handle
    %DIVIDABNDES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        %Entradas
        TJLP % Taxa de Juros de Longo Prazo para o cálculo da dívida
        spread % Taxa de spread cobrada pelo banco
        liberacao % Vetor com os valores liberados pelo banco
        dateLiberacao % Vetor com as datas de liberação do banco
        dateFimCarencia % Tempo de carência em meses
        dateJuros % Datas de pagamento de juros
        dateFimAmortizacao % Duração da amortização da dívida
        
        %Auxliares
        n_cenarios
        tipo
        coupom % TJLP + spread
        coupomDiario % Coupom diario
        datas % Vetor com todas as datas desde a 1a liberacao até quitação da dívida
        mes
        ano
        iSaldo
        iDateJuros
        iDateLiberacao
        iUltimoDiaUtilMes
        iUltimoDiaUtilAno
        mesesAmortizacao % Número de meses de pagamento da dívida
        fatorCorrecao
        indiceCorrecao
        vetorDiasUteis
        isDiaUtil
        LastDayOfMonth
        LastDayOfYear
        JurosMensal
        JurosAnual
        Datas_FimDoMes
        Datas_FimDoAno
        
        teste
        
        %Saidas
            %Price
        saldo % Vetor com o valor do saldo para cada dia de 'datas' %%%%CORRIGIR
        principal
        interestAcumulado % Vetor com o valor do interest acumulado para cada dia de 'datas'
        interestAcumulado_sem_reset % % Vetor com o valor do interest acumulado do mes
            %Fluxos
        jurosPagos % Vetor com valores pagos de juros
        amortizacaoPaga % Vetor com valores pagos de amortização
            %DRE
        MtM_FimDoMes
        PnL_FimDoMes
        MtM_FimDoAno
        PnL_FimDoAno
        PnL_FimDoMes_Acumulado
        PnL_FimDoAno_Acumulado
        
    end
    
    methods (Access = private)
        
        function saldoDiario(this)
            
            diaAtual = this.datas(this.iSaldo);

            if diaAtual == this.dateLiberacao(this.iDateLiberacao)
                
                this.principal(this.iSaldo,:)=this.principal(this.iSaldo-1,:)+this.liberacao(this.iDateLiberacao);
                this.iDateLiberacao=this.iDateLiberacao+1;
                
            else
                
                this.principal(this.iSaldo,:)=this.principal(this.iSaldo-1,:);
                
            end
            
            this.interestAcumulado(this.iSaldo,:) = this.interestAcumulado(this.iSaldo-1,:) + this.principal(this.iSaldo,:).*this.coupomDiario;
            this.interestAcumulado_sem_reset(this.iSaldo,:) = this.interestAcumulado_sem_reset(this.iSaldo-1,:) + this.principal(this.iSaldo,:).*this.coupomDiario;
            
            if diaAtual == this.dateJuros(this.iDateJuros)
            
                if diaAtual > this.dateFimCarencia
                    
%                     diasMes = days365(datenum(['01-' num2str(month(diaAtual)) '-' num2str(year(diaAtual))],'dd-mm-yyyy'),eomdate(diaAtual))+1;
                    diasSemPagar=this.dateJuros(this.iDateJuros)-this.dateJuros(this.iDateJuros-1);
                    this.fatorCorrecao(this.mesesAmortizacao,:) = this.interestAcumulado(this.iSaldo,:) * 30/(diasSemPagar * this.principal(this.iSaldo,:));
                    this.indiceCorrecao(this.mesesAmortizacao,:) = (1+this.fatorCorrecao(this.mesesAmortizacao,:))^this.mesesAmortizacao;
                    this.amortizacaoPaga(this.mesesAmortizacao,:) = this.fatorCorrecao(this.mesesAmortizacao,:)/(this.indiceCorrecao(this.mesesAmortizacao,:)-1)*this.principal(this.iSaldo,:);
                    this.principal(this.iSaldo,:)=roundn(this.principal(this.iSaldo,:)-this.amortizacaoPaga(this.mesesAmortizacao,:),-9);
                    
                    this.mesesAmortizacao = this.mesesAmortizacao - 1;
                    
                    
                end
                
                this.jurosPagos(this.iDateJuros,:)=this.interestAcumulado(this.iSaldo,:);
                this.interestAcumulado(this.iSaldo,:) = 0;
                this.iDateJuros = this.iDateJuros+1;
                
            end
                   
            this.saldo(this.iSaldo,:)=this.principal(this.iSaldo,:)+this.interestAcumulado(this.iSaldo,:);
            
            if f_isUltimoDiaUtilMes(this)
              
                this.mes = this.mes + 1;
                
                if this.mes == 1
                    this.PnL_FimDoMes(this.mes,:) = this.interestAcumulado_sem_reset(this.iSaldo,:);
                    this.PnL_FimDoMes_Acumulado = this.PnL_FimDoMes_Acumulado + this.PnL_FimDoMes(this.mes,:);
                else
                    this.PnL_FimDoMes(this.mes,:) = this.interestAcumulado_sem_reset(this.iSaldo,:) - this.PnL_FimDoMes_Acumulado;
                    this.PnL_FimDoMes_Acumulado = this.PnL_FimDoMes_Acumulado + this.PnL_FimDoMes(this.mes,:);
                end
                
                this.MtM_FimDoMes(this.mes,:) = this.saldo(this.iSaldo,:);
                
            end
            
            if f_isUltimoDiaUtilAno(this)
                
                this.ano = this.ano + 1;
                
                if this.ano == 1
                    this.PnL_FimDoAno(this.ano,:) = this.interestAcumulado_sem_reset(this.iSaldo,:);
                    this.PnL_FimDoAno_Acumulado = this.PnL_FimDoAno_Acumulado + this.PnL_FimDoAno(this.ano,:);
                else
                    this.PnL_FimDoAno(this.ano,:) = this.interestAcumulado_sem_reset(this.iSaldo,:) - this.PnL_FimDoAno_Acumulado;
                    this.PnL_FimDoAno_Acumulado = this.PnL_FimDoAno_Acumulado + this.PnL_FimDoAno(this.ano,:);
                end
                
                this.MtM_FimDoAno(this.ano,:) = this.saldo(this.iSaldo,:);
                
            end
            this.iSaldo = this.iSaldo+1;
            
        end
        
        function booleanOut = f_isUltimoDiaUtilMes(this) % sergio 17/10/2013
            % Verifica se hoje é o último dia útil do mês            
            
            if this.vetorDiasUteis(this.iSaldo)
                dataAtual = this.datas(this.iSaldo);
                if dataAtual == this.Datas_FimDoMes(this.iUltimoDiaUtilMes)
                    booleanOut = 1;
                    this.iUltimoDiaUtilMes = this.iUltimoDiaUtilMes + 1;
                else
                    booleanOut = 0;
                end
            else
                booleanOut = 0;
            end
            
        end
        
        function booleanOut = f_isUltimoDiaUtilAno(this) % sergio 17/10/2013
            % Verifica se hoje é o último dia útil do ano

            if this.vetorDiasUteis(this.iSaldo)
                dataAtual = this.datas(this.iSaldo);
                if dataAtual == this.Datas_FimDoAno(this.iUltimoDiaUtilAno)
                    booleanOut = 1;
                    this.iUltimoDiaUtilAno = this.iUltimoDiaUtilAno + 1;
                else
                    booleanOut = 0;
                end
            else
                booleanOut = 0;
            end
 
        end
        
    end
    
    methods
        
        function this = DividaBNDES(TJLP, spread, liberacao, dateLiberacao, dateFimCarencia, dateJurosCarencia, dateFimAmortizacao, isDiaUtil)
        
            this.TJLP=TJLP;
            this.spread=spread;
            this.liberacao=[liberacao 0];
            this.dateLiberacao=[dateLiberacao dateFimAmortizacao];
            this.dateFimCarencia=dateFimCarencia;
            this.tipo='BNDES';
            
            this.dateFimAmortizacao=dateFimAmortizacao;
            
            this.datas = this.dateLiberacao(1):dateFimAmortizacao;
            
            this.mesesAmortizacao = months(this.dateFimCarencia,this.dateFimAmortizacao)+1;
            dateJurosAmortizacao=zeros(1,this.mesesAmortizacao);
            
            for k=1:this.mesesAmortizacao
                dateJurosAmortizacao(k)=eomdate(datenum(['01/' num2str(month(this.dateFimCarencia)+k-1) '/' num2str(year(this.dateFimCarencia))],'dd/mm/yyyy'));
            end
            
            this.dateJuros=[dateJurosCarencia dateJurosAmortizacao];
            
            this.isDiaUtil = isDiaUtil;
            
            iDiasUteis_i = find(isDiaUtil(1, :) == this.dateLiberacao(1), 1);
            iDiasUteis_f = find(isDiaUtil(1, :) == this.dateFimAmortizacao, 1);
            
            this.vetorDiasUteis = isDiaUtil(2, iDiasUteis_i : iDiasUteis_f);
            
            cont = 1;
            mesInicial = month(dateLiberacao(1));
            anoInicial = year(dateLiberacao(1));
            mesFinal = month(dateFimAmortizacao);
            anoFinal = year(dateFimAmortizacao);
            
            this.teste = 0;
            
            y = anoInicial;
            for m = mesInicial : 12
                ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == m) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                this.Datas_FimDoMes(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(m) '/' num2str(y)], 'dd/mm/yyyy');
                cont = cont + 1;
            end
            
            for y = (anoInicial + 1) : (anoFinal - 1)
                for m = 1 : 12
                    ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == m) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                    this.Datas_FimDoMes(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(m) '/' num2str(y)], 'dd/mm/yyyy');
                    cont = cont + 1;
                end
            end
            
            y = anoFinal;
            for m = 1 : mesFinal
                ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == m) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                this.Datas_FimDoMes(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(m) '/' num2str(y)], 'dd/mm/yyyy');
                cont = cont + 1;
            end
            
            cont = 1;
            
            for y = anoInicial : anoFinal
                ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == 12) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                this.Datas_FimDoAno(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(12) '/' num2str(y)], 'dd/mm/yyyy');
                cont = cont + 1;
            end
            
            this.PnL_FimDoMes_Acumulado = 0;
            this.PnL_FimDoAno_Acumulado = 0;
            
        end
        
        function generate(this)
            
            tam=length(this.datas);
            
            this.mes=0;
            this.ano=0;
            
            this.iSaldo=2;
            
            this.iDateJuros=1;
            this.iDateLiberacao=2;
            
            this.coupom=this.TJLP+this.spread;
            this.coupomDiario=this.coupom/360;
            this.n_cenarios = length(this.TJLP);
            
            this.saldo = zeros(tam,this.n_cenarios);
            this.interestAcumulado = zeros(tam,this.n_cenarios);
            this.interestAcumulado_sem_reset = zeros(tam,this.n_cenarios);
            this.principal = zeros(tam,this.n_cenarios);
            
            this.saldo(1,:)=this.liberacao(1);
            this.principal(1,:)=this.liberacao(1);
            
            this.iUltimoDiaUtilMes = 1;
            this.iUltimoDiaUtilAno = 1;
            
            for i = 2:tam
                this.saldoDiario();
            end
            
            this.amortizacaoPaga=fliplr(this.amortizacaoPaga);
            
            lastDayMes = find(this.isDiaUtil(2, (month(this.dateFimAmortizacao) == month(this.isDiaUtil(1,:))) & (year(this.dateFimAmortizacao) == year(this.isDiaUtil(1,:)))),1,'last');
            lastDayAno = find(this.isDiaUtil(2, (month(this.isDiaUtil(1,:)) == 12) & (year(this.dateFimAmortizacao) == year(this.isDiaUtil(1,:)))),1,'last');
            
            if this.dateFimAmortizacao ~= datenum([num2str(lastDayMes) '/' num2str(month(this.dateFimAmortizacao)) '/' num2str(year(this.dateFimAmortizacao))],'dd/mm/yyyy')
                
                this.mes=this.mes+1;
                this.MtM_FimDoMes(this.mes,:)=this.principal(end,:)+this.interestAcumulado(end,:);
                this.PnL_FimDoMes(this.mes,:)=this.interestAcumulado_sem_reset(end,:) - this.PnL_FimDoMes_Acumulado;
                ultimoDiaUtil = find(this.isDiaUtil(2, ((month(this.isDiaUtil(1, :)) == month(datenum(['01/' num2str(1+month(this.dateFimAmortizacao)) '/' num2str(year(this.dateFimAmortizacao))],'dd/mm/yyyy'))) & (year(this.isDiaUtil(1, :)) == year(datenum(['01/' num2str(1+month(this.dateFimAmortizacao)) '/' num2str(year(this.dateFimAmortizacao))],'dd/mm/yyyy'))))), 1, 'last');
                this.Datas_FimDoMes(this.mes) = datenum([num2str(ultimoDiaUtil) '/' num2str(1+month(this.dateFimAmortizacao)) '/' num2str(year(this.dateFimAmortizacao))], 'dd/mm/yyyy');
            
            end
            
            if this.dateFimAmortizacao ~= datenum([num2str(lastDayAno) '/12/' num2str(year(this.dateFimAmortizacao))],'dd/mm/yyyy')
                
                this.ano=this.ano+1;
                this.MtM_FimDoAno(this.ano,:)=this.principal(end,:)+this.interestAcumulado(end,:);
                this.PnL_FimDoAno(this.ano,:)=this.interestAcumulado_sem_reset(end,:) - this.PnL_FimDoAno_Acumulado;
                ultimoDiaUtil = find(this.isDiaUtil(2, ((month(this.isDiaUtil(1, :)) == 12) & (year(this.isDiaUtil(1, :)) == year(this.Datas_FimDoMes(end))))), 1, 'last');
                this.Datas_FimDoAno(this.ano) = datenum([num2str(ultimoDiaUtil) '/12/' num2str(year(this.Datas_FimDoMes(end)))],'dd/mm/yyyy');
            
            end
            
%             this.PnL_FimDoMes = [this.JurosMensal(1) diff(this.JurosMensal)];
%             this.PnL_FimDoAno = [this.JurosAnual(1) diff(this.JurosAnual)];
            
        end
            
    end
    
end

