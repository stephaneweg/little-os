#define minSlabPower = 5
#define maxSlabPower = 9


    
type SlabEntry field = 1
    NextEntry as SlabEntry ptr
end type

type Slab field =1
    NextSlab as Slab ptr
    FreeList as SlabEntry ptr
    SlabStart as unsigned integer
    ItemSize as unsigned integer
    IsFull as unsigned byte
    
    declare sub Init(isize as unsigned integer)
    declare function Alloc(isize as unsigned integer) as any ptr
    declare function Free(addr as any ptr) as unsigned byte
end type

type SlabMetaData  field=1
    SlabEntry as Slab
    FirstSlab as Slab ptr
    declare function Alloc(s as unsigned integer) as any ptr
    declare sub Free(addr as any ptr)
end type 
dim shared SlabMeta as SlabMetaData
declare sub SlabINIT()
