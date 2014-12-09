`timescale 1ns / 1ps

module vme_sim_master(
        clk,
        rstn,
        sw_reset,
        vme_cmd,
        vme_cmd_rd,
        vme_wr,
        vme_addr,
        vme_wr_data,
        vme_rd,
        vme_rd_data,
        ga,
        addr,
        am,
        as,
        data_in,
        data_out,
        ds0,
        ds1,
        oe_b,
        dtack,
        iack,
        lword,
        write_b,
        berr,
        sysfail
    );
    
    input         clk;
    input         rstn;
    input         sw_reset;
    input         vme_cmd;
    output        vme_cmd_rd;
    input  [23:1] vme_addr;
    input         vme_wr;
    input  [15:0] vme_wr_data;
    input         vme_rd;
    output [15:0] vme_rd_data;
    output [23:1] addr;
    output [6:0]  ga;
    output [5:0]  am;
    output        as;
    input  [15:0] data_in;
    output [15:0] data_out;
    output        ds0;
    output        ds1;
    output        oe_b;
    input         dtack;
    output        iack;
    output        lword;
    output        write_b;
    output        berr;
    output        sysfail;
    
    localparam t1  = 8'b00001000;
    localparam t2  = 8'b00001000;
    localparam t3  = 8'b00001000;
    localparam t4  = 8'b00001000;
    localparam t5  = 8'b00010000;
    
    reg [7:0]  cnt_out;
    reg [23:1] reg_addr;
    reg [15:0] reg_data;
    reg        reg_wr;
    reg        reg_rd;
    
    reg [23:1] addr;
    reg [15:0] data_out;
    reg [15:0] vme_rd_data;
    
    reg [3:0] current_state;
    reg [3:0] next_state;
    
    localparam IDLE          = 4'b0000;
    localparam CMD           = 4'b0001;
    localparam WR_BEGIN      = 4'b0010;
    localparam WR_AS_LOW     = 4'b0011;
    localparam WR_DS_LOW     = 4'b0100;
    localparam WR_DTACK_LOW  = 4'b0101;
    localparam WR_AS_HIGH    = 4'b0110;
    localparam WR_DS_HIGH    = 4'b0111;
    localparam WR_DTACK_HIGH = 4'b1000;
    localparam WR_END        = 4'b1001;
    
    reg write_b;
    reg iack;
    reg oe_b;
    reg as;
    reg ds0;
    reg ds1;
    reg d_load;
    reg cnt_en;
    reg cnt_res;
    reg ad_load;
    reg vme_cmd_rd;
    
    assign berr    = 1'b0;
    assign sysfail = 1'b1;
    assign lword   = 1'b1;
    assign ga      = 7'b1111111; // VME logic is negative. This matches to used geo address of the OTMB = 0000000
//    assign am      = 6'b111101;
    assign am = 6'b111001; // Address modifier: 0x39=6'b111001 - A24 non-priv mode, 0x3D=6'b111101 - A24 supervisor mode
    
    always @ ( posedge clk or  rstn or  sw_reset or  cnt_en or  cnt_res)
    begin : cnt
        reg [7:0]cnt_data;
        if ( ( rstn == 1'b0 ) | ( sw_reset == 1'b1 ) ) 
        begin
            cnt_data = { 1'b0 };
        end
        else
        begin 
            if ( clk ) 
            begin
                if ( cnt_res == 1'b1 ) 
                begin
                    cnt_data = { 1'b0 };
                end
                else
                begin 
                    if ( cnt_en == 1'b1 ) 
                    begin
                        cnt_data = ( cnt_data + 1 );
                    end
                end
            end
        end
        cnt_out <= cnt_data;
    end
    
    always @ (  d_load or  ad_load or  rstn or  sw_reset or posedge clk or  reg_addr or  reg_data or  data_in)
    begin : ad_regs
        if ( ( rstn == 1'b0 ) | ( sw_reset == 1'b1 ) ) 
        begin
            reg_addr <= { 1'b0 };
            reg_data <= { 1'b0 };
            reg_wr <= 1'b0;
            reg_rd <= 1'b0;
        end
        else
        begin 
            if ( clk & ( ad_load == 1'b1 ) ) 
            begin
                reg_addr <= vme_addr;
                reg_data <= vme_wr_data;
                reg_wr <= vme_wr;
                reg_rd <= vme_rd;
            end
        end
        addr <= reg_addr;
        data_out <= reg_data;
        if ( ( rstn == 1'b0 ) | ( sw_reset == 1'b1 ) ) 
        begin
            vme_rd_data <= { 1'b0 };
        end
        else
        begin 
            if ( clk & ( d_load == 1'b1 ) ) 
            begin
                vme_rd_data <= data_in;
            end
        end
    end
    
    always @ (  next_state or  rstn or  sw_reset or posedge clk)
    begin : fsm_state_regs
        if ( ( rstn == 1'b0 ) | ( sw_reset == 1'b1 ) ) 
        begin
            current_state <= IDLE;
        end
        else
        begin 
            if ( clk ) 
            begin
                current_state <= next_state;
            end
        end
    end
    
    always @ (  vme_cmd or  current_state or  cnt_out or  vme_wr or  vme_addr or  vme_wr_data or  dtack)
    begin : fsm_comb_logic
        case ( current_state ) 
        IDLE: // 4'b0000
        begin
            write_b <= 1'b0;
            iack    <= 1'b0;
            oe_b    <= 1'b0;
            as      <= 1'b1;
            ds0     <= 1'b1;
            ds1     <= 1'b1;
            d_load  <= 1'b0;
            if ( vme_cmd == 1'b1 ) 
            begin
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b1;
                ad_load    <= 1'b1;
                vme_cmd_rd <= 1'b0;
                next_state <= CMD;
            end
            else
            begin 
                cnt_en     <= 1'b0;
                cnt_res    <= 1'b0;
                ad_load    <= 1'b0;
                vme_cmd_rd <= 1'b0;
                next_state <= IDLE;
            end
        end
        CMD: // 4'b0001
        begin
            write_b    <= 1'b0;
            oe_b       <= 1'b0;
            as         <= 1'b1;
            ds0        <= 1'b1;
            ds1        <= 1'b1;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            if ( ( reg_wr == 1'b1 ) | ( reg_rd == 1'b1 ) ) 
            begin
                iack       <= 1'b1;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b1;
                next_state <= WR_BEGIN;
            end
            else
            begin 
                iack       <= 1'b0;
                cnt_en     <= 1'b0;
                cnt_res    <= 1'b0;
                next_state <= IDLE;
            end
        end
        WR_BEGIN: // 4'b0010
        begin
            if ( reg_rd == 1'b1 ) 
            begin
                oe_b    <= 1'b1;
                write_b <= 1'b1;
            end
            else
            begin 
                oe_b    <= 1'b0;
                write_b <= 1'b0;
            end
            iack       <= 1'b1;
            ds0        <= 1'b1;
            ds1        <= 1'b1;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            if ( cnt_out == t1 ) 
            begin
                as         <= 1'b0;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b1;
                next_state <= WR_AS_LOW; // 4'b0011
            end
            else
            begin 
                as         <= 1'b1;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b0;
                next_state <= WR_BEGIN; // 4'b0010
            end
        end
        WR_AS_LOW: // 4'b0011
        begin
            if ( reg_rd == 1'b1 ) 
            begin
                oe_b    <= 1'b1;
                write_b <= 1'b1;
            end
            else
            begin 
                oe_b    <= 1'b0;
                write_b <= 1'b0;
            end
            iack       <= 1'b1;
            as         <= 1'b0;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            if ( cnt_out == t2 ) // 8'b00001000
            begin
                ds0     <= 1'b0;
                ds1     <= 1'b0;
                cnt_en  <= 1'b1;
                cnt_res <= 1'b1;
                next_state <= WR_DS_LOW; // 4'b0100
            end
            else
            begin 
                ds0        <= 1'b1;
                ds1        <= 1'b1;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b0;
                next_state <= WR_AS_LOW; // 4'b0011
            end
        end
        WR_DS_LOW: // 4'b0100
        begin
            if ( reg_rd == 1'b1 ) 
            begin
                oe_b    <= 1'b1;
                write_b <= 1'b1;
            end
            else
            begin 
                oe_b    <= 1'b0;
                write_b <= 1'b0;
            end
            iack       <= 1'b1;
            as         <= 1'b0;
            ds0        <= 1'b0;
            ds1        <= 1'b0;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            if ( dtack == 1'b0 ) 
            begin
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b1;
                next_state <= WR_DTACK_LOW; // 4'b0101
            end
            else
            begin 
                cnt_en <= 1'b1;
                cnt_res <= 1'b1;
                next_state <= WR_DS_LOW; // 4'b0100
            end
        end
        WR_DTACK_LOW: // 4'b0101
        begin
            if ( reg_rd == 1'b1 ) 
            begin
                oe_b    <= 1'b1;
                write_b <= 1'b1;
            end
            else
            begin 
                oe_b    <= 1'b0;
                write_b <= 1'b0;
            end
            iack       <= 1'b1;
            ds0        <= 1'b0;
            ds1        <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            if ( cnt_out == t3 ) 
            begin
                as      <= 1'b1;
                cnt_en  <= 1'b1;
                cnt_res <= 1'b1;
                if ( reg_rd == 1'b1 ) 
                begin
                    d_load <= 1'b1;
                end
                else
                begin 
                    d_load <= 1'b0;
                end
                next_state <= WR_AS_HIGH; // 4'b0110
            end
            else
            begin 
                as         <= 1'b0;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b0;
                next_state <= WR_DTACK_LOW; // 4'b0101
            end
        end
        WR_AS_HIGH: // 4'b0110
        begin
            if ( reg_rd == 1'b1 ) 
            begin
                oe_b    <= 1'b1;
                write_b <= 1'b1;
            end
            else
            begin 
                oe_b    <= 1'b0;
                write_b <= 1'b0;
            end
            iack       <= 1'b1;
            as         <= 1'b1;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            if ( cnt_out == t4 ) 
            begin
                ds0        <= 1'b1;
                ds1        <= 1'b1;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b1;
                next_state <= WR_DS_HIGH; // 4'b0111
            end
            else
            begin 
                ds0        <= 1'b0;
                ds1        <= 1'b0;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b0;
                next_state <= WR_AS_HIGH; // 4'b0110
            end
        end
        WR_DS_HIGH: // 4'b0111
        begin
            if ( reg_rd == 1'b1 ) 
            begin
                oe_b    <= 1'b1;
                write_b <= 1'b1;
            end
            else
            begin 
                oe_b    <= 1'b0;
                write_b <= 1'b0;
            end
            iack       <= 1'b1;
            as         <= 1'b1;
            ds0        <= 1'b1;
            ds1        <= 1'b1;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            if ( dtack == 1'b1 )
            begin
                cnt_en  <= 1'b1;
                cnt_res <= 1'b1;
                next_state <= WR_DTACK_HIGH; // 4'b1000
            end
            else
            begin 
                cnt_en  <= 1'b1;
                cnt_res <= 1'b1;
                next_state <= WR_DS_HIGH; // 4'b0111
            end
        end
        WR_DTACK_HIGH: // 4'b1000
        begin
            as      <= 1'b1;
            ds0     <= 1'b1;
            ds1     <= 1'b1;
            d_load  <= 1'b0;
            ad_load <= 1'b0;
            if ( cnt_out == t5 ) 
            begin
                iack       <= 1'b0;
                oe_b       <= 1'b0;
                write_b    <= 1'b0;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b1;
                vme_cmd_rd <= 1'b0;
                next_state <= WR_END; // 4'b1001
            end
            else
            begin 
                if ( reg_rd == 1'b1 ) 
                begin
                    oe_b    <= 1'b1;
                    write_b <= 1'b1;
                end
                else
                begin 
                    oe_b    <= 1'b0;
                    write_b <= 1'b0;
                end
                iack       <= 1'b1;
                cnt_en     <= 1'b1;
                cnt_res    <= 1'b0;
                vme_cmd_rd <= 1'b0;
                next_state <= WR_DTACK_HIGH; // 1'b1000
            end
        end
        WR_END: // 4'b1001
        begin
            iack       <= 1'b0;
            oe_b       <= 1'b0;
            write_b    <= 1'b0;
            as         <= 1'b1;
            ds0        <= 1'b1;
            ds1        <= 1'b1;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b1;
            cnt_en     <= 1'b0;
            cnt_res    <= 1'b0;
            if ( ( vme_cmd == 1'b1 ) & ( vme_wr == 1'b1 ) ) 
            begin
                next_state <= WR_BEGIN; // 4'b0010
            end
            else
            begin 
                next_state <= IDLE; // 4'b0000
            end
        end
        default :
        begin
            write_b    <= 1'b0;
            iack       <= 1'b0;
            oe_b       <= 1'b0;
            as         <= 1'b1;
            ds0        <= 1'b1;
            ds1        <= 1'b1;
            d_load     <= 1'b0;
            ad_load    <= 1'b0;
            vme_cmd_rd <= 1'b0;
            cnt_en     <= 1'b0;
            cnt_res    <= 1'b0;
            next_state <= IDLE; // 4'b0000
        end
        endcase
    end
endmodule 
