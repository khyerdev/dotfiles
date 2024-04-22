function emanfm
    set vol 75
    if set -q $1 && string match -qr '^-?[0-9]+(\.?[0-9]*)?$' -- "$1"
        set vol $1
    end
    echo "Playing streamed audio from EmanFM. To stop seeing song names, hit CTRL+C. Then to stop listening, close the terminal, or run 'fg' and hit CTRL+C."
    mpv https://emanfm.isso.moe/stream --volume=$vol &>> /dev/null &
    set last "none"
    while true
        set song (curl -s https://emanfm.isso.moe/metadata)
        if [ $song != $last ]
            echo "Next up: $song"
        end
        sleep 5
        set last $song
    end
end
