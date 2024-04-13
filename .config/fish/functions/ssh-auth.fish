function ssh-auth
    if [ $argv[1] = "" ]
        echo "1st argument needs to be the name of a private ed25519 key in $HOME/.ssh"
    else if [ $argv[1] = -kill ]
        pkill ssh-agent
    else
        if not pgrep ssh-agent &>> /dev/null
            ssh-agent | sed 's/.*=/set \0/g' | sed 's/=/ /g' | source
            ssh-add $HOME/.ssh/$argv[1]
        else
            set SSH_AGENT_PID (pgrep ssh-agent); export SSH_AGENT_PID
            echo "Agent already running: $SSH_AGENT_PID"
            set SSH_AUTH_SOCK (find (find /tmp -name "ssh-*" 2>> /dev/null) -name "agent.*" 2>> /dev/null); export SSH_AUTH_SOCK
            ssh-add $HOME/.ssh/$argv[1]
        end
    end
end
