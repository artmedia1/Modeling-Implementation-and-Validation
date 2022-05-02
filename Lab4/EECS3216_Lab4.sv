package definitions;


  parameter ON  = 1'b1;
  parameter OFF = 1'b0;

  enum logic [5:0] {RST, C5, C10, C20, Timer} State, NextState;

  integer count = 0;
  integer Time = 0;
  integer IgnoreTimer = 0;
  integer firstLoop = 0;
  reg toggle;
  reg C5Enable = 1;
  reg C10Enable = 1;
  reg C20Enable = 1;
  reg ignore = 0; //Used to debounce signal
  parameter TRUE = 1'b1;
  parameter FALSE = 1'b0;
  parameter D = 32'd25000000;


endpackage

module EECS3216_Lab4 (input Clock,
							 input TimerON, //SW4
							 input Coin5,
							 input Coin10,
							 input Coin20,
							 input Reset,
							 output reg [6:0] tenSec,
							 output reg [6:0] oneSec,
							 output reg C5Enable,
							 output reg C10Enable,
							 output reg C20Enable);

  import definitions::*;

  //
  // Update state or reset on every + clock edge
  // We have no clear
  //
  
  always @(posedge Clock)
  begin
	if (TimerON)
		State <= Timer;
	else if (!TimerON && !Coin5 && !Coin10 && !Coin20)
		State <= RST;
	else
		State <= NextState;
  end


  always @(posedge Clock)
  begin 
			
		if(State == RST) begin
			C5Enable <= 1;
			C10Enable <= 1;
			C20Enable <= 1;
		end

		if (Reset == 1'b0) begin
			Time <= 0;
		end 
		
		if(State == C5 && C5Enable == 1) begin
			if (ignore == 1)
				IgnoreTimer <= IgnoreTimer + 23'b1;
			else if (ignore == 0) begin
				if(Time > 93)
					Time <= 99;
				else
					Time <= Time + 5;
				C5Enable <= 0;
				ignore <= 1;
			end 
		end
		
		if(State == C10 && C10Enable == 1) begin
			if (ignore == 1)
				IgnoreTimer <= IgnoreTimer + 23'b1;
			else if (ignore == 0) begin
				if(Time > 88)
					Time <= 99;
				else
					Time <= Time + 10;
				C10Enable <= 0;
				ignore <= 1;
			end 
		end

		if(State == C20 && C20Enable == 1) begin
			if (ignore == 1)
				IgnoreTimer <= IgnoreTimer + 23'b1;
			else if (ignore == 0) begin
				if(Time > 78)
					Time <= 99;
				else
					Time <= Time + 20;
				C20Enable <= 0;
				ignore <= 1;
			end 
		end		
		
		if (IgnoreTimer  == 23'd5000000) begin
			IgnoreTimer <= 23'd0;
			ignore <= 0;
		end
	
		count <= count + 32'd1;
	
			
		if (count >= (D - 32'd1)) begin

			count <= 32'd0;
			
			toggle <= ~toggle;
			if(State == Timer && toggle) begin		
			
				Time <= Time - 1;
					

	  
				if(Time < 1)
					Time <= 0;		
				
			end
		end
		case (Time / 10) 
			5'd1: tenSec <= 7'b1111001;
			5'd2: tenSec <= 7'b0100100;
			5'd3: tenSec <= 7'b0110000;
			5'd4: tenSec <= 7'b0011001;
			5'd5: tenSec <= 7'b0010010;
			5'd6: tenSec <= 7'b0000010;
			5'd7: tenSec <= 7'b1111000;
			5'd8: tenSec <= 7'b0000000;
			5'd9: tenSec <= 7'b0011000;
			default: tenSec <= 7'b1000000; //sets oneSec to 0
		endcase	
					
		case (Time % 10)
			5'd1: oneSec <= 7'b1111001;
			5'd2: oneSec <= 7'b0100100;
			5'd3: oneSec <= 7'b0110000;
			5'd4: oneSec <= 7'b0011001;
			5'd5: oneSec <= 7'b0010010;
			5'd6: oneSec <= 7'b0000010;
			5'd7: oneSec <= 7'b1111000;
			5'd8: oneSec <= 7'b0000000;
			5'd9: oneSec <= 7'b0011000;
			default: oneSec <= 7'b1000000; //sets oneSec to 0
		endcase	
	end
  

  //
  // Next state generation logic
  //

  always @(State or Coin5 or Coin10 or Coin20 or Reset)
  begin
  case (State)
	  RST:		begin
					if(Coin5)
						NextState <= C5;
					else if (Coin10)
						NextState <= C10;
					else if (Coin20)
						NextState <= C20;
					else
						NextState <= RST;
					end
					
		C5:		begin
					if (!Coin5)
						NextState <= RST;
					else
						NextState <= C5;
					end
		
		C10:		begin
					if (!Coin10)
						NextState <= RST;
					else
						NextState <= C10;
					end

		C20:		begin
					if (!Coin20)
						NextState <= RST;
					else
						NextState <= C20;
					end					
  endcase
  end
  
  



  

  
endmodule
