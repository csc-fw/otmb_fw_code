// PROM: Model of the XCF128XFTG Xilinx EPROM

module prom_sim(
        clk,
        rst,
        we_b,
        cs_b,
        oe_b,
        le_b,
        addr,
        data
    );
    input        clk;
    input        rst;
    input        we_b;
    input        cs_b;
    input        oe_b;
    input        le_b;
    input [22:0] addr;
    inout [15:0] data;
    
    localparam NBK = 16;  // Number of banks
    localparam NBL = 128; // Number of blocks
    localparam NWD = 16;  // Number of words
    
    wire [15:0] mem_out = 16'b0000000000000000;
    
    reg [NBK-1:0] read_status_reg;
    reg [NBK-1:0] read_elec_sig;
    reg [NBK-1:0] read_array;
    reg [NBK-1:0] program;
    reg [NBK-1:0] buffer_program;
    
    localparam lock_unlock_code     = 16'h0060;
    localparam unlock_confirm_code  = 16'h00D0;
    localparam lock_confirm_code    = 16'h0001;
    
    localparam read_status_reg_code = 16'h0070;
    localparam read_elec_sig_code   = 16'h0090;
    localparam read_array_code      = 16'h00ff;
    localparam program_code         = 16'h0040;
    localparam buffer_program_code  = 16'h00e8;
    
    localparam  manufacturer_code   = 16'h0049; // ES - Bank Address + 0
    wire [15:0] device_code         = 16'h506B; // ES - Bank Address + 1
    
    reg [15:0] prom_data[NBL-1:0][NWD-1:0];
    
    reg [15:0] command_reg[NBK-1:0];       // command register
    reg [15:0] configuration_reg[NBK-1:0]; // ES - Bank Address + 5
    reg [15:0] bank_data[NBK-1:0];
    reg [15:0] bank_out[NBK-1:0];
    reg [15:0] status_reg[NBK-1:0];        // Status Register
    
    reg [NBK-1:0] program_done;
    
    reg [15:0] block_status[NBL-1:0]; // ES - Block Address + 2
    
    wire [15:0] data_in;
    reg  [15:0] data_out;
    
    wire [15:0] latched_data = 16'b0000000000000000;
    reg  [22:0] latched_addr;
    
    wire [22:0] addr_cnt_out = 23'b00000000000000000000000;
    
    localparam AG_IDLE = 4'b0000;
    localparam AG_RUN  = 4'b0001;
    
    reg [NBK-1:0] next_state;
    reg [NBK-1:0] current_state;
    
    reg [NBK-1:0] ag_ld;
    reg [NBK-1:0] ag_en;
    reg [NBK-1:0] ag_lw;
    
    integer ag_ad_cnt_out[NBK-1:0];
    integer ag_nw_cnt_out[NBK-1:0];
    
    integer bk_index = 0; // bank address  (0 -> 15)
    integer bl_index = 0; // block address (0 -> 127)
    integer wd_index = 0; // word address  (0 -> 15)
    integer int_addr = 0;
    integer int_data = 0;
    
    always @ ( latched_addr )
    begin
    	bk_index = latched_addr[22:19];
    	bl_index = latched_addr[22:16];
    	wd_index = latched_addr[3:0];
    end
    
    always @ ( addr )
    begin
    	int_addr = addr[15:0];
    end
    
    always @ ( data )
    begin
    	int_data = data[15:0];
    end
    
//    assign bk_index = latched_addr[22:19];
//    assign bl_index = latched_addr[22:16];
//    assign wd_index = latched_addr[3:0];
//    assign int_addr = addr[15:0];
//    assign int_data = data[15:0];
    
    // -------------------------------------------------------------------------
    always @ (  rst or  command_reg or  bl_index or  bk_index)
    begin : block_status_proc
        integer i;
        for ( i = 0 ; ( i <= NBL-1 ) ; i = ( i + 1 ) )
        begin 
            if ( rst == 1'b1 ) 
            begin
                block_status[i][15:1] <= 15'b000000000000000;
                block_status[i][0]    <= 1'b1;
            end
        end
        //
        for ( i = 0 ; ( i <= NBL-1 ) ; i = ( i + 1 ) )
        begin 
            if ( ( command_reg[bk_index] == unlock_confirm_code ) & ( i == bl_index ) ) 
            begin
                block_status[i][15:1] <= 15'b000000000000000;
                block_status[i][0]    <= 1'b0;
            end
            else
            begin 
                if ( ( command_reg[bk_index] == lock_confirm_code ) & ( i == bl_index ) ) 
                begin
                    block_status[i][15:1] <= 15'b000000000000000;
                    block_status[i][0]    <= 1'b1;
                end
            end
        end
    end
    
    // -------------------------------------------------------------------------
    always @ (  rst)
    begin : configuration_reg_proc
        integer i;
        for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
        begin 
            if ( rst == 1'b1 ) 
            begin
                configuration_reg[i][15:4] <= 12'b110011001100;
                configuration_reg[i][3:0]   <= i;
            end
        end
    end
    
    // -------------------------------------------------------------------------
    always @ (  rst)
    begin : status_reg_proc
        integer i;
        for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
        begin 
            if ( rst == 1'b1 ) 
            begin
                status_reg[i][15:12] <= 4'b1111;
                status_reg[i][11:8]  <= i;
                status_reg[i][7:0]   <= 8'b10000000;
            end
        end
    end
    
    // -------------------------------------------------------------------------
    // Latch Command/Data
    always @ ( posedge we_b or  cs_b or  data_in or  bk_index or  command_reg or  rst)
    begin : ld_proc
        integer i;
        for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
        begin 
            if ( rst == 1'b1 ) 
            begin
                command_reg[i]  <= read_array_code;
            end
            else
            begin 
                if ( we_b & ( i == bk_index ) & ( ( command_reg[i] == read_array_code ) | ( data_in == read_array_code ) ) ) 
                begin
                    command_reg[i]  <= data_in;
                end
                else
                begin 
                    if ( we_b & ( i == bk_index ) & ( command_reg[i] == lock_unlock_code ) & ( data_in == unlock_confirm_code ) )
                    begin
                        command_reg[i]  <= data_in;
                    end
                    else
                    begin 
                        if ( we_b & ( i == bk_index ) & ( command_reg[i] == unlock_confirm_code ) & ( data_in == read_elec_sig_code ) )
                        begin
                            command_reg[i]  <= data_in;
                        end
                    end
                end
            end
        end
    end
    
    // -------------------------------------------------------------------------
    // Latch Address
    always @ ( posedge le_b or  cs_b or  addr)
    begin : la_proc
        if ( le_b ) 
        begin
            latched_addr <= addr;
        end
    end
    
    // -------------------------------------------------------------------------
    always @ (  clk or  command_reg)
    begin : cmd_dec_proc
        integer i;
        for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
        begin 
            if ( command_reg[i] == read_status_reg_code ) // 0x70
            begin
                read_status_reg[i]  <= 1'b1;
            end
            else
            begin 
                read_status_reg[i]  <= 1'b0;
            end
            
            if ( command_reg[i] == read_elec_sig_code ) // 0x90
            begin
                read_elec_sig[i]  <= 1'b1;
            end
            else
            begin 
                read_elec_sig[i]  <= 1'b0;
            end
            
            if ( command_reg[i] == read_array_code ) // 0xff
            begin
                read_array[i]  <= 1'b1;
            end
            else
            begin 
                read_array[i]  <= 1'b0;
            end
            
            if ( command_reg[i] == program_code ) // 0x40
            begin
                program[i]  <= 1'b1;
            end
            else
            begin 
                program[i]  <= 1'b0;
            end
            
            if ( command_reg[i] == buffer_program_code ) // 0xe8
            begin
                buffer_program[i]  <= 1'b1;
            end
            else
            begin 
                buffer_program[i]  <= 1'b0;
            end
        end
    end
    
    // -------------------------------------------------------------------------
    always @ (  read_status_reg or  status_reg or  read_elec_sig or  read_array or  bank_data or  bank_out or  bk_index or  bl_index or  wd_index or  block_status)
    begin : out_mux_proc
        integer i;
        for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
        begin 
            if ( ( i == bk_index ) & ( read_status_reg[i] == 1'b1 ) ) 
            begin
                bank_out[i]  <= status_reg[i];
            end
            else
            begin 
                if ( ( i == bk_index ) & ( read_elec_sig[i] == 1'b1 ) ) 
                begin
                    if ( wd_index == 0 ) 
                    begin
                        bank_out[i]  <= manufacturer_code;
                    end
                    else
                    begin 
                        if ( wd_index == 1 ) 
                        begin
                            bank_out[i]  <= device_code;
                        end
                        else
                        begin 
                            if ( wd_index == 2 ) 
                            begin
                                bank_out[i]  <= block_status[bl_index];
                            end
                            else
                            begin 
                                if ( wd_index == 5 ) 
                                begin
                                    bank_out[i]  <= configuration_reg[i];
                                end
                            end
                        end
                    end
                end
                else
                begin 
                    if ( ( i == bk_index ) & ( read_array[i] == 1'b1 ) ) 
                    begin
                        bank_out[i]  <= bank_data[i];
                    end
                    else
                    begin 
                        bank_out[i]  <= status_reg[i];
                    end
                end
            end
        end
        data_out <= bank_out[bk_index];
    end
    
    // -------------------------------------------------------------------------
    // Address Generator for Buffer_Program and Read_N
    always @ ( posedge we_b or next_state or  rst)
    begin : ag_fsm_state_regs
        integer i;
        for ( i = 0 ; i <= NBK-1 ; i = i + 1 )
        begin 
            if ( rst == 1'b1 ) 
            begin
                current_state[i] <= AG_IDLE;
            end
            else
            begin 
                if ( we_b ) 
                begin
                    current_state[i]  <= next_state[i];
                end
            end
        end
    end
    
    // -------------------------------------------------------------------------
    // Address Generator
    always @ (  current_state or  ag_nw_cnt_out or  command_reg)
    begin : ag_fsm_comb_logic
        integer i;
        for ( i = 0 ; i <= NBK-1 ; i = i + 1 )
        begin 
            case ( current_state[i] ) 
            
            AG_IDLE:
            begin
                ag_en[i]  <= 1'b0;
                ag_lw[i]  <= 1'b0;
                if ( command_reg[i] == buffer_program_code ) 
                begin
                    ag_ld[i]      <= 1'b1;
                    next_state[i] <= AG_RUN;
                end
                else
                begin 
                    ag_ld[i]      <= 1'b0;
                    next_state[i] <= AG_IDLE;
                end
            end
            
            AG_RUN:
            begin
                ag_ld[i] <= 1'b0;
                ag_en[i] <= 1'b1;
                if ( ag_nw_cnt_out[i] == 0 ) 
                begin
                    ag_lw[i]      <= 1'b1;
                    next_state[i] <= AG_IDLE;
                end
                else
                begin 
                    ag_lw[i]      <= 1'b0;
                    next_state[i] <= AG_RUN;
                end
            end
            
            default :
            begin
                ag_ld[i]      <= 1'b0;
                ag_en[i]      <= 1'b0;
                ag_lw[i]      <= 1'b0;
                next_state[i] <= AG_IDLE;
            end
            endcase
        end
    end
    
    // -------------------------------------------------------------------------
    // Address Generator: address counter
    always @ ( rst or posedge we_b or  int_addr or  ag_ld or  ag_en)
    begin : ag_ad_cnt_proc
        integer ag_ad_cnt_data[NBK-1:0];
        integer i;
        for ( i = 0 ; i <= NBK-1 ; i = i + 1 )
        begin 
            if ( rst == 1'b1 ) 
            begin
                ag_ad_cnt_data[i]  = 0;
            end
            else
            begin 
                if ( we_b ) 
                begin
                    if ( ag_ld[i] == 1'b1 ) 
                    begin
                        ag_ad_cnt_data[i]  = int_addr;
                    end
                    else
                    begin 
                        if ( ag_en[i] == 1'b1 ) 
                        begin
                            ag_ad_cnt_data[i] = ag_ad_cnt_data[i] + 1;
                        end
                    end
                end
            end
            ag_ad_cnt_out[i]  <= ag_ad_cnt_data[i];
        end
    end
    
    // -------------------------------------------------------------------------
    // Address Generator: number of words counter
    always @ (  rst or posedge we_b or  int_data or  ag_ld or  ag_en)
    begin : ag_nw_cnt_proc
        integer ag_nw_cnt_data[NBK-1:0];
        integer i;
        for ( i = 0 ; i <= NBK-1 ; i = i + 1 )
        begin 
            if ( rst == 1'b1 ) 
            begin
                ag_nw_cnt_data[i]  = 0;
            end
            else
            begin 
                if ( we_b ) 
                begin
                    if ( ag_ld[i] == 1'b1 ) 
                    begin
                        ag_nw_cnt_data[i]  = int_data;
                    end
                    else
                    begin 
                        if ( ag_en[i] == 1'b1 ) 
                        begin
                            ag_nw_cnt_data[i] = ag_nw_cnt_data[i] - 1; // Why it is "-1" here??? It was in original code from UCSB
                        end
                    end
                end
            end
            ag_nw_cnt_out[i]  <= ag_nw_cnt_data[i];
        end
    end
    
    // -------------------------------------------------------------------------
    // Memory
    reg [7:0] i_reg8;
    reg [7:0] j_reg8;
    always @ ( posedge clk or  cs_b or posedge we_b or  oe_b or  bk_index or  bl_index or  command_reg or  program_done or  data or  rst or  ag_en or  ag_lw)
    begin : mem_proc
        integer i;
        integer j;
        // Initial Memory Reset
        if ( rst == 1'b1 ) 
        begin
            for ( i = 0 ; i <= NBL-1 ; i = i + 1 )
            begin 
                for ( j = 0 ; j <= NWD-1 ; j = j + 1 )
                begin 
                    i_reg8 = i;
                    j_reg8 = j;
                    prom_data[i][j]  <= { i_reg8, j_reg8 };
                end
            end
            for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
            begin 
                program_done[i]  <= 1'b0;
            end
        end
        // Bank Write
        if ( we_b ) 
        begin
            if ( ( command_reg[bk_index] == program_code ) & ( block_status[bl_index][0] == 1'b0 ) & ( program_done[bk_index] == 1'b0 ) ) 
            begin
                prom_data[bl_index][wd_index] <= data;
                program_done[bk_index]        <= 1'b1;
            end
            else
            begin 
                if ( ( command_reg[bk_index] == buffer_program_code ) & ( ag_en[bk_index] == 1'b1 ) & ( block_status[bl_index][0] == 1'b0 ) & ( program_done[bk_index] == 1'b0 ) ) 
                begin
                    prom_data[bl_index][wd_index] <= data;
                    program_done[bk_index]        <= ag_lw[bk_index];
                end
            end
        end
        
        for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
        begin 
            if ( we_b & ( i == bk_index ) & ( command_reg[i] == program_code ) & ( data_in == read_array_code ) )
            begin
                program_done[i]  <= 1'b0;
            end
            else
            begin 
                if ( we_b & ( i == bk_index ) & ( command_reg[i] == buffer_program_code ) & ( data_in == read_array_code ) )
                begin
                    program_done[i]  <= 1'b0;
                end
            end
        end
        // Bank Read
        for ( i = 0 ; ( i <= NBK-1 ) ; i = ( i + 1 ) )
        begin 
            if ( ( command_reg[i] == read_array_code ) & ( cs_b == 1'b0 ) & ( oe_b == 1'b0 ) & clk ) 
            begin
                bank_data[i]  <= prom_data[bl_index][wd_index];
            end
        end
    end
    
    // -------------------------------------------------------------------------
    // Bidirectional Port
    IOBUF #(.DRIVE(12),.IOSTANDARD("DEFAULT"),.SLEW("SLOW")) IOBUF_DATA[15:0] (.O(data_in),.IO(data),.I(data_out),.T(oe_b));
    // Code below was created automatically when VHDL converted to Verilog 
//    genvar I;
//    generate
//        for ( I = 0 ; ( I <= 15 ) ; I = ( I + 1 ) )
//        begin : GEN_16
//            iobuf data_buf (
//                    .i(data_out[I]),
//                    .io(data[I]),
//                    .o(data_in[I]),
//                    .t(oe_b)
//                );
//        end
//    endgenerate

endmodule 
