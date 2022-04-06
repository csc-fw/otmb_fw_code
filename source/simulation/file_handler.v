`timescale 1ns / 1ps

module file_handler(
  clk,
  start,
  vme_cmd_reg,
  vme_dat_reg_in,
  vme_dat_reg_out,
  vme_cmd_rd,
  vme_dat_wr
);

  input wire        clk;
  input wire        vme_cmd_rd;
  input wire        vme_dat_wr;
  input wire [31:0] vme_dat_reg_out;
  
  output reg        start;
  output reg [31:0] vme_cmd_reg;
  output reg [31:0] vme_dat_reg_in;
  
  reg [15:0]  command; 
  reg [0:480] comment; 
  reg         read_cmd;
  reg [31:0]  mask;
  reg [15:0]  write_data;
  reg [15:0]  read_data;
  reg [15:0]  vme_instruction;

  integer infile;
  integer outfile;
  integer r = 1;

  initial
  begin
    start          = 1'b0;
//    mask           = 32'h00a80000; // mask in original UCSB code
    mask           = 32'h00000000;
    vme_cmd_reg    = mask;
    vme_dat_reg_in = 32'h00000000;
  end

  initial
  begin
    infile  = $fopen("../source/simulation/commands/test_vme.txt","r");      // Test of VME
    outfile = $fopen("../source/simulation/commands/test_vme_out.txt","w");  // Test of VME
    
    while (!$feof(infile))
    begin
      @(posedge clk) #10
      
      if (vme_cmd_rd) 
      begin
        $display($time, "  File_handler: Start Reading Line from File");
        r = $fscanf(infile,"%s",command);
//        $display($time, "  File_handler: r = %d", r);
        if (r == 1)
        begin
          if (command == "R" || command == "r" || command == "W" || command == "w") 
          begin
            start = 1'b1;
            r = $fscanf(infile,"%h %h",vme_cmd_reg[23:1],vme_dat_reg_in);
            $display($time, "  File_handler: command = %s, vme_address = 0x%h, vme_data = 0x%h", command, vme_cmd_reg[23:1], vme_dat_reg_in);
          end
          else 
          begin
            start = 1'b0;
            $display($time, "  File_handler: unknown command = %s", command);
          end
              
          r = $fgets(comment,infile);
          $display($time, "  File_handler: comment = %s", comment);
          if (start == 1'b0)
            $fwrite(outfile, "%s  %s", command,  comment);
        
          vme_instruction = vme_cmd_reg[15:0];
          vme_cmd_reg     = vme_cmd_reg | mask;
        
          if (command == "R" || command == "r") 
            vme_cmd_reg[25] = 1'b1;
          else
            vme_cmd_reg[24] = 1'b1;
            
          read_cmd   = vme_cmd_reg[25];
          write_data = vme_dat_reg_in[15:0];
        
        end
        else
        begin
          $display($time, "  File_handler: End of File");
        end
      end
      else
      begin
        start          = 1'b0;
        vme_cmd_reg    = mask;
        vme_dat_reg_in = 32'h00000000;
      end   
      
      read_data = vme_dat_reg_out[15:0];
      
      if (vme_dat_wr) 
      begin
        if (read_cmd)
          $fwrite(outfile, "%s  %h %h %s", command, vme_instruction, read_data, comment);
        else
          $fwrite(outfile, "%s  %h %h %s", command, vme_instruction, write_data, comment);
      end
    end    

    $fclose(outfile);
    $fclose(infile);
    $display($time, " Finishing the Sequence of Commands");
    $stop;
  end

endmodule
