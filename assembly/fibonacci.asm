init:
#Entrada del programa:
	addi x2, x0, 10 #Cargar numero de elementos de la secuencia de fibonacci (N)



	addi a0, x0, 0x000 #Cargar dirección de guardado
	addi x1, x0, 0 #Indice del bucle
   	add t0, x0, x0 #Elemento i-1
    addi t1, x0, 1 #Elemento i
    
    beq x2, x0, fin #Si N es 0 finalizar el programa
    sw t0, 0(a0) #Escribir el primer elemento (0) de la serie de Fibonacci
    

    addi a1, x0, 1 #Registro temporal con el valor 1
	beq x2, a1, fin #Si N es 1 finalizar el programa    
    sw t1, 4(a0) #Escribir el segundo elemento (1) de la seire de Fibonacci
     
    addi a0, a0, 8 #Sumar el desplazamiento de la dirección de guardado
    addi x1, x1, 2 #Incrementar el indice
    
loop:
	beq x1, x2, fin #Condicion de salida del bucle
	add t2, t0, t1 #Sumar el elemento i + (i-1)
    add t0, t1, x0 #Desplazar el elemento i a i-1
 	add t1, t2, x0 #Desplazar el elemento nuevo a i
    
    sw t2, 0(a0) #Guardar el nuevo dato
    addi a0, a0, 4 #Sumar el desplazamiento de la dirección de guardado
    
    addi x1, x1, 1 #Incrementar el indice
    beq x0, x0, loop

    
fin:
