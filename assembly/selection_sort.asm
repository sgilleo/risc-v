.text
	la a0, numbers #Guardar la dirección de los datos
    add x1, x0, x0 #Indice del bucle externo i en multiplos de 4
    add x2, x0, x0 #Indice del bucle interno j en multiplos de 4
    lw x3, n #Numero de bytes para ordenar
    addi x4, x3, -4 #Numero de bytes para ordenar -4
    
    
loop:
	bge x1, x4, end
	add t0, x1, x0 #Indice del dato minimo
    
    addi x2, x1, 4 #Comienzo del bucle interior en j = i+1
inner_loop:
	bge x2, x3, inner_loop_end #Condicion de salida del bucle interior
	add a1, a0, x2 #Calculamos la direccion para el dato con indice j
    lw t1, 0(a1) #Leemos el dato de indice j
    
    add a2, a0, t0 #Calculamos la direccion para el dato con indice minimo
    lw t2, 0(a2) #Leemos el dato de indice minimo
    
	bge t1, t2, end_if
if:
	add t0, x2, x0 #Actualizamos el indice mínimo al indice j
end_if:
    addi x2, x2, 4 #Incrementamos j por 4 bytes 
    j inner_loop
inner_loop_end:
	
	#Intercambio del dato minimo con el actual:
    add a1, a0, x1 #Calculamos la direccion para el dato con indice i
    lw t1, 0(a1) #Leemos el dato de indice i
    add a2, a0, t0 #Calculamos la direccion para el dato con indice minimo
    lw t2, 0(a2) #Leemos el dato de indice minimo
    sw t2, 0(a1) #Escribimos el nuevo numero menor en la posicion actual
    sw t1, 0(a2) #Escribimos el numero de la posicion actual en la posicion del menor numero
        
    addi x1, x1, 4 
    j loop
end:
    
.data
n: .word 56 #Cantidad de números a ordenar en bytes (4*N)
numbers:
	.word 45, 87, 32, 12, 98, 123, 5, 25, 37, 3, 72, 7, 14, 68