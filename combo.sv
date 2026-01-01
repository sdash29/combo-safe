
module combo( input logic MAX10_CLK1_50,
				  input logic[1:0] KEY,
				  input logic[12:8] ARDUINO_IO,
				  input logic GND,
				  input logic[9:0]SW,
				  output logic[7:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,
				  output logic[9:0] LEDR
				  );

logic [3:0] key_code;
logic key_validn;
logic[7:0] segments;
logic saveAT,savePW;
//assign key_validn=ARDUINO_IO[12];
//assign key_code[3:0]=ARDUINO_IO[11:8];
assign key_validn=KEY[1];
assign key_code[3:0]=SW[3:0];
logic clk, reset, enter,match;

logic [2:0]count1;
logic [47:0] buffer;
logic[47:0] PASSWORD,ATTEMPT;

logic[2:0] presentstate;
assign LEDR[9:7]=presentstate;
assign LEDR[6:3]=key_code;
assign LEDR[2:0]=count1;


localparam logic[47:0] OPEN=48'hF7_C0_8C_86_AB_F7;
localparam logic[47:0] LOCKED=48'hC7_C0_C6_89_86_C0;
localparam logic[7:0] OFF=8'b11111111;

assign clk=MAX10_CLK1_50;

always_comb begin
enter=0;
case (presentstate)
3'b001: enter=(!key_validn_sync)&(key_code_sync==4'he)&(count1>3'd6) ;

3'b011:enter=  (!key_validn_sync)&(key_code_sync==4'he)&(count1>3'd6);

//3'b001: enter=(press)&(key_code_sync==4'he)&(count1==3'd6);
//3'b011:enter=(press)&(key_code_sync==4'he)&(count1>=3'd6);
endcase
end


//synchronize signals

logic[3:0] key_code_sync;
logic key_validn_sync;
logic ff1,ff2,prev;

always_ff @(posedge clk)begin
  ff1<=key_validn;
  ff2<=ff1;
  
  
 // sample<=key_code
end

assign key_validn_sync=ff2;

logic[3:0] ff3,ff4;
always_ff @(posedge clk)begin
  ff3<=key_code;
  ff4<=ff3;
end

assign key_code_sync=ff4;

//detect falling edge

logic prev1,ff5;
logic press;

always_ff @(posedge clk)begin
    
    prev1<=key_validn_sync;
	 press<=prev1 & !key_validn_sync;
end


always_comb begin
 match=(ATTEMPT==PASSWORD);
 reset=(!key_validn_sync)&(key_code_sync==4'hf)&(presentstate==3'b001||3'b011);
end


always_ff @(posedge clk) begin
  
 if(savePW)
  PASSWORD<=buffer;
  
  if(saveAT)
  ATTEMPT<=buffer;
  
end

//display open at state a and locked
always_ff @(posedge clk) begin
 if(presentstate==3'b000)
    {HEX5,HEX4,HEX3,HEX2,HEX1,HEX0}<=OPEN;
 
 else if(presentstate==3'b010)
    {HEX5,HEX4,HEX3,HEX2,HEX1,HEX0}<=LOCKED;
	 
 else
    {HEX5,HEX4,HEX3,HEX2,HEX1,HEX0}<=buffer;

end


always_ff @(posedge clk)begin
//create counter to six for key validn
if(presentstate==3'b001||presentstate==3'b011)begin
 if(press)begin
 if(count1<= 3'd6) begin
  count1<=count1+1;
  if(count1<3'd6)
  buffer<={buffer[39:0],segments};
	 
	 end
	end
  end

else  begin
   count1<=3'b001;
	//buffer<={OFF,OFF,OFF,OFF,OFF,OFF};
	buffer<={OFF,OFF,OFF,OFF,OFF,segments};
	end
	
//end of counter 
	
end 

 always_comb
 case(key_code_sync)
 //gfe_dcfa
 4'h0: segments =8'b11000000;
 4'h1: segments =8'b11111001;
 4'h2: segments =8'b10100100;
 4'h3: segments =8'b10110000;
 4'h4: segments= 8'b10011001;
 4'h5: segments= 8'b10010010;
 4'h6: segments= 8'b10000010;	
 4'h7: segments= 8'b11111000;	
 4'h8: segments= 8'b10000000;
 4'h9: segments= 8'b10011000;
 4'ha: segments= 8'b10001000;	
 4'hb: segments= 8'b10000011;
 4'hc: segments= 8'b10100111;
 4'hd: segments= 8'b10100001;
 4'he: segments= 8'b10000110;
 4'hf: segments= 8'b10001110;
 
 default: segments= 8'b11111111;
 endcase
 
fsm_synth u1(enter, match,reset,press,clk,count1,saveAT,savePW,KEY,presentstate);

endmodule

module fsm_synth(input logic enter,
					  input logic match,
					  input logic reset,
					  press,
					  input logic clk,
					  input logic[2:0] count1,
					  output logic saveAT,
					  output logic savePW,
					  input logic[1:0] KEY,
					  output logic[2:0] presentstate);

typedef enum int unsigned{STATE_A=0,STATE_B=1,STATE_C=2,STATE_D=3,STATE_E=4,
STATE_WAIT=5} statetype;
statetype present_state,next_state;


always_comb begin
case(present_state)
   STATE_A: begin
	           saveAT=0;
				  savePW=0;
				 end
	STATE_B: begin
	           saveAT=1;
				  savePW=0;
				 end
	STATE_C: begin
	           saveAT=0;
				  savePW=0;
				 end
	STATE_D:begin 
	           saveAT=0;
				  savePW=1;
			  end
	STATE_E: begin
	           saveAT=0;
				  savePW=0;
				end
	default: begin
	           saveAT=0;
				  savePW=0;
	         end
	endcase
end
//nextstate block

always_comb begin
 
 next_state=present_state;
  case(present_state)
    STATE_A: begin
	  if(press) next_state=STATE_B;
	 end
	 
	 STATE_B: begin
	  if(enter) next_state=STATE_WAIT;
	 end  
   
	 STATE_WAIT: begin
        next_state=STATE_C;
   	
	 end
	 STATE_C: begin
	  if(press) next_state=STATE_D;
	 end
	 
	 STATE_D: begin
	  if(enter) next_state=STATE_E;
	 end
	 
	 STATE_E: begin
	  if(match) next_state=STATE_A;
	  else next_state=STATE_C;
	 end
	 
	
  endcase
end

always_ff @(posedge clk) begin
    if(reset) begin
	    if(present_state==STATE_B) 
	    present_state<=STATE_A;
		 
	    if(present_state==STATE_D) 
	    present_state<=STATE_C;
	 end	 
		 
	 else begin
	    present_state<=next_state;   
	 end
	 
	 presentstate<=present_state;
end

endmodule




