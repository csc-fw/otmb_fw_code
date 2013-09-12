-- Package with the components from ISE_12.3/ISE/vhdl/hdlMacro
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;

package hdlMacro is 

-- 16-Bit Loadable Cascadable Accumulator with Carry-In, Carry-Out and Synchronous Reset
component ACC16
port (
    CO   : out STD_LOGIC;
    OFL  : out STD_LOGIC;
    Q    : out STD_LOGIC_VECTOR(15 downto 0);

    ADD  : in STD_LOGIC;
    B    : in STD_LOGIC_VECTOR(15 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CI   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(15 downto 0);
    L    : in STD_LOGIC;
    R    : in STD_LOGIC
    );
end component;

-- 4-Bit Loadable Cascadable Accumulator with Carry-In, Carry-Out and Synchronous Reset
component ACC4
  
port (
    CO   : out STD_LOGIC;
    OFL  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;

    ADD  : in STD_LOGIC;
    B0   : in STD_LOGIC;
    B1   : in STD_LOGIC;
    B2   : in STD_LOGIC;
    B3   : in STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CI   : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC;
    R    : in STD_LOGIC
    );
end component;

-- 8-Bit Loadable Cascadable Accumulator with Carry-In, Carry-Out and Synchronous Reset
component ACC8
port (
    CO   : out STD_LOGIC;
    OFL  : out STD_LOGIC;
    Q    : out STD_LOGIC_VECTOR(7 downto 0);

    ADD  : in STD_LOGIC;
    B    : in STD_LOGIC_VECTOR(7 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CI   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(7 downto 0);
    L    : in STD_LOGIC;
    R    : in STD_LOGIC
    );
end component;

-- 16-bit cascadable Full Adder with Carry-In, Carry-out
component ADD16
port(
       CO  : out std_logic;
       OFL : out std_logic;
       S   : out std_logic_vector(15 downto 0);
    
       A   : in std_logic_vector(15 downto 0);
       B   : in std_logic_vector(15 downto 0);
       CI  : in std_logic
    );
end component;

-- 4-bit cascadable Full Adder with Carry-In, Carry-out
component ADD4
  port(
    CO  : out std_logic;
    OFL : out std_logic;
    S0  : out std_logic;
    S1  : out std_logic;
    S2  : out std_logic;
    S3  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic;
    CI  : in std_logic
  );
end component;

-- 8-bit cascadable Full Adder with Carry-In, Carry-out
component ADD8
port(
    CO  : out std_logic;
    OFL : out std_logic;
    S   : out std_logic_vector(7 downto 0);
    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0);
    CI  : in std_logic
  );
end component;

-- 16-bit Cascadable Adder/Subtracter with Carry-In, Carry-out
component ADSU16
port(
    CO   : out std_logic;
    OFL  : out std_logic;
    S    : out std_logic_vector(15 downto 0);

    A    : in std_logic_vector(15 downto 0);
    ADD  : in std_logic;
    B    : in std_logic_vector(15 downto 0);
    CI   : in std_logic
  );
end component;

-- 4-bit Cascadable Adder/Subtracter with Carry-In, Carry-out
component ADSU4
  port(
    CO  : out std_logic;
    OFL : out std_logic;
    S0  : out std_logic;
    S1  : out std_logic;
    S2  : out std_logic;
    S3  : out std_logic;
    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    ADD : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic;
    CI  : in std_logic
  );
end component;

-- 8-bit Cascadable Adder/Subtracter with Carry-In, Carry-out
component ADSU8
port(
    CO   : out std_logic;
    OFL  : out std_logic;
    S    : out std_logic_vector(7 downto 0);

    A    : in std_logic_vector(7 downto 0);
    ADD  : in std_logic;
    B    : in std_logic_vector(7 downto 0);
    CI   : in std_logic
  );
end component;

-- 12-input AND gate with Non-inverted Inputs
component AND12
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10  : in std_logic;
    I11  : in std_logic
  );
end component;

-- 16-input AND gate with Non-inverted Inputs
component AND16
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10  : in std_logic;
    I11  : in std_logic;
    I12  : in std_logic;
    I13  : in std_logic;
    I14  : in std_logic;
    I15  : in std_logic
  );
end component;

-- 6-input AND gate with Non-inverted Inputs
component AND6
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end component;

-- 7-input AND gate with Non-inverted Inputs
component AND7
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end component;

-- 8-input AND gate with Non-inverted Inputs
component AND8
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end component;

-- 9-input AND gate with Non-inverted Inputs
component AND9
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end component;

-- 4-Bit Barrel Shifter
component BRLSHFT4
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    I0  : in STD_LOGIC;
    I1  : in STD_LOGIC;
    I2  : in STD_LOGIC;
    I3  : in STD_LOGIC;
    S0  : in STD_LOGIC;
    S1  : in STD_LOGIC
    );
end component;

-- 8-Bit Barrel Shifter
component BRLSHFT8
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    O4  : out STD_LOGIC;
    O5  : out STD_LOGIC;
    O6  : out STD_LOGIC;
    O7  : out STD_LOGIC;
    I0  : in STD_LOGIC;
    I1  : in STD_LOGIC;
    I2  : in STD_LOGIC;
    I3  : in STD_LOGIC;
    I4  : in STD_LOGIC;
    I5  : in STD_LOGIC;
    I6  : in STD_LOGIC;
    I7  : in STD_LOGIC;
    S0  : in STD_LOGIC;
    S1  : in STD_LOGIC;
    S2  : in STD_LOGIC
    );
end component;

-- Multiple 3- state Buffer with Active High Enable
component BUFE16
port(
    O  : out std_logic_vector(15 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(15 downto 0)
  );
end component;

-- Multiple 3- state Buffer with Active High Enable
component BUFE4
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    E   : in std_logic;
    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Multiple 3- state Buffer with Active High Enable
component BUFE8
port(
    O  : out std_logic_vector(7 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(7 downto 0)
  );
end component;

-- Multiple 3- state Buffer with Active Low Enable
component BUFT16
port(
    O  : out std_logic_vector(15 downto 0);

    I  : in std_logic_vector(15 downto 0);
    T  : in std_logic
  );
end component;

-- Multiple 3- state Buffer with Active Low Enable
component BUFT4
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    T   : in std_logic
  );
end component;

-- Multiple 3- state Buffer with Active Low Enable
component BUFT8
port(
    O  : out std_logic_vector(7 downto 0);

    I  : in std_logic_vector(7 downto 0);
    T  : in std_logic
  );
end component;

-- 16-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB16CE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end component;

-- 16-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
component CB16CLED
port (
       CEO : out STD_LOGIC;
       Q   : out STD_LOGIC_VECTOR(15 downto 0);
       TC  : out STD_LOGIC;
       C   : in STD_LOGIC;
       CE  : in STD_LOGIC;
       CLR : in STD_LOGIC;
       D   : in STD_LOGIC_VECTOR (15 downto 0);	
       L   : in STD_LOGIC;
       UP  : in STD_LOGIC );
end component;

-- 16-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB16CLE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR (15 downto 0);	
    L   : in STD_LOGIC );
end component;

-- 16-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
component CB16RE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 2-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB2CE
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end component;

-- 2-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
component CB2CLED
	
port (
       CEO : out STD_LOGIC;
       Q0  : out STD_LOGIC;
       Q1  : out STD_LOGIC;
       TC  : out STD_LOGIC;
       C   : in STD_LOGIC;
       CE  : in STD_LOGIC;
       CLR : in STD_LOGIC;
       D0  : in STD_LOGIC;	
       D1  : in STD_LOGIC;	
       L   : in STD_LOGIC;
       UP  : in STD_LOGIC );
end component;

-- 2-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB2CLE
  
port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;	
    D1  : in STD_LOGIC;	
    L   : in STD_LOGIC );
end component;

-- 2-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
component CB2RE
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 4-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB4CE
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end component;

-- 4-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
component CB4CLED
	
port (
        CEO : out STD_LOGIC;
        Q0  : out STD_LOGIC;
        Q1  : out STD_LOGIC;
        Q2  : out STD_LOGIC;
        Q3  : out STD_LOGIC;
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D0  : in STD_LOGIC;	
        D1  : in STD_LOGIC;	
        D2  : in STD_LOGIC;	
        D3  : in STD_LOGIC;	
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC );
end component;

-- 4-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB4CLE
  
port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;	
    D1  : in STD_LOGIC;	
    D2  : in STD_LOGIC;	
    D3  : in STD_LOGIC;	
    L   : in STD_LOGIC );
end component;

-- 4-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
component CB4RE
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB8CE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end component;

-- 8-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
component CB8CLED
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(7 downto 0);
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR (7 downto 0);	
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC );
end component;

-- 8-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CB8CLE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR (7 downto 0);	
    L   : in STD_LOGIC );
end component;

-- 8-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
component CB8RE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 16-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CC16CE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in  STD_LOGIC;
    CE  : in  STD_LOGIC;
    CLR : in  STD_LOGIC
    );
end component;

-- 16-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CC16CLED
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(15 downto 0);
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR(15 downto 0);
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC);
end component;

-- 16-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CC16CLE
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(15 downto 0);
        TC  : out STD_LOGIC;
        CLR : in STD_LOGIC;
        CE  : in STD_LOGIC;
        C   : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR (15 downto 0);
        L   : in STD_LOGIC );
end component;

-- 16-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
component CC16RE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CC8CE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end component;

-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CC8CLED
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(7 downto 0);
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR (7 downto 0);	
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC );
end component;

-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
component CC8CLE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR (7 downto 0);	
    L   : in STD_LOGIC );
end component;

-- 8-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
component CC8RE
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 4-Bit Cascadable BCD Counter with Clock Enable and Asynchronous Clear
component CD4CE
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end component;

-- 4-Bit Loadable Cascadable BCD Counter with Clock Enable and Asynchronous Clear
component CD4CLE
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC
    );
end component;

-- 4-Bit Cascadable BCD Counter with Clock Enable and Synchronous Reset
component CD4RE
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 4-Bit Loadable Cascadable BCD Counter with Clock Enable and Synchronous Reset
component CD4RLE
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    L   : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 4-Bit Johnson Counter with Clock Enable and Asynchronous Clear
component CJ4CE
  
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end component;

-- 4-Bit Johnson Binary Counter with Clock Enable and Synchronous Reset
component CJ4RE
  port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 5-Bit Johnson Counter with Clock Enable and Asynchronous Clear
component CJ5CE
  
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    Q4   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end component;

-- 5-Bit Johnson Binary Counter with Clock Enable and Synchronous Reset
component CJ5RE
  port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    Q4  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 8-Bit Johnson Counter with Clock Enable and Asynchronous Clear
component CJ8CE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end component;

-- 8-Bit Johnson Counter with Clock Enable and Synchronous Reset
component CJ8RE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 16-bit Identity Comparator
component COMP16
port(
    EQ  : out std_logic;

    A   : in std_logic_vector(15 downto 0);
    B   : in std_logic_vector(15 downto 0)
  );
end component;

-- 2-bit Identity Comparator
component COMP2
  
port(
    EQ  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic
  );
end component;

-- 4-bit Identity Comparator
component COMP4
  
port(
    EQ  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic
  );
end component;

-- 8-bit Identity Comparator
component COMP8
port(
    EQ  : out std_logic;

    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0)
  );
end component;

-- 16-bit Magnitude Comparator
component COMPM16
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(15 downto 0);
    B   : in std_logic_vector(15 downto 0)
  );
end component;

-- 2-bit Magnitude Comparator
component COMPM2
  
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic
  );
end component;

-- 4-bit Magnitude Comparator
component COMPM4
  
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic
  );
end component;

-- 8-bit Magnitude Comparator
component COMPM8
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0)
  );
end component;

-- 16-bit Magnitude Comparator
component COMPMC16
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(15 downto 0);
    B   : in std_logic_vector(15 downto 0)
  );
end component;

-- 8-bit Magnitude Comparator
component COMPMC8
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0)
  );
end component;

-- 16-Bit Negative Edge Binary Counter with Clock Enable and Asynchronous Clear
component CR16CE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end component;

-- 8-Bit Negative Edge Binary Counter with Clock Enable and Asynchronous Clear
component CR8CE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end component;

-- 2 -to -4 Line Decoder/Demultiplexer with Enable
component D2_4E
  
port(
    D0  : out std_logic;
    D1  : out std_logic;
    D2  : out std_logic;
    D3  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    E   : in std_logic
  );
end component;

-- 3 -to -8 Line Decoder/Demultiplexer with Enable
component D3_8E
  
port(
    D0  : out std_logic;
    D1  : out std_logic;
    D2  : out std_logic;
    D3  : out std_logic;
    D4  : out std_logic;
    D5  : out std_logic;
    D6  : out std_logic;
    D7  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    E   : in std_logic
  );
end component;

-- 4 -to -16 Line Decoder/Demultiplexer with Enable
component D4_16E
  
port(
    D0  : out std_logic;
    D1  : out std_logic;
    D2  : out std_logic;
    D3  : out std_logic;
    D4  : out std_logic;
    D5  : out std_logic;
    D6  : out std_logic;
    D7  : out std_logic;
    D8  : out std_logic;
    D9  : out std_logic;
    D10  : out std_logic;
    D11  : out std_logic;
    D12  : out std_logic;
    D13  : out std_logic;
    D14  : out std_logic;
    D15  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    E   : in std_logic
  );
end component;

-- 16 Bit Active Low Decoder
component DEC_CC16
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic;
    A8   : in std_logic;
    A9   : in std_logic;
    A10  : in std_logic;
    A11  : in std_logic;
    A12  : in std_logic;
    A13  : in std_logic;
    A14  : in std_logic;
    A15  : in std_logic;
    CIN : in std_logic
  );
end component;

-- 4 Bit Active Low Decoder
component DEC_CC4
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    CIN : in std_logic
  );
end component;

-- 8 Bit Active Low Decoder
component DEC_CC8
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic;
    CIN : in std_logic
  );
end component;

-- 16 Bit Active Low Decoder
component DECODE16
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic;
    A8   : in std_logic;
    A9   : in std_logic;
    A10  : in std_logic;
    A11  : in std_logic;
    A12  : in std_logic;
    A13  : in std_logic;
    A14  : in std_logic;
    A15  : in std_logic
  );
end component;

-- 32 Bit Active Low Decoder
component DECODE32
port(
    O    : out std_logic;
    A    : in std_logic_vector(31 downto 0)
  );
end component;

-- 4 Bit Active Low Decoder
component DECODE4
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic
  );
end component;

-- 64 Bit Active Low Decoder
component DECODE64
port(
    O    : out std_logic;
    A    : in std_logic_vector(63 downto 0)
  );
end component;

-- 8 Bit Active Low Decoder
component DECODE8
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic
  );
end component;

-- 16-Bit Data Register with Clock Enable and Asynchronous Clear
component FD16CE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

-- 16-Bit Data Register with Clock Enable and Synchronous Reset
component FD16RE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    R   : in STD_LOGIC
    );
end component;

-- 4-Bit Data Register with Clock Enable and Asynchronous Clear
component FD4CE
port (
    Q0  : out STD_LOGIC := '0';
    Q1  : out STD_LOGIC := '0';
    Q2  : out STD_LOGIC := '0';
    Q3  : out STD_LOGIC := '0';

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end component;

-- 4-Bit Data Register with Clock Enable and Synchronous Reset
component FD4RE
  port (
    Q0  : out STD_LOGIC := '0';
    Q1  : out STD_LOGIC := '0';
    Q2  : out STD_LOGIC := '0';
    Q3  : out STD_LOGIC := '0';

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end component;

-- 8-Bit Data Register with Clock Enable and Asynchronous Clear
component FD8CE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

-- 8-Bit Data Register with Clock Enable and Synchronous Reset
component FD8RE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    R   : in STD_LOGIC
    );
end component;

-- J-K Flip-Flop with Clock Enable and Asynchronous Clear
component FJKCE
  generic(
    INIT : bit := '0'
    );
  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC
    );
end component;

-- J-K Flip-Flop with Asynchronous Clear
component FJKC
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CLR : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC
    );
end component;

-- J-K Flip-Flop with Clock Enable and Asynchronous Preset
component FJKPE
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    PRE : in STD_LOGIC
    );
end component;

-- J-K Flip-Flop with Asynchronous Preset
component FJKP
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    PRE : in STD_LOGIC
    );
end component;

-- J-K Flip-Flop with Clock Enable and Synchronous Reset and Set
component FJKRSE
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC
    );
end component;

-- J-K Flip-Flop with Clock Enable and Synchronous Reset and Set
component FJKSRE
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC
    );
end component;

-- Toggle Flip-Flop with Toggle and Clock Enable and Asynchronous Clear
component FTCE
 generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Asynchronous Clear
component FTCLE
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Asynchronous Clear
component FTCLEX
 generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle Flip-Flop with Toggle Enable and Asynchronous Clear
component FTC
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CLR : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle Flip-Flop with Toggle and Clock Enable and Asynchronous Preset
component FTPE
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    PRE : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Asynchronous Preset
component FTPLE
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    PRE : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle Flip-Flop with Toggle Enable and Asynchronous Preset
component FTP
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    PRE : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
component FTRSE
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
component FTRSLE
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
component FTSRE
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
component FTSRLE
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- Multiple Input Buffer
component IBUF16
port(
    O  : out std_logic_vector(15 downto 0);
    I  : in std_logic_vector(15 downto 0)
  );
end component;

-- Multiple Input Buffer
component IBUF4
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Multiple Input Buffer
component IBUF8
port(
    O  : out std_logic_vector(7 downto 0);
    I  : in std_logic_vector(7 downto 0)
  );
end component;

-- Multiple Input D Flip Flop
component IFD16
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

-- Single Input D Flip Flop with Inverted Clock
component IFD_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Multiple Input D Flip Flop
component IFD4
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end component;

-- Multiple Input D Flip Flop
component IFD8
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

-- Single Input D Flip Flop with Inverted Clock
component IFDI_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Single Input D Flip Flop
component IFDI
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Single Input D Flip Flop
component IFD
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Multiple Input D Flip Flop with Clock Enable
component IFDX16
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

-- Single Input D Flip Flop with Inverted Clock and Clock Enable
component IFDX_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Multiple Input D Flip Flop with Clock Enable
component IFDX4
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end component;

-- Multiple Input D Flip Flop Clock Enable
component IFDX8
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

-- Single Input D Flip Flop with Inverted Clock and Clock Enable
component IFDXI_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Single Input D Flip Flop with Clock Enable
component IFDXI
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Single Input D Flip Flop with Clock Enable
component IFDX
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Transparent Input Data Latches
component ILD16
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC
    );
end component;

-- Transparent Input Data Latch with Inverted Gate
component ILD_1
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC
    );

end component;

-- Transparent Input Data Latches
component ILD4
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC
    );
end component;

-- Transparent Input Data Latches
component ILD8
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC
    );
end component;

-- Transparent Input Data Latch with Inverted Clock
component ILDI_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC
    );

end component;

-- Transparent Input Data Latch
component ILDI
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC
    );

end component;

-- Transparent Input Data Latches
component ILDX16
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end component;

-- Transparent Input Data Latch with Inverted Gate
component ILDX_1
  generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );

end component;

-- Transparent Input Data Latches
component ILDX4
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end component;

-- Transparent Input Data Latches
component ILDX8
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end component;

-- Transparent Input Data Latch with Inverted Gate
component ILDXI_1
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );

end component;

-- Transparent Input Data Latch
component ILDXI
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );

end component;

-- Transparent Input Data Latch
component ILDX
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );

end component;

-- 16-input Inverter
component INV16
port(
    O  : out std_logic_vector(15 downto 0);

    I  : in std_logic_vector(15 downto 0)
  );
end component;

-- 4-input Inverter
component INV4
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- 8-input Inverter
component INV8
port(
    O  : out std_logic_vector(7 downto 0);

    I  : in std_logic_vector(7 downto 0)
  );
end component;

-- Transparent Data Latches with Asynchronous Clear and Gate Enable
component LD16CE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end component;

-- Multiple Transparent Data Latches
component LD16
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC
    );
end component;

-- Transparent Data Latches with Asynchronous Clear and Gate Enable
component LD4CE
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end component;

-- Multiple Transparent Data Latches
component LD4
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC
    );
end component;

-- Transparent Data Latches with Asynchronous Clear and Gate Enable
component LD8CE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end component;

-- Multiple Transparent Data Latches
component LD8
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC
    );
end component;

-- 16-to-1 Multiplexer with Enable
component M16_1E
  
port(
    O    : out std_logic;

    D0   : in std_logic;
    D1   : in std_logic;
    D2   : in std_logic;
    D3   : in std_logic;
    D4   : in std_logic;
    D5   : in std_logic;
    D6   : in std_logic;
    D7   : in std_logic;
    D8   : in std_logic;
    D9   : in std_logic;
    D10  : in std_logic;
    D11  : in std_logic;
    D12  : in std_logic;
    D13  : in std_logic;
    D14  : in std_logic;
    D15  : in std_logic;
    E    : in std_logic;
    S0   : in std_logic;
    S1   : in std_logic;
    S2   : in std_logic;
    S3   : in std_logic
  );
end component;

-- 2-to-1 Multiplexer with D0 Inverted
component M2_1B1

port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    S0  : in std_logic
  );
end component;

-- 2-to-1 Multiplexer with D0 and D1 Inverted
component M2_1B2
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    S0  : in std_logic
  );
end component;

-- 2-to-1 Multiplexer with Enable
component M2_1E
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    E   : in std_logic;
    S0  : in std_logic
  );
end component;

-- 2-to-1 Multiplexer
component M2_1
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    S0  : in std_logic
  );
end component;

-- 4-to-1 Multiplexer with Enable
component M4_1E
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    D2  : in std_logic;
    D3  : in std_logic;
    E   : in std_logic;
    S0  : in std_logic;
    S1  : in std_logic
  );
end component;

-- 8-to-1 Multiplexer with Enable
component M8_1E
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    D2  : in std_logic;
    D3  : in std_logic;
    D4  : in std_logic;
    D5  : in std_logic;
    D6  : in std_logic;
    D7  : in std_logic;
    E   : in std_logic;
    S0  : in std_logic;
    S1  : in std_logic;
    S2  : in std_logic
  );
end component;

-- 12-input NAND gate with Non-inverted Inputs
component NAND12
  
port(
    O   : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic
  );
end component;

-- 16-input NAND gate with Non-inverted Inputs
component NAND16
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10  : in std_logic;
    I11  : in std_logic;
    I12  : in std_logic;
    I13  : in std_logic;
    I14  : in std_logic;
    I15  : in std_logic
  );
end component;

-- 6-input NAND gate with Non-inverted Inputs
component NAND6
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end component;

-- 7-input NAND gate with Non-inverted Inputs
component NAND7
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end component;

-- 8-input NAND gate with Non-inverted Inputs
component NAND8
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end component;

-- 9-input NAND gate with Non-inverted Inputs
component NAND9
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end component;

-- 12-input NOR gate with Non-inverted Inputs
component NOR12
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic
  );
end component;

-- 16-input NOR gate with Non-inverted Inputs
component NOR16
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic;
    I12 : in std_logic;
    I13 : in std_logic;
    I14 : in std_logic;
    I15 : in std_logic
  );
end component;

-- 6-input NOR gate with Non-inverted Inputs
component NOR6
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end component;

-- 7-input NOR gate with Non-inverted Inputs
component NOR7
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end component;

-- 8-input NOR gate with Non-inverted Inputs
component NOR8
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end component;

-- 9-input NOR gate with Non-inverted Inputs
component NOR9
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end component;

-- Multiple Output Buffer
component OBUF16
port(
    O  : out std_logic_vector(15 downto 0);
    I  : in std_logic_vector(15 downto 0)
  );
end component;

-- Multiple Output Buffer
component OBUF4
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Multiple Output Buffer
component OBUF8
port(
    O  : out std_logic_vector(7 downto 0);
    I  : in std_logic_vector(7 downto 0)
  );
end component;

-- Multiple 3- state Output Buffer with Active High Enable
component OBUFE16
port(
    O  : out std_logic_vector(15 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(15 downto 0)
  );
end component;

-- Multiple 3- state Output Buffer with Active High Enable
component OBUFE4
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    E   : in std_logic;
    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Multiple 3- state Output Buffer with Active High Enable
component OBUFE8
port(
    O  : out std_logic_vector(7 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(7 downto 0)
  );
end component;

-- 3- state Output Buffer with Active High Enable
component OBUFE
port(
    O  : out std_logic;

    E  : in std_logic;
    I  : in std_logic
  );
end component;

-- Multiple 3- state Output Buffer with Active Low Enable
component OBUFT16
port(
    O  : out std_logic_vector(15 downto 0);

    I  : in std_logic_vector(15 downto 0);
    T  : in std_logic
  );
end component;

-- Multiple 3- state Output Buffer with Active Low Enable
component OBUFT4
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    T   : in std_logic
  );
end component;

-- Multiple 3- state Output Buffer with Active Low Enable
component OBUFT8
port(
    O  : out std_logic_vector(7 downto 0);

    I  : in std_logic_vector(7 downto 0);
    T  : in std_logic
  );
end component;

-- Multiple Output D Flip Flop
component OFD16
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

-- Single Output D Flip Flop with Inverted Clock
component OFD_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Multiple Output D Flip Flop
component OFD4
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end component;

-- Multiple Output D Flip Flop
component OFD8
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

-- D Flip Flops with Active High Enable Output Buffers
component OFDE16
port (
    O   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    E   : in STD_LOGIC
    );
end component;

-- Output D Flip Flop with Active High Enable Output Buffer and Inverted Clock
component OFDE_1
generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    E  : in STD_LOGIC
    );

end component;

-- D Flip Flops with Active High Enable Output Buffers
component OFDE4
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    E   : in STD_LOGIC
    );
end component;

-- D Flip Flops with Active High Enable Output Buffers
component OFDE8
port (
    O   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    E   : in STD_LOGIC
    );
end component;

-- Output D Flip Flop with Active High Enable Output Buffer
component OFDE
generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    E  : in STD_LOGIC
    );

end component;

-- Single Output D Flip Flop with Inverted Clock
component OFDI_1
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Single Output D Flip Flop
component OFDI
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- D Flip Flops with Active Low 3-State Output Enable Buffers
component OFDT16
port (
    O   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    T   : in STD_LOGIC
    );
end component;

-- Output D Flip Flop with Active Low 3-State Output Buffer and Inverted Clock
component OFDT_1
generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    T  : in STD_LOGIC
    );

end component;

-- D Flip Flops with Active Low 3-State Output Enable Buffers
component OFDT4
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end component;

-- D Flip Flops with Active Low 3-State Output Enable Buffers
component OFDT8
port (
    O   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    T   : in STD_LOGIC
    );
end component;

-- Output D Flip Flop with Active Low 3-State Output Enable Buffer
component OFDT
 generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    T  : in STD_LOGIC
    );

end component;

-- Single Output D Flip Flop
component OFD
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Multiple Output D Flip Flop with Clock Enable
component OFDX16
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end component;

-- Single Output D Flip Flop with Inverted Clock and Clock Enable
component OFDX_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Multiple Output D Flip Flop with Clock Enable
component OFDX4
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end component;

-- Multiple Output D Flip Flop Clock Enable
component OFDX8
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

-- Single Output D Flip Flop with Inverted Clock and Clock Enable
component OFDXI_1
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Single Output D Flip Flop with Clock Enable
component OFDXI
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- Single Output D Flip Flop with Clock Enable
component OFDX
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );

end component;

-- 12-input OR gate with Non-inverted Inputs
component OR12
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic
  );
end component;

-- 16-input OR gate with Non-inverted Inputs
component OR16
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic;
    I12 : in std_logic;
    I13 : in std_logic;
    I14 : in std_logic;
    I15 : in std_logic
  );
end component;

-- 6-input OR gate with Non-inverted Inputs
component OR6
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end component;

-- 7-input OR gate with Non-inverted Inputs
component OR7
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end component;

-- 8-input OR gate with Non-inverted Inputs
component OR8
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end component;

-- 9-input OR gate with Non-inverted Inputs
component OR9
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end component;

-- 16-Deep by 2-Wide Static Dual Port Synchronous RAM
component RAM16X2D
  
port(
    DPO0  : out std_logic;
    DPO1  : out std_logic;
    SPO0  : out std_logic;
    SPO1  : out std_logic;

    A0    : in std_logic;
    A1    : in std_logic;
    A2    : in std_logic;
    A3    : in std_logic;
    D0    : in std_logic;
    D1    : in std_logic;
    DPRA0 : in std_logic;
    DPRA1 : in std_logic;
    DPRA2 : in std_logic;
    DPRA3 : in std_logic;
    WCLK  : in std_logic;
    WE    : in std_logic
  );
end component;

-- 16-Deep by 4-Wide Static Dual Port Synchronous RAM
component RAM16X4D
  
port(
    DPO0  : out std_logic;
    DPO1  : out std_logic;
    DPO2  : out std_logic;
    DPO3  : out std_logic;
    SPO0  : out std_logic;
    SPO1  : out std_logic;
    SPO2  : out std_logic;
    SPO3  : out std_logic;

    A0    : in std_logic;
    A1    : in std_logic;
    A2    : in std_logic;
    A3    : in std_logic;
    D0    : in std_logic;
    D1    : in std_logic;
    D2    : in std_logic;
    D3    : in std_logic;
    DPRA0 : in std_logic;
    DPRA1 : in std_logic;
    DPRA2 : in std_logic;
    DPRA3 : in std_logic;
    WCLK  : in std_logic;
    WE    : in std_logic
  );
end component;

-- 16-Deep by 8-Wide Static Dual Port Synchronous RAM
component RAM16X8D
port(
    DPO   : out std_logic_vector(7 downto 0);
    SPO   : out std_logic_vector(7 downto 0);

    A0    : in std_logic;
    A1    : in std_logic;
    A2    : in std_logic;
    A3    : in std_logic;
    D     : in std_logic_vector(7 downto 0);
    DPRA0 : in std_logic;
    DPRA1 : in std_logic;
    DPRA2 : in std_logic;
    DPRA3 : in std_logic;
    WCLK  : in std_logic;
    WE    : in std_logic
  );
end component;

-- Sum of Products
component SOP3B1A
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end component;

-- Sum of Products
component SOP3B1B
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end component;

-- Sum of Products
component SOP3B2A
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end component;

-- Sum of Products
component SOP3B2B
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end component;

-- Sum of Products
component SOP3B3
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end component;

-- Sum of Products
component SOP3
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end component;

-- Sum of Products
component SOP4B1
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Sum of Products
component SOP4B2A
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Sum of Products
component SOP4B2B
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Sum of Products
component SOP4B3
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Sum of Products
component SOP4B4
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- Sum of Products
component SOP4
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end component;

-- 16-Bit Serial-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
component SR16CE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 16-Bit Shift Register with Clock Enable and Asynchronous Clear
component SR16CLED
port (
    Q    : out STD_LOGIC_VECTOR(15 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(15 downto 0);
    L    : in STD_LOGIC;
    LEFT : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end component;

-- 16-Bit Loadable Serial/Parallel-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
component SR16CLE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    L   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 16-Bit Serial-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
component SR16RE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 16-Bit Shift Register with Clock Enable and Synchronous Reset
component SR16RLED
port (
    Q    : out STD_LOGIC_VECTOR(15 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(15 downto 0);
    L    : in STD_LOGIC; 
    LEFT : in STD_LOGIC;
    R    : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end component;

-- 16-Bit Loadable Serial/Parallel-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
component SR16RLE
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    L   : in STD_LOGIC; 
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 4-Bit Serial-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
component SR4CE
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 4-Bit Shift Register with Clock Enable and Asynchronous Clear
component SR4CLED
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC;
    LEFT : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end component;

-- 4-Bit Loadable Serial/Parallel-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
component SR4CLE
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    L   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 4-Bit Serial-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
component SR4RE
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 4-Bit Shift Register with Clock Enable and Synchronous Reset
component SR4RLED
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC; 
    LEFT : in STD_LOGIC;
    R    : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end component;

-- 4-Bit Loadable Serial/Parallel-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
component SR4RLE
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    L   : in STD_LOGIC; 
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 8-Bit Serial-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
component SR8CE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 8-Bit Shift Register with Clock Enable and Asynchronous Clear
component SR8CLED
port (
    Q    : out STD_LOGIC_VECTOR(7 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(7 downto 0);
    L    : in STD_LOGIC;
    LEFT : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end component;

-- 8-Bit Loadable Serial/Parallel-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
component SR8CLE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    L   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 8-Bit Serial-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
component SR8RE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 8-Bit Shift Register with Clock Enable and Synchronous Reset
component SR8RLED
port (
    Q    : out STD_LOGIC_VECTOR(7 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(7 downto 0);
    L    : in STD_LOGIC; 
    LEFT : in STD_LOGIC;
    R    : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end component;

-- 8-Bit Loadable Serial/Parallel-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
component SR8RLE
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    L   : in STD_LOGIC; 
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end component;

-- 6-input XNOR gate with Non-inverted Inputs
component XNOR6
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end component;

-- 7-input XNOR gate with Non-inverted Inputs
component XNOR7
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end component;

-- 8-input XNOR gate with Non-inverted Inputs
component XNOR8
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end component;

-- 9-input XNOR gate with Non-inverted Inputs
component XNOR9
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end component;

-- 6-input XOR gate with Non-inverted Inputs
component XOR6
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end component;

-- 7-input XOR gate with Non-inverted Inputs
component XOR7
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end component;

-- 8-input XOR gate with Non-inverted Inputs
component XOR8
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end component;

-- 9-input XOR gate with Non-inverted Inputs
component XOR9
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end component;


end hdlMacro;

-- 16-Bit Loadable Cascadable Accumulator with Carry-In, Carry-Out and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ACC16 is
port (
    CO   : out STD_LOGIC;
    OFL  : out STD_LOGIC;
    Q    : out STD_LOGIC_VECTOR(15 downto 0);

    ADD  : in STD_LOGIC;
    B    : in STD_LOGIC_VECTOR(15 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CI   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(15 downto 0);
    L    : in STD_LOGIC;
    R    : in STD_LOGIC
    );
end ACC16;

architecture ACC16_V of ACC16 is
begin

   process(C)
   variable adsu_tmp : STD_LOGIC_VECTOR(16 downto 0);
   variable q_tmp    : STD_LOGIC;
   begin
     if (C'event and C ='1') then
       if (R='1') then
        adsu_tmp := (others => '0');
        q_tmp := '0';
       elsif (L='1') then
         adsu_tmp(15 downto 0) := D;
       elsif (CE='1') then 
         q_tmp := adsu_tmp(15);
         if(ADD = '1') then
           adsu_tmp := conv_std_logic_vector((conv_integer(adsu_tmp(15 downto 0)) + conv_integer(B) + conv_integer(CI)),17);
         else
           adsu_tmp := conv_std_logic_vector((conv_integer(adsu_tmp(15 downto 0)) - conv_integer(not CI) - conv_integer(B)),17);
         end if;
       end if;
     end if;

   Q <= adsu_tmp(15 downto 0);

   if (ADD='1') then
     CO <= adsu_tmp(16);
     OFL <=  ( q_tmp and B(15) and (not adsu_tmp(15)) ) or ( (not q_tmp) and (not B(15)) and adsu_tmp(15) );  
   else
     CO <= not adsu_tmp(16);
     OFL <=  ( q_tmp and (not B(15)) and (not adsu_tmp(15)) ) or ( (not q_tmp) and B(15) and adsu_tmp(15) );  
   end if;

   end process;
end ACC16_V;



-- 4-Bit Loadable Cascadable Accumulator with Carry-In, Carry-Out and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ACC4 is
  
port (
    CO   : out STD_LOGIC;
    OFL  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;

    ADD  : in STD_LOGIC;
    B0   : in STD_LOGIC;
    B1   : in STD_LOGIC;
    B2   : in STD_LOGIC;
    B3   : in STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CI   : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC;
    R    : in STD_LOGIC
    );
end ACC4;

architecture ACC4_V of ACC4 is
begin
   process(C)
   variable adsu_tmp : STD_LOGIC_VECTOR(4 downto 0);
   variable b_tmp    : STD_LOGIC_VECTOR(3 downto 0);
   variable q_tmp    : STD_LOGIC;

   begin
     b_tmp := B3&B2&B1&B0; 
     
     if (C'event and C ='1') then
       if (R='1') then
         adsu_tmp := (others => '0');
         q_tmp := '0';
       elsif (L='1') then
         adsu_tmp(3 downto 0) := D3&D2&D1&D0;
       elsif (CE='1') then 
         q_tmp := adsu_tmp(3);
         if(ADD = '1') then
           adsu_tmp := conv_std_logic_vector((conv_integer(adsu_tmp(3 downto 0)) + conv_integer(b_tmp) + conv_integer(CI)),5);
         else
           adsu_tmp := conv_std_logic_vector((conv_integer(adsu_tmp(3 downto 0)) - conv_integer(not CI) - conv_integer(b_tmp)),5);
         end if;
       end if;
     end if;

   if (ADD='1') then
     CO <= adsu_tmp(4);
     OFL <=  ( q_tmp and B3 and (not adsu_tmp(3)) ) or ( (not q_tmp) and (not B3) and adsu_tmp(3) );  
   elsif(ADD = '0') then
     CO <= not (adsu_tmp(4));
     OFL <=  ( q_tmp and (not B3) and (not adsu_tmp(3)) ) or ( (not q_tmp) and B3 and adsu_tmp(3) );  
   end if;

   Q3 <= adsu_tmp(3);
   Q2 <= adsu_tmp(2);
   Q1 <= adsu_tmp(1);
   Q0 <= adsu_tmp(0);


   end process;
   
end ACC4_V;



-- 8-Bit Loadable Cascadable Accumulator with Carry-In, Carry-Out and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ACC8 is
port (
    CO   : out STD_LOGIC;
    OFL  : out STD_LOGIC;
    Q    : out STD_LOGIC_VECTOR(7 downto 0);

    ADD  : in STD_LOGIC;
    B    : in STD_LOGIC_VECTOR(7 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CI   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(7 downto 0);
    L    : in STD_LOGIC;
    R    : in STD_LOGIC
    );
end ACC8;

architecture ACC8_V of ACC8 is
begin

   process(C)
   variable adsu_tmp : STD_LOGIC_VECTOR(8 downto 0);
   variable q_tmp    : STD_LOGIC;
   begin
     if (C'event and C ='1') then
       if (R='1') then
          adsu_tmp := (others => '0');
          q_tmp := '0';
       elsif (L='1') then
         adsu_tmp(7 downto 0) := D;
       elsif (CE='1') then 
         q_tmp := adsu_tmp(7);
         if(ADD = '1') then
           adsu_tmp := conv_std_logic_vector((conv_integer(adsu_tmp(7 downto 0)) + conv_integer(B) + conv_integer(CI)),9);
         else
           adsu_tmp := conv_std_logic_vector((conv_integer(adsu_tmp(7 downto 0)) - conv_integer(not CI) - conv_integer(B)),9);
         end if;
       end if;
     end if;

   Q <= adsu_tmp(7 downto 0);
 
   if (ADD='1') then
     CO <= adsu_tmp(8);
     OFL <=  ( q_tmp and B(7) and (not adsu_tmp(7)) ) or ( (not q_tmp) and (not B(7)) and adsu_tmp(7) );  
   else
     CO <= not adsu_tmp(8);
     OFL <=  ( q_tmp and (not B(7)) and (not adsu_tmp(7)) ) or ( (not q_tmp) and B(7) and adsu_tmp(7) );  
   end if;

   end process;
end ACC8_V;



-- 16-bit cascadable Full Adder with Carry-In, Carry-out
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity ADD16 is
port(
       CO  : out std_logic;
       OFL : out std_logic;
       S   : out std_logic_vector(15 downto 0);
    
       A   : in std_logic_vector(15 downto 0);
       B   : in std_logic_vector(15 downto 0);
       CI  : in std_logic
    );
end ADD16;

architecture ADD16_V of ADD16 is
  signal adder_tmp: std_logic_vector(16 downto 0);
begin
  adder_tmp <= conv_std_logic_vector((conv_integer(A) + conv_integer(B) + conv_integer(CI)),17);
  S         <= adder_tmp(15 downto 0);
  CO        <= adder_tmp(16);
  OFL <=  ( A(15) and B(15) and (not adder_tmp(15)) ) or ( (not A(15)) and (not B(15)) and adder_tmp(15) );  
          
end ADD16_V;



-- 4-bit cascadable Full Adder with Carry-In, Carry-out
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity ADD4 is
  port(
    CO  : out std_logic;
    OFL : out std_logic;
    S0  : out std_logic;
    S1  : out std_logic;
    S2  : out std_logic;
    S3  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic;
    CI  : in std_logic
  );
end ADD4;

architecture ADD4_V of ADD4 is
begin
 adsu_p : process (A0, A1, A2, A3, B0, B1, B2, B3, CI)
    variable adsu_tmp : std_logic_vector(4 downto 0);
    variable a_tmp    : std_logic_vector(3 downto 0);
    variable b_tmp    : std_logic_vector(3 downto 0);
  begin
    a_tmp := A3 & A2 & A1 & A0;
    b_tmp := B3 & B2 & B1 & B0;
    adsu_tmp := conv_std_logic_vector((conv_integer(a_tmp) + conv_integer(b_tmp) + conv_integer(CI)),5);
      
    S3 <= adsu_tmp(3);
    S2 <= adsu_tmp(2);
    S1 <= adsu_tmp(1);
    S0 <= adsu_tmp(0);
    CO <= adsu_tmp(4);
    OFL <= ( A3 and B3 and (not adsu_tmp(3)) ) or ( (not A3) and (not B3) and adsu_tmp(3) ); 
  end process; 

end ADD4_V;



-- 8-bit cascadable Full Adder with Carry-In, Carry-out
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity ADD8 is
port(
    CO  : out std_logic;
    OFL : out std_logic;
    S   : out std_logic_vector(7 downto 0);
    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0);
    CI  : in std_logic
  );
end ADD8;

architecture ADD8_V of ADD8 is
  signal adder_tmp: std_logic_vector(8 downto 0);
begin
  adder_tmp <= conv_std_logic_vector((conv_integer(A) + conv_integer(B) + conv_integer(CI)),9);
  S  <= adder_tmp(7 downto 0);
  CO <= adder_tmp(8);
  OFL <=  ( A(7) and B(7) and (not adder_tmp(7)) ) or ( (not A(7)) and (not B(7)) and adder_tmp(7) );  
end ADD8_V;



-- 16-bit Cascadable Adder/Subtracter with Carry-In, Carry-out
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity ADSU16 is
port(
    CO   : out std_logic;
    OFL  : out std_logic;
    S    : out std_logic_vector(15 downto 0);

    A    : in std_logic_vector(15 downto 0);
    ADD  : in std_logic;
    B    : in std_logic_vector(15 downto 0);
    CI   : in std_logic
  );
end ADSU16;

architecture ADSU16_V of ADSU16 is

begin
  adsu_p : process (A, ADD, B, CI)
    variable adsu_tmp : std_logic_vector(16 downto 0);
  begin
    if(ADD = '1') then
     adsu_tmp := conv_std_logic_vector((conv_integer(A) + conv_integer(B) + conv_integer(CI)),17);
    else
     adsu_tmp := conv_std_logic_vector((conv_integer(A) - conv_integer(not CI) - conv_integer(B)),17);
  end if;
      
  S   <= adsu_tmp(15 downto 0);
   
  if (ADD='1') then
    CO <= adsu_tmp(16);
    OFL <=  ( A(15) and B(15) and (not adsu_tmp(15)) ) or ( (not A(15)) and (not B(15)) and adsu_tmp(15) );  
  else
    CO <= not adsu_tmp(16);
    OFL <=  ( A(15) and (not B(15)) and (not adsu_tmp(15)) ) or ( (not A(15)) and B(15) and adsu_tmp(15) );  
  end if;
 
  end process;
  
end ADSU16_V;



-- 4-bit Cascadable Adder/Subtracter with Carry-In, Carry-out
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity ADSU4 is
  port(
    CO  : out std_logic;
    OFL : out std_logic;
    S0  : out std_logic;
    S1  : out std_logic;
    S2  : out std_logic;
    S3  : out std_logic;
    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    ADD : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic;
    CI  : in std_logic
  );
end ADSU4;

architecture ADSU4_V of ADSU4 is

begin
  adsu_p : process (A0, A1, A2, A3, ADD, B0, B1, B2, B3, CI)
    variable adsu_tmp : std_logic_vector(4 downto 0);
    variable a_tmp    : std_logic_vector(3 downto 0);
    variable b_tmp    : std_logic_vector(3 downto 0);
  begin
    a_tmp := A3 & A2 & A1 & A0;
    b_tmp := B3 & B2 & B1 & B0;
    if (ADD = '1') then
      adsu_tmp := conv_std_logic_vector((conv_integer(a_tmp) + conv_integer(b_tmp) + conv_integer(CI)),5);
    else
      adsu_tmp := conv_std_logic_vector((conv_integer(a_tmp) - conv_integer(not CI) - conv_integer(b_tmp)),5);
    end if;
      
   S3 <= adsu_tmp(3);
   S2 <= adsu_tmp(2);
   S1 <= adsu_tmp(1);
   S0 <= adsu_tmp(0);
   
   if (ADD='1') then
     CO <= adsu_tmp(4);
     OFL <= ( A3 and B3 and (not adsu_tmp(3)) ) or ( (not A3) and (not B3) and adsu_tmp(3) ); 
   else
     CO <= not adsu_tmp(4);
     OFL <= ( A3 and (not B3) and (not adsu_tmp(3)) ) or ( (not A3) and B3 and adsu_tmp(3) ); 
   end if;
 
  end process;
  
end ADSU4_V;



-- 8-bit Cascadable Adder/Subtracter with Carry-In, Carry-out
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity ADSU8 is
port(
    CO   : out std_logic;
    OFL  : out std_logic;
    S    : out std_logic_vector(7 downto 0);

    A    : in std_logic_vector(7 downto 0);
    ADD  : in std_logic;
    B    : in std_logic_vector(7 downto 0);
    CI   : in std_logic
  );
end ADSU8;

architecture ADSU8_V of ADSU8 is

begin
  adsu_p : process (A, ADD, B, CI)
    variable adsu_tmp : std_logic_vector(8 downto 0);
  begin
    if (ADD = '1') then
      adsu_tmp := conv_std_logic_vector((conv_integer(A) + conv_integer(B) + conv_integer(CI)),9);
    else
      adsu_tmp := conv_std_logic_vector((conv_integer(A) - conv_integer(not CI) - conv_integer(B)),9);
    end if;
      
  S <= adsu_tmp(7 downto 0);

  if (ADD='1') then
    CO <= adsu_tmp(8);
    OFL <=  ( A(7) and B(7) and (not adsu_tmp(7)) ) or ( (not A(7)) and (not B(7)) and adsu_tmp(7) );  
  else
    CO <= not adsu_tmp(8);
    OFL <=  ( A(7) and (not B(7)) and (not adsu_tmp(7)) ) or ( (not A(7)) and B(7) and adsu_tmp(7) );  
  end if;

  end process;
  
end ADSU8_V;



-- 12-input AND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity AND12 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10  : in std_logic;
    I11  : in std_logic
  );
end AND12;

architecture AND12_V of AND12 is
begin
  O <= I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7 and I8 and I9 and I10 and I11;
end AND12_V;



-- 16-input AND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity AND16 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10  : in std_logic;
    I11  : in std_logic;
    I12  : in std_logic;
    I13  : in std_logic;
    I14  : in std_logic;
    I15  : in std_logic
  );
end AND16;

architecture AND16_V of AND16 is
begin
  O <= I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7 and I8 and I9 and I10 and I11 and I12 and I13 and I14 and I15;
end AND16_V;



-- 6-input AND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity AND6 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end AND6;

architecture AND6_V of AND6 is
begin
  O <= I0 and I1 and I2 and I3 and I4 and I5;
end AND6_V;



-- 7-input AND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity AND7 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end AND7;

architecture AND7_V of AND7 is
begin
  O <= I0 and I1 and I2 and I3 and I4 and I5 and I6;
end AND7_V;



-- 8-input AND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity AND8 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end AND8;

architecture AND8_V of AND8 is
begin
  O <= I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7;
end AND8_V;



-- 9-input AND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity AND9 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end AND9;

architecture AND9_V of AND9 is
begin
  O <= I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7 and I8;
end AND9_V;



-- 4-Bit Barrel Shifter
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity BRLSHFT4 is
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    I0  : in STD_LOGIC;
    I1  : in STD_LOGIC;
    I2  : in STD_LOGIC;
    I3  : in STD_LOGIC;
    S0  : in STD_LOGIC;
    S1  : in STD_LOGIC
    );
end BRLSHFT4;

architecture Behavioral of BRLSHFT4 is
signal q_tmp : std_logic_vector(3 downto 0);
begin

process(I0, I1, I2, I3, S0, S1)
variable s_tmp : std_logic_vector(1 downto 0);
begin
   s_tmp := S1&S0;
   case s_tmp is
    
   when "00"    => q_tmp <= I3 & I2 & I1 & I0;
   when "01"    => q_tmp <= I0 & I3 & I2 & I1;
   when "10"    => q_tmp <= I1 & I0 & I3 & I2;
   when "11"    => q_tmp <= I2 & I1 & I0 & I3;
   when  others => q_tmp <= I3 & I2 & I1 & I0;

   end case;
end process;

O3 <= q_tmp(3);
O2 <= q_tmp(2);
O1 <= q_tmp(1);
O0 <= q_tmp(0);


end Behavioral;



-- 8-Bit Barrel Shifter
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity BRLSHFT8 is
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    O4  : out STD_LOGIC;
    O5  : out STD_LOGIC;
    O6  : out STD_LOGIC;
    O7  : out STD_LOGIC;
    I0  : in STD_LOGIC;
    I1  : in STD_LOGIC;
    I2  : in STD_LOGIC;
    I3  : in STD_LOGIC;
    I4  : in STD_LOGIC;
    I5  : in STD_LOGIC;
    I6  : in STD_LOGIC;
    I7  : in STD_LOGIC;
    S0  : in STD_LOGIC;
    S1  : in STD_LOGIC;
    S2  : in STD_LOGIC
    );
end BRLSHFT8;

architecture Behavioral of BRLSHFT8 is
signal q_tmp : std_logic_vector(7 downto 0);
begin

process(I0, I1, I2, I3, I4, I5, I6, I7, S0, S1, S2)
variable s_tmp : std_logic_vector(2 downto 0);
begin
   s_tmp := S2&S1&S0;
   case s_tmp is
    
   when "000"    => q_tmp <= I7 & I6 & I5 & I4 & I3 & I2 & I1 & I0;
   when "001"    => q_tmp <= I0 & I7 & I6 & I5 & I4 & I3 & I2 & I1;
   when "010"    => q_tmp <= I1 & I0 & I7 & I6 & I5 & I4 & I3 & I2;
   when "011"    => q_tmp <= I2 & I1 & I0 & I7 & I6 & I5 & I4 & I3;
   when "100"    => q_tmp <= I3 & I2 & I1 & I0 & I7 & I6 & I5 & I4;
   when "101"    => q_tmp <= I4 & I3 & I2 & I1 & I0 & I7 & I6 & I5;
   when "110"    => q_tmp <= I5 & I4 & I3 & I2 & I1 & I0 & I7 & I6;
   when "111"    => q_tmp <= I6 & I5 & I4 & I3 & I2 & I1 & I0 & I7;
   when  others =>  q_tmp <= I7 & I6 & I5 & I4 & I3 & I2 & I1 & I0;

   end case;
end process;

O7 <= q_tmp(7);
O6 <= q_tmp(6);
O5 <= q_tmp(5);
O4 <= q_tmp(4);
O3 <= q_tmp(3);
O2 <= q_tmp(2);
O1 <= q_tmp(1);
O0 <= q_tmp(0);


end Behavioral;



-- Multiple 3- state Buffer with Active High Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity BUFE16 is
port(
    O  : out std_logic_vector(15 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(15 downto 0)
  );
end BUFE16;

architecture BUFE16_V of BUFE16 is
begin
  process (I, E)
  begin
    if (E='1') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end BUFE16_V;



-- Multiple 3- state Buffer with Active High Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity BUFE4 is
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    E   : in std_logic;
    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end BUFE4;

architecture BUFE4_V of BUFE4 is
begin
  process (I0, I1, I2, I3, E)
  begin
    if (E='1') then

      O0 <= I0;
      O1 <= I1;
      O2 <= I2;
      O3 <= I3;

    else

      O0 <= 'Z';
      O1 <= 'Z';
      O2 <= 'Z';
      O3 <= 'Z';

  end if;
 end process;

end BUFE4_V;



-- Multiple 3- state Buffer with Active High Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity BUFE8 is
port(
    O  : out std_logic_vector(7 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(7 downto 0)
  );
end BUFE8;

architecture BUFE8_V of BUFE8 is
begin
  process (I, E)
  begin
    if (E='1') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end BUFE8_V;



-- Multiple 3- state Buffer with Active Low Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity BUFT16 is
port(
    O  : out std_logic_vector(15 downto 0);

    I  : in std_logic_vector(15 downto 0);
    T  : in std_logic
  );
end BUFT16;

architecture BUFT16_V of BUFT16 is
begin
  process (I, T)
  begin
    if (T='0') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end BUFT16_V;



-- Multiple 3- state Buffer with Active Low Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity BUFT4 is
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    T   : in std_logic
  );
end BUFT4;

architecture BUFT4_V of BUFT4 is
begin
  process (I0, I1, I2, I3, T)
  begin
    if (T='0') then

      O0 <= I0;
      O1 <= I1;
      O2 <= I2;
      O3 <= I3;

    else

      O0 <= 'Z';
      O1 <= 'Z';
      O2 <= 'Z';
      O3 <= 'Z';

  end if;
 end process;

end BUFT4_V;



-- Multiple 3- state Buffer with Active Low Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity BUFT8 is
port(
    O  : out std_logic_vector(7 downto 0);

    I  : in std_logic_vector(7 downto 0);
    T  : in std_logic
  );
end BUFT8;

architecture BUFT8_V of BUFT8 is
begin
  process (I, T)
  begin
    if (T='0') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end BUFT8_V;



-- 16-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB16CE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end CB16CE;

architecture Behavioral of CB16CE is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <=  '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
Q   <= COUNT;

end Behavioral;



-- 16-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB16CLED is
port (
       CEO : out STD_LOGIC;
       Q   : out STD_LOGIC_VECTOR(15 downto 0);
       TC  : out STD_LOGIC;
       C   : in STD_LOGIC;
       CE  : in STD_LOGIC;
       CLR : in STD_LOGIC;
       D   : in STD_LOGIC_VECTOR (15 downto 0);	
       L   : in STD_LOGIC;
       UP  : in STD_LOGIC );
end CB16CLED;

architecture Behavioral of CB16CLED is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

  constant TERMINAL_COUNT_UP : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (L = '1') then
      COUNT <= D;
    elsif (CE='1') then
      if (UP='1') then
        COUNT <= COUNT+1;
      elsif (UP='0') then
        COUNT <= COUNT-1;
      end if;
    end if;
  end if;
end process;

TC  <= '0' when  (CLR = '1') else 
       '1' when  (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
        ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) else '0'; 
CEO <= '1' when  ((((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
        ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) and CE='1') else '0'; 

Q   <= COUNT;

end Behavioral;



-- 16-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB16CLE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR (15 downto 0);	
    L   : in STD_LOGIC );
end CB16CLE;

architecture Behavioral of CB16CLE is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C ='1') then
    if (L = '1') then
      COUNT <= D;
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <= '0' when (CLR = '1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q   <= COUNT;

end Behavioral;



-- 16-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB16RE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CB16RE;

architecture CB16RE_V of CB16RE is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <= '0' when (R='1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q   <= COUNT;

end CB16RE_V;



-- 2-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB2CE is
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end CB2CE;

architecture Behavioral of CB2CE is

  signal COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC   <= '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO  <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';

Q1 <= COUNT(1);
Q0 <= COUNT(0);

end Behavioral;



-- 2-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB2CLED is
	
port (
       CEO : out STD_LOGIC;
       Q0  : out STD_LOGIC;
       Q1  : out STD_LOGIC;
       TC  : out STD_LOGIC;
       C   : in STD_LOGIC;
       CE  : in STD_LOGIC;
       CLR : in STD_LOGIC;
       D0  : in STD_LOGIC;	
       D1  : in STD_LOGIC;	
       L   : in STD_LOGIC;
       UP  : in STD_LOGIC );
end CB2CLED;

architecture Behavioral of CB2CLED is

  signal COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

  constant TERMINAL_COUNT_UP : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (L = '1') then
      COUNT <= D1&D0;
    elsif (CE='1') then
      if (UP='1') then
        COUNT <= COUNT+1;
      elsif (UP='0') then
        COUNT <= COUNT-1;
      end if;
    end if;
  end if;
end process;

TC  <= '0' when  (CLR = '1') else 
       '1' when  (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) else '0'; 
CEO <= '1' when  ((((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
        ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) and CE='1') else '0'; 

Q1  <= COUNT(1);
Q0  <= COUNT(0);

end Behavioral;



-- 2-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB2CLE is
  
port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;	
    D1  : in STD_LOGIC;	
    L   : in STD_LOGIC );
end CB2CLE;

architecture Behavioral of CB2CLE is

  signal COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C ='1') then
    if (L = '1') then
      COUNT <= D1&D0;
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <=  '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 

Q1  <= COUNT(1);
Q0  <= COUNT(0);

end Behavioral;



-- 2-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB2RE is
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CB2RE;

architecture CB2RE_V of CB2RE is

  signal COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <= '0' when (R='1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end CB2RE_V;



-- 4-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB4CE is
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end CB4CE;

architecture Behavioral of CB4CE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC   <=  '0' when (CLR = '1') else
         '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO  <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';

Q3 <= COUNT(3);
Q2 <= COUNT(2);
Q1 <= COUNT(1);
Q0 <= COUNT(0);

end Behavioral;



-- 4-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB4CLED is
	
port (
        CEO : out STD_LOGIC;
        Q0  : out STD_LOGIC;
        Q1  : out STD_LOGIC;
        Q2  : out STD_LOGIC;
        Q3  : out STD_LOGIC;
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D0  : in STD_LOGIC;	
        D1  : in STD_LOGIC;	
        D2  : in STD_LOGIC;	
        D3  : in STD_LOGIC;	
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC );
end CB4CLED;

architecture Behavioral of CB4CLED is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

  constant TERMINAL_COUNT_UP : STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (L = '1') then
      COUNT <= D3&D2&D1&D0;
    elsif (CE='1') then
      if (UP='1') then
        COUNT <= COUNT+1;
      elsif (UP='0') then
        COUNT <= COUNT-1;
      end if;
    end if;
  end if;
end process;

TC  <= '0' when  (CLR = '1') else 
       '1' when  (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
        ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) else '0'; 
CEO <= '1' when  ((((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
        ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) and CE='1') else '0'; 

Q3  <= COUNT(3);
Q2  <= COUNT(2);
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end Behavioral;



-- 4-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB4CLE is
  
port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;	
    D1  : in STD_LOGIC;	
    D2  : in STD_LOGIC;	
    D3  : in STD_LOGIC;	
    L   : in STD_LOGIC );
end CB4CLE;

architecture Behavioral of CB4CLE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '1');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C ='1') then
    if (L = '1') then
      COUNT <= D3&D2&D1&D0;
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <=  '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
 
Q3  <= COUNT(3);
Q2  <= COUNT(2);
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end Behavioral;



-- 4-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB4RE is
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CB4RE;

architecture CB4RE_V of CB4RE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '1');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <= '0' when (R ='1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q3  <= COUNT(3);
Q2  <= COUNT(2);
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end CB4RE_V;



-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB8CE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end CB8CE;

architecture Behavioral of CB8CE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <=  '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
Q   <= COUNT;

end Behavioral;



-- 8-Bit Loadable Cascadable Bidirectional Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB8CLED is
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(7 downto 0);
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR (7 downto 0);	
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC );
end CB8CLED;

architecture Behavioral of CB8CLED is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

  constant TERMINAL_COUNT_UP : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (L = '1') then
      COUNT <= D;
    elsif (CE='1') then
      if (UP='1') then
        COUNT <= COUNT+1;
      elsif (UP='0') then
        COUNT <= COUNT-1;
      end if;
    end if;
  end if;
end process;

TC  <= '0' when  (CLR = '1') else 
       '1' when  (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
        ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) else '0'; 
CEO <= '1' when  ((((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
        ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) and CE='1') else '0'; 

Q   <= COUNT;

end Behavioral;



-- 8-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB8CLE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR (7 downto 0);	
    L   : in STD_LOGIC );
end CB8CLE;

architecture Behavioral of CB8CLE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C ='1') then
    if (L = '1') then
      COUNT <= D;
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <=  '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q   <= COUNT;

end Behavioral;



-- 8-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CB8RE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CB8RE;

architecture CB8RE_V of CB8RE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC  <=  '0'  when (R='1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q   <= COUNT;

end CB8RE_V;



-- 16-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC16CE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in  STD_LOGIC;
    CE  : in  STD_LOGIC;
    CLR : in  STD_LOGIC
    );
end CC16CE;

architecture Behavioral of CC16CE is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
  
begin

  process(C, CLR)
  begin
    if (CLR='1') then
      COUNT <= (others => '0');
    elsif (C'event and C = '1') then
      if (CE='1') then 
      COUNT <= COUNT+1;
      end if;
    end if;
  end process;


  TC <= '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0';
  CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
  Q<=COUNT;

end Behavioral;



-- 16-Bit Loadable Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC16CLED is
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(15 downto 0);
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR(15 downto 0);
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC);
end CC16CLED;

architecture Behavioral of CC16CLED is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

  constant TERMINAL_COUNT_UP : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
    elsif (C'event and C = '1') then
      if (L = '1') then
        COUNT <= D;
      elsif (CE='1') then
        if (UP='1') then
          COUNT <= COUNT+1;
        elsif (UP='0') then
          COUNT <= COUNT-1;
        end if;
      end if;
  end if;
end process;

TC <=    '0' when (CLR = '1') else
         '1' when (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
	((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) else '0'; 

CEO <= '1' when (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
	 ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0')))  and CE='1' else '0';
Q <= COUNT;

end Behavioral;



-- 16-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC16CLE is
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(15 downto 0);
        TC  : out STD_LOGIC;
        CLR : in STD_LOGIC;
        CE  : in STD_LOGIC;
        C   : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR (15 downto 0);
        L   : in STD_LOGIC );
end CC16CLE;

architecture Behavioral of CC16CLE is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (L = '1') then
      COUNT <= D;
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC <=  '0' when (CLR = '1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
Q<=COUNT;

end Behavioral;



-- 16-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC16RE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CC16RE;

architecture CC16RE_V of CC16RE is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '1');

begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC <= '0' when (R='1') else
      '1' when (COUNT = TERMINAL_COUNT) else '0' ;
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
Q <= COUNT;

end CC16RE_V;



-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC8CE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end CC8CE;

architecture Behavioral of CC8CE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC <=  '0' when (CLR = '1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';
Q <= COUNT;

end Behavioral;



-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC8CLED is
port (
        CEO : out STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(7 downto 0);
        TC  : out STD_LOGIC;
        C   : in STD_LOGIC;
        CE  : in STD_LOGIC;
        CLR : in STD_LOGIC;
        D   : in STD_LOGIC_VECTOR (7 downto 0);	
        L   : in STD_LOGIC;
        UP  : in STD_LOGIC );
end CC8CLED;

architecture Behavioral of CC8CLED is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

  constant TERMINAL_COUNT_UP : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (L = '1') then
      COUNT <= D;
    elsif (CE='1') then
      if (UP='1') then
        COUNT <= COUNT+1;
      elsif (UP='0') then
        COUNT <= COUNT-1;
      end if;
    end if;
  end if;
end process;

TC <= '0' when (CLR = '1') else
      '1' when  (((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or 
 ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) else '0'; 
CEO <= '1' when  ((((COUNT = TERMINAL_COUNT_UP) and (UP = '1')) or ((COUNT = TERMINAL_COUNT_DOWN) and (UP = '0'))) and CE='1') else '0'; 

Q <= COUNT;

end Behavioral;



-- 8-Bit Cascadable Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC8CLE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR (7 downto 0);	
    L   : in STD_LOGIC );
end CC8CLE;

architecture Behavioral of CC8CLE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');

begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C ='1') then
    if (L = '1') then
      COUNT <= D;
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC <=  '0' when (CLR = '1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q <= COUNT;

end Behavioral;



-- 8-Bit Cascadable Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CC8RE is
port (
    CEO : out STD_LOGIC;
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CC8RE;

architecture CC8RE_V of CC8RE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC <= '0' when (R='1') else
      '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q <= COUNT;

end CC8RE_V;



-- 4-Bit Cascadable BCD Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CD4CE is
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end CD4CE;

architecture Behavioral of CD4CE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(3 downto 0) := "1001";
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 

      if (COUNT = "1001") then
        COUNT <= "0000";
      elsif (COUNT = "1011") then
        COUNT <= "0110";
      elsif (COUNT = "1101") then
        COUNT <= "0100";
      elsif (COUNT = "1111") then
        COUNT <= "0010";
      else
        COUNT <= COUNT+1;
      end if;

    end if;
  end if;
end process;

TC   <= '0' when (CLR = '1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO  <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';

Q3   <= COUNT(3);
Q2   <= COUNT(2);
Q1   <= COUNT(1);
Q0   <= COUNT(0);

end Behavioral;



-- 4-Bit Loadable Cascadable BCD Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CD4CLE is
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC
    );
end CD4CLE;

architecture Behavioral of CD4CLE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(3 downto 0) := "1001";
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (L ='1') then
      COUNT <= D3&D2&D1&D0; 
    elsif (CE='1') then 

      if (COUNT = "1001") then
        COUNT <= "0000";
      elsif (COUNT = "1011") then
        COUNT <= "0110";
      elsif (COUNT = "1101") then
        COUNT <= "0100";
      elsif (COUNT = "1111") then
        COUNT <= "0010";
      else
        COUNT <= COUNT+1;
      end if;

    end if;
  end if;
end process;

TC   <= '0' when (CLR='1') else
        '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO  <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';

Q3   <= COUNT(3);
Q2   <= COUNT(2);
Q1   <= COUNT(1);
Q0   <= COUNT(0);

end Behavioral;



-- 4-Bit Cascadable BCD Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CD4RE is
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CD4RE;

architecture CD4RE_V of CD4RE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(3 downto 0) := "1001";

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      
      if (COUNT = "1001") then
        COUNT <= "0000";
      elsif (COUNT = "1011") then
        COUNT <= "0110";
      elsif (COUNT = "1101") then
        COUNT <= "0100";
      elsif (COUNT = "1111") then
        COUNT <= "0010";
      else
        COUNT <= COUNT+1;
      end if;

    end if;
  end if;
end process;

TC  <= '0' when (R='1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q3  <= COUNT(3);
Q2  <= COUNT(2);
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end CD4RE_V;



-- 4-Bit Loadable Cascadable BCD Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CD4RLE is
  port (
    CEO : out STD_LOGIC;
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    TC  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    L   : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CD4RLE;

architecture CD4RLE_V of CD4RLE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(3 downto 0) := "1001";

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (L='1') then
      COUNT <= D3&D2&D1&D0;
    
    elsif (CE='1') then 
      
      if (COUNT = "1001") then
        COUNT <= "0000";
      elsif (COUNT = "1011") then
        COUNT <= "0110";
      elsif (COUNT = "1101") then
        COUNT <= "0100";
      elsif (COUNT = "1111") then
        COUNT <= "0010";
      else
        COUNT <= COUNT+1;
      end if;

    end if;
  end if;
end process;

TC  <= '0' when (R='1') else
       '1' when (COUNT = TERMINAL_COUNT) else '0'; 
CEO <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0'; 
Q3  <= COUNT(3);
Q2  <= COUNT(2);
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end CD4RLE_V;



-- 4-Bit Johnson Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity CJ4CE is
  
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end CJ4CE;

architecture Behavioral of CJ4CE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT(0) <= not COUNT(3);
      COUNT(3 downto 1) <= COUNT(2 downto 0);
    end if;
  end if;
end process;

Q3 <= COUNT(3);
Q2 <= COUNT(2);
Q1 <= COUNT(1);
Q0 <= COUNT(0);

end Behavioral;



-- 4-Bit Johnson Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity CJ4RE is
  port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CJ4RE;

architecture CJ4RE_V of CJ4RE is

  signal COUNT : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT(0) <= not COUNT(3);
      COUNT(3 downto 1) <= COUNT(2 downto 0);
    end if;
  end if;
end process;

Q3  <= COUNT(3);
Q2  <= COUNT(2);
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end CJ4RE_V;



-- 5-Bit Johnson Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity CJ5CE is
  
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    Q4   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end CJ5CE;

architecture Behavioral of CJ5CE is

  signal COUNT : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT(0) <= not COUNT(4);
      COUNT(4 downto 1) <= COUNT(3 downto 0);
    end if;
  end if;
end process;

Q4 <= COUNT(4);
Q3 <= COUNT(3);
Q2 <= COUNT(2);
Q1 <= COUNT(1);
Q0 <= COUNT(0);

end Behavioral;



-- 5-Bit Johnson Binary Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity CJ5RE is
  port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    Q4  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CJ5RE;

architecture CJ5RE_V of CJ5RE is

  signal COUNT : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT(0) <= not COUNT(4);
      COUNT(4 downto 1) <= COUNT(3 downto 0);
    end if;
  end if;
end process;

Q4  <= COUNT(4);
Q3  <= COUNT(3);
Q2  <= COUNT(2);
Q1  <= COUNT(1);
Q0  <= COUNT(0);

end CJ5RE_V;



-- 8-Bit Johnson Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity CJ8CE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end CJ8CE;

architecture Behavioral of CJ8CE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT(0)                <= not COUNT(7);
      COUNT(7 downto 1) <= COUNT(6 downto 0);
    end if;
  end if;
end process;

Q   <= COUNT;

end Behavioral;



-- 8-Bit Johnson Counter with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity CJ8RE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end CJ8RE;

architecture CJ8RE_V of CJ8RE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

process(C)
begin
  if (C'event and C ='1') then
    if (R='1') then
      COUNT <= (others => '0');
    elsif (CE='1') then 
      COUNT(0)                <= not COUNT(7);
      COUNT(7 downto 1) <= COUNT(6 downto 0);
    end if;
  end if;
end process;

Q   <= COUNT;

end CJ8RE_V;



-- 16-bit Identity Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity COMP16 is
port(
    EQ  : out std_logic;

    A   : in std_logic_vector(15 downto 0);
    B   : in std_logic_vector(15 downto 0)
  );
end COMP16;

architecture COMP16_V of COMP16 is
begin
  EQ <= '1' when (A=B) else '0';
end COMP16_V;



-- 2-bit Identity Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity COMP2 is
  
port(
    EQ  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic
  );
end COMP2;

architecture COMP2_V of COMP2 is
begin
  EQ <= '1' when (A0=B0 and A1=B1) else '0';
end COMP2_V;



-- 4-bit Identity Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity COMP4 is
  
port(
    EQ  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic
  );
end COMP4;

architecture COMP4_V of COMP4 is
begin
  EQ <= '1' when (A0=B0 and A1=B1 and A2=B2 and A3=B3) else '0';
end COMP4_V;



-- 8-bit Identity Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity COMP8 is
port(
    EQ  : out std_logic;

    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0)
  );
end COMP8;

architecture COMP8_V of COMP8 is
begin
  EQ <= '1' when (A=B) else '0';
end COMP8_V;



-- 16-bit Magnitude Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
entity COMPM16 is
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(15 downto 0);
    B   : in std_logic_vector(15 downto 0)
  );
end COMPM16;

architecture COMPM16_V of COMPM16 is
begin
     
  GT <= '1' when ( A > B ) else '0';
  LT <= '1' when ( A < B ) else '0';

end COMPM16_V;



-- 2-bit Magnitude Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity COMPM2 is
  
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic
  );
end COMPM2;

architecture COMPM2_V of COMPM2 is

  signal a_tmp: std_logic_vector(1 downto 0);
  signal b_tmp: std_logic_vector(1 downto 0);

begin

 a_tmp <= A1&A0;
 b_tmp <= B1&B0; 
 GT <= '1' when (a_tmp > b_tmp) else '0';
 LT <= '1' when (a_tmp < b_tmp) else '0';
     
end COMPM2_V;



-- 4-bit Magnitude Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
entity COMPM4 is
  
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    B0  : in std_logic;
    B1  : in std_logic;
    B2  : in std_logic;
    B3  : in std_logic
  );
end COMPM4;

architecture COMPM4_V of COMPM4 is
  signal a_tmp: std_logic_vector(3 downto 0);
  signal b_tmp: std_logic_vector(3 downto 0);

begin

   a_tmp <= A3&A2&A1&A0;
   b_tmp <= B3&B2&B1&B0;
   
   GT <= '1' when (a_tmp > b_tmp ) else '0';
   LT <= '1' when (a_tmp < b_tmp ) else '0';
     
end COMPM4_V;



-- 8-bit Magnitude Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
entity COMPM8 is
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0)
  );
end COMPM8;

architecture COMPM8_V of COMPM8 is
begin
     
  GT <= '1' when (A > B) else '0';
  LT <= '1' when (A < B) else '0';
 
end COMPM8_V;



-- 16-bit Magnitude Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
entity COMPMC16 is
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(15 downto 0);
    B   : in std_logic_vector(15 downto 0)
  );
end COMPMC16;

architecture COMPMC16_V of COMPMC16 is
begin
     
  GT <= '1' when ( A > B ) else '0';
  LT <= '1' when ( A < B ) else '0';

end COMPMC16_V;



-- 8-bit Magnitude Comparator
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
entity COMPMC8 is
port(
    GT  : out std_logic;
    LT  : out std_logic;

    A   : in std_logic_vector(7 downto 0);
    B   : in std_logic_vector(7 downto 0)
  );
end COMPMC8;

architecture COMPMC8_V of COMPMC8 is
begin
     
  GT <= '1' when ( A > B ) else '0';
  LT <= '1' when ( A < B ) else '0';

end COMPMC8_V;



-- 16-Bit Negative Edge Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CR16CE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end CR16CE;

architecture Behavioral of CR16CE is

  signal COUNT : STD_LOGIC_VECTOR(15 downto 0);
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '0') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

Q   <= COUNT;

end Behavioral;



-- 8-Bit Negative Edge Binary Counter with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity CR8CE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC
    );
end CR8CE;

architecture Behavioral of CR8CE is

  signal COUNT : STD_LOGIC_VECTOR(7 downto 0);
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '0') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

Q   <= COUNT;

end Behavioral;



-- 2 -to -4 Line Decoder/Demultiplexer with Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity D2_4E is
  
port(
    D0  : out std_logic;
    D1  : out std_logic;
    D2  : out std_logic;
    D3  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    E   : in std_logic
  );
end D2_4E;

architecture D2_4E_V of D2_4E is
  signal d_tmp : std_logic_vector(3 downto 0);
begin
  process (A0, A1, E)
  variable sel   : std_logic_vector(1 downto 0);
  begin
    sel := A1&A0;
    if( E = '0') then
    d_tmp <= "0000";
    else
      case sel is
      when "00" => d_tmp <= "0001";
      when "01" => d_tmp <= "0010";
      when "10" => d_tmp <= "0100";
      when "11" => d_tmp <= "1000";
      when others => NULL;
      end case;
    end if;
  end process; 

    D3 <= d_tmp(3);
    D2 <= d_tmp(2);
    D1 <= d_tmp(1);
    D0 <= d_tmp(0);

end D2_4E_V;



-- 3 -to -8 Line Decoder/Demultiplexer with Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity D3_8E is
  
port(
    D0  : out std_logic;
    D1  : out std_logic;
    D2  : out std_logic;
    D3  : out std_logic;
    D4  : out std_logic;
    D5  : out std_logic;
    D6  : out std_logic;
    D7  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    E   : in std_logic
  );
end D3_8E;

architecture D3_8E_V of D3_8E is
  signal d_tmp : std_logic_vector(7 downto 0);
begin
  process (A0, A1, A2, E)
  variable sel   : std_logic_vector(2 downto 0);
  begin
    sel := A2&A1&A0;
    if( E = '0') then
    d_tmp <= "00000000";
    else
      case sel is
      when "000" => d_tmp <= "00000001";
      when "001" => d_tmp <= "00000010";
      when "010" => d_tmp <= "00000100";
      when "011" => d_tmp <= "00001000";
      when "100" => d_tmp <= "00010000";
      when "101" => d_tmp <= "00100000";
      when "110" => d_tmp <= "01000000";
      when "111" => d_tmp <= "10000000";
      when others => NULL;
      end case;
    end if;
  end process; 

    D7 <= d_tmp(7);
    D6 <= d_tmp(6);
    D5 <= d_tmp(5);
    D4 <= d_tmp(4);
    D3 <= d_tmp(3);
    D2 <= d_tmp(2);
    D1 <= d_tmp(1);
    D0 <= d_tmp(0);

end D3_8E_V;



-- 4 -to -16 Line Decoder/Demultiplexer with Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity D4_16E is
  
port(
    D0  : out std_logic;
    D1  : out std_logic;
    D2  : out std_logic;
    D3  : out std_logic;
    D4  : out std_logic;
    D5  : out std_logic;
    D6  : out std_logic;
    D7  : out std_logic;
    D8  : out std_logic;
    D9  : out std_logic;
    D10  : out std_logic;
    D11  : out std_logic;
    D12  : out std_logic;
    D13  : out std_logic;
    D14  : out std_logic;
    D15  : out std_logic;

    A0  : in std_logic;
    A1  : in std_logic;
    A2  : in std_logic;
    A3  : in std_logic;
    E   : in std_logic
  );
end D4_16E;

architecture D4_16E_V of D4_16E is
  signal d_tmp : std_logic_vector(15 downto 0);
begin
  process (A0, A1, A2, A3, E)
  variable sel   : std_logic_vector(3 downto 0);
  begin
    sel := A3&A2&A1&A0;
    if( E = '0') then
    d_tmp <= "0000000000000000";
    else
      case sel is
      when "0000" => d_tmp <= "0000000000000001";
      when "0001" => d_tmp <= "0000000000000010";
      when "0010" => d_tmp <= "0000000000000100";
      when "0011" => d_tmp <= "0000000000001000";
      when "0100" => d_tmp <= "0000000000010000";
      when "0101" => d_tmp <= "0000000000100000";
      when "0110" => d_tmp <= "0000000001000000";
      when "0111" => d_tmp <= "0000000010000000";
      when "1000" => d_tmp <= "0000000100000000";
      when "1001" => d_tmp <= "0000001000000000";
      when "1010" => d_tmp <= "0000010000000000";
      when "1011" => d_tmp <= "0000100000000000";
      when "1100" => d_tmp <= "0001000000000000";
      when "1101" => d_tmp <= "0010000000000000";
      when "1110" => d_tmp <= "0100000000000000";
      when "1111" => d_tmp <= "1000000000000000";
      when others => NULL;
      end case;
    end if;
  end process; 

    D15 <= d_tmp(15);
    D14 <= d_tmp(14);
    D13 <= d_tmp(13);
    D12 <= d_tmp(12);
    D11 <= d_tmp(11);
    D10 <= d_tmp(10);
    D9  <= d_tmp(9);
    D8  <= d_tmp(8);
    D7  <= d_tmp(7);
    D6  <= d_tmp(6);
    D5  <= d_tmp(5);
    D4  <= d_tmp(4);
    D3  <= d_tmp(3);
    D2  <= d_tmp(2);
    D1  <= d_tmp(1);
    D0  <= d_tmp(0);

end D4_16E_V;



-- 16 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DEC_CC16 is
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic;
    A8   : in std_logic;
    A9   : in std_logic;
    A10  : in std_logic;
    A11  : in std_logic;
    A12  : in std_logic;
    A13  : in std_logic;
    A14  : in std_logic;
    A15  : in std_logic;
    CIN : in std_logic
  );
end DEC_CC16;

architecture DEC_CC16_V of DEC_CC16 is
begin
  process (A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, CIN)
  begin
    if((A0 and A1 and A2 and A3 and A4 and A5 and A6 and A7 and A8 and A9 and A10 and A11 and A12 and A13 and A14 and A15) = '1') then
      if(CIN = '1') then
      O <= '1';
      else
      O <= '0';
      end if;
    else
    O <= '0';
    end if;
  end process; 

end DEC_CC16_V;



-- 4 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DEC_CC4 is
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    CIN : in std_logic
  );
end DEC_CC4;

architecture DEC_CC4_V of DEC_CC4 is
begin
  process (A0, A1, A2, A3, CIN)
  begin
    if((A0 and A1 and A2 and A3) = '1') then
      if(CIN = '1') then
      O <= '1';
      else
      O <= '0';
      end if;
    else
    O <= '0';
    end if;
  end process; 

end DEC_CC4_V;



-- 8 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DEC_CC8 is
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic;
    CIN : in std_logic
  );
end DEC_CC8;

architecture DEC_CC8_V of DEC_CC8 is
begin
  process (A0, A1, A2, A3, A4, A5, A6, A7, CIN)
  begin
    if((A0 and A1 and A2 and A3 and A4 and A5 and A6 and A7) = '1') then
      if(CIN = '1') then
      O <= '1';
      else
      O <= '0';
      end if;
    else
    O <= '0';
    end if;
  end process; 

end DEC_CC8_V;



-- 16 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DECODE16 is
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic;
    A8   : in std_logic;
    A9   : in std_logic;
    A10  : in std_logic;
    A11  : in std_logic;
    A12  : in std_logic;
    A13  : in std_logic;
    A14  : in std_logic;
    A15  : in std_logic
  );
end DECODE16;

architecture DECODE16_V of DECODE16 is
begin
    O <= (A0 and A1 and A2 and A3 and A4 and A5 and A6 and A7 and A8 and A9 and A10 and A11 and A12 and A13 and A14 and A15) ;

end DECODE16_V;



-- 32 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DECODE32 is
port(
    O    : out std_logic;
    A    : in std_logic_vector(31 downto 0)
  );
end DECODE32;

architecture DECODE32_V of DECODE32 is
begin
   process(A)
   begin
      if (A = "11111111111111111111111111111111") then
      O <= '1';
      else
      O <= '0';
      end if;
   end process;

end DECODE32_V;



-- 4 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DECODE4 is
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic
  );
end DECODE4;

architecture DECODE4_V of DECODE4 is
begin
  O <= (A0 and A1 and A2 and A3);

end DECODE4_V;



-- 64 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DECODE64 is
port(
    O    : out std_logic;
    A    : in std_logic_vector(63 downto 0)
  );
end DECODE64;

architecture DECODE64_V of DECODE64 is
begin
   process(A)
   begin
      if (A = "1111111111111111111111111111111111111111111111111111111111111111") then
      O <= '1';
      else
      O <= '0';
      end if;
   end process;

end DECODE64_V;



-- 8 Bit Active Low Decoder
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity DECODE8 is
  
port(
    O    : out std_logic;

    A0   : in std_logic;
    A1   : in std_logic;
    A2   : in std_logic;
    A3   : in std_logic;
    A4   : in std_logic;
    A5   : in std_logic;
    A6   : in std_logic;
    A7   : in std_logic
  );
end DECODE8;

architecture DECODE8_V of DECODE8 is
begin
    O <= (A0 and A1 and A2 and A3 and A4 and A5 and A6 and A7) ;

end DECODE8_V;



-- 16-Bit Data Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FD16CE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end FD16CE;

architecture Behavioral of FD16CE is

begin

process(C, CLR)
begin
  if (CLR='1') then
    Q <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- 16-Bit Data Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FD16RE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    R   : in STD_LOGIC
    );
end FD16RE;

architecture Behavioral of FD16RE is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      Q <= (others => '0');
    elsif (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- 4-Bit Data Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FD4CE is
port (
    Q0  : out STD_LOGIC := '0';
    Q1  : out STD_LOGIC := '0';
    Q2  : out STD_LOGIC := '0';
    Q3  : out STD_LOGIC := '0';

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end FD4CE;

architecture Behavioral of FD4CE is

begin

process(C, CLR)
begin
  if (CLR='1') then
    Q3 <= '0';
    Q2 <= '0';
    Q1 <= '0';
    Q0 <= '0';
  elsif (C'event and C = '1') then
    if (CE='1') then 
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
    end if;
  end if;
end process;


end Behavioral;



-- 4-Bit Data Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FD4RE is
  port (
    Q0  : out STD_LOGIC := '0';
    Q1  : out STD_LOGIC := '0';
    Q2  : out STD_LOGIC := '0';
    Q3  : out STD_LOGIC := '0';

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    R   : in STD_LOGIC
    );
end FD4RE;

architecture Behavioral of FD4RE is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      Q3 <= '0';
      Q2 <= '0';
      Q1 <= '0';
      Q0 <= '0';
    elsif (CE='1') then 
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
    end if;
  end if;
end process;


end Behavioral;



-- 8-Bit Data Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FD8CE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end FD8CE;

architecture Behavioral of FD8CE is

begin

process(C, CLR)
begin
  if (CLR='1') then
    Q <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- 8-Bit Data Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FD8RE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    R   : in STD_LOGIC
    );
end FD8RE;

architecture Behavioral of FD8RE is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      Q <= (others => '0');
    elsif (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- J-K Flip-Flop with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FJKCE is
  generic(
    INIT : bit := '0'
    );
  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC
    );
end FJKCE;

architecture Behavioral of FJKCE is
signal q_tmp : std_logic := TO_X01(INIT);

begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= '0';
  elsif (C'event and C = '1') then
    if(CE= '1') then
      if(J='0') then
        if(K='1') then
        q_tmp <= '0';
      end if;
      else
        if(K='0') then
        q_tmp <= '1';
        else
        q_tmp <= not q_tmp;
        end if;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- J-K Flip-Flop with Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FJKC is
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CLR : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC
    );
end FJKC;

architecture Behavioral of FJKC is
signal q_tmp : std_logic := TO_X01(INIT);

begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= '0';
  elsif (C'event and C = '1') then
    if(J='0') then
      if(K='1') then
      q_tmp <= '0';
    end if;
    else
      if(K='0') then
      q_tmp <= '1';
      else
      q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- J-K Flip-Flop with Clock Enable and Asynchronous Preset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FJKPE is
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    PRE : in STD_LOGIC
    );
end FJKPE;

architecture Behavioral of FJKPE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, PRE)
begin
  if (PRE='1') then
    q_tmp <= '1';
  elsif (C'event and C = '1') then
    if(CE= '1') then
      if(J='0') then
        if(K='1') then
        q_tmp <= '0';
      end if;
      else
        if(K='0') then
        q_tmp <= '1';
        else
        q_tmp <= not q_tmp;
        end if;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- J-K Flip-Flop with Asynchronous Preset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FJKP is
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    PRE : in STD_LOGIC
    );
end FJKP;

architecture Behavioral of FJKP is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, PRE)
begin
  if (PRE='1') then
    q_tmp <= '1';
  elsif (C'event and C = '1') then
    if(J='0') then
      if(K='1') then
      q_tmp <= '0';
    end if;
    else
      if(K='0') then
      q_tmp <= '1';
      else
      q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- J-K Flip-Flop with Clock Enable and Synchronous Reset and Set
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FJKRSE is
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC
    );
end FJKRSE;

architecture Behavioral of FJKRSE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= '0';
    elsif(S= '1') then
      q_tmp <= '1';
    elsif(CE ='1') then
      if(J='0') then
        if(K='1') then
        q_tmp <= '0';
      end if;
      else
        if(K='0') then
        q_tmp <= '1';
        else
        q_tmp <= not q_tmp;
        end if;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- J-K Flip-Flop with Clock Enable and Synchronous Reset and Set
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FJKSRE is
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    J   : in STD_LOGIC;
    K   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC
    );
end FJKSRE;

architecture Behavioral of FJKSRE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (S='1') then
      q_tmp <= '1';
    elsif(R= '1') then
      q_tmp <= '0';
    elsif(CE ='1') then
      if(J='0') then
        if(K='1') then
        q_tmp <= '0';
      end if;
      else
        if(K='0') then
        q_tmp <= '1';
        else
        q_tmp <= not q_tmp;
        end if;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle Flip-Flop with Toggle and Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTCE is
 generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTCE;

architecture Behavioral of FTCE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= '0';
  elsif (C'event and C = '1') then
    if(CE='1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTCLE is
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTCLE;

architecture Behavioral of FTCLE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= '0';
  elsif (C'event and C = '1') then
    if(L= '1') then
      q_tmp <= D;
    elsif(CE='1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTCLEX is
 generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTCLEX;

architecture Behavioral of FTCLEX is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= '0';
  elsif (C'event and C = '1') then
    if(L= '1') then
      q_tmp <= D;
    elsif(CE='1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle Flip-Flop with Toggle Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTC is
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC := '0';
    C   : in STD_LOGIC;
    CLR : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTC;

architecture Behavioral of FTC is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= '0';
  elsif (C'event and C = '1') then
    if(T='1') then
      q_tmp <= not q_tmp;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle Flip-Flop with Toggle and Clock Enable and Asynchronous Preset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTPE is
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    PRE : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTPE;

architecture Behavioral of FTPE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, PRE)
begin
  if (PRE='1') then
    q_tmp <= '1';
  elsif (C'event and C = '1') then
    if(CE= '1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Asynchronous Preset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTPLE is
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    PRE : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTPLE;

architecture Behavioral of FTPLE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, PRE)
begin
  if (PRE='1') then
    q_tmp <= '1';
  elsif (C'event and C = '1') then
    if(L='1') then
      q_tmp <= D;
    elsif(CE= '1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle Flip-Flop with Toggle Enable and Asynchronous Preset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTP is
generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC := '1';
    C   : in STD_LOGIC;
    PRE : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTP;

architecture Behavioral of FTP is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C, PRE)
begin
  if (PRE='1') then
    q_tmp <= '1';
  elsif (C'event and C = '1') then
    if(T='1') then
      q_tmp <= not q_tmp;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTRSE is
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTRSE;

architecture Behavioral of FTRSE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
    if(R='1') then
      q_tmp <= '0';
    elsif(S='1') then
      q_tmp <= '1';
    elsif(CE='1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTRSLE is
generic(
    INIT : bit := '0'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTRSLE;

architecture Behavioral of FTRSLE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
    if(R='1') then
      q_tmp <= '0';
    elsif(S='1') then
      q_tmp <= '1';
    elsif(L='1') then
      q_tmp <= D;
    elsif(CE='1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTSRE is
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTSRE;

architecture Behavioral of FTSRE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
    if(S='1') then
      q_tmp <= '1';
    elsif(R='1') then
      q_tmp <= '0';
    elsif(CE='1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Toggle/Loadable Flip-Flop with Toggle and Clock Enable and Synchronous Reset and Set
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity FTSRLE is
 generic(
    INIT : bit := '1'
    );

  port (
    Q   : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC;
    L   : in STD_LOGIC;
    R   : in STD_LOGIC;
    S   : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end FTSRLE;

architecture Behavioral of FTSRLE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
    if(S='1') then
      q_tmp <= '1';
    elsif(R='1') then
      q_tmp <= '0';
    elsif(L='1') then
      q_tmp <= D;
    elsif(CE='1') then
      if(T='1') then
        q_tmp <= not q_tmp;
      end if;
    end if;
  end if;  
end process;

Q <= q_tmp;

end Behavioral;



-- Multiple Input Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity IBUF16 is
port(
    O  : out std_logic_vector(15 downto 0);
    I  : in std_logic_vector(15 downto 0)
  );
end IBUF16;

architecture IBUF16_V of IBUF16 is
begin

  O <= I;

end IBUF16_V;



-- Multiple Input Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity IBUF4 is
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end IBUF4;

architecture IBUF4_V of IBUF4 is
begin

  O0 <= I0;
  O1 <= I1;
  O2 <= I2;
  O3 <= I3;

end IBUF4_V;



-- Multiple Input Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity IBUF8 is
port(
    O  : out std_logic_vector(7 downto 0);
    I  : in std_logic_vector(7 downto 0)
  );
end IBUF8;

architecture IBUF8_V of IBUF8 is
begin

  O <= I;

end IBUF8_V;



-- Multiple Input D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFD16 is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end IFD16;

architecture Behavioral of IFD16 is

begin

process(C)
begin
  if (C'event and C = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop with Inverted Clock
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFD_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
attribute IOB         : string ;
attribute IOB of Q : signal is "True";	

end IFD_1;

architecture Behavioral of IFD_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin

  Q <= q_tmp;

process(C)
begin
  

  if (C'event and C = '0') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Multiple Input D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFD4 is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end IFD4;

architecture Behavioral of IFD4 is

begin

process(C)
begin
  if (C'event and C = '1') then
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
  end if;
end process;


end Behavioral;



-- Multiple Input D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFD8 is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end IFD8;

architecture Behavioral of IFD8 is

begin

process(C)
begin
  if (C'event and C = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop with Inverted Clock
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDI_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end IFDI_1;

architecture Behavioral of IFDI_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
    Q <= q_tmp;

process(C)
begin
  if (C'event and C = '0') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDI is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end IFDI;

architecture Behavioral of IFDI is
signal q_tmp : std_logic := TO_X01(INIT);

begin
   Q <= q_tmp;

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFD is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end IFD;

architecture Behavioral of IFD is
signal q_tmp : std_logic := TO_X01(INIT);

begin
     Q <= q_tmp;

process(C)

begin

  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Multiple Input D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDX16 is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end IFDX16;

architecture Behavioral of IFDX16 is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop with Inverted Clock and Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDX_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end IFDX_1;

architecture Behavioral of IFDX_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
   Q <= q_tmp;

process(C)
begin
  if (C'event and C = '0') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Multiple Input D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDX4 is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end IFDX4;

architecture Behavioral of IFDX4 is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
    end if;
  end if;
end process;


end Behavioral;



-- Multiple Input D Flip Flop Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDX8 is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end IFDX8;

architecture Behavioral of IFDX8 is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop with Inverted Clock and Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDXI_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end IFDXI_1;

architecture Behavioral of IFDXI_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '0') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDXI is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end IFDXI;

architecture Behavioral of IFDXI is
signal q_tmp : std_logic := TO_X01(INIT);
begin

  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Input D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity IFDX is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end IFDX;

architecture Behavioral of IFDX is

signal q_tmp : std_logic := TO_X01(INIT);
begin
   Q <= q_tmp;
process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILD16 is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC
    );
end ILD16;

architecture Behavioral of ILD16 is

begin

process(D, G)
begin
  if (G = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latch with Inverted Gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILD_1 is
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end ILD_1;

architecture Behavioral of ILD_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(D, G)
begin
  if (G = '0') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILD4 is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC
    );
end ILD4;

architecture Behavioral of ILD4 is

begin

process(D0, D1, D2, D3, G)
begin
  if (G = '1') then
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILD8 is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC
    );
end ILD8;

architecture Behavioral of ILD8 is

begin

process(D, G)
begin
  if (G = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latch with Inverted Clock
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDI_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end ILDI_1;

architecture Behavioral of ILDI_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
   Q <= q_tmp;
      
process(D, G)
begin
  if (G = '0') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latch
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDI is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end ILDI;

architecture Behavioral of ILDI is
signal q_tmp : std_logic := TO_X01(INIT);

begin
   Q <= q_tmp;
process(D, G)
begin
  if (G = '1') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDX16 is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end ILDX16;

architecture Behavioral of ILDX16 is

begin

process(D, G, GE)
begin
  if ( (GE = '1') and (G = '1') ) then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latch with Inverted Gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDX_1 is
  generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end ILDX_1;

architecture Behavioral of ILDX_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(D, G, GE)
begin
  if ( (GE= '1') and (G = '0') ) then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDX4 is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end ILDX4;

architecture Behavioral of ILDX4 is

begin

process(D0, D1, D2, D3, G, GE)
begin
  if ( (GE = '1') and (G = '1') ) then
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDX8 is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end ILDX8;

architecture Behavioral of ILDX8 is

begin

process(D, G, GE)
begin
  if ( (GE = '1') and (G = '1') ) then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latch with Inverted Gate
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDXI_1 is
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end ILDXI_1;

architecture Behavioral of ILDXI_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(D, G, GE)
begin
  if ( (GE= '1') and (G = '0') ) then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latch
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDXI is
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end ILDXI;

architecture Behavioral of ILDXI is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(D, G, GE)
begin
  if ( (GE= '1') and (G = '1') ) then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Transparent Input Data Latch
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ILDX is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    D  : in STD_LOGIC;
    G  : in STD_LOGIC;
    GE : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end ILDX;

architecture Behavioral of ILDX is
signal q_tmp : std_logic := TO_X01(INIT);

begin
   Q <= q_tmp;

process(D, G, GE)
begin
  if ( (GE= '1') and (G = '1') ) then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- 16-input Inverter
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity INV16 is
port(
    O  : out std_logic_vector(15 downto 0);

    I  : in std_logic_vector(15 downto 0)
  );
end INV16;

architecture INV16_V of INV16 is
begin
  O <= not I ;
end INV16_V;



-- 4-input Inverter
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity INV4 is
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end INV4;

architecture INV4_V of INV4 is
begin
  O0 <= not I0 ;
  O1 <= not I1 ;
  O2 <= not I2 ;
  O3 <= not I3 ;
end INV4_V;



-- 8-input Inverter
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity INV8 is
port(
    O  : out std_logic_vector(7 downto 0);

    I  : in std_logic_vector(7 downto 0)
  );
end INV8;

architecture INV8_V of INV8 is
begin
  O <= not I ;
end INV8_V;



-- Transparent Data Latches with Asynchronous Clear and Gate Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity LD16CE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end LD16CE;

architecture Behavioral of LD16CE is

begin

process(CLR, D, G, GE)
begin
  if (CLR= '1') then
      Q <= (others => '0');
  elsif ( (GE= '1') and (G = '1') ) then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Multiple Transparent Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity LD16 is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    G   : in STD_LOGIC
    );
end LD16;

architecture Behavioral of LD16 is

begin

process(D, G)
begin
  if (G = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Transparent Data Latches with Asynchronous Clear and Gate Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity LD4CE is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end LD4CE;

architecture Behavioral of LD4CE is

begin

process(CLR, D0, D1, D2, D3, G, GE)
begin
  if (CLR = '1') then
      Q3 <= '0';
      Q2 <= '0';
      Q1 <= '0';
      Q0 <= '0';
  elsif ( (GE= '1') and (G = '1') )then
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
  end if;
end process;


end Behavioral;



-- Multiple Transparent Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity LD4 is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    G   : in STD_LOGIC
    );
end LD4;

architecture Behavioral of LD4 is

begin

process(D0, D1, D2, D3, G)
begin
  if (G = '1') then
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
  end if;
end process;


end Behavioral;



-- Transparent Data Latches with Asynchronous Clear and Gate Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity LD8CE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC;
    GE  : in STD_LOGIC
    );
end LD8CE;

architecture Behavioral of LD8CE is

begin

process(CLR, D, G, GE)
begin
  if (CLR= '1') then
      Q <= (others => '0');
  elsif ( (GE= '1') and (G = '1') ) then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Multiple Transparent Data Latches
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity LD8 is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    G   : in STD_LOGIC
    );
end LD8;

architecture Behavioral of LD8 is

begin

process(D, G)
begin
  if (G = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- 16-to-1 Multiplexer with Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity M16_1E is
  
port(
    O    : out std_logic;

    D0   : in std_logic;
    D1   : in std_logic;
    D2   : in std_logic;
    D3   : in std_logic;
    D4   : in std_logic;
    D5   : in std_logic;
    D6   : in std_logic;
    D7   : in std_logic;
    D8   : in std_logic;
    D9   : in std_logic;
    D10  : in std_logic;
    D11  : in std_logic;
    D12  : in std_logic;
    D13  : in std_logic;
    D14  : in std_logic;
    D15  : in std_logic;
    E    : in std_logic;
    S0   : in std_logic;
    S1   : in std_logic;
    S2   : in std_logic;
    S3   : in std_logic
  );
end M16_1E;

architecture M16_1E_V of M16_1E is
begin
  process (D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, E, S0, S1, S2, S3)
  variable sel : std_logic_vector(3 downto 0);
  begin
    sel := S3&S2&S1&S0;
    if( E = '0') then
    O <= '0';
    else
      case sel is
      when "0000" => O <= D0;
      when "0001" => O <= D1;
      when "0010" => O <= D2;
      when "0011" => O <= D3;
      when "0100" => O <= D4;
      when "0101" => O <= D5;
      when "0110" => O <= D6;
      when "0111" => O <= D7;
      when "1000" => O <= D8;
      when "1001" => O <= D9;
      when "1010" => O <= D10;
      when "1011" => O <= D11;
      when "1100" => O <= D12;
      when "1101" => O <= D13;
      when "1110" => O <= D14;
      when "1111" => O <= D15;
      when others => NULL;
      end case;
    end if;
    end process; 
end M16_1E_V;



-- 2-to-1 Multiplexer with D0 Inverted
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity M2_1B1 is

port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    S0  : in std_logic
  );
end M2_1B1;

architecture M2_1B1_V of M2_1B1 is
begin
  process (D0, D1, S0)
  begin
    case S0 is
    when '0' => O <= not D0;
    when '1' => O <= D1;
    when others => NULL;
    end case;
    end process; 
end M2_1B1_V;



-- 2-to-1 Multiplexer with D0 and D1 Inverted
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity M2_1B2 is
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    S0  : in std_logic
  );
end M2_1B2;

architecture M2_1B2_V of M2_1B2 is
begin
  process (D0, D1, S0)
  begin
    case S0 is
    when '0' => O <= not D0;
    when '1' => O <= not D1;
    when others => NULL;
    end case;
    end process; 
end M2_1B2_V;



-- 2-to-1 Multiplexer with Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity M2_1E is
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    E   : in std_logic;
    S0  : in std_logic
  );
end M2_1E;

architecture M2_1E_V of M2_1E is
begin
  process (D0, D1, E, S0)
  begin
    if( E = '0') then
    O <= '0';
    else
      case S0 is
      when '0' => O <= D0;
      when '1' => O <= D1;
      when others => NULL;
      end case;
    end if;
    end process; 
end M2_1E_V;



-- 2-to-1 Multiplexer
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity M2_1 is
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    S0  : in std_logic
  );
end M2_1;

architecture M2_1_V of M2_1 is
begin
  process (D0, D1, S0)
  begin
    case S0 is
    when '0' => O <= D0;
    when '1' => O <= D1;
    when others => NULL;
    end case;
    end process; 
end M2_1_V;



-- 4-to-1 Multiplexer with Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity M4_1E is
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    D2  : in std_logic;
    D3  : in std_logic;
    E   : in std_logic;
    S0  : in std_logic;
    S1  : in std_logic
  );
end M4_1E;

architecture M4_1E_V of M4_1E is
begin
  process (D0, D1, D2, D3, E, S0, S1)
  variable sel : std_logic_vector(1 downto 0);
  begin
    sel := S1&S0;
    if( E = '0') then
    O <= '0';
    else
      case sel is
      when "00" => O <= D0;
      when "01" => O <= D1;
      when "10" => O <= D2;
      when "11" => O <= D3;
      when others => NULL;
      end case;
    end if;
    end process; 
end M4_1E_V;



-- 8-to-1 Multiplexer with Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity M8_1E is
  
port(
    O   : out std_logic;

    D0  : in std_logic;
    D1  : in std_logic;
    D2  : in std_logic;
    D3  : in std_logic;
    D4  : in std_logic;
    D5  : in std_logic;
    D6  : in std_logic;
    D7  : in std_logic;
    E   : in std_logic;
    S0  : in std_logic;
    S1  : in std_logic;
    S2  : in std_logic
  );
end M8_1E;

architecture M8_1E_V of M8_1E is
begin
  process (D0, D1, D2, D3, D4, D5, D6, D7, E, S0, S1, S2)
  variable sel : std_logic_vector(2 downto 0);
  begin
    sel := S2&S1&S0;
    if( E = '0') then
    O <= '0';
    else
      case sel is
      when "000" => O <= D0;
      when "001" => O <= D1;
      when "010" => O <= D2;
      when "011" => O <= D3;
      when "100" => O <= D4;
      when "101" => O <= D5;
      when "110" => O <= D6;
      when "111" => O <= D7;
      when others => NULL;
      end case;
    end if;
    end process; 
end M8_1E_V;



-- 12-input NAND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NAND12 is
  
port(
    O   : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic
  );
end NAND12;

architecture NAND12_V of NAND12 is
begin
  O <= not (I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7 and I8 and I9 and I10 and I11);
end NAND12_V;



-- 16-input NAND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NAND16 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10  : in std_logic;
    I11  : in std_logic;
    I12  : in std_logic;
    I13  : in std_logic;
    I14  : in std_logic;
    I15  : in std_logic
  );
end NAND16;

architecture NAND16_V of NAND16 is
begin
  O <= not (I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7 and I8 and I9 and I10 and I11 and I12 and I13 and I14 and I15);
end NAND16_V;



-- 6-input NAND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NAND6 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end NAND6;

architecture NAND6_V of NAND6 is
begin
  O <= not (I0 and I1 and I2 and I3 and I4 and I5);
end NAND6_V;



-- 7-input NAND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NAND7 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end NAND7;

architecture NAND7_V of NAND7 is
begin
  O <= not (I0 and I1 and I2 and I3 and I4 and I5 and I6);
end NAND7_V;



-- 8-input NAND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NAND8 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end NAND8;

architecture NAND8_V of NAND8 is
begin
  O <= not (I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7);
end NAND8_V;



-- 9-input NAND gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NAND9 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end NAND9;

architecture NAND9_V of NAND9 is
begin
  O <= not (I0 and I1 and I2 and I3 and I4 and I5 and I6 and I7 and I8);
end NAND9_V;



-- 12-input NOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NOR12 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic
  );
end NOR12;

architecture NOR12_V of NOR12 is
begin
  O <= not (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7 or I8 or I9 or I10 or I11);
end NOR12_V;



-- 16-input NOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NOR16 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic;
    I12 : in std_logic;
    I13 : in std_logic;
    I14 : in std_logic;
    I15 : in std_logic
  );
end NOR16;

architecture NOR16_V of NOR16 is
begin
  O <= not (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7 or I8 or I9 or I10 or I11 or I12 or I13 or I14 or I15);
end NOR16_V;



-- 6-input NOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NOR6 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end NOR6;

architecture NOR6_V of NOR6 is
begin
  O <= not (I0 or I1 or I2 or I3 or I4 or I5);
end NOR6_V;



-- 7-input NOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NOR7 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end NOR7;

architecture NOR7_V of NOR7 is
begin
  O <= not (I0 or I1 or I2 or I3 or I4 or I5 or I6);
end NOR7_V;



-- 8-input NOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NOR8 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end NOR8;

architecture NOR8_V of NOR8 is
begin
  O <= not (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7);
end NOR8_V;



-- 9-input NOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity NOR9 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end NOR9;

architecture NOR9_V of NOR9 is
begin
  O <= not (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7 or I8);
end NOR9_V;



-- Multiple Output Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUF16 is
port(
    O  : out std_logic_vector(15 downto 0);
    I  : in std_logic_vector(15 downto 0)
  );
end OBUF16;

architecture OBUF16_V of OBUF16 is
begin

  O <= I;

end OBUF16_V;



-- Multiple Output Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUF4 is
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end OBUF4;

architecture OBUF4_V of OBUF4 is
begin

  O0 <= I0;
  O1 <= I1;
  O2 <= I2;
  O3 <= I3;

end OBUF4_V;



-- Multiple Output Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUF8 is
port(
    O  : out std_logic_vector(7 downto 0);
    I  : in std_logic_vector(7 downto 0)
  );
end OBUF8;

architecture OBUF8_V of OBUF8 is
begin

  O <= I;

end OBUF8_V;



-- Multiple 3- state Output Buffer with Active High Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUFE16 is
port(
    O  : out std_logic_vector(15 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(15 downto 0)
  );
end OBUFE16;

architecture OBUFE16_V of OBUFE16 is
begin
  process (I, E)
  begin
    if (E='1') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end OBUFE16_V;



-- Multiple 3- state Output Buffer with Active High Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUFE4 is
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    E   : in std_logic;
    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end OBUFE4;

architecture OBUFE4_V of OBUFE4 is
begin
  process (I0, I1, I2, I3, E)
  begin
    if (E='1') then

      O0 <= I0;
      O1 <= I1;
      O2 <= I2;
      O3 <= I3;

    else

      O0 <= 'Z';
      O1 <= 'Z';
      O2 <= 'Z';
      O3 <= 'Z';

  end if;
 end process;

end OBUFE4_V;



-- Multiple 3- state Output Buffer with Active High Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUFE8 is
port(
    O  : out std_logic_vector(7 downto 0);

    E  : in std_logic;
    I  : in std_logic_vector(7 downto 0)
  );
end OBUFE8;

architecture OBUFE8_V of OBUFE8 is
begin
  process (I, E)
  begin
    if (E='1') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end OBUFE8_V;



-- 3- state Output Buffer with Active High Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUFE is
port(
    O  : out std_logic;

    E  : in std_logic;
    I  : in std_logic
  );
end OBUFE;

architecture OBUFE_V of OBUFE is
begin
  process (I, E)
  begin
    if (E='1') then
      O  <= I;
    else
      O  <= 'Z';
  end if;
 end process;

end OBUFE_V;



-- Multiple 3- state Output Buffer with Active Low Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUFT16 is
port(
    O  : out std_logic_vector(15 downto 0);

    I  : in std_logic_vector(15 downto 0);
    T  : in std_logic
  );
end OBUFT16;

architecture OBUFT16_V of OBUFT16 is
begin
  process (I, T)
  begin
    if (T='0') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end OBUFT16_V;



-- Multiple 3- state Output Buffer with Active Low Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUFT4 is
  
port(
    O0  : out std_logic;
    O1  : out std_logic;
    O2  : out std_logic;
    O3  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    T   : in std_logic
  );
end OBUFT4;

architecture OBUFT4_V of OBUFT4 is
begin
  process (I0, I1, I2, I3, T)
  begin
    if (T='0') then

      O0 <= I0;
      O1 <= I1;
      O2 <= I2;
      O3 <= I3;

    else

      O0 <= 'Z';
      O1 <= 'Z';
      O2 <= 'Z';
      O3 <= 'Z';

  end if;
 end process;

end OBUFT4_V;



-- Multiple 3- state Output Buffer with Active Low Enable
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OBUFT8 is
port(
    O  : out std_logic_vector(7 downto 0);

    I  : in std_logic_vector(7 downto 0);
    T  : in std_logic
  );
end OBUFT8;

architecture OBUFT8_V of OBUFT8 is
begin
  process (I, T)
  begin
    if (T='0') then
      O  <= I;
    else
      O  <= (others => 'Z');
  end if;
 end process;

end OBUFT8_V;



-- Multiple Output D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFD16 is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end OFD16;

architecture Behavioral of OFD16 is

begin

process(C)
begin
  if (C'event and C = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- Single Output D Flip Flop with Inverted Clock
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFD_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFD_1;

architecture Behavioral of OFD_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '0') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Multiple Output D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFD4 is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end OFD4;

architecture Behavioral of OFD4 is

begin

process(C)
begin
  if (C'event and C = '1') then
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
  end if;
end process;


end Behavioral;



-- Multiple Output D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFD8 is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end OFD8;

architecture Behavioral of OFD8 is

begin

process(C)
begin
  if (C'event and C = '1') then
      Q <= D;
  end if;
end process;


end Behavioral;



-- D Flip Flops with Active High Enable Output Buffers
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDE16 is
port (
    O   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    E   : in STD_LOGIC
    );
end OFDE16;

architecture Behavioral of OFDE16 is
signal q_tmp : std_logic_vector(15 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;

 O <= q_tmp when (E= '1') else (others => 'Z');

end Behavioral;



-- Output D Flip Flop with Active High Enable Output Buffer and Inverted Clock
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDE_1 is
generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    E  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of O : signal is "True";	

end OFDE_1;

architecture Behavioral of OFDE_1 is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '0') then
     q_tmp <= D;
  end if;
end process;

O <= q_tmp when (E= '1') else 'Z';

end Behavioral;



-- D Flip Flops with Active High Enable Output Buffers
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDE4 is
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    E   : in STD_LOGIC
    );
end OFDE4;

architecture Behavioral of OFDE4 is
signal q_tmp : std_logic_vector(3 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D3&D2&D1&D0;
  end if;
end process;

O3 <= q_tmp(3) when (E= '1') else 'Z';
O2 <= q_tmp(2) when (E= '1') else 'Z';
O1 <= q_tmp(1) when (E= '1') else 'Z';
O0 <= q_tmp(0) when (E= '1') else 'Z';

end Behavioral;



-- D Flip Flops with Active High Enable Output Buffers
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDE8 is
port (
    O   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    E   : in STD_LOGIC
    );
end OFDE8;

architecture Behavioral of OFDE8 is
signal q_tmp : std_logic_vector(7 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;

 O <= q_tmp when (E= '1') else (others => 'Z');

end Behavioral;



-- Output D Flip Flop with Active High Enable Output Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDE is
generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    E  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of O : signal is "True";	

end OFDE;

architecture Behavioral of OFDE is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;

O <= q_tmp when (E= '1') else 'Z';

end Behavioral;



-- Single Output D Flip Flop with Inverted Clock
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDI_1 is
 generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFDI_1;

architecture Behavioral of OFDI_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
   Q <= q_tmp;

process(C)
begin
  if (C'event and C = '0') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Single Output D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDI is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFDI;

architecture Behavioral of OFDI is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- D Flip Flops with Active Low 3-State Output Enable Buffers
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDT16 is
port (
    O   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    T   : in STD_LOGIC
    );
end OFDT16;

architecture Behavioral of OFDT16 is
signal q_tmp : std_logic_vector(15 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;

  O <= q_tmp when (T= '0') else (others => 'Z');

end Behavioral;



-- Output D Flip Flop with Active Low 3-State Output Buffer and Inverted Clock
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDT_1 is
generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    T  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of O : signal is "True";	

end OFDT_1;

architecture Behavioral of OFDT_1 is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '0') then
      q_tmp <= D;
  end if;
end process;

O <= q_tmp when (T= '0') else 'Z';

end Behavioral;



-- D Flip Flops with Active Low 3-State Output Enable Buffers
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDT4 is
port (
    O0  : out STD_LOGIC;
    O1  : out STD_LOGIC;
    O2  : out STD_LOGIC;
    O3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    T   : in STD_LOGIC
    );
end OFDT4;

architecture Behavioral of OFDT4 is
signal q_tmp : std_logic_vector(3 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D3&D2&D1&D0;
  end if;
end process;

O3 <= q_tmp(3) when (T= '0') else 'Z';
O2 <= q_tmp(2) when (T= '0') else 'Z';
O1 <= q_tmp(1) when (T= '0') else 'Z';
O0 <= q_tmp(0) when (T= '0') else 'Z';

end Behavioral;



-- D Flip Flops with Active Low 3-State Output Enable Buffers
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDT8 is
port (
    O   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    T   : in STD_LOGIC
    );
end OFDT8;

architecture Behavioral of OFDT8 is
signal q_tmp : std_logic_vector(7 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;

  O <= q_tmp when (T= '0') else (others => 'Z');

end Behavioral;



-- Output D Flip Flop with Active Low 3-State Output Enable Buffer
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDT is
 generic(
    INIT : bit := '0'
    );

port (
    O  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC;
    T  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of O : signal is "True";	

end OFDT;

architecture Behavioral of OFDT is
signal q_tmp : std_logic := TO_X01(INIT);
begin

process(C)
begin
  if (C'event and C = '1') then
     q_tmp <= D;
  end if;
end process;

O <= q_tmp when (T= '0') else 'Z';

end Behavioral;



-- Single Output D Flip Flop
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFD is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFD;

architecture Behavioral of OFD is
signal q_tmp : std_logic := TO_X01(INIT);
begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '1') then
      q_tmp <= D;
  end if;
end process;


end Behavioral;



-- Multiple Output D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDX16 is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0)
    );
end OFDX16;

architecture Behavioral of OFDX16 is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Output D Flip Flop with Inverted Clock and Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDX_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFDX_1;

architecture Behavioral of OFDX_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '0') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Multiple Output D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDX4 is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC
    );
end OFDX4;

architecture Behavioral of OFDX4 is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      Q3 <= D3;
      Q2 <= D2;
      Q1 <= D1;
      Q0 <= D0;
    end if;
  end if;
end process;


end Behavioral;



-- Multiple Output D Flip Flop Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDX8 is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0)
    );
end OFDX8;

architecture Behavioral of OFDX8 is

begin

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      Q <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Output D Flip Flop with Inverted Clock and Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDXI_1 is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFDXI_1;

architecture Behavioral of OFDXI_1 is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '0') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Output D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDXI is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFDXI;

architecture Behavioral of OFDXI is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- Single Output D Flip Flop with Clock Enable
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity OFDX is
generic(
    INIT : bit := '0'
    );

port (
    Q  : out STD_LOGIC;
    C  : in STD_LOGIC;
    CE : in STD_LOGIC;
    D  : in STD_LOGIC
    );
-- attribute IOB         : string ;
-- attribute IOB of Q : signal is "True";	

end OFDX;

architecture Behavioral of OFDX is
signal q_tmp : std_logic := TO_X01(INIT);

begin
  Q <= q_tmp;

process(C)
begin
  if (C'event and C = '1') then
    if (CE='1') then 
      q_tmp <= D;
    end if;
  end if;
end process;


end Behavioral;



-- 12-input OR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OR12 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic
  );
end OR12;

architecture OR12_V of OR12 is
begin
  O <=  (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7 or I8 or I9 or I10 or I11);
end OR12_V;



-- 16-input OR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OR16 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic;
    I9  : in std_logic;
    I10 : in std_logic;
    I11 : in std_logic;
    I12 : in std_logic;
    I13 : in std_logic;
    I14 : in std_logic;
    I15 : in std_logic
  );
end OR16;

architecture OR16_V of OR16 is
begin
  O <=  (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7 or I8 or I9 or I10 or I11 or I12 or I13 or I14 or I15);
end OR16_V;



-- 6-input OR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OR6 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end OR6;

architecture OR6_V of OR6 is
begin
  O <=  (I0 or I1 or I2 or I3 or I4 or I5);
end OR6_V;



-- 7-input OR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OR7 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end OR7;

architecture OR7_V of OR7 is
begin
  O <= (I0 or I1 or I2 or I3 or I4 or I5 or I6);
end OR7_V;



-- 8-input OR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OR8 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end OR8;

architecture OR8_V of OR8 is
begin
  O <= (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7);
end OR8_V;



-- 9-input OR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity OR9 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end OR9;

architecture OR9_V of OR9 is
begin
  O <=  (I0 or I1 or I2 or I3 or I4 or I5 or I6 or I7 or I8);
end OR9_V;



-- 16-Deep by 2-Wide Static Dual Port Synchronous RAM
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity RAM16X2D is
  
port(
    DPO0  : out std_logic;
    DPO1  : out std_logic;
    SPO0  : out std_logic;
    SPO1  : out std_logic;

    A0    : in std_logic;
    A1    : in std_logic;
    A2    : in std_logic;
    A3    : in std_logic;
    D0    : in std_logic;
    D1    : in std_logic;
    DPRA0 : in std_logic;
    DPRA1 : in std_logic;
    DPRA2 : in std_logic;
    DPRA3 : in std_logic;
    WCLK  : in std_logic;
    WE    : in std_logic
  );
end RAM16X2D;

architecture RAM16X2D_V of RAM16X2D is

signal mem0 : std_logic_vector(16 downto 0);
signal mem1 : std_logic_vector(16 downto 0);

begin
  
  process(A0, A1, A2, A3, DPRA0, DPRA1, DPRA2, DPRA3, mem0, mem1)
  variable addr : std_logic_vector(3 downto 0);
  variable dpra : std_logic_vector(3 downto 0);
  variable index_s: integer;
  variable index_d: integer;

  begin
    addr    := A3&A2&A1&A0;
    index_s := conv_integer(addr);
    dpra    := DPRA3&DPRA2&DPRA1&DPRA0;
    index_d := conv_integer(dpra);

    SPO0    <= mem0(index_s);
    SPO1    <= mem1(index_s);
    DPO0    <= mem0(index_d);
    DPO1    <= mem1(index_d);

  end process;

  process(WCLK)
  variable addr : std_logic_vector(3 downto 0);
  variable index_s: integer;

  begin
    addr := A3&A2&A1&A0;
    index_s := conv_integer(addr);

    if( WCLK'event and (WCLK= '1') ) then
      if( WE = '1' ) then
        mem0(index_s) <= D0;
        mem1(index_s) <= D1;
      end if;
   end if; 
  end process;
     
end RAM16X2D_V;



-- 16-Deep by 4-Wide Static Dual Port Synchronous RAM
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity RAM16X4D is
  
port(
    DPO0  : out std_logic;
    DPO1  : out std_logic;
    DPO2  : out std_logic;
    DPO3  : out std_logic;
    SPO0  : out std_logic;
    SPO1  : out std_logic;
    SPO2  : out std_logic;
    SPO3  : out std_logic;

    A0    : in std_logic;
    A1    : in std_logic;
    A2    : in std_logic;
    A3    : in std_logic;
    D0    : in std_logic;
    D1    : in std_logic;
    D2    : in std_logic;
    D3    : in std_logic;
    DPRA0 : in std_logic;
    DPRA1 : in std_logic;
    DPRA2 : in std_logic;
    DPRA3 : in std_logic;
    WCLK  : in std_logic;
    WE    : in std_logic
  );
end RAM16X4D;

architecture RAM16X4D_V of RAM16X4D is

signal mem0 : std_logic_vector(16 downto 0);
signal mem1 : std_logic_vector(16 downto 0);
signal mem2 : std_logic_vector(16 downto 0);
signal mem3 : std_logic_vector(16 downto 0);

begin
  
  process(A0, A1, A2, A3, DPRA0, DPRA1, DPRA2, DPRA3, mem0, mem1, mem2, mem3)
  variable addr : std_logic_vector(3 downto 0);
  variable dpra : std_logic_vector(3 downto 0);
  variable index_s: integer := 0;
  variable index_d: integer := 0;

  begin
    addr    := A3&A2&A1&A0;
    index_s := conv_integer(addr);
    dpra    := DPRA3&DPRA2&DPRA1&DPRA0;
    index_d := conv_integer(dpra);

    SPO0    <= mem0(index_s);
    SPO1    <= mem1(index_s);
    SPO2    <= mem2(index_s);
    SPO3    <= mem3(index_s);

    DPO0    <= mem0(index_d);
    DPO1    <= mem1(index_d);
    DPO2    <= mem2(index_d);
    DPO3    <= mem3(index_d);

  end process;

  process(WCLK)
  variable addr : std_logic_vector(3 downto 0);
  variable index_s: integer;

  begin
    addr := A3&A2&A1&A0;
    index_s := conv_integer(addr);

    if( WCLK'event and (WCLK= '1') ) then
      if( WE = '1' ) then
        mem0(index_s) <= D0;
        mem1(index_s) <= D1;
        mem2(index_s) <= D2;
        mem3(index_s) <= D3;
      end if;
   end if; 
  end process;
     
end RAM16X4D_V;



-- 16-Deep by 8-Wide Static Dual Port Synchronous RAM
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity RAM16X8D is
port(
    DPO   : out std_logic_vector(7 downto 0);
    SPO   : out std_logic_vector(7 downto 0);

    A0    : in std_logic;
    A1    : in std_logic;
    A2    : in std_logic;
    A3    : in std_logic;
    D     : in std_logic_vector(7 downto 0);
    DPRA0 : in std_logic;
    DPRA1 : in std_logic;
    DPRA2 : in std_logic;
    DPRA3 : in std_logic;
    WCLK  : in std_logic;
    WE    : in std_logic
  );
end RAM16X8D;

architecture RAM16X8D_V of RAM16X8D is

signal mem0 : std_logic_vector(16 downto 0);
signal mem1 : std_logic_vector(16 downto 0);
signal mem2 : std_logic_vector(16 downto 0);
signal mem3 : std_logic_vector(16 downto 0);
signal mem4 : std_logic_vector(16 downto 0);
signal mem5 : std_logic_vector(16 downto 0);
signal mem6 : std_logic_vector(16 downto 0);
signal mem7 : std_logic_vector(16 downto 0);

begin
  
  process(A0, A1, A2, A3, DPRA0, DPRA1, DPRA2, DPRA3, mem0, mem1, mem2, mem3, mem4, mem5, mem6, mem7)
  variable addr : std_logic_vector(3 downto 0);
  variable dpra : std_logic_vector(3 downto 0);
  variable index_s: integer;
  variable index_d: integer;

  begin
    addr    := A3&A2&A1&A0;
    index_s := conv_integer(addr);
    dpra    := DPRA3&DPRA2&DPRA1&DPRA0;
    index_d := conv_integer(dpra);

    SPO(0)    <= mem0(index_s);
    SPO(1)    <= mem1(index_s);
    SPO(2)    <= mem2(index_s);
    SPO(3)    <= mem3(index_s);
    SPO(4)    <= mem4(index_s);
    SPO(5)    <= mem5(index_s);
    SPO(6)    <= mem6(index_s);
    SPO(7)    <= mem7(index_s);

    DPO(0)    <= mem0(index_d);
    DPO(1)    <= mem1(index_d);
    DPO(2)    <= mem2(index_d);
    DPO(3)    <= mem3(index_d);
    DPO(4)    <= mem4(index_d);
    DPO(5)    <= mem5(index_d);
    DPO(6)    <= mem6(index_d);
    DPO(7)    <= mem7(index_d);

  end process;

  process(WCLK)
  variable addr : std_logic_vector(3 downto 0);
  variable index_s: integer;

  begin
    addr := A3&A2&A1&A0;
    index_s := conv_integer(addr);

    if( WCLK'event and (WCLK= '1') ) then
      if( WE = '1' ) then
        mem0(index_s) <= D(0);
        mem1(index_s) <= D(1);
        mem2(index_s) <= D(2);
        mem3(index_s) <= D(3);
        mem4(index_s) <= D(4);
        mem5(index_s) <= D(5);
        mem6(index_s) <= D(6);
        mem7(index_s) <= D(7);
      end if;
   end if; 
  end process;
     
end RAM16X8D_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP3B1A is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end SOP3B1A;

architecture SOP3B1A_V of SOP3B1A is
begin
  O <=  ( (not I0) and I1) or I2;

end SOP3B1A_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP3B1B is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end SOP3B1B;

architecture SOP3B1B_V of SOP3B1B is
begin
  O <=  (I0 and I1) or (not I2) ;

end SOP3B1B_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP3B2A is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end SOP3B2A;

architecture SOP3B2A_V of SOP3B2A is
begin
  O <=  ((not I0) and (not I1)) or I2;

end SOP3B2A_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP3B2B is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end SOP3B2B;

architecture SOP3B2B_V of SOP3B2B is
begin
  O <=  ((not I0) and I1) or (not I2);

end SOP3B2B_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP3B3 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end SOP3B3;

architecture SOP3B3_V of SOP3B3 is
begin
  O <=  ((not I0) and (not I1)) or (not I2);

end SOP3B3_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP3 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic
  );
end SOP3;

architecture SOP3_V of SOP3 is
begin
  O <=  (I0 and I1) or I2;

end SOP3_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP4B1 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end SOP4B1;

architecture SOP4B1_V of SOP4B1 is
begin
  O <=  ( (not I0) and I1) or (I2 and I3) ;

end SOP4B1_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP4B2A is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end SOP4B2A;

architecture SOP4B2A_V of SOP4B2A is
begin
  O <=  ( (not I0) and (not I1) ) or (I2 and I3) ;

end SOP4B2A_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP4B2B is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end SOP4B2B;

architecture SOP4B2B_V of SOP4B2B is
begin
  O <=  ( (not I0) and I1) or ( (not I2) and I3) ;

end SOP4B2B_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP4B3 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end SOP4B3;

architecture SOP4B3_V of SOP4B3 is
begin
  O <=  ( (not I0) and (not I1) ) or ( (not I2) and I3) ;

end SOP4B3_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP4B4 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end SOP4B4;

architecture SOP4B4_V of SOP4B4 is
begin
  O <=  ( (not I0) and (not I1) ) or ( (not I2) and (not I3) ) ;

end SOP4B4_V;



-- Sum of Products
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity SOP4 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic
  );
end SOP4;

architecture SOP4_V of SOP4 is
begin
  O <=  (I0 and I1) or (I2 and I3) ;

end SOP4_V;



-- 16-Bit Serial-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR16CE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR16CE;

architecture Behavioral of SR16CE is
signal q_tmp : std_logic_vector(15 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      q_tmp <= ( q_tmp(14 downto 0) & SLI );
    end if;
  end if;
end process;

Q <= q_tmp;


end Behavioral;



-- 16-Bit Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR16CLED is
port (
    Q    : out STD_LOGIC_VECTOR(15 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(15 downto 0);
    L    : in STD_LOGIC;
    LEFT : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end SR16CLED;

architecture Behavioral of SR16CLED is
signal q_tmp : std_logic_vector(15 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= (others => '0');
  elsif (C'event and C = '1') then
    if (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      if (LEFT= '1') then
        q_tmp <= ( q_tmp(14 downto 0) & SLI );
      else
        q_tmp <= ( SRI & q_tmp(15 downto 1) );
      end if;
    end if;
  end if;
end process;

Q <= q_tmp;


end Behavioral;



-- 16-Bit Loadable Serial/Parallel-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR16CLE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    L   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR16CLE;

architecture Behavioral of SR16CLE is
signal q_tmp : std_logic_vector(15 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= (others => '0');
  elsif (C'event and C = '1') then
    if (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(14 downto 0) & SLI );
    end if;
  end if;
end process;

Q <= q_tmp;

end Behavioral;



-- 16-Bit Serial-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR16RE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR16RE;

architecture Behavioral of SR16RE is
signal q_tmp : STD_LOGIC_VECTOR(15 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= (others => '0');
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(14 downto 0) & SLI );
    end if;
  end if;
end process;
Q <= q_tmp;

end Behavioral;



-- 16-Bit Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR16RLED is
port (
    Q    : out STD_LOGIC_VECTOR(15 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(15 downto 0);
    L    : in STD_LOGIC; 
    LEFT : in STD_LOGIC;
    R    : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end SR16RLED;

architecture Behavioral of SR16RLED is
signal q_tmp : STD_LOGIC_VECTOR(15 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= (others => '0');
    elsif (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      if (LEFT= '1') then
        q_tmp <= ( q_tmp(14 downto 0) & SLI );
      else
        q_tmp <= ( SRI & q_tmp(15 downto 1) );
      end if;
    end if;
  end if;
end process;
Q <= q_tmp;

end Behavioral;



-- 16-Bit Loadable Serial/Parallel-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR16RLE is
port (
    Q   : out STD_LOGIC_VECTOR(15 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(15 downto 0);
    L   : in STD_LOGIC; 
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR16RLE;

architecture Behavioral of SR16RLE is
signal q_tmp : STD_LOGIC_VECTOR(15 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= (others => '0');
    elsif (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(14 downto 0) & SLI );
    end if;
  end if;
end process;
Q <= q_tmp;

end Behavioral;



-- 4-Bit Serial-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR4CE is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR4CE;

architecture Behavioral of SR4CE is
signal q_tmp : std_logic_vector(3 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= "0000";
  elsif (C'event and C = '1') then
    if (CE='1') then 
      q_tmp <= ( q_tmp(2 downto 0) & SLI );
    end if;
  end if;
end process;

Q3 <= q_tmp(3);
Q2 <= q_tmp(2);
Q1 <= q_tmp(1);
Q0 <= q_tmp(0);


end Behavioral;



-- 4-Bit Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR4CLED is
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC;
    LEFT : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end SR4CLED;

architecture Behavioral of SR4CLED is
signal q_tmp : std_logic_vector(3 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= "0000";
  elsif (C'event and C = '1') then
    if (L= '1') then
      q_tmp <= D3&D2&D1&D0;
    elsif (CE='1') then 
      if (LEFT= '1') then
        q_tmp <= ( q_tmp(2 downto 0) & SLI );
      else
        q_tmp <= ( SRI & q_tmp(3 downto 1) );
      end if;
    end if;
  end if;
end process;

Q3 <= q_tmp(3);
Q2 <= q_tmp(2);
Q1 <= q_tmp(1);
Q0 <= q_tmp(0);


end Behavioral;



-- 4-Bit Loadable Serial/Parallel-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR4CLE is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    L   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR4CLE;

architecture Behavioral of SR4CLE is
signal q_tmp : std_logic_vector(3 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= "0000";
  elsif (C'event and C = '1') then
    if (L= '1') then
      q_tmp <= D3&D2&D1&D0;
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(2 downto 0) & SLI );
    end if;
  end if;
end process;

Q3 <= q_tmp(3);
Q2 <= q_tmp(2);
Q1 <= q_tmp(1);
Q0 <= q_tmp(0);


end Behavioral;



-- 4-Bit Serial-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR4RE is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR4RE;

architecture Behavioral of SR4RE is
signal q_tmp : STD_LOGIC_VECTOR(3 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= "0000";
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(2 downto 0) & SLI );
    end if;
  end if;
end process;
Q3 <= q_tmp(3);
Q2 <= q_tmp(2);
Q1 <= q_tmp(1);
Q0 <= q_tmp(0);

end Behavioral;



-- 4-Bit Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR4RLED is
port (
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    Q2   : out STD_LOGIC;
    Q3   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    D0   : in STD_LOGIC;
    D1   : in STD_LOGIC;
    D2   : in STD_LOGIC;
    D3   : in STD_LOGIC;
    L    : in STD_LOGIC; 
    LEFT : in STD_LOGIC;
    R    : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end SR4RLED;

architecture Behavioral of SR4RLED is
signal q_tmp : STD_LOGIC_VECTOR(3 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= "0000";
    elsif (L= '1') then
      q_tmp <= D3&D2&D1&D0;
    elsif (CE='1') then 
      if (LEFT= '1') then
        q_tmp <= ( q_tmp(2 downto 0) & SLI );
      else
        q_tmp <= ( SRI & q_tmp(3 downto 1) );
      end if;
    end if;
  end if;
end process;
Q3 <= q_tmp(3);
Q2 <= q_tmp(2);
Q1 <= q_tmp(1);
Q0 <= q_tmp(0);

end Behavioral;



-- 4-Bit Loadable Serial/Parallel-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR4RLE is
port (
    Q0  : out STD_LOGIC;
    Q1  : out STD_LOGIC;
    Q2  : out STD_LOGIC;
    Q3  : out STD_LOGIC;
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D0  : in STD_LOGIC;
    D1  : in STD_LOGIC;
    D2  : in STD_LOGIC;
    D3  : in STD_LOGIC;
    L   : in STD_LOGIC; 
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR4RLE;

architecture Behavioral of SR4RLE is
signal q_tmp : STD_LOGIC_VECTOR(3 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= "0000";
    elsif (L= '1') then
      q_tmp <= D3&D2&D1&D0;
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(2 downto 0) & SLI );
    end if;
  end if;
end process;
Q3 <= q_tmp(3);
Q2 <= q_tmp(2);
Q1 <= q_tmp(1);
Q0 <= q_tmp(0);

end Behavioral;



-- 8-Bit Serial-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR8CE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR8CE;

architecture Behavioral of SR8CE is
signal q_tmp : std_logic_vector(7 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      q_tmp <= ( q_tmp(6 downto 0) & SLI );
    end if;
  end if;
end process;

Q <= q_tmp;


end Behavioral;



-- 8-Bit Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR8CLED is
port (
    Q    : out STD_LOGIC_VECTOR(7 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(7 downto 0);
    L    : in STD_LOGIC;
    LEFT : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end SR8CLED;

architecture Behavioral of SR8CLED is
signal q_tmp : std_logic_vector(7 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= (others => '0');
  elsif (C'event and C = '1') then
    if (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      if (LEFT= '1') then
        q_tmp <= ( q_tmp(6 downto 0) & SLI );
      else
        q_tmp <= ( SRI & q_tmp(7 downto 1) );
      end if;
    end if;
  end if;
end process;

Q <= q_tmp;


end Behavioral;



-- 8-Bit Loadable Serial/Parallel-In Parallel-Out Shift Register with Clock Enable and Asynchronous Clear
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR8CLE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    CLR : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    L   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR8CLE;

architecture Behavioral of SR8CLE is
signal q_tmp : std_logic_vector(7 downto 0);
begin

process(C, CLR)
begin
  if (CLR='1') then
    q_tmp <= (others => '0');
  elsif (C'event and C = '1') then
    if (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(6 downto 0) & SLI );
    end if;
  end if;
end process;

Q <= q_tmp;

end Behavioral;



-- 8-Bit Serial-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR8RE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR8RE;

architecture Behavioral of SR8RE is
signal q_tmp : STD_LOGIC_VECTOR(7 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= (others => '0');
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(6 downto 0) & SLI );
    end if;
  end if;
end process;
Q <= q_tmp;

end Behavioral;



-- 8-Bit Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR8RLED is
port (
    Q    : out STD_LOGIC_VECTOR(7 downto 0);
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    D    : in STD_LOGIC_VECTOR(7 downto 0);
    L    : in STD_LOGIC; 
    LEFT : in STD_LOGIC;
    R    : in STD_LOGIC;
    SLI  : in STD_LOGIC;
    SRI  : in STD_LOGIC
    );
end SR8RLED;

architecture Behavioral of SR8RLED is
signal q_tmp : STD_LOGIC_VECTOR(7 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= (others => '0');
    elsif (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      if (LEFT= '1') then
        q_tmp <= ( q_tmp(6 downto 0) & SLI );
      else
        q_tmp <= ( SRI & q_tmp(7 downto 1) );
      end if;
    end if;
  end if;
end process;
Q <= q_tmp;

end Behavioral;



-- 8-Bit Loadable Serial/Parallel-In Parallel Out Shift Register with Clock Enable and Synchronous Reset
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SR8RLE is
port (
    Q   : out STD_LOGIC_VECTOR(7 downto 0);
    C   : in STD_LOGIC;
    CE  : in STD_LOGIC;
    D   : in STD_LOGIC_VECTOR(7 downto 0);
    L   : in STD_LOGIC; 
    R   : in STD_LOGIC;
    SLI : in STD_LOGIC
    );
end SR8RLE;

architecture Behavioral of SR8RLE is
signal q_tmp : STD_LOGIC_VECTOR(7 downto 0);
begin

process(C)
begin
  if (C'event and C = '1') then
    if (R='1') then
      q_tmp <= (others => '0');
    elsif (L= '1') then
      q_tmp <= D;
    elsif (CE='1') then 
      q_tmp <= ( q_tmp(6 downto 0) & SLI );
    end if;
  end if;
end process;
Q <= q_tmp;

end Behavioral;



-- 6-input XNOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XNOR6 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end XNOR6;

architecture XNOR6_V of XNOR6 is
begin
  O <= not (I0 xor I1 xor I2 xor I3 xor I4 xor I5);
end XNOR6_V;



-- 7-input XNOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XNOR7 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end XNOR7;

architecture XNOR7_V of XNOR7 is
begin
  O <= not (I0 xor I1 xor I2 xor I3 xor I4 xor I5 xor I6) ;
end XNOR7_V;



-- 8-input XNOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XNOR8 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end XNOR8;

architecture XNOR8_V of XNOR8 is
begin
  O <= not (I0 xor I1 xor I2 xor I3 xor I4 xor I5 xor I6 xor I7);
end XNOR8_V;



-- 9-input XNOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XNOR9 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end XNOR9;

architecture XNOR9_V of XNOR9 is
begin
  O <= not (I0 xor I1 xor I2 xor I3 xor I4 xor I5 xor I6 xor I7 xor I8);
end XNOR9_V;



-- 6-input XOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XOR6 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic
  );
end XOR6;

architecture XOR6_V of XOR6 is
begin
  O <= I0 xor I1 xor I2 xor I3 xor I4 xor I5;
end XOR6_V;



-- 7-input XOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XOR7 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic
  );
end XOR7;

architecture XOR7_V of XOR7 is
begin
  O <= I0 xor I1 xor I2 xor I3 xor I4 xor I5 xor I6;
end XOR7_V;



-- 8-input XOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XOR8 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic
  );
end XOR8;

architecture XOR8_V of XOR8 is
begin
  O <= I0 xor I1 xor I2 xor I3 xor I4 xor I5 xor I6 xor I7;
end XOR8_V;



-- 9-input XOR gate with Non-inverted Inputs
library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity XOR9 is
  
port(
    O  : out std_logic;

    I0  : in std_logic;
    I1  : in std_logic;
    I2  : in std_logic;
    I3  : in std_logic;
    I4  : in std_logic;
    I5  : in std_logic;
    I6  : in std_logic;
    I7  : in std_logic;
    I8  : in std_logic
  );
end XOR9;

architecture XOR9_V of XOR9 is
begin
  O <= I0 xor I1 xor I2 xor I3 xor I4 xor I5 xor I6 xor I7 xor I8;
end XOR9_V;





