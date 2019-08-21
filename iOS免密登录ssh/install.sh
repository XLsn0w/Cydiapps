#!/bin/bash
shell_root_dir=$(pwd)
shell_file_name="issh.sh"
shell_file=$shell_root_dir"/"$shell_file_name

bash_profile=$HOME"/.bash_profile"
zsh_profile=$HOME"/.zshrc"


function xlog(){
    echo "[log]: "$1
}

if [[ ! -d ~/.issh ]]; then
	mkdir -p ~/.issh
fi

echo "$shell_root_dir" > ~/.issh/rootdir

if [[ "$SHELL" = "/bin/zsh" ]]; then

	sh_profile=$zsh_profile

elif [[ "$SHELL" = "/bin/bash" ]]; then

	sh_profile=$bash_profile

else
	echo "Not Support shell:$SHELL"
	exit
fi


# add issh.sh to shell_profile
xlog "add \"source $shell_file\" to $sh_profile"

grep 'issh.sh' $sh_profile > /dev/null
if [ $? -eq 0 ]; then
    xlog $sh_profile" has include "$shell_file_name" just source it."
else
    xlog "install..."
    echo -e "\nsource $shell_file" >> $sh_profile
fi

# source $sh_profile > /dev/null
xlog "Please Run command:source $sh_profile"