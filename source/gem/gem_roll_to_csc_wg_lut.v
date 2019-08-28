
module gem_roll_to_csc_wg_lut(

   input          clock,
   input          wen, // write enable
   input  [2:0]   w_adr, // write address
   input  [6:0]   w_data, // write data

   input          renodd,
   input          reneven,
   input  [2:0]   r_adr1, 
   output [6:0]   r_data1, 
   input  [2:0]   r_adr2, 
   output [6:0]   r_data2, 


)

reg [6:0] r_data1_reg, r_data2_reg;

always @(posedge clock) begin
    if (wen)   begin
        gem_roll_to_csc_wg_odd_low    [w_adr] <= w_data;
        gem_roll_to_csc_wg_odd_high   [w_adr] <= w_data;
        gem_roll_to_csc_wg_even_low   [w_adr] <= w_data;
        gem_roll_to_csc_wg_even_high  [w_adr] <= w_data;
    end

    if (renodd)   begin
        r_data1_reg <= gem_roll_to_csc_wg_odd_low  [r_adr1];
        r_data2_reg <= gem_roll_to_csc_wg_odd_high [r_adr2];
    end
    if (reneven)   begin
        r_data1_reg <= gem_roll_to_csc_wg_even_low  [r_adr1];
        r_data2_reg <= gem_roll_to_csc_wg_even_high [r_adr2];
    end
end

assign r_data1 = r_data1_reg;
assign r_data2 = r_data2_reg;



reg [6:0] gem_roll_to_csc_wg_odd_low  [7:0]; 
reg [6:0] gem_roll_to_csc_wg_odd_high [7:0]; 
reg [6:0] gem_roll_to_csc_wg_even_low  [7:0]; 
reg [6:0] gem_roll_to_csc_wg_even_high [7:0]; 

  initial begin
	gem_roll_to_csc_wg_odd_low[ 0]     =   7'd37;	gem_roll_to_csc_wg_odd_high[ 0]     =   7'd47;
	gem_roll_to_csc_wg_odd_low[ 1]     =   7'd31;	gem_roll_to_csc_wg_odd_high[ 1]     =   7'd44;
	gem_roll_to_csc_wg_odd_low[ 2]     =   7'd27;	gem_roll_to_csc_wg_odd_high[ 2]     =   7'd38;
	gem_roll_to_csc_wg_odd_low[ 3]     =   7'd22;	gem_roll_to_csc_wg_odd_high[ 3]     =   7'd33;
	gem_roll_to_csc_wg_odd_low[ 4]     =   7'd19;	gem_roll_to_csc_wg_odd_high[ 4]     =   7'd28;
	gem_roll_to_csc_wg_odd_low[ 5]     =   7'd15;	gem_roll_to_csc_wg_odd_high[ 5]     =   7'd23;
	gem_roll_to_csc_wg_odd_low[ 6]     =   7'd11;	gem_roll_to_csc_wg_odd_high[ 6]     =   7'd19;
	gem_roll_to_csc_wg_odd_low[ 7]     =   7'd 8;	gem_roll_to_csc_wg_odd_high[ 7]     =   7'd15;
  end


  initial begin
	gem_roll_to_csc_wg_even_low[ 0]     =   7'd37;	gem_roll_to_csc_wg_even_high[ 0]     =   7'd47;
	gem_roll_to_csc_wg_even_low[ 1]     =   7'd31;	gem_roll_to_csc_wg_even_high[ 1]     =   7'd44;
	gem_roll_to_csc_wg_even_low[ 2]     =   7'd27;	gem_roll_to_csc_wg_even_high[ 2]     =   7'd38;
	gem_roll_to_csc_wg_even_low[ 3]     =   7'd22;	gem_roll_to_csc_wg_even_high[ 3]     =   7'd32;
	gem_roll_to_csc_wg_even_low[ 4]     =   7'd17;	gem_roll_to_csc_wg_even_high[ 4]     =   7'd27;
	gem_roll_to_csc_wg_even_low[ 5]     =   7'd13;	gem_roll_to_csc_wg_even_high[ 5]     =   7'd22;
	gem_roll_to_csc_wg_even_low[ 6]     =   7'd10;	gem_roll_to_csc_wg_even_high[ 6]     =   7'd17;
	gem_roll_to_csc_wg_even_low[ 7]     =   7'd 6;	gem_roll_to_csc_wg_even_high[ 7]     =   7'd14;
  end


endmodule
