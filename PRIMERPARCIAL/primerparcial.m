clc;
clear;
pkg load database;

%Variable para ir almacenando los resultados
global resultados conn;
resultados = struct();

try
    % Conectar a la base de datos
    conn = pq_connect(setdbopts('dbname', 'primerparcial', 'host', 'localhost', 'port', '5432', 'user', 'postgres', 'password', 'hidrogeno'));
    disp('Conexión a la base de datos establecida.');
catch ME
    error('No se pudo conectar a la base de datos: %s', ME.message);
end

function menu()
  opcion = 0;
  while opcion ~= 7
    fprintf('\n\t\t¡Bienvenido al Menú Principal!\n');
    fprintf('1. Calcular factorial\n');
    fprintf('2. Sistema login\n');
    fprintf('3. Calcular distancia entre dos puntos\n');
    fprintf('4. Calcular IMC\n');
    fprintf('5. Sueldo base semanal\n');
    fprintf('6. Historial de datos\n');
    fprintf('7. Salir\n');

  try
    opcion = input('Seleccione una opción: ');
    if isempty(opcion) || ~isnumeric(opcion) || opcion < 1 || opcion > 10
      error('Entrada inválida. Por favor, ingrese un número entre 1 y 10.');
    endif
  catch ME
    fprintf('Error: %s\n', ME.message);
    continue;
  end

        switch opcion

            case 1 %calcular factorial
              calculo_factorial();

            case 2 %Sistema login
              sistemaLogin();
            case 3 %calcular distancia entre dos puntos
              calcular_distancia();
            case 4 %calcular imc
              calcular_imc();
            case 5 %sueldo base semanal
              calcular_nomina();
            case 6 %Historial de datos
                mostrar_historial();

            case 7 %salir
                fprintf('¡Gracias por visitarnos! Vuelva pronto.\n');
            otherwise
                fprintf('Opción no válida. Intente nuevamente.\n');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ingresoDatos()
    global resultados;
    try
      resultados.nombre = input('Ingrese el nombre del usuario: ', 's');
      if isempty(resultados.nombre)
            error('El nombre no puede estar vacío.');
      end
        fprintf('Datos ingresados correctamente.\n');
    catch ME
        fprintf('Error: %s\n', ME.message);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function calculo_factorial()
  global conn;
  global resultados;
  try
    while true
      % Pedir al usuario que ingrese un número
      resultados.tipo_programa1 = 'Factorial';
      resultados.x = input('Ingresa un número entero positivo: ');

      % Calcular el factorial usando la función calcularFactorial
      if( ~isnumeric(resultados.x) || resultados.x < 0 || mod(resultados.x,1) != 0)
          disp('Error: El numero ingresado debe ser entero positivo. Intenta de nuevo.'); %si no es entero positivo, se encicla de nuevo
      elseif(isempty(resultados.x))
        disp('Error: no ingresaste nada. Intenta de nuevo'); %si no ingresa nada. Vuelve al ciclo
      else
          break; %si ingresa un entero positivo sale del ciclo
      end
    end

      if (resultados.x == 0 || resultados.x == 1)
          resultados.factorial = 1;

      elseif(resultados.x >1)
          resultados.factorial = 1;

          for (i = 2:resultados.x)
              resultados.factorial = resultados.factorial * i;
          end
      end
        fprintf('El factorial de %d es %d\n', resultados.x, resultados.factorial);
      % Mostrar el resultado
        ingnum = int2str(resultados.x);
        resfac = int2str(resultados.factorial);
        ingfac = cstrcat("insert into factorial values('",ingnum,"',",resfac,");");
        N=pq_exec_params(conn,ingfac);
        %guardar datos en la base de datos

  catch e
      % Manejar el error si el usuario ingresa un número negativo o no entero
      fprintf('Ocurrió un error. Error: %s\n', e.message);

  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sistemaLogin()

  global resultados;
% Inicializar el número de intentos
  resultados.intentos = 3;

  while resultados.intentos > 0
      resultados.tipo_programa2 = 'Login';
      % Solicitar el nombre de usuario y la contraseña
      resultados.usuario = input('Ingrese el nombre de usuario: ', 's');
      resultados.contrasena = input('Ingrese la contraseña: ', 's');

      % Verificar las credenciales
      if strcmp(resultados.usuario, 'admin') && strcmp(resultados.contrasena, '123')
          disp('¡Inicio de sesión exitoso!');
          break; % Salir del loop principal
      else
          % Mostrar el número de intentos restantes
          resultados.intentos = resultados.intentos - 1;
          fprintf('Credenciales incorrectas. Te quedan %d intentos.\n', resultados.intentos);

          % Cerrar el programa si se agotan los intentos
          if resultados.intentos == 0
              disp('Has agotado todos los intentos. Cerrando el programa.');
              return;
          end
      end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calcular_distancia()
  global conn;
  global resultados;
  try
    % Solicitar las coordenadas del primer punto
    resultados.tipo_programa3 = 'Distancia';
    fprintf('Ingrese las coordenadas del primer punto (x1, y1):\n');
    resultados.x1 = input('x1 = ');
    resultados.y1 = input('y1 = ');

    % Validar si las entradas son numéricas
    if ~isnumeric(resultados.x1) || ~isnumeric(resultados.y1) || isempty(resultados.x1) || isempty(resultados.y1)
      error('Las coordenadas deben ser valores numéricos.');
    end

    % Solicitar las coordenadas del segundo punto
    fprintf('\nIngrese las coordenadas del segundo punto (x2, y2):\n');
    resultados.x2 = input('x2 = ');
    resultados.y2 = input('y2 = ');

    % Validar si las entradas son numéricas
    if ~isnumeric(resultados.x2) || ~isnumeric(resultados.y2) || isempty(resultados.x2) || isempty(resultados.y2)
      error('Las coordenadas deben ser valores numéricos.');
    end

    % Calcular la distancia usando la fórmula de Pitágoras
    resultados.distancia = sqrt((resultados.x2 - resultados.x1)^2 + (resultados.y2 - resultados.y1)^2);

    % Mostrar el resultado
    fprintf('\nLa distancia más corta entre los puntos (%d, %d) y (%d, %d) es: %.4f\n', ...
            resultados.x1, resultados.y1, resultados.x2, resultados.y2, resultados.distancia);

        x1 = num2str(resultados.x1);
        y1 = num2str(resultados.y1);
        x2 = num2str(resultados.x2);
        y2 = num2str(resultados.y2);
        rc = num2str(resultados.distancia);
        p1 = strcat(x1,",",y1);
        p2 = strcat(x2,",",y2);
        ingcar = cstrcat("insert into cartesiano values('",p1,"','",p2,"',",rc,");");
        N=pq_exec_params(conn,ingcar);
  catch ME
    % Manejo de errores
    fprintf('Error: %s\n', ME.message);
  end_try_catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calcular_imc()
  global conn;
  global resultados;
  try
    resultados.tipo_programa4 = 'IMC';
    % Solicitar al usuario su sexo (hombre/mujer)
    resultados.genero = input('Ingrese su genero ("hombre" o "mujer"): ', 's');
    resultados.genero = lower(strtrim(resultados.genero)); % Convertir a minúsculas y quitar espacios

    % Validar el ingreso del sexo
    if ~strcmp(resultados.genero, 'hombre') && ~strcmp(resultados.genero, 'mujer')
      error('Debe ingresar "hombre" o "mujer".');
    end

    % Solicitar el peso
    resultados.peso = input('Ingrese su peso en kilogramos (kg): ');
    if isempty(resultados.peso) || ~isnumeric(resultados.peso) || resultados.peso <= 0
      error('El peso debe ser un valor numérico positivo.');
    end

    % Solicitar la altura
    resultados.altura = input('Ingrese su altura en metros (m): ');
    if isempty(resultados.altura) || ~isnumeric(resultados.altura) || resultados.altura <= 0
      error('La altura debe ser un valor numérico positivo.');
    end

    % Calcular el IMC
    resultados.imc = resultados.peso / (resultados.altura^2);

    % Mostrar el resultado del IMC
    fprintf('\nSu Índice de Masa Corporal (IMC) es: %.2f\n', resultados.imc);

    % Determinar la conducta a seguir según el IMC y sexo
    if strcmp(resultados.genero, 'mujer')
      if resultados.imc < 18.5
        fprintf('Conducta a seguir: Bajo peso, consulte a su médico.\n');
        resultados.estado = 'Bajo Peso';
        resultados.conducta = 'consulte a su médico.';
      elseif resultados.imc >= 18.5 && resultados.imc < 24.9
        fprintf('Conducta a seguir: Peso normal, continúe con buenos hábitos.\n');
        resultados.estado = 'Peso Normal';
        resultados.conducta = 'continúe con buenos hábitos.';
      elseif resultados.imc >= 25 && resultados.imc < 29.9
        fprintf('Conducta a seguir: Sobrepeso, considere una rutina de ejercicios.\n');
        resultados.estado = 'Sobrepeso';
        resultados.conducta = 'considere una rutina de ejercicios.';
      else
        fprintf('Conducta a seguir: Obesidad, consulte a su médico para un plan adecuado.\n');
        resultados.estado = 'Obesidad';
        resultados.conducta = 'consulte a su médico para un plan adecuado.';
      end
    elseif strcmp(resultados.genero, 'hombre')
      if resultados.imc < 18.5
        fprintf('Conducta a seguir: Bajo peso, consulte a su médico.\n');
        resultados.estado = 'Bajo Peso';
        resultados.conducta = 'consulte a su médico.';
      elseif resultados.imc >= 18.5 && resultados.imc < 24.9
        fprintf('Conducta a seguir: Peso normal, continúe con buenos hábitos.\n');
        resultados.estado = 'Peso Normal';
        resultados.conducta = 'continúe con buenos hábitos.';
      elseif resultados.imc >= 25 && resultados.imc < 29.9
        fprintf('Conducta a seguir: Sobrepeso, considere una rutina de ejercicios.\n');
        resultados.estado = 'Sobrepeso';
        resultados.conducta = 'considere una rutina de ejercicios.';
      else
        fprintf('Conducta a seguir: Obesidad, consulte a su médico para un plan adecuado.\n');
        resultados.estado = 'Obesidad';
        resultados.conducta = 'consulte a su médico para un plan adecuado.';
      end
    end
        peso = num2str(resultados.peso);
        altura = num2str(resultados.altura);
        imc = num2str(resultados.imc);

       ingimc = cstrcat("insert into imc values('",resultados.genero,"',",peso,",",altura,",",imc,",'",resultados.estado,"','",resultados.conducta,"');");
       N=pq_exec_params(conn,ingimc);

  catch ME
    % Manejo de errores
    fprintf('Error: %s\n', ME.message);
  end_try_catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function calcular_nomina()
  global conn;
  global resultados;
  % Constante para el precio por hora
  PRECIO_HORA = 6;

  try
    % Solicitar horas de trabajo
    resultados.tipo_programa5 = 'Sueldo semanal';
    resultados.horas_trabajo = input('Ingrese las horas de trabajo semanales: ');
    if isempty(resultados.horas_trabajo) || ~isnumeric(resultados.horas_trabajo) || resultados.horas_trabajo < 0
      error('Las horas de trabajo deben ser un valor numérico positivo.');
    end
    if resultados.horas_trabajo > 40
      resultados.horas_extras = resultados.horas_trabajo - 40;
      resultados.horas_base = 40;
    else
      resultados.horas_base = resultados.horas_trabajo;
      resultados.horas_extras = 0;
    end


    % Calcular precio por hora extra
    if resultados.horas_extras  == 0
      resultados.precio_hora_extra = 0;
    elseif resultados.horas_extras  < 10
      resultados.precio_hora_extra = PRECIO_HORA * 1.5; % 50% mayor
    elseif resultados.horas_extras >= 9 && resultados.horas_extras <= 20
      resultados.precio_hora_extra = PRECIO_HORA * 1.5*1.4; % 40% mayor
    else
      resultados.precio_hora_extra = PRECIO_HORA * 1.5*1.4 * 1.2; % 20% mayor
    end

    % Calcular el sueldo base semanal
    resultados.sueldo_base = resultados.horas_base * PRECIO_HORA;
    resultados.sueldo_total = resultados.sueldo_base + (resultados.horas_extras * resultados.precio_hora_extra);

    % Mostrar los resultados
    fprintf('\nResumen de nómina:\n');
    fprintf('Horas trabajadas: %d\n', resultados.horas_trabajo);
    fprintf('Horas extra: %d\n', resultados.horas_extras);
    fprintf('Precio por hora: %.2f\n', PRECIO_HORA);
    fprintf('Precio por hora extra: %.2f\n', resultados.precio_hora_extra);
    fprintf('Sueldo base semanal: %.2f\n', resultados.sueldo_base);
    fprintf('Sueldo base total: %.2f\n', resultados.sueldo_total);

        ht = num2str(resultados.horas_trabajo);
        he = num2str(resultados.horas_extras);
        phb = num2str(PRECIO_HORA);
        phe = num2str(resultados.precio_hora_extra);
        sb = num2str(resultados.sueldo_base);
        st = num2str(resultados.sueldo_total);

      ingnomina = cstrcat("insert into nomina values(",ht,",",he,",",phb,",",phe,",",sb,",",st,");");
      N=pq_exec_params(conn,ingnomina);

  catch ME
    % Manejo de errores
    fprintf('Error: %s\n', ME.message);
  end_try_catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function registrar_operacion()
    #global resultados;
    global resultados conn;
    try

        % Generar el texto para el archivo
        fecha_actual = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        registro_txt = sprintf([...
            '----------------------------------------------\n', ...
            'Fecha: %s\n', ...
            'Usuario: %s\n', ...
            'Tipo de programa: %s\n', ...
            'Numero a calcular factorial: %s\n', ...
            'Resultado de factorial: %s\n', ...
            '----------------------------------------------\n', ...
            'Tipo de programa: %s\n', ...
            'Intentos disponibles: %s\n', ...
            'Usuario: %s\n', ...
            'Password: %s\n', ...
            '----------------------------------------------\n', ...
            'Tipo de programa: %s\n', ...
            'x1: %s\n', ...
            'y1: %s\n', ...
            'x2: %s\n', ...
            'y2: %s\n', ...
            'distancia entre coordenadas: %s\n', ...
            '----------------------------------------------\n', ...
            'Tipo de programa: %s\n', ...
            'Genero: %s\n', ...
            'Peso: %s\n', ...
            'Altura: %s\n', ...
            'IMC: %s\n', ...
            '----------------------------------------------\n', ...
            'Tipo de programa: %s\n', ...
            'Horas trabajadas: %s\n', ...
            'Horas extras trabajadas: %s\n', ...
            'Precio horas extras trabajadas: %s\n', ...
            'Sueldo por semana: %s\n', ...
            '----------------------------------------------\n'], ...
            fecha_actual, resultados.nombre, ...
            resultados.tipo_programa1, num2str(resultados.x), num2str(resultados.factorial), ...
            resultados.tipo_programa2, num2str(resultados.intentos), resultados.usuario, resultados.contrasena, ...
            resultados.tipo_programa3, num2str(resultados.x1), num2str(resultados.y1), num2str(resultados.x2), num2str(resultados.y2), num2str(resultados.distancia), ...
            resultados.tipo_programa4, resultados.genero, num2str(resultados.peso), num2str(resultados.altura), num2str(resultados.imc), ...
            resultados.tipo_programa5, num2str(resultados.horas_trabajo), num2str(resultados.horas_extras), num2str(resultados.precio_hora_extra), num2str(resultados.sueldo_base));

        fprintf('Archivo salida.txt generado:\n');
        fprintf('%s\n', registro_txt);

        % Guardar en el archivo txt
        archivo = 'C:\Users\Melissa A\Documents\Cursos 2do semestre 2024\proyectos IE\PrimerParcial\salida.txt';
        fid = fopen(archivo, 'a');
        fprintf(fid, '%s', registro_txt);
        fclose(fid);
        disp('Operación guardada en el archivo de texto.');

        % Guardar en la base de datos factorial
        try
          query = "INSERT INTO factorial (nombre, numero, factorial) VALUES ($1, $2, $3)";
          params = {resultados.nombre, resultados.x, resultados.factorial};
          pq_exec_params(conn, query, params);
          disp('Datos guardados en la base de datos factorial.');
        catch ME
            fprintf('Error al guardar en la base de datos factorial: %s\n', ME.message);
        end

        % Guardar en la base de datos login
        try
          query = "INSERT INTO login (nombre, intentos, usuario, contraseña) VALUES ($1, $2, $3, $4)";
          params = {resultados.nombre, resultados.intentos, resultados.usuario, resultados.contrasena};
          pq_exec_params(conn, query, params);
          disp('Datos guardados en la base de datos login.');
        catch ME
            fprintf('Error al guardar en la base de datos login: %s\n', ME.message);
        end

        % Guardar en la base de datos distancia
        try
          query = "INSERT INTO distancia (nombre, x1, y1, x2, y2, distancia) VALUES ($1, $2, $3, $4, $5, $6)";
          params = {resultados.nombre, resultados.x1, resultados.y1, resultados.x2, resultados.y2, resultados.distancia};
          pq_exec_params(conn, query, params);
          disp('Datos guardados en la base de datos distancia.');
        catch ME
            fprintf('Error al guardar en la base de datos distancia: %s\n', ME.message);
        end

        % Guardar en la base de datos imc
        try
          query = "INSERT INTO imc (nombre, genero, peso, altura, imc) VALUES ($1, $2, $3, $4, $5)";
          params = {resultados.nombre, resultados.genero, resultados.peso, resultados.altura, resultados.imc};
          pq_exec_params(conn, query, params);
          disp('Datos guardados en la base de datos imc.');
        catch ME
            fprintf('Error al guardar en la base de datos imc: %s\n', ME.message);
        end

        % Guardar en la base de datos nominas
        try
          query = "INSERT INTO nominas (nombre, horas_trabajo, horas_extra, precio_hora_extra, sueldo_base) VALUES ($1, $2, $3, $4, $5)";
          params = {resultados.nombre, resultados.horas_trabajo, resultados.horas_extras, resultados.precio_hora_extra, resultados.sueldo_base};
          pq_exec_params(conn, query, params);
          disp('Datos guardados en la base de datos nominas.');
        catch ME
            fprintf('Error al guardar en la base de datos nominas: %s\n', ME.message);
        end

    catch ME
        fprintf('Error al registrar la operación: %s\n', ME.message);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mostrar_historial()
    global conn;

    opcionh = 0;
  while opcionh ~= 6
    fprintf('\n\t\tSeleccione Historial a consultar\n');
    fprintf('1. Factorial\n');
    fprintf('2. Login\n');
    fprintf('3. Distancia entre puntos\n');
    fprintf('4. IMC\n');
    fprintf('5. Nomina\n');
    fprintf('6. Salir\n');

  try
    opcionh = input('Seleccione una opción: ');
    if isempty(opcionh) || ~isnumeric(opcionh) || opcionh < 1 || opcionh > 6
      error('Entrada inválida. Por favor, ingrese un número entre 1 y 10.');
    endif
  catch ME
    fprintf('Error: %s\n', ME.message);
    continue;
  end

        switch opcionh
            case 1  %consulta historial factorial
              N=pq_exec_params(conn,'select*from factorial;')
            case 2 %consulta historial login
              N=pq_exec_params(conn,'select*from login;')
            case 3 %consulta historial cartesiano
              N=pq_exec_params(conn,'select*from cartesiano;')
            case 4 %consulta historial imc
              N=pq_exec_params(conn,'select*from imc;')
            case 5 %consulta historial nomina
              N=pq_exec_params(conn,'select*from nomina;')

            case 6 %salir
                fprintf('¡Gracias por consultar historial.\n');
            otherwise
                fprintf('Opción no válida. Intente nuevamente.\n');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function borrar_datos()
    global conn;
    try
        pq_exec_params(conn, "delete from factorial;");
        pq_exec_params(conn, "delete from login;");
        pq_exec_params(conn, "delete from distancia;");
        pq_exec_params(conn, "delete from imc;");
        pq_exec_params(conn, "delete from nominas;");
        fprintf('Todos los registros de la base de datos han sido eliminados.\n');
    catch ME
        fprintf('Error al borrar los datos de la base de datos: %s\n', ME.message);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mostrar_resultados()
    global resultados;
    disp('Valores actuales de resultados:');
    disp(resultados);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

menu();
pq_close(conn);
