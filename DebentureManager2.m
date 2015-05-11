classdef DebentureManager2 < handle
    %DEBENTUREMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        
        % Para cada cenário:
        
        ipca % IPCA para cada dia
        taxaJuros % taxa diária de juros
        nominal % valor nominal da debênture
        nominalInicial % valor nominal da debênture
        juros % juros acumulado a pagar
        correcaoPaga % correção acumulada a pagar
        dateEmissao % Dia de Emissão da debênture
        dateEmissao_util % Dia de Emissão útil da debênture
        n_cenarios % número de cenários
        pPremioPrePagamento % Porcentagem do saldo a ser pago como premio para pre-pagamento da dívida (pagamento na data final da debenture)
        pPremioReducaoCapital % Porcentagem do saldo a ser pago como premio para reduzir o capital social (pagamento na data da redução)
        dateReducaoCapital % Data da redução de Capital Social
        pCustoEmissao % Porcentagem sobre o valor nominal de custo de emissão (pagamento na emissão)
        pTaxaCETIP % Porcentagem mensal sobre o saldo a ser pago como custo de manutanção (mensal)
        valorCustoMensal % Valor a ser pago como custo de manutanção (mensal)
        valorCustoSemestral % Valor a ser pago como custo de manutanção (semestral) DRE rateado ao longo do semestre
        valorCustoAnual % Valor a ser pago como custo de manutanção (anual) DRE rateado ao longo do ano
        
        dateFinal_util
        ipcaAcumulado % índice de IPCA acumulado
        ipcaAcumuladoTruncado % índice de IPCA acumulado truncado
        ipcaDiario % índice de IPCA diário
        taxajurosAPagarAcumulado % índice de taxa de juros acumulado
        ipcaAcumuladoAteUltimoAniversario % índice de IPCA acumulado até o ultimo aniversário da debênture
        ipcaAtual % IPCA desse mês
        ipcaAnterior % IPCA do mês passado
        ipcaMonth % IPCA Atual / IPCA Anterior
        
        correcaoAPagarAcumulada % valor da correção para cada dia de 'datas'
        correcaoAPagarAcumulada_sem_reset % valor da correção para cada dia de 'datas' sem reset nos dias de pagamento de correção
        correcaoTotalPaga % valor da correção acumulada até dia de pagamento de amortização
        NV_IPCA % valor de correção monetária + nominal para cada dia de 'datas'
        jurosAPagarAcumulado % valor do juros acumulado para cada dia de 'datas'
        jurosAPagarAcumulado_sem_reset % valor do juros acumulado para cada dia de 'datas' sem reset nos dias de pagamento de juros
        jurosAcumulado_ate_juros % valor do juros acumulado até data de pagamento de juros
        diasUteis % vetor com 'U' para dias úteis e 'F' para dias livres e feriados, para cada dia de 'datas' 
        
        dateJuros % vetor com dias de pagamento de juros
        amortizacao % matriz com dias e valores de amortização
        price % vetor com o valor do price para cada dia de 'datas'
        interest % vetor com o valor do interest para cada dia de 'datas'
        datas % vetor com todas as datas desde 'dateEmissao' até 'dateFinal'
        vetorDiasUteis % vetor com classificação dos dias em úteis ou livres
        dateFinal % Dia Final útil da Debênture
        vetorUltimoDiaUtilMes % Vetor com as datas dos últimos dias úteis de cada mês
        vetorUltimoDiaUtilAno % Vetor com as datas dos últimos dias úteis de cada ano
        iUltimoDiaUtilMes
        iUltimoDiaUtilAno

        
        MtM_FimDoMes % vetor de zeros, exceto no final do mês, em que é o Price
        PnL_Mensal_Acumulado_Juros
        PnL_Mensal_Acumulado_Correcao
        PnL_Anual_Acumulado_Juros
        PnL_Anual_Acumulado_Correcao
        PnL_Juros_FimDoMes % vetor de zeros, exceto no final do mês, em que é o Juros acumulados
        PnL_Correcao_FimDoMes % vetor de zeros, exceto no final do mês, em que é a Correção Monetária acumulada
        JurosAcumulados_FimDoMes % vetor de valores de Juros acumulados até mês no fim de cada mês 
        CorrecaoAcumulada_FimDoMes % vetor de valores de Correcao acumulados até mês no fim de cada mês 
        MtM_FimDoAno % vetor de zeros, exceto no final do ano, em que é o Price
        PnL_Juros_FimDoAno % vetor de zeros, exceto no final do ano, em que é o Juros acumulados
        PnL_Correcao_FimDoAno % vetor de zeros, exceto no final do ano, em que é a Correção Monetária acumulada
        JurosAcumulados_FimDoAno % vetor de valores de Juros acumulados até mês no fim de cada ano 
        CorrecaoAcumulada_FimDoAno % vetor de valores de Correcao acumulados até mês no fim de cada ano 
        Datas_FimDoMes % vetor de datas de fim do mes
        Datas_FimDoAno % vetor de datas de fim do ano

        iDateJuros % índice do vetor de datas de pagamento de juros
        iAmortizacao % índice do vetor de amortização
        iPrice % índice do vetor do Price
        iIPCA % índice do vetor do IPCA
        iDateAniversario % índice do vetor de datas de aniversário
        iNDiasUteis % índice do vetor de dias úteis do mês
%         iReducao % índice do vetor de reduções de capital
        
        mes % mês relativo ao início da debenture
        ano % ano relativo ao início da debênture
        diaUtilMes % contador de dias úteis do mês
        mesAtual % mês de dateAtual
        
        nDiasUteisMes % número de dias úteis do mês

        isDiaUtil
        nextDiaUtil % próximo dia útil em relação ao dia atual
        
        tipo % tipo da debênture (CDI, IPCA, ...)
        
        pAP % parâmetro de atualização do price aos dias livres
        
        % pDUL é 1 para o primeio dia útil de uma sequência de dias úteis
        % pDUL é 0 para o primeiro dia livre de uma sequência de dias
        % livres       
        pDUL 
        
        pCM % parâmetro de contagem do número de dias úteis do mês
        
        datasAniversario % vetor com as data de aniversário de cada debênture    

        pAIPCA % parâmetro de atualização do IPCA (antes ou após o cálculo do price)
        
        pUIPCA % parâmetro de update do IPCA
        
        NumeroDebentures % Número de debentures
        
        nCIPCAM % número de casas do IPCA Month
        nCDI % número de casas do Daily Index
        nCAccI % número de casas do Accumulated Index
        nCNVIPCA % número de casas do NV + IPCA
        nCID % número de casas do Interest (Daily)
        nCIAcc % número de casas do Interest (Accumulated)
        nCI % número de casas do Interest
        nCP % número de casas do Price
        nCN % número de casas do Nominal
        
        
        
    end
    
    methods (Static)
        function truncado = truncar(value, n)
            truncado = fix(double(value) * 10^n) / 10^n;
        end
    end

    methods (Access = private)

        function priceDiario(this)
            dateAtual = this.datas(this.iPrice);
                     
%             if dateAtual == datenum('18/07/2021', 'dd/mm/yyyy')
%                 disp('hi');
%             end

            % Se é dia útil
            if this.vetorDiasUteis(this.iPrice) % ruivo_02/10/2013
                
                if ~ this.pAIPCA
                     % Se pAP == 1 e pDUL == 1
                    if this.pAP && this.pDUL
                        this.holdData();
                        this.pDUL = 0;
                    else
                        % Calcula o price para o dia atual
                        this.calculatePrice();
                    end
                    
                    % Se é dia de aniversário, passa a apontar o número de dias
                    % úteis do próximo mês e zera o contador de dias úteis para
                    % o próximo dia
                    if (dateAtual == this.datasAniversario(this.iDateAniversario))
                        this.ipcaAcumuladoAteUltimoAniversario = this.ipcaAcumuladoTruncado(this.iPrice, :);
                        this.iNDiasUteis = this.iNDiasUteis + 1;
                        this.iDateAniversario = this.iDateAniversario + 1;
                        if this.pUIPCA
                            this.diaUtilMes = 0;
                        end
                    end
                    
                    
                end
                
                % Se é dia de atualizar o IPCA, atualiza o IPCA
                if dateAtual == this.ipca(this.iIPCA, 1)
                    
                    %POG POG POG POG POG POG POG
                    if dateAtual == this.ipca(end,1)
                        this.iNDiasUteis = this.iNDiasUteis - 1;
                    end
                    %POG POG POG POG POG POG POG
                    
                    this.updateIPCA();
                    
                % Se não é, mantém o IPCA diário do dia anterior
                else
                    this.ipcaDiario(this.iPrice, :) = this.ipcaDiario(this.iPrice - 1, :);
                end
                
                if this.pAIPCA
                     % Se pAP == 1 e pDUL == 1
                    if this.pAP && this.pDUL
                        this.holdData();
                        this.pDUL = 0;

                    else
                        % Calcula o price para o dia atual
                        this.calculatePrice(); 
                    end
                    
                    % Se é dia de aniversário, passa a apontar o número de dias
                    % úteis do próximo mês e zera o contador de dias úteis para
                    % o próximo dia
                    if (dateAtual == this.datasAniversario(this.iDateAniversario))
                        this.ipcaAcumuladoAteUltimoAniversario = this.ipcaAcumuladoTruncado(this.iPrice, :);
                        this.iNDiasUteis = this.iNDiasUteis + 1;
                        this.iDateAniversario = this.iDateAniversario + 1;
                        if this.pUIPCA 
                            this.diaUtilMes = 0;
                        end
                    end

                    
                end
                

                % Se é dia de pagamento de amortização, paga amortização
                if dateAtual == this.amortizacao(this.iAmortizacao, 1)
                    this.payAmortization();       
                end
                
                % Se é dia de pagamento de juros, paga juros
                if dateAtual == this.dateJuros(this.iDateJuros)
                    this.payInterest();
                end
                
                % Se é último dia útil do mês, armazena dados para a DRE
                % mensal
                if f_isUltimoDiaUtilMes(this)

                    this.mes = this.mes + 1;
                    
                    if this.mes == 1
                        this.PnL_Juros_FimDoMes(this.mes,:) = this.jurosAPagarAcumulado_sem_reset(this.iPrice, :);
                        this.PnL_Correcao_FimDoMes(this.mes,:) = this.correcaoAPagarAcumulada_sem_reset(this.iPrice, :);
                        this.PnL_Mensal_Acumulado_Juros(this.mes,:) = this.PnL_Juros_FimDoMes(this.mes,:);
                        this.PnL_Mensal_Acumulado_Correcao(this.mes,:) = this.PnL_Correcao_FimDoMes(this.mes,:);
                    else
                        this.PnL_Juros_FimDoMes(this.mes,:) = this.jurosAPagarAcumulado_sem_reset(this.iPrice, :) - this.PnL_Mensal_Acumulado_Juros(this.mes-1,:);
                        this.PnL_Correcao_FimDoMes(this.mes,:) = this.correcaoAPagarAcumulada_sem_reset(this.iPrice, :) - this.PnL_Mensal_Acumulado_Correcao(this.mes-1,:);
                        this.PnL_Mensal_Acumulado_Juros(this.mes,:) = this.PnL_Mensal_Acumulado_Juros(this.mes-1,:) + this.PnL_Juros_FimDoMes(this.mes,:);
                        this.PnL_Mensal_Acumulado_Correcao(this.mes,:) = this.PnL_Mensal_Acumulado_Correcao(this.mes-1,:) + this.PnL_Correcao_FimDoMes(this.mes,:);
                    end
                    
                    this.MtM_FimDoMes(this.mes,:) = this.price(this.iPrice,:);
                    this.Datas_FimDoMes(this.mes)=this.datas(this.iPrice);
                    
                end
                
                % Se é último dia do ano, armazena dados para a DRE anual
                if f_isUltimoDiaUtilAno(this)
                    
                    this.ano = this.ano + 1;
                    
                    if this.ano == 1
                        this.PnL_Juros_FimDoAno(this.ano,:) = this.jurosAPagarAcumulado_sem_reset(this.iPrice, :);
                        this.PnL_Correcao_FimDoAno(this.ano,:) = this.correcaoAPagarAcumulada_sem_reset(this.iPrice, :);
                        this.PnL_Anual_Acumulado_Juros(this.ano,:) = this.PnL_Juros_FimDoAno(this.ano,:);
                        this.PnL_Anual_Acumulado_Correcao(this.ano,:) = this.PnL_Correcao_FimDoAno(this.ano,:);
                    else
                        this.PnL_Juros_FimDoAno(this.ano,:) = this.jurosAPagarAcumulado_sem_reset(this.iPrice, :) - this.PnL_Anual_Acumulado_Juros(this.ano-1,:);
                        this.PnL_Correcao_FimDoAno(this.ano,:) = this.correcaoAPagarAcumulada_sem_reset(this.iPrice, :) - this.PnL_Anual_Acumulado_Correcao(this.ano-1,:);
                        this.PnL_Anual_Acumulado_Juros(this.ano,:) = this.PnL_Anual_Acumulado_Juros(this.ano-1,:) + this.PnL_Juros_FimDoAno(this.ano,:);
                        this.PnL_Anual_Acumulado_Correcao(this.ano,:) = this.PnL_Anual_Acumulado_Correcao(this.ano-1,:) + this.PnL_Correcao_FimDoAno(this.ano,:);
                    end
                    
                    
                    this.MtM_FimDoAno(this.ano, :) = this.price(this.iPrice, :);
                    this.Datas_FimDoAno(this.ano)=this.datas(this.iPrice);
                end
                          
            % Se é dia livre    
            else
                % Se é dia de pagamento de juros, prorroga pagamento de 
                % juros para amanhã
                if dateAtual == this.dateJuros(this.iDateJuros)
                    this.dateJuros(this.iDateJuros) = this.dateJuros(this.iDateJuros) + 1;
                end
                
                % Se é dia de pagamento de amortização, prorroga pagamento 
                % de amortização para amanhã 
                if dateAtual == this.amortizacao(this.iAmortizacao, 1)
                    this.amortizacao(this.iAmortizacao, 1) = this.amortizacao(this.iAmortizacao, 1) + 1;
                end
                
                % Se é dia de atualização de IPCA, prorroga a atualização
                % de IPCA para amanhã
                if dateAtual == this.ipca(this.iIPCA, 1)
                    this.ipca(this.iIPCA, 1) = this.ipca(this.iIPCA, 1) + 1;
                end
                
                % Se pAP == 1 e pDUL == 0
                if this.pAP && ~ this.pDUL
                    this.calculatePrice();
                    this.pDUL = 1;
                    this.ipcaDiario(this.iPrice, :) = this.ipcaDiario(this.iPrice - 1, :);
                    
                % Se não é, repete os dados do dia anterior
                else
                    this.holdData();
                end     

            end
            this.iPrice = this.iPrice + 1;
        end
        
        function calculatePrice(this)
            
            % Se a atualização do price for retroativa
            if this.pUIPCA
                this.diaUtilMes = this.diaUtilMes + 1;
%                 if this.iNDiasUteis == 287
%                     disp('aqui');
%                 end
                this.ipcaAcumulado(this.iPrice, :) = DebentureManager2.truncar(this.ipcaMonth .^ (this.diaUtilMes / this.nDiasUteisMes(this.iNDiasUteis, 1)) .* this.ipcaAcumuladoAteUltimoAniversario, this.nCDI);
%                 this.ipcaAcumulado(this.iPrice, :) = DebentureManager2.truncar(sym(num2str(this.ipcaMonth .^ (this.diaUtilMes / this.nDiasUteisMes(this.iNDiasUteis, 1)), '%.16f')) .*  sym(num2str(this.ipcaAcumuladoAteUltimoAniversario, '%.16f')), this.nCDI);
            % Se a atualização do price for acumulada diariamente
            else
                this.ipcaAcumulado(this.iPrice, :) = DebentureManager2.truncar((this.ipcaDiario(this.iPrice - 1, :)) .* this.ipcaAcumulado(this.iPrice - 1, :), this.nCDI);    
%                 this.ipcaAcumulado(this.iPrice, :) = DebentureManager2.truncar(sym(num2str((this.ipcaDiario(this.iPrice - 1, :)), '%.16f')) .*  sym(num2str(this.ipcaAcumulado(this.iPrice - 1, :), '%.16f')), this.nCDI);     
            end        
            
            % IPCA acumulado truncado
            this.ipcaAcumuladoTruncado(this.iPrice, :) = DebentureManager2.truncar(this.ipcaAcumulado(this.iPrice, :), this.nCAccI); 
            
            this.taxajurosAPagarAcumulado(this.iPrice, :) = DebentureManager2.truncar(roundn(1 + this.taxaJuros, -1 * (this.nCID)) * this.taxajurosAPagarAcumulado(this.iPrice - 1, :), this.nCIAcc);
%             this.taxajurosAPagarAcumulado(this.iPrice, :) = DebentureManager2.truncar(sym(num2str(roundn(1 + this.taxaJuros, -1 * (this.nCID)), '%.9f')) * sym(num2str(this.taxajurosAPagarAcumulado(this.iPrice - 1, :), '%.9f')), this.nCIAcc);

            this.NV_IPCA(this.iPrice, :) = DebentureManager2.truncar(this.nominal * this.ipcaAcumuladoTruncado(this.iPrice, :), this.nCNVIPCA);
%             this.NV_IPCA(this.iPrice, :) = sym(num2str(this.nominal, ['%.' num2str(this.nCN) 'f'])) * sym(num2str(this.ipcaAcumuladoTruncado(this.iPrice, :), ['%.' num2str(this.nCAccI) 'f']));
%             this.NV_IPCA(this.iPrice, :) = (vpi(num2str(this.nominal * 10 ^ this.nCN)) * vpi(num2str(this.ipcaAcumuladoTruncado(this.iPrice, :)' * 10 ^ this.nCAccI)))'; % ruivo_02/10/2013
            
            this.correcaoAPagarAcumulada(this.iPrice, :) = DebentureManager2.truncar(this.NV_IPCA(this.iPrice, :) - this.nominal, this.nCNVIPCA);
%             this.correcaoAPagarAcumulada(this.iPrice, :) = this.NV_IPCA(this.iPrice, :) - sym(num2str(this.nominal, ['%.' num2str(this.nCN) 'f']));
%             this.correcaoAPagarAcumulada(this.iPrice, :) = this.NV_IPCA(this.iPrice, :) - (vpi(num2str(this.nominal)) * vpi(10 ^ (this.nCN + this.nCAccI)));

%             NV_IPCAStr = [repmat('0000', this.n_cenarios, 1) strtrim(num2str(this.NV_IPCA(this.iPrice, :)'))];
%             NV_IPCAStr = NV_IPCAStr(:, 1 : end - (this.nCN + this.nCAccI - this.nCNVIPCA));
%             this.NV_IPCA(this.iPrice, :) = str2double(NV_IPCAStr)' / (10 ^ this.nCNVIPCA);
% 
%             correcaoAPagarAcumuladaStr = num2str(this.correcaoAPagarAcumulada(this.iPrice, :));
%             correcaoAPagarAcumuladaStr = correcaoAPagarAcumuladaStr(1 : end - (this.nCN + this.nCAccI - this.nCNVIPCA));            
%             this.correcaoAPagarAcumulada(this.iPrice, :) = str2double(correcaoAPagarAcumuladaStr) / (10 ^ this.nCNVIPCA);
            
            this.correcaoAPagarAcumulada_sem_reset(this.iPrice, :) = this.correcaoAPagarAcumulada(this.iPrice, :) + this.correcaoTotalPaga; % ruivo_09/10/2013
            
            this.interest(this.iPrice, :) = DebentureManager2.truncar((this.taxajurosAPagarAcumulado(this.iPrice, :) - 1) .* this.NV_IPCA(this.iPrice, :), this.nCP); % ruivo_02/10/2013
            
            this.jurosAPagarAcumulado(this.iPrice, :) = this.interest(this.iPrice, :);  % ruivo_04/10/2013
            this.jurosAPagarAcumulado_sem_reset(this.iPrice, :) = this.jurosAPagarAcumulado(this.iPrice, :) + this.jurosAcumulado_ate_juros; % ruivo_09/10/2013
            
            this.price(this.iPrice, :) = this.interest(this.iPrice, :) + this.NV_IPCA(this.iPrice, :); % ruivo_02/10/2013
        end
        
        function payInterest(this)
  
            this.taxajurosAPagarAcumulado(this.iPrice, :) = 1;
            this.juros(this.iDateJuros, :) = this.jurosAPagarAcumulado(this.iPrice, :); % ruivo_02/10/2013
            this.price(this.iPrice, :) = this.NV_IPCA(this.iPrice, :); % ruivo_02/10/2013
            this.iDateJuros = this.iDateJuros + 1;
            this.jurosAcumulado_ate_juros = this.jurosAPagarAcumulado_sem_reset(this.iPrice, :);
            this.jurosAPagarAcumulado(this.iPrice, :) = 0;  % ruivo_04/10/2013
                            
            this.price(this.iPrice, :) = DebentureManager2.truncar(this.price(this.iPrice, :), this.nCP);
            
        end
        
        function payAmortization(this)
           
            atualizacaoMonetaria = this.amortizacao(this.iAmortizacao, 2) * (this.ipcaAcumuladoTruncado(this.iPrice, :) - 1);
            this.NV_IPCA(this.iPrice, :) = this.NV_IPCA(this.iPrice, :) - this.amortizacao(this.iAmortizacao, 2) - atualizacaoMonetaria;
            this.NV_IPCA(this.iPrice, :) = DebentureManager2.truncar(this.NV_IPCA(this.iPrice, :), this.nCP);
            this.correcaoTotalPaga = this.correcaoTotalPaga + atualizacaoMonetaria;
            this.correcaoAPagarAcumulada(this.iPrice, :) = this.correcaoAPagarAcumulada(this.iPrice, :) - atualizacaoMonetaria; % ruivo_14/10/2013
            this.correcaoAPagarAcumulada(this.iPrice, :) = DebentureManager2.truncar( this.correcaoAPagarAcumulada(this.iPrice, :), this.nCNVIPCA);
            this.correcaoPaga(this.iAmortizacao, :) = atualizacaoMonetaria;
            
            this.nominal = this.nominal - this.amortizacao(this.iAmortizacao, 2);

            this.iAmortizacao = this.iAmortizacao + 1;

        end
        
        function updateIPCA(this)
            
            this.ipcaAnterior = this.ipca(this.iIPCA - 1, 2:end);
            this.ipcaAtual = this.ipca(this.iIPCA, 2:end);
            this.ipcaMonth = DebentureManager2.truncar(this.ipcaAtual ./ this.ipcaAnterior, this.nCIPCAM);
            filtro_NaN_inf = isnan(this.ipcaMonth) | isinf(this.ipcaMonth);
            this.ipcaMonth(filtro_NaN_inf) = 0;

            this.ipcaDiario(this.iPrice, :) = DebentureManager2.truncar(this.ipcaMonth.^(1/this.nDiasUteisMes(this.iNDiasUteis, 1)), this.nCDI);
%             this.ipcaDiario(this.iPrice, :) = DebentureManager2.truncar(sym(num2str(this.ipcaMonth.^(1/this.nDiasUteisMes(this.iNDiasUteis, 1)), '%.16f')), this.nCDI);
            this.iIPCA = this.iIPCA + 1;
        end
        
        function holdData(this)
            this.ipcaAcumulado(this.iPrice, :) = this.ipcaAcumulado(this.iPrice - 1, :); % ruivo_02/10/2013
            this.ipcaAcumuladoTruncado(this.iPrice, :) = this.ipcaAcumuladoTruncado(this.iPrice - 1, :); % ruivo_02/10/2013
            this.taxajurosAPagarAcumulado(this.iPrice, :) = this.taxajurosAPagarAcumulado(this.iPrice - 1, :); % ruivo_02/10/2013
            this.NV_IPCA(this.iPrice, :) = this.NV_IPCA(this.iPrice - 1, :); % ruivo_02/10/2013
            this.interest(this.iPrice, :) = this.interest(this.iPrice - 1, :); % ruivo_02/10/2013
            this.ipcaDiario(this.iPrice, :) = this.ipcaDiario(this.iPrice - 1, :);   % ruivo_02/10/2013
            this.jurosAPagarAcumulado(this.iPrice, :) = this.jurosAPagarAcumulado(this.iPrice - 1, :); % ruivo_04/10/2013
            this.correcaoAPagarAcumulada(this.iPrice, :) = this.correcaoAPagarAcumulada(this.iPrice - 1, :); % ruivo_04/10/2013
            this.jurosAPagarAcumulado_sem_reset(this.iPrice, :) = this.jurosAPagarAcumulado_sem_reset(this.iPrice - 1, :); % ruivo_09/10/2013
            this.correcaoAPagarAcumulada_sem_reset(this.iPrice, :) = this.correcaoAPagarAcumulada_sem_reset(this.iPrice - 1, :); % ruivo_09/10/2013
            this.price(this.iPrice, :) = this.price(this.iPrice - 1, :); % ruivo_02/10/2013

        end
        
        function booleanOut = f_isUltimoDiaUtilMes(this) % sergio 19/11/2013
            % Verifica se hoje é o último dia útil do mês            
            
            if this.vetorDiasUteis(this.iPrice)
                dataAtual = this.datas(this.iPrice);
                if dataAtual == this.vetorUltimoDiaUtilMes(this.iUltimoDiaUtilMes)
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

            if this.vetorDiasUteis(this.iPrice)
                dataAtual = this.datas(this.iPrice);
                if dataAtual == this.vetorUltimoDiaUtilAno(this.iUltimoDiaUtilAno)
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

        
        function this = DebentureManager2(ipca, tipo, taxaJuros, nominal, dateJuros, amortizacao, dateEmissao, dateFinal, pPremioPrePagamento, pPremioReducaoCapital, dateReducaoCapital, ...
                pCustoEmissao, pTaxaCETIP, valorCustoMensal, valorCustoSemestral, valorCustoAnual, isDiaUtil, n_cenarios, pAP, pCM, pAIPCA, pUIPCA, nC)
            
            % Tipo da debênture
            this.tipo = tipo;
            
            % Parâmetros da debênture
            this.pAP = pAP;           
            this.pCM = pCM;           
            this.pAIPCA = pAIPCA;      
            this.pUIPCA = pUIPCA;
            
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
            
            % Números de casas decimais da debênture
            this.nCIPCAM = nC(1);
            this.nCDI = nC(2);
            this.nCAccI = nC(3);
            this.nCNVIPCA = nC(4);
            this.nCID = nC(5);
            this.nCIAcc = nC(6);
            this.nCI = nC(7);
            this.nCP = nC(8);
            this.nCN = nC(9);
            
            % Demais parâmetros de entrar
            this.ipca = ipca;
            this.taxaJuros = (1 + taxaJuros)^(1/252) - 1;
            this.nominal = nominal;
            this.nominalInicial = nominal;
            this.dateJuros = dateJuros;
            this.amortizacao = amortizacao;
            this.dateEmissao = dateEmissao;
            this.dateEmissao_util = dateEmissao;
            this.dateFinal = dateFinal; % ruivo_02/10/2013
            this.dateFinal_util = dateFinal; % ruivo_03/10/2013
            this.n_cenarios = n_cenarios; % ruivo_02/10/2013
            this.isDiaUtil = isDiaUtil;    

            % Ínicialização de índices
            this.iDateJuros = 1;
            this.iAmortizacao = 1;
            this.iDateAniversario = 2;
            this.iIPCA = 2;
            this.iPrice = 2;    
            this.iNDiasUteis = 1; 
%             this.iReducao = 1;
            
            this.iUltimoDiaUtilMes = 1;
            this.iUltimoDiaUtilAno = 1;
            
            % Checagem de erros no vetor de IPCA
            datasComIPCAErrado = this.ipca(this.ipca(:, 2) <= 0, 1);     
            if ~ isempty(datasComIPCAErrado)
                mensagemJanela = 'Os seguintes dias úteis possuem IPCAs/IPGMs nulos ou negativos:';            
                for i = 1 : length(datasComIPCAErrado)
                    mensagemJanela = [mensagemJanela ' ' datestr(datasComIPCAErrado(i), 'dd/mm/yyyy') ';'];
                end            
                mensagemJanela = [mensagemJanela '. Continuar mesmo assim?'];                
                resposta = questdlg(mensagemJanela,'Atenção','Sim','Nao','Sim');            
                if strcmp(resposta,'Nao')
                    quit;
                end
            end
            
            % Joga Data Final para o próximo dia útil após a Data Final
            while ~ isDiaUtil(2,isDiaUtil(1,:) == this.dateFinal_util)
                this.dateFinal_util = this.dateFinal_util + 1;
            end
            
            % Vetor de datas vai do dia de emissão à Data Final Útil
            this.datas = (this.dateEmissao : this.dateFinal_util)'; % ruivo_03/10/2013
            
            % Joga Data de Emissão para o próximo dia útil após a Data de
            % Emissão
            while ~ isDiaUtil(2,isDiaUtil(1,:) == this.dateEmissao_util)
                this.dateEmissao_util = this.dateEmissao_util + 1;
                this.iPrice = this.iPrice + 1;
            end

            % Vetor com classificação em dias úteis ou livres, da Data de 
            % Emissão até a Data Final Útil
            iDiasUteis_i = find(isDiaUtil(1, :) == this.dateEmissao, 1); % ruivo_03/10/2013
            iDiasUteis_f = find(isDiaUtil(1, :) == this.dateFinal_util, 1); % ruivo_03/10/2013
            this.vetorDiasUteis = isDiaUtil(2, iDiasUteis_i : iDiasUteis_f); % ruivo_03/10/2013
           
            % Vetor com classificação em dias úteis ou livres, de um 
            % dia após a Data de Emissão até a Data Final Útil
            iDiasUteis_i = find(isDiaUtil(1, :) == this.dateEmissao + 1, 1);
            iDiasUteis_f = find(isDiaUtil(1, :) == this.dateFinal_util, 1);
            vetorDiasUteis_aux = isDiaUtil(2, iDiasUteis_i : iDiasUteis_f); % ruivo_03/10/2013
           
            % A primeira data de aniversário é a Data de Emissão Útil
            this.datasAniversario(1) = this.dateEmissao_util;
            
            % A próxima data de aniversário é, a princípio, a Data de
            % Emissão somada a um mês
            proxDataAniversario = addtodate(dateEmissao, 1, 'month');
            
            % Guarda datas de aniversário
            i = 2;
            while proxDataAniversario <= this.dateFinal_util
                while ~ isDiaUtil(2, isDiaUtil(1,:) == proxDataAniversario)
                    proxDataAniversario = proxDataAniversario + 1;
                end
                this.datasAniversario(i) = proxDataAniversario;
                proxDataAniversario = addtodate(dateEmissao, i, 'month');
                i = i + 1;
            end
            
            this.datasAniversario(i) = this.dateFinal_util;
            
            % Para fins de simulação, a matriz de IPCA deve ter a data de
            % aniversário da debênture que viria após a Data Final
            this.ipca(size(this.ipca, 1) + 1, 1) = this.datasAniversario(end); % ruivo_22/10/2013
            
            % Contagem de dias úteis do mês
            iNDiasUteisMes = 1;
            nDiasUteisMesAtual = 0;
            
            % Se quiser contar o número de dias úteis do mês do calendário
            if this.pCM
                
                anoEmissao = year(dateEmissao);
                mesEmissao = month(dateEmissao);
                anoFinal = year(dateFinal);
                mesFinal = month(dateFinal);
                
                iNDiasUteisMes = 1;
                
                for i = mesEmissao : 12
                    this.nDiasUteisMes(iNDiasUteisMes, 1) = sum(isDiaUtil(2, (month(isDiaUtil(1, :)) == i) & (year(isDiaUtil(1, :)) == anoEmissao)));
                    iNDiasUteisMes = iNDiasUteisMes + 1;
                end
                
                for i = anoEmissao + 1 : anoFinal - 1
                    for j = 1 : 12
                        this.nDiasUteisMes(iNDiasUteisMes, 1) = sum(isDiaUtil(2, (month(isDiaUtil(1, :)) == j) & (year(isDiaUtil(1, :)) == i)));
                        iNDiasUteisMes = iNDiasUteisMes + 1;
                    end
                end
                
                for i = 1 : mesFinal
                    this.nDiasUteisMes(iNDiasUteisMes, 1) = sum(isDiaUtil(2, (month(isDiaUtil(1, :)) == i) & (year(isDiaUtil(1, :)) == anoFinal)));
                    iNDiasUteisMes = iNDiasUteisMes + 1;
                end
                
            % Se quiser contar o número de dias úteis do mês entre
            % aniversários da debênture
            else
                iData = 1; % ruivo_02/10/2013     
                i = 2;
                % Número de dias úteis entre dois aniversários da debênture
                for dateAtual = dateEmissao + 1 : this.dateFinal_util
%                     if dateAtual == datenum(2037,11,30)
%                         disp('aqui');
%                     end
                    if vetorDiasUteis_aux(iData)
                        if dateAtual < this.datasAniversario(i)
                            nDiasUteisMesAtual = nDiasUteisMesAtual + 1;
                        elseif dateAtual == this.datasAniversario(i)
                            nDiasUteisMesAtual = nDiasUteisMesAtual + 1;
                            this.nDiasUteisMes(iNDiasUteisMes, 1) = nDiasUteisMesAtual;
                            nDiasUteisMesAtual = 0;
                            iNDiasUteisMes = iNDiasUteisMes + 1;
                            i = i + 1;
                        end
                    end
                    iData = iData + 1;
                end
            end    
            
            % Date Final da debênture recebe o Date Final Útil
            this.dateFinal = this.dateFinal_util;
            
            % Calcula o IPCA Diário inicial
            this.ipcaAnterior(1, :) = this.ipca(this.iIPCA - 1, 2:end);
            this.ipcaAtual(1, :) = this.ipca(this.iIPCA, 2:end);
            this.ipcaMonth = DebentureManager2.truncar(this.ipcaAtual ./ this.ipcaAnterior, this.nCIPCAM);
            if isnan(this.ipcaMonth) || isinf(this.ipcaMonth)
                this.ipcaMonth = 0;
            end
            tam = size(this.datas, 1) - 1; % ruivo_02/10/2013
%             this.ipcaDiario(this.iPrice - 1, :) = DebentureManager2.truncar(sym(num2str(this.ipcaMonth.^(1/this.nDiasUteisMes(this.iNDiasUteis, 1)), '%.16f')), this.nCDI);
            
            this.iIPCA = this.iIPCA + 1;
            
            % Classifica os dias da debênture em "U" (úteis) ou "F"
            % (livres: finais de semana ou feriados)
            this.diasUteis(1 : length(this.vetorDiasUteis), 1) = 'U';
            this.diasUteis = this.diasUteis .* this.vetorDiasUteis';
            this.diasUteis(this.diasUteis == 0) = 'F';
            this.diasUteis = char(this.diasUteis);
            
            % Price é atualizado no primeiro dia útil
            this.pDUL = 0;
            
            this.mesAtual = month(this.dateEmissao);
            this.diaUtilMes = 0;
            
            cont = 1;
            mesInicial = month(this.dateEmissao);
            anoInicial = year(this.dateEmissao);
            mesFinal = month(this.dateFinal);
            anoFinal = year(this.dateFinal);
            
            this.MtM_FimDoMes=zeros(months(this.dateEmissao,this.dateFinal)+1,this.n_cenarios);
            this.PnL_Juros_FimDoMes=zeros(months(this.dateEmissao,this.dateFinal)+1,this.n_cenarios);
            this.PnL_Correcao_FimDoMes=zeros(months(this.dateEmissao,this.dateFinal)+1,this.n_cenarios);
            
            this.MtM_FimDoAno=zeros(anoFinal-anoInicial+1,this.n_cenarios);
            this.PnL_Juros_FimDoAno=zeros(anoFinal-anoInicial+1,this.n_cenarios);
            this.PnL_Correcao_FimDoAno=zeros(anoFinal-anoInicial+1,this.n_cenarios);
            
            this.PnL_Mensal_Acumulado_Juros = zeros(months(this.dateEmissao,this.dateFinal)+1,this.n_cenarios);
            this.PnL_Mensal_Acumulado_Correcao = zeros(months(this.dateEmissao,this.dateFinal)+1,this.n_cenarios);
            this.PnL_Anual_Acumulado_Juros = zeros(anoFinal-anoInicial+1,this.n_cenarios);
            this.PnL_Anual_Acumulado_Correcao = zeros(anoFinal-anoInicial+1,this.n_cenarios);
            
            y = anoInicial;
            for m = mesInicial : 12
                ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == m) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                this.vetorUltimoDiaUtilMes(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(m) '/' num2str(y)], 'dd/mm/yyyy');
                cont = cont + 1;
            end
            
            for y = (anoInicial + 1) : (anoFinal - 1)
                for m = 1 : 12
                    ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == m) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                    this.vetorUltimoDiaUtilMes(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(m) '/' num2str(y)], 'dd/mm/yyyy');
                    cont = cont + 1;
                end
            end
            
            y = anoFinal;
            for m = 1 : mesFinal
                ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == m) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                this.vetorUltimoDiaUtilMes(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(m) '/' num2str(y)], 'dd/mm/yyyy');
                cont = cont + 1;
            end
            
            cont = 1;
            
            for y = anoInicial : anoFinal
                ultimoDiaUtil = find(this.isDiaUtil(2, (month(this.isDiaUtil(1, :)) == 12) & (year(this.isDiaUtil(1, :)) == y)), 1, 'last');
                this.vetorUltimoDiaUtilAno(cont) = datenum([num2str(ultimoDiaUtil) '/' num2str(12) '/' num2str(y)], 'dd/mm/yyyy');
                cont = cont + 1;
            end
            

            
        end
        
        %
        function generate(this)
            tam = size(this.datas, 1) - (this.iPrice - 1);
            meses = months(this.dateEmissao,this.dateFinal)+1;
            anos = year(this.dateFinal) - year(this.dateEmissao)+1;
            
            % Inicialização
            this.price = zeros(tam, this.n_cenarios);
            this.price(1 : this.iPrice - 1, :) = this.nominal;

            this.mes=0;
            this.ano=0;
            
            this.interest = zeros(tam, this.n_cenarios); % ruivo_02/10/2013
            
            this.NV_IPCA = zeros(tam, this.n_cenarios); % ruivo_02/10/2013
            this.NV_IPCA(1 : this.iPrice - 1, :) = this.nominal; % ruivo_02/10/2013
            
            this.ipcaAcumulado = zeros(tam, this.n_cenarios); % ruivo_02/10/2013
            this.ipcaAcumulado(1 : this.iPrice - 1, :) = 1; % ruivo_02/10/2013
            
            this.juros = zeros(size(this.dateJuros, 1), this.n_cenarios);
            this.ipcaAcumuladoTruncado = zeros(tam, this.n_cenarios); % ruivo_21/10/2013
            this.ipcaAcumuladoTruncado(1 : this.iPrice - 1, :) = 1; % ruivo_21/10/2013
            this.ipcaDiario = zeros(tam, this.n_cenarios); % ruivo_02/10/2013
            this.ipcaDiario(this.iPrice - 1, :) = DebentureManager2.truncar(this.ipcaMonth.^(1/this.nDiasUteisMes(this.iNDiasUteis, 1)), this.nCDI);
            
            this.taxajurosAPagarAcumulado = zeros(tam, this.n_cenarios); % ruivo_02/10/2013
            this.taxajurosAPagarAcumulado(1 : this.iPrice - 1, :) = 1; % ruivo_02/10/2013
            
            this.correcaoAPagarAcumulada = zeros(tam, this.n_cenarios); % ruivo_04/10/2013
            this.jurosAPagarAcumulado = zeros(tam, this.n_cenarios); % ruivo_04/10/2013
            
            this.correcaoAPagarAcumulada_sem_reset = zeros(tam, this.n_cenarios); % ruivo_09/10/2013
            this.jurosAPagarAcumulado_sem_reset = zeros(tam, this.n_cenarios); % ruivo_09/10/2013
            
            this.jurosAcumulado_ate_juros = zeros(1, this.n_cenarios); % ruivo_09/10/2013
            
            this.correcaoPaga = zeros(size(this.amortizacao(:, 1), 1), this.n_cenarios); % ruivo_14/10/2013
            
            this.ipcaAcumuladoAteUltimoAniversario = 1; % ruivo_22/10/2013
            
            this.correcaoTotalPaga = zeros(1, this.n_cenarios); % ruivo_23/10/2013
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            this.PnL_Anual_Acumulado_Correcao = zeros(anos,this.n_cenarios);
            this.PnL_Anual_Acumulado_Juros = zeros(anos,this.n_cenarios);
            this.PnL_Correcao_FimDoAno = zeros(anos,this.n_cenarios);
            this.PnL_Correcao_FimDoMes = zeros(meses,this.n_cenarios);
            this.PnL_Juros_FimDoAno = zeros(anos,this.n_cenarios);
            this.PnL_Juros_FimDoMes = zeros(meses,this.n_cenarios);
            this.PnL_Mensal_Acumulado_Correcao = zeros(meses,this.n_cenarios);
            this.PnL_Mensal_Acumulado_Juros = zeros(meses,this.n_cenarios);
            
            this.MtM_FimDoAno = zeros(anos,this.n_cenarios);
            this.MtM_FimDoMes = zeros(meses,this.n_cenarios);
            this.Datas_FimDoAno = zeros(anos,1);
            this.Datas_FimDoMes = zeros(meses,1);
            
            % CORRIGIR tam
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Execução da calculadora
            for i = 1 : tam
                this.priceDiario();
            end
            
            % Montagem das DREs mensal e anual
            lastDayMes = find(this.isDiaUtil(2, (month(this.dateFinal) == month(this.isDiaUtil(1,:))) & (year(this.dateFinal) == year(this.isDiaUtil(1,:)))),1,'last');
            
            if day(this.dateFinal_util) ~= lastDayMes
                
                this.mes=this.mes+1;
                this.MtM_FimDoMes(this.mes,:)=this.price(end,:);
                this.PnL_Juros_FimDoMes(this.mes,:)=this.jurosAPagarAcumulado_sem_reset(end,:) - this.PnL_Mensal_Acumulado_Juros(this.mes-1,:);
                this.PnL_Correcao_FimDoMes(this.mes,:)=this.correcaoAPagarAcumulada_sem_reset(end,:) - this.PnL_Mensal_Acumulado_Correcao(this.mes-1,:);
                
                this.Datas_FimDoMes(this.mes)=datenum([num2str(lastDayMes) '/' num2str(month(this.dateFinal)) '/' num2str(year(this.dateFinal))],'dd/mm/yyyy');
            
            end
            
            lastDayAno = find(this.isDiaUtil(2, (month(this.isDiaUtil(1,:)) == 12) & (year(this.dateFinal) == year(this.isDiaUtil(1,:)))),1,'last');
            
            if this.dateFinal_util ~= datenum([num2str(lastDayAno) '/12/' num2str(year(this.dateFinal))],'dd/mm/yyyy')
                
                this.ano=this.ano+1;
                this.MtM_FimDoAno(this.ano,:)=this.price(end,:);
                this.PnL_Juros_FimDoAno(this.ano,:)=this.jurosAPagarAcumulado_sem_reset(end,:) - this.PnL_Anual_Acumulado_Juros(this.ano-1,:);
                this.PnL_Correcao_FimDoAno(this.ano,:)=this.correcaoAPagarAcumulada_sem_reset(end,:) - this.PnL_Anual_Acumulado_Correcao(this.ano-1,:);
                
                this.Datas_FimDoAno(this.ano)=datenum([num2str(lastDayAno) '/12/' num2str(year(this.dateFinal))],'dd/mm/yyyy');
            
            end
            
%             this.PnL_Juros_FimDoMes = [this.JurosAcumulados_FimDoMes(1, :)' diff(this.JurosAcumulados_FimDoMes,1,1)']';
%             this.PnL_Correcao_FimDoMes = [this.CorrecaoAcumulada_FimDoMes(1, :)' diff(this.CorrecaoAcumulada_FimDoMes,1,1)']';
% 
%             this.PnL_Juros_FimDoAno = [this.JurosAcumulados_FimDoAno(1, :)' diff(this.JurosAcumulados_FimDoAno,1,1)']';
%             this.PnL_Correcao_FimDoAno = [this.CorrecaoAcumulada_FimDoAno(1, :)' diff(this.CorrecaoAcumulada_FimDoAno,1,1)']';
            
        end

    end
    
end

