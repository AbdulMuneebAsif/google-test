function RegWrite(key as String, value as String)
    m.sec.write(key, value)
end function

function RegRead(key as string)
    success = m.sec.read(key)
    if m.sec.Exists(key)
        return success
    else
        return invalid
    end if 

end function