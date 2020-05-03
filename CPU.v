module CPU(

//2^23 Hz clock
input wire pllClk,

output reg idk,
output test_cpu,

output wire VCC,	//5V

output wire clock,	//pin 2

output write = 1'b0,		//pin 3
output read = 1'b1,		//pin 4
output chip,		//pin 5

output reg [15:0] add,		//address pins
output reg [15:0] store_add,	//to store the next address

input wire [7:0] data_in,	//data coming in from the cartridge (shares the same pins as data_out)
output reg [7:0] data_out,	//data going out to the cartridge (shares the same pins as data_in)

output wire SRAM,		//pin 30

input wire REQ,			//pin 31

input wire ground,


//registers
output reg halt = 1'b0,
output reg [7:0] A = 8'h00,
output reg [7:0] F = 8'h00,
output reg [7:0] B = 8'h00,
output reg [7:0] C = 8'h00,
output reg [7:0] D = 8'h00,
output reg [7:0] E = 8'h00,
output reg [7:0] H = 8'h00,
output reg [7:0] L = 8'h00,

output reg [15:0] SP = 16'h0000,		//stack pointer
output reg [15:0] PC = 16'h0100,		//program counter
output reg [15:0] CI = 16'h0100,

output reg [2:0] TCycle = 3'd0,		//1 clock tick
output reg [2:0] MCycle = 3'd0,		//4 TCycles

//flags
output wire flagZ = 1'b0,		//zero
output wire flagN = 1'b0,		//negative
output wire flagH = 1'b0,		//half carry
output wire flagC = 1'b0		//full carry

);

initial
begin

end
//


always @ (posedge pllClk)
begin
	case(data_in)
		
		
		/////////////////
		// 8-bit loads //
		/////////////////
		
		
		//ld nn, n
		8'h06,8'h0E,8'h16,8'h1E,8'h26,8'h2E:
		begin
		
			TCycle <= 3'd4;	//set tick/machine cycles
			MCycle <= 3'd1;
			
				case (data_in)
					8'h06:	//B
					begin
						PC <= PC +1;
						CI = PC +1;
						add = PC;
						B = data_in;
					end
					
					8'h0E:	//C
					begin
						PC = PC +1;
						add = PC;
						C = data_in;					
					end
					
					8'h16:	//D
					begin
						PC = PC +1;
						add = PC;
						D = data_in;
					end
					
					8'h1E:	//E
					begin
						PC = PC +1;
						add = PC;
						E = data_in;
					end
					
					8'h26:	//H
					begin
						PC = PC +1;
						add = PC;
						H = data_in;
					end
					
					8'h2E:	//L
					begin
						PC = PC +1;
						add = PC;
						L = data_in;
					end
				endcase
		end
		
		//ld r1, r2
		8'h7F,8'h78,8'h79,8'h7A,8'h7B,8'h7C,8'h7D,8'h7E,8'h40,8'h41,
		8'h42,8'h43,8'h44,8'h45,8'h46,8'h48,8'h49,8'h4A,8'h4B,8'h4C,
		8'h4D,8'h4E,8'h50,8'h51,8'h52,8'h53,8'h54,8'h55,8'h56,8'h58,
		8'h59,8'h5A,8'h5B,8'h5C,8'h5D,8'h5E,8'h60,8'h61,8'h62,8'h63,
		8'h64,8'h65,8'h66,8'h68,8'h69,8'h6A,8'h6B,8'h6C,8'h6D,8'h6E,
		8'h70,8'h71,8'h72,8'h73,8'h74,8'h75,8'h36:
		begin
		
		
		end
		
		//ld A, n
		8'h7F,8'h78,8'h79,8'h7A,8'h7B,8'h7C,8'h7D,8'h0A,8'h1A,8'h7E,8'hFA,8'h3E:
		begin
		
			case(data_in)	//determine if address is 16 or 8 bit
				8'h0A,8'h1A,8'h7E:	//16 bit
				begin
					case(data_in)
						8'h0A:	//BC
						begin
							PC <= PC +1;
							CI[15:8] <= B;
							CI[7:0] = C;
							add = CI;
							A = data_in;
							add = PC;
						end
						
						8'h1A:	//DE
						begin
							PC <= PC +1;
							CI[15:8] <= D;
							CI[7:0] = E;
							add = CI;
							A = data_in;
							add = PC;
						end
						
						8'h7E:	//HL
						begin
							PC <= PC +1;
							CI[15:8] <= H;
							CI[7:0] = L;
							add = CI;
							A = data_in;
							add = PC;
						end
					endcase
				end
				
				8'h7F,8'h78,8'h79,8'h7A,8'h7B,8'h7C,8'h7D:	//8 bit
				begin
				
				end
				
				8'hFA:	//based on next 2 opcodes
				begin
					PC <= PC +1;
					CI = PC +1;
					add = PC;
					store_add [7:0] = data_in;	//store the current data for least significant byte (blocking)
					
					PC <= PC +1;
					CI = PC +1;
					add = PC;
					store_add [15:8] = data_in;	//store the current data for most significant byte (blocking)
					add [15:0] = store_add [15:0];	//set address to data that was read
					A = data_in;	//store data at address to reg A
					
					PC <= PC +1;
					CI = PC +1;
					add [15:0] = PC [15:0];
				end
				
				8'h3E:	//store next opcode to reg A
				begin
					PC <= PC +1;
					CI = PC +1;
					add = PC;
					A = data_in;
				end
				
			endcase
				
				
		
		end
		
		//ld n, A
		8'h7F,8'h47,8'h4F,8'h57,8'h5F,8'h67,8'h6F,8'h02,8'h12,8'h77,8'hEA:
		begin
		end
		
		//LD A, (C)
		8'hF2:
		begin
		end
		
		//LC (C), A
		8'hE2:
		begin
		end
		
		//LD A, (HL-)
		8'h3A:
		begin
		end
		
		//LD (HL-), A
		8'h32:
		begin
		end
		
		//LD A, (HL+)
		8'h2A:
		begin
		end
		
		//LD (HL+), A
		8'h22:
		begin
		end
		
		//LD (hFF00+n), A
		8'hE0:
		begin
		end
		
		//LD A, (hFF00+n)
		8'hF0:
		begin
		end
		
		
		//////////////////
		// 16-bit loads //
		//////////////////
		
		
		//LD n, nn
		8'h01,8'h11,8'h21,8'h31:
		begin
		end
		
		//LD SP, HL
		8'hF9:
		begin
		end
		
		//LD HL, SP+n
		8'hF8:
		begin
		end
		
		//LD (nn), SP
		8'h08:
		begin
		end
		
		//PUSH nn
		8'hC5,8'hD5,8'hE5,8'hF5:
		begin
		end
		
		//POP nn
		8'hC1,8'hD1,8'hE1,8'hF1:
		begin
		end
		
		
		//////////////////////
		// 8-bit arithmetic //
		//////////////////////
		
		
		//ADD A, n
		8'h80,8'h81,8'h82,8'h83,8'h84,8'h85,8'h86,8'h87,8'hC6:
		begin
		end
		
		//ADC A, n
		8'h88,8'h89,8'h8A,8'h8B,8'h8C,8'h8D,8'h8E,8'h8F,8'hCE:
		begin
		end
		
		//SUB n
		8'h90,8'h91,8'h92,8'h93,8'h94,8'h95,8'h96,8'h97,8'hD6:
		begin
		end
		
		//SBC A, n
		8'h98,8'h99,8'h9A,8'h9B,8'h9C,8'h9D,8'h9E,8'h9F:
		begin
		end
		
		//AND n
		8'hA0,8'hA1,8'hA2,8'hA3,8'hA4,8'hA5,8'hA6,8'hA7,8'hE6:
		begin
		end
		
		//OR n
		8'hB7,8'hB0,8'hB1,8'hB2,8'hB3,8'hB4,8'hB5,8'hB6,8'hF6:
		begin
		end
		
		//XOR n
		8'hA8,8'hA9,8'hAA,8'hAB,8'hAC,8'hAD,8'hAE,8'hAF,8'hEE:
		begin
		end
		
		//CP n
		8'hB8,8'hB9,8'hBA,8'hBB,8'hBC,8'hBD,8'hBE,8'hBF,8'hFE:
		begin
		end
		
		//INC n
		8'h04,8'h0C,8'h14,8'h1C,8'h24,8'h2C,8'h34,8'h3C:
		begin
		end
		
		//DEC n
		8'h05,8'h0D,8'h15,8'h1D,8'h25,8'h2D,8'h35,8'h3D:
		begin
		end
		
		
		///////////////////////
		// 16-bit arithmetic //
		///////////////////////
		
		
		//ADD HL, n
		8'h09,8'h19,8'h29,8'h39:
		begin
		end
		
		//ADD SP, n
		8'hE8:
		begin
		end
		
		//INC nn
		8'h03,8'h13,8'h23,8'h33:
		begin
		end
		
		//DEC nn
		8'h0B,8'h1B,8'h2B,8'h3B:
		begin
		end
		
		
		///////////
		// Misc. //
		///////////
		
		
		//DAA
		8'h27:
		begin
		end
		
		//CPL
		8'h2F:
		begin
		end
		
		//CCF
		8'h3F:
		begin
		end
		
		//SCF
		8'h37:
		begin
		end
		
		//NOP
		8'h00:
		begin
		end
		
		//HALT
		8'h76:
		begin
		end
		
		//STOP
		8'h10:
		begin
		end
		
		//DI
		8'hF3:
		begin
		end
		
		//EI
		8'hFB:
		begin
		end
		
		
		////////////////////////
		// Rotates and Shifts //
		////////////////////////
		
		
		//RLCA
		8'h07:
		begin
		end
		
		//RLA
		8'h17:
		begin
		end
		
		//RRCA
		8'h0F:
		begin
		end
		
		//RRA
		8'h1F:
		begin
		end
		
		
		///////////
		// Jumps //
		///////////
		
		
		//JP nn
		8'hC3:
		begin
		
		end
		
		//JP cc, nn
		8'hC2,8'hCA,8'hD2,8'hDA:
		begin
		
		end
		
		//JP (HL)
		8'hE9:
		begin
		
		end
		
		//JR n
		8'h18:
		begin
		
		end
		
		//JR cc, n
		8'h20,8'h28,8'h30,8'h38:
		begin
		
		end
		
		
		///////////
		// Calls //
		///////////
		
		
		//Call nn
		8'hCD:
		begin
		
		end
		
		//Call cc, nn
		8'hC4,8'hCC,8'hD4,8'hDC:
		begin
		
		end
		
		
		//////////////
		// Restarts //
		//////////////
		
		
		//RST n
		8'hC7,8'hCF,8'hD7,8'hDF,8'hE7,8'hEF,8'hF7,8'hFF:
		begin
		
		end
		
		
		/////////////
		// Returns //
		/////////////
		
		
		//RET
		8'hC9:
		begin
		
		end
		
		//RET cc
		8'hC0,8'hC8,8'hD0,8'hD8:
		begin
		
		end
		
		//RETI
		8'hD9:
		begin
		
		end
		
		
		////////////////
		// CB opcodes //
		////////////////
		
		
		8'hCB:
		begin
		case(data_in)
		
			//SWAP n
			8'h30,8'h31,8'h32,8'h33,8'h34,8'h35,8'h36,8'h37:
			begin
			
			end
			
			//RLC n
			8'h00,8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07:
			begin
			
			end
			
			//RL n
			8'h10,8'h11,8'h12,8'h13,8'h14,8'h15,8'h16,8'h17:
			begin
			
			end
			
			//RRC n
			8'h08,8'h09,8'h0A,8'h0B,8'h0C,8'h0D,8'h0E,8'h0F:
			begin
			
			end
			
			//RR n
			8'h18,8'h19,8'h1A,8'h1B,8'h1C,8'h1D,8'h1E,8'h1F:
			begin
			
			end
			
			//SLA n
			8'h20,8'h21,8'h22,8'h23,8'h24,8'h25,8'h26,8'h27:
			begin
			
			end
			
			//SRA n
			8'h28,8'h29,8'h2A,8'h2B2C,8'h2D,8'h2E,8'h2F:
			begin
			
			end
			
			//SRL n
			8'h38,8'h39,8'h3A,8'h3B,8'h3C,8'h3D,8'h3E,8'h3F:
			begin
			
			end
			
			//BIT b, r
			8'h40,8'h41,8'h42,8'h43,8'h44,8'h45,8'h46,8'h47:
			begin
			
			end
			
			//SET b, r
			8'hC0,8'hC1,8'hC2,8'hC3,8'hC4,8'hC5,8'hC6,8'hC7:
			begin
			
			end
			
			//RES b, r
			8'h80,8'h81,8'h82,8'h83,8'h84,8'h85,8'h86,8'h87:
			begin
			
			end
		
		endcase
		end
		
		
	endcase
	
end

assign flagZ = F[7];
assign flagN = F[6];
assign flagH = F[5];
assign flagC = F[4];

//assign add[15:0] = input wire add[15:0];

endmodule