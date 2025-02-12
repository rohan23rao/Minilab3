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
logic tx_done;

logic [7:0] databus_out;
logic [15:0] division_buffer;
assign databus = iorw ? databus_out : 1'bz;

UART_tx U_TX tx(
    .clk(clk), 
    .rst_n(rst),
    .trmt(tbr),
    .tx_data(tx_data),
    .TX(txd),
    .tx_done(tx_done),
    .baud_val(division_buffer)
);

UART_rx U_RX(.clk(clk), 
             .rst_n(rst),
             .RX(rxd),
             .clr_rdy(1'b0), 
             .rx_data(rx_data), 
             .rdy(rda),
             .baud_val(division_buffer)
);

always_ff @(posedge clk, negedge rst) begin
    if (!rst) databus_out <= 0;
    else begin
        case (ioaddr)
            2'b00: begin
                databus_out <= rx_data;
                if (!iorw) tx_data <= databus;
            end
            2'b01: databus_out <= {6'b000000, rda, tbr};
            2'b10: division_buffer[7:0] <= databus;
            2'b11: division_buffer[15:8] <= databus;            
        endcase         
        
    end

end





endmodule
