classdef DebentureManager < handle
    %DEBENTUREMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % Para cada cenário:
        
        cdi % taxa de CDI para cada dia
        spread % taxa diária de Spread
        nominal % valor nominal da debênture
        nominalInicial % valor nominal inicial da debênture
        juros % juros acumulado a pagar
        dateEmissao % Dia de Emissão da debênture
        dateEmissao_util % Dia de Emissão útil da debênture
        n_cenarios % número de cenários
        tam % número de dias a rodas
        NumeroDebentures % Quantidade de debentures emitida
        pPremioPrePagamento % Porcentagem do saldo a ser pago como premio para pre-pagamento da dívida (pagamento na data final da debenture)
        pPremioReducaoCapital % Porcentagem do saldo a ser pago como premio para reduzir o capital social (pagamento na data da redução)
        dateReducaoCapital % Data da redução de Capital Social
        pCustoEmissao % Porcentagem sobre o valor nominal de custo de emissão (pagamento na emissão)
        pTaxaCETIP % Porcentagem mensal sobre o saldo a ser pago como custo de manutanção (mensal)
        valorCustoMensal % Valor a ser pago como custo de manutanção (mensal)
        valorCustoSemestral % Valor a ser pago como custo de manutanção (semestral) DRE rateado ao longo do semestre
        valorCustoAnual % Valor a ser pago como custo de manutanção (anual) DRE rateado ao longo do ano

        cdiAcumulado % índice de CDI acumulado
        spreadAcumulado % índice de Spread acumulado
        cdiDiario % índice de CDI diário
        cdiMaisSpread % índice de CDI mais Spread acumulados
        
        diasUteis % vetor com 'U' para dias úteis e 'F' para dias livres e feriados, para cada dia de 'datas'
        isDiaUtil % vetor com TODOS os dias uteis de 2001 a 2077
        
        acumulado % valor de Juros + CDI acumulados para cada dia de 'datas'
        acumulado_sem_reset % valor de Juros + CDI acumulados sem reset nos dias de pagamento de juros
        acumulado_ate_juros % valor de Juros + CDI acumulados até data de pagamento de juros
        
        dateJuros % vetor com dias de pagamento de juros
        amortizacao % matriz com dias e valores de amortização
        price % vetor com o valor do price para cada dia de 'datas'
        interest % vetor com o valor do interest para cada dia de 'datas'
        datas % vetor com todas as datas desde 'dateEmissao' até 'dateFinal'
        vetorDiasUteis % vetor com classificação dos dias em úteis ou livres
        dateFinal % Dia Final útil da Debênture
        dateFinal_util % Dia Final útil da debênture

        MtM_FimDoMes % vetor de valores de Price no fim de cada mês
        PnL_FimDoMes % vetor de valores de Juros incididos no mês no fim de cada mês
        JurosAcumulados_FimDoMes % vetor de valores de Juros acumulados até mês no fim de cada mês 
        MtM_FimDoAno % vetor de valores de Price no fim de cada mês
        PnL_FimDoAno % vetor de valores de Juros incididos no mês no fim de cada mês
        JurosAcumulados_FimDoAno % vetor de valores de Juros acumulados até mês no fim de cada mês 
        isUltimoDiaUtilMes % vetor booleano dizendo se é último dia útil do mês
        isUltimoDiaUtilAno % vetor booleano dizendo se é último dia útil do ano
        isUltimoDiaMes % vetor booleano dizendo se é último dia do mês
        isUltimoDiaAno % vetor booleano dizendo se é último dia do ano
        Datas_FimDoMes % vetor de datas de fim do mes
        Datas_FimDoAno % vetor de datas de fim do ano

        iDateJuros % índice do vetor de datas de pagamento de juros
        iAmortizacao % índice do vetor de amortização
        iPrice % índice do vetor do Price
        iCDI % índice do vetor do CDI
        mes % mês relativo ao inicio da debenture
        ano % ano relativo ao inicio da debenture
        
        tipo % tipo da debênture (CDI, IPCA, ...)
        pAP % parâmetro de atualização do price
        pFimUtil % parâmetro de saída no último dia útil
        
        % pDUL é 1 para o primeio dia útil de uma sequência de dias úteis
        % pDUL é 0 para o primeiro dia livre de uma sequência de dias
        % livres       
        pDUL 
    end

    methods (Access = private)

        function priceDiario(this)
            
            diaAtual = this.datas(this.iPrice);
            
            % Verifica se é o último dia útil do mês ou do ano
            this.isUltimoDiaUtilMes(this.iPrice)=this.f_isUltimoDiaUtilMes; % sergio 18/10/2013
            this.isUltimoDiaUtilAno(this.iPrice)=this.f_isUltimoDiaUtilAno; % sergio 18/10/2013
            % Verifica se é o último dia o mês ou do ano
            this.isUltimoDiaMes(this.iPrice)=this.f_isUltimoDiaMes; % sergio 27/02/2014
            this.isUltimoDiaAno(this.iPrice)=this.f_isUltimoDiaAno; % sergio 27/02/2014

            
            % Se é dia útil
            if this.vetorDiasUteis(this.iPrice) % ruivo_30/09/2013
                
                % Se pAP == 1 e pDUL == 1
                if this.pAP && this.pDUL
                    this.holdData();
                    this.pDUL = 0;
  
                else
                    % Calcula o price para o dia atual
                    this.calculatePrice();
                end
                
                % Se é dia de pagamento de juros, paga juros
                if diaAtual == this.dateJuros(this.iDateJuros)
                    this.payInterest();
                end
                
                % Se é dia de pagamento de amortização, paga amortização
                if diaAtual == this.amortizacao(this.iAmortizacao, 1)
                    this.payAmortization();
                end
                

                % (se é último dia útil do mês AND se saida é último dia útil) OR (se é último dia do mês AND se saida é último dia)
                if (this.isUltimoDiaUtilMes(this.iPrice) && this.pFimUtil) || (this.isUltimoDiaMes(this.iPrice) && ~this.pFimUtil) 
                    this.mes=this.mes+1;
                    this.MtM_FimDoMes(this.mes, :) = this.price(this.iPrice, :);
                    this.JurosAcumulados_FimDoMes(this.mes, :) = this.acumulado_sem_reset(this.iPrice, :);
                    this.Datas_FimDoMes(this.mes)=this.datas(this.iPrice);
                end
                
                % (se é último dia útil do ano AND se saida é último dia útil) OR (se é último dia do ano AND se saida é último dia)
                if (this.isUltimoDiaUtilAno(this.iPrice) && this.pFimUtil) || (this.isUltimoDiaAno(this.iPrice) && ~this.pFimUtil) 
                    this.ano=this.ano+1;
                    this.MtM_FimDoAno(this.ano, :) = this.price(this.iPrice, :);
                    this.JurosAcumulados_FimDoAno(this.ano, :) = this.acumulado_sem_reset(this.iPrice, :);
                    this.Datas_FimDoAno(this.ano)=this.datas(this.iPrice);                    
                end

            % Se é dia livre
            else

                % Se é dia de pagamento de juros, prorroga pagamento de 
                % juros para amanhã
                if diaAtual == this.dateJuros(this.iDateJuros)
                    this.dateJuros(this.iDateJuros) = this.dateJuros(this.iDateJuros) + 1;
                end
                
                % Se é dia de pagamento de amortização, prorroga pagamento
                % de amortização para amanhã
                if diaAtual == this.amortizacao(this.iAmortizacao, 1)
                    this.amortizacao(this.iAmortizacao, 1) = this.amortizacao(this.iAmortizacao, 1) + 1;
                end
                
                % Se pAP == 1 e pDUL == 0
                if this.pAP && ~ this.pDUL
                    this.iCDI = this.iCDI + 1;
                    this.calculatePrice();
                    this.pDUL = 1;
                    
                % Se não é, repete os dados do dia anterior
                else
                    this.holdData();
                end              
                
                if this.isUltimoDiaMes(this.iPrice) && ~this.pFimUtil
                    this.mes=this.mes+1;
                    this.MtM_FimDoMes(this.mes, :) = this.price(this.iPrice, :);
                    this.JurosAcumulados_FimDoMes(this.mes, :) = this.acumulado_sem_reset(this.iPrice, :);
                    this.Datas_FimDoMes(this.mes)=this.datas(this.iPrice);
                end
                if this.isUltimoDiaAno(this.iPrice) && ~this.pFimUtil
                    this.ano=this.ano+1;
                    this.MtM_FimDoAno(this.ano, :) = this.price(this.iPrice, :);
                    this.JurosAcumulados_FimDoAno(this.ano, :) = this.acumulado_sem_reset(this.iPrice, :);
                    this.Datas_FimDoAno(this.ano)=this.datas(this.iPrice);            
                end

            end

            if ~ this.pAP
            
                if this.datas(this.iPrice) ~= this.dateFinal && this.vetorDiasUteis(this.iPrice + 1) % ruivo_30/09/2013
                    this.iCDI = this.iCDI + 1;
                end
            else
                if this.datas(this.iPrice) ~= this.dateFinal && this.vetorDiasUteis(this.iPrice + 1) && ~ this.pDUL % ruivo_30/09/2013
                    this.iCDI = this.iCDI + 1;
                end
            end
            
            this.iPrice = this.iPrice + 1;
        
        end        
        
        function calculatePrice(this)
            this.cdiDiario(this.iPrice,:) = roundn((1 + this.cdi(this.iCDI,:)).^(1/252) -1, -8); % ruivo_01/10/2013
                
            this.cdiAcumulado(this.iPrice,:) = floor((1 + this.cdiDiario(this.iPrice,:)) .* this.cdiAcumulado(this.iPrice - 1,:) * 1e16) / 1e16; % ruivo_01/10/2013

            this.spreadAcumulado(this.iPrice,1) = (1 + this.spread) * this.spreadAcumulado(this.iPrice - 1,1); % ruivo_01/10/2013

            this.cdiMaisSpread(this.iPrice,:) = (roundn(roundn(this.cdiAcumulado(this.iPrice,:), -8) * roundn(this.spreadAcumulado(this.iPrice,1), -9), -9)); % ruivo_01/10/2013

%             this.interest = vpi(num2str((this.cdiMaisSpread(this.iPrice,:) - 1) * 1e9)) * vpi(num2str(this.nominal * 1e2));
%             interestStr = ['00000' strtrim(num2str(this.interest))];
%             interestStr = interestStr(1 : end - 5);
%             this.interest = str2double(interestStr) / 1e6;   
            this.interest = (this.cdiMaisSpread(this.iPrice,:) - 1) * (this.nominal);
              
            this.acumulado(this.iPrice,:) = this.interest;  % ruivo_30/09/2013
              
            this.acumulado_sem_reset(this.iPrice, :) = this.acumulado(this.iPrice, :) + this.acumulado_ate_juros;
               
            this.price(this.iPrice, :) = this.interest + this.nominal;
        end
        
        function payInterest(this)
            this.cdiAcumulado(this.iPrice,:) = 1; % ruivo_01/10/2013
            this.spreadAcumulado(this.iPrice,1) = 1; % ruivo_01/10/2013
            this.juros(this.iDateJuros, :) = this.interest;%this.price(this.iPrice, 1) - this.nominal;
            this.price(this.iPrice, :) = this.nominal;
            this.iDateJuros = this.iDateJuros + 1;
            this.acumulado_ate_juros = this.acumulado_sem_reset(this.iPrice, :); % ruivo_09/10/2013
            this.acumulado(this.iPrice, 1) = 0; % ruivo_07/10/2013
        end
        
        function payAmortization(this)
            this.nominal = this.nominal - this.amortizacao(this.iAmortizacao, 2);
            this.price(this.iPrice, :) = this.price(this.iPrice, :) - this.amortizacao(this.iAmortizacao, 2); % ruivo_01/10/2013
            this.iAmortizacao = this.iAmortizacao + 1;
        end
        
        function holdData(this)
            this.acumulado(this.iPrice,:) = this.acumulado(this.iPrice - 1,:); % ruivo_30/09/2013
            this.acumulado_sem_reset(this.iPrice,:) = this.acumulado_sem_reset(this.iPrice - 1,:); % ruivo_09/10/2013
            this.price(this.iPrice, :) = this.price(this.iPrice - 1, :);    
            this.cdiAcumulado(this.iPrice, :) = this.cdiAcumulado(this.iPrice - 1, :); % ruivo_01/10/2013
            this.spreadAcumulado(this.iPrice, 1) = this.spreadAcumulado(this.iPrice - 1, 1); % ruivo_01/10/2013
        end
        
        
        function booleanOut = f_isUltimoDiaUtilMes(this) % sergio 17/10/2013
            % Verifica se hoje é o último dia útil do mês            
            if this.vetorDiasUteis(this.iPrice)              
                diaAtual = this.datas(this.iPrice);
                DiasAteProximoDiaUtil = find(this.vetorDiasUteis(this.iPrice+1:end)==1,1,'first'); % retorna o 1o dia util entre amanhã e o fim
                proximoDiaUtil=this.datas(this.iPrice+DiasAteProximoDiaUtil);             
                if month(proximoDiaUtil)~=month(diaAtual)
                    booleanOut=1;
                else
                    booleanOut=0;
                end            
            else
                booleanOut=0;
            end
            
        end
        
        function booleanOut = f_isUltimoDiaUtilAno(this) % sergio 17/10/2013
            % Verifica se hoje é o último dia útil do mês          
            if this.vetorDiasUteis(this.iPrice)              
                diaAtual = this.datas(this.iPrice);
                DiasAteProximoDiaUtil = find(this.vetorDiasUteis(this.iPrice+1:end)==1,1,'first'); % retorna o 1o dia util entre amanhã e o fim
                proximoDiaUtil=this.datas(this.iPrice+DiasAteProximoDiaUtil);           
                if year(proximoDiaUtil) ~= year(diaAtual)
                    booleanOut=1;
                else
                    booleanOut=0;
                end               
            else
                booleanOut=0;
            end  
        end

        function booleanOut = f_isUltimoDiaMes(this) % Verifica se é o último dia do mês
            esteMes = month(this.datas(this.iPrice));
            esteAno = year(this.datas(this.iPrice));
            esteDia = day(this.datas(this.iPrice));
            ultimoDia = eomday(esteAno, esteMes);
            booleanOut = ultimoDia == esteDia;
        end

        function booleanOut = f_isUltimoDiaAno(this) % Verifica se é o último dia do ano
            esteMes = month(this.datas(this.iPrice));
            esteDia = day(this.datas(this.iPrice));
            booleanOut = (esteMes == 12) & (esteDia == 31);
        end
        
        function inicialize(this)
            
            % tam = size(this.datas, 1) - (this.iPrice - 1);
            
            % this.mes=0;
            % this.ano=0;
            
            % this.price = zeros(tam, this.n_cenarios);
            % this.price(1 : this.iPrice - 1, :) = this.nominal;
            
            % this.acumulado = zeros(tam,this.n_cenarios); % ruivo_30/09/2013
            % this.acumulado(1 : this.iPrice - 1, :) = 0; % ruivo_30/09/2013
            
            % this.acumulado_sem_reset = zeros(tam,this.n_cenarios); % ruivo_30/09/2013
            % this.acumulado_sem_reset(1 : this.iPrice - 1, :) = 0; % ruivo_30/09/2013
            
            % this.cdiMaisSpread = zeros(tam,this.n_cenarios); % ruivo_01/10/2013
            % this.cdiMaisSpread(1 : this.iPrice - 1, :) = 1; % ruivo_01/10/2013
            
            % this.cdiAcumulado = zeros(tam,this.n_cenarios); % ruivo_01/10/2013
            % this.cdiAcumulado(1 : this.iPrice - 1, :) = 1; % ruivo_01/10/2013
            
            % this.spreadAcumulado = zeros(tam,1); % ruivo_01/10/2013
            % this.spreadAcumulado(1 : this.iPrice - 1, 1) = 1; % ruivo_01/10/2013
            
            % this.acumulado_ate_juros = 0;

            this.tam = size(this.datas, 1) - (this.iPrice - 1);
            
            this.cdiDiario = zeros(this.tam,this.n_cenarios); % ruivo_01/10/2013
            
            this.mes=0;
            this.ano=0;
            
            this.price(1 : this.iPrice - 1, 1:this.n_cenarios) = this.nominal;
            
            this.acumulado(1 : this.iPrice - 1, 1:this.n_cenarios) = 0; % ruivo_30/09/2013
            
            this.acumulado_sem_reset(1 : this.iPrice - 1, 1:this.n_cenarios) = 0; % ruivo_30/09/2013
            
            this.cdiMaisSpread(1 : this.iPrice - 1, 1:this.n_cenarios) = 1; % ruivo_01/10/2013
            
            this.cdiAcumulado(1 : this.iPrice - 1, 1:this.n_cenarios) = 1; % ruivo_01/10/2013
            
            this.spreadAcumulado(1 : this.iPrice - 1, 1) = 1; % ruivo_01/10/2013
            
%             this.cdiDiario(1 : this.iPrice - 1, 1:this.n_cenarios) = 0; % ruivo_01/10/2013
            
            this.acumulado_ate_juros = 0;
            
        end
        
    end
    
    methods

        function this = DebentureManager(cdi, spread, nominal, dateJuros, amortizacao, dateEmissao, dateFinal, pPremioPrePagamento, pPremioReducaoCapital, dateReducaoCapital, ...
                pCustoEmissao, pTaxaCETIP, valorCustoMensal, valorCustoSemestral, valorCustoAnual, isDiaUtil, n_cenarios, pAP, pFimUtil)
            
            this.tipo = 'CDI'; % ruivo_10/10/2013
            
            this.pAP = pAP;
            this.pFimUtil = pFimUtil;
            
            % Premios
            this.pPremioPrePagamento = pPremioPrePagamento;
            this.pPremioReducaoCapital = pPremioReducaoCapital;
            this.dateReducaoCapital = dateReducaoCapital;
            
            % Custos
            this.pCustoEmissao = pCustoEmissao;
            this.pTaxaCETIP = pTaxaCETIP;
            this.valorCustoMensal = valorCustoMensal;
            this.valorCustoSemestral = valorCustoSemestral;
            this.valorCustoAnual = valorCustoAnual;

            this.cdi = cdi; % ruivo_04/10/2013
            this.spread = (1 + spread)^(1/252) - 1;
            this.nominal = nominal;
            this.nominalInicial = nominal;
            this.dateJuros = dateJuros;
            this.amortizacao = amortizacao;
            this.dateEmissao = dateEmissao;
            this.dateEmissao_util = dateEmissao;
            this.dateFinal = dateFinal;
            this.dateFinal_util = this.dateFinal;
            this.juros = zeros(size(dateJuros, 1), n_cenarios); % ruivo_01/10/2013
            
            this.isDiaUtil = isDiaUtil;

            this.iDateJuros = 1;
            this.iAmortizacao = 1;
            
            iDiasUteis_i = find(isDiaUtil(1, :) == this.dateEmissao, 1); % ruivo_04/10/2013
            iDiasUteis_f = find(isDiaUtil(1, :) == this.dateFinal, 1); % ruivo_04/10/2013
            vetorDiasUteis_aux = isDiaUtil(2, iDiasUteis_i : iDiasUteis_f); % ruivo_04/10/2013
            
            this.datas = (this.dateEmissao : this.dateFinal)';  
            
            datasChecagemErros = this.datas;
            
            % remove finais de semana e feriados da matriz de CDI
            filtroDiasLivres = find(vetorDiasUteis_aux' == 0);
            this.cdi(filtroDiasLivres, :) = [];
                      
%             this.cdi = bsxfun(@times, this.cdi, vetorDiasUteis_aux'); % ruivo_10/10/2013          
%             this.cdi = this.cdi(this.cdi ~= 0);           
%             numCDI = length(this.cdi) / n_cenarios;         
%             this.cdi = reshape(this.cdi(this.cdi ~= 0), [numCDI n_cenarios]); % ruivo_04/10/2013

            % Checagem de erros na matriz de CDI
            if size(this.cdi(this.cdi ~= 0), 1) ~= sum(vetorDiasUteis_aux)
                filtroChecagemErros = find(vetorDiasUteis_aux');
                datasChecagemErros = datasChecagemErros(filtroChecagemErros);       
                
                filtroChecagemErros = find(this.cdi(:, 1) <= 0);
                datasChecagemErros = datasChecagemErros(filtroChecagemErros);
                datasChecagemErros = sort(unique(datasChecagemErros));
                
                mensagemJanela = 'Os seguintes dias úteis possuem CDIs nulos ou negativos:';
                
                for i = 1 : length(datasChecagemErros)
                     mensagemJanela = [mensagemJanela ' ' datestr(datasChecagemErros(i), 'dd/mm/yyyy') ';'];
                end
                
                mensagemJanela = [mensagemJanela '. Continuar mesmo assim?'];
                
                resposta = questdlg(mensagemJanela,'Atenção','Sim','Nao','Sim');
                
                if strcmp(resposta,'Nao')
                    quit;
                end
            end
            
            while ~isDiaUtil(2,isDiaUtil(1,:) == this.dateFinal_util)
                this.dateFinal_util = this.dateFinal_util + 1;
            end
            this.dateFinal = this.dateFinal_util;

            this.iPrice = 2;
            
            while ~isDiaUtil(2,isDiaUtil(1,:) == this.dateEmissao_util)
                this.dateEmissao_util = this.dateEmissao_util + 1;
                this.iPrice = this.iPrice + 1;
            end
            
            this.datas = (this.dateEmissao : this.dateFinal)'; 
            
            this.iCDI = 1;
            
            iDiasUteis_f = find(isDiaUtil(1, :) == this.dateFinal, 1); % ruivo_03/10/2013
            this.vetorDiasUteis = isDiaUtil(2, iDiasUteis_i : iDiasUteis_f); % ruivo_03/10/2013
            
            this.n_cenarios = n_cenarios; % ruivo_01/10/2013
            
            this.diasUteis(1 : length(this.vetorDiasUteis), 1) = 'U';
            this.diasUteis = this.diasUteis .* this.vetorDiasUteis';
            this.diasUteis(this.diasUteis == 0) = 'F';
            this.diasUteis = char(this.diasUteis);
            
            this.pDUL = 0;

        end
        
        function generateNotEveryThing(this, tam)
            this.price = zeros(tam, 1);
            this.price(1,1) = this.nominal;
            for i = 1 : tam
                this.priceDiario();
            end
        end

        function stepCalculate(this, dias)

            for k = 1 : dias
                this.priceDiario();
            end

        end

        function generate(this)
            
            this.inicialize();
            
            for i = 1 : this.tam
                this.priceDiario();
            end
            
            if this.pFimUtil
                lastDayMes = find(this.isDiaUtil(2, (month(this.dateFinal) == month(this.isDiaUtil(1,:))) & (year(this.dateFinal) == year(this.isDiaUtil(1,:)))),1,'last');
                lastDayAno = find(this.isDiaUtil(2, (month(this.isDiaUtil(1,:)) == 12) & (year(this.dateFinal) == year(this.isDiaUtil(1,:)))),1,'last');
            else
                lastDayMes = day(eomdate(this.dateFinal));
                lastDayAno = 31;
            end
            
            if (day(this.dateFinal_util) ~= lastDayMes && this.pFimUtil) || (this.dateFinal ~= lastDayMes && ~this.pFimUtil)
                
                this.mes=this.mes+1;
                
                this.MtM_FimDoMes(this.mes, :) = this.price(end, :);
                this.JurosAcumulados_FimDoMes(this.mes, :) = this.acumulado_sem_reset(end, :);
                
                this.Datas_FimDoMes(this.mes)=datenum([num2str(lastDayMes) '/' num2str(month(this.dateFinal)) '/' num2str(year(this.dateFinal))],'dd/mm/yyyy');
            
            end
            
            if (this.dateFinal_util ~= datenum([num2str(lastDayAno) '/12/' num2str(year(this.dateFinal))],'dd/mm/yyyy') && this.pFimUtil) || (~(month(this.dateFinal) == 12 && day(this.dateFinal) == 31)  && ~this.pFimUtil)
                
                this.ano=this.ano+1;
                
                this.MtM_FimDoAno(this.ano, :) = this.price(end, :);
                this.JurosAcumulados_FimDoAno(this.ano, :) = this.acumulado_sem_reset(end, :);
                
                this.Datas_FimDoAno(this.ano)=datenum([num2str(lastDayAno) '/12/' num2str(year(this.dateFinal))],'dd/mm/yyyy');
            
            end
                
            this.PnL_FimDoMes = [this.JurosAcumulados_FimDoMes(1, :)' diff(this.JurosAcumulados_FimDoMes,1,1)']';
            this.PnL_FimDoAno = [this.JurosAcumulados_FimDoAno(1, :)' diff(this.JurosAcumulados_FimDoAno,1,1)']';
            
        end

    end
    
end

