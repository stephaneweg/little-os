#include "xapp.bi"
#include "xapp.bas"


declare sub MAIN(p as unsigned integer)


sub MAIN(p as unsigned integer)
    dim i as unsigned integer = 0
    do
        ConsoleWrite(@"Test X ")
        ConsoleWriteNumber(i,10)
        ConsoleNewLine
        i+=1
    loop
end sub