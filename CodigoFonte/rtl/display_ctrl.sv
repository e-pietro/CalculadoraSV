module Display_Ctrl (
    input logic [7:0] [3:0] displays,           // Entrada: valores dos displays (d0 a d7)
    output logic [7:0] [7:0] segments           // Saídas: segments[0]=A, segments[1]=B, ..., segments[7]=DP
);
        // Para cada um dos 8 displays, converte o dígito em sinais de 7 segmentos
    always_comb begin
        for (int i = 0; i < 8; i++) begin
            case (displays[i])
                    // '_' divide os números em dois grupos de 4 para melhor leitura
                4'b0000: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b11111100; // 0: a-f ligados, g e dp desligados
                4'b0001: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b01100000; // 1: b,c ligados, dp desligado
                4'b0010: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b11011010; // 2: a,b,d,e,g ligados, dp desligado
                4'b0011: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b11110010; // 3: a,b,c,d,g ligados, dp desligado
                4'b0100: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b01100110; // 4: b,c,f,g ligados, dp desligado
                4'b0101: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b10110110; // 5: a,c,d,f,g ligados, dp desligado
                4'b0110: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b10111110; // 6: a,c,d,e,f,g ligados, dp desligado
                4'b0111: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b11100000; // 7: a,b,c ligados, dp desligado
                4'b1000: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b11111110; // 8: todos ligados, dp desligado
                4'b1001: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b11110110; // 9: a,b,c,d,f,g ligados, dp desligado
                4'b1101: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b11111100; // O: a-f ligados, g e dp desligados (mesmo que 0)
                4'b1110: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b01100000; // R: mesmo que 1 (ajustado para simplificar)
                4'b1111: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b10011110; // E: a,d,e,f,g ligados, dp desligado
                default: {segments[0][i], segments[1][i], segments[2][i], segments[3][i], segments[4][i], segments[5][i], segments[6][i], segments[7][i]} = 8'b00000001; // Padrão: apenas dp ligado
            endcase
        end
    end
endmodule