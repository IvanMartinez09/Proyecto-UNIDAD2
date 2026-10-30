; Proyecto Unidad 2 - Lenguajes de Interfaz
; Docente: Dr. Jose Luis Medina Jimenez
; Tienda de Electronica: inventario y ventas
; Integrantes: (Jose Angel Grande Espinoza), (Jesus Ivan Martinez Reyes), (Angel Ernesto Santos Plazola)
;
; Regla de negocio: alerta de existencia minima.
; Si un producto queda con 5 piezas o menos se avisa que hay que resurtir.

INCLUDE Irvine32.inc

.data
; ---- catalogo ----
catalogo     BYTE 440 DUP(0)        
numProd      DWORD 0                
catTemp      BYTE 440 DUP(0)        
numTemp      DWORD 0                

; ---- datos de la sesion ----
ingresos     DWORD 0                
ventasHechas DWORD 0                
hayCambios   DWORD 0                

; ---- buffers ----
bufEntrada   BYTE 81 DUP(0)         
bufCodigo    BYTE 8 DUP(0)          
bufNombre    BYTE 26 DUP(0)         
bufNum       BYTE 11 DUP(0)         
bufCampo     BYTE 41 DUP(0)         

; ---- validacion ----
limiteMin    DWORD ?               
limiteMax    DWORD ?                
msgPedir     DWORD ?                
precioPesos  DWORD ?               
precioCent   DWORD ?              
cuentaEnt    DWORD ?                
cuentaDec    DWORD ?                
hayPunto     DWORD ?               
diez         DWORD 10
cien         DWORD 100
nuevoPrecio  DWORD ?                
nuevaExis    DWORD ?                
cantidad     DWORD ?                
importe      DWORD ?              
nuevosIngresos DWORD ?             
centavosTmp  DWORD ?             
cuantosBajos DWORD ?               
; ---- archivo ----
archDefault  BYTE "inventario.txt",0
nombreArch   BYTE 61 DUP(0)         
handleArch   DWORD ?                
bufArchivo   BYTE 1001 DUP(0)       
bytesPedidos DWORD ?               
bytesLeidos  DWORD ?                
lineaArch    DWORD ?                
msgErrArch   DWORD ?                
txtSep       BYTE "|",0
txtFinLinea  BYTE 0Dh,0Ah,0

; ---- mensajes ----
msgTitulo   BYTE "=====================================================",0Dh,0Ah
            BYTE "     TIENDA DE ELECTRONICA  -  Inventario y Ventas",0Dh,0Ah
            BYTE "=====================================================",0
msgMenu     BYTE " 1. Registrar producto",0Dh,0Ah
            BYTE " 2. Mostrar inventario",0Dh,0Ah
            BYTE " 3. Buscar producto por codigo",0Dh,0Ah
            BYTE " 4. Recibir mercancia",0Dh,0Ah
            BYTE " 5. Vender",0Dh,0Ah
            BYTE " 6. Resumen",0Dh,0Ah
            BYTE " 7. Guardar catalogo",0Dh,0Ah
            BYTE " 8. Cargar catalogo",0Dh,0Ah
            BYTE " 0. Salir",0Dh,0Ah
            BYTE "Opcion: ",0
msgOpcionMal BYTE "  Opcion no valida, escribe un numero del 0 al 8.",0

msgPideCodigo  BYTE "Codigo (formato ABC-123): ",0
msgPideNombre  BYTE "Nombre (1 a 25 caracteres): ",0
msgPidePrecio  BYTE "Precio en MXN (ejempl: 185.50): ",0
msgPideExis    BYTE "Existencia inicial (0 a 100): ",0
msgPideCantE   BYTE "Unidades recibidas: ",0
msgPideCantV   BYTE "Unidades a vender: ",0

msgVacio       BYTE "  No se permiten datos vacios.",0
msgCodMal      BYTE "  Codigo incorrecto. Deben ser 3 letras MAYUSCULAS, guion y 3 digitos.",0
msgNomMal      BYTE "  Nombre invalido (1 a 25 caracteres, sin '|' y sin iniciar con espacio).",0
msgPrecioMal   BYTE "  Precio con formato incorrecto. Usa solo digitos y un punto con 1 o 2 decimales.",0
msgPrecioRango BYTE "  Precio fuera de rango ($0.01 a $9999.99 MXN).",0
msgNumMal      BYTE "  Solo se permiten digitos (sin signos, espacios ni punto).",0
msgRango1      BYTE "  Valor fuera de rango. Debe estar entre ",0
msgRango2      BYTE " y ",0

msgLleno       BYTE "  Catalogo lleno: ya hay 10 productos registrados.",0
msgDuplicado   BYTE "  Ese codigo ya existe. No se registro el producto.",0
msgRegistrado  BYTE "  Producto registrado.",0
msgNoExiste    BYTE "  No existe un producto con ese codigo.",0
msgEncontrado  BYTE "  Producto encontrado:",0
msgSinProd     BYTE "  (No hay productos registrados)",0
msgInvTitulo   BYTE "---------------- INVENTARIO ----------------",0

msgExcede1     BYTE "  Rechazado: se excederian las 100 unidades. Solo caben ",0
msgExcede2     BYTE " unidades mas.",0
msgRecibido    BYTE "  Mercancia recibida. Nueva existencia: ",0

msgSinExis     BYTE "  Venta rechazada: el producto no tiene existencias.",0
msgInsuf1      BYTE "  Venta rechazada: existencias insuficientes (hay ",0
msgInsuf2      BYTE ").",0
msgDesborde    BYTE "  Operacion rechazada: desbordamiento en el calculo.",0
msgTicket      BYTE "---------------- TICKET DE VENTA ----------------",0
msgTkPrecio    BYTE "  Precio unitario : ",0
msgTkCant      BYTE "  Cantidad        : ",0
msgTkTotal     BYTE "  TOTAL A PAGAR   : ",0
msgVendido     BYTE "  Venta registrada. Existencia restante: ",0
msgAlerta      BYTE "  ALERTA: quedan 5 piezas o menos, hay que resurtir este producto.",0
msgSinAlerta   BYTE "  Existencia suficiente (mas de 5 piezas), no hay alerta.",0

msgResTitulo   BYTE "------------------- RESUMEN -------------------",0
msgResProd     BYTE "  Productos registrados   : ",0
msgResUnid     BYTE "  Unidades disponibles    : ",0
msgResValor    BYTE "  Valor del inventario    : ",0
msgResIngr     BYTE "  Ingresos de la sesion   : ",0
msgResVentas   BYTE "  Ventas realizadas       : ",0
msgResBajos    BYTE "  Productos por resurtir  : ",0

msgPideArch    BYTE "Nombre del archivo (Enter = inventario.txt): ",0
msgNadaGuardar BYTE "  No hay productos para guardar.",0
msgErrCrear    BYTE "  No se pudo crear el archivo.",0
msgErrEscribir BYTE "  Error al escribir: no se escribieron todos los bytes.",0
msgGuardado1   BYTE "  Catalogo guardado. Bytes escritos: ",0
msgErrAbrir    BYTE "  El archivo no existe o no se pudo abrir. Se conserva el catalogo actual.",0
msgErrLeer     BYTE "  Error al leer el archivo. Se conserva el catalogo actual.",0
msgArchVacio   BYTE "  El archivo esta vacio. Se conserva el catalogo actual.",0
msgArchGrande  BYTE "  El archivo es demasiado grande. Se conserva el catalogo actual.",0
msgArchMal1    BYTE "  Archivo invalido, linea ",0
msgArchMal2    BYTE ": ",0
msgArchMal3    BYTE "      No se cargo nada, se conserva el catalogo actual.",0
msgCargado1    BYTE "  Catalogo cargado. Productos: ",0
msgBytesLei    BYTE "  Bytes leidos del archivo: ",0

errFormato     BYTE "formato de linea incorrecto",0
errCodigo      BYTE "codigo invalido",0
errDupl        BYTE "codigo duplicado",0
errNombre      BYTE "nombre invalido",0
errPrecio      BYTE "precio invalido o fuera de rango",0
errExis        BYTE "existencia invalida o fuera de rango",0
errMuchos      BYTE "hay mas de 10 productos",0
errNinguno     BYTE "no contiene productos",0

msgSalirAviso  BYTE "Hay cambios sin guardar. Guardar antes de salir? (S/N): ",0

txtCodigo      BYTE "  ",0
txtBarra       BYTE " | ",0
txtExis        BYTE " | Exist: ",0
txtBaja        BYTE "  EXISTENCIA BAJA",0
txtParen       BYTE ") ",0
txtPesos       BYTE "$",0
txtPunto       BYTE ".",0
txtCero        BYTE "0",0
txtMXN         BYTE " MXN",0

.code
; ---- main ----
; Muestra el menu, lee la opcion y llama al procedimiento que toca.
; Se repite hasta que el usuario escribe 0.
main PROC
menuPrincipal:
    call Crlf
    mov  edx, OFFSET msgTitulo      ; EDX = direccion del titulo
    call WriteString                ; lo mostramos
    call Crlf
    mov  edx, OFFSET msgMenu        ; mostramos las opciones
    call WriteString
    call LeerOpcion                 ; EAX = opcion elegida (o -1 si no sirve)
    call Crlf

    cmp  eax, 1                     ; comparamos la opcion con cada numero
    je   opRegistrar
    cmp  eax, 2
    je   opInventario
    cmp  eax, 3
    je   opBuscar
    cmp  eax, 4
    je   opRecibir
    cmp  eax, 5
    je   opVender
    cmp  eax, 6
    je   opResumen
    cmp  eax, 7
    je   opGuardar
    cmp  eax, 8
    je   opCargar
    cmp  eax, 0
    je   opSalir

    mov  edx, OFFSET msgOpcionMal   ; si no fue ninguna, opcion invalida
    call WriteString
    call Crlf
    jmp  menuPrincipal              ; regresamos al menu

opRegistrar:
    call RegistrarProducto
    jmp  menuPrincipal
opInventario:
    call MostrarInventario
    jmp  menuPrincipal
opBuscar:
    call BuscarProducto
    jmp  menuPrincipal
opRecibir:
    call RecibirMercancia
    jmp  menuPrincipal
opVender:
    call VenderProducto
    jmp  menuPrincipal
opResumen:
    call MostrarResumen
    jmp  menuPrincipal
opGuardar:
    call GuardarCatalogo
    jmp  menuPrincipal
opCargar:
    call CargarCatalogo
    jmp  menuPrincipal

opSalir:
    call ConfirmarSalida            ; pregunta si hay cambios sin guardar
    exit
main ENDP

; ---- LeerOpcion ----
; Recibe: nada
; Regresa: EAX = opcion de 0 a 8, o -1 si no es valida
; Cambia: EAX
LeerOpcion PROC
    push ebx                        ; guardamos los registros que usamos
    push ecx
    push edx
    push esi

    mov  edx, OFFSET bufEntrada     ; EDX = donde se guarda lo que se teclea
    mov  ecx, 80                    ; ECX = maximo de caracteres
    call ReadString                 ; EAX = cuantos caracteres se escribieron
    cmp  eax, 1                     ; la opcion debe ser de 1 caracter
    jne  loInvalida

    mov  esi, OFFSET bufEntrada     ; ESI apunta al texto
    mov  ecx, eax                   ; ECX = largo del texto
    call ConvertirEntero            ; EAX = numero, EBX = 1 si era valido
    cmp  ebx, 1
    jne  loInvalida                 ; no era un digito
    cmp  eax, 8
    ja   loInvalida                 ; mayor a 8 no existe en el menu
    jmp  loFin

loInvalida:
    mov  eax, -1                    ; -1 = opcion no valida
loFin:
    pop  esi                        ; sacamos en orden inverso
    pop  edx
    pop  ecx
    pop  ebx
    ret
LeerOpcion ENDP

; ---- ValidarCodigo ----
; Revisa el formato ABC-123
; Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = 1 si es valido, 0 si no
; Cambia: EAX
ValidarCodigo PROC
    push ebx
    push ecx
    push esi

    cmp  ecx, 7                     ; el codigo mide exactamente 7
    jne  vcMal

    mov  ebx, 0                     ; EBX = posicion (0, 1, 2)
vcLetras:
    mov  al, [esi]                  ; AL = caracter actual
    cmp  al, 'A'                    ; menor que 'A' no es mayuscula
    jb   vcMal
    cmp  al, 'Z'                    ; mayor que 'Z' no es mayuscula
    ja   vcMal
    inc  esi                        ; siguiente caracter
    inc  ebx                        ; siguiente posicion
    cmp  ebx, 3                     ; repetimos mientras sea menor a 3
    jb   vcLetras

    mov  al, [esi]                  ; posicion 3: debe ser el guion
    cmp  al, '-'
    jne  vcMal
    inc  esi

    mov  ecx, 3                     ; faltan 3 digitos, LOOP usa ECX
vcDigitos:
    mov  al, [esi]
    cmp  al, '0'                    ; menor que '0' no es digito
    jb   vcMal
    cmp  al, '9'                    ; mayor que '9' no es digito
    ja   vcMal
    inc  esi
    loop vcDigitos                  ; ECX - 1, repite si no es 0

    mov  eax, 1                     ; paso todo, es valido
    jmp  vcFin
vcMal:
    mov  eax, 0                     ; algo fallo
vcFin:
    pop  esi
    pop  ecx
    pop  ebx
    ret
ValidarCodigo ENDP

; ---- ValidarNombre ----
; Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = 1 si es valido, 0 si no
; Cambia: EAX
ValidarNombre PROC
    push ecx
    push esi

    cmp  ecx, 0                     ; vacio no se acepta
    je   vnMal
    cmp  ecx, 25                    ; mas de 25 letras no se acepta
    ja   vnMal

    mov  al, [esi]                  ; revisamos la primera letra
    cmp  al, ' '                    ; no puede empezar con espacio
    je   vnMal

vnCiclo:
    mov  al, [esi]                  ; AL = caracter actual
    cmp  al, ' '                    ; menor a espacio = caracter de control
    jb   vnMal
    cmp  al, '|'                    ; el '|' lo usamos en el archivo pa que se mire en formato tabla
    je   vnMal
    inc  esi                        ; siguiente caracter
    loop vnCiclo                    ; se repite una vez por cada caracter

    mov  eax, 1                     ; nombre valido
    jmp  vnFin
vnMal:
    mov  eax, 0                     ; nombre invalido
vnFin:
    pop  esi
    pop  ecx
    ret
ValidarNombre ENDP

; ---- ConvertirEntero ----
; Convierte un texto de digitos a numero: acumulado = acumulado * 10 + digito
; Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = numero, EBX = 1 si es valido, 0 si no
; Cambia: EAX, EBX
ConvertirEntero PROC
    push ecx
    push edx
    push esi
    push edi

    mov  eax, 0                     ; acumulado empieza en 0
    cmp  ecx, 0                     ; texto vacio
    je   ceMal
    mov  edi, 10                    ; EDI = 10 para multiplicar

ceCiclo:
    mov  ebx, 0                     ; limpiamos EBX
    mov  bl, [esi]                  ; BL = caracter actual
    cmp  bl, '0'                    ; si no esta entre '0' y '9' no es digito
    jb   ceMal
    cmp  bl, '9'
    ja   ceMal
    sub  bl, '0'                    ; '7' - '0' = 7 (de caracter a numero)

    mul  edi                        ; EDX:EAX = acumulado * 10
    cmp  edx, 0                     ; si EDX no es 0 ya no cabe en 32 bits
    jne  ceMal
    add  eax, ebx                   ; le sumamos el digito
    jb   ceMal                      ; CF = 1 (acarreo): se desbordo

    inc  esi                        ; siguiente caracter
    loop ceCiclo

    mov  ebx, 1                     ; todo bien
    jmp  ceFin
ceMal:
    mov  eax, 0
    mov  ebx, 0                     ; no es valido
ceFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    ret
ConvertirEntero ENDP

; ---- ConvertirPrecio ----
; Convierte un precio en pesos a centavos: "185.50" -> 18550
; Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = centavos, EBX = 1 valido, 0 formato malo, 2 fuera de rango
; Cambia: EAX, EBX
ConvertirPrecio PROC
    push ecx
    push edx                        ; MUL cambia EDX, por eso lo guardamos
    push esi

    mov  precioPesos, 0             ; empezamos todo en 0
    mov  precioCent, 0
    mov  cuentaEnt, 0
    mov  cuentaDec, 0
    mov  hayPunto, 0

    cmp  ecx, 0                     ; texto vacio
    je   cpFormato

cpCiclo:
    mov  ebx, 0
    mov  bl, [esi]                  ; BL = caracter actual
    cmp  bl, '.'                    ; es el punto?
    je   cpPunto
    cmp  bl, '0'                    ; si no es digito: $, coma, letra, etc.
    jb   cpFormato
    cmp  bl, '9'
    ja   cpFormato
    sub  bl, '0'                    ; caracter a numero

    cmp  hayPunto, 1                ; si ya paso el punto es decimal
    je   cpDecimal

    mov  eax, precioPesos           ; digito de los pesos
    mul  diez                       ; pesos * 10
    cmp  edx, 0                     ; numero demasiado grande
    jne  cpRango
    add  eax, ebx                   ; + digito
    jb   cpRango                    ; CF = 1 (acarreo): no cabe
    mov  precioPesos, eax
    inc  cuentaEnt                  ; contamos digitos antes del punto
    jmp  cpSiguiente

cpDecimal:
    cmp  cuentaDec, 2               ; ya habia 2 decimales, este seria el tercero
    jae  cpFormato
    mov  eax, precioCent            ; digito de los centavos
    mul  diez                       ; centavos * 10
    add  eax, ebx                   ; + digito
    mov  precioCent, eax
    inc  cuentaDec                  ; contamos decimales
    jmp  cpSiguiente

cpPunto:
    cmp  hayPunto, 1                ; un segundo punto no se acepta
    je   cpFormato
    cmp  cuentaEnt, 0               ; ".50" no tiene pesos antes del punto
    je   cpFormato
    mov  hayPunto, 1                ; marcamos que ya aparecio el punto

cpSiguiente:
    inc  esi                        ; siguiente caracter
    dec  ecx                        ; uno menos por revisar
    jne  cpCiclo                   

    cmp  hayPunto, 1                ; si no hubo punto, ya esta
    jne  cpArmar
    cmp  cuentaDec, 0               ; "185." tiene punto pero no decimales
    je   cpFormato
    cmp  cuentaDec, 1               ; con 2 decimales ya esta
    jne  cpArmar
    mov  eax, precioCent            ; con 1 decimal: 185.5 son 50 centavos
    mul  diez
    mov  precioCent, eax

cpArmar:
    cmp  precioPesos, 9999          ; mas de 9999 pesos no se acepta
    ja   cpRango
    mov  eax, precioPesos
    mul  cien                       ; pesos * 100
    add  eax, precioCent            ; + centavos
    cmp  eax, 1                     ; menos de 1 centavo ($0.00) no vale
    jb   cpRango
    cmp  eax, 999999                ; mas de $9999.99 no vale
    ja   cpRango
    mov  ebx, 1                     ; precio valido
    jmp  cpFin

cpFormato:
    mov  eax, 0
    mov  ebx, 0                     ; formato incorrecto
    jmp  cpFin
cpRango:
    mov  eax, 0
    mov  ebx, 2                     ; fuera de rango
cpFin:
    pop  esi
    pop  edx
    pop  ecx
    ret
ConvertirPrecio ENDP

; ---- CapturarCodigo ----
; Pide el codigo hasta que sea valido y lo copia a bufCodigo
; Recibe: nada
; Regresa: bufCodigo con el codigo
; Cambia: nada
CapturarCodigo PROC
    push eax
    push ecx
    push edx
    push esi
    push edi

ccPedir:
    mov  edx, OFFSET msgPideCodigo
    call WriteString
    mov  edx, OFFSET bufEntrada     ; EDX = donde se guarda
    mov  ecx, 80                    ; ECX = maximo de caracteres
    call ReadString                 ; EAX = caracteres leidos
    cmp  eax, 0                     ; solo dio Enter
    je   ccVacio

    mov  esi, OFFSET bufEntrada     ; revisamos el formato
    mov  ecx, eax
    call ValidarCodigo
    cmp  eax, 1
    jne  ccMal

    mov  esi, OFFSET bufEntrada     ; copiamos los 7 caracteres + 00h
    mov  edi, OFFSET bufCodigo
    mov  ecx, 8
    call CopiarBytes
    jmp  ccFin

ccVacio:
    mov  edx, OFFSET msgVacio
    call WriteString
    call Crlf
    jmp  ccPedir                    ; lo pedimos otra vez
ccMal:
    mov  edx, OFFSET msgCodMal
    call WriteString
    call Crlf
    jmp  ccPedir
ccFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  eax
    ret
CapturarCodigo ENDP

; ---- CapturarNombre ----
; Pide el nombre hasta que sea valido y lo copia a bufNombre
; Recibe: nada
; Regresa: bufNombre con el nombre
; Cambia: nada
CapturarNombre PROC
    push eax
    push ecx
    push edx
    push esi
    push edi

cnPedir:
    mov  edx, OFFSET msgPideNombre
    call WriteString
    mov  edx, OFFSET bufEntrada
    mov  ecx, 80                    ; dejamos escribir de mas para saber si pasa de 25
    call ReadString
    cmp  eax, 0
    je   cnVacio

    mov  esi, OFFSET bufEntrada
    mov  ecx, eax
    call ValidarNombre
    cmp  eax, 1
    jne  cnMal

    inc  ecx                        ; largo + 1 para copiar tambien el 00h
    mov  esi, OFFSET bufEntrada
    mov  edi, OFFSET bufNombre
    call CopiarBytes
    jmp  cnFin

cnVacio:
    mov  edx, OFFSET msgVacio
    call WriteString
    call Crlf
    jmp  cnPedir
cnMal:
    mov  edx, OFFSET msgNomMal
    call WriteString
    call Crlf
    jmp  cnPedir
cnFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  eax
    ret
CapturarNombre ENDP

; ---- CapturarPrecio ----
; Pide el precio hasta que sea valido
; Recibe: nada
; Regresa: EAX = precio en centavos
; Cambia: EAX
CapturarPrecio PROC
    push ebx
    push ecx
    push edx
    push esi

cprPedir:
    mov  edx, OFFSET msgPidePrecio
    call WriteString
    mov  edx, OFFSET bufEntrada
    mov  ecx, 80
    call ReadString
    cmp  eax, 0
    je   cprVacio

    mov  esi, OFFSET bufEntrada
    mov  ecx, eax
    call ConvertirPrecio            ; EAX = centavos, EBX = resultado
    cmp  ebx, 1                     ; 1 = valido
    je   cprListo
    cmp  ebx, 2                     ; 2 = fuera de rango
    je   cprRango

    mov  edx, OFFSET msgPrecioMal   ; 0 = formato incorrecto
    call WriteString
    call Crlf
    jmp  cprPedir
cprRango:
    mov  edx, OFFSET msgPrecioRango
    call WriteString
    call Crlf
    jmp  cprPedir
cprVacio:
    mov  edx, OFFSET msgVacio
    call WriteString
    call Crlf
    jmp  cprPedir
cprListo:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret
CapturarPrecio ENDP

; ---- CapturarNumero ----
; Pide un numero entero hasta que este dentro del rango
; Recibe: EDX = mensaje, EBX = minimo, ECX = maximo
; Regresa: EAX = numero
; Cambia: EAX
CapturarNumero PROC
    push ebx
    push ecx
    push edx
    push esi

    mov  msgPedir, edx             
    mov  limiteMin, ebx             
    mov  limiteMax, ecx

cnuPedir:
    mov  edx, msgPedir              ; mostramos el mensaje
    call WriteString
    mov  edx, OFFSET bufEntrada
    mov  ecx, 80
    call ReadString
    cmp  eax, 0
    je   cnuVacio

    mov  esi, OFFSET bufEntrada
    mov  ecx, eax
    call ConvertirEntero            ; EAX = numero, EBX = 1 si es valido
    cmp  ebx, 1
    jne  cnuNoNumero
    cmp  eax, limiteMin             ; menor al minimo
    jb   cnuRango
    cmp  eax, limiteMax             ; mayor al maximo
    ja   cnuRango
    jmp  cnuFin                     ; numero correcto

cnuVacio:
    mov  edx, OFFSET msgVacio
    call WriteString
    call Crlf
    jmp  cnuPedir
cnuNoNumero:
    mov  edx, OFFSET msgNumMal
    call WriteString
    call Crlf
    jmp  cnuPedir
cnuRango:
    mov  edx, OFFSET msgRango1      ; debe estar en el rango
    call WriteString
    mov  eax, limiteMin
    call MostrarNumero
    mov  edx, OFFSET msgRango2
    call WriteString
    mov  eax, limiteMax
    call MostrarNumero
    call Crlf
    jmp  cnuPedir

cnuFin:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret
CapturarNumero ENDP

; ---- convertirDecimal ----
; Convierte un numero a texto dividiendo entre 10
; Recibe: EAX = numero, ESI = direccion del buffer (11 bytes)
; Regresa: el texto en el buffer, EAX = cuantos digitos tiene
; Cambia: EAX
convertirDecimal PROC
    push ebx
    push ecx
    push edx
    push esi

    mov  ebx, 10                    ;  dividimos entre 10
    mov  ecx, 0                     ; ECX cuenta los digitos
cdDividir:
    mov  edx, 0                     ; EDX en 0 porque DIV usa EDX:EAX
    div  ebx                        ; EAX = cociente, EDX = residuo (el digito)
    push edx                        ; guardamos el digito en la pila
    inc  ecx                        ; un digito mas
    cmp  eax, 0                     ; si el cociente no es 0, seguimos
    jne  cdDividir

    mov  ebx, ecx                   ; guardamos cuantos digitos son
cdArmar:
    pop  edx                        ; sale primero el ultimo que entro
    add  dl, '0'                    ; numero a caracter ASCII
    mov  [esi], dl                  ; lo ponemos en el buffer
    inc  esi                        ; siguiente posicion
    loop cdArmar                    ; tantas veces como digitos

    mov  dl, 0
    mov  [esi], dl                  ; 00h al final de la cadena
    mov  eax, ebx                   ; EAX = cuantos digitos

    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret
convertirDecimal ENDP

; ---- MostrarNumero ----
; Recibe: EAX = numero a mostrar
; Regresa: nada
; Cambia: nada
MostrarNumero PROC
    push eax
    push edx
    push esi

    mov  esi, OFFSET bufNum         ; ESI = buffer donde queda el texto
    call convertirDecimal           ; numero = texto
    mov  edx, OFFSET bufNum
    call WriteString                ; mostramos el texto

    pop  esi
    pop  edx
    pop  eax
    ret
MostrarNumero ENDP

; ---- MostrarImporte ----
; Muestra centavos como $pesos.centavos MXN (18550 -> $185.50 MXN)
; Recibe: EAX = importe en centavos
; Regresa: nada
; Cambia: nada
MostrarImporte PROC
    push eax
    push ebx
    push edx

    mov  edx, 0                     ; EDX en 0 para dividir EDX:EAX
    mov  ebx, 100
    div  ebx                        ; EAX = pesos, EDX = centavos
    mov  centavosTmp, edx           ; guardamos los centavos

    mov  edx, OFFSET txtPesos       ; "$"
    call WriteString
    call MostrarNumero              ; pesos
    mov  edx, OFFSET txtPunto       ; "."
    call WriteString

    mov  eax, centavosTmp
    cmp  eax, 10                    ; si son 10 o mas ya tienen 2 digitos
    jae  miCentavos
    mov  edx, OFFSET txtCero        ; si no, ponemos un 0 antes (5 -> 05)
    call WriteString
miCentavos:
    call MostrarNumero              ; centavos
    mov  edx, OFFSET txtMXN         ; " MXN"
    call WriteString

    pop  edx
    pop  ebx
    pop  eax
    ret
MostrarImporte ENDP

; ---- MostrarProducto ----
; Muestra un producto en un renglon. Si tiene 5 o menos piezas
; Recibe: ESI = direccion del producto
; Regresa: nada
; Cambia: nada
MostrarProducto PROC
    push eax
    push edx

    mov  edx, esi                   ; codigo (byte 0 del producto)
    call WriteString
    mov  edx, OFFSET txtBarra
    call WriteString
    mov  edx, esi
    add  edx, 8                     ; nombre (byte 8 del producto)
    call WriteString
    mov  edx, OFFSET txtBarra
    call WriteString
    mov  eax, [esi + 36]            ; precio (byte 36)
    call MostrarImporte
    mov  edx, OFFSET txtExis
    call WriteString
    mov  eax, [esi + 40]            ; existencia (byte 40)
    call MostrarNumero

    cmp  eax, 5                     ; regla: 5 piezas o menos = existencia baja
    ja   mpFin                      ; mas de 5, no hay alerta
    mov  edx, OFFSET txtBaja        ; marcamos el producto
    call WriteString
mpFin:
    call Crlf

    pop  edx
    pop  eax
    ret
MostrarProducto ENDP

; ---- CopiarBytes ----
; Copia bytes de un lugar a otro, uno por uno
; Recibe: ESI = origen, EDI = destino, ECX = cuantos bytes
; Regresa: los bytes copiados en el destino
; Cambia: nada
CopiarBytes PROC
    push eax
    push ecx
    push esi
    push edi

    cmp  ecx, 0                     ; si son 0 bytes no hay nada que copiar
    je   cbFin
cbCiclo:
    mov  al, [esi]                  ; leemos un byte del origen
    mov  [edi], al                  ; lo escribimos en el destino
    inc  esi
    inc  edi
    loop cbCiclo
cbFin:
    pop  edi
    pop  esi
    pop  ecx
    pop  eax
    ret
CopiarBytes ENDP

; ---- AgregarTexto ----
; Copia un texto (sin su 00h) al final de lo que se esta armando
; Recibe: EDX = texto, EDI = donde se va a copiar
; Regresa: EDI = posicion siguiente al ultimo caracter copiado
; Cambia: EDI
AgregarTexto PROC
    push eax
    push edx

atCiclo:
    mov  al, [edx]                  ; caracter del texto
    cmp  al, 0                      ; si es 00h ya terminamos
    je   atFin
    mov  [edi], al                  ; lo copiamos
    inc  edx
    inc  edi
    jmp  atCiclo
atFin:
    pop  edx
    pop  eax
    ret
AgregarTexto ENDP

; ---- BuscarCodigo ----
; Recorre un catalogo con ESI comparando el codigo de cada producto
; Recibe: EDX = codigo buscado, ESI = direccion del catalogo, ECX = cuantos productos
; Regresa: EAX = numero de producto (0 a 9) o -1, ESI = direccion del producto
; Cambia: EAX, ESI
BuscarCodigo PROC
    push ebx
    push ecx
    push edi

    mov  edi, ecx                   ; guardamos el total para sacar el numero
    cmp  ecx, 0                     ; catalogo vacio
    je   bcNoEsta

bcProducto:
    mov  ebx, 0                     ; EBX = posicion dentro del codigo
bcComparar:
    mov  al, [esi + ebx]            ; caracter del producto
    cmp  al, [edx + ebx]            ; contra el caracter buscado
    jne  bcSiguiente                ; si es diferente, no es este
    inc  ebx
    cmp  ebx, 7                     ; revisamos los 7 caracteres
    jb   bcComparar

    mov  eax, edi                   ; lo encontramos
    sub  eax, ecx                   ; numero = total - los que faltaban
    jmp  bcFin

bcSiguiente:
    add  esi, 44                    ; ESI pasa al siguiente producto
    loop bcProducto

bcNoEsta:
    mov  eax, -1                    ; no se encontro
bcFin:
    pop  edi
    pop  ecx
    pop  ebx
    ret
BuscarCodigo ENDP

; ---- PedirProductoExistente ----
; Pide un codigo y lo busca en el catalogo
; Recibe: nada
; Regresa: EAX = numero de producto o -1, ESI = direccion del producto
; Cambia: EAX, ESI
PedirProductoExistente PROC
    push ecx
    push edx

    call CapturarCodigo             ; deja el codigo en bufCodigo
    mov  edx, OFFSET bufCodigo
    mov  esi, OFFSET catalogo
    mov  ecx, numProd
    call BuscarCodigo
    cmp  eax, -1
    jne  ppFin
    mov  edx, OFFSET msgNoExiste    ; no esta registrado
    call WriteString
    call Crlf
ppFin:
    pop  edx
    pop  ecx
    ret
PedirProductoExistente ENDP

; ---- RegistrarProducto (opcion 1) ----
; Recibe: nad
; Regresa: nada
; Cambia: nada
RegistrarProducto PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    cmp  numProd, 10                ; si ya hay 10 no cabe otro
    jae  rpLleno

    call CapturarCodigo             ; codigo con formato correcto
    mov  edx, OFFSET bufCodigo
    mov  esi, OFFSET catalogo
    mov  ecx, numProd
    call BuscarCodigo               ; revisamos que no exista
    cmp  eax, -1
    jne  rpDuplicado                ; si se encontro, esta duplicado

    call CapturarNombre             ; nombre en bufNombre
    call CapturarPrecio             ; precio en EAX
    mov  nuevoPrecio, eax
    mov  edx, OFFSET msgPideExis
    mov  ebx, 0                     ; existencia minima 0
    mov  ecx, 100                   ; existencia maxima 100
    call CapturarNumero
    mov  nuevaExis, eax

    mov  eax, numProd               ; direccion = catalogo + numProd * 44
    mov  ebx, 44
    mul  ebx
    mov  edi, OFFSET catalogo
    add  edi, eax                   ; EDI = donde va el nuevo producto

    mov  esi, OFFSET bufCodigo      ; copiamos el codigo (byte 0)
    mov  ecx, 8
    call CopiarBytes
    add  edi, 8                     ; copiamos el nombre (byte 8)
    mov  esi, OFFSET bufNombre
    mov  ecx, 26
    call CopiarBytes
    sub  edi, 8                     ; regresamos al inicio del producto
    mov  eax, nuevoPrecio
    mov  [edi + 36], eax            ; precio (byte 36)
    mov  eax, nuevaExis
    mov  [edi + 40], eax            ; existencia (byte 40)

    inc  numProd                    ; un producto mas
    mov  hayCambios, 1              ; hay cambios sin guardar
    mov  edx, OFFSET msgRegistrado
    call WriteString
    call Crlf
    mov  esi, edi                   ; mostramos el producto registrado
    mov  edx, OFFSET txtCodigo
    call WriteString
    call MostrarProducto
    jmp  rpFin

rpLleno:
    mov  edx, OFFSET msgLleno
    call WriteString
    call Crlf
    jmp  rpFin
rpDuplicado:
    mov  edx, OFFSET msgDuplicado
    call WriteString
    call Crlf
rpFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
RegistrarProducto ENDP

; ---- MostrarInventario (opcion 2) ----
; Recibe: nada
; Regresa: nada
; Cambia: nada
MostrarInventario PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov  edx, OFFSET msgInvTitulo
    call WriteString
    call Crlf
    cmp  numProd, 0                 ; no hay productos
    je   miVacio

    mov  esi, OFFSET catalogo       ; ESI = primer producto
    mov  ecx, numProd               ; ECX = cuantos hay (para LOOP)
    mov  ebx, 1                     ; numero de renglon
miCiclo:
    mov  eax, ebx
    call MostrarNumero              
    mov  edx, OFFSET txtParen       
    call WriteString
    call MostrarProducto            ; datos del producto
    add  esi, 44                    ; siguiente producto
    inc  ebx
    loop miCiclo
    jmp  miFin

miVacio:
    mov  edx, OFFSET msgSinProd
    call WriteString
    call Crlf
miFin:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
MostrarInventario ENDP

; ---- BuscarProducto (opcion 3) ----
; Recibe: nada
; Regresa: nada
; Cambia: nada
BuscarProducto PROC
    push eax
    push edx
    push esi

    call PedirProductoExistente     ; EAX = numero, ESI = producto
    cmp  eax, -1                    ; no se encontro
    je   bpFin
    mov  edx, OFFSET msgEncontrado
    call WriteString
    call Crlf
    mov  edx, OFFSET txtCodigo
    call WriteString
    call MostrarProducto
bpFin:
    pop  esi
    pop  edx
    pop  eax
    ret
BuscarProducto ENDP

; ---- RecibirMercancia (opcion 4) ----
; Suma unidades a un producto sin pasar de 100
; Recibe: nada
; Regresa: nada
; Cambia: nada
RecibirMercancia PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    call PedirProductoExistente
    cmp  eax, -1
    je   rmFin
    mov  edx, OFFSET txtCodigo
    call WriteString
    call MostrarProducto

    mov  edx, OFFSET msgPideCantE
    mov  ebx, 1                     ; minimo 1 (mayor que cero)
    mov  ecx, 100                   ; maximo 100
    call CapturarNumero             ; EAX = unidades recibidas

    mov  ebx, [esi + 40]            ; EBX = existencia actual
    add  ebx, eax                   ; + lo que llego
    cmp  ebx, 100                   ; no puede pasar de 100
    ja   rmExcede

    mov  [esi + 40], ebx            ; ahora si guardamos la nueva existencia
    mov  hayCambios, 1
    mov  edx, OFFSET msgRecibido
    call WriteString
    mov  eax, ebx
    call MostrarNumero
    call Crlf
    jmp  rmFin

rmExcede:
    mov  edx, OFFSET msgExcede1
    call WriteString
    mov  eax, 100
    sub  eax, [esi + 40]            ; cuantas caben todavia
    call MostrarNumero
    mov  edx, OFFSET msgExcede2
    call WriteString
    call Crlf
rmFin:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
RecibirMercancia ENDP

; ---- VenderProducto (opcion 5) ----
; Revisa existencias, calcula el importe y descuenta las unidades.
; Al final aplica la regla: si quedan 5 piezas o menos muestra la alerta.
; Recibe: nada
; Regresa: nada
; Cambia: nada
VenderProducto PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    call PedirProductoExistente     ; ESI = producto
    cmp  eax, -1
    je   vpFin
    mov  edx, OFFSET txtCodigo
    call WriteString
    call MostrarProducto

    mov  eax, [esi + 40]            ; existencia
    cmp  eax, 0                     ; si no hay nada, no se puede vender
    je   vpSinExis

    mov  edx, OFFSET msgPideCantV
    mov  ebx, 1                     ; minimo 1
    mov  ecx, 100                   ; maximo 100
    call CapturarNumero
    mov  cantidad, eax

    cmp  eax, [esi + 40]            ; pide mas de lo que hay?
    ja   vpInsuficiente

    mov  eax, [esi + 36]            ; precio
    mul  cantidad                   ; EDX:EAX = precio * cantidad
    cmp  edx, 0                     ; si EDX no es 0, no cabe
    jne  vpDesborde
    mov  importe, eax

    mov  eax, ingresos              
    add  eax, importe
    jb   vpDesborde                 ; CF = 1 (acarreo): no cabe
    mov  nuevosIngresos, eax

    ; hasta aqui no se ha cambiado nada, ahora si se actualiza
    mov  eax, cantidad
    sub  [esi + 40], eax            ; existencia - cantidad
    mov  eax, nuevosIngresos
    mov  ingresos, eax              ; ingresos + importe
    inc  ventasHechas
    mov  hayCambios, 1

    call Crlf
    mov  edx, OFFSET msgTicket
    call WriteString
    call Crlf
    mov  edx, OFFSET msgTkPrecio
    call WriteString
    mov  eax, [esi + 36]
    call MostrarImporte
    call Crlf
    mov  edx, OFFSET msgTkCant
    call WriteString
    mov  eax, cantidad
    call MostrarNumero
    call Crlf
    mov  edx, OFFSET msgTkTotal
    call WriteString
    mov  eax, importe
    call MostrarImporte
    call Crlf
    mov  edx, OFFSET msgVendido
    call WriteString
    mov  eax, [esi + 40]            ; existencia que quedo
    call MostrarNumero
    call Crlf

    ; regla de negocio: alerta de existencia minima
    cmp  eax, 5                     ; quedan 5 o menos?
    ja   vpSinAlerta                ; mas de 5, todo bien
    mov  edx, OFFSET msgAlerta      ; 5 o menos, avisamos que hay que comprar mas
    call WriteString
    call Crlf
    jmp  vpFin
vpSinAlerta:
    mov  edx, OFFSET msgSinAlerta
    call WriteString
    call Crlf
    jmp  vpFin

vpSinExis:
    mov  edx, OFFSET msgSinExis
    call WriteString
    call Crlf
    jmp  vpFin
vpInsuficiente:
    mov  edx, OFFSET msgInsuf1
    call WriteString
    mov  eax, [esi + 40]
    call MostrarNumero
    mov  edx, OFFSET msgInsuf2
    call WriteString
    call Crlf
    jmp  vpFin
vpDesborde:
    mov  edx, OFFSET msgDesborde
    call WriteString
    call Crlf
vpFin:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
VenderProducto ENDP

; ---- MostrarResumen (opcion 6) ----
; Suma unidades, valor del inventario y cuenta los productos por resurtir
; Recibe: nada
; Regresa: nada
; Cambia: nada
MostrarResumen PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov  ebx, 0                     ; EBX = total de unidades
    mov  edi, 0                     ; EDI = valor del inventario
    mov  cuantosBajos, 0            ; productos con 5 o menos
    mov  ecx, numProd
    cmp  ecx, 0
    je   mrMostrar

    mov  esi, OFFSET catalogo       ; ESI = primer producto
mrCiclo:
    mov  eax, [esi + 40]            ; existencia
    add  ebx, eax                   ; sumamos unidades
    cmp  eax, 5                     ; regla: 5 o menos se cuenta
    ja   mrValor
    inc  cuantosBajos
mrValor:
    mov  edx, [esi + 36]            ; precio
    mul  edx                        ; EDX:EAX = existencia * precio
    cmp  edx, 0
    jne  mrDesborde
    add  edi, eax                   ; sumamos al valor
    jb   mrDesborde                 ; CF = 1 (acarreo): no cabe
    add  esi, 44                    ; siguiente producto
    loop mrCiclo

mrMostrar:
    mov  edx, OFFSET msgResTitulo
    call WriteString
    call Crlf
    mov  edx, OFFSET msgResProd
    call WriteString
    mov  eax, numProd
    call MostrarNumero
    call Crlf
    mov  edx, OFFSET msgResUnid
    call WriteString
    mov  eax, ebx
    call MostrarNumero
    call Crlf
    mov  edx, OFFSET msgResValor
    call WriteString
    mov  eax, edi
    call MostrarImporte
    call Crlf
    mov  edx, OFFSET msgResIngr
    call WriteString
    mov  eax, ingresos
    call MostrarImporte
    call Crlf
    mov  edx, OFFSET msgResVentas
    call WriteString
    mov  eax, ventasHechas
    call MostrarNumero
    call Crlf
    mov  edx, OFFSET msgResBajos
    call WriteString
    mov  eax, cuantosBajos
    call MostrarNumero
    call Crlf
    jmp  mrFin

mrDesborde:
    mov  edx, OFFSET msgDesborde
    call WriteString
    call Crlf
mrFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
MostrarResumen ENDP

; ---- PedirNombreArchivo ----
; Pide el nombre del archivo; si solo dan Enter se usa inventario.txt
; Recibe: nada
; Regresa: nombreArch con el nombre
; Cambia: nada
PedirNombreArchivo PROC
    push eax
    push ecx
    push edx
    push esi
    push edi

    mov  edx, OFFSET msgPideArch
    call WriteString
    mov  edx, OFFSET nombreArch
    mov  ecx, 60                    ; nombreArch mide 61 (60 + 00h)
    call ReadString
    cmp  eax, 0                     ; si escribio algo, se usa eso
    jne  pnFin
    mov  esi, OFFSET archDefault    ; si no, copiamos "inventario.txt"
    mov  edi, OFFSET nombreArch
    mov  ecx, 15                    ; 14 letras + 00h
    call CopiarBytes
pnFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  eax
    ret
PedirNombreArchivo ENDP

; ---- ArmarTextoArchivo ----
; Escribe en bufArchivo una linea por producto: CODIGO|NOMBRE|PRECIO|EXISTENCIA
; Recibe: nada
; Regresa: EAX = cuantos bytes se armaron
; Cambia: EAX
ArmarTextoArchivo PROC
    push ecx
    push edx
    push esi
    push edi

    mov  edi, OFFSET bufArchivo     ; EDI = donde vamos escribiendo
    mov  esi, OFFSET catalogo       ; ESI = producto actual
    mov  ecx, numProd
atCicloProd:
    mov  edx, esi                   ; codigo
    call AgregarTexto
    mov  edx, OFFSET txtSep         ; "|"
    call AgregarTexto

    mov  edx, esi
    add  edx, 8                     ; nombre
    call AgregarTexto
    mov  edx, OFFSET txtSep
    call AgregarTexto

    push esi                        ; guardamos ESI porque convertirDecimal lo usa
    mov  eax, [esi + 36]            ; precio en centavos
    mov  esi, OFFSET bufNum
    call convertirDecimal           ; precio = texto
    pop  esi
    mov  edx, OFFSET bufNum
    call AgregarTexto
    mov  edx, OFFSET txtSep
    call AgregarTexto

    push esi
    mov  eax, [esi + 40]            ; existencia
    mov  esi, OFFSET bufNum
    call convertirDecimal           ; existencia = texto
    pop  esi
    mov  edx, OFFSET bufNum
    call AgregarTexto
    mov  edx, OFFSET txtFinLinea    ; salto de linea
    call AgregarTexto

    add  esi, 44                    ; siguiente producto
    dec  ecx                        ; uno menos
    jne  atCicloProd                ; ciclo largo, por eso no usamos LOOP

    mov  eax, edi                   ; bytes = donde terminamos - donde empezamos
    sub  eax, OFFSET bufArchivo

    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    ret
ArmarTextoArchivo ENDP

; ---- GuardarCatalogo (opcion 7) ----
; Recibe: nada
; Regresa: hayCambios = 0 si se guardo bien
; Cambia: nada
GuardarCatalogo PROC
    push eax
    push ecx
    push edx

    cmp  numProd, 0                
    je   gcNada

    call PedirNombreArchivo
    call ArmarTextoArchivo          ; EAX = bytes a escribir
    mov  bytesPedidos, eax          ; lo guardamos para comparar despues

    mov  edx, OFFSET nombreArch     ; EDX = nombre del archivo
    call CreateOutputFile           ; EAX = handle
    cmp  eax, INVALID_HANDLE_VALUE  ; no se pudo crear
    je   gcErrCrear
    mov  handleArch, eax

    mov  eax, handleArch            ; EAX = handle
    mov  edx, OFFSET bufArchivo     ; EDX = que vamos a escribir
    mov  ecx, bytesPedidos          ; ECX = cuantos bytes
    call WriteToFile                ; EAX = bytes que si se escribieron
    push eax                        ; lo guardamos mientras cerramos
    mov  eax, handleArch
    call CloseFile                  ; cerramos el archivo
    pop  eax
    cmp  eax, bytesPedidos          
    jne  gcErrEscribir

    mov  hayCambios, 0              ; ya no hay cambios pendientes
    mov  edx, OFFSET msgGuardado1
    call WriteString
    call MostrarNumero              ; bytes escritos
    call Crlf
    jmp  gcFin

gcNada:
    mov  edx, OFFSET msgNadaGuardar
    call WriteString
    call Crlf
    jmp  gcFin
gcErrCrear:
    mov  edx, OFFSET msgErrCrear
    call WriteString
    call Crlf
    jmp  gcFin
gcErrEscribir:
    mov  edx, OFFSET msgErrEscribir
    call WriteString
    call Crlf
gcFin:
    pop  edx
    pop  ecx
    pop  eax
    ret
GuardarCatalogo ENDP

; ---- LeerCampo ----
; Copia a bufCampo un campo del archivo, hasta '|', CR, LF o 00h
; Recibe: ESI = posicion en bufArchivo
; Regresa: EAX = largo del campo (0 si pasa de 40), ESI = en el separador
; Cambia: EAX, ESI
LeerCampo PROC
    push ebx

    mov  ebx, 0                     ; EBX = caracteres del campo
lcCiclo:
    mov  al, [esi]                  ; caracter actual
    cmp  al, '|'                    ; separador
    je   lcFin
    cmp  al, 0Dh                    ; CR
    je   lcFin
    cmp  al, 0Ah                    ; LF
    je   lcFin
    cmp  al, 0                      ; fin del texto
    je   lcFin
    cmp  ebx, 40                    ; campo demasiado largo
    jae  lcLargo
    mov  bufCampo[ebx], al          ; copiamos el caracter
    inc  ebx
    inc  esi
    jmp  lcCiclo

lcLargo:
    mov  ebx, 0                     ; lo marcamos vacio para que se rechace
lcFin:
    mov  bufCampo[ebx], 0           ; 00h al final del campo
    mov  eax, ebx                   ; EAX = largo

    pop  ebx
    ret
LeerCampo ENDP

; ---- ProcesarArchivo ----
; Arma el catalogo en catTemp a partir del texto leido, revisando cada campo
; Recibe: bufArchivo con el texto y 00h al final
; Regresa: EAX = 1 si todo esta bien, 0 si no (motivo en msgErrArch)
; Cambia: EAX
ProcesarArchivo PROC
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov  numTemp, 0
    mov  lineaArch, 0
    mov  esi, OFFSET bufArchivo     ; ESI recorre el texto del archivo
    mov  edi, OFFSET catTemp        ; EDI = producto que se esta llenando

paLinea:
    mov  al, [esi]                  ; saltamos CR y LF sobrantes
    cmp  al, 0Dh
    je   paSaltar
    cmp  al, 0Ah
    je   paSaltar
    cmp  al, 0                      ; fin del texto
    je   paFinTexto
    jmp  paNueva
paSaltar:
    inc  esi
    jmp  paLinea

paNueva:
    inc  lineaArch                  ; una linea mas
    cmp  numTemp, 10                ; ya hay 10, no cabe otra
    jae  paMuchos

    ; campo 1: codigo
    call LeerCampo                  ; EAX = largo
    mov  bl, [esi]
    cmp  bl, '|'                    ; despues del codigo va '|'
    jne  paFormato
    inc  esi                        ; saltamos el '|'
    push esi
    mov  esi, OFFSET bufCampo
    mov  ecx, eax
    call ValidarCodigo              ; mismo procedimiento que en el teclado
    pop  esi
    cmp  eax, 1
    jne  paCodigo
    push esi
    mov  edx, OFFSET bufCampo       ; que no se repita en el archivo
    mov  esi, OFFSET catTemp
    mov  ecx, numTemp
    call BuscarCodigo
    pop  esi
    cmp  eax, -1
    jne  paDuplicado
    push esi
    mov  esi, OFFSET bufCampo       ; copiamos el codigo (byte 0)
    mov  ecx, 8
    call CopiarBytes
    pop  esi

    ; campo 2: nombre
    call LeerCampo
    mov  bl, [esi]
    cmp  bl, '|'
    jne  paFormato
    inc  esi
    push esi
    mov  esi, OFFSET bufCampo
    mov  ecx, eax
    call ValidarNombre
    pop  esi
    cmp  eax, 1
    jne  paNombre
    push esi
    push edi
    mov  esi, OFFSET bufCampo
    add  edi, 8                     ; nombre (byte 8)
    inc  ecx                        ; largo + 00h
    call CopiarBytes
    pop  edi
    pop  esi

    ; campo 3: precio en centavos
    call LeerCampo
    mov  bl, [esi]
    cmp  bl, '|'
    jne  paFormato
    inc  esi
    push esi
    mov  esi, OFFSET bufCampo
    mov  ecx, eax
    call ConvertirEntero            ; EAX = numero, EBX = valido
    pop  esi
    cmp  ebx, 1
    jne  paPrecio
    cmp  eax, 1                     ; $0.01 minimo
    jb   paPrecio
    cmp  eax, 999999                ; $9999.99 maximo
    ja   paPrecio
    mov  [edi + 36], eax            ; precio (byte 36)

    ; campo 4: existencia (despues viene fin de linea)
    call LeerCampo
    mov  bl, [esi]
    cmp  bl, '|'                    ; no debe haber un quinto campo
    je   paFormato
    push esi
    mov  esi, OFFSET bufCampo
    mov  ecx, eax
    call ConvertirEntero
    pop  esi
    cmp  ebx, 1
    jne  paExis
    cmp  eax, 100                   ; maximo 100
    ja   paExis
    mov  [edi + 40], eax            ; existencia (byte 40)

    inc  numTemp                    ; producto completo
    add  edi, 44                    ; siguiente producto en catTemp
    jmp  paLinea

paFinTexto:
    cmp  numTemp, 0                 ; el archivo no traia productos
    je   paNinguno
    mov  eax, 1                     ; todo bien
    jmp  paFin

paFormato:
    mov  msgErrArch, OFFSET errFormato
    jmp  paError
paCodigo:
    mov  msgErrArch, OFFSET errCodigo
    jmp  paError
paDuplicado:
    mov  msgErrArch, OFFSET errDupl
    jmp  paError
paNombre:
    mov  msgErrArch, OFFSET errNombre
    jmp  paError
paPrecio:
    mov  msgErrArch, OFFSET errPrecio
    jmp  paError
paExis:
    mov  msgErrArch, OFFSET errExis
    jmp  paError
paMuchos:
    mov  msgErrArch, OFFSET errMuchos
    jmp  paError
paNinguno:
    mov  msgErrArch, OFFSET errNinguno
paError:
    mov  eax, 0                     ; archivo invalido
paFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret
ProcesarArchivo ENDP

; ---- CargarCatalogo (opcion 8) ----
; Lee el archivo, lo revisa y solo si esta bien reemplaza el catalogo
; Recibe: nada
; Regresa: catalogo y numProd nuevos si el archivo es valido
; Cambia: nada
CargarCatalogo PROC
    push eax
    push ecx
    push edx
    push esi
    push edi

    call PedirNombreArchivo

    mov  edx, OFFSET nombreArch     ; EDX = nombre del archivo
    call OpenInputFile              ; EAX = handle
    cmp  eax, INVALID_HANDLE_VALUE  ; no existe o no se pudo abrir
    je   ccaNoAbre
    mov  handleArch, eax

    mov  edx, OFFSET bufArchivo     ; EDX = donde se guarda lo leido
    mov  ecx, 1000                  ; ECX = maximo 1000 bytes (dejamos 1 para el 00h)
    call ReadFromFile               ; EAX = bytes leidos, CF = 1 si hubo error
    jb   ccaErrLeer                 ; CF = 1: error al leer
    mov  bytesLeidos, eax
    mov  eax, handleArch
    call CloseFile                  ; cerramos el archivo

    mov  edx, OFFSET msgBytesLei
    call WriteString
    mov  eax, bytesLeidos
    call MostrarNumero
    call Crlf

    cmp  bytesLeidos, 0             ; archivo vacio
    je   ccaVacio
    cmp  bytesLeidos, 1000          ; lleno el buffer, puede que falte texto
    jae  ccaGrande

    mov  esi, bytesLeidos           ; ESI = posicion despues del ultimo byte
    mov  bufArchivo[esi], 0         ; ahi ponemos el 00h

    call ProcesarArchivo            ; revisamos todo el archivo
    cmp  eax, 1
    jne  ccaInvalido

    mov  eax, numTemp               ; bytes a copiar = numTemp * 44
    mov  ecx, 44
    mul  ecx
    mov  ecx, eax
    mov  esi, OFFSET catTemp        ; copiamos catTemp al catalogo
    mov  edi, OFFSET catalogo
    call CopiarBytes
    mov  eax, numTemp
    mov  numProd, eax
    mov  hayCambios, 0              ; recien cargado, no hay cambios

    mov  edx, OFFSET msgCargado1
    call WriteString
    mov  eax, numProd
    call MostrarNumero
    call Crlf
    call MostrarInventario
    jmp  ccaFin

ccaNoAbre:
    mov  edx, OFFSET msgErrAbrir
    call WriteString
    call Crlf
    jmp  ccaFin
ccaErrLeer:
    mov  eax, handleArch            ; aunque fallo, cerramos el archivo
    call CloseFile
    mov  edx, OFFSET msgErrLeer
    call WriteString
    call Crlf
    jmp  ccaFin
ccaVacio:
    mov  edx, OFFSET msgArchVacio
    call WriteString
    call Crlf
    jmp  ccaFin
ccaGrande:
    mov  edx, OFFSET msgArchGrande
    call WriteString
    call Crlf
    jmp  ccaFin
ccaInvalido:
    mov  edx, OFFSET msgArchMal1   
    call WriteString
    mov  eax, lineaArch
    call MostrarNumero
    mov  edx, OFFSET msgArchMal2
    call WriteString
    mov  edx, msgErrArch
    call WriteString
    call Crlf
    mov  edx, OFFSET msgArchMal3
    call WriteString
    call Crlf
ccaFin:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  eax
    ret
CargarCatalogo ENDP

; ---- ConfirmarSalida ----
; Si hay cambios sin guardar pregunta si se quieren guardar (S/N)
; Recibe: nada
; Regresa: nada
; Cambia: nada
ConfirmarSalida PROC
    push eax
    push ecx
    push edx

csRevisar:
    cmp  hayCambios, 0              ; no hay cambios, salimos
    je   csFin
    mov  edx, OFFSET msgSalirAviso
    call WriteString
    mov  edx, OFFSET bufEntrada
    mov  ecx, 80
    call ReadString
    cmp  eax, 1                     ; debe ser una sola letra
    jne  csRevisar
    mov  al, bufEntrada             ; AL = la letra
    cmp  al, 'S'
    je   csGuardar
    cmp  al, 's'
    je   csGuardar
    cmp  al, 'N'
    je   csFin
    cmp  al, 'n'
    je   csFin
    jmp  csRevisar                  ; otra letra, preguntamos otra vez
csGuardar:
    call GuardarCatalogo            ; si se guarda, hayCambios queda en 0
    jmp  csRevisar
csFin:
    pop  edx
    pop  ecx
    pop  eax
    ret
ConfirmarSalida ENDP

END main