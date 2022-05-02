package definitions;


  parameter ON  = 1'b1;
  parameter OFF = 1'b0;

  enum logic [5:0] {push, pop, rdy} State, NextState;

  integer numToDisplay = 0;
  integer currentIndex = 0;
  integer popIndex = 0;
  integer counter = 0;
  integer IgnoreTimer = 0;
  reg [5:0] savedNum [15:0];
  reg toggle = 1;
  reg ignore = 0; //Used to debounce signal
  parameter D = 32'd25000000;


endpackage

module EECS3216_Lab5 (input Clock,
							 input Reset,
							 input[1:0] do_op,
							 input KEY1,
							 input[5:0] sixBitNum,
							 output reg [6:0] tenSec,
							 output reg [6:0] oneSec,
							 output rdyLight,
							 output pushLight,
							 output popLight);

  import definitions::*;

  //
  // Update state or reset on every + clock edge
  // We have no clear
  //
  initial begin
		State <= rdy;
		NextState <= rdy;	
	//	savedNum[0] <= 6'b111111;
	end

  always @(posedge Clock)
  begin 
  
		State <= NextState;
	

		if(KEY1)
			toggle <= 1; //prevents currentIndex from incrementing or decrementing when holding down button		
		
		if(!Reset) begin 
			for(int i = 0; i < 16; i++)
				savedNum[i] = 0;
			currentIndex <= 0;
			popIndex <= 0;
			numToDisplay <= 0;
		end
			
//		if(!Reset)begin
//			for (int i = 0; i < 32; i++)
//				savedNum[i] <= 0;
		
//		if(State == rdy) 
//			numToDisplay <= sixBitNum;
//		else if(State == push) begin
//			numToDisplay <= savedNum[currentIndex];
//			if (!KEY1) begin
//				if (ignore == 1)
//					IgnoreTimer <= IgnoreTimer + 23'b1;
//				else if (ignore == 0) begin
//					savedNum[currentIndex] <= sixBitNum;
//					currentIndex <= currentIndex + 1;
//					ignore <= 1;
//				end
//			end
//		end
//		else begin
//			if (!KEY1)
//				if (ignore == 1)
//					IgnoreTimer <= IgnoreTimer + 23'b1;
//				else if (ignore == 0) begin
//					numToDisplay <= savedNum[currentIndex];
//					currentIndex <= currentIndex - 1;
//					ignore <= 1;
//				end
//			end
//		end
		
//			if (ignore == 1)
//				IgnoreTimer <= IgnoreTimer + 23'b1;
//			else if (ignore == 0) begin
//				if(!KEY1) begin
//					savedNum[currentIndex] <= int'(sixBitNum);
//					numToDisplay <= savedNum[currentIndex];
//					currentIndex <= currentIndex + 1;
//					end
//		
//				if(!Reset) begin
//					numToDisplay <= savedNum[10];
//					end
//					
//				ignore <= 1;
//			end

		
		
//		if (ignore == 1)
//				IgnoreTimer <= IgnoreTimer + 23'b1;
//				
//		else if (ignore == 0) begin
//			if(!Reset && toggle == 1) begin
//				toggle <= 0;
//				numToDisplay <= sixBitNum;
//				savedNum[currentIndex] <= sixBitNum;
//				currentIndex <= currentIndex + 1;
//			end
//			if(!KEY1 && toggle == 1) begin
//				toggle <= 0;
//				if(currentIndex == 0)
//					popIndex = 0;
//				else
//				popIndex = currentIndex - 1;
//				
//				numToDisplay <= savedNum[popIndex];
//				currentIndex <= currentIndex - 1;
//			end
//			
//			ignore <= 1;
//		end
		
		if(State == rdy) begin
//			numToDisplay <= sixBitNum;
			rdyLight = 0;
			pushLight = 1;
			popLight = 1;
		end
		
		else if(State == push)begin
//			numToDisplay <= sixBitNum;
			rdyLight = 1;
			pushLight = 0;
			popLight = 1;	
			if (ignore == 1)
				IgnoreTimer <= IgnoreTimer + 23'b1;
			else begin
				if(!KEY1 && toggle == 1 && currentIndex < 16) begin
					toggle <= 0;
			//		numToDisplay <= sixBitNum;
					savedNum[currentIndex] <= sixBitNum;
					currentIndex <= currentIndex + 1;
				end			
				ignore <= 1;
			end
		end
		
		else begin
			rdyLight = 1;
			pushLight = 1;
			popLight = 0;
			if (ignore == 1)
				IgnoreTimer <= IgnoreTimer + 23'b1;
			else begin
				if(!KEY1 && toggle == 1) begin
					toggle <= 0;
					if(currentIndex == 0)
						popIndex = 0;
					else begin
						popIndex = currentIndex - 1;
				//		numToDisplay <= popIndex;
						numToDisplay <= savedNum[popIndex];
						currentIndex <= currentIndex - 1;
					end
				end
				ignore <= 1;
			end
		end
		
		
		if (IgnoreTimer  == 23'd5000000) begin
			IgnoreTimer <= 23'd0;
			ignore <= 0;
		end
//		if(State == rdy)begin
//			numToDisplay <= savedNum[currentIndex];
//			rdyLight = 0;
//			pushLight = 1;
//			popLight = 1;
//			end
//		else if(State == push) begin
//				rdyLight = 1;
//				pushLight = 0;
//				popLight = 1;
//				numToDisplay <= savedNum[currentIndex - 1];
//			if(currentIndex < 31) begin
//				if(KEY1) begin
//					savedNum[currentIndex] <= sixBitNum;
//					currentIndex <= currentIndex + 1;
//					end
//				end
//			end
//		else begin
//				rdyLight = 1;
//				pushLight = 1;
//				popLight = 0;
//			if(currentIndex > 0) begin
//				if(KEY1)
//					numToDisplay <= savedNum[currentIndex];
//					currentIndex <= currentIndex - 1;
//				end
//			end
		
		case (numToDisplay / 10) 
			'd1: tenSec <= 7'b1111001;
			'd2: tenSec <= 7'b0100100;
			'd3: tenSec <= 7'b0110000;
			'd4: tenSec <= 7'b0011001;
			'd5: tenSec <= 7'b0010010;
			'd6: tenSec <= 7'b0000010;
			'd7: tenSec <= 7'b1111000;
			'd8: tenSec <= 7'b0000000;
			'd9: tenSec <= 7'b0011000;
			default: tenSec <= 7'b1000000; //sets oneSec to 0
		endcase	
					
		case (numToDisplay % 10)
			'd1: oneSec <= 7'b1111001;
			'd2: oneSec <= 7'b0100100;
			'd3: oneSec <= 7'b0110000;
			'd4: oneSec <= 7'b0011001;
			'd5: oneSec <= 7'b0010010;
			'd6: oneSec <= 7'b0000010;
			'd7: oneSec <= 7'b1111000;
			'd8: oneSec <= 7'b0000000;
			'd9: oneSec <= 7'b0011000;
			default: oneSec <= 7'b1000000; //sets oneSec to 0
		endcase
		
	end
  

  //
  // Next state generation logic
  //

	always @(do_op)
	begin
		case(State)
			rdy:
				begin
					if(do_op == 2)
						NextState = push;
					else if(do_op == 1)
						NextState = pop;
					else
						NextState = rdy;
				end
				
			push:
				begin
					if(do_op == 2)
						NextState = push;
					else if(do_op == 1)
						NextState = pop;
					else
						NextState = rdy;
				end
				

			pop:
				begin
					if(do_op == 2)
						NextState = push;
					else if(do_op == 1)
						NextState = pop;
					else
						NextState = rdy;
				end
		endcase
	end

  
endmodule
