//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output logic iocs,
    output logic iorw,
    input rda,
    input tbr,
    output logic [1:0] ioaddr,
    inout [7:0] databus
    );

logic [7:0] databus_out;
logic [7:0] databus_in;
assign databus = (~iorw) ? databus_out : 8'bzzzzzzzz;


typedef enum reg [2:0] {IDLE, RX_READ, CFG1, CFG2, TX} state_t;
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst) begin
    if (!rst) state <= IDLE;
    else state <= nxt_state;
end

always_ff @(posedge clk, negedge rst) begin
    if (!rst) databus_in <= 0;
    else if (iorw) databus_in <= databus;
end

always_comb begin
    iorw = 1;
    iocs = 1;
    ioaddr = 2'b00;
    databus_out = 0;
	 nxt_state = state;
    case (state) 
        IDLE: begin
            nxt_state = CFG1;
        end
        RX_READ: begin
            nxt_state = TX;
        end
        CFG1: begin
            iorw = 0;
            ioaddr = 2'b10;
            case (br_cfg)
                2'b00: databus_out = 8'hb0;
                2'b01: databus_out = 8'h58;
                2'b10: databus_out = 8'h2c;
                2'b11: databus_out = 8'h16;
            endcase
            nxt_state = CFG2;
        end
        CFG2: begin
            iorw = 0;
            ioaddr = 2'b11;
            case (br_cfg)
                2'b00: databus_out = 8'h28;
                2'b01: databus_out = 8'h14;
                2'b10: databus_out = 8'h0a;
                2'b11: databus_out = 8'h05;
            endcase
            if (rda) begin
                nxt_state = RX_READ;
            end
        end
        TX: begin
            iorw = 0;
            databus_out = databus_in;
            nxt_state = IDLE;
        end
    endcase
end




endmodule
