#!/bin/bash

notify-send -u critical "Youtube Downloader 1.0" "Welcome $USER"

if ! type youtube-dl &>/dev/null;then
    DLG=$(yad --form --window-icon="mhykol1.png" \
        --borders=10 \
        --text="youtube-dl not found\n\n  Install it first and run the script again" --button="OK" \
        --title="Youtube Downloader 1.0" --center --undecorated \
    )
    exit
fi

while :; do
    ENTRY=$(yad --form --window-icon="mhykol1.png" --center \
        --borders=10 \
        --title="Youtube Downloader 1.0" \
        --field="Enter Save directory:DIR" \
        --field="Enter youtube url" \
        --field="Play file when downloaded:CHK" \
        --field="Audio only:CHK" \
        )
    RET=$?

    OIFS=$IFS
    IFS="|"
    i=0
    retChoice=()

    for ret in $ENTRY;do 
        retChoice[$i]="$ret"
        i=$(($i+1))
    done

    IFS=$OIFS

    SAVEDIR=${retChoice[0]}
    URL=${retChoice[1]}
    URL=${URL##*'='}
    PLAY=${retChoice[2]}
    AUDIO=${retChoice[3]}
    
    if (( $RET == 1 ));then
        exit
    fi
    if [[ -z $SAVEDIR ]] || [[ -z $URL ]];then
        yad --form --title "Youtube Downloader 1.0" --text="Complete both fields" --center --window-icon="mhykol1.png"
    else
        break
    fi
done

if [[ $AUDIO == FALSE ]]; then
    UTUBE="youtube-dl --newline -i -o $SAVEDIR/%(id)s.%(ext)s $URL"
else
    UTUBE="youtube-dl -f 141/bestaudio -i -o $SAVEDIR/%(id)s.%(ext)s $URL"
fi

$UTUBE 2>/dev/null | while read -r line ; do
   if [[ "$(echo $line | grep '[0-9]*%')" ]];then
      percent=$(echo $line | awk '{print $2}')
      echo "${percent%.*}%"
   fi 
done | yad --progress --auto-close \
            --window-icon="mhykol1.png" \
            --center --undecorated --borders=10 \
            --text="Youtube downloader\n\nDownloading: $URL" --button="gtk-cancel:1" 

if (( $PIPESTATUS == 1 ));then
    rm $(find $SAVEDIR -type f -name $URL.* | grep part) &>/dev/null
    notify-send -t 3000 --icon "dialog-info" "Download cancelled"
    exit
fi

if [[ $PLAY = TRUE ]] &>/dev/null;then
    xdg-open "$SAVEDIR/$URL".*
fi

exit 0