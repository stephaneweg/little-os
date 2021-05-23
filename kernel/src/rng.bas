


function NextRandomNumber(min as unsigned integer,max as unsigned integer) as unsigned integer
    dim mi as unsigned integer=min
    dim ma as unsigned integer=max
    if mi>ma then
        mi=max
        ma=min
    end if
    dim interval as unsigned integer=max-mi
    read_rtc()
    nextR = nextR * 1103515245 + ((((( (day + month*31 + year*365) *24 )+hour) *60)+minute)*60) + second
    read_rtc()
    nextR = nextR * 1103515245 + ((((( (day + month*31 + year*365) *24 )+hour) *60)+minute)*60) + second
    return  min+((cast(unsigned integer ,(nextR / 65536) MOD 32768)) MOD (interval+1))
return 0
end function