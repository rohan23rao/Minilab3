module spart_tb();



logic clk, rst, iocs, iorw, iorw2, rda, tbr, rxd, txd;
wire [7:0] data;
logic [1:0] br_cfg;
logic [15:0] baud;
logic [1:0] ioaddr;
assign baud = 16'h28b0; // baud rate 4800

// write from spart1
spart spart1(
    .clk(clk),
    .rst(rst),
    .iocs(iocs),
    .iorw(iorw),
    .rda(rda),
    .tbr(tbr),
    .ioaddr(ioaddr),
    .databus(data),
    .txd(txd),
    .rxd(rxd)
);

// driver
driver spart_driver(
    .clk(clk),
    .rst(rst),
    .br_cfg(br_cfg),
    .iocs(iocs),
    .iorw(iorw),
    .rda(rda),
    .tbr(tbr),
    .ioaddr(ioaddr),
    .databus(data)
);



initial begin
    clk = 0;
    rst = 1;
    rxd = 1;
    br_cfg = 0;
    @(negedge clk) rst = 0;
    @(negedge clk) rst = 1;
    repeat (baud) @(posedge clk) rxd = 0;
    repeat (8) begin
        rxd = ~rxd;
        repeat (baud) @(posedge clk);
    end
    repeat (baud) @(posedge clk) rxd = 1;
    repeat (20*baud) @(posedge clk);

    repeat (baud) @(posedge clk) rxd = 0;
    for (int i = 0; i < 8; i++) begin
        rxd = baud[i];
        repeat (baud) @(posedge clk);
    end
    repeat (baud) @(posedge clk) rxd = 1;

    repeat (baud) @(posedge clk) rxd = 1;
    repeat (20*baud) @(posedge clk);
    $stop();
end

always
    #5 clk = ~clk;

endmodule