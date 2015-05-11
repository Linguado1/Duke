try

%     newPath = uigetdir('C:\Program Files\MATLAB\MATLAB Compiler Runtime\v81\bin\win64','Selecionar pasta de bibliotecas do MCR');
    newPath = 'C:\Program Files\MATLAB\MATLAB Compiler Runtime\v81\bin\win64';
    if exist(newPath, 'dir')
        newPath=['"' newPath '"'];

        eval(['!SETX PATH ' newPath]);
    
        msgbox('Instalação finalizada com sucesso');
    else
        msgbox('Matlab Compiler Runtime não encontrado.');
    end

catch e
    
    msgbox(e.message)
    
end
