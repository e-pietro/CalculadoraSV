module tb_Calculadora_Top;
    logic reset;
    logic clock;
    logic [3:0] cmd;
    logic [1:0] status;
    logic [7:0] [7:0] segments;
    logic [7:0] [3:0] displays;

    Calculadora_Top top (
        .reset(reset),
        .clock(clock),
        .cmd(cmd),
        .status(status),
        .segments(segments),
        .displays(displays)
    );

    always #5 clock = ~clock;

    initial begin
            // Monitora quando os valores inseridos a cada borda de descida
        $monitor("Time=%0t cmd=%h reset=%b status=%h displays[7:0]=%h %h %h %h %h %h %h %h segments[7:0]=%h %h %h %h %h %h %h %h",
                 $time, cmd, reset, status,
                 displays[7], displays[6], displays[5], displays[4],
                 displays[3], displays[2], displays[1], displays[0],
                 segments[7], segments[6], segments[5], segments[4],
                 segments[3], segments[2], segments[1], segments[0]);
        clock = 0;
        reset = 1;
        cmd = 4'b0000;  // Valor indefinido para cmd
        #5;
        reset = 0;
        #5;

        // Teste 1: Soma (10 + 21 = 31)
        $display("\n--- Teste 1: Soma (10 + 21 = 31) ---");
        // Inserir 10
        cmd = 4'b0001;   // 1
        #10;
        cmd = 4'b0000;   // 0
        #10;
        // Soma
        cmd = 4'b1010;   // +
        #10;
        // Inserir 21
        cmd = 4'b0010;   // 2
        #10;
        cmd = 4'b0001;   // 1
        #10;
        // Resultado
        cmd = 4'b1110;   // =
        #50;

        // Teste 2: Subtração (30 - 15 = 15)
        $display("\n--- Teste 2: Subtracao (30 - 15 = 15) ---");
        reset = 1;       // Reset para iniciar um novo teste
        #10;
        reset = 0;
        #10;
        // Inserir 30
        cmd = 4'b0011;   // 3
        #10;
        cmd = 4'b0000;   // 0
        #10;
        // Subtração
        cmd = 4'b1011;   // -
        #10;
        // Inserir 15
        cmd = 4'b0001;   // 1
        #10;
        cmd = 4'b0101;   // 5
        #10;
        // Resultado
        cmd = 4'b1110;   // =
        #50;

        // Teste 3: Multiplicação (3 * 4 = 12)
        $display("\n--- Teste 3: Multiplicacao (3 * 4 = 12) ---");
        reset = 1;       // Reset para iniciar um novo teste
        #10;
        reset = 0;
        #10;
        // Inserir 3
        cmd = 4'b0011;   // 3
        #10;
        // Multiplicação
        cmd = 4'b1100;   // *
        #10;
        // Inserir 4
        cmd = 4'b0100;   // 4
        #10;
        // Resultado
        cmd = 4'b1110;   // =
        #20000;

        // Teste 4: Erro (inserir mais de 8 dígitos: 123456789)
        $display("\n--- Teste 4: Erro (inserir mais de 8 digitos: 123456789) ---");
        reset = 1;       // Reset para iniciar um novo teste
        #10;
        reset = 0;
        #10;
        // Inserir 123456789
        cmd = 4'b0001;   // 1
        #10;
        cmd = 4'b0010;   // 2
        #10;
        cmd = 4'b0011;   // 3
        #10;
        cmd = 4'b0100;   // 4
        #10;
        cmd = 4'b0101;   // 5
        #10;
        cmd = 4'b0110;   // 6
        #10;
        cmd = 4'b0111;   // 7
        #10;
        cmd = 4'b1000;   // 8
        #10;
        cmd = 4'b1001;   // 9 (deve acionar o estado ERRO)
        #50;
    end
endmodule
