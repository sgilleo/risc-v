init:
#Entrada del programa:
	addi x2, x0, 10 #Cargar numero de elementos de la secuencia de fibonacci (N)



	addi a0, x0, 0x000 #Cargar dirección de guardado
	addi x1, x0, 0 #Indice del bucle
   	add t0, x0, x0 #Elemento i-1
    addi t1, x0, 1 #Elemento i

    beq x2, x0, fin #Si N es 0 finalizar el programa
    sw t0, 0(a0) #Escribir el primer elemento (0) de la serie de Fibonacci
    addi x1, x1, 1 #Registro temporal con el valor 1

	beq x1, x2, fin #Si x1=N finalizar el programa    
    sw t1, 4(a0)  #Escribir el segundo elemento (1) de la seire de Fibonacci
    addi a0, a0, 8 #Sumar el desplazamiento de la dirección de guardado

    addi x1, x1, 1 #Incrementar el indice
    
loop:
	# Calcular F(i+1)
    add t2, t0, t1         # t2 = F(i-1) + F(i)
    sw t2, 0(a0)           # Guardar F(i+1) en memoria

    # Actualizar valores
    add t0, t1, x0         # t0 = F(i)
    add t1, t2, x0         # t1 = F(i+1)
    addi a0, a0, 4         # Avanzar dirección de memoria
    addi x1, x1, 1         # Incrementar índice

    # Continuar el bucle
    bne x1, x2, loop       # Si índice < N, repetir el bucle

    
fin:
    #FIN del programa
    nop #instruccion vacia para finalizar nop