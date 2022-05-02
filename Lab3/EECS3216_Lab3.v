module EECS3216_Lab3 (cin, temp, sevenSegDisplay, leftLights, rightLights, leftLightSwitch, rightLightSwitch);

input cin, leftLightSwitch, rightLightSwitch;

reg[31:0] count;
reg [1:0] rightLedCount;
reg [1:0] leftLedCount;
reg [1:0] rightContinuousBlinker;
reg [1:0] leftContinuousBlinker;
reg error = 0;


output reg [6:0] sevenSegDisplay;
output reg [2:0] leftLights;
output reg [2:0] rightLights;
output reg [3:0] temp;

parameter D = 32'd25000000;

always @(posedge cin)
begin
	if (!leftLightSwitch) begin
		leftLights <= 3'b000;
		leftLedCount <= 0;
		leftContinuousBlinker <= 0;
	end
	
	if (!rightLightSwitch) begin
		rightLights <= 3'b000;
		rightLedCount <= 0;
		rightContinuousBlinker <= 0;
	end 
	
	if (leftLightSwitch & rightLightSwitch) begin
		error <= 1;
		rightLedCount <= 0;
		leftLedCount <= 0;
		rightContinuousBlinker <= 0;
		leftContinuousBlinker <= 0;
	end	
	else begin
		sevenSegDisplay <= 7'b1111111;
		error <= 0;
	end		
	count <= count + 32'd1;
	
	if (count >= (D - 1)) begin
         count <= 32'd0;
			if (error == 1) begin
				rightLights <= 3'b000;
				leftLights <= 3'b000;
				sevenSegDisplay <= 7'b0000110;
			end
			else if (leftLightSwitch) begin
				if (leftContinuousBlinker == 2'd3)
					leftLights <= 3'b111;
				else begin
					case (leftLedCount)
						2'd0: leftLights <= 3'b001;
						2'd1: leftLights <= 3'b011;
						2'd2: leftLights <= 3'b111;
						default: leftLights <= 3'b000;
					endcase
					if (leftLedCount == 2'd3) begin
						leftLedCount <= 0;
						leftContinuousBlinker <= leftContinuousBlinker + 2'd1;
					end
					else
						leftLedCount <= leftLedCount + 2'd1;
				end
			end
			else begin
				if (rightContinuousBlinker == 2'd3)
					rightLights <= 3'b111;
				else begin
					case (rightLedCount)
						2'd0: rightLights <= 3'b100;
						2'd1: rightLights <= 3'b110;
						2'd2: rightLights <= 3'b111;
						default: rightLights <= 3'b000;
					endcase
					if (rightLedCount == 2'd3) begin
						rightLedCount <= 0;
						rightContinuousBlinker <= rightContinuousBlinker + 2'd1;
					end
					else
						rightLedCount <= rightLedCount + 2'd1;
				end
			end
	end
end
endmodule 