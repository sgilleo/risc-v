init: # Inicializar los valores en la memoria
    addi x1, x0, 0x000 # Cargar la dirección de memoria inicial (Índice i)

    # Inicializar el arreglo
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

    addi x2, x0, 0 # Fin del arreglo
    sw x2, 36(x1)

    nop # Espacio para asegurar propagación en el pipeline

# x1: Dirección i
# x2: Dirección j
# x3: Dirección del dato mínimo
# x4: Valor del dato actual (i)
# x5: Valor del dato en la dirección j
# x6: Valor del dato en la dirección mínima

loop:
    lw x4, 0(x1)       # Cargar el valor actual
    beq x4, x0, end    # Condición de salida del algoritmo (último dato es 0)
    nop                # Espacio para prevenir riesgos estructurales
    
    add x3, x0, x1     # Dirección del valor mínimo (suponemos que i es el mínimo)
    addi x2, x1, 4     # Comienzo del bucle interior: j = i + 1

inner_loop:
    lw x6, 0(x3)       # Cargar el valor mínimo actual
    lw x5, 0(x2)       # Cargar el valor del siguiente elemento (j)
    nop                # Espacio para lectura de memoria
    beq x5, x0, inner_loop_end # Si llegamos al final del arreglo, terminamos el bucle interior
    
    bge x5, x6, end_if # Si el valor actual no es menor, saltar la asignación
    nop                # Espacio para la comparación
if:
    add x3, x0, x2     # Actualizar la dirección mínima al índice j
end_if:
    addi x2, x2, 4     # Avanzar al siguiente índice (j)
    nop                # Espacio para prevenir riesgos estructurales
    jal x0, inner_loop # Regresar al inicio del bucle interior

inner_loop_end:
    sw x6, 0(x1)       # Guardar el valor mínimo en la posición actual
    sw x4, 0(x3)       # Guardar el valor actual en la posición mínima
    nop                # Espacio para escritura de memoria

    addi x1, x1, 4     # Avanzar al siguiente índice (i)
    nop                # Espacio para prevenir riesgos de datos
    jal x0, loop       # Regresar al inicio del bucle principal

end:
    nop                # Espacio para finalizar
    