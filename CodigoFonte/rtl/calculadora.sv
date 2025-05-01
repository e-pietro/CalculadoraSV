module Calculadora (
    input logic reset,
    input logic clock,
    input logic [3:0] cmd,                      // Entrada: comando ou dígito (0-9, a=+, b=-, c=*, e=resultado)
    output logic [1:0] status,                  // Saída: estado (00=PRONTA, 01=OCUPADA, 10=ERRO)
    output logic [7:0][3:0] digits              // Saída: valores dos dígitos (d0 a d7)
);
    // Definição dos estados
    typedef enum logic [1:0] {
        PRONTA  = 2'b00,                        // Calculadora pronta para entrada
        OCUPADA = 2'b01,                        // Durante multiplicação
        ERRO    = 2'b10                         // Estado de erro
    } state_t;

        // Registradores
    state_t state;                              // Estado atual
    logic [3:0] digits_counter;                 // Contador de dígitos inseridos (0 a 8)
    logic [31:0] mult_counter;                   // Contador de ciclos de multiplicação
    logic [31:0] cycles_to_run;                 // Número de ciclos a executar (baseado em operator2)
    logic [3:0] operation;                      // Armazena o comando da operação
    logic [31:0] operator1;                     // Primeiro número da operação
    logic [31:0] operator2;                     // Segundo número da operação
    logic [31:0] result;                        // Resultado da operação
    logic calculate_result;                     // Flag para indicar que o resultado deve ser calculado
    logic waiting_for_second_operand;           // Flag para indicar que estamos esperando o segundo operando

        // Variáveis combinacionais
    logic [31:0] operator1_comb;                // Valor combinacional de operator1
    logic [31:0] operator2_comb;                // Valor combinacional de operator2

        // Lógica combinacional para calcular operator1 e operator2
    always_comb begin
        operator1_comb = 0;
        operator2_comb = 0;
            // Calcula os operadores a partir dos dígitos (d0 é o menos significativo)
        for (int i = 0; i < digits_counter; i++) begin
            operator1_comb = operator1_comb + (digits[i] * (10 ** i));
            operator2_comb = operator2_comb + (digits[i] * (10 ** i));
        end
    end

        // Máquina de estados e lógica síncrona
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            state <= PRONTA;                    // Estado inicial: PRONTA
            for (int i = 0; i < 8; i++) begin
                digits[i] <= 4'b0000;           // Zera todos os dígitos
            end
            digits_counter <= 4'b0000;
            operator1 <= 32'b0;
            operator2 <= 32'b0;
            result <= 32'b0;
            mult_counter <= 4'b0000;
            cycles_to_run <= 32'b0;
            operation <= 4'b0000;
            status <= PRONTA;
            calculate_result <= 0;
            waiting_for_second_operand <= 0;
        end else begin
                // Atualiza status
            status <= state;

                // Processa o cálculo do resultado se a flag estiver ativa
            if (calculate_result) begin
                calculate_result <= 0;
                    // Calcula resultado
                if (operation == 4'b1010) begin
                    result <= operator1 + operator2;
                end else if (operation == 4'b1011) begin
                    if (operator1 >= operator2) begin
                        result <= operator1 - operator2;
                    end else begin
                        state <= ERRO;          // Resultado negativo
                        digits_counter <= 4'd4; // Configura para 4 dígitos ("ERRO")
                    end
                end else if (operation == 4'b1100) begin
                    if (result <= 99999999 && state != ERRO) begin
                            // Exibe resultado dígito por dígito
                        automatic logic [31:0] temp_result = result;
                        for (int i = 0; i < 8; i++) begin
                            digits[i] <= 4'b0000;   // Zera antes de exibir
                        end
                        digits_counter <= 4'b0000;
                        for (int i = 0; i < 8 && temp_result > 0; i++) begin
                            digits[i] <= temp_result % 10;
                            temp_result = temp_result / 10;
                            digits_counter <= i + 1;
                        end
                        if (result == 0) begin
                            digits[0] <= 0;
                            digits_counter <= 1;
                        end
                    end
                end else if (state != ERRO) begin
                    state <= ERRO;              // Resultado grande
                    digits_counter <= 4'd4;     // Configura para 4 dígitos ("ERRO")
                end
            end

            case (state)
                PRONTA: begin
                        // Dígitos de 0 a 9
                    if (cmd <= 4'b1001) begin
                        if (digits_counter < 8) begin
                                // Move dígitos para a esquerda (d0 é o mais à direita)
                            for (int i = 7; i > 0; i--) begin
                                digits[i] <= digits[i-1];
                            end
                            digits[0] <= cmd;   // Insere novo dígito em d0
                            digits_counter <= digits_counter + 1;
                        end else begin
                            state <= ERRO;      // Display cheio
                            digits_counter <= 4'd4; // Configura para 4 dígitos ("ERRO")
                        end
                    end
                    // Soma, subtração, multiplicação
                    else if (cmd == 4'b1010 || cmd == 4'b1011 || cmd == 4'b1100) begin
                            // Usa valor combinacional para operator1
                        operator1 <= operator1_comb;
                            // Zera dígitos para próxima entrada
                        for (int i = 0; i < 8; i++) begin
                            digits[i] <= 4'b0000;
                        end
                        digits_counter <= 4'b0000;
                        operation <= cmd;
                        if (cmd == 4'b1100) begin
                            waiting_for_second_operand <= 1; // Espera o segundo operando
                        end
                    end
                    // Resultado
                    else if (cmd == 4'b1110 && digits_counter > 0) begin
                        if (waiting_for_second_operand) begin
                                // Captura o segundo operando e inicia a multiplicação
                            operator2 <= operator2_comb;
                            cycles_to_run <= operator2_comb;
                            waiting_for_second_operand <= 0;
                            state <= OCUPADA;
                            mult_counter <= 32'b0;
                            result <= 32'b0;
                        end else begin
                                // Processa soma ou subtração
                            operator2 <= operator2_comb;
                            calculate_result <= 1; // Ativa a flag para calcular o resultado no próximo ciclo
                        end
                    end
                        // Backspace
                    else if (cmd == 4'b1111 && digits_counter > 0) begin
                        for (int i = 0; i < 7; i++) begin
                            digits[i] <= digits[i+1];
                        end
                        digits[7] <= 4'b0000;
                        digits_counter <= digits_counter - 1;
                    end
                        // Ignora comandos inválidos (como x)
                    else begin
                        state <= PRONTA;
                    end
                end

                OCUPADA: begin
                    if (mult_counter < cycles_to_run) begin
                            // Realiza uma soma por ciclo
                        result <= result + operator1;
                        mult_counter <= mult_counter + 1;
                    end else begin
                            // Verifica limites após o cálculo
                        if (cycles_to_run > 1500000) begin
                            state <= ERRO; // Operando grande
                            digits_counter <= 4'd4; // Configura para 4 dígitos ("ERRO")
                        end else if (result <= 99999999) begin
                                // Exibe resultado dígito por dígito
                            automatic logic [31:0] temp_result = result;
                            for (int i = 0; i < 8; i++) begin
                                digits[i] <= 4'b0000; // Zera antes de exibir
                            end
                            digits_counter <= 4'b0000;
                            for (int i = 0; i < 8 && temp_result > 0; i++) begin
                                digits[i] <= temp_result % 10;
                                temp_result = temp_result / 10;
                                digits_counter <= i + 1;
                            end
                            if (result == 0) begin
                                digits[0] <= 0;
                                digits_counter <= 1;
                            end
                            state <= PRONTA;
                        end else begin
                            state <= ERRO;          // Resultado grande
                            digits_counter <= 4'd4; // Configura para 4 dígitos ("ERRO")
                        end
                    end
                end

                ERRO: begin
                        // Configura os dígitos para exibir "ERRO"
                    digits[0] <= 4'b1101; // O (d0)
                    digits[1] <= 4'b1100; // R (d1)
                    digits[2] <= 4'b1100; // R (d2)
                    digits[3] <= 4'b1111; // E (d3)
                    digits[4] <= 4'b0000; // Apagado (d4)
                    digits[5] <= 4'b0000; // Apagado (d5)
                    digits[6] <= 4'b0000; // Apagado (d6)
                    digits[7] <= 4'b0000; // Apagado (d7)
                    digits_counter <= 4'd4; // Mantém 4 dígitos ativos
                        // Permanece no estado ERRO até o reset
                end

                default: begin
                    state <= PRONTA;
                    for (int i = 0; i < 8; i++) begin
                        digits[i] <= 4'b0000;
                    end
                    digits_counter <= 4'b0000;
                end
            endcase
        end
    end
endmodule
