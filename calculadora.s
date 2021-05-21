@Calculadora RPN
@Grupo:
@   Diego Henrique Arenas Okawa     (RA: 2127890)
@   Louis Brommelstroet     (RA: 2127997)

.data
.equ SWI_SETLED,        0x201    @LEDs on/off                       
.equ SWI_CheckBlack,    0x202    @check Black button
.equ SWI_CheckBlue,     0x203    @check press Blue button
.equ SWI_DRAW_INT,      0x205    @display an int on LCD             
.equ SWI_CLEAR_DISPLAY, 0x206    @clear LCD
.equ SWI_CLEAR_LINE,    0x208    @clear a line on LCD
.equ RIGHT_LED,         0x02     @bit patterns for LED lights
.equ LEFT_BLACK_BUTTON, 0x01     @bit patterns for black buttons
.equ BLUE_KEY_00,       1<<0     @button(0)
.equ BLUE_KEY_01,       1<<1     @button(1)
.equ BLUE_KEY_02,       1<<2     @button(2)
.equ BLUE_KEY_03,       1<<3     @button(3)
.equ BLUE_KEY_04,       1<<4     @button(4)
.equ BLUE_KEY_05,       1<<5     @button(5)
.equ BLUE_KEY_06,       1<<6     @button(6)
.equ BLUE_KEY_07,       1<<7     @button(7)
.equ BLUE_KEY_08,       1<<8     @button(8)
.equ BLUE_KEY_09,       1<<9     @button(9)
.equ BLUE_KEY_10,       1<<10    @button(10)
.equ BLUE_KEY_11,       1<<11    @button(11)
.equ BLUE_KEY_12,       1<<12    @button(12)
.equ BLUE_KEY_13,       1<<13    @button(13)
.equ BLUE_KEY_14,       1<<14    @button(14)
.equ BLUE_KEY_15,       1<<15    @button(15)
pilha:  .space 24
.align
.text

start:
    ldr r9, =pilha                      @Carrega o endereço da pilha no registrador r9
    mov r1, #0                          @Escreve 0 no registrador r1, que é a posição na pilha
    mov r2, #0                          @Escreve 0 no registrador r2, que é penúltimo valor da pilha
    mov r3, #0                          @Escreve 0 no registrador r3, que é o valor atual da pilha
    swi SWI_CLEAR_DISPLAY               @Limpa a tela
    b print                             @Atualiza a tela

loop:
black:
    swi SWI_CheckBlack                  @Retorna os botões pretos pressionados
    tst r0, #LEFT_BLACK_BUTTON          @Verifica se o botão apertado foi o esquerdo (01 nesta versao do ARMSIM)
    beq blue                            @Se não, testa os botões azuis
    swi SWI_CLEAR_DISPLAY               @Limpa a tela
    mov r1, #0                          @Zera a posição na pilha
    mov r2, #0                          @Limpa o penúltimo valor da pilha
    mov r3, #0                          @Limpa o valor atual da pilha
    b print                             @Atualiza a tela
    
blue:
    swi SWI_CheckBlue                   @Retorna os botões azuis pressionados 
    cmp r0, #0                          @Verifica se nenhum botão azul foi pressionado 
    beq loop                            @Se sim, reinicia o loop

enter:
    tst r0, #BLUE_KEY_12                @Verifica se o botão 12 (tecla ENTER) foi pressionado
    beq digit                           @Se não, testa os dígitos
    cmp r1, #6                          @Verifica se a pilha está cheia
    beq print                           @Se sim, atualiza a tela
    str r2, [r9, r1, lsl #2]            @Armazena o penúltimo valor (r2) no endereço da pilha (r9) + a posição na pilha * 4 bytes (r1 deslocado por 2 bits a esquerda)
    add r1, r1, #1                      @Incrementa o tamanho da pilha
    mov r3, r2                          @O valor atual passa a ser o penúltimo
    mov r2, #0                          @Limpa o valor atual
    b print                             @Atualiza a tela

digit:
    mov r8, #10                         @Escreve 10 (valor temporário) no registrador r8 (valor numérico da tecla pressionada)
    mov r7, #10                         @Armazena 10
    tst r0, #BLUE_KEY_00                @Verifica se o botão 00 (tecla 1) foi pressionado
    movne r8, #1                        @Se sim, escreve 1 
    tst r0, #BLUE_KEY_01                @Verifica se o botão 01 (tecla 2) foi pressionado
    movne r8, #2                        @Se sim, escreve 2
    tst r0, #BLUE_KEY_02                @Verifica se o botão 02 (tecla 3) foi pressionado
    movne r8, #3                        @Se sim, escreve 3
    tst r0, #BLUE_KEY_04                @Verifica se o botão 04 (tecla 4) foi pressionado
    movne r8, #4                        @Se sim, escreve 4
    tst r0, #BLUE_KEY_05                @Verifica se o botão 05 (tecla 5) foi pressionado
    movne r8, #5                        @Se sim, escreve 5
    tst r0, #BLUE_KEY_06                @Verifica se o botão 06 (tecla 6) foi pressionado
    movne r8, #6                        @Se sim, escreve 6
    tst r0, #BLUE_KEY_08                @Verifica se o botão 08 (tecla 7) foi pressionado
    movne r8, #7                        @Se sim, escreve 7
    tst r0, #BLUE_KEY_09                @Verifica se o botão 09 (tecla 8) foi pressionado
    movne r8, #8                        @Se sim, escreve 8
    tst r0, #BLUE_KEY_10                @Verifica se o botão 10 (tecla 9) foi pressionado
    movne r8, #9                        @Se sim, escreve 9
    tst r0, #BLUE_KEY_13                @Verifica se o botão 13 (tecla 0) foi pressionado
    movne r8, #0                        @Se sim, escreve 0
    cmp r8, #10                         @Verifica se o registrador r8 é igual a 10 (valor temporario definido)
    beq operation                       @Se sim, ele não foi modificado, então testa as teclas de operação
    mla r2, r7, r2, r8                  @Atualiza o valor atual multiplicado por 10 (r7) e adiciona r8 (valor numérico da tecla pressionada)
    b print                             @Atualiza a tela

operation:
    cmp r1, #0                          @Verifica se a posição na pilha é zero, já que não é possível operar com menos de 2 valores
    beq print                           @Se sim, atualiza a tela
    tst r0, #BLUE_KEY_03                @Verifica se o botão 03 (tecla +) foi pressionado
    addne r2, r3, r2                    @Se sim, soma o penúltimo valor (r2) e o ultimo (r3) e armazena no penúltimo 
    bne operation_end                   @Se sim, pula para operation_end
    tst r0, #BLUE_KEY_07                @Verifica se o botão 07 (tecla -) foi pressionado
    subne r2, r3, r2                    @Se sim, subtrai o penúltimo valor (r2) do ultimo (r3) e armazena no penúltimo
    bne operation_end                   @Se sim, pula para operation_end
    tst r0, #BLUE_KEY_11                @Verifica se o botão 11 (tecla *) foi pressionado
    mulne r2, r3, r2                    @Se sim, multiplica o penúltimo valor (r2) com o ultimo (r3) e armazena no penúltimo
    bne operation_end                   @Se sim, pula para operation_end
    tst r0, #BLUE_KEY_14 + BLUE_KEY_15  @Verifica se o botão 14 (tecla do resto) ou o botão 15 (tecla da divisao) foram pressionadas
    beq print                           @Se nao, atualiza a tela
    cmp r2, #0                          @Verifica se o ultimo valor é igual a 0
    moveq r0, #RIGHT_LED                @Se sim, armazena o valor do LED direito como parametro em r0
    swieq SWI_SETLED                    @Se sim, acende o LED direito (02 nesta versao do ARMSIM) 
    beq print                           @Se sim, atualiza a tela
    mov r8, r2                          @Copia o divisor (r2) para r8
    mov r2, #0                          @Limpa o registrador r2

divide:
    subs r3, r3, r8                     @Subtrai o divisor (r8) de r3 e compara o resultado
    addge r2, r2, #1                    @Se for maior ou igual a 0, adiciona 1 ao r2
    bge divide                          @Caso sim, continua a dividir
    add r3, r3, r8                      @Faz a correção para se obter um resto positivo
    tst r0, #BLUE_KEY_14                @Verifica se o botão 14 (tecla do resto) foi pressionado
    movne r2, r3                        @Se sim, escreve o resto em r2 (valor atual)

operation_end:
    mov r0, r1                          @Escreve a posição da pilha como o número da linha na tela como parâmetro
    subs r1, r1, #1                     @Decrementa o tamanho da pilha
    ldr r3, [r9, r1, lsl #2]            @Carrega o valor atual (r3) do endereço da pilha (r9) + a posicao na pilha * 4 (r1 deslocado por 2 bits a esquerda)
    swi SWI_CLEAR_LINE                  @Limpa a linha antiga


print:
    mov r0, r1                          @Escreve a posição da pilha como o número da linha na tela como parâmetro
    swi SWI_CLEAR_LINE                  @Limpa a linha atual
    mov r0, #0                          @Escreve 0 como parâmetro (a posição x para SWI_DRAW_INT e nenhuma LED para SWI_SETLED) 
    swi SWI_DRAW_INT                    @Escreve o valor atual na tela
    swi SWI_SETLED                      @Apaga as LEDs
    b loop                              @Reinicia o loop
