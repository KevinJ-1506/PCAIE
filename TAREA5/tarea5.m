if(exist('OCTAVE_VERSION', 'builtin')~= 0)
pkg load signal;
end

% Definición de categorías
bajoPeso = "Bajo Peso";
pesoNormal = "Peso Normal";
sobrePeso = "Sobrepeso";
#IMC=0;

% Menú principal
opcion = 0;
while opcion ~= 6
  % Menú de opciones
  disp('Seleccione una opcion:');
  disp('1. Ingresar datos');
  disp('2. Mostrar datos');
  disp('3. Guardar');
  disp('4. Leer');
  disp('5. Borrar');
  disp('6. Salir');
  opcion = input('Ingrese su eleccion: ');

  if isempty(opcion) || ~isnumeric(opcion) || opcion < 1 || opcion > 6
    disp('Entrada inválida. Por favor, ingrese un número entre 1 y 6.');
    continue;
  end

  switch opcion
    case 1
      % Ingreso de datos
      try
        nombre = input('Ingrese el nombre del usuario: ', 's');
        if isempty(nombre) || ~ischar(nombre) || ~isempty(str2num(nombre))
          disp('Error: El nombre no puede ser un número o estar vacío. Intenta de nuevo.');
          continue;
        end

        peso = input('Ingrese el peso del usuario en kilogramos: ');
        if isempty(peso) || ~isnumeric(peso) || peso <= 0
          disp('Peso inválido. Debe ser un número positivo.');
          continue;
        end

        altura = input('Ingrese la altura del usuario en metros: ');
        if isempty(altura) || ~isnumeric(altura) || altura <= 0
          disp('Altura inválida. Debe ser un número positivo.');
          continue;
        end

        disp('Información guardada correctamente.');
        disp(' ');
      catch
        disp('Error al ingresar los datos del usuario.');
      end_try_catch

    case 2
  % Mostrar datos del IMC
      try
        % Calcula el IMC
        IMC = peso / altura^2;
        % Muestra el valor del IMC
        fprintf('El Índice de Masa Corporal de %s es de %.2f \n', nombre, IMC);
        % Determina la categoría del IMC
        if IMC < 18.5
          categoria = bajoPeso';
        elseif IMC >= 18.5 && IMC < 25
          categoria = pesoNormal;
        else
          categoria = sobrePeso;
        end

        % Muestra la categoría
        fprintf('%s se encuentra en la categoría: %s \n',nombre, categoria);
        disp(' ');

      catch
        disp('Error al mostrar los datos del usuario.');
      end_try_catch

    case 3
      % Guardar información en un archivo txt
      try
        file1=fopen('imc.txt', 'w'); %crea o abre en modo escritura
        fprintf(file1, '-------------------------------------------- \n');
        fprintf(file1, 'Nombre: %s \n', nombre);
        fprintf(file1, 'Peso: %.2f [kg]\n', peso);
        fprintf(file1, 'Altura: %.2f [m]\n', altura);
        fprintf(file1, 'Indice de Masa Corporal (IMC): %.2f \n', IMC);
        fprintf(file1, 'Categoría: %s \n', categoria);
        fprintf(file1, '-------------------------------------------- \n');
        fclose(file1);

        disp('¡Documento creado y guardado correctamente!');
        disp(' ');
      catch
        disp('No se pudo guardar el archivo.');
      end_try_catch

    case 4
      % Leer los datos del archivo txt
      try
        disp('Leyendo el archivo...');
        file1 = fopen('imc.txt', 'r');
        while ~feof(file1) % Mientras no sea el final del archivo
          linea = fgets(file1); % Leer una línea
          disp(linea); % Mostrar la línea en pantalla
        end
        fclose(file1); % Cerrar el archivo
        disp('Cerrando archivo...');
        disp(' ');
      catch
        disp('No se pudieron leer los datos del archivo. Intente de nuevo.');
      end_try_catch

    case 5
      % Borrar el archivo
      try
        fclose('all'); % Cierra cualquier archivo abierto
        % Intenta borrar el archivo
        if exist('imc.txt', 'file') % Verifica si el archivo existe
          unlink('imc.txt'); % Elimina el archivo
          disp('El archivo fue eliminado correctamente.');
          disp(' ' );
        else
          disp('No se pudo eliminar el archivo porque no existe.');
          disp(' ');
        end
      catch
        disp('Error al intentar eliminar el archivo.');
        disp(' ');
      end_try_catch

    case 6
      % Salir
      disp('¡Gracias por usar el programa!');
  endswitch
end

