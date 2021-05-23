
sub ConsoleWrite(txt as unsigned byte ptr)
    asm
        mov eax,0x01
        mov ebx,[txt]
        int 0x31
    end asm
end sub 

sub ConsoleWriteLine(txt as unsigned byte ptr)
    asm
        mov eax,0x02
        mov ebx,[txt]
        int 0x31
    end asm
end sub 

sub ConsoleWriteNumber(num as unsigned integer,_base as unsigned integer)
    asm
        mov eax,0x3
        mov ebx,[num]
        mov ecx,[_base]
        int 0x31
    end asm
end sub

sub ConsoleNewLine()
    asm
        mov eax,0x4
        int 0x31
    end asm
end sub

sub ConsolePrintOK()
    asm
        mov eax,0x5
        int 0x31
    end asm
end sub

sub ConsoleBackSpace()
    asm
        mov eax,0x6
        int 0x31
    end asm
end sub

sub ConsoleSetForeground(c as unsigned integer)
    asm
        mov eax,0x7
        mov ebx,[c]
        int 0x31
    end asm
end sub

sub ConsolePutChar(c as unsigned byte)
	asm
		mov eax,0x8
		xor ebx,ebx
		mov bl,[c]
		int 0x31
	end asm
end sub


function WindowCreate(w as unsigned integer,h as unsigned integer, t as any ptr) as unsigned integer 
    asm
        mov eax,&h10
        mov ebx,[w]
        shl ebx,16
        or ebx,[h]
        mov ecx,[t]
        int 0x31
        mov [function],eax
    end asm
end function

function ButtonCreate(_parent as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer,t as any ptr,c as any ptr, parm as unsigned integer) as unsigned integer
    asm
		push ebp
        mov eax,&h11
        mov ebx,[_parent]
        mov ecx,[w]
        shl ecx,16
        or ecx,[h]
        mov edx,[x]
        shl edx,16
        or edx,[y]
        mov esi,[t]
        mov edi,[c]
		push [parm]
		pop ebp
        int 0x31
		pop ebp
        mov [function],eax
    end asm
end function

function TextBoxCreate(_parent as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer) as unsigned integer
    asm
        mov eax,&h12
        mov ebx,[_parent]
        mov ecx,[w]
        shl ecx,16
        or ecx,[h]
        mov edx,[x]
        shl edx,16
        or edx,[y]
        int 0x31
        mov [function],eax
    end asm
end function

function TextBlockCreate(_p as unsigned integer,x as integer,y as integer,t as unsigned byte ptr,c as unsigned integer) as unsigned integer
    asm
        mov eax,&h17
        mov ebx,[_p]
        mov ecx,[x]
        shl ecx,16
        or ecx,[y]
        mov edx,[c]
        mov esi,[t]
        int 0x31
        mov [function],eax
    end asm
end function

sub TextBoxSetText(_tb as unsigned integer,text as any ptr)
    asm
        mov eax,&h13
        mov ebx,[_tb]
        mov ecx,[text]
        int 0x31
    end asm
end sub

sub TextBoxAppendChar(_tb as unsigned integer,c as unsigned byte)
    asm
        mov eax,&h14
        mov ebx,[_tb]
        mov ecx,[c]
        int 0x31
    end asm
end sub

sub TextBoxGetText(_tb as unsigned integer,dst  as unsigned byte ptr)

    asm
        mov eax,&h15
        mov ebx,[_tb]
		mov edi,[dst]
        int 0x31
    end asm
end sub



function MessageBoxShow(text as any ptr,title as any ptr) as integer
    asm
        mov eax,&h30
        mov ebx,[text]
        mov ecx,[title]
        int 0x31
        mov [function],eax
    end asm
end function

function MessageConfirmShow(text as any ptr,title as any ptr) as integer
    asm
        mov eax,&h31
        mov ebx,[text]
        mov ecx,[title]
        int 0x31
        mov [function],eax
    end asm
end function



function GDICreate(_parent as unsigned integer,x as  integer,y as  integer,w as unsigned integer,h as unsigned  integer) as unsigned integer
     asm
        mov eax,&h16
        mov ebx,[_parent]
        mov ecx,[w]
        shl ecx,16
        or ecx,[h]
        mov edx,[x]
        shl edx,16
        or edx,[y]
        int 0x31
        mov [function],eax
    end asm
end function

sub GDISetPosition(_gd as unsigned integer,x as integer,y as integer)
	asm
		mov eax,&h40
		mov ebx,[_gd]
		mov ecx,[x]
		mov edx,[y]
		int 0x31
	end asm
end sub

sub ButtonSetSkin(_btn as unsigned integer,skin as unsigned byte ptr)
    asm
        mov eax,&h41
        mov ebx,[_btn]
        mov ecx,[skin]
        int 0x31
    end asm
end sub

sub GDISetTransparent(_gdi as unsigned integer,transparent as unsigned integer)
    asm
        mov eax,&h42
        mov ebx,[_gdi]
        mov ecx,[transparent]
        int 0x31
    end asm
end sub

sub ButtonSetIcon(_btn as unsigned integer,icon as unsigned byte ptr,big as unsigned integer)
    asm
        mov eax,&h43
        mov ebx,[_btn]
        mov ecx,[icon]
        mov edx,[big]
        int 0x31
    end asm
end sub

sub GDISetForegroundColor(g as unsigned integer,c as unsigned integer)
    asm
        mov eax,&h44
        mov ebx,[g]
        mov ecx,[c]
        int 0x31
    end asm
end sub

sub GDIDrawLine(_gd as unsigned integer,x1 as  integer,y1 as  integer,x2 as  integer,y2 as  integer,c as unsigned integer)
     asm
        mov eax,&h50
        mov ebx,[_gd]
        mov ecx,[x1]
        shl ecx,16
        or ecx,[y1]
        mov edx,[x2]
        shl edx,16
        or edx,[y2]
        mov esi,[c]
        int 0x31
    end asm
end sub

sub GDIDrawRectangle(_gd as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
     asm
        mov eax,&h51
        mov ebx,[_gd]
        mov ecx,[x1]
        shl ecx,16
        or ecx,[y1]
        mov edx,[x2]
        shl edx,16
        or edx,[y2]
        mov esi,[c]
        int 0x31
    end asm
end sub

sub GDIFillRectangle(_gd as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
     asm
        mov eax,&h52
        mov ebx,[_gd]
        mov ecx,[x1]
        shl ecx,16
        or ecx,[y1]
        mov edx,[x2]
        shl edx,16
        or edx,[y2]
        mov esi,[c]
        int 0x31
    end asm
end sub

sub GDIDrawText(_gd as unsigned integer,txt as unsigned byte ptr,x as integer,y as integer,c as unsigned integer)
    asm
        mov eax,&h53
        mov ebx,[_gd]
        mov ecx,[x]
        shl ecx,16
        or ecx,[y]
        mov edx,[c]
        mov esi,[txt]
        int 0x31
    end asm
end sub

sub GDIClear(_gd as unsigned integer,c as unsigned integer)
    asm
        mov eax,&h54
        mov ebx,[_gd]
        mov ecx,[c]
        int 0x31
    end asm
end sub


sub GDIDrawChar(_gd as unsigned integer,cara as unsigned byte,x as integer,y as integer,c as unsigned integer)
    asm
        mov eax,&h55
        mov ebx,[_gd]
        mov ecx,[x]
        shl ecx,16
        or ecx,[y]
        mov edx,[c]
        mov esi,[cara]
        int 0x31
    end asm
end sub

sub GDIOnKeyPress(_elem as unsigned integer,callback as any ptr)
    asm
        mov eax,&h60
        mov ebx,[_elem]
        mov ecx,[callback]
        int 0x31
    end asm
end sub

sub GDIOnMouseClick(_elem as unsigned integer,callback as any ptr)
    asm
        mov eax,&h61
        mov ebx,[_elem]
        mov ecx,[callback]
        int 0x31
    end asm
end sub

sub GetScreenRes(byref x as unsigned integer,byref y as unsigned integer )
    asm
        mov eax, &hD0
        int 0x31
        mov edi,[x]
        mov [edi],eax
        mov edi,[y]
        mov [edi],ebx
    end asm
end sub

function PAlloc(cnt as unsigned integer) as any ptr
    dim retval as any ptr
    asm
        mov eax,&hE0
        mov ebx,[cnt]
        int 0x31
        mov [retval],eax
    end asm
    
    return retval
end function

function  CreateThread(fn as any ptr,prio as unsigned integer) as unsigned integer
    asm
        mov eax,&hE1
        mov ebx,[fn]
        mov ecx,[prio]
        int 0x31
        mov [function],eax
    end asm
end function

sub ThreadYield()
    asm
        mov eax,&hE2
        int 0x31
    end asm
end sub


function SemaphoreCreate() as unsigned integer
    asm 
        mov eax,&hE3
        int 0x31
        mov [function],eax
    end asm
end function


sub SemaphoreLock(s as unsigned integer)
    asm
        mov eax,&hE4
        mov ebx,[s]
        int 0x31
    end asm
end sub

sub SemaphoreUnlock(s as unsigned integer)
    asm
        mov eax,&hE5
        mov ebx,[s]
        int 0x31
    end asm
end sub

function ExecApp(path as unsigned byte ptr) as unsigned integer
    asm
        mov eax,&hE6
        mov ebx,[path]
        int 0x31
        mov [function],eax
    end asm
end function

sub ExitApp()
    asm
        mov eax,&hFE
        int 0x31
    end asm
end sub

sub WaitForEvent()
	asm
		mov eax,0xff
		int 0x31
	end asm
    do:loop
end sub

sub EnterCritical()
	asm
		mov eax ,&hE7
		int 0x31
	end asm
end sub

sub ExitCritical()
	asm
		mov eax,&hE8
		int 0x31
	end asm
end sub





function FileOpen(p as unsigned byte ptr) as unsigned integer
	asm 
		mov eax,0xF000
		mov esi,[p]
		int 0x31
		mov [function],eax
	end asm
end function

function FileCreate(p as unsigned byte ptr) as unsigned integer
	asm
		mov eax,0xF001
		mov esi,[p]
		int 0x31
		mov [function],eax
	end asm
end function

function FileRead(f as unsigned integer, count as unsigned integer,dest as any ptr) as unsigned integer
	asm
		mov eax,0xF002
		mov ebx,[f]
		mov ecx,[count]
		mov edi,[dest]
		int 0x31
		mov [function],eax
	end asm
end function

sub FileWrite(f as unsigned integer,count as unsigned integer,src as any ptr)
	asm
		mov eax,0xF003
		mov ebx,[f]
		mov ecx,[count]
		mov esi,[src]
		int 0x31
	end asm
end sub

sub FileClose(f as unsigned integer,doFlush as integer)
	asm
		mov eax,0xF004
		mov ebx,[f]
        mov ecx,[doFlush]
		int 0x31
	end asm
end sub

function FileSize(f as unsigned integer) as unsigned integer
	asm
		mov eax,0xF005
		mov ebx,[f]
		int 0x31
		mov [function],eax
	end asm
end function

function FileSeek(f as unsigned integer,count as unsigned integer,mode as unsigned integer) as unsigned integer
	asm
		mov eax,0xF006
		mov ebx,[f]
		mov ecx,[count]
		mov edx,[mode]
		int 0x31
		mov [function],eax
	end asm
end function

function FileReadLine(f as unsigned integer,dst as any ptr) as unsigned integer
	asm
		mov eax,0xF007
		mov ebx,[f]
		mov edi,[dst]
		int 0x31
		mov [function],eax
	end asm
end function
		
function FileEOF(f as unsigned integer) as unsigned integer
	asm
		mov eax,0xF00A
		mov ebx,[f]
		int 0x31
		mov [function],eax
	end asm
end function

function VFSListDir(path as unsigned byte ptr,attrib as unsigned integer,skip as unsigned integer,count as unsigned integer,dst as VFSDirectoryEntry ptr) as unsigned integer
    asm
        mov eax,0xF00F
        mov ebx,[attrib]
        mov ecx,[count]
        mov edx,[skip]
        mov esi,[path]
        mov edi,[dst]
        int 0x31
        mov [function],eax
    end asm
end function




sub DefineIRQHandler(intNO as unsigned integer,c as sub(_intno as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer))
    asm
        mov eax,&hFA
        mov ebx,[intNO]
        mov ecx,[c]
        int 0x31
    end asm
end sub

sub IRQ_ENABLE(intno as unsigned integer)
    asm
        mov eax,&hFB
        mov ebx,[intno]
        int 0x31
    end asm
end sub
