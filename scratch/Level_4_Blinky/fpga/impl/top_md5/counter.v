module counter(CLEAR, CK12, LED);
    input CLEAR;        // Set counter=0
    input CK12;     // Clock source
    output [7:0] LED;   // Output display
    
    reg [27:0] count;   // a 28 bit counter
    reg metaclear;      // bring CLEAR into     
                        // our clock domain

    always @(posedge CK12)
    begin
        metaclear <= CLEAR;
        if (metaclear)
            count <= 0;
        else count <= count + 1;
    end

    assign LED = count[27:20]; // Set display

endmodule
