function ttw
    clear
    if test (count $argv) -eq 0
        t ls w_
    else
        t $argv w_
    end
end
