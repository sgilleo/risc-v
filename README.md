# RISC-V Verilog

Un procesador basado en la arquitectura RISC-V 32I diseñado en Verilog para las prácticas de la asignatura ISDIGI.

## Descripcion

RISC-V es una arquitectura de conjunto de instrucciones (ISA) de hardware libre basado en un diseño de tipo RISC (conjunto de instrucciones reducido). El objetivo general del presente proyecto consiste en la realización, verificación funcional y validación experimental de un microcontrolador sencillo basado en un subconjunto de la arquitectura del juego de instrucciones del RISC-V.

## Programas en ensamblador

El proyecto contiene dos programas en ensamblador (Fibonacci y Ordenamiento) de ejemplo junto a sus respectivos testbench en SystemVerilog.

El programa de Fibonacci obtiene la secuencia de Fibonacci de n números donde n es un número especificado en el registro x2.

El programa de Ordenamiento de números escribe datos arbitrarios en las primeras posiciones de la memoria de datos y postriormente los ordena de menor a mayor hasta que se encuentra un cero, que marca el último número.

## Testbench Fase 1

Los testbench para las unidades funcionales de la CPU son: tb_ALU.sv, tb_RAM.sv, tb_ROM.sv, tb_REG.sv

## Testbench Fase 2

El testbench para la verificación exhaustiva y automatizada de todas las instrucciones es tb_CPU_Core.sv

Los testbench para la verificación de los dos programas de ensamblador son tb_Fibonacci.sv y tb_Sorting.sv