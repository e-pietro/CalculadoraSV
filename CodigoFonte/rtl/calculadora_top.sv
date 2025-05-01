module Calculadora_Top (
    input logic reset,
    input logic clock,
    input logic [3:0] cmd,                  // Entrada: comando ou dígito (0-9, a=+, b=-, c=*, e=resultado)
    output logic [1:0] status,              // Saída: estado (00=PRONTA, 01=OCUPADA, 10=ERRO)
    output logic [7:0][7:0] segments,       // Saídas: segments[0]=A, segments[1]=B, ..., segments[7]=DP
    output logic [7:0][3:0] displays        // Saída: valores dos displays (d0 a d7) para o testbench
);
        // Sinais internos
    logic [7:0][3:0] calc_digits;           // Dígitos do Calculadora

        // Instancia o módulo Calculadora
    Calculadora calc (
        .reset(reset),
        .clock(clock),
        .cmd(cmd),
        .status(status),
        .digits(calc_digits)
    );

        // Instancia o módulo Display_Ctrl
    Display_Ctrl disp (
        .displays(displays),
        .segments(segments)
    );

        // Lógica para atualizar os displays
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 8; i++) begin
                displays[i] <= 4'b0000;     // Zera todos os displays
            end
        end else begin
                // Atualiza todos os displays de uma vez
            for (int i = 0; i < 8; i++) begin
                displays[i] <= calc_digits[i];
            end
        end
    end
endmodule