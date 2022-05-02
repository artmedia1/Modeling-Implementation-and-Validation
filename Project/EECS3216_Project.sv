module EECS3216_Project(input MAX10_CLK1_50, input KEY[1:0], output [9:0] LEDR, 
								output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
									
enum {rdy, win_State, lose_State, speed_one, speed_two, speed_three} State, NextState;

parameter TRUE = 1'b1;
parameter FALSE = 1'b0;
parameter ON = 1'b1;
parameter OFF = 1'b0;
reg [31:0] counter;
reg [31:0] D = 32'd50000000;
integer lightPattern = 0;
integer gameSpeed = 1;
reg toggle = 1;
reg blink = ON;

	initial begin
		State = rdy;
		NextState = rdy;
		HEX5 <= 7'b1111111;
		HEX4 <= 7'b1111111;		
		HEX3 <= 7'b1111111;
		HEX2 <= 7'b1111111;
		HEX1 <= 7'b1111111;
		HEX0 <= 7'b1111111;
	end

	always_ff@(posedge MAX10_CLK1_50)begin
		State <= NextState;
			
		if(!KEY[0]) begin //Reset
			State <= rdy;
			lightPattern <= 0;
			gameSpeed <= 1;
			LEDR <= 10'b0000000000;
			HEX0 <= 7'b1111111;
			HEX1 <= 7'b1111111;
			HEX2 <= 7'b1111111;
			HEX3 <= 7'b1111111;
			HEX4 <= 7'b1111111;
			HEX5 <= 7'b1111111;
			blink = ON;
		end
		
		if(KEY[1])
			toggle <= 1;
		
				
		if(!KEY[1] && toggle == 1 && State != rdy)begin 
			toggle <= 0;
			if(lightPattern != 4) begin// WHY FOUR INSTEAD OF 5? IDK MY LEDs ARE LIKE ONE DIGIT OFF; MENTAL MATH WAS OFF BY 1?
				gameSpeed <= 0;			//If the LED is not on LEDR5, then lose game, gameSpeed 0
			end
			else begin
				lightPattern <= 0;
				
				if(State != speed_three && State != win_State && State != lose_State)
					blink = ON;
					
				gameSpeed <= gameSpeed + 1;
			end	
		end	
			
		if(State == rdy) begin
			D = 32'd25000000;
	   end
		else if(State == speed_one) begin
			HEX5 <= 7'b0010010;
			HEX4 <= 7'b0001100;
			HEX3 <= 7'b0000110;
			HEX2 <= 7'b0000110;
			HEX1 <= 7'b0100001;
			HEX0 <= 7'b1111001;
			D = 32'd50000000;
	   end
		else if(State == speed_two) begin
			HEX5 <= 7'b0010010;
			HEX4 <= 7'b0001100;
			HEX3 <= 7'b0000110;
			HEX2 <= 7'b0000110;
			HEX1 <= 7'b0100001;
			HEX0 <= 7'b0100100;
			D = 32'd25000000;
	   end
		else if(State == speed_three) begin
			HEX5 <= 7'b0010010;
			HEX4 <= 7'b0001100;
			HEX3 <= 7'b0000110;
			HEX2 <= 7'b0000110;
			HEX1 <= 7'b0100001;
			HEX0 <= 7'b0110000;
			D = 32'd12500000;
	   end
		else if (State == lose_State) begin //spells lose
			HEX5 <= 7'b1111111;
			HEX4 <= 7'b1111111;			
			HEX3 <= 7'b1000111;
			HEX2 <= 7'b1000000;
			HEX1 <= 7'b0010010;
			HEX0 <= 7'b0000110;	
		end
		else if (State == win_State) begin //spells yay
			HEX5 <= 7'b1111111;
			HEX4 <= 7'b1111111;
			HEX3 <= 7'b1111111;			
			HEX2 <= 7'b0010001;
			HEX1 <= 7'b0001000;
			HEX0 <= 7'b0010001;	
		end		
		
		
		counter++;
		
		
		
		if(counter >= (D - 1))begin
			counter <= 0;

			if(State == rdy && blink == ON) begin //Game ready state	
				if(lightPattern < 8) begin		//blinks SW5
					LEDR[5] <= ~LEDR[5];
					lightPattern <= lightPattern + 1;
				end
				else begin //Changes blink to 0, switches state to speed_one
					blink <= OFF;
					LEDR[5] <= 0;
					lightPattern <= 9;
				end
			end
			else if (State == speed_one || State == speed_two || State == speed_three) begin //logic for rotating the lights between LEDR 0-9
				
				if (lightPattern == 9) begin
					LEDR[0] <= 0;
					LEDR[9] <= 1;
					lightPattern <= 8;
					end
				else if(lightPattern < 9 && lightPattern > 4) begin
					LEDR[lightPattern + 1] <= 0;
					LEDR[lightPattern] <= 1;
					lightPattern <= lightPattern - 1;
					end
				else if (lightPattern == 4)begin
					LEDR[lightPattern + 1] <= 0;
					LEDR[4] <= 1;
					lightPattern <= lightPattern - 1;
					end
				else if (lightPattern < 4 && lightPattern > 0)begin
					LEDR[lightPattern + 1] <= 0;
					LEDR[lightPattern] <= 1;
					lightPattern <= lightPattern - 1;
					end
				else begin
					LEDR[0] <= 1;
					LEDR[1] <= 0;
					lightPattern <= 9;
					end		
			end
		end
	end
	
	always @(gameSpeed or blink)begin //NextState logic
			
		case (State)
			rdy: begin
					if(blink == ON)
						NextState <= rdy;
					else
						if(gameSpeed == 0)
							NextState <= lose_State;					
						else if(gameSpeed == 1)
							NextState <= speed_one;
						else if(gameSpeed == 2)
							NextState <= speed_two;
						else if(gameSpeed == 3)
							NextState <= speed_three;
						else if(gameSpeed == 4)
							NextState <= win_State;
					end
			speed_one:
					if(gameSpeed == 0)
						NextState <= lose_State;
					else if(gameSpeed == 2)
						NextState <= rdy;
					else
						NextState <= speed_one;
			speed_two:
					if(gameSpeed == 0)
						NextState <= lose_State;
					else if (gameSpeed == 3)
						NextState <= rdy;
					else
						NextState <= speed_two;
			speed_three:
					if(gameSpeed == 0)
						NextState <= lose_State;
					else if (gameSpeed == 4)
						NextState <= win_State;	
					else NextState <= speed_three;
		endcase
	
	end
	
endmodule 	