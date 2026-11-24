Hello,
hstp.sh = history-picker shell script

This code is created by Gemini on my question for a script version alternate to hstr and fzf, as both are too complicated to install, break etc.

And all becuase to refind and insert:
    sudo apt update && sudo apt upgrade && sudo apt autoremove
        (which also could have been a single "-"uuc (update+upgrade+cleaner) in apt !!!) since felt: 100k linux-years !

It should replace the ugly ctrl+R function which never gives results and is illogical. 

It is also a shell-script!

As the bash has everything in it (doing too much, not L/unix in core) but is strong enough to do this, it was the only logical question, why binary, if a fast script can do that and is nearly always available. (only good thing about bashes imNho).

Still some or many may find it suitable for their work.


!!! Caution may still need a lot of work and refinement, but due to agpl the next script-guru or Machine Intellect will offer a better version!!!!

Instructions:

1. Download
2. open terminal and copy:
3.     cp hstp.sh ~/.local/bin/hstp.sh
4. make it executable:
5.     chmod +x ~/.local/bin/hstp.sh
6. install needed software:
7.     sudo apt install -y xclip
8. bind it in your bash-config (linux mint):
9.     [[ -f ~/.local/bin/hstp.sh ]] && source ~/.local/bin/hstp.sh
10. use key: ctrl + R  


