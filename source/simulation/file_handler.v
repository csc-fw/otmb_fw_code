`timescale 1ns / 1ps
module file_handler(clk, start, vme_cmd_reg, vme_dat_reg_in, vme_dat_reg_out, vme_cmd_rd, vme_dat_wr);

   input wire clk;
   input wire vme_cmd_rd;
   input wire vme_dat_wr;
   output reg start; 
   output reg [31:0] vme_cmd_reg;
   output reg [31:0] vme_dat_reg_in;
   input wire [31:0] vme_dat_reg_out;
   reg [15:0] 	     command; 
   reg [255:0] 	     parameters; 
   reg [0:480] 	     comment; 
   reg 		     read_cmd;
   reg [31:0] 	     mask;
   reg [15:0] 	     write_data, read_data, vme_instruction;

   integer 	     infile, outfile, r;

   initial
     begin
	start = 1'b0;
	mask = 32'h00a80000;
	vme_cmd_reg = mask;
	vme_dat_reg_in = 32'h00000000;
     end

   initial
     begin
	infile= $fopen("source\\simulation\\commands\\test_vme.txt","r");       // Test of VME
	outfile=$fopen("source\\simulation\\commands\\test_vme_out.txt","w");  // Test of VME
	while (!$feof(infile))
	  begin
             @(posedge clk) #10
               if (vme_cmd_rd) 
		 begin
		    r = $fscanf(infile,"%s",command);
		    if (command == "R" || command == "r" || command == "W" || command == "w") 
                      begin
			 start = 1'b1;
			 r = $fscanf(infile,"%h %h",vme_cmd_reg,vme_dat_reg_in);
		      end
	            else 
	              start = 1'b0;
		    
		    r = $fgets(comment,infile);
		    if (start == 1'b0)
                      $fwrite(outfile, "%s  %s", command,  comment);
		    $display("%s",comment);
		    vme_instruction = vme_cmd_reg[15:0];
		    vme_cmd_reg = vme_cmd_reg | mask;
		    if (command == "R" || command == "r") 
		      vme_cmd_reg[25] = 1'b1;
	            else
		      vme_cmd_reg[24] = 1'b1;
	            read_cmd = vme_cmd_reg[25];
	            write_data = vme_dat_reg_in[15:0];
	         end
               else
		 begin
		    start = 1'b0;
		    vme_cmd_reg = mask;
		    vme_dat_reg_in = 32'h00000000;
		 end   
             read_data = vme_dat_reg_out[15:0];
             if (vme_dat_wr) 
               begin
		  if (read_cmd)
                    $fwrite(outfile, "%s  %h       %h %s", command, vme_instruction, read_data, comment);
		  else
                    $fwrite(outfile, "%s  %h %h %s", command, vme_instruction, write_data, comment);
               end
	  end    

	$fclose(outfile);
	$fclose(infile);
	$stop;
     end
endmodule
