class packet;
	rand bit [7:0] sa;
	rand bit [7:0] da;
    bit[31:0] len;
    bit [31:0] crc;
    rand bit [7:0] payload[];
	
	bit[7:0] inp_stream[$];

    bit [7:0] outp_stream[$];
	
	
	constraint valid {
		sa inside {[1:8]};
		da inside {[1:8]};
		
		payload.size() inside {[2:1990]};
		
		foreach (payload[i])
			payload[i] inside{[0:255]};
		
	}
	
	function  void pack(ref bit[7:0] q_inp[$]);		// I* why no automatic for task
        q_inp={<<8{this.payload,this.crc,this.len,this.da,this.sa}};
    endfunction
	
	function automatic void unpack(ref bit[7:0] q_inp[$]);
        {<<8{this.payload,this.crc,this.len,this.da,this.sa}}=q_inp;
    endfunction
	
	function void print();
		$display("[Packet print] sa=%0d da=%0d	len=%0d crc=%0d",this.sa,this.da,this.len,this.crc);
		$write("Payload");
		foreach(payload[k])
			$write("%0h",payload[k]);
		
		$display("\n");
		
	endfunction
	
	function void post_randomize();
		len=1+1+4+4+payload.size();
		crc=payload.sum();
		this.pack(inp_stream);
	
	endfunction
	
	function copy(packet rhs);
		if(rhs==null) begin
			$display("[error] null handle passed to copy method");
		end
		else begin
			this.sa=rhs.sa;
			this.da=rhs.da;
			this.len=rhs.len;
			this.crc=rhs.crc;
			this.payload=rhs.payload;
			this.inp_stream=rhs.inp_stream;
		end
		
	endfunction
	
	function compare(input packet dut_pkt);
		bit status;
		status=1;
		
		foreach(dut_pkt.inp_stream[i])
			status=status && (this.inp_stream[i]==dut_pkt.inp_stream[i]);
		
		return status;
		
	endfunction
	
			
endclass