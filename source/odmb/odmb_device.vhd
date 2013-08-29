-- ODMB_DEVICE: If ODMB mode is selected, this module generates the DMB_TX signals and
-- provides other ODMB functionalities.

library ieee;
use ieee.std_logic_1164.all;

entity odmb_device is
  port (
    clock        : in std_logic;
    clock_vme    : in std_logic;
    global_reset : in std_logic;

    vme_address : in std_logic_vector(23 downto 1);
    vme_data    : in std_logic_vector(15 downto 0);
    is_read     : in std_logic;
    bd_sel      : in std_logic;

    odmb_sel  : out std_logic;
    odmb_data : out std_logic_vector(15 downto 0)
    );
end odmb_device;

architecture odmb_device_arch of odmb_device is

begin

  odmb_sel <= '1';
  odmb_data <= x"0DDB";

end odmb_device_arch;
