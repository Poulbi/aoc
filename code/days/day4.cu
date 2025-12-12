#define FORCE_THREADS_COUNT 1
#include "base/base.h"

#include "cu.h"

global_variable void (*Log)(char *Format, ...) = OS_PrintFormat;

ENTRY_POINT(EntryPoint)
{
    
    if(Params->ArgsCount >= 2)
    {
        str8 InputFile = OS_ReadEntireFileIntoMemory(Params->Args[1]);
        if(InputFile.Size)
        {
            umm LineSize = 0;
            
            for(umm Idx = 0; Idx < InputFile.Size; Idx += 1)
            {
                if(InputFile.Data[Idx] == '\n')
                {
                    LineSize = Idx + 1;
                    break;
                }
            }
            Assert(InputFile.Size%LineSize == 0);
            Assert(LineSize && InputFile.Data[LineSize - 1] == '\n'); // NOTE(luca): We should check every line...
            
            // 1. check around you
            // 2. if '@' rolls += 1
            // 3. if  < 4 access count += 1
            
            umm Lines = (InputFile.Size/LineSize);
            
            u8 *Row = InputFile.Data;
            s32 AccessibleRollsCount = 0;
            for(s32 Y = 0; Y < (s32)Lines; Y += 1)
            {
                u8 *Char = Row;
                for(s32 X = 0; X < (s32)LineSize; X += 1)
                {
                    if(*Char == '@')
                    {
                        s32 MinX = Maximum(X - 1, 0);
                        s32 MinY = Maximum(Y - 1, 0);
                        s32 MaxX = Minimum(X + 1, (s32)LineSize - 1);
                        s32 MaxY = Minimum(Y + 1, (s32)Lines - 1);
                        
                        s32 RollsCount = 0;
                        for(s32 ScanY = MinY; ScanY <= MaxY; ScanY += 1)
                        {
                            for(s32 ScanX = MinX; ScanX <= MaxX; ScanX += 1)
                            {
                                u8 *ScanChar = InputFile.Data + (ScanY*LineSize + ScanX);
                                if(!(ScanX == X && ScanY == Y))
                                {
                                    RollsCount += !!(*ScanChar == '@');
                                }
                            }
                        }
                        if(RollsCount < 4)
                        {
                            AccessibleRollsCount += 1;
                        }
                    }
                    
                    Char += 1;
                }
                
                Row += LineSize;
            }
            
            Log("There are %d accessible rolls.\n", AccessibleRollsCount);
            
        }
        else
        {
            // TODO(luca): Loggign
        }
    }
    else
    {
        // TODO(luca): 
    }
    
    return 0;
}