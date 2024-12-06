% Pedir al usuario que ingrese un número

n = input('Ingresa un número entero positivo: ');



try

    % Calcular el factorial usando la función calcularFactorial
3
    if n < 0

        error('El factorial no está definido para números negativos.');

    elseif n == 0 || n == 1

        factorial = 1;

    else

        factorial = 1;

        for i = 2:n

            factorial = factorial * i;

        end

    end

    % Mostrar el resultado

    fprintf('El factorial de %d es %d\n', n, factorial);

catch e

    % Manejar el error si el usuario ingresa un número negativo o no entero

    fprintf('Error: %s\n', e.message);

end
