import psycopg2
import os
import re
from datetime import datetime

# Configuración de la base de datos
DB_CONFIG = {
    'host': 'localhost',
    'database': 'retra1',
    'user': 'postgres',
    'password': 'hidrogeno',
    'port': '5432'
}

# Expresiones regulares para validación
NOMBRE_REGEX = re.compile(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{2,50}$')
EMAIL_REGEX = re.compile(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')

def conectar_db():
    """Establece conexión con la base de datos PostgreSQL"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"\n[!] Error de conexión a la base de datos: {e}")
        return None

def validar_nombre(nombre):
    """Valida que el nombre solo contenga letras y espacios"""
    if not NOMBRE_REGEX.match(nombre):
        print("[!] Nombre inválido. Solo debe contener letras y espacios (2-50 caracteres)")
        return False
    return True

def validar_email(email):
    """Valida el formato básico de un email"""
    if not EMAIL_REGEX.match(email):
        print("[!] Email inválido. Formato debe ser usuario@dominio.com")
        return False
    return True

def input_numerico(mensaje, min_val=0, max_val=None):
    """Solicita y valida un valor numérico"""
    while True:
        valor = input(mensaje).strip()
        if valor.isdigit():
            num = int(valor)
            if min_val is not None and num < min_val:
                print(f"[!] El valor debe ser mayor o igual a {min_val}")
                continue
            if max_val is not None and num > max_val:
                print(f"[!] El valor debe ser menor o igual a {max_val}")
                continue
            return num
        print("[!] Entrada inválida. Debe ser un número entero")

def registrar_cliente():
    """Registra un nuevo cliente o recupera existente"""
    print("\n--- REGISTRO DE CLIENTE ---")
    
    # Validar nombre
    while True:
        nombre = input("Nombre del cliente: ").strip()
        if validar_nombre(nombre):
            break
    
    # Validar email
    while True:
        email = input("Email del cliente: ").strip().lower()
        if validar_email(email):
            break
    
    conn = conectar_db()
    if conn is None:
        return None
    
    try:
        cursor = conn.cursor()
        # Verificar si el cliente existe
        cursor.execute(
            "SELECT id FROM clientes WHERE nombre_cliente = %s OR email = %s",
            (nombre, email)
        )
        cliente_existente = cursor.fetchone()
        
        if cliente_existente:
            print("\n[✓] Cliente ya registrado. Usando datos existentes")
            return cliente_existente[0]
        else:
            # Insertar nuevo cliente
            cursor.execute(
                "INSERT INTO clientes (nombre_cliente, email) VALUES (%s, %s) RETURNING id",
                (nombre, email)
            )
            cliente_id = cursor.fetchone()[0]
            conn.commit()
            print("\n[✓] Nuevo cliente registrado exitosamente")
            return cliente_id
    except Exception as e:
        print(f"\n[!] Error al registrar cliente: {e}")
        conn.rollback()
        return None
    finally:
        conn.close()

def mostrar_productos():
    """Muestra todos los productos disponibles"""
    conn = conectar_db()
    if conn is None:
        return []
    
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, nombre_producto, precio_unitario FROM productos")
        productos = cursor.fetchall()
        
        if not productos:
            print("\n[!] No hay productos disponibles en el inventario")
            return []
        
        print("\n--- PRODUCTOS DISPONIBLES ---")
        print("ID  | Nombre".ljust(35) + " | Precio Unitario")
        print("-" * 55)
        for prod in productos:
            print(f"{str(prod[0]).ljust(3)} | {prod[1].ljust(30)} | Q{prod[2]:.2f}")
        
        return productos
    except Exception as e:
        print(f"\n[!] Error al cargar productos: {e}")
        return []
    finally:
        conn.close()

def seleccionar_productos():
    """Permite al usuario seleccionar productos y cantidades"""
    productos = mostrar_productos()
    if not productos:
        return []
    
    seleccionados = []
    ids_disponibles = [str(p[0]) for p in productos]
    
    while True:
        print("\nIngrese ID del producto (0 para finalizar)")
        prod_id = input("> ").strip()
        
        if prod_id == '0':
            if seleccionados:
                break
            else:
                print("[!] Debe seleccionar al menos un producto")
                continue
        
        # Validar ID numérico
        if not prod_id.isdigit():
            print("[!] ID debe ser un número. Intente nuevamente")
            continue
            
        prod_id = int(prod_id)
        
        # Verificar existencia del producto
        producto = next((p for p in productos if p[0] == prod_id), None)
        if not producto:
            print("[!] ID de producto inválido")
            continue
        
        # Validar cantidad
        cantidad = input_numerico(
            f"Cantidad para '{producto[1]}': ",
            min_val=1,
            max_val=1000
        )
        
        subtotal = cantidad * producto[2]
        seleccionados.append({
            'id': producto[0],
            'nombre': producto[1],
            'precio': producto[2],
            'cantidad': cantidad,
            'subtotal': subtotal
        })
        
        print(f"[✓] Agregado: {cantidad} x {producto[1]} = Q{subtotal:.2f}")
    
    return seleccionados

def generar_factura(cliente_id, productos):
    """Guarda la factura en la base de datos y genera archivo"""
    if not productos:
        print("\n[!] Operación cancelada. No hay productos para facturar")
        return
    
    conn = conectar_db()
    if conn is None:
        return
    
    try:
        cursor = conn.cursor()
        
        # Obtener datos del cliente
        cursor.execute("SELECT nombre_cliente, email FROM clientes WHERE id = %s", (cliente_id,))
        cliente = cursor.fetchone()
        
        if not cliente:
            print("\n[!] Cliente no encontrado en la base de datos")
            return
        
        nombre_cliente, email_cliente = cliente
        total = sum(p['subtotal'] for p in productos)
        
        # Insertar factura
        cursor.execute(
            "INSERT INTO facturas (cliente_id, total) VALUES (%s, %s) RETURNING id",
            (cliente_id, total)
        )
        factura_id = cursor.fetchone()[0]
        
        # Insertar detalles
        for prod in productos:
            cursor.execute(
                "INSERT INTO detalles_factura (factura_id, producto_id, cantidad, subtotal) "
                "VALUES (%s, %s, %s, %s)",
                (factura_id, prod['id'], prod['cantidad'], prod['subtotal'])
            )
        
        conn.commit()
        
        # Mostrar resumen
        print("\n--- RESUMEN DE FACTURA ---")
        print(f"Cliente: {nombre_cliente}")
        print(f"Email: {email_cliente}")
        print("\nProductos:")
        for prod in productos:
            print(f"- {prod['nombre']}: {prod['cantidad']} x Q{prod['precio']:.2f} = Q{prod['subtotal']:.2f}")
        print("-" * 40)
        print(f"TOTAL A PAGAR: Q{total:.2f}")
        print("-" * 40)
        
        # Generar archivo de texto
        guardar_factura_txt(factura_id, nombre_cliente, email_cliente, productos, total)
        
    except Exception as e:
        print(f"\n[!] Error al generar factura: {e}")
        conn.rollback()
    finally:
        conn.close()

def guardar_factura_txt(factura_id, cliente, email, productos, total):
    """Guarda la factura en un archivo de texto"""
    try:
        fecha = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        nombre_archivo = "factura.txt"
        modo = 'a' if os.path.exists(nombre_archivo) else 'w'
        
        with open(nombre_archivo, modo, encoding='utf-8') as f:
            f.write("\n" + "=" * 60 + "\n")
            f.write(f"FACTURA ELECTRÓNICA - RETRA1\n")
            f.write("=" * 60 + "\n")
            f.write(f"ID Factura: {factura_id}\n")
            f.write(f"Fecha: {fecha}\n")
            f.write(f"Cliente: {cliente}\n")
            f.write(f"Email: {email}\n")
            f.write("-" * 60 + "\n")
            f.write("DETALLE DE COMPRA:\n\n")
            f.write("{:<5} {:<30} {:<10} {:<10} {:<10}\n".format(
                "CANT", "PRODUCTO", "P. UNIT", "SUBTOTAL", "ID"))
            f.write("-" * 60 + "\n")
            
            for prod in productos:
                f.write("{:<5} {:<30} Q{:<9.2f} Q{:<9.2f} {:<10}\n".format(
                    prod['cantidad'],
                    prod['nombre'],
                    prod['precio'],
                    prod['subtotal'],
                    prod['id']))
            
            f.write("-" * 60 + "\n")
            f.write(f"TOTAL: Q{total:.2f}\n")
            f.write("=" * 60 + "\n\n")
        
        print(f"\n[✓] Factura guardada en '{nombre_archivo}'")
    except Exception as e:
        print(f"\n[!] Error al guardar archivo: {e}")

def consultar_facturas():
    """Consulta facturas anteriores por email de cliente"""
    print("\n--- CONSULTA DE FACTURAS ---")
    
    # Validar email
    while True:
        email = input("Ingrese email del cliente: ").strip().lower()
        if validar_email(email):
            break
    
    conn = conectar_db()
    if conn is None:
        return
    
    try:
        cursor = conn.cursor()
        # Obtener cliente
        cursor.execute(
            "SELECT id, nombre_cliente FROM clientes WHERE email = %s", 
            (email,))
        cliente = cursor.fetchone()
        
        if not cliente:
            print("\n[!] Cliente no encontrado")
            return
        
        cliente_id, nombre_cliente = cliente
        
        # Obtener facturas del cliente
        cursor.execute(
            "SELECT id, fecha, total FROM facturas WHERE cliente_id = %s ORDER BY fecha DESC",
            (cliente_id,))
        facturas = cursor.fetchall()
        
        if not facturas:
            print("\n[!] No se encontraron facturas para este cliente")
            return
        
        print(f"\nFacturas de {nombre_cliente} ({email}):")
        print("-" * 50)
        for fact in facturas:
            print(f"Factura #{fact[0]} - {fact[1].strftime('%d/%m/%Y')} - Total: Q{fact[2]:.2f}")
        
        # Detalle de una factura específica
        fact_id = input("\nIngrese ID de factura para detalles (0 para salir): ").strip()
        if fact_id == '0':
            return
        
        # Validar ID numérico
        if not fact_id.isdigit():
            print("[!] ID de factura debe ser un número")
            return
            
        fact_id = int(fact_id)
        
        if fact_id not in [f[0] for f in facturas]:
            print("[!] ID de factura inválido")
            return
        
        cursor.execute(
            "SELECT p.nombre_producto, d.cantidad, d.subtotal, d.producto_id "
            "FROM detalles_factura d "
            "JOIN productos p ON d.producto_id = p.id "
            "WHERE d.factura_id = %s",
            (fact_id,))
        detalles = cursor.fetchall()
        
        print(f"\nDETALLE FACTURA #{fact_id}")
        print("-" * 60)
        for det in detalles:
            print(f"{det[1]} x {det[0]} (ID: {det[3]}) = Q{det[2]:.2f}")
        print("-" * 60)
            
    except Exception as e:
        print(f"\n[!] Error en consulta: {e}")
    finally:
        conn.close()

def menu_principal():
    """Muestra el menú principal del sistema"""
    while True:
        print("\n--- SISTEMA DE FACTURACIÓN RETRA1 ---")
        print("1. Registrar nuevo cliente")
        print("2. Crear nueva factura")
        print("3. Consultar facturas existentes")
        print("4. Salir")
        
        opcion = input("\nSeleccione una opción: ").strip()
        
        if opcion == '1':
            registrar_cliente()
        elif opcion == '2':
            cliente_id = registrar_cliente()
            if cliente_id:
                productos = seleccionar_productos()
                if productos:
                    generar_factura(cliente_id, productos)
        elif opcion == '3':
            consultar_facturas()
        elif opcion == '4':
            print("\n[✓] Sistema cerrado. ¡Hasta pronto!")
            break
        else:
            print("\n[!] Opción inválida. Intente nuevamente")

if __name__ == "__main__":
    print("\n" + "=" * 50)
    print("SISTEMA DE FACTURACIÓN PARA TIENDA DE ELECTRÓNICA")
    print("=" * 50)
    menu_principal()