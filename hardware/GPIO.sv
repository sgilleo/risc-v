module GPIO(data_in,seg0, seg1, seg2, seg3, seg4);

	input [31:0]data_in; 
	output [6:0]seg0,seg1,seg2,seg3,seg4;

	
	logic [3:0]d0,d1,d2,d3,d4;
	
	always_comb begin
	
	d0 = data_in % 32'd10;
	d1 = (data_in/32'd10) % 32'd10;
	d2 = (data_in/32'd100) % 32'd10;
	d3 = (data_in/32'd1000) % 32'd10;
	d4 = (data_in/32'd10000) % 32'd10;
	
	end
	
	
always_comb
	begin
case (d0)
            4'h0: seg0 = 7'b1000000;
            4'h1: seg0 = 7'b1111001;
            4'h2: seg0 = 7'b0100100;
            4'h3: seg0 = 7'b0110000;
            4'h4: seg0 = 7'b0011001;
            4'h5: seg0 = 7'b0010010;
            4'h6: seg0 = 7'b0000010;
            4'h7: seg0 = 7'b1111000;
            4'h8: seg0 = 7'b0000000;
            4'h9: seg0 = 7'b0010000;
            4'hA: seg0 = 7'b0000100;
            4'hB: seg0 = 7'b0000011;
            4'hC: seg0 = 7'b1000110;
            4'hD: seg0 = 7'b0100001;
            4'hE: seg0 = 7'b0000110;
            4'hF: seg0 = 7'b0001110;
            default: seg0 = 7'b1111111; // Apagado (ánodo común)
        endcase
    end

	 
always_comb
	begin
case (d1)
            4'h0: seg1 = 7'b1000000;
            4'h1: seg1 = 7'b1111001;
            4'h2: seg1 = 7'b0100100;
            4'h3: seg1 = 7'b0110000;
            4'h4: seg1 = 7'b0011001;
            4'h5: seg1 = 7'b0010010;
            4'h6: seg1 = 7'b0000010;
            4'h7: seg1 = 7'b1111000;
            4'h8: seg1 = 7'b0000000;
            4'h9: seg1 = 7'b0010000;
            4'hA: seg1 = 7'b0000100;
            4'hB: seg1 = 7'b0000011;
            4'hC: seg1 = 7'b1000110;
            4'hD: seg1 = 7'b0100001;
            4'hE: seg1 = 7'b0000110;
            4'hF: seg1 = 7'b0001110;
            default: seg1 = 7'b1111111; // Apagado (ánodo común)
        endcase
    end

always_comb
	begin
case (d2)
            4'h0: seg2 = 7'b1000000;
            4'h1: seg2 = 7'b1111001;
            4'h2: seg2 = 7'b0100100;
            4'h3: seg2 = 7'b0110000;
            4'h4: seg2 = 7'b0011001;
            4'h5: seg2 = 7'b0010010;
            4'h6: seg2 = 7'b0000010;
            4'h7: seg2 = 7'b1111000;
            4'h8: seg2 = 7'b0000000;
            4'h9: seg2 = 7'b0010000;
            4'hA: seg2 = 7'b0000100;
            4'hB: seg2 = 7'b0000011;
            4'hC: seg2 = 7'b1000110;
            4'hD: seg2 = 7'b0100001;
            4'hE: seg2 = 7'b0000110;
            4'hF: seg2 = 7'b0001110;
            default: seg2 = 7'b1111111; // Apagado (ánodo común)
        endcase
    end

	 
always_comb
	begin
case (d3)
            4'h0: seg3 = 7'b1000000;
            4'h1: seg3 = 7'b1111001;
            4'h2: seg3 = 7'b0100100;
            4'h3: seg3 = 7'b0110000;
            4'h4: seg3 = 7'b0011001;
            4'h5: seg3 = 7'b0010010;
            4'h6: seg3 = 7'b0000010;
            4'h7: seg3 = 7'b1111000;
            4'h8: seg3 = 7'b0000000;
            4'h9: seg3 = 7'b0010000;
            4'hA: seg3 = 7'b0000100;
            4'hB: seg3 = 7'b0000011;
            4'hC: seg3 = 7'b1000110;
            4'hD: seg3 = 7'b0100001;
            4'hE: seg3 = 7'b0000110;
            4'hF: seg3 = 7'b0001110;
            default: seg3 = 7'b1111111; // Apagado (ánodo común)
        endcase
    end

	 
always_comb
	begin
case (d4)
            4'h0: seg4 = 7'b1000000;
            4'h1: seg4 = 7'b1111001;
            4'h2: seg4 = 7'b0100100;
            4'h3: seg4 = 7'b0110000;
            4'h4: seg4 = 7'b0011001;
            4'h5: seg4 = 7'b0010010;
            4'h6: seg4 = 7'b0000010;
            4'h7: seg4 = 7'b1111000;
            4'h8: seg4 = 7'b0000000;
            4'h9: seg4 = 7'b0010000;
            4'hA: seg4 = 7'b0000100;
            4'hB: seg4 = 7'b0000011;
            4'hC: seg4 = 7'b1000110;
            4'hD: seg4 = 7'b0100001;
            4'hE: seg4 = 7'b0000110;
            4'hF: seg4 = 7'b0001110;
            default: seg4 = 7'b1111111; // Apagado (ánodo común)
        endcase
    end

	
	
endmodule
