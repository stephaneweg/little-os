

TYPE VFSDirectoryEntry field = 1
    FileName(0 to 255) as unsigned byte
    EntryType as unsigned integer
    Size as unsigned integer
End Type

declare sub ConsoleWrite(txt as unsigned byte ptr)
declare sub ConsoleWriteLine(txt as unsigned byte ptr)
declare sub ConsoleWriteNumber(num as unsigned integer,_base as unsigned integer)
declare sub ConsoleNewLine()
declare sub ConsolePrintOK()
declare sub ConsoleBackSpace()
declare sub ConsoleSetForeground(c as unsigned integer)
declare sub ConsolePutChar(c as unsigned byte)

declare sub GDISetPosition(_gd as unsigned integer,x as integer,y as integer)
declare sub GDISetForegroundColor(g as unsigned integer,c as unsigned integer)
declare sub ButtonSetSkin(_btn as unsigned integer,skin as unsigned byte ptr)
declare sub ButtonSetIcon(_btn as unsigned integer,icon as unsigned byte ptr,big as unsigned integer)
declare sub GDISetTransparent(_gdi as unsigned integer,transparent as unsigned integer)
declare sub GDIOnKeyPress(_elem as unsigned integer,callback as any ptr)
declare sub GDIOnMouseClick(_elem as unsigned integer,callback as any ptr)
declare function GDICreate(_parent as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer) as unsigned integer
declare sub GDIDrawLine(_parent as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
declare sub GDIDrawRectangle(_parent as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
declare sub GDIFillRectangle(_parent as unsigned integer,x1 as integer,y1 as integer,x2 as integer,y2 as integer,c as unsigned integer)
declare sub GDIDrawText(_gd as unsigned integer,txt as unsigned byte ptr,x as integer,y as integer,c as unsigned integer)
declare sub GDIClear(_gd as unsigned integer,c as unsigned integer)
declare sub GDIDrawChar(_gd as unsigned integer,cara as unsigned byte,x as integer,y as integer,c as unsigned integer)

declare function WindowCreate(w as unsigned integer,h as unsigned integer, t as any ptr) as unsigned integer
declare function ButtonCreate(_p as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer,t as any ptr,c as any ptr, parm as unsigned integer) as unsigned integer
declare function TextBoxCreate(_p as unsigned integer,x as integer,y as integer,w as unsigned integer,h as unsigned integer) as unsigned integer
declare function TextBlockCreate(_p as unsigned integer,x as integer,y as integer,t as unsigned byte ptr,c as unsigned integer) as unsigned integer

declare sub TextBoxSetText(_p as unsigned integer,text as any ptr)
declare sub TextBoxAppendChar(_p as unsigned integer,c as unsigned byte)
declare sub TextBoxGetText(_tb as unsigned integer,dst  as unsigned byte ptr)
declare function MessageBoxShow(text as any ptr,title as any ptr) as integer
declare function MessageConfirmShow(text as any ptr,title as any ptr) as integer

declare sub GetScreenRes(byref x as unsigned integer,byref y as unsigned integer )

declare function SemaphoreCreate() as unsigned integer
declare sub SemaphoreLock(s as unsigned integer)
declare sub SemaphoreUnlock(s as unsigned integer)


declare function ExecApp(path as unsigned byte ptr) as unsigned integer
declare function CreateThread(fn as any ptr,prio as unsigned integer) as unsigned integer
declare sub ThreadYield()
declare function PAlloc(cnt as unsigned integer) as any ptr
declare sub WaitForEvent()
#macro EndCallBack()
	asm
		mov esp,ebp
		add esp,12 'remove parameters (sender+args) and return addr to the stack
		mov eax,0xff
		int 0x31
	end asm
	do:loop
#endmacro

declare sub EnterCritical()
declare sub ExitCritical()

declare sub DefineIRQHandler(intNO as unsigned integer,c as sub(_intno as unsigned integer,_eax as unsigned integer,_ebx as unsigned integer,_ecx as unsigned integer,_edx as unsigned integer,_esi as unsigned integer,_edi as unsigned integer))
#macro EndIRQHandler()
asm
    mov esp,ebp
    add esp,32
    mov eax,0xff
    int 0x31
end asm
do:loop
#endmacro
declare sub IRQ_ENABLE(intno as unsigned integer)

declare function FileOpen(p as unsigned byte ptr) as unsigned integer
declare function FileCreate(p as unsigned byte ptr) as unsigned integer
declare function FileRead(f as unsigned integer, count as unsigned integer,dest as any ptr) as unsigned integer
declare sub FileWrite(f as unsigned integer,count as unsigned integer,src as any ptr)
declare sub FileClose(f as unsigned integer,doFlush as integer)
declare function FileSize(f as unsigned integer) as unsigned integer
declare function FileSeek(f as unsigned integer,count as unsigned integer,mode as unsigned integer) as unsigned integer
declare function FileReadLine(f as unsigned integer,dst as any ptr) as unsigned integer
declare function FileEOF(f as unsigned integer) as unsigned integer
declare function VFSListDir(path as unsigned byte ptr,attrib as unsigned integer,skip as unsigned integer,count as unsigned integer,dst as VFSDirectoryEntry ptr) as unsigned integer
