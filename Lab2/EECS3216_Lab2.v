module EECS3216_Lab2 (cin, reset, led, switch, holder);

input cin, reset;
input switch; //either on or off
//SWITCH DOWN = 0;
//counterOrClockControl - SW9
//increaseOrDecrease - SW8
//setOrStartClock - SW7
//pause = top button
//reset = bottom button

 
reg[31:0] count;
reg ignore = 0;
reg toggle;
reg twoSecondDelay = 1;
reg [1:0] delay = 2'b0;
reg [22:0] timer = 23'b0;
reg [3:0] currentLed = 4'b0;

output reg [7:0] led;
output reg [1:0] holder = 2'b00;


reg [31:0] D = 32'd25000000;


always @(posedge cin)
begin
		if (ignore == 1)begin
			timer <= timer + 23'b1;
		end
		else if (reset == 1'b0)begin
			led <= 8'b00000000;
			currentLed <= 0;
			D <= 32'd25000000;
			twoSecondDelay <= 1;
			ignore <= 1;
		end
		
		if (timer  == 23'd5000000) begin
			timer <= 23'd0;
			ignore <= 0;
		end

		count <= count + 32'd1;
		
      if (count >= (D - 1)) begin // maybe make this D/2
         count <= 32'd0;
			toggle <= ~toggle;
			
			if(toggle)begin
				case (currentLed)
					4'd1: led <= 8'b10000000;
					4'd2: led <= 8'b11000000;
					4'd3: led <= 8'b11100000;
					4'd4: led <= 8'b11110000;
					4'd5: led <= 8'b11111000;
					4'd6: led <= 8'b11111100;
					4'd7: led <= 8'b11111110;
					4'd8: led <= 8'b11111111;
					default: led <= 8'b00000000;
				endcase

				
				if(currentLed == 4'd8)begin
					currentLed <= 4'd0;
				//	D <= 32'd25000000;
					twoSecondDelay <= 1;
				end
				else begin
					currentLed <= currentLed + 4'd1;
				end
			end
			else begin
				if(switch)begin
					D <= 32'd25000000;
					twoSecondDelay <= 1;
				end
				else begin					
					if(twoSecondDelay == 1 && currentLed > 0) begin
						D <= 32'd50000000;
						twoSecondDelay <= 0;
					end
					else begin
						D <= D / 2;
					end
				end
			end
		end
end
endmodule

