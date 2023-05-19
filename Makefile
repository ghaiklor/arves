all: clean run

analyze:
	ghdl analyze -fsynopsys rtl/*.vhdl

run: analyze
	ghdl run -fsynopsys soc_tb --wave=wave.ghw

clean:
	rm -rf wave.ghw work-obj93.cf
