local arg = { ... }
-- 8-bit registers
-- Main Registers
-- AX primary accumulator 
AL = 0
AH = 0
-- BX base, accumulator 
BL = 0
BH = 0
-- CX counter, accumulator
CL = 0
CH = 0
-- DX accumulator, extended acc
DL = 0
DH = 0

-- 16-bit registers
-- Index Registers
-- Source Index 
SI  = 0
-- Destination Index 
DI  = 0
-- Base Pointer 
BP = 0
-- Stack Pointer 
SP = 0

-- Program Counter
-- Instruction Pointer 
IP = 0

-- Segment Registers
-- Code Segment
CS = 0
-- Data Segment
DS = 0
-- Extra Segment
ES = 0
-- Stack Segment
SS  = 0

-- Status Registers
-- Overflow Flag
OF = 0
-- Direction Flag
DF = 0
-- Iterrupt Flag
IF = 0
-- Trap Flag
TF = 0
-- Sign Flag
SF = 0
-- Zero Flag
ZF = 0
-- Auxiliary carry Flag
AF = 0
-- Parity Flag
PF = 0
-- Carry Flag
CF = 0

function getIndex(x,y,width)
	return x+y*width
end

-- Video RAM at 8000h
RAM = {}

-- Load Program
local file = fs.open( arg[1], "rb" )
for i=1,16384 do -- Initialize RAM with Program (16KB)
	byteRead = file.read()
	RAM[i] = byteRead
end

-- Convert number to bits
function toBits(num,bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return table.concat(t)
end

-- Convert number to hex
function decimalToHex(num)
	numinit = num
    if num == 0 then
        return '0000'
    end
    local neg = false
    if num < 0 then
        neg = true
        num = num * -1
    end
    local hexstr = "0123456789ABCDEF"
    local result = ""
    while num > 0 do
        local n = num % 16
        result = string.sub(hexstr, n + 1, n + 1) .. result
        num = math.floor(num / 16)
    end
    if neg then
        result = '-' .. result
    end
    if numinit < 16 then
        result = '0' .. result
    end
    if numinit < 256 then
        result = '0' .. result
    end
    if numinit < 4096 then
        result = '0' .. result
    end
    return result
end

-- Update Screen
function updateScreen()
	for y=0,25 do --Y
		for x=0,80 do -- X
			index = getIndex(x,y,80)
			term.setCursorPos(x,y+1)
			io.write(string.char(RAM[8000+index]))
		end
	end
end

opCode = 0
bytesWanted = 0

while (IP < 16384) do -- Play Program
	IP = IP+1
	if (bytesWanted == 0) then -- Read Opcodes if no bytes are wanted
		if (RAM[IP] == 4) then -- ADD to AL
			bytesWanted = 1
			opCode = 4
		end
		if (RAM[IP] == 5) then -- ADD to AX
			bytesWanted = 2
			opCode = 5
		end
		
		-- ADC
		if (RAM[IP] == 20) then -- ADC AL
			bytesWanted = 1
			opCode = 20
		end 
		if (RAM[IP] == 21) then -- ADC AX
			bytesWanted = 2
			opCode = 21
		end 
		
		-- INC
		if (RAM[IP] == 64) then -- INC AX
			bytesWanted = 0
			AXs = toBits(tonumber(toBits(AH,8) .. toBits(AL,8),2)+tonumber(toBits(0,8) .. toBits(1,8),2),16)
			if (tonumber(AXs,2) == 0) then
				ZF = 1
			end
			if (tonumber(AXs,2) < 0) then
				SF = 1
			end
			if (tonumber(AXs,2) > 255) then
				AXs = toBits(65535,16)
				OF = 1
			end
			AH = tonumber(string.sub(AXs, 1, 8),2)
			AL = tonumber(string.sub(AXs, 9, 16),2)
			opCode = 64
		end 
		if (RAM[IP] == 65) then -- INC CX
			bytesWanted = 0
			CXs = toBits(tonumber(toBits(CH,8) .. toBits(CL,8),2)+tonumber(toBits(0,8) .. toBits(1,8),2),16)
			if (tonumber(CXs,2) == 0) then
				ZF = 1
			end
			if (tonumber(CXs,2) < 0) then
				SF = 1
			end
			if (tonumber(CXs,2) > 255) then
				CXs = toBits(65535,16)
				OF = 1
			end
			CH = tonumber(string.sub(CXs, 1, 8),2)
			CL = tonumber(string.sub(CXs, 9, 16),2)
			opCode = 65
		end 
		if (RAM[IP] == 66) then -- INC DX
			bytesWanted = 0
			DXs = toBits(tonumber(toBits(DH,8) .. toBits(DL,8),2)+tonumber(toBits(0,8) .. toBits(1,8),2),16)
			if (tonumber(DXs,2) == 0) then
				ZF = 1
			end
			if (tonumber(DXs,2) < 0) then
				SF = 1
			end
			if (tonumber(DXs,2) > 255) then
				DXs = toBits(65535,16)
				OF = 1
			end
			DH = tonumber(string.sub(DXs, 1, 8),2)
			DL = tonumber(string.sub(DXs, 9, 16),2)
			opCode = 66
		end 
		if (RAM[IP] == 67) then -- INC BX
			bytesWanted = 0
			BXs = toBits(tonumber(toBits(BH,8) .. toBits(BL,8),2)+tonumber(toBits(0,8) .. toBits(1,8),2),16)
			if (tonumber(BXs,2) == 0) then
				ZF = 1
			end
			if (tonumber(BXs,2) < 0) then
				SF = 1
			end
			if (tonumber(BXs,2) > 255) then
				BXs = toBits(65535,16)
				OF = 1
			end
			BH = tonumber(string.sub(BXs, 1, 8),2)
			BL = tonumber(string.sub(BXs, 9, 16),2)
			opCode = 67
		end 
		
		-- NOP
		if (opCode == 144) then -- NOP
			bytesWanted = 0
			opCode = 144
		end
		
		-- MOV
		-- Move immediate to Lows
		if (RAM[IP] == 176) then -- Move immediate to AL
			bytesWanted = 1
			opCode = 176
		end 
		if (RAM[IP] == 177) then -- Move immediate to CL
			bytesWanted = 1
			opCode = 177
		end
		if (RAM[IP] == 178) then -- Move immediate to DL
			bytesWanted = 1
			opCode = 178
		end
		if (RAM[IP] == 179) then -- Move immediate to BL
			bytesWanted = 1
			opCode = 179
		end
		
		-- Move immediate to Highs
		if (RAM[IP] == 180) then -- Move immediate to AH
			bytesWanted = 1
			opCode = 180
		end 
		if (RAM[IP] == 181) then -- Move immediate to CH
			bytesWanted = 1
			opCode = 181
		end
		if (RAM[IP] == 182) then -- Move immediate to DH
			bytesWanted = 1
			opCode = 182
		end
		if (RAM[IP] == 183) then -- Move immediate to BH
			bytesWanted = 1
			opCode = 183
		end
		
		-- Move immediate to AX
		if (RAM[IP] == 184) then -- Move immediate to AX
			bytesWanted = 2
			opCode = 184
		end
		
		if (RAM[IP] == 185) then -- Move immediate to CX
			bytesWanted = 2
			opCode = 185
		end
		
		if (RAM[IP] == 186) then -- Move immediate to DX
			bytesWanted = 2
			opCode = 186
		end
		
		if (RAM[IP] == 187) then -- Move immediate to BX
			bytesWanted = 2
			opCode = 187
		end
		
		-- JMP
		if (opCode == 233) then -- Jump near relative to next instruction
			bytesWanted = 2
			opCode = 233
		end
		
		if (RAM[IP] == 235) then -- Jump short relative to next instruction
			bytesWanted = 1
			opCode = 235
		end
		
	else 	-- If bytes are wanted, do what that instruction does
		if (opCode == 4) then ---- ADD to AL
			AL = AL+RAM[IP]
			if (AL > 255) then
				AL = 255
				CF = 1
			end
			if (AL == 0) then
				ZF = 1
			end
			if (AL < 0) then
				SF = 1
			end
			if (AL > 255) then
				AL = 255
				OF = 1
			end
			bytesWanted = 0
		end
		
		if (opCode == 5) then ---- ADD to AX
			if (bytesWanted == 2) then
				--AL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				AXs = toBits(tonumber(toBits(AH,8) .. toBits(AL,8),2)+tonumber(toBits(RAM[IP],8) .. toBits(RAM[IP-1],8),2),16)
				if (tonumber(AXs,2) > 65535) then
					AXs = toBits(65535,16)
					CF = 1
				end
				if (tonumber(AXs,2) == 0) then
					ZF = 1
				end
				if (tonumber(AXs,2) < 0) then
					SF = 1
				end
				if (tonumber(AXs,2) > 255) then
					AXs = toBits(65535,16)
					OF = 1
				end
				AH = tonumber(string.sub(AXs, 1, 8),2)
				AL = tonumber(string.sub(AXs, 9, 16),2)
				bytesWanted = 0
			end
		end
		
		if (opCode == 20) then ---- ADD with Carry to AL
			AL = AL+RAM[IP]+CF
			if (AL > 255) then
				AL = 255
				CF = 1
			end
			if (AL == 0) then
				ZF = 1
			end
			if (AL < 0) then
				SF = 1
			end
			if (AL > 255) then
				AL = 255
				OF = 1
			end
			bytesWanted = 0
		end
		
		if (opCode == 5) then ---- ADD with Carry to AX
			if (bytesWanted == 2) then
				--AL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				AXs = toBits(tonumber(toBits(AH,8) .. toBits(AL,8),2)+tonumber(toBits(RAM[IP],8) .. toBits(RAM[IP-1],8),2)+tonumber(toBits(CP,16),2),16)
				if (tonumber(AXs,2) > 65535) then
					AXs = toBits(65535,16)
					CF = 1
				end
				if (tonumber(AXs,2) == 0) then
					ZF = 1
				end
				if (tonumber(AXs,2) < 0) then
					SF = 1
				end
				if (tonumber(AXs,2) > 255) then
					AXs = toBits(65535,16)
					OF = 1
				end
				AH = tonumber(string.sub(AXs, 1, 8),2)
				AL = tonumber(string.sub(AXs, 9, 16),2)
				bytesWanted = 0
			end
		end
		
		-- Move immediate to Lows
		if (opCode == 176) then -- Move immediate to AL
			AL = RAM[IP]
			bytesWanted = 0
		end
		if (opCode == 177) then -- Move immediate to CL
			CL = RAM[IP]
			bytesWanted = 0
		end
		if (opCode == 178) then -- Move immediate to DL
			DL = RAM[IP]
			bytesWanted = 0
		end
		if (opCode == 179) then -- Move immediate to BL
			BL = RAM[IP]
			bytesWanted = 0
		end
		
		-- Move immediate to Highs
		if (opCode == 180) then -- Move immediate to AH
			AH = RAM[IP]
			bytesWanted = 0
		end
		if (opCode == 181) then -- Move immediate to CH
			CH = RAM[IP]
			bytesWanted = 0
		end
		if (opCode == 182) then -- Move immediate to DH
			DH = RAM[IP]
			bytesWanted = 0
		end
		if (opCode == 183) then -- Move immediate to BH
			BH = RAM[IP]
			bytesWanted = 0
		end
		
		-- Move immediate to 16-bit
		if (opCode == 184) then -- Move immediate to AX
			if (bytesWanted == 2) then
				AL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				AH = RAM[IP]				
				bytesWanted = 0
			end
		end
		
		if (opCode == 185) then -- Move immediate to CX
			if (bytesWanted == 2) then
				CL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				CH = RAM[IP]				
				bytesWanted = 0
			end
		end
		
		if (opCode == 186) then -- Move immediate to DX
			if (bytesWanted == 2) then
				DL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				DH = RAM[IP]				
				bytesWanted = 0
			end
		end
		
		if (opCode == 187) then -- Move immediate to BX
			if (bytesWanted == 2) then
				BL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				BH = RAM[IP]				
				bytesWanted = 0
			end
		end
		
		-- JMP
		if (opCode == 233) then -- Jump near relative to next instruction
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				IP = IP + tonumber(toBits(RAM[IP],8) .. toBits(RAM[IP-1],8),2)			
				bytesWanted = 0
			end
		end
		
		if (opCode == 235) then -- Jump short relative to next instruction
			IP = IP + RAM[IP]
			bytesWanted = 0
		end
	end
end
print("AX: " .. decimalToHex(tonumber(toBits(AH,8) .. toBits(AL,8),2)))
print("BX: " .. decimalToHex(tonumber(toBits(BH,8) .. toBits(BL,8),2)))
print("CX: " .. decimalToHex(tonumber(toBits(CH,8) .. toBits(CL,8),2)))
print("DX: " .. decimalToHex(tonumber(toBits(DH,8) .. toBits(DL,8),2)))
print("")
print("CF: " .. CF)
print("OF: " .. OF)