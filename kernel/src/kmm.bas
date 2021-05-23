

function PageAlloc(count as unsigned integer) as any ptr
    'var addr = find_free_pages(@kernel_context,1,cuint(KEND),VMM_PAGETABLES_VIRT_START)
    'if (addr=0) then
    '    KERNEL_ERROR(@"Cannot allocate page",0)
    'end if
    var paddr = PMM_ALLOCPAGE(count)
    'identity mapping
    'return vmm_kernel_automap(paddr,PAGE_SIZE*count,VMM_FLAGS_KERNEL_DATA)
    return paddr
end function

sub PageFree(addr as any ptr)
    var paddr = current_context->resolve(addr)
    var count = PMM_FREE(paddr)
    'vmm_kernel_unmap(addr,PAGE_SIZE*count)
end sub


function KAlloc(size as unsigned integer) as any ptr
    return SlabMeta.KAlloc(size)
end function

sub KFree(addr as any ptr)
    SlabMeta.KFree(addr)
end sub