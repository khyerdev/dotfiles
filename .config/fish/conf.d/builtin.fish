function fish_title
    echo $PWD | sed "s*$HOME*~*"
end
