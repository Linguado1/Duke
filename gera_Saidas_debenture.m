%% Se há um único cenário, escreve os dados de saída na planilha com o nome contido em output_filename

[output_filename , output_filepath] = uiputfile({'*.xlsx;*.xls' , 'EXCEL (*.xlsx,*.xls)'}, 'Salvar Planilha');

output_filename = [output_filepath output_filename];

tic;

% if n_cenarios == 1

    %
    % ABA 1
    %

    current_sheet = 1;
    column = 1;

    % Datas
    dates_title = {'Datas'};
    dates_data = num2cell(datestr(db.datas, 'dd/mm/yyyy'),[2 3]);

    data_matrix(1:(length(db.datas) + 1),column) = [dates_title ; dates_data];

    column = column + 1;

    % Dias úteis
    dias_uteis_title = {'Dia Útil'};
    dias_uteis_data = num2cell(db.diasUteis);

    data_matrix(1:(length(db.diasUteis) + 1),column) = [dias_uteis_title ; dias_uteis_data];

    column = column + 1;

    % Price
    price_title = {'Price'};
    price_data = num2cell(mean(db.price(:,1:numRealidades),2));

    data_matrix(1:(size(db.price,1) + 1),column) = [price_title ; price_data];

    column = column + 1;

    % Juros Acumulado
    juros_acumulado_title = {'Juros Acumulado'};
    juros_acumulado_data = num2cell(mean(db.jurosAPagarAcumulado(:,1:numRealidades),2));

    data_matrix(1:(size(db.jurosAPagarAcumulado,1)+1),column) = [juros_acumulado_title ; juros_acumulado_data];

    column = column + 1;

    % Correção Acumulada
    correcao_acumulada_title = {'Correção Acumulada'};
    correcao_acumulada_data = num2cell(mean(db.correcaoAPagarAcumulada(:,1:numRealidades),2));

    data_matrix(1:(size(db.correcaoAPagarAcumulada,1)+1),column) = [correcao_acumulada_title ; correcao_acumulada_data];

    % Intervalo de células na aba do arquivo XLS
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];

    % Escreve a matriz de dados na aba selecionada do arquivo XLS
    xlswrite(output_filename,data_matrix,current_sheet,range);

    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(1).Name = 'Price IPCA Unitário'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
    
    %%
    % ABA 2
    %

    current_sheet = 2;
    column = 1;
    clear data_matrix;

    % Datas de pagamento de juros
    dates_juros_title = {'Datas de Juros'};
    dates_juros_data = num2cell(datestr(db.dateJuros, 'dd/mm/yyyy'),[2 3]);

    max_length = max(length(db.dateJuros),length(db.amortizacao(:,1)));

    data_matrix(1:(length(db.dateJuros) + 1),column) = [dates_juros_title ; dates_juros_data];
    data_matrix((length(db.dateJuros) + 2):max_length,column) = {''};

    column = column + 1;

    % Quantidades pagas de juros
    juros_title = {'Juros Pagos'};
    juros_data = num2cell(mean(db.juros(:,1:numRealidades),2));

    data_matrix(1:(size(db.juros,1) + 1),column) = [juros_title ; juros_data];
    data_matrix((size(db.juros,1) + 2):max_length,column) = {''};

    column = column + 1;

    % Datas de pagamento de amortização
    dates_amortizacao_title = {'Datas de Amortização'};
    dates_amortizacao_data = num2cell(datestr(db.amortizacao(:,1), 'dd/mm/yyyy'),[2 3]);

    data_matrix(1:(length(db.amortizacao(:,1)) + 1),column) = [dates_amortizacao_title ; dates_amortizacao_data];
    data_matrix((length(db.amortizacao(:,1)) + 2):max_length,column) = {''};

    column = column + 1;

    % Quantidades pagas de amortização
    amortizacao_title = {'Amortização Paga'};
    amortizacao_data = num2cell(db.amortizacao(:,2));

    data_matrix(1:(length(db.amortizacao(:,2)) + 1),column) = [amortizacao_title ; amortizacao_data];
    data_matrix((length(db.amortizacao(:,2)) + 2):max_length,column) = {''};

    column = column + 1;

    % Correção Monetária Paga
    correcao_paga_title = {'Correção Acumulada Paga'};
    correcao_paga_data = num2cell(mean(db.correcaoPaga(:,1:numRealidades),2));

    data_matrix(1:(size(db.correcaoPaga,1) + 1),column) = [correcao_paga_title ; correcao_paga_data];
    data_matrix((size(db.correcaoPaga,1) + 2):max_length,column) = {''};

    tempo_xls = toc;

%     % Tempo gasto para execução da debênture
% 
%     time_debenture_title = {'Tempo de execução da debênture (s)'};
%     time_debenture_data = {tempo_debenture};
% 
%     data_matrix(1:2,column) = [time_debenture_title time_debenture_data];
%     data_matrix(3:max_length,column) = {''};
% 
%     column = column + 1;
% 
%     % Tempo gasto para escrever os dados no arquivo XLS
% 
%     time_xls_title = {'Tempo XLS'};
%     time_xls_data = {tempo_xls};
%     data_matrix(1:2,column) = [time_xls_title time_xls_data];
%     data_matrix(3:max_length,column) = {''};

    % Intervalo de células na aba do arquivo XLS
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];

    % Escreve a matriz de dados na aba selecionada do arquivo XLS
    xlswrite(output_filename,data_matrix,current_sheet,range);
    
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(2).Name = 'Fluxos IPCA Unitário'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
    
    %%
    % ABA 3
    %
    
    current_sheet = 3;
    column = 1;
    clear data_matrix;
    
    % Datas de fim de mês
    dates_FimDoMes_title = {'Fim do Mês'};
    dates_FimDoMes_data = num2cell(datestr(db.Datas_FimDoMes,'dd/mm/yyyy'),[2 3]);
    
    max_length = length(db.Datas_FimDoMes);
    
    data_matrix(1:(length(db.Datas_FimDoMes) + 1),column) = [dates_FimDoMes_title ; dates_FimDoMes_data];
    data_matrix((length(db.Datas_FimDoMes) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % MtM
    MtM_title = {'MtM da dívida'};
    MtM_data = num2cell(mean(db.MtM_FimDoMes(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.MtM_FimDoMes,1) + 1),column) = [MtM_title ; MtM_data];
    data_matrix((size(db.MtM_FimDoMes,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % PnL Juros
    PnL_Juros_title = {'PnL de Juros'};
    PnL_Juros_data = num2cell(mean(db.PnL_Juros_FimDoMes(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoMes,1) + 1),column) = [PnL_Juros_title ; PnL_Juros_data];
    data_matrix((size(db.PnL_Juros_FimDoMes,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Correcao
    PnL_Correcao_title = {'PnL de Correção Monetária'};
    PnL_Correcao_data = num2cell(mean(db.PnL_Correcao_FimDoMes(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Correcao_FimDoMes,1) + 1),column) = [PnL_Correcao_title ; PnL_Correcao_data];
    data_matrix((size(db.PnL_Correcao_FimDoMes,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Total
    PnL_Total_title = {'PnL da dívida'};
    PnL_Total_data = num2cell(mean(db.PnL_Juros_FimDoMes(:,1:numRealidades),2)+mean(db.PnL_Correcao_FimDoMes(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoMes+db.PnL_Correcao_FimDoMes,1) + 1),column) = [PnL_Total_title ; PnL_Total_data];
    data_matrix((size(db.PnL_Juros_FimDoMes+db.PnL_Correcao_FimDoMes,1) + 2):max_length,column) = {''};
    
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];
    
    xlswrite(output_filename,data_matrix,current_sheet,range);
    
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(3).Name = 'DRE Mensal Unitário'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
    
    %%
    % ABA 4
    %
    
    current_sheet = 4;
    column = 1;
    clear data_matrix;
    
    % Datas de fim de mês
    dates_FimDoAno_title = {'Fim do Ano'};
    dates_FimDoAno_data = num2cell(datestr(db.Datas_FimDoAno,'dd/mm/yyyy'),[2 3]);
    
    max_length = length(db.Datas_FimDoAno);
    
    data_matrix(1:(length(db.Datas_FimDoAno) + 1),column) = [dates_FimDoAno_title ; dates_FimDoAno_data];
    data_matrix((length(db.Datas_FimDoAno) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % MtM
    MtM_title = {'MtM da dívida'};
    MtM_data = num2cell(mean(db.MtM_FimDoAno(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.MtM_FimDoAno,1) + 1),column) = [MtM_title ; MtM_data];
    data_matrix((size(db.MtM_FimDoAno,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % PnL Juros
    PnL_Juros_title = {'PnL de Juros'};
    PnL_Juros_data = num2cell(mean(db.PnL_Juros_FimDoAno(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoAno,1) + 1),column) = [PnL_Juros_title ; PnL_Juros_data];
    data_matrix((size(db.PnL_Juros_FimDoAno,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Correcao
    PnL_Correcao_title = {'PnL de Correção Monetária'};
    PnL_Correcao_data = num2cell(mean(db.PnL_Correcao_FimDoAno,2));
    
    data_matrix(1:(size(db.PnL_Correcao_FimDoAno) + 1),column) = [PnL_Correcao_title ; PnL_Correcao_data];
    data_matrix((size(db.PnL_Correcao_FimDoAno) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Total
    PnL_Total_title = {'PnL da dívida'};
    PnL_Total_data = num2cell(mean(db.PnL_Juros_FimDoAno+db.PnL_Correcao_FimDoAno,2));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoAno+db.PnL_Correcao_FimDoAno,1) + 1),column) = [PnL_Total_title ; PnL_Total_data];
    data_matrix((size(db.PnL_Juros_FimDoAno+db.PnL_Correcao_FimDoAno,1) + 2):max_length,column) = {''};
    
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];
    
    xlswrite(output_filename,data_matrix,current_sheet,range);
    
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(4).Name = 'DRE Anual Unitário'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
    
    %%
    % ABA 5
    %

    current_sheet = 5;
    column = 1;

    % Datas
    dates_title = {'Datas'};
    dates_data = num2cell(datestr(db.datas, 'dd/mm/yyyy'),[2 3]);

    data_matrix(1:(length(db.datas) + 1),column) = [dates_title ; dates_data];

    column = column + 1;

    % Dias úteis
    dias_uteis_title = {'Dia Útil'};
    dias_uteis_data = num2cell(db.diasUteis);

    data_matrix(1:(length(db.diasUteis) + 1),column) = [dias_uteis_title ; dias_uteis_data];

    column = column + 1;

    % Price
    price_title = {'Price'};
    price_data = num2cell(NumeroDebentures*mean(db.price(:,1:numRealidades),2));

    data_matrix(1:(size(db.price,1) + 1),column) = [price_title ; price_data];

    column = column + 1;

    % Juros Acumulado
    juros_acumulado_title = {'Juros Acumulado'};
    juros_acumulado_data = num2cell(NumeroDebentures*mean(db.jurosAPagarAcumulado(:,1:numRealidades),2));

    data_matrix(1:(size(db.jurosAPagarAcumulado,1)+1),column) = [juros_acumulado_title ; juros_acumulado_data];

    column = column + 1;

    % Correção Acumulada
    correcao_acumulada_title = {'Correção Acumulada'};
    correcao_acumulada_data = num2cell(NumeroDebentures*mean(db.correcaoAPagarAcumulada(:,1:numRealidades),2));

    data_matrix(1:(size(db.correcaoAPagarAcumulada,1)+1),column) = [correcao_acumulada_title ; correcao_acumulada_data];

    % Intervalo de células na aba do arquivo XLS
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];

    % Escreve a matriz de dados na aba selecionada do arquivo XLS
    xlswrite(output_filename,data_matrix,current_sheet,range);

    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(5).Name = 'Price IPCA Total'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
    
    %%
    % ABA 6
    %

    current_sheet = 6;
    column = 1;
    clear data_matrix;

    % Datas de pagamento de juros
    dates_juros_title = {'Datas de Juros'};
    dates_juros_data = num2cell(datestr(db.dateJuros, 'dd/mm/yyyy'),[2 3]);

    max_length = max(length(db.dateJuros),length(db.amortizacao(:,1)));

    data_matrix(1:(length(db.dateJuros) + 1),column) = [dates_juros_title ; dates_juros_data];
    data_matrix((length(db.dateJuros) + 2):max_length,column) = {''};

    column = column + 1;

    % Quantidades pagas de juros
    juros_title = {'Juros Pagos'};
    juros_data = num2cell(NumeroDebentures*mean(db.juros(:,1:numRealidades),2));

    data_matrix(1:(size(db.juros,1) + 1),column) = [juros_title ; juros_data];
    data_matrix((size(db.juros,1) + 2):max_length,column) = {''};

    column = column + 1;

    % Datas de pagamento de amortização
    dates_amortizacao_title = {'Datas de Amortização'};
    dates_amortizacao_data = num2cell(datestr(db.amortizacao(:,1), 'dd/mm/yyyy'),[2 3]);

    data_matrix(1:(length(db.amortizacao(:,1)) + 1),column) = [dates_amortizacao_title ; dates_amortizacao_data];
    data_matrix((length(db.amortizacao(:,1)) + 2):max_length,column) = {''};

    column = column + 1;

    % Quantidades pagas de amortização
    amortizacao_title = {'Amortização Paga'};
    amortizacao_data = num2cell(NumeroDebentures*db.amortizacao(:,2));

    data_matrix(1:(length(db.amortizacao(:,2)) + 1),column) = [amortizacao_title ; amortizacao_data];
    data_matrix((length(db.amortizacao(:,2)) + 2):max_length,column) = {''};

    column = column + 1;

    % Correção Monetária Paga
    correcao_paga_title = {'Correção Acumulada Paga'};
    correcao_paga_data = num2cell(NumeroDebentures*mean(db.correcaoPaga(:,1:numRealidades),2));

    data_matrix(1:(size(db.correcaoPaga,1) + 1),column) = [correcao_paga_title ; correcao_paga_data];
    data_matrix((size(db.correcaoPaga,1) + 2):max_length,column) = {''};

    tempo_xls = toc;

%     % Tempo gasto para execução da debênture
% 
%     time_debenture_title = {'Tempo de execução da debênture (s)'};
%     time_debenture_data = {tempo_debenture};
% 
%     data_matrix(1:2,column) = [time_debenture_title time_debenture_data];
%     data_matrix(3:max_length,column) = {''};
% 
%     column = column + 1;
% 
%     % Tempo gasto para escrever os dados no arquivo XLS
% 
%     time_xls_title = {'Tempo XLS'};
%     time_xls_data = {tempo_xls};
%     data_matrix(1:2,column) = [time_xls_title time_xls_data];
%     data_matrix(3:max_length,column) = {''};

    % Intervalo de células na aba do arquivo XLS
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];

    % Escreve a matriz de dados na aba selecionada do arquivo XLS
    xlswrite(output_filename,data_matrix,current_sheet,range);
    
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(6).Name = 'Fluxos IPCA Total'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
    
    %%
    % ABA 7
    %
    
    current_sheet = 7;
    column = 1;
    clear data_matrix;
    
    % Datas de fim de mês
    dates_FimDoMes_title = {'Fim do Mês'};
    dates_FimDoMes_data = num2cell(datestr(db.Datas_FimDoMes,'dd/mm/yyyy'),[2 3]);
    
    max_length = length(db.Datas_FimDoMes);
    
    data_matrix(1:(length(db.Datas_FimDoMes) + 1),column) = [dates_FimDoMes_title ; dates_FimDoMes_data];
    data_matrix((length(db.Datas_FimDoMes) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % MtM
    MtM_title = {'MtM da dívida'};
    MtM_data = num2cell(NumeroDebentures*mean(db.MtM_FimDoMes(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.MtM_FimDoMes,1) + 1),column) = [MtM_title ; MtM_data];
    data_matrix((size(db.MtM_FimDoMes,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % PnL Juros
    PnL_Juros_title = {'PnL de Juros'};
    PnL_Juros_data = num2cell(NumeroDebentures*mean(db.PnL_Juros_FimDoMes(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoMes,1) + 1),column) = [PnL_Juros_title ; PnL_Juros_data];
    data_matrix((size(db.PnL_Juros_FimDoMes,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Correcao
    PnL_Correcao_title = {'PnL de Correção Monetária'};
    PnL_Correcao_data = num2cell(NumeroDebentures*mean(db.PnL_Correcao_FimDoMes(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Correcao_FimDoMes,1) + 1),column) = [PnL_Correcao_title ; PnL_Correcao_data];
    data_matrix((size(db.PnL_Correcao_FimDoMes,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Total
    PnL_Total_title = {'PnL da dívida'};
    PnL_Total_data = num2cell(NumeroDebentures*(mean(db.PnL_Juros_FimDoMes(:,1:numRealidades)+db.PnL_Correcao_FimDoMes(:,1:numRealidades),2)));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoMes+db.PnL_Correcao_FimDoMes,1) + 1),column) = [PnL_Total_title ; PnL_Total_data];
    data_matrix((size(db.PnL_Juros_FimDoMes+db.PnL_Correcao_FimDoMes,1) + 2):max_length,column) = {''};
    
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];
    
    xlswrite(output_filename,data_matrix,current_sheet,range);
    
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(7).Name = 'DRE Mensal Total'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
    
    %%
    % ABA 8
    %
    
    current_sheet = 8;
    column = 1;
    clear data_matrix;
    
    % Datas de fim de mês
    dates_FimDoAno_title = {'Fim do Ano'};
    dates_FimDoAno_data = num2cell(datestr(db.Datas_FimDoAno,'dd/mm/yyyy'),[2 3]);
    
    max_length = length(db.Datas_FimDoAno);
    
    data_matrix(1:(length(db.Datas_FimDoAno) + 1),column) = [dates_FimDoAno_title ; dates_FimDoAno_data];
    data_matrix((length(db.Datas_FimDoAno) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % MtM
    MtM_title = {'MtM da dívida'};
    MtM_data = num2cell(NumeroDebentures*mean(db.MtM_FimDoAno(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.MtM_FimDoAno,1) + 1),column) = [MtM_title ; MtM_data];
    data_matrix((size(db.MtM_FimDoAno,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
    % PnL Juros
    PnL_Juros_title = {'PnL de Juros'};
    PnL_Juros_data = num2cell(NumeroDebentures*mean(db.PnL_Juros_FimDoAno(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoAno,1) + 1),column) = [PnL_Juros_title ; PnL_Juros_data];
    data_matrix((size(db.PnL_Juros_FimDoAno,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Correcao
    PnL_Correcao_title = {'PnL de Correção Monetária'};
    PnL_Correcao_data = num2cell(NumeroDebentures*mean(db.PnL_Correcao_FimDoAno(:,1:numRealidades),2));
    
    data_matrix(1:(size(db.PnL_Correcao_FimDoAno,1) + 1),column) = [PnL_Correcao_title ; PnL_Correcao_data];
    data_matrix((size(db.PnL_Correcao_FimDoAno,1) + 2):max_length,column) = {''};
    
    column = column + 1;
    
	% PnL Total
    PnL_Total_title = {'PnL da dívida'};
    PnL_Total_data = num2cell(NumeroDebentures*(mean(db.PnL_Juros_FimDoAno(:,1:numRealidades)+db.PnL_Correcao_FimDoAno(:,1:numRealidades),2)));
    
    data_matrix(1:(size(db.PnL_Juros_FimDoAno+db.PnL_Correcao_FimDoAno,1) + 1),column) = [PnL_Total_title ; PnL_Total_data];
    data_matrix((size(db.PnL_Juros_FimDoAno+db.PnL_Correcao_FimDoAno,1) + 2):max_length,column) = {''};
    
    range_from = 'A1';
    range_to = ['E' num2str(size(data_matrix,1))];
    range = [range_from ':' range_to];
    
    xlswrite(output_filename,data_matrix,current_sheet,range);
    
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks.Open(output_filename); %# open file (enter full path!)
    ewb.Worksheets.Item(8).Name = 'DRE Anual Total'; %# rename 1st sheet
    ewb.Save %# save to the same file
    ewb.Close(false)
    e.Quit
% end