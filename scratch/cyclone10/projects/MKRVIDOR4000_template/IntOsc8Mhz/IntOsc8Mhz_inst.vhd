	component IntOsc8Mhz is
		port (
			oscena : in  std_logic := 'X'; -- oscena
			clkout : out std_logic         -- clk
		);
	end component IntOsc8Mhz;

	u0 : component IntOsc8Mhz
		port map (
			oscena => CONNECTED_TO_oscena, -- oscena.oscena
			clkout => CONNECTED_TO_clkout  -- clkout.clk
		);

