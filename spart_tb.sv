module spart_tb();



logic clk, rst, iocs, iorw, rda, tbr, rxd, txd;
logic [1:0] ioaddr;
logic [7:0] data;

module spart(
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

initial begin
end

always
    #5 clk = ~clk;

endmodule