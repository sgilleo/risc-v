init: #Inicializar los valores en la memoria
	addi x1, x0, 0x000 #Cargar la direccion de memoria inicial (Indice i)
    
    addi x2, x0, 9
    sw x2, 0(x1)
	
    addi x2, x0, 4
    sw x2, 4(x1)
    
    addi x2, x0, 6
    sw x2, 8(x1)
    
    addi x2, x0, 1
    sw x2, 12(x1)

    addi x2, x0, 5
    sw x2, 16(x1)
    
    addi x2, x0, 7
    sw x2, 20(x1)
    
    addi x2, x0, 8
    sw x2, 24(x1)
    
    addi x2, x0, 2
    sw x2, 28(x1)

    addi x2, x0, 3
    sw x2, 32(x1)
    
	addi x2, x0, 0 #Fin de los datos
    sw x2, 36(x1)
    


#x1: Direccion i
#x2: Direccion j
#x3: Direccion dato minimo
#x4: Valor dato actual (i)
#x5: Valor dato en direccion j
#x6: Valor dato en direccion minima
    
loop:
	lw x4, 0(x1) #Valor del dato actual
    beq x4, x0, end #Condicion de salida del algoritmo (ultimo dato es cero)
    
    add x3, x0, x1 #Direccion del valor minimo
	
    addi x2, x1, 4 #Comienzo del bucle interior en j = i+1 
inner_loop:
	lw x6, 0(x3) #Valor del dato minimo
    
	lw x5, 0(x2) #Valor del dato en la direccion j
    beq x5, x0, inner_loop_end #Condicion de salida del bucle interior
      
	bge x5, x6, end_if
if:
	add x3, x0, x2 #Direccion minima igual a j
end_if:
	addi x2, x2, 4
    jal x0, inner_loop
inner_loop_end:

	sw x6, 0(x1) #Intercambiar valores
    sw x4, 0(x3)

	addi x1, x1, 4
    jal x0, loop
end: