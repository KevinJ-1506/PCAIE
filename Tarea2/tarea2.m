if(exist('OCTAVE_VERSION', 'builtin')~= 0)
pkg load database;
end
conn = pq_connect(setdbopts('dbname','tarea2','host','localhost','port','5432','user','postgres','password','hidrogeno'))
opcion = 0;
while opcion ~=4
  disp('Seleccione una opción:')
  disp('1.Consultar tabla')
  disp('2.insertar datos a la tabla')
  disp('3.Borrar datos')
  disp('4.Salir')
  opcion = input('Ingrese su Elección:');
  if isempty(opcion) || ~isnumeric(opcion) || opcion <= 0
          disp('opcion inválido.');
          continue;
        end
    switch opcion
      case 1
        % Ingreso de datos
      try
        tabla = input('Ingrese nombre de la tabla: ', 's');
        if isempty(tabla) || ~ischar(tabla) || ~isempty(str2num(tabla))
          disp('Error: El nombre no puede ser un número o estar vacío. Intenta de nuevo.');
          continue;
        end
        tab = cstrcat('select*from ',tabla,';');
        N=pq_exec_params(conn,tab)

      catch
        disp('Error de consulta.');
      end_try_catch

      case 2
      try
        nombre = input('Ingrese el Nombre: ', 's');
        if isempty(nombre) || ~ischar(nombre) || ~isempty(str2num(nombre))
          disp('Error: El nombre no puede ser un número o estar vacío. Intenta de nuevo.');
          continue;
        end

        carnet = input('Ingrese No.Carnet: ');
        if isempty(carnet) || ~isnumeric(carnet) || carnet <= 0
          disp('identificacion inválido. Debe ser un número positivo.');
          continue;
        end
        car = int2str(carnet);
        ingreso = cstrcat("insert into redes values('",nombre,"',",car,");");
        N=pq_exec_params(conn,ingreso)
         catch
        disp('Error de ingreso de datos.');
      end_try_catch

      case 3
      try
        borrado = input('Ingrese nombre a de registro: ', 's');
        if isempty(tabla) || ~ischar(tabla) || ~isempty(str2num(tabla))
          disp('Error: El nombre no puede ser un número o estar vacío. Intenta de nuevo.');
          continue;
        end
        tab = cstrcat("Delete from redes where nombre = '",borrado,"';");
        N=pq_exec_params(conn,tab)

      catch
        disp('Error de consulta.');
      end_try_catch
      case 4
        disp('Saliendo del Programa.....');
      otherwise
        disp('Opción no valida.');
    end
 end
