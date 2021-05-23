#include once "stdlib.bi"
#include once "stdlib.bas"


#include once "xapp.bi"
#include once "xapp.bas"
#include once "slab.bi"
#include once "slab.bas"

dim shared fline(0 to 255) as unsigned byte

dim shared entries(0 to 50) as VFSDirectoryEntry
sub MAIN(p as any ptr) 
    dim buttonWidth as integer = 150
    
    SlabINIT()

    dim f as unsigned integer = FileOpen(@"SYS:/ETC/INIT.CFG")
    while not FileEOF(f)
        FileReadLine(f,@fline(0))
        if strlen(@fline(0))>0 then
            ExecApp(@fline(0))
        end if
    wend
    FileClose(f,0)
    ExitApp()
end sub
