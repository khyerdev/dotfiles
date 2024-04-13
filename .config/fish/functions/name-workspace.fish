function name-workspace
    set id (hyprctl activeworkspace -j | jq .id)
    if [ $argv[1] = "-clear" ]
        hyprctl dispatch renameworkspace $id $id
    else
        hyprctl dispatch renameworkspace $id $id:$argv[1]
    end
end
