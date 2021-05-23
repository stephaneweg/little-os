
#include once "stdlib.bi"
#include once "tobject.bi"
#include once "tstring.bi"
#include once "multiboot.bi"
#include once "in_out.bi"

#include once "realmode.bi"
#include once "gdt.bi"
#include once "pic.bi"
#include once "console.bi"
#include once "pmm.bi"
#include once "vmm.bi"
#include once "slab.bi"
#include once "kmm.bi"
#include once "interrupt.bi"
#include once "devices.bi"
#include once "devmgr.bi"
#include once "vfs.bi"
#include once "hd.bi"
#include once "fatfs.bi"
#include once "keyboard.bi"
#include once "mouse.bi"
#include once "vesa.bi"

#include once "process.bi"
#include once "thread.bi"
#include once "scheduler.bi"
#include once "rng.bi"
#include once "gdi/gdi.bi"
#include once "syscall.bi"
#include once "semaphore.bi"
#include once "filehandle.bi"
#include once "kernel.bi"
SUB MAIN (mb_info as multiboot_info ptr)
    asm cli
    ConsoleInit()
    
    GDT_INIT()
    InterruptsManager_Init()
    PMM_INIT(mb_info)
    VMM_INIT()
    
    VMM_INIT_LOCAL()
    SlabInit()
    
    DEVMGR_INIT()
    VFS_INIT()
    HD_INIT()
    FAT_INIT()
    VFS_MOUNT(@"HDA1",@"FATFS",@"SYS:/")
    RealMode_INIT()
    IRQ_DISABLE(0)
    
    
    
    INIT_KBD()
	KBD_Flush()
    INIT_MOUSE()
    
    
    IRQ_ATTACH_HANDLER(&h31,@SyscallHandler)
    Thread.InitManager()
    
    IDLE_Thread = Thread.CreateSys(@KERNEL_IDLE,MaxPriority)
    VMM_EXIT()
    var mode = VesaProbe()
    vmm_init_local()
    ConsoleNewLine()
    if (mode<>0) then
        EnterGraphicMode(mode)
        Process.Load(@"SYS:/SYS/INIT.BIN",0)
        Thread.Ready()
    else
        ConsoleWriteLine(@"Cannot set graphic mode")
    end if
   
    
    ConsoleWriteLIne(@"Kernel Loop")
    asm sti
    do
    loop
end sub


sub EnterGraphicMode(mode as unsigned integer)
    WindowSkin = Skin.Create(@"SYS:/RES/WINDOW.BMP",1,7,7,32,7)
	ButtonSkin = Skin.Create(@"SYS:/RES/BUTTON.BMP",3,12,12,12,12)
	WindowCloseBtn = GImage.LoadFromBitmap(@"SYS:/RES/CLOSEBTN.BMP")
    FontManager.Init()
    
    
    VMM_EXIT()
	VesaSetMode(mode)
    vmm_init_local()
    ScreenInit()
    
    GuiThread = Thread.CreateSys(@GUILoop,0)
end sub


sub GuiLoop(p as any ptr)
    do
        IRQ_DISABLE(0)
		GuiThread->InCritical = 1
        ScreenLoop()
		if (ProcessToTerminate<>0) then
			Process.Terminate(ProcessToTerminate,0)
			ProcessToTerminate = 0
		end if
		GuiThread->InCritical = 0
        IRQ_ENABLE(0)
        
        
		'wait thread
		asm
            mov eax,&hFF '&hE2
            int 0x31
        end asm
    loop
end sub

sub KERNEL_ERROR(message as unsigned byte ptr,code as unsigned integer)
    VMM_EXIT()
    VesaResetScreen()
    ConsoleSetBackGround(4)
    ConsoleSetForeground(15)
    ConsoleClear()
    ConsoleWriteLine(@"KERNEL PANIC")
    ConsoleWriteTextAndHex(@"Code : ",code,true)
    ConsoleNewLine()
    ConsoleWriteLine(@"Message :")
    ConsoleWriteLine(message)

    asm 
        cli
        .panic_halt:
            hlt
        jmp .panic_halt
    end asm
end sub

#include once "arch/x86/realmode.bas"
#include once "arch/x86/gdt.bas"
#include once "arch/x86/vmm.bas"
#include once "arch/x86/pic.bas"
#include once "console.bas"
#include once "stdlib.bas"
#include once "tobject.bas"
#include once "tstring.bas"
#include once "pmm.bas"
#include once "slab.bas"
#include once "kmm.bas"
#include once "interrupt.bas"
#include once "devices.bas"
#include once "devmgr.bas"
#include once "vfs.bas"
#include once "drivers/hd.bas"
#include once "drivers/keyboard.bas"
#include once "drivers/mouse.bas"
#include once "drivers/vesa.bas"
#include once "fs/fatfs.bas"
#include once "process.bas"
#include once "thread.bas"
#include once "scheduler.bas"
#include once "rng.bas"
#include once "gdi/gdi.bas"
#include once "syscall.bas"
#include once "semaphore.bas"
#include once "filehandle.bas"