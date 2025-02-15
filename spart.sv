//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
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
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );
    
// TX signals
logic trmt;
logic [7:0] tx_data;
logic [7:0] rx_data;
logic tx_done;
logic rx_rdy;
logic set_rda;

logic [7:0] databus_out;
logic [15:0] division_buffer;
assign databus = (iorw) ? databus_out : 8'hzz;
assign rda = rx_rdy | set_rda;
assign set_rda = ((~ioaddr[1]) & iorw) ? (~ioaddr[0]) ? rx_rdy : 1 : 0;

assign tx_data = (ioaddr == 2'b00 && !iorw) ?  databus : 0;

UART_tx U_TX(
    .clk(clk), 
    .rst_n(rst),
    .trmt((~iorw) & (tbr) & (~(|ioaddr))),
    .tx_data(tx_data),
    .TX(txd),
    .tx_done(tx_done),
    .baud_val(division_buffer),
    .tx_rdy(tbr)
);

UART_rx U_RX(.clk(clk), 
             .rst_n(rst),
             .RX(rxd),
             .clr_rdy(0), 
             .rx_data(rx_data), 
             .rdy(rx_rdy),
             .baud_val(division_buffer)
);

always_comb begin
    if (!rst) databus_out = 0;
    else begin
        case (ioaddr)
            2'b00: begin
                databus_out = rx_data;
            end
            2'b01: begin
                databus_out = {6'b000000, rda, tbr};
            end
            default: databus_out = 0;          
        endcase         
    end
end

always_ff @(posedge clk, negedge rst) begin
    if (!rst) division_buffer <= 0;
    else if (ioaddr == 2'b10 && !iorw) division_buffer[7:0] <= databus;
    else if (ioaddr == 2'b11 && !iorw) division_buffer[15:8] <= databus;
end





endmodule
