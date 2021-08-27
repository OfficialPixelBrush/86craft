local arg = { ... }

BitLimit16 = 65536
BitLimit8  = 255
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

function combineBytesToWord(high,low)
	return tonumber(toBits(high,8) .. toBits(low,8),2)
end

function checkBit(bit, number) 
	return string.sub(toBits(number), bit, bit)
end


while (IP < 16384) do -- Play Program
	IP = IP+1
	if (bytesWanted == 0) then -- Read Opcodes if no bytes are wanted
		if (RAM[IP] == 4) then -- ADD to AL
			bytesWanted = 1
			opCode = 4
		elseif (RAM[IP] == 5) then -- ADD to AX
			bytesWanted = 2
			opCode = 5
		elseif (RAM[IP] == 12) then -- OR AL
			bytesWanted = 1
			opCode = 12
		elseif (RAM[IP] == 13) then -- OR AX
			bytesWanted = 2
			opCode = 13
		elseif (RAM[IP] == 20) then -- ADC AL
			bytesWanted = 1
			opCode = 20
		elseif (RAM[IP] == 21) then -- ADC AX
			bytesWanted = 2
			opCode = 21
		elseif (RAM[IP] == 64) then -- INC AX
			bytesWanted = 0
			AXs = toBits(combineBytesToWord(AH,AL)+combineBytesToWord(0,1),16)
			AH = tonumber(string.sub(AXs, 1, 8),2)
			AL = tonumber(string.sub(AXs, 9, 16),2)
			opCode = 64
		elseif (RAM[IP] == 65) then -- INC CX
			bytesWanted = 0
			CXs = toBits(combineBytesToWord(CH,CL)+combineBytesToWord(0,1),16)
			CH = tonumber(string.sub(CXs, 1, 8),2)
			CL = tonumber(string.sub(CXs, 9, 16),2)
			opCode = 65
		elseif (RAM[IP] == 66) then -- INC DX
			bytesWanted = 0
			DXs = toBits(combineBytesToWord(DH,DL)+combineBytesToWord(0,1),16)
			DH = tonumber(string.sub(DXs, 1, 8),2)
			DL = tonumber(string.sub(DXs, 9, 16),2)
			opCode = 66
		elseif (RAM[IP] == 67) then -- INC BX
			bytesWanted = 0
			BXs = toBits(combineBytesToWord(BH,BL)+combineBytesToWord(0,1),16)
			BH = tonumber(string.sub(BXs, 1, 8),2)
			BL = tonumber(string.sub(BXs, 9, 16),2)
			opCode = 67
		elseif (RAM[IP] == 68) then -- INC SP
			bytesWanted = 0
			SP = SP+1
			if (SP > BitLimit16) {	-- Overflow
				SP = SP - BitLimit16
			}
			opCode = 68
		elseif (RAM[IP] == 69) then -- INC BP
			bytesWanted = 0
			BP = BP+1
			if (BP > BitLimit16) {	-- Overflow
				BP = BP - BitLimit16
			}
			opCode = 69
		elseif (RAM[IP] == 70) then -- INC SI
			bytesWanted = 0
			SI = SI+1
			if (SI > BitLimit16) {	-- Overflow
				SI = SI - BitLimit16
			}
			opCode = 70
		elseif (RAM[IP] == 71) then -- INC DI
			bytesWanted = 0
			DI = DI+1
			if (DI > BitLimit16) {	-- Overflow
				DI = Di - BitLimit16
			}
			opCode = 71
		elseif (RAM[IP] == 72) then -- DEC AX
			bytesWanted = 0
			AXs = toBits(combineBytesToWord(AH,AL)-combineBytesToWord(0,1),16)
			AH = tonumber(string.sub(AXs, 1, 8),2)
			AL = tonumber(string.sub(AXs, 9, 16),2)
			opCode = 72
		elseif (RAM[IP] == 73) then -- DEC CX
			bytesWanted = 0
			CXs = toBits(combineBytesToWord(CH,CL)-combineBytesToWord(0,1),16)
			CH = tonumber(string.sub(CXs, 1, 8),2)
			CL = tonumber(string.sub(CXs, 9, 16),2)
			opCode = 73
		elseif (RAM[IP] == 74) then -- DEC DX
			bytesWanted = 0
			DXs = toBits(combineBytesToWord(DH,DL)-combineBytesToWord(0,1),16)
			DH = tonumber(string.sub(DXs, 1, 8),2)
			DL = tonumber(string.sub(DXs, 9, 16),2)
			opCode = 74
		elseif (RAM[IP] == 75) then -- DEC BX
			bytesWanted = 0
			BXs = toBits(combineBytesToWord(BH,BL)-combineBytesToWord(0,1),16)
			BH = tonumber(string.sub(BXs, 1, 8),2)
			BL = tonumber(string.sub(BXs, 9, 16),2)
			opCode = 75
		elseif (RAM[IP] == 76) then -- DEC SP
			bytesWanted = 0
			SP = SP+1
			if (SP < 0) {	-- Underflow
				SP = SP + BitLimit16
			}
			opCode = 76
		elseif (RAM[IP] == 77) then -- DEC BP
			bytesWanted = 0
			BP = BP+1
			if (BP < 0) {	-- Underflow
				BP = BP + BitLimit16
			}
			opCode = 77
		elseif (RAM[IP] == 78) then -- DEC SI
			bytesWanted = 0
			SI = SI+1
			if (SI < 0) {	-- Underflow
				SI = SI + BitLimit16
			}
			opCode = 78
		elseif (RAM[IP] == 79) then -- DEC DI
			bytesWanted = 0
			DI = DI+1
			if (DI < 0) {	-- Underflow
				DI = Di + BitLimit16
			}
			opCode = 79
		elseif (opCode == 144) then -- NOP
			bytesWanted = 0
			opCode = 144
		elseif (RAM[IP] == 176) then -- Move Byte to Register/Memory
			bytesWanted = 1
			opCode = 176
		elseif (RAM[IP] == 176) then -- Move immediate to AL
			bytesWanted = 1
			opCode = 176
		elseif (RAM[IP] == 177) then -- Move immediate to CL
			bytesWanted = 1
			opCode = 177
		elseif (RAM[IP] == 178) then -- Move immediate to DL
			bytesWanted = 1
			opCode = 178
		elseif (RAM[IP] == 179) then -- Move immediate to BL
			bytesWanted = 1
			opCode = 179
		elseif (RAM[IP] == 180) then -- Move immediate to AH
			bytesWanted = 1
			opCode = 180
		elseif (RAM[IP] == 181) then -- Move immediate to CH
			bytesWanted = 1
			opCode = 181
		elseif (RAM[IP] == 182) then -- Move immediate to DH
			bytesWanted = 1
			opCode = 182
		elseif (RAM[IP] == 183) then -- Move immediate to BH
			bytesWanted = 1
			opCode = 183
		elseif (RAM[IP] == 184) then -- Move immediate to AX
			bytesWanted = 2
			opCode = 184
		elseif (RAM[IP] == 185) then -- Move immediate to CX
			bytesWanted = 2
			opCode = 185
		elseif (RAM[IP] == 186) then -- Move immediate to DX
			bytesWanted = 2
			opCode = 186
		elseif (RAM[IP] == 187) then -- Move immediate to BX
			bytesWanted = 2
			opCode = 187
		elseif (RAM[IP] == 188) then -- Move immediate to SP
			bytesWanted = 2
			opCode = 188
		elseif (RAM[IP] == 189) then -- Move immediate to BP
			bytesWanted = 2
			opCode = 189
		elseif (RAM[IP] == 190) then -- Move immediate to SI
			bytesWanted = 2
			opCode = 190
		elseif (RAM[IP] == 191) then -- Move immediate to DI
			bytesWanted = 2
			opCode = 191
		elseif (RAM[IP] == 205) then -- Move immediate to DI
			bytesWanted = 1
			opCode = 205
		elseif (opCode == 233) then -- Jump near relative to next instruction
			bytesWanted = 2
			opCode = 233
		elseif (RAM[IP] == 235) then -- Jump short relative to next instruction
			bytesWanted = 1
			opCode = 235
		end
		
	else 	-- If bytes are wanted, do what that instruction does
		if (opCode == 4) then ---- ADD to AL
			AL = AL+RAM[IP]
			if (checkBit(1,AL) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end	
			bytesWanted = 0
		elseif (opCode == 5) then ---- ADD to AX
			if (bytesWanted == 2) then
				--AL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				AXs = toBits(combineBytesToWord(AH,AL)+combineBytesToWord(RAM[IP],RAM[IP-1]),16)
				AH = tonumber(string.sub(AXs, 1, 8),2)
				AL = tonumber(string.sub(AXs, 9, 16),2)
				--print("ADD AX " .. decimalToHex(IP))
				if (checkBit(1,AXs) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end	
				if (128-tonumber(AXs,2) == 0) then
					ZF = 1
				else 
					ZF = 0
				end
				bytesWanted = 0
			end
		elseif (opCode == 12) then ---- Or Immediate with AL
			ALbin = toBits(AL,8)
			RAMbin = toBits(RAM[IP],8)
			ALor = ""
			for i=1,8 do
				--if ((RAMbin[i] == "1") or (ALbin[i] == "1")) then
				if ((string.sub(RAMbin, i, i) == "1") or (string.sub(ALbin, i, i) == "1")) then
					ALor = ALor .. "1"
				else 
					ALor = ALor .. "0"
				end
			end
			AL = tonumber(ALor,2)
			--print("OR AL " .. decimalToHex(IP))
			if (checkBit(1,AL) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end	
			bytesWanted = 0
		elseif (opCode == 13) then ---- Or Immediate with AX
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				AXbin = toBits(combineBytesToWord(AH,AL),16)
				RAMbin = toBits(combineBytesToWord(RAM[IP],RAM[IP-1]),16)
				AXor = ""
				for i=1,16 do
					if ((string.sub(RAMbin, i, i) == "1") or (string.sub(AXbin, i, i) == "1")) then
						AXor = AXor .. "1"
					else 
						AXor = AXor .. "0"
					end
				end
				AH = tonumber(string.sub(AXor, 1, 8),2)
				AL = tonumber(string.sub(AXor, 9, 16),2)
				--print("OR AX " .. decimalToHex(IP))
				if (checkBit(1,AH) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end	
				bytesWanted = 0
			end
		elseif (opCode == 20) then ---- ADD with Carry to AL
			AL = AL+RAM[IP]+CF
			if (checkBit(1,AL) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end	
			bytesWanted = 0
		elseif (opCode == 21) then ---- ADD with Carry to AX
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				AXs = toBits(combineBytesToWord(AH,AL)+combineBytesToWord(RAM[IP],RAM[IP-1])+tonumber(toBits(CF,16),2),16)
				AH = tonumber(string.sub(AXs, 1, 8),2)
				AL = tonumber(string.sub(AXs, 9, 16),2)
				bytesWanted = 0
				--print("ADC AX " .. decimalToHex(IP))
				if (checkBit(1,AXs) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end		
			end
		elseif (opCode == 176) then -- Move immediate to AL
			AL = RAM[IP]
			if (checkBit(1,AL) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif (opCode == 177) then -- Move immediate to CL
			CL = RAM[IP]
			if (checkBit(1,CL) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif(opCode == 178) then -- Move immediate to DL
			DL = RAM[IP]
			if (checkBit(1,DL) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif (opCode == 179) then -- Move immediate to BL
			BL = RAM[IP]
			if (checkBit(1,BL) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif (opCode == 180) then -- Move immediate to AH
			AH = RAM[IP]
			if (checkBit(1,AH) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif (opCode == 181) then -- Move immediate to CH
			CH = RAM[IP]
			if (checkBit(1,CH) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif (opCode == 182) then -- Move immediate to DH
			DH = RAM[IP]
			if (checkBit(1,DH) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif (opCode == 183) then -- Move immediate to BH
			BH = RAM[IP]
			if (checkBit(1,BH) == "1") then -- Sign Flag Check
				SF = 1
			else 
				SF = 0
			end
			bytesWanted = 0
		elseif (opCode == 184) then -- Move immediate to AX
			if (bytesWanted == 2) then
				AL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				AH = RAM[IP]	
				if (checkBit(1,AH) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end			
				bytesWanted = 0
			end
			--print("MOV AX " .. decimalToHex(IP))
		elseif (opCode == 185) then -- Move immediate to CX
			if (bytesWanted == 2) then
				CL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				CH = RAM[IP]	
				if (checkBit(1,CH) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end						
				bytesWanted = 0
			end
		elseif (opCode == 186) then -- Move immediate to DX
			if (bytesWanted == 2) then
				DL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				DH = RAM[IP]	
				if (checkBit(1,DH) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end						
				bytesWanted = 0
			end
		elseif (opCode == 187) then -- Move immediate to BX
			if (bytesWanted == 2) then
				BL = RAM[IP]
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				BH = RAM[IP]	
				if (checkBit(1,BH) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end						
				bytesWanted = 0
			end
		elseif (opCode == 188) then -- Move immediate to SP
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				SP = combineBytesToWord(RAM[IP], RAM[IP]-1)
				if (checkBit(1,SP) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end			
				bytesWanted = 0
			end
		elseif (opCode == 189) then -- Move immediate to BP
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				BP = combineBytesToWord(RAM[IP], RAM[IP]-1)
				if (checkBit(1,BP) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end			
				bytesWanted = 0
			end
		elseif (opCode == 190) then -- Move immediate to SI
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				SI = combineBytesToWord(RAM[IP], RAM[IP]-1)
				if (checkBit(1,SI) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end		
				bytesWanted = 0
			end
		elseif (opCode == 191) then -- Move immediate to DI
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				DI = combineBytesToWord(RAM[IP], RAM[IP]-1)
				if (checkBit(1,DI) == "1") then -- Sign Flag Check
					SF = 1
				else 
					SF = 0
				end		
				bytesWanted = 0
			end
		elseif (opCode == 205) then -- INT
			--print("INT")
			if (RAM[IP] == 33) then -- INT 21
				if (AH == 9) then -- INT 21,9
					while (RAM[IP] ~= 36) do
						io.write(string.char(RAM[IP]))
						IP = IP+1
					end
				end 
			end
			bytesWanted = 0
		elseif (opCode == 233) then -- Jump near relative to next instruction
			if (bytesWanted == 2) then
				bytesWanted = 1
			elseif (bytesWanted == 1) then
				IP = IP + combineBytesToWord(RAM[IP],RAM[IP-1])
				bytesWanted = 0
			end
		elseif (opCode == 235) then -- Jump short relative to next instruction
			IP = IP + (128-RAM[IP])
			--print("AX: " .. decimalToHex(tonumber(toBits(AH,8) .. toBits(AL,8),2)))
			bytesWanted = 0
		end
	end
end
print("AX: " .. decimalToHex(combineBytesToWord(AH,AL)))
print("BX: " .. decimalToHex(combineBytesToWord(BH,BL)))
print("CX: " .. decimalToHex(combineBytesToWord(CH,CL)))
print("DX: " .. decimalToHex(combineBytesToWord(DH,DL)))
print("")
print("OF: " .. OF)
print("DF: " .. DF)
print("IF: " .. IF)
print("TF: " .. TF)
print("SF: " .. SF)
print("ZF: " .. ZF)
print("AF: " .. AF)
print("PF: " .. PF)
print("CF: " .. CF)