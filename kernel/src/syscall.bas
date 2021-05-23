sub XAppButtonClick(btn as TButton ptr)
    asm cli
    if (btn->Owner<>0 and btn->AppCallBack) then
        var th = cptr(Thread ptr,btn->OwnerThread)
		var proc = cptr(Process ptr,th->Owner)
        if (th->State = ThreadState.Waiting) then
            var currentContext = vmm_get_current_context()
            proc->VMM_Context.Activate()
            
            dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
            st->EIP = btn->AppCallback
			st->ESP = st->ESP-8
			*cptr(unsigned integer ptr, st->ESP+4) =cast(unsigned integer, btn)
			*cptr(unsigned integer ptr, st->ESP+8) =cast(unsigned integer, btn->AppCallBackParameter)
            Scheduler.SetThreadReady(th,0)
            
            currentContext->Activate()
           
        end if
    end if
    asm sti
end sub

sub XAppKeyPress(elem as GDIBase ptr,k as unsigned byte)
    if (elem->OwnerThread<>0 and elem->_onUserKeyDown<>0) then
        var th = cptr(Thread ptr,elem->OwnerThread)
        var proc = cptr(Process ptr,th->Owner)
        if (th->State = ThreadState.Waiting) then
            var currentContext = vmm_get_current_context()
            proc->VMM_Context.Activate()
            
            dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
            st->EIP = elem->_onUserKeyDown
			st->ESP = st->ESP-8
			*cptr(unsigned integer ptr, st->ESP+4) =cast(unsigned integer,elem)
			*cptr(unsigned integer ptr, st->ESP+8) =cast(unsigned integer,k)
			
			
            Scheduler.SetThreadReady(th,0)
            
            currentContext->Activate()
           
        end if
    end if
end sub

sub XAppMouseClick(elem as GDIBase ptr,mx as integer,my as integer)
if (elem->OwnerThread<>0 and elem->_onUserClick<>0) then
        var th = cptr(Thread ptr,elem->OwnerThread)
        var proc = cptr(Process ptr,th->Owner)
        if (th->State = ThreadState.Waiting) then
            var currentContext = vmm_get_current_context()
            proc->VMM_Context.Activate()
            
            dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
            st->EIP = elem->_onUserClick
			st->ESP = st->ESP-8
			*cptr(unsigned integer ptr, st->ESP+4) =cast(unsigned integer,elem)
			*cptr(unsigned integer ptr, st->ESP+8) =cast(unsigned integer,(mx shl 16) or my)
			
			
            Scheduler.SetThreadReady(th,0)
            
            currentContext->Activate()
            
        end if
    end if
end sub

sub XappIRQReceived(intno as unsigned integer)',p as IRQ_THREAD_POOL ptr)
    var th = cptr(Thread ptr,IRQ_THREAD_HANDLERS(intno).Owner)
    if (th<>0) then
        if (th->State=ThreadState.Waiting) then
            var proc=th->Owner
            var currentContext = vmm_get_current_context()
            proc->VMM_Context.Activate()
                
            dim st as IRQ_Stack ptr = cptr(IRQ_Stack ptr,th->SavedESP)
            st->EIP = IRQ_THREAD_HANDLERS(intno).EntryPoint
            st->ESP = st->ESP-4
            *cptr(unsigned integer ptr, st->ESP+4)  =intno
            '*cptr(unsigned integer ptr, st->ESP+8)  =p->EAX
            '*cptr(unsigned integer ptr, st->ESP+12) =p->EBX
            '*cptr(unsigned integer ptr, st->ESP+16) =p->ECX
            '*cptr(unsigned integer ptr, st->ESP+20) =p->EDX
            '*cptr(unsigned integer ptr, st->ESP+24) =p->ESI        
            '*cptr(unsigned integer ptr, st->ESP+28) =p->EDI
            Scheduler.SetThreadReady(th,0)
                
            currentContext->Activate()
        end if
    end if
end sub

function SysCallHandler(stack as IRQ_Stack ptr) as IRQ_Stack ptr
    dim CurrentThread as Thread ptr = Scheduler.CurrentRuningThread
    select case stack->EAX
        case 1
            ConsoleWrite(cptr(unsigned byte ptr,stack->EBX))
        case 2
             ConsoleWriteLine(cptr(unsigned byte ptr,stack->EBX))
        case 3
            ConsoleWriteNumber(stack->EBX,stack->ECX)
        case 4
            ConsoleNewLine()
        case 5
            ConsolePrintOK()
        case 6
            ConsoleBackSpace()
        case 7
            ConsoleSetForeground(stack->EBX)
        case 8
            ConsolePutChar(cast(unsigned byte ,stack->EBX))
        case 9
            var _ptrDouble  =cptr(double ptr, stack->EBX)
            var _ptrStr = cptr(unsigned byte ptr, stack->ECX)
            ftoa(*_ptrDouble,_ptrStr)
        case &hA
            var _ptrDouble  =cptr(double ptr, stack->EBX)
            var _ptrStr = cptr(unsigned byte ptr, stack->ECX)
            *_ptrDouble = atof(_ptrStr)
        case &h10
            dim _w as unsigned integer = stack->EBX shr 16
            dim _h as unsigned integer = stack->EBX and &hFFFF
            dim _x as integer = (XRES - _w) shr 1
            dim _y as integer = (YRES - _h) shr 1
            dim _t as unsigned byte ptr = cptr(unsigned byte ptr,stack->ECX)
           
            NewObj(win,TWindow)
            win->SetSize(_w + win->_paddingLeft + win->_paddingRight,_h+win->_paddingTop+win->_paddingBottom)
            win->SetPosition(_x,_y)
            win->Owner = CurrentThread->Owner
            win->OwnerThread = CurrentThread
            win->Title = _t
            rootScreen->AddChild(win)
            
            stack->EAX = cast(unsigned integer,win)
        case &h11
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _w as unsigned integer = stack->ECX shr 16
            dim _h as unsigned integer = stack->ECX and &hFFFF
            dim _x as unsigned integer = stack->EDX shr 16
            dim _y as unsigned integer = stack->EDX and &hFFFF
            dim _t as unsigned byte ptr = cptr(unsigned byte ptr,stack->ESI)
            dim _c as unsigned integer = stack->EDI
            dim _p as unsigned integer  = stack->EBP
            NewObj(btn,TButton)
            btn->SetSize(_w,_h)
            btn->SetPosition(_x,_y)
            btn->Owner = CurrentThread->Owner
            btn->OwnerThread = CurrentThread
            btn->Text = _t
            btn->OnClick = @XAppButtonClick
            btn->AppCallBack = _c
			btn->AppCallBackParameter = _p
            
            _parent->AddChild(btn)
            stack->EAX = cast(unsigned integer,btn)
        case &h12
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _w as unsigned integer = stack->ECX shr 16
            dim _h as unsigned integer = stack->ECX and &hFFFF
            dim _x as unsigned integer = stack->EDX shr 16
            dim _y as unsigned integer = stack->EDX and &hFFFF
            
            NewObj(txt,TextBox)
            txt->SetSize(_w,_h)
            txt->SetPosition(_x,_y)
            txt->Owner = CurrentThread->Owner
            txt->OwnerThread = CurrentThread
            
            _parent->AddChild(txt)
            stack->EAX = cast(unsigned integer,txt)
        case &h13
            dim txt as TextBox ptr = cptr(TextBox ptr,stack->EBX)
            if (txt->TypeName = TextBoxTypeName) then
                dim _t as unsigned byte ptr = cptr(unsigned byte ptr,stack->ECX)
                txt->Text = _t
            end if
        case &h14
            dim txt as TextBox ptr = cptr(TextBox ptr,stack->EBX)
            if (txt->TypeName = TextBoxTypeName) then
                dim c as unsigned byte = cast(unsigned byte,stack->ECX)
                txt->_Text->AppendChar(c)
                txt->Invalidate()
            end if
        case &h15
            dim txt as TextBox ptr = cptr(TextBox ptr,stack->EBX)
            if (txt->TypeName = TextBoxTypeName) then
                strcpy(cptr(unsigned byte ptr,stack->EDI),txt->_Text->Buffer)
            end if
            
        case &h16 'create generic ui element
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _w as unsigned integer = stack->ECX shr 16
            dim _h as unsigned integer = stack->ECX and &hFFFF
            dim _x as unsigned integer = stack->EDX shr 16
            dim _y as unsigned integer = stack->EDX and &hFFFF
            
            NewObj(gd,GDIBase)
            gd->SetSize(_w,_h)
            gd->SetPosition(_x,_y)
            gd->Owner = CurrentThread->Owner
            gd->OwnerThread = CurrentThread
            if (_parent<>0) then
                _parent->AddChild(gd)
            else
                rootScreen->AddChild(gd)
            end if
            
            stack->EAX = cast(unsigned integer,gd)
        case &h17'create textblock
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _x as unsigned integer = stack->ECX shr 16
            dim _y as unsigned integer = stack->ECX and &hFFFF
            dim _c as unsigned integer = stack->ECX
            dim _t as unsigned byte ptr = cptr(unsigned byte ptr,stack->ESI)
            NewObj(tb,TextBlock)
            tb->SetSize(strlen(_t)*9,16)
            tb->SetPosition(_x,_y)
            tb->Text = _t
            tb->ForeColor = _c
            
            if (_parent<>0) then
                _parent->AddChild(tb)
            else
                rootScreen->AddChild(tb)
            end if
            stack->EAX = cast(unsigned integer,tb)
        case &h20 'create console
            dim _parent as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _w as unsigned integer = stack->ECX shr 16
            dim _h as unsigned integer = stack->ECX and &hFFFF
            dim _x as unsigned integer = stack->EDX shr 16
            dim _y as unsigned integer = stack->EDX and &hFFFF
            
            
            NewObj(console,TConsole)
            console->SetSize(_w,_h)
            console->SetPosition(_x,_y)
			console->Clear(&hFF000000)
            console->Owner = CurrentThread->Owner
            console->OwnerThread = CurrentThread
            if (_parent<>0) then
                _parent->AddChild(console)
            else
                rootScreen->AddChild(console)
            end if
            
            stack->EAX = cast(unsigned integer,console)
        case &h21 'console write
            dim console as TConsole ptr = cptr(TConsole ptr,stack->EBX)
            if (console->TypeName=TConsoleTypeName) then
                console->Write(cptr(unsigned byte ptr,stack->ECX))
                console->parent->invalidate()
            end if
        case &h22 'console write line
            dim console as TConsole ptr = cptr(TConsole ptr,stack->EBX)
            if (console->TypeName=TConsoleTypeName) then
                console->WriteLine(cptr(unsigned byte ptr,stack->ECX))
                console->parent->invalidate()
            end if
        case &h23 'console put char
            dim console as TConsole ptr = cptr(TConsole ptr,stack->EBX)
            if (console->TypeName=TConsoleTypeName) then
                console->PutChar(cast(unsigned byte,stack->ECX))
                console->parent->invalidate()
            end if
        case &h24 'console new line
            dim console as TConsole ptr = cptr(TConsole ptr,stack->EBX)
            if (console->TypeName=TConsoleTypeName) then
                console->NewLine()
            end if
        case &h40 'GDISetPosition
            dim g as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            g->SetPosition(cast(integer,stack->ECX),cast(integer,stack->EDX))
        case &h41 'ButtonSetSkin
            dim btn as TButton ptr = cptr(TButton ptr,stack->EBX)
            if (btn->TypeName=TButtonTypeName) then
                dim sknPath as unsigned byte ptr = cptr(unsigned byte ptr,stack->ECX)
                btn->_Skin = Skin.Create(sknPath,3,12,12,12,12)
                btn->Invalidate()
            end if
        case &h42'GDISetTransparent
            dim g as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            g->_transparent = stack->ECX
            g->Invalidate()
            
        case &h43'ButtonSetIcon
            dim btn as TButton ptr = cptr(TButton ptr,Stack->EBX)
            if (btn->TypeName=TButtonTypeName) then
                dim btnPath as unsigned byte ptr = cptr(unsigned byte ptr,stack->ECX)
                if (stack->edx=0) then
                    btn->SmallIcon = GImage.LoadFromBitmap(btnPath)
                elseif(stack->edx=1) then
                    btn->BigIcon = GImage.LoadFromBitmap(btnPath)
                end if
                btn->Invalidate()
            end if
            
        case &h44 'GDISetFGColor
            dim g as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            g->FGColor = stack->ECX
            g->Invalidate()
        case &h50 'draw line
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _x1 as unsigned integer = stack->ECX shr 16
            dim _y1 as unsigned integer = stack->ECX and &hFFFF
            dim _x2 as unsigned integer = stack->EDX shr 16
            dim _y2 as unsigned integer = stack->EDX and &hFFFF
            dim _c as unsigned integer = stack->ESI
            if (_gd<>0) then _gd->DrawLine(_x1,_y1,_x2,_y2,_c)
            if (_gd->Parent<>0) then 
                _gd->Parent->Invalidate()
               ' RootScreen->Redraw()
            end if
        case &h51 'drawRectangle
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _x1 as unsigned integer = stack->ECX shr 16
            dim _y1 as unsigned integer = stack->ECX and &hFFFF
            dim _x2 as unsigned integer = stack->EDX shr 16
            dim _y2 as unsigned integer = stack->EDX and &hFFFF
            dim _c as unsigned integer = stack->ESI
            if (_gd<>0) then _gd->DrawRectangle(_x1,_y1,_x2,_y2,_c)
            if (_gd->Parent<>0) then 
                _gd->Parent->Invalidate()
               ' RootScreen->Redraw()
            end if
        case &h52 'fillRectangle
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            dim _x1 as unsigned integer = stack->ECX shr 16
            dim _y1 as unsigned integer = stack->ECX and &hFFFF
            dim _x2 as unsigned integer = stack->EDX shr 16
            dim _y2 as unsigned integer = stack->EDX and &hFFFF
            dim _c as unsigned integer = stack->ESI
            dim _a as unsigned integer = _c shr 24
            
            if (_gd<>0) then 
                if (_a = 0 or _a = 255) then
                    _gd->FillRectangle(_x1,_y1,_x2,_y2,_c)
                else
                    _gd->FillRectangleAlpha(_x1,_y1,_x2,_y2,_c)
                end if
            end if
            if (_gd->Parent<>0) then
                _gd->Parent->Invalidate()
              '  RootScreen->Redraw()
            end if
		case &h53 'draw text
		
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
			dim txt as unsigned byte ptr = cptr(unsigned byte ptr,stack->ESI)
			dim _x as unsigned integer = stack->ECX shr 16
            dim _y as unsigned integer = stack->ECX and &hFFFF
			dim c as unsigned integer = stack->EDX
			_gd->DrawText(txt,_x,_y,c,FontManager.ML,1)
            if (_gd->Parent<>0) then
                _gd->Parent->Invalidate()
            end if
        case &h54'clear
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
			dim c as unsigned integer = stack->EcX
            _gd->Clear(c)
        case &h55 'draw char
		
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
			dim cara as unsigned byte = stack->ESI
			dim _x as unsigned integer = stack->ECX shr 16
            dim _y as unsigned integer = stack->ECX and &hFFFF
			dim c as unsigned integer = stack->EDX
			_gd->DrawChar(cara,_x,_y,c,FontManager.ML,1)
            if (_gd->Parent<>0) then
                _gd->Parent->Invalidate()
            end if
        case &h56 'put buffer
            dim _gd as GDIBase ptr = cptr(GDIBase ptr,stack->EDI)
            dim src as unsigned integer ptr = cptr(unsigned integer ptr,stack->esi)
            dim _w as unsigned integer = stack->EBX shr 16
            dim _h as unsigned integer = stack->EBX and &hFFFF
            dim _x as unsigned integer = stack->ECX shr 16
            dim _y as unsigned integer = stack->ECX and &hFFFF
         
                
            if (stack->EDX = 3) then
                dim src32 as unsigned integer ptr = kalloc(sizeof(unsigned integer)*_w*_h)
                dim src24 as unsigned byte ptr = cptr(unsigned byte ptr,src)
                dim n as unsigned integer = (_w*_h)-1
                dim i as unsigned integer
                for i = 0 to n
                    var b = src24[i*3]
                    var g = src24[i*3+1]
                    var r = src24[i*3+2]
                    src32[i] = (r shl 16) or (g shl 8) or (b) or &hFF000000 
                next i
                _gd->PutOtherRaw(src32,_w,_h,_x,_y)
                kfree(src32)
            else
                _gd->PutOtherRaw(src,_w,_h,_x,_y)
            end if
            if (_gd->Parent<>0) then
                _gd->Parent->Invalidate()
            end if
        case &h60 'OnKeyPress
            dim _g as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            _g->_onUserKeyDown = stack->ECX
        case &h61 'OnMouseClick
            dim _g as GDIBase ptr = cptr(GDIBase ptr,stack->EBX)
            _g->_onUserClick = stack->ECX
        case &h30
            MessageBox.Show( cptr(unsigned byte ptr,stack->EBX), cptr(unsigned byte ptr,stack->ECX),DIALOGButton.OKOnly,CurrentThread)
            currentThread->State=ThreadState.WaitingDialog
            return int20Handler(stack)
        case &h31
            MessageBox.Show( cptr(unsigned byte ptr,stack->EBX), cptr(unsigned byte ptr,stack->ECX),DIALOGButton.NoYes,CurrentThread)
            currentThread->State=ThreadState.WaitingDialog
            return int20Handler(stack)
            
        case &hD0
            stack->EAX = XRES
            stack->EBX = YRES
			
			
        case &hE0 'page alloc
            stack->EAX = (CurrentThread->Owner->SBRK(stack->EBX) shl 12) + ProcessAddress
        case &hE1 'create thread
            var prio = stack->ECX
            if (prio<currentThread->BasePriority) then prio = CurrentThread->BasePriority
            var th = Thread.Create(currentThread->Owner,cptr(sub(p as any ptr),stack->EBX),prio)
            stack->EAX = th->ID
        case &hE2 'yield
            return Scheduler.Switch(stack, Scheduler.Schedule())
        case &hE3 'semaphore init
            var sem = cptr(Semaphore ptr,KAlloc(sizeof(Semaphore)))
            sem->Constructor
            stack->EAX  = cast(unsigned integer,sem)
        case &hE4 'semaphore lock
            var sem = cptr(Semaphore ptr, stack->EBX)
            if (not sem->SemLock(CurrentThread)) then
                return int20Handler(stack)
            end if
        case &hE5 'semaphore unlock
            var sem = cptr(Semaphore ptr, stack->EBX)
            sem->SemUnlock(CurrentThread)
        case &hE6 'load app
            var ctx = vmm_get_current_context()
            var p=Process.Load(cptr(unsigned byte ptr,stack->EBX),0)
            
            ctx->Activate()
            if (p<>0) then 
                    stack->EAX = 1
                    'return Scheduler.Switch(stack, Scheduler.Schedule())
            else
                stack->EBX=0
            end if
		case &hE7 'enter critical
            IRQ_DISABLE(0)
			currentThread->InCritical = 1
		case &hE8 'exit critical
			currentThread->InCritical = 0
            IRQ_ENABLE(0)
		
        case &hFA 'define irq handler
            IRQ_SET_THREAD_HANDLER(stack->EBX,CurrentThread,stack->ECX)
       
        case &hFB 'enable irq
            IRQ_ENABLE(stack->EBX)
			
		case &hFD
			dim proc as Process ptr = cptr(Process ptr,stack->EBX)
			Process.Terminate(proc,0)
			if (proc=currentThread->Owner) then return int20Handler(stack)
		case &hFE
			Process.Terminate(currentThread->Owner,0)
			return int20Handler(stack)
        case &hFF
			return currentThread->DoWait(stack)
            
            
        'concern files
        case &hF00
            var fname = cptr(unsigned byte ptr,stack->ESI)
            dim fsize as unsigned integer  = 0
            var buff = VFS_LOAD_FILE(fname,@fsize)
            stack->ECX = fsize
            if (buff<>0) then
                memcpy(cast(unsigned byte ptr,stack->EDI),buff,fsize)
                KFree(buff)
            end if
        case &hF01
            var fname = cptr(unsigned byte ptr,stack->EBX)
            dim fsize as unsigned integer = stack->ECX
            dim buff as unsigned byte ptr = cptr(unsigned byte ptr,stack->EDX)
            VFS_WRITE_FILE(fname,fsize,buff)
            
        case &hF000 'fopen
            var fname = cptr(unsigned byte ptr,stack->ESI)
            var handle = cptr(FileHandle ptr,KAlloc(sizeof(FileHandle)))
            handle->Constructor()
            if (handle->Open(fname)=1) then
                stack->EAX = cast(unsigned integer,handle)
            else
                handle->destructor()
                KFree(handle)
                stack->EAX = 0
            end if
        case &hF001 'fcreate
            var fname = cptr(unsigned byte ptr,stack->ESI)
            var handle = cptr(FileHandle ptr,KAlloc(sizeof(FileHandle)))
            handle->Constructor()
            handle->Create(fname)
            stack->EAX = cast(unsigned integer,handle)
        case &hF002 'fread
            var handle = cptr(FileHandle ptr,stack->EBX)
            var count = stack->ECX
            var dest = cptr(unsigned byte ptr,stack->EDI)
            stack->EAX = handle->Read(count,dest)
        case &hF003 'fwrite
            var handle = cptr(FileHandle ptr,stack->EBX)
            var count = stack->ECX
            var src = cptr(unsigned byte ptr,stack->ESI)
            handle->Write(count,src)
        case &hF004 'fclose
            var handle = cptr(FileHandle ptr,stack->EBX)
            var doFlush  = stack->ECX
            if (doFlush=1) then handle->Flush()
            handle->Destructor()
            KFree(handle)
        case &hF005 'flen
            var handle = cptr(FileHandle ptr,stack->EBX)
            stack->EAX = handle->FileSize
        case &hF006 'fseek
            var handle = cptr(FileHandle ptr,stack->EBX)
            stack->EAX = handle->LSeek(stack->ECX,stack->EDX)
        case &hF007 'readline
            var handle = cptr(FileHandle ptr,stack->EBX)
            var dest = cptr(unsigned byte ptr,stack->EDI)
            stack->EAX = handle->ReadLine(dest)
        case &hF00A
            var handle = cptr(FileHandle ptr,stack->EBX)
            stack->EAX = handle->FilePos>=handle->FileSize
        case &hF00F
            var path = cptr(unsigned byte ptr,stack->ESI)
            var dst = cptr(VFSDirectoryEntry ptr,stack->EDI)
            var cpt = stack->ECX
            var skip = stack->EDX
            var attrib = stack->EBX
            stack->EAX = VFS_LIST_DIR(path,attrib,dst,skip,cpt )

            
            
        
    end select
    return stack
end function
    