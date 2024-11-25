init:
	addi x1, x0, 0 #Indice del bucle
   	add t0, x0, x0 #Elemento i-1
    addi t1, x0, 1 #Elemento i
    addi x2, x0, 10 #Cargar numero de elementos de la secuencia de fibonacci (N)
    addi a0, x0, 0x0A0 #Cargar dirección de guardado
    
    beq x2, x0, fin #Si N es 0 finalizar el programa
    sw t0, 0(a0) #Escribir el primer elemento (0) de la serie de Fibonacci
    addi a0, a0, 4 #Sumar el desplazamiento de la dirección de guardado
    addi x1, x1, 1 #Incrementar el indice
    
loop:
	bge x1, x2, fin
	add t2, t0, t1 #Sumar el elemento i + (i-1)
    add t0, t1, x0 #Desplazar el elemento i a i-1
 	add t1, t2, x0 #Desplazar el elemento nuevo a i
    
    sw t2, 0(a0) #Guardar el nuevo dato
    addi a0, a0, 4 #Sumar el desplazamiento de la dirección de guardado
    
    addi x1, x1, 1 #Incrementar el indice
    j loop

    
fin:
