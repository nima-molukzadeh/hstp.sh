Hello,

this code is created by Gemini on my question for a script version alternate to hstr and fzf, as both are too complicated to install, break etc.
As the bash has everythign in it (doing too much, not L/unix in core) but is strong enough to do this, it was the only logical question, why binary, if a fast script can do that and is nearly always aviable. (only good thing about bashes imNho).

Still some or many may find it suitable for their work.

Caution may still need a lot of work and refinement, but due to agpl the next script-guru oder Machine Intellect will offer a better version!

Instuctions:

1. Download
2. open terminal and copy:
3. cp hstp.sh ~/.local/bin/hstp.sh
4. make it executable:
5. chmod +x ~/.local/bin/hstp.sh
6. install needed software:
7. sudo apt install -y xclip
8. bind it in your bash-config (linux mint):
9. [[ -f ~/.local/bin/hstp.sh ]] && source ~/.local/bin/hstp.sh
10. use key: ctrl + R  (it replaces the ugly dumb old search version) (realy, doing so many thing but cant fix that since 20k linux years ?)
